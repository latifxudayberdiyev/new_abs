create or replace package Esbin_Kernel is

  -- Author  : B.URALOV
  -- Purpose : ESBIN (inbound ESB) - yagona kirish nuqtasi. Birlamchi ishga
  --           tushirish har doim mavjud SM process_code orqali
  --           (Core_Api.Execute_Process_Clob / Get_Model_Clob) - istisnosiz.
  --           ESBIN o'zining mustaqil request/response audit-logini yuritadi
  --           (SM'ning o'z logidan/SET_LOG flagidan qat'iy nazar).

  ----
  -- i_User_Id - psbesb/Esb_Api.Execute_Request naqshiga mos: chaqiruvchi
  -- (AUTH moduli/Java qatlami) so'rovni allaqachon autentifikatsiya qilgan va
  -- shifrlangan login/parolni tekshirib, ESBIN uchun real user_id'ni bergan
  -- bo'ladi - ESBIN o'zi endi access_token qabul qilmaydi/tekshirmaydi.
  ----
  Procedure Execute_Request
  (
    i_User_Id        in number,
    i_Method_Code    in varchar2,
    i_Request        in clob,
    i_Ext_Request_Id in varchar2,
    i_Ip_Address     in varchar2 := null,
    o_Response       out clob,
    o_Code           out number,
    o_Msg            out varchar2,
    o_Ora_Msg        out varchar2
  );

  ----
  -- Partner texnik useri login: login/parol (Io_Hash: 'login', 'password',
  -- ixtiyoriy 'client_ip') -> access_token. IP allowlist tekshiruvi parol
  -- tekshirishdan OLDIN bajariladi (CPU-arzon rad, keyin qimmat PBKDF2).
  -- Har qanday rad javobi bir xil generic xabar bilan qaytadi - qaysi qadam
  -- yiqilgani chaqiruvchiga oshkor qilinmaydi.
  ----
  Procedure Login(Io_Hash in out nocopy Core.Hash_t, o_Code out number, o_Msg out varchar2, o_Ora_Msg out varchar2);

  ----
  -- Ixtiyoriy 'access_token'ni (Io_Hash) revoke qiladi. Token topilmasa ham
  -- HAR DOIM muvaffaqiyatli qaytadi (o_Code=0) - token mavjudligini oshkor
  -- qilmaslik uchun. IP allowlist ATAYLAB tekshirilmaydi - token oqib ketgan
  -- deb gumon qilingan taqdirda ham kutilmagan tarmoqdan yopish imkoni bo'lsin.
  ----
  Procedure Logout(Io_Hash in out nocopy Core.Hash_t, o_Code out number, o_Msg out varchar2, o_Ora_Msg out varchar2);

  ----
  -- Admin amali: Io_Hash 'user_id'ni tashiydi - shu texnik userning JORIY
  -- tokeni darhol yaroqsiz qilinadi (partner-user qatorini passiv qilmasdan).
  -- UAPP'ga FAQAT Esbin_Sm_Api orqali (Core_Api'ning guard qilingan process
  -- dispatch'i orqali, xuddi Save_User_Methods/Attach_User_Methods kabi)
  -- ochiladi - tashqi partnerga to'g'ridan-to'g'ri EMAS.
  ----
  Procedure Revoke_Token(Io_Hash in out nocopy Core.Hash_t, o_Code out number, o_Msg out varchar2, o_Ora_Msg out varchar2);

  ----
  -- Asinxron navbatdagi (QUEUED) so'rovlarni bajaradi. Scheduler job
  -- tomonidan davriy chaqirilishi mo'ljallangan (job'ning o'zi hali
  -- ro'yxatga olinmagan - alohida tasdiq bilan).
  ----
  Procedure Run_Async_Queue;

  ----
  -- Admin ekran uchun: userga barcha aktiv metodlar ro'yxatini, har biri
  -- uchun granted (Y/N) belgisi bilan qaytaradi. ESBIN_R_USER_METHOD_REL
  -- CORE button/menu tizimiga bog'lanmaydi - alohida boshqariladi.
  ----
  Procedure Model_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  ----
  -- Userning butun method-dostup to'plamini almashtiradi.
  ----
  Procedure Save_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  ----
  -- Mavjud grantlarni o'chirmasdan, faqat qo'shimcha method_code'larni
  -- biriktiradi.
  ----
  Procedure Attach_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

end Esbin_Kernel;
/
create or replace package body Esbin_Kernel is

  ----
  -- so'ralayotgan process_code/user_id'ni partnerning xom so'rov JSON'iga
  -- qo'shib, Core_Api kutayotgan yagona (flat) JSON obyektini quradi.
  ----
  Function Build_Merged_Request
  (
    i_Request     clob,
    i_Process_Code varchar2,
    i_User_Id      number
  ) return clob is
    v_Merged clob;
  begin
    select Json_Mergepatch(i_Request,
                           '{"process_code":"' || i_Process_Code || '","user_id":' || i_User_Id || '}')
      into v_Merged
      from dual;
    return v_Merged;
  end Build_Merged_Request;

  ----
  -- Asinxron (yoki tugallangan sinxron) so'rovning natijasini qaytaradi.
  -- Lookup kaliti i_Request tanasidan olinadi: {"ext_request_id":"..."}
  -- yoki {"esbin_request_id":123}.
  ----
  Procedure Get_Request_Result
  (
    i_Partner_Code varchar2,
    i_Request      clob,
    o_Response     out clob,
    o_Code         out number,
    o_Msg          out varchar2
  ) is
    v_Ext_Request_Id varchar2(100);
    v_Esbin_Id        number;
    v_Row             Esbin_Requests%rowtype;
    v_Method          Esbin_R_Methods%rowtype;
    v_Response_Clob   clob;
  begin
    o_Code           := Esbin_Const.c_Success_Code;
    v_Ext_Request_Id := Json_Value(i_Request, '$.ext_request_id');
    v_Esbin_Id       := Json_Value(i_Request, '$.esbin_request_id');

    if v_Esbin_Id is not null then
      Esbin_Util.Select_Request(i_Id => v_Esbin_Id, i_Is_Raise => false, o_Request => v_Row);
    elsif v_Ext_Request_Id is not null then
      Esbin_Util.Select_Request_By_Ext_Id(i_Partner_Code   => i_Partner_Code,
                                          i_Ext_Request_Id => v_Ext_Request_Id,
                                          i_Is_Raise        => false,
                                          o_Request         => v_Row);
    end if;

    if v_Row.Id is null or v_Row.Partner_Code != i_Partner_Code then
      o_Code := 404;
      o_Msg  := 'So''rov topilmadi';
      return;
    end if;

    if v_Row.State in
       (Esbin_Const.c_State_Received, Esbin_Const.c_State_Queued, Esbin_Const.c_State_Running) then
      o_Response := '{"esbin_request_id":' || v_Row.Id || ',"state":"' || v_Row.State || '"}';
      return;
    end if;

    Esbin_Util.Select_Method(i_Method_Code => v_Row.Method_Code, o_Method => v_Method);

    begin
      if v_Method.Result_Function is not null then
        -- natija tegishli moduldan jonli olinadi: Function X(i_Ext_Request_Id varchar2, i_Esbin_Request_Id number) return clob
        execute immediate 'begin :1 := ' || v_Method.Result_Function || '(:2, :3); end;'
          using out v_Response_Clob, in v_Row.Ext_Request_Id, in v_Row.Id;
      else
        select Response
          into v_Response_Clob
          from Esbin_Request_Details
         where Request_Id = v_Row.Id;
      end if;
    exception
      when others then
        v_Response_Clob := null;
    end;

    o_Response := '{"esbin_request_id":' || v_Row.Id || ',"state":"' || v_Row.State || '","response":' ||
                  Nvl(v_Response_Clob, 'null') || '}';
  exception
    when others then
      o_Code := -1;
      -- sqlerrm xom holda o_Msg orqali tashqi partnerga (Java gateway orqali)
      -- yetib bormasligi kerak - server-side sabab uchun cms_tag.log/Auth_Audit
      -- ishlatiladi, bu yerda emas.
      o_Msg  := Auth_Const.c_Msg_Sys_Error;
  end Get_Request_Result;

  Procedure Execute_Request
  (
    i_User_Id        in number,
    i_Method_Code    in varchar2,
    i_Request        in clob,
    i_Ext_Request_Id in varchar2,
    i_Ip_Address     in varchar2 := null,
    o_Response       out clob,
    o_Code           out number,
    o_Msg            out varchar2,
    o_Ora_Msg        out varchar2
  ) is
    v_User_Id      number := i_User_Id;
    v_Partner_Code varchar2(50);
    v_Method       Esbin_R_Methods%rowtype;
    v_Row          Esbin_Requests%rowtype;
    v_Merged       clob;
  begin
    -- Auth_Api_Gateway.Execute bilan bir xil intizom (qarang paket boshidagi
    -- izoh): HAR chaqiruv boshida, hech qanday ish boshlanmasdan oldin, butun
    -- UAPP namespace tozalanadi - pool'langan ulanishda oldingi so'rovdan
    -- qolgan cb_code/local_code/lang/oper_day/user_location kabi maydonlarga
    -- (Set_System_Actor faqat user_id'ni tozalaydi) ishonilmasin.
    Auth_Session.Clear_Context;
    Core.User_Context.Clear_Context;

    o_Code := Esbin_Const.c_Success_Code;

    -- 1) user -> partner. Access_token endi bu yerda tekshirilmaydi - chaqiruvchi
    -- (AUTH moduli/Java qatlami) shifrlangan login/parolni allaqachon tekshirib,
    -- real user_id'ni bergan (psbesb/Esb_Kernel.Execute_Request naqshiga mos).
    begin
      select Partner_Code
        into v_Partner_Code
        from Esbin_R_Partner_Users
       where User_Id = v_User_Id
         and State = 'A';
    exception
      when no_data_found then
        o_Code    := 401;
        o_Msg     := 'User hech qanday faol hamkorga bog''lanmagan: ' || v_User_Id;
        o_Ora_Msg := o_Msg;
        return;
    end;

    -- 2) natija so'rash - alohida (infratuzilma) yo'l, ESBIN_R_METHODS'da ro'yxatga olinmaydi
    if i_Method_Code = Esbin_Const.c_Method_Get_Result then
      Get_Request_Result(i_Partner_Code => v_Partner_Code,
                         i_Request      => i_Request,
                         o_Response     => o_Response,
                         o_Code         => o_Code,
                         o_Msg          => o_Msg);
      return;
    end if;

    -- 3) method
    begin
      Esbin_Util.Select_Method(i_Method_Code => i_Method_Code, o_Method => v_Method);
    exception
      when no_data_found then
        o_Code    := 404;
        o_Msg     := 'Method topilmadi: ' || i_Method_Code;
        o_Ora_Msg := o_Msg;
        return;
    end;
    if v_Method.State != 'A' then
      o_Code    := 404;
      o_Msg     := 'Method active emas: ' || i_Method_Code;
      o_Ora_Msg := o_Msg;
      return;
    end if;

    -- 4) partnerning shu user orqali kirishi (1-qadamda State='A' bilan aniqlangan, qo'shimcha himoya)
    if not Esbin_Util.Has_Partner_User(i_Partner_Code => v_Partner_Code, i_User_Id => v_User_Id) then
      o_Code    := 403;
      o_Msg     := 'Ruxsat yo''q';
      o_Ora_Msg := o_Msg;
      return;
    end if;

    -- 4a) userning aynan shu methodga dostupi bormi - ESBIN_R_USER_METHOD_REL
    --     orqali alohida boshqariladi, CORE button/menu tizimiga bog'lanmaydi.
    if not Esbin_Util.Has_User_Method_Rel(i_User_Id => v_User_Id, i_Method_Code => i_Method_Code) then
      o_Code    := 403;
      o_Msg     := 'Bu methodga dostup yo''q: ' || i_Method_Code;
      o_Ora_Msg := o_Msg;
      return;
    end if;

    -- 5) idempotentlik
    if v_Method.Is_Idempotent = 'Y' and
       Esbin_Util.Has_Request_By_Ext_Id(i_Partner_Code => v_Partner_Code, i_Ext_Request_Id => i_Ext_Request_Id) then
      o_Code    := 409;
      o_Msg     := 'Bu ext_request_id uchun so''rov allaqachon mavjud: ' || i_Ext_Request_Id;
      o_Ora_Msg := o_Msg;
      return;
    end if;

    -- 6) ESBIN'ning o'z jurnaliga yozish
    v_Row.Id             := Esbin_Request_Sq.Nextval;
    v_Row.Ext_Request_Id := i_Ext_Request_Id;
    v_Row.Partner_Code   := v_Partner_Code;
    v_Row.User_Id        := v_User_Id;
    v_Row.Method_Code    := i_Method_Code;
    v_Row.Sync_Type      := v_Method.Synchronize_Type;
    v_Row.Created_On     := sysdate;
    v_Row.Ip_Address     := i_Ip_Address;
    v_Row.State          := case
                              when v_Method.Synchronize_Type = Esbin_Const.c_Sync_Type_A then
                               Esbin_Const.c_State_Queued
                              else
                               Esbin_Const.c_State_Received
                            end;
    Esbin_Dml.Insert_Request(v_Row);

    -- 7) asinxron: darhol navbatga qo'yib qaytaramiz. So'rov matni har doim
    --    saqlanadi (ADD_LOG'dan qat'iy nazar) - keyin Run_Async_Queue uchun
    --    zarur, bu shunchaki logging emas.
    if v_Method.Synchronize_Type = Esbin_Const.c_Sync_Type_A then
      Esbin_Dml.Insert_Request_Detail(i_Request_Id => v_Row.Id, i_Request => i_Request, i_Response => null);
      o_Response := '{"esbin_request_id":' || v_Row.Id || ',"state":"' || Esbin_Const.c_State_Queued || '"}';
      return;
    end if;

    -- 8) sinxron: darhol bajarish
    if v_Method.Add_Log = 'Y' then
      Esbin_Dml.Insert_Request_Detail(i_Request_Id => v_Row.Id, i_Request => i_Request, i_Response => null);
    end if;

    Esbin_Dml.Update_Request_State(i_Id => v_Row.Id, i_State => Esbin_Const.c_State_Running, i_Started_On => sysdate);
    v_Merged := Build_Merged_Request(i_Request      => i_Request,
                                     i_Process_Code => v_Method.Process_Code,
                                     i_User_Id      => v_User_Id);
    begin
      -- Core_Api.Check_Process_Access identitetni Core.User_Env.Get_User_Id
      -- (SYS_CONTEXT('UAPP','user_id')) orqali oladi - JSON'dagi user_id buni
      -- QONOATLANTIRMAYDI. Auth_Api_Gateway.Execute'dagi bilan bir xil intizom:
      -- har chiqish yo'lida (muvaffaqiyat VA xato) Clear_System_Actor chaqiriladi -
      -- ulanish pool'langan, kontekst oqib qolsa keyingi so'rov ESBIN userining
      -- identitetini meros qilib oladi.
      Auth_Session.Set_System_Actor(v_User_Id);
      if v_Method.Request_Type = Esbin_Const.c_Request_Type_Get then
        o_Response := Core_Api.Get_Model_Clob(v_Merged);
      else
        Core_Api.Execute_Process_Clob(v_Merged);
        -- Core_Api.Execute_Process_Clob o'zi commit qilmaydi - chaqiruvchi
        -- javobgar (butun sessiya davomida shu konvensiya kuzatildi).
        commit;
        o_Response := '{"success":true}';
      end if;
      Auth_Session.Clear_Context;
      Core.User_Context.Clear_Context;
      Esbin_Dml.Update_Request_State(i_Id => v_Row.Id, i_State => Esbin_Const.c_State_Success, i_Finished_On => sysdate);
    exception
      when others then
        Auth_Session.Clear_Context;
        Core.User_Context.Clear_Context;
        rollback;
        o_Code    := -1;
        -- sqlerrm xom holda o_Msg orqali tashqi partnerga (Java gateway orqali)
        -- yetib bormasligi kerak.
        o_Msg     := Auth_Const.c_Msg_Sys_Error;
        o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
        Esbin_Dml.Update_Request_State(i_Id => v_Row.Id, i_State => Esbin_Const.c_State_Error, i_Finished_On => sysdate);
    end;

    if v_Method.Add_Log = 'Y' then
      Esbin_Dml.Insert_Request_Detail(i_Request_Id => v_Row.Id,
                                      i_Request     => i_Request,
                                      i_Response    => Nvl(o_Response, '{"error":"SYS_ERROR"}'));
    end if;
  exception
    when others then
      o_Code    := -1;
      -- sqlerrm xom holda o_Msg orqali tashqi partnerga yetib bormasligi kerak
      -- (Java gateway reach); o_Ora_Msg server-side logging uchun, o'zgarishsiz.
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Execute_Request;

  Procedure Run_Async_Queue is
    v_Method       Esbin_R_Methods%rowtype;
    -- Bo'sh (hech qachon assign qilinmaydigan) rowtype - v_Method'ni har
    -- iteratsiya boshida "reset" qilish uchun ishlatiladi. PL/SQL %rowtype
    -- o'zgaruvchisiga literal NULL bevosita berilmaydi (PLS-00382).
    c_Empty_Method Esbin_R_Methods%rowtype;
    v_Request      clob;
    v_Merged       clob;
    v_Response     clob;
    v_Claimed      pls_integer;
  begin
    -- Eslatma: bir vaqtning o'zida faqat bitta worker ishlashi ko'zda
    -- tutilgan (hozircha haqiqiy scheduler job ro'yxatga olinmagan - alohida
    -- tasdiq bilan). Bir nechta worker parallel ishlaydigan bo'lsa, quyidagi
    -- "claim" UPDATE'ni bitta atomik amal sifatida ishlatish kifoya - u
    -- avtonom Update_Request_State bilan aralashmasligi uchun ataylab oddiy
    -- (nonavtonom) UPDATE+commit qilingan.
    for r in (select Id, User_Id, Partner_Code, Method_Code
                from Esbin_Requests
               where State = Esbin_Const.c_State_Queued
               order by Id) loop
      -- Har iteratsiya boshida - Auth_Api_Gateway.Execute bilan bir xil
      -- intizom (qarang paket boshidagi izoh): pool'langan ulanishda oldingi
      -- so'rov qoldirgan har qanday UAPP kontekst maydoni (cb_code/local_code/
      -- lang/oper_day/user_location - Set_System_Actor faqat user_id'ni
      -- tozalaydi) keyingi qatorga oqib o'tmasin.
      Auth_Session.Clear_Context;
      Core.User_Context.Clear_Context;

      v_Claimed := 0;
      update Esbin_Requests
         set State      = Esbin_Const.c_State_Running,
             Started_On = sysdate
       where Id = r.Id
         and State = Esbin_Const.c_State_Queued;
      v_Claimed := sql%rowcount;
      commit;

      if v_Claimed = 0 then
        continue; -- boshqa worker allaqachon olgan
      end if;

      -- Har iteratsiya boshida tozalanadi - aks holda oldingi qatorda
      -- Select_Method no_data_found bersa, KEYINGI qatorning exception
      -- handleri eski (boshqa qatorga tegishli) v_Method.Add_Log'ni o'qib qoladi.
      v_Method := c_Empty_Method;

      begin
        Esbin_Util.Select_Method(i_Method_Code => r.Method_Code, o_Method => v_Method);

        select Request
          into v_Request
          from Esbin_Request_Details
         where Request_Id = r.Id;

        -- Navbatga qo'yilgandan keyin partner/user/method revoke qilingan
        -- bo'lishi mumkin (Revoke_Token, partner/user passivga o'tkazilgan,
        -- method o'chirilgan yoki aynan shu userdan method granti olib
        -- tashlangan) - shu holatda Core_Api'ga umuman yubormasdan xato deb
        -- belgilaymiz.
        if v_Method.State != 'A' or
           not Esbin_Util.Has_Partner_User(i_Partner_Code => r.Partner_Code, i_User_Id => r.User_Id) or
           not Esbin_Util.Exists_Active_Partner(i_Partner_Code => r.Partner_Code) or
           not Esbin_Util.Has_User_Method_Rel(i_User_Id => r.User_Id, i_Method_Code => r.Method_Code) then
          Esbin_Dml.Update_Request_State(i_Id => r.Id, i_State => Esbin_Const.c_State_Error, i_Finished_On => sysdate);
          if v_Method.Add_Log = 'Y' then
            Esbin_Dml.Insert_Request_Detail(i_Request_Id => r.Id,
                                            i_Request     => v_Request,
                                            i_Response    => '{"error":"PARTNER_USER_INACTIVE"}');
          end if;
          commit;
        else
          v_Merged := Build_Merged_Request(i_Request      => v_Request,
                                           i_Process_Code => v_Method.Process_Code,
                                           i_User_Id      => r.User_Id);
          -- Sinxron yo'ldagi bilan bir xil intizom - qarang Execute_Request.
          Auth_Session.Set_System_Actor(r.User_Id);
          if v_Method.Request_Type = Esbin_Const.c_Request_Type_Get then
            v_Response := Core_Api.Get_Model_Clob(v_Merged);
          else
            Core_Api.Execute_Process_Clob(v_Merged);
            v_Response := '{"success":true}';
          end if;
          Auth_Session.Clear_Context;
          Core.User_Context.Clear_Context;

          Esbin_Dml.Update_Request_State(i_Id => r.Id, i_State => Esbin_Const.c_State_Success, i_Finished_On => sysdate);
          if v_Method.Add_Log = 'Y' then
            Esbin_Dml.Insert_Request_Detail(i_Request_Id => r.Id, i_Request => v_Request, i_Response => v_Response);
          end if;
          commit;
        end if;
      exception
        when others then
          Auth_Session.Clear_Context;
          Core.User_Context.Clear_Context;
          -- Muvaffaqiyatsiz Core_Api chaqiruvidan qolgan har qanday yarim DML
          -- asosiy tranzaksiyada bo'lishi mumkin - COMMIT emas, ROLLBACK
          -- qilinadi (sinxron yo'ldagi Execute_Request handleri bilan bir xil
          -- intizom). Pastdagi audit/holat yozuvlari avtonom - shu rollback'ga
          -- bog'liq emas.
          rollback;
          -- Partnerga (Response'ga) generic xato qaytariladi - lekin haqiqiy
          -- sabab hech qayerda yo'qolmasin: server-side-only audit yozuvi
          -- (partnerga hech qachon qaytarilmaydi).
          Auth_Audit.Log(i_Event_Type  => 'ESBIN_ASYNC_ERROR',
                         i_Success     => 'N',
                         i_User_Id     => r.User_Id,
                         i_Provider    => 'ESBIN',
                         i_Reason_Code => sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace);
          Esbin_Dml.Update_Request_State(i_Id => r.Id, i_State => Esbin_Const.c_State_Error, i_Finished_On => sysdate);
          if v_Method.Add_Log = 'Y' then
            Esbin_Dml.Insert_Request_Detail(i_Request_Id => r.Id, i_Request => v_Request, i_Response => '{"error":"SYS_ERROR"}');
          end if;
      end;
    end loop;
  end Run_Async_Queue;

  Procedure Model_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_User_Id number;
    v_List    Core.Arraylist := Core.Arraylist();
    v_Item    Core.Hash_t;
  begin
    o_Code    := Esbin_Const.c_Success_Code;
    v_User_Id := Io_Hash.Get_Number('user_id');

    for r in (select Method_Code, Name
                from Esbin_R_Methods
               where State = 'A'
               order by Method_Code) loop
      v_Item := Core.Hash_t();
      v_Item.Put('method_code', r.Method_Code);
      v_Item.Put('name', r.Name);
      v_Item.Put('granted',
                case
                  when Esbin_Util.Has_User_Method_Rel(i_User_Id => v_User_Id, i_Method_Code => r.Method_Code) then
                   1
                  else
                   0
                end);
      v_List.Push(v_Item);
    end loop;

    Io_Hash.Put('user_id', v_User_Id);
    Io_Hash.Put('methods', v_List);
  exception
    when others then
      o_Code    := -1;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Model_User_Methods;

  Procedure Save_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_User_Id      number;
    v_Method_Codes Core.Array_Varchar2;
  begin
    o_Code         := Esbin_Const.c_Success_Code;
    v_User_Id      := Io_Hash.Get_Number('user_id');
    v_Method_Codes := Io_Hash.Get_Optional_Array_Varchar2('method_codes');
    Esbin_Dml.Sync_User_Methods(i_User_Id => v_User_Id, i_Method_Codes => v_Method_Codes);
  exception
    when others then
      o_Code    := -1;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Save_User_Methods;

  Procedure Attach_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_User_Id      number;
    v_Method_Codes Core.Array_Varchar2;
  begin
    o_Code         := Esbin_Const.c_Success_Code;
    v_User_Id      := Io_Hash.Get_Number('user_id');
    v_Method_Codes := Io_Hash.Get_Optional_Array_Varchar2('method_codes');
    Esbin_Dml.Attach_User_Methods(i_User_Id => v_User_Id, i_Method_Codes => v_Method_Codes);
  exception
    when others then
      o_Code    := -1;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Attach_User_Methods;

  Procedure Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    c_Deny           constant number := 1;
    -- AUTH_LOCKOUTS.USERNAME varchar2(100); Esbin_Const.c_Lockout_Ns ('ESBIN:')
    -- 6 belgi -> login shu chegaradan uzun bo'lmasligi kerak: 6+94=100.
    c_Max_Login_Len  constant pls_integer := 94;

    v_Login_Raw    varchar2(4000);
    v_Login        varchar2(100);
    v_Lockout_Key  varchar2(120);
    v_Password     varchar2(4000);
    v_Client_Ip    varchar2(45);
    v_Locked_Until date;

    v_User_Id     number;
    v_Key_State   varchar2(1);
    v_Stored_Hash varchar2(1000);
    v_u           Core_Users%rowtype;

    v_Partner_Code varchar2(50);
    v_Ttl_Override number;
    v_Ip_Allowlist Esbin_R_Partner_Users.Ip_Allowlist%type;
    v_Ttl_Min      pls_integer;
    v_Token        varchar2(64);

    Procedure Deny(i_Reason varchar2) is
    begin
      Auth_Audit.Log(i_Event_Type  => 'ESBIN_LOGIN_FAIL',
                     i_Success     => 'N',
                     i_Username    => v_Login,
                     i_User_Id     => v_User_Id,
                     i_Provider    => 'ESBIN',
                     i_Reason_Code => i_Reason,
                     i_Client_Ip   => v_Client_Ip);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
    end Deny;
  begin
    o_Code := Esbin_Const.c_Success_Code;

    -- Io_Hash.Get_* dagi xato (masalan 'login' kaliti yo'q) DECLARE bo'limidagi
    -- initializerda bo'lsa, shu blokning O'Z exception handleriga (pastda)
    -- tutilmaydi - shu bois BEGIN tanasidagi birinchi amallar sifatida ko'chirilgan.
    v_Login_Raw := Auth_Util.Norm_Username(Io_Hash.Get_Varchar2('login'));
    v_Password  := Io_Hash.Get_Varchar2('password');
    v_Client_Ip := Io_Hash.Get_Optional_Varchar2('client_ip');

    -- 1) login uzunligi (lockout kalitidan OLDIN - AUTH_LOCKOUTS.USERNAME kesib
    --    tashlanishining oldini olish uchun)
    if Length(v_Login_Raw) > c_Max_Login_Len then
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
      return;
    end if;
    v_Login       := v_Login_Raw;
    v_Lockout_Key := Esbin_Const.c_Lockout_Ns || v_Login;

    -- 2) brute-force lockout
    if Auth_Lockout.Is_Locked(v_Lockout_Key, v_Locked_Until) then
      Auth_Audit.Log(i_Event_Type  => 'ESBIN_LOGIN_LOCKED',
                     i_Success     => 'N',
                     i_Username    => v_Login,
                     i_Provider    => 'ESBIN',
                     i_Reason_Code => Auth_Const.c_Rsn_Locked,
                     i_Client_Ip   => v_Client_Ip);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
      return;
    end if;

    -- 3) LOCAL identity (parol HALI tekshirilmaydi)
    begin
      select User_Id, State, Password
        into v_User_Id, v_Key_State, v_Stored_Hash
        from Core_User_Keys
       where Provider_Type = Auth_Const.c_Provider_Local
         and Provider_Key = v_Login;
    exception
      when no_data_found or too_many_rows then
        Deny(Auth_Const.c_Rsn_Not_Provisioned);
        return;
    end;

    -- 4) key holati
    if v_Key_State != Auth_Const.c_State_Active then
      Deny(Auth_Const.c_Rsn_Key_Passive);
      return;
    end if;

    -- 5) CORE_USERS holati
    begin
      select *
        into v_u
        from Core_Users
       where User_Id = v_User_Id;
    exception
      when no_data_found then
        Deny(Auth_Const.c_Rsn_Not_Provisioned);
        return;
    end;
    if v_u.State != Auth_Const.c_State_Active or
       sysdate not between v_u.Activate_Date and v_u.Deactivate_Date or
       v_u.Is_Access_Denied = 'Y' then
      Deny(Auth_Const.c_Rsn_User_Not_Active);
      return;
    end if;

    -- 6) aktiv partner-user a'zoligi
    begin
      select pu.Partner_Code, p.Token_Ttl_Min, pu.Ip_Allowlist
        into v_Partner_Code, v_Ttl_Override, v_Ip_Allowlist
        from Esbin_R_Partner_Users pu
        join Esbin_R_Partners p on p.Partner_Code = pu.Partner_Code and p.State = 'A'
       where pu.User_Id = v_User_Id
         and pu.State = 'A';
    exception
      when no_data_found or too_many_rows then
        Deny('NOT_PARTNER_USER');
        return;
    end;

    -- 7) IP allowlist - PAROLNI TEKSHIRISHDAN OLDIN (allowlist'dan tashqari
    --    chaqiruvchini CPU-qimmat PBKDF2'ga yetkazmasdan rad etish)
    if not Esbin_Util.Ip_Allowed(v_Client_Ip, v_Ip_Allowlist) then
      Deny('IP_NOT_ALLOWED');
      return;
    end if;

    -- 8) ENDIGINA parol
    if not Auth_Util.Verify_Local_Hash(v_Password, v_Stored_Hash) then
      Auth_Lockout.Register_Failure(v_Lockout_Key);
      Deny(Auth_Const.c_Rsn_Bad_Credentials);
      return;
    end if;

    -- 9) muvaffaqiyat
    Auth_Lockout.Reset(v_Lockout_Key);
    v_Token   := Auth_Util.Random_Token;
    v_Ttl_Min := Nvl(v_Ttl_Override, Esbin_Const.c_Token_Ttl_Min);
    Esbin_Dml.Set_Partner_Token(i_User_Id           => v_User_Id,
                                i_Login              => v_Login,
                                i_Access_Token_Hash  => Auth_Util.Hash_Sha256(v_Token),
                                i_Refresh_Token      => null,
                                i_Expires_On         => sysdate + v_Ttl_Min / 1440);
    commit;
    Auth_Audit.Log(i_Event_Type  => 'ESBIN_LOGIN_OK',
                   i_Success     => 'Y',
                   i_Username    => v_Login,
                   i_User_Id     => v_User_Id,
                   i_Provider    => 'ESBIN',
                   i_Reason_Code => Auth_Const.c_Rsn_Ok,
                   i_Client_Ip   => v_Client_Ip);

    Io_Hash.Put('access_token', v_Token);
    Io_Hash.Put('expires_in', v_Ttl_Min * 60);
    Io_Hash.Put('partner_code', v_Partner_Code);
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Login;

  Procedure Logout
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Token   varchar2(4000) := Io_Hash.Get_Optional_Varchar2('access_token');
    v_User_Id number;
  begin
    o_Code := Esbin_Const.c_Success_Code;
    -- Token bor-yo'qligi/yaroqliligi HECH QACHON oshkor qilinmaydi - shu bois
    -- natija har doim muvaffaqiyatli (o_Code=0), token topilmasa ham.
    -- IP allowlist ATAYLAB tekshirilmaydi: token oqib ketgan deb gumon
    -- qilingan taqdirda ham uni kutilmagan tarmoqdan yopish imkoni bo'lishi kerak.
    if v_Token is not null then
      begin
        select User_Id
          into v_User_Id
          from Esbin_Partner_Tokens
         where Access_Token_Hash = Auth_Util.Hash_Sha256(v_Token)
           and Revoked_On is null;
      exception
        when no_data_found then
          v_User_Id := null;
      end;
      if v_User_Id is not null then
        Esbin_Dml.Revoke_Partner_Token(i_User_Id => v_User_Id, i_Reason => 'LOGOUT');
        Auth_Audit.Log(i_Event_Type  => 'ESBIN_LOGOUT',
                       i_Success     => 'Y',
                       i_User_Id     => v_User_Id,
                       i_Provider    => 'ESBIN',
                       i_Reason_Code => Auth_Const.c_Rsn_Ok,
                       i_Client_Ip   => Io_Hash.Get_Optional_Varchar2('client_ip'));
      end if;
    end if;
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Logout;

  Procedure Revoke_Token
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_User_Id number;
  begin
    o_Code    := Esbin_Const.c_Success_Code;
    v_User_Id := Io_Hash.Get_Number('user_id');
    Esbin_Dml.Revoke_Partner_Token(i_User_Id => v_User_Id, i_Reason => 'ADMIN_REVOKE');
    Auth_Audit.Log(i_Event_Type  => 'ESBIN_TOKEN_REVOKED',
                   i_Success     => 'Y',
                   i_User_Id     => v_User_Id,
                   i_Provider    => 'ESBIN',
                   i_Reason_Code => Auth_Const.c_Rsn_Ok);
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Revoke_Token;

end Esbin_Kernel;
/
