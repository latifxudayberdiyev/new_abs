create or replace package Core_Api is

  -- Author  : B.URALOV
  -- Created : 18.06.2026 11:25:53
  -- Purpose :
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Process_Clob(i_Json clob);
  ----------------------------------------------------------------------------------------------------
  Function Get_Model_Clob(i_Json clob) return clob;
  ----------------------------------------------------------------------------------------------------
  -- "Bitta eshik" - har qanday JSP sahifa uchun holatsiz o'qish (menyu/dashboard/...).
  -- i_Json: {"page_url":"..."}. page_url - chaqiruvchi JSP'ning o'z
  -- request.getServletPath()'i (client parametri emas - server qaysi JSP
  -- ishga tushganini aniqlagan qiymat, shuning uchun soxtalashtirib bo'lmaydi,
  -- avvalgi "read_code" client parametri esa soxtalashtirilishi mumkin edi).
  -- page_url CORE_R_MENUS orqali CORE_R_API_READS'ga bog'lanadi (deploy vaqtida
  -- yoziladi, UAPP hech qachon yozmaydi). menu_id chaqiruvchidan QABUL
  -- QILINMAYDI - registry qatoridan o'qiladi, shu bilan sahifa-spoofing yopiladi
  -- (xuddi Core_Sidebar.Get_User_Menu user_id'ni hech qachon parametr sifatida
  -- qabul qilmasligi kabi). Noma'lum/faol-emas/ruxsat-yo'q/kontekst-yo'q - barchasi
  -- BIR XIL bo'sh javobga tushadi (enumeration'ga qarshi, farqlanmaydigan xato).
  -- Natija: {"access":"Y|N","buttons":[...],"data":{...}}
  Function Get_Page_Init(i_Json clob) return clob;
  ----------------------------------------------------------------------------------------------------
  -- PageInitFilter uchun (UAPP faqat Core_Api'ni ko'radi - Check_Process_Access/Is_Debug_User
  -- ICHKI, package spec'da yo'q, UAPP ularga hech qachon to'g'ridan-to'g'ri kira olmaydi):
  --
  -- Get_User_Process_Codes - joriy userga grant qilingan har bir button uchun process_code
  -- (EXECUTE_PROCESS eshigi) VA model_process_code (GET_MODEL eshigi, agar bo'lsa) - ya'ni
  -- Check_Process_Access MAPPED_AUTHORIZED beradigan kodlar to'plami. Sahifa-ichidagi
  -- <t:button>/?process_code= erta tekshiruvi uchun (asl darvoza baribir Check_Process_Access).
  procedure Get_User_Process_Codes(o_Codes out Array_Varchar2);
  ----------------------------------------------------------------------------------------------------
  -- RO'YXATGA OLINGAN (foydalanuvchidan qat'i nazar) barcha faol process_code/model_process_code -
  -- "bu kod umuman nazoratga olinganmi" tekshiruvi uchun (Check_Process_Access'ning UNMAPPED
  -- qoidasi bilan bir xil mantiq: nazoratga olinmagan kod bloklanmaydi, bosqichma-bosqich joriy).
  procedure Get_All_Process_Codes(o_Codes out Array_Varchar2);
  ----------------------------------------------------------------------------------------------------
  -- Is_Debug_User(Core.User_Env.Get_User_Id) ning JDBC/JSP uchun varchar2 ('Y'/'N') qobig'i -
  -- PL/SQL BOOLEAN standart JDBC orqali chaqirilmaydi.
  Function Is_Debug return varchar2;
end Core_Api;
/
create or replace package body Core_Api is
  ----------------------------------------------------------------------------------------------------
  -- Process-code guard uchun "eshik" nomlari (CORE_PROCESS_ACCESS_LOG.door / CORE_R_MENU_BUTTONS
  -- ustun tanlovi shu bilan aniqlanadi - Execute_Process_Clob har doim process_code ustuniga,
  -- Get_Model_Clob har doim model_process_code ustuniga qarshi tekshiriladi).
  c_Door_Execute_Process constant varchar2(20) := 'EXECUTE_PROCESS';
  c_Door_Get_Model       constant varchar2(20) := 'GET_MODEL';
  --
  c_Outcome_Unmapped           constant varchar2(20) := 'UNMAPPED';
  c_Outcome_Mapped_Authorized  constant varchar2(20) := 'MAPPED_AUTHORIZED';
  c_Outcome_Mapped_Denied      constant varchar2(20) := 'MAPPED_DENIED';
  -- Cross-door escalation: GET_MODEL eshigiga (Get_Model_Clob) process_type != 'GET' bo'lgan
  -- process_code kelsa (Sm_Kernel.Set_Method dispatch process_type'ga qarab ishlaydi, Core_Api
  -- eshigiga emas) - bu holda code SM_R_PROCESSES'da haqiqatan mavjud, lekin GET_MODEL uchun
  -- noto'g'ri turdagi process, shu sabab UNMAPPED bilan bir xil "noma'lum" sifatida yozilsa,
  -- eskalatsiya ko'rinmas bo'lib qoladi (masking). Shu uchun alohida outcome.
  c_Outcome_Wrong_Door_Type    constant varchar2(20) := 'WRONG_DOOR_TYPE';
  -- NO_USER_CTX: process_code mapped (CORE_R_MENU_BUTTONS'da qator bor), lekin
  -- Core.User_Env.Get_User_Id NULL - grant so'roviga yetib bormasdan alohida ajratiladi,
  -- shu bilan "kontekst yo'q" "foydalanuvchi bor-u granti yo'q" (MAPPED_DENIED) dan
  -- log'da farqlanadi.
  c_Outcome_No_User_Ctx        constant varchar2(20) := 'NO_USER_CTX';
  -- GUARD_ERROR: qaror-berish so'rovlarining o'zi (SELECT'lar, hash accessor) kutilmagan
  -- xato berdi - "guard qaror bera olmadi" degani, LOG-bosqichdagidek jimgina yutilib
  -- ALLOW'ga aylanmaydi (Check_Process_Access sarlavha izohiga qarang - fail-closed).
  c_Outcome_Guard_Error        constant varchar2(20) := 'GUARD_ERROR';
  -- FOREIGN_PROCESS_ID: so'rovda process_code yo'q, faqat process_id (Sm_Kernel.Set_Method'ning
  -- process_id-based rerun yo'li - Sm_Kernel.pck qatoriga qarang: process_id mavjud bo'lsa,
  -- process_code UMUMAN o'qilmaydi/e'tiborga olinmaydi, Rerun_Process/Sm_Init.Reinit_Process_Data
  -- orqali Io_Hash SM_PROCESS_EVENTS'dagi saqlangan tarixiy so'rov bilan TO'LIQ almashtiriladi).
  -- Bu yerda SM_PROCESSES'dan process_id bo'yicha process_code va created_by aniqlanadi - agar
  -- qator topilmasa YOKI topilgan qatorning created_by'i joriy foydalanuvchi (v_User_Id) bilan
  -- mos kelmasa, bu boshqa foydalanuvchining jarayonini davom ettirishga (IDOR) urinish sifatida
  -- alohida, ko'rinadigan outcome bilan belgilanadi (na UNMAPPED, na MAPPED_DENIED bilan
  -- aralashtirilmaydi - sabab boshqacha).
  c_Outcome_Foreign_Process_Id constant varchar2(20) := 'FOREIGN_PROCESS_ID';
  --
  -- Check_Process_Access ichida v_Enforce_Action uchun nomlangan konstantalar (raw literal'lar
  -- o'rniga - c_Outcome_*/c_Door_* konvensiyasiga mos).
  c_Act_Allow                  constant varchar2(20) := 'ALLOW';
  c_Act_Block                  constant varchar2(20) := 'BLOCK';
  c_Act_Warn_Bypass            constant varchar2(20) := 'WARN_BYPASS';
  --
  -- Raise_Application_Error kodlari (raw literal -20000/-20003 o'rniga)
  c_Err_Access_Denied          constant number := -20003; -- Check_Process_Access BLOCK
  c_Err_Process_Failed         constant number := -20000; -- Sm_Kernel.Set_Method xatosi
  ----------------------------------------------------------------------------------------------------
  -- Process-code guard: Write_Access_Log / Is_Debug_User / Check_Process_Access.
  --
  -- Write_Access_Log - AVTONOM yozuvchi. HECH QACHON bloklamaydi, HECH QACHON istisno
  -- chiqarmaydi va chaqiruvchi tranzaksiyasini HECH QACHON commit/rollback qilmaydi
  -- (pragma autonomous_transaction + o'zining mustaqil commit/rollback'i bilan izolyatsiya
  -- qilingan). Bu yerdagi har qanday INSERT xatosi (masalan check-constraint'ga mos
  -- kelmaydigan qiymat) yutiladi va o_Log_Id NULL qaytariladi - BU ATAYLAB VA DOIMIY: log
  -- yozish muvaffaqiyatsizligi ishlab chiqarish yo'lini hech qachon buzmasligi kerak.
  --
  -- Is_Debug_User - Core_Users.Debug='Y' bo'lgan, hozir FAOL (State=Active, Is_Access_Denied=N,
  -- sysdate Activate_Date/Deactivate_Date oralig'ida) foydalanuvchini aniqlaydi. Har qanday
  -- xato (shu jumladan i_User_Id mavjud bo'lmasa) FALSE qaytaradi - fail-closed (debug-bypass
  -- faqat ANIQ tasdiqlangan holatda beriladi, noaniqlikda emas).
  --
  -- Check_Process_Access - qaror qabul qiluvchi "eshik" (call-site entry point, ilgarigi
  -- Log_Process_Access o'rnini bosadi). AVTONOM EMAS - shu sabab o'qish-so'rovlari (SELECT'lar)
  -- chaqiruvchining joriy tranzaksiyasi doirasida ishlaydi (faqat SELECT, hech narsa yozmaydi/
  -- o'zgartirmaydi), so'ng haqiqiy yozishni avtonom Write_Access_Log'ga topshiradi, so'ng kerak
  -- bo'lsa bloklaydi (Raise_Application_Error). DIQQAT (LOG-bosqichdan farqli, ATAYLAB): qaror
  -- yo'lidagi (decision-path) kutilmagan xatolar BU YERDA JIMGINA YUTILMAYDI - ular GUARD_ERROR
  -- outcome'iga aylanadi, bu esa ENFORCE_DOOR/ENFORCE rejimlarida BLOKLAYDI. Sabab: jonli bank
  -- tizimida "guard qaror bera olmadi" degani "yo'q" (deny) degani bo'lishi kerak, "ha" (allow)
  -- emas - shu bilan fail-open emas, fail-closed tamoyili ta'minlanadi.
  --
  -- ESLATMA (Get_Model_Clob'ga xos, kutilmagan bo'lmasligi uchun ATAYLAB shu yerda
  -- hujjatlashtirilgan): Get_Model_Clob'ning 'params' massiv-loop'i har bir elementni ketma-ket
  -- qayta ishlaydi - agar Check_Process_Access N-elementda BLOKlasa (Raise_Application_Error),
  -- 1..N-1 elementlar bu N-elementdan OLDIN allaqachon muvaffaqiyatli bajarilgan bo'ladi va bu
  -- ORQAGA QAYTARILMAYDI (rollback qilinmaydi). Bu QABUL QILINGAN xatti-harakat, chunki
  -- Get_Model_Clob tub mohiyatan O'QISH (read) yo'li - lekin bu keyingi o'quvchini
  -- ajablantirmasligi uchun bu yerda ANIQ aytib qo'yiladi.
  Procedure Write_Access_Log
  (
    i_User_Id        number,
    i_Process_Code   varchar2,
    i_Door           varchar2,
    i_Outcome        varchar2,
    i_Would_Block    varchar2,
    i_Enforce_Action varchar2,
    i_Session_Id     varchar2,
    i_Process_Id     number,
    o_Log_Id         out number
  ) is
    pragma autonomous_transaction;
  begin
    o_Log_Id := Core_Process_Access_Log_Sq.Nextval;
    insert into Core_Process_Access_Log
      (log_id, event_on, user_id, process_code, door, outcome, would_block, session_id, process_id, enforce_action)
    values
      (o_Log_Id, sysdate, i_User_Id, i_Process_Code, i_Door, i_Outcome, i_Would_Block, i_Session_Id, i_Process_Id, i_Enforce_Action);
    commit;
  exception
    when others then
      begin
        rollback;
      exception
        when others then null;
      end;
      o_Log_Id := null;
  end Write_Access_Log;
  ----------------------------------------------------------------------------------------------------
  Function Is_Debug_User(i_User_Id number) return boolean is
    v_Debug Core_Users.Debug%type;
  begin
    if i_User_Id is null then return false; end if;
    select Nvl(u.Debug, 'N') into v_Debug
      from Core_Users u
     where u.User_Id          = i_User_Id
       and u.State            = Core_Const.c_State_Active
       and u.Is_Access_Denied = 'N'
       and Trunc(sysdate) between u.Activate_Date and u.Deactivate_Date;
    return v_Debug = 'Y';
  exception
    when others then return false;
  end Is_Debug_User;
  ----------------------------------------------------------------------------------------------------
  Procedure Check_Process_Access(i_Hash Core.Hash_t, i_Door varchar2) is
    v_User_Id        number;
    v_Process_Code   varchar2(100);
    v_Process_Id     number;
    v_Mapped_Cnt     number;
    v_Grant_Cnt      number;
    v_Outcome        varchar2(20);
    v_Would_Block    varchar2(1);
    v_Enforce_Action varchar2(20);
    v_Mode_Blocks    boolean;
    v_Session_Id     varchar2(64);
    v_Process_Type   Sm_R_Processes.Process_Type%type;
    v_Log_Id         number;
    v_Resolved_Owner Sm_Processes.Created_By%type;
  begin
    -- Qaror-berish bloki: shu blokning ICHIDAGI har qanday kutilmagan xato (hash accessor,
    -- SELECT'lar, ...) GUARD_ERROR outcome'iga aylanadi - pastdagi umumiy "when others" bilan
    -- jimgina yutilmaydi (yuqoridagi sarlavha izohiga qarang).
    begin
      -- Forenzik korrelyatsiya: DB-sessiya identifikatori (jadval izohiga qarang - bu UAPP
      -- token-hash asosidagi sessiya bilan bir xil emas, faqat qo'shimcha iz). ATAYLAB shu
      -- blokning BIRINCHI operatori - agar pastdagi hash accessor'lar (masalan mahalliy
      -- o'zgaruvchiga sig'maydigan qiymat, ORA-06502) yoki boshqa o'qishlar xato bersa, ijro
      -- GUARD_ERROR handler'iga o'tadi; v_Session_Id shu vaqtga qadar allaqachon to'ldirilgan
      -- bo'lishi SHART - aks holda aynan forenzik jihatdan eng muhim (xato) qatorlarda
      -- sessiya-korrelyatsiyasi yo'qolib qolardi.
      v_Session_Id   := Sys_Context('USERENV', 'SESSIONID');
      v_User_Id      := Core.User_Env.Get_User_Id;
      v_Process_Code := i_Hash.Get_Optional_Varchar2('process_code');
      v_Process_Id   := i_Hash.Get_Optional_Number('process_id');
      --
      -- process_id-based rerun (Sm_Kernel.Set_Method, ~1027-1034-qatorlar): process_id
      -- so'rovda BOR bo'lsa, Sm_Kernel process_code'ni UMUMAN o'qimaydi/e'tiborga olmaydi -
      -- Rerun_Process -> Sm_Init.Reinit_Process_Data orqali butun Io_Hash SM_PROCESS_EVENTS'da
      -- saqlangan tarixiy so'rov bilan TO'LIQ almashtiriladi). Shu sabab (chaqiruvchi process_code
      -- yuborgan bo'lsa ham) process_id mavjud bo'lganda SHU YERDA ham process_code SM_PROCESSES
      -- (process_id, process_code, created_by) bo'yicha aniqlanadi va faqat joriy foydalanuvchiga
      -- (created_by = v_User_Id) tegishli bo'lsagina davom ettiriladi - aks holda boshqa
      -- foydalanuvchining jarayonini davom ettirish (IDOR) bo'lardi.
      if v_Process_Id is not null then
        begin
          select p.process_code, p.created_by
            into v_Process_Code, v_Resolved_Owner
            from Sm_Processes p
           where p.process_id = v_Process_Id;
          --
          if v_User_Id is null or v_Resolved_Owner != v_User_Id then
            v_Outcome := c_Outcome_Foreign_Process_Id;
          end if;
        exception
          when No_Data_Found then
            v_Outcome      := c_Outcome_Foreign_Process_Id;
            v_Process_Code := null;
        end;
      end if;
      --
      if v_Outcome is not null then
        null; -- yuqorida (process_id resolution) allaqachon hal qilindi (Foreign_Process_Id)
      elsif v_Process_Code is null then
        v_Outcome := c_Outcome_Unmapped;
      else
        select count(*)
          into v_Mapped_Cnt
          from Core_R_Menu_Buttons b
         where (case when i_Door = c_Door_Execute_Process then b.process_code else b.model_process_code end) =
               v_Process_Code
           and b.state = Core_Const.c_State_Active;
        --
        if v_Mapped_Cnt = 0 then
          v_Outcome := c_Outcome_Unmapped;
          -- Cross-door escalation tekshiruvi: FAQAT GET_MODEL eshigi uchun - CORE_R_MENU_BUTTONS
          -- orqali model_process_code sifatida bog'lanmagan bo'lsa ham, kod SM_R_PROCESSES'da
          -- to'g'ridan-to'g'ri (CORE_R_MENU_BUTTONS'dan mustaqil) mavjudligini va process_type'ini
          -- tekshiramiz - agar mavjud bo'lsa-yu process_type != 'GET' bo'lsa, bu shunchaki
          -- "noma'lum kod" emas, balki GET/o'qish eshigiga POST/OPERATION (yozish) turidagi kod
          -- yuborilgan degani (Sm_Kernel.Set_Method process_type bo'yicha dispatch qiladi, u
          -- eshikni bilmaydi) - alohida, ko'rinadigan outcome bilan belgilanadi.
          if i_Door = c_Door_Get_Model then
            begin
              select p.process_type
                into v_Process_Type
                from Sm_R_Processes p
               where p.process_code = v_Process_Code;
              --
              if v_Process_Type != 'GET' then
                v_Outcome := c_Outcome_Wrong_Door_Type;
              end if;
            exception
              when No_Data_Found then
                null; -- haqiqatan ham noma'lum kod - UNMAPPED sifatida qoladi
            end;
          end if;
        elsif v_User_Id is null then
          -- Mapped, lekin foydalanuvchi konteksti yo'q - 0-qatorli grant so'roviga
          -- yetib bormasdan alohida ajratiladi (c_Outcome_No_User_Ctx izohiga qarang).
          v_Outcome := c_Outcome_No_User_Ctx;
        else
          select count(*)
            into v_Grant_Cnt
            from Core_R_Menu_Buttons b
            join ADM_REL_USER_BUTTONS g
              on g.menu_id = b.menu_id and g.button_id = b.button_id
           where (case when i_Door = c_Door_Execute_Process then b.process_code else b.model_process_code end) =
                 v_Process_Code
             and b.state   = Core_Const.c_State_Active
             and g.user_id = v_User_Id
             and g.state   = Core_Const.c_State_Active
             and sysdate between g.date_activate and g.date_deactivate;
          --
          if v_Grant_Cnt > 0 then
            v_Outcome := c_Outcome_Mapped_Authorized;
          else
            v_Outcome := c_Outcome_Mapped_Denied;
          end if;
        end if;
      end if;
    exception
      when others then
        v_Outcome := c_Outcome_Guard_Error;
    end;
    --
    -- F3: fail-open whitelist emas - faqat ANIQ policy-approved "hech qachon bloklamaydi"
    -- outcome'lar uchun 'N', QOLGAN HAMMASI (shu jumladan kelajakda qo'shiladigan har qanday
    -- yangi c_Outcome_* konstantasi) uchun 'Y' - shu bilan yangi outcome sukut bo'yicha
    -- bloklash-nomzodi hisoblanadi, jimgina ruxsat-berilgan bo'lib qolmaydi.
    v_Would_Block := case
                       when v_Outcome in (c_Outcome_Mapped_Authorized, c_Outcome_Unmapped)
                       then 'N'
                       else 'Y'
                     end;
    --
    v_Mode_Blocks := (Core_Const.c_Process_Guard_Mode = Core_Const.c_Guard_Mode_Enforce and v_Would_Block = 'Y')
                   or (Core_Const.c_Process_Guard_Mode = Core_Const.c_Guard_Mode_Enforce_Door
                       and v_Outcome in (c_Outcome_Wrong_Door_Type, c_Outcome_Guard_Error));
    --
    if v_Mode_Blocks then
      if Is_Debug_User(v_User_Id) then
        v_Enforce_Action := c_Act_Warn_Bypass;
        -- F8: Dbms_Output.Put_Line o'zi istisno chiqarishi mumkin (masalan ORU-10027 -
        -- buffer to'lib ketishi) - bu holat pastdagi Write_Access_Log'ning ishlashiga
        -- HECH QACHON to'sqinlik qilmasligi kerak, shu sabab alohida yutiladi.
        begin
          Dbms_Output.Put_Line('CORE_API GUARD WARNING: ruxsat yo''q (' || v_Outcome || ', ' ||
                                i_Door || '/' || v_Process_Code || ') - DEBUG rejimi, baribir bajarilmoqda.');
        exception
          when others then null;
        end;
      else
        v_Enforce_Action := c_Act_Block;
      end if;
    else
      v_Enforce_Action := c_Act_Allow;
    end if;
    --
    Write_Access_Log(
      i_User_Id        => v_User_Id,
      i_Process_Code   => v_Process_Code,
      i_Door           => i_Door,
      i_Outcome        => v_Outcome,
      i_Would_Block    => v_Would_Block,
      i_Enforce_Action => v_Enforce_Action,
      i_Session_Id     => v_Session_Id,
      i_Process_Id     => v_Process_Id,
      o_Log_Id         => v_Log_Id
    );
    --
    -- F4: WARN_BYPASS - privileged bypass - AGAR uning audit-yozuvi (Write_Access_Log,
    -- avtonom) muvaffaqiyatsiz bo'lsa (v_Log_Id NULL), buni jimgina "bypass bajarildi, lekin
    -- iz yo'q" holatida qoldirmaymiz - BLOCK'ga eskalatsiya qilinadi (audit-trail bo'lmagan
    -- privileged bypass qabul qilinmaydigan xavf).
    if v_Enforce_Action = c_Act_Warn_Bypass and v_Log_Id is null then
      v_Enforce_Action := c_Act_Block;
    end if;
    --
    if v_Enforce_Action = c_Act_Block then
      -- Ataylab outcome/process_code kiritilMAYDI - faqat log_id (support/DBA
      -- CORE_PROCESS_ACCESS_LOG'da shu log_id bo'yicha tafsilotni topadi). Avtorizatsiya
      -- katalogi haqida hech narsa chaqiruvchiga/brauzerga oqmasligi kerak.
      Raise_Application_Error(c_Err_Access_Denied, 'Ruxsat yo''q (ref: ' || v_Log_Id || ')');
    end if;
  end Check_Process_Access;
  ----------------------------------------------------------------------------------------------------
  Procedure Execute_Process_Clob(i_Json clob) is
    v_Hash    Core.Hash_t;
    v_Code     number;
    v_Msg      varchar2(3000);
    v_Ora_Msg  varchar2(3000);
  begin
Json_Parser.Parse_Json(i_Json, v_Hash);
    --
    Check_Process_Access(v_Hash, c_Door_Execute_Process);
    --
    Sm_Kernel.Set_Method(Io_Hash   => v_Hash,
                         o_Code    => v_Code,
                         o_Msg     => v_Msg,
                         o_Ora_Msg => v_Ora_Msg);
    --
    if v_Code != Sm_Const.c_Success_Code then
      Raise_Application_Error(c_Err_Process_Failed, v_Msg);
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  -- model_process_code -> process_code: t:reference/edit() konvensiyasida
  -- process_code saqlash (POST) uchun, model_process_code esa modelni
  -- o'qish (GET) uchun ishlatiladi (bir xil so'rovda ikkalasi ham keladi,
  -- ammo Sm_Kernel faqat process_code'ni o'qiydi - shuning uchun bu yerda
  -- model_process_code mavjud bo'lsa process_code'ga ko'chiriladi).
  ----------------------------------------------------------------------------------------------------
  Function Get_Model_Clob(i_Json clob) return clob is
    v_Hash       Core.Hash_t := Core.Hash_t();
    v_Params     Core.Arraylist;
    v_Param_Hash Core.Hash_t;
    v_Data       Core.Hash_t := Core.Hash_t();
    v_Code       number;
    v_Msg        varchar2(3000);
    v_Ora_Msg    varchar2(3000);
  begin
    v_Hash   := Json_Parser.Parse_Json(i_Json);
    v_Params := v_Hash.Get_Optional_Arraylist('params');
    --
    -- Yagona (params'siz, tekis) so'rov ham xuddi shu bitta pastdagi tsikl orqali
    -- o'tishi uchun bitta elementli Arraylist'ga o'raladi - ikkita alohida, bir xil
    -- 5-qadamli oqim (rename/Check_Process_Access/Set_Method/xato-tekshiruv/data)
    -- o'rniga bitta.
    if v_Params is null then
      v_Params := Core.Arraylist();
      v_Params.Push(v_Hash);
    end if;
    --
    for i in 1 .. v_Params.count loop
      v_Param_Hash := Treat(v_Params.Get_r_Hash_t(i) as Core.Hash_t);
      --
      if v_Param_Hash.Has('model_process_code') then
        v_Param_Hash.Put('process_code',
                         v_Param_Hash.Get_Varchar2('model_process_code'));
      end if;
      --
      Check_Process_Access(v_Param_Hash, c_Door_Get_Model);
      --
      v_Param_Hash.Put('data', v_Data);
      Sm_Kernel.Set_Method(v_Param_Hash, v_Code, v_Msg, v_Ora_Msg);
      --
      if v_Code != Sm_Const.c_Success_Code then
        Raise_Application_Error(c_Err_Process_Failed, v_Msg);
      end if;
      --
      v_Data := v_Param_Hash.Get_Optional_Hash_t('data');
    end loop;
    --
    return v_Data.Json_Clob;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Get_Page_Init(i_Json clob) return clob is
    v_Hash      Core.Hash_t;
    v_Page_Url  varchar2(1000);
    v_Row       Core_R_Api_Reads%rowtype;
    v_User_Id   number := Core.User_Env.Get_User_Id;
    v_Result    Core.Hash_t := Core.Hash_t();
    v_Buttons   Core.Arraylist := Core.Arraylist();
    v_Data      Core.Hash_t := Core.Hash_t();
    v_Cnt       number;
    v_Code      number;
    v_Msg       varchar2(3000);
    v_Ora_Msg   varchar2(3000);
    v_Sql_Stm   varchar2(500);
  begin
    -- Fail-closed default javob - har chiqish yo'li shu bilan qaytadi,
    -- faqat oxirida hammasi muvaffaqiyatli bo'lsa 'Y'ga almashtiriladi.
    v_Result.Put('access', 'N');
    v_Result.Put('buttons', Core.Arraylist());
    v_Result.Put('data', Core.Hash_t());
    --
    if v_User_Id is null then
      return v_Result.Json_Clob;
    end if;
    --
    begin
      v_Hash     := Json_Parser.Parse_Json(i_Json);
      v_Page_Url := v_Hash.Get_Optional_Varchar2('page_url');
    exception
      when others then
        return v_Result.Json_Clob;
    end;
    --
    if v_Page_Url is null then
      return v_Result.Json_Clob;
    end if;
    --
    begin
      select r.*
        into v_Row
        from Core_R_Api_Reads r
        join Core_R_Menus m on m.Menu_Id = r.Menu_Id
       where m.Page_Url = v_Page_Url
         and r.State = 'A'
         and m.State = 'A';
    exception
      when No_Data_Found then
        return v_Result.Json_Clob;
    end;
    --
    if v_Row.Requires_Context = 'Y' and v_User_Id is null then
      return v_Result.Json_Clob;
    end if;
    --
    -- Sahifa-darajali ruxsat: read_code o'ziga tegishli menu_id'ni registry'dan
    -- olib keladi (chaqiruvchi hech qachon menu_id aytmaydi) - CORE_REL_USER_MENUS
    -- bo'yicha tekshiriladi. menu_id NULL bo'lsa (sahifaga bog'liq bo'lmagan umumiy
    -- o'qish) - bu qadam o'tkazib yuboriladi.
    if v_Row.Menu_Id is not null then
      select count(*)
        into v_Cnt
        from ADM_REL_USER_MENUS
       where user_id = v_User_Id
         and menu_id = v_Row.Menu_Id
         and state   = 'A'
         and sysdate between date_activate and date_deactivate;
      --
      if v_Cnt = 0 then
        return v_Result.Json_Clob;
      end if;
      --
      -- Buttonlar = katalog (shu menyuda qanday buttonlar bor) kesishmasi
      -- foydalanuvchi granti bilan - ikkalasi ham allaqachon mavjud jadvallar,
      -- bu yerda yangi ruxsat manbai YARATILMAYDI.
      for r in (select b.action_code
                  from Core_R_Menu_Buttons b
                  join ADM_REL_USER_BUTTONS g
                    on g.menu_id = b.menu_id and g.button_id = b.button_id
                 where b.menu_id = v_Row.Menu_Id
                   and b.state   = 'A'
                   and g.user_id = v_User_Id
                   and g.state   = 'A'
                   and sysdate between g.date_activate and g.date_deactivate
                 order by b.order_by)
      loop
        v_Buttons.Push(r.action_code);
      end loop;
    end if;
    --
    -- Dispatch: Sm_Kernel.Run_Procedure bilan bir xil bind-safe EXECUTE IMMEDIATE
    -- shakli. procedure_name faqat controlled-deploy orqali yoziladi (jadval
    -- izohiga qarang) - shu invariantga tayanadi.
    v_Sql_Stm := 'begin ' || v_Row.Procedure_Name || '(:1,:2,:3,:4); end;';
    begin
      execute immediate v_Sql_Stm
        using in out v_Data, out v_Code, out v_Msg, out v_Ora_Msg;
    exception
      when others then
        -- Ichki xato tafsilotini JSPga chiqarmaymiz - bir xil bo'sh javob.
        return v_Result.Json_Clob;
    end;
    --
    if v_Code != Core_Const.c_Success_Code then
      return v_Result.Json_Clob;
    end if;
    --
    v_Result.Put('access', 'Y');
    v_Result.Put('buttons', v_Buttons);
    v_Result.Put('data', v_Data);
    return v_Result.Json_Clob;
  end;
  ----------------------------------------------------------------------------------------------------
  -- PageInitFilter delegatlari - Check_Process_Access bilan bir xil grant-manbaga (ADM_REL_USER_BUTTONS)
  -- qaraydi, yangi ruxsat manbai YARATMAYDI, faqat uni sessiya-keshga oldindan chiqarib beradi.
  procedure Get_User_Process_Codes(o_Codes out Array_Varchar2) is
    v_User_Id number := Core.User_Env.Get_User_Id;
  begin
    o_Codes := Array_Varchar2();
    if v_User_Id is null then
      return;
    end if;
    select Code
      bulk collect into o_Codes
      from ( select b.Process_Code as Code
               from Core_R_Menu_Buttons b
               join ADM_REL_USER_BUTTONS g on g.Menu_Id = b.Menu_Id and g.Button_Id = b.Button_Id
              where b.State     = Core_Const.c_State_Active
                and b.Process_Code is not null
                and g.User_Id   = v_User_Id
                and g.State     = Core_Const.c_State_Active
                and sysdate between g.Date_Activate and g.Date_Deactivate
             union
             select b.Model_Process_Code as Code
               from Core_R_Menu_Buttons b
               join ADM_REL_USER_BUTTONS g on g.Menu_Id = b.Menu_Id and g.Button_Id = b.Button_Id
              where b.State     = Core_Const.c_State_Active
                and b.Model_Process_Code is not null
                and g.User_Id   = v_User_Id
                and g.State     = Core_Const.c_State_Active
                and sysdate between g.Date_Activate and g.Date_Deactivate );
  end Get_User_Process_Codes;
  ----------------------------------------------------------------------------------------------------
  procedure Get_All_Process_Codes(o_Codes out Array_Varchar2) is
  begin
    select Code
      bulk collect into o_Codes
      from ( select Process_Code as Code from Core_R_Menu_Buttons
              where State = Core_Const.c_State_Active and Process_Code is not null
             union
             select Model_Process_Code as Code from Core_R_Menu_Buttons
              where State = Core_Const.c_State_Active and Model_Process_Code is not null );
  end Get_All_Process_Codes;
  ----------------------------------------------------------------------------------------------------
  Function Is_Debug return varchar2 is
  begin
    return case when Is_Debug_User(Core.User_Env.Get_User_Id) then 'Y' else 'N' end;
  end Is_Debug;
end Core_Api;
/
