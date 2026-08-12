create or replace package Auth_Session is
  -- Author      : CROBS
  -- Created     : 18.05.2026
  -- Изменён     : 19.05.2026 - idle-slide вынесен в autonomous (не трогает вызывающую
  --                            транзакцию), троттлинг обновления, аудит смены IP.
  -- Назначение  : Серверная сессия (без JWT) + доверенный установщик контекста
  --               приложения "UAPP" (читается CORE.USER_ENV).
  --   ВНИМАНИЕ: пакет указан в  CREATE CONTEXT UAPP USING CORE.AUTH_SESSION
  ----------------------------------------------------------------------------------------------------
  -- Создать сессию. Сырой токен возвращается один раз (хранится только хэш).
  Procedure Create_Session
  (
    i_User_Id    in number,
    i_Provider   in varchar2,
    i_Cb_Code    in varchar2,
    i_Local_Code in varchar2,
    i_Lang       in varchar2,
    i_Client_Ip  in varchar2,
    i_User_Agent in varchar2,
    o_Token      out varchar2,
    o_Ttl_Sec    out number
  );
  ----------------------------------------------------------------------------------------------------
  -- Проверить токен, сдвинуть окно бездействия и загрузить контекст UAPP
  -- для текущей сессии БД. true + o_User_Id при успехе.
  Function Validate
  (
    i_Token     in varchar2,
    i_Client_Ip in varchar2,
    o_User_Id   out number,
    o_Reason    out varchar2
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  Procedure close
  (
    i_Token  varchar2,
    i_Reason varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Очистить контекст UAPP для текущей сессии БД.
  Procedure Clear_Context;
  ----------------------------------------------------------------------------------------------------
  -- Vaqtincha (auth qilinmagan chaqiruvchi uchun) UAPP.user_id'ni o'rnatadi
  -- (default 0 = SYSTEM USER) - masalan, tiklash tokeni orqali parol
  -- o'rnatishda (Auth_Pwd_Kernel.Reset_With_Token). Har doim keyin
  -- Clear_System_Actor bilan tozalanishi kerak - aks holda USER_ENV.Get_User_Id
  -- boshqa avtorizatsiyalanmagan chaqiruvlarda ham shu qiymatni qaytaraveradi.
  Procedure Set_System_Actor(i_User_Id in number default 0);
  ----------------------------------------------------------------------------------------------------
  -- Set_System_Actor bilan qo'yilgan user_id'ni tozalaydi - butun UAPP nomspace'ni
  -- EMAS (agar chaqiruvchida allaqachon haqiqiy sessiya konteksti - cb_code/
  -- local_code/lang/oper_day - bo'lsa, ular buzilmasin uchun).
  Procedure Clear_System_Actor;
  ----------------------------------------------------------------------------------------------------
  Procedure Purge_Expired;
  ----------------------------------------------------------------------------------------------------
  -- Debug: sqlplus orqali (CORE sxemasi ulanishidan) to'g'ridan-to'g'ri
  -- chaqiriladi - login/parolsiz, faqat sababni talab qiladi. i_Cb_Code /
  -- i_Local_Code UCHTA rejimni bildiradi (bir sessiyada istalgancha marta
  -- qayta chaqirilishi mumkin - branch almashtirish uchun):
  --   - faqat i_Local_Code berilsa: FAQAT o'sha filialga dostup (LOCAL rejim),
  --     cb_code Abs_Branches'dan avtomatik olinadi;
  --   - faqat i_Cb_Code berilsa: o'sha bank ostidagi BARCHA locallarga dostup
  --     (CB rejim), kontekst uchun local_code bosh ofisdan (code_header is
  --     null) olinadi;
  --   - ikkalasi ham berilmasa: CHEKLOVSIZ - istalgan local_code'ga dostup
  --     (FULL rejim), kontekst uchun bankning istalgan bosh ofisi ishlatiladi;
  --   - ikkalasi HAM berilsa - xato (noaniq).
  -- Core_Locals.Has_Local_Access/Assert_Local_Access shu rejimni
  -- 'local_access_mode' kontekst atributidan o'qiydi. Doim maxsus DEBUG_USER
  -- (user_id=-100, haqiqiy xodim EMAS) kontekstini o'rnatadi - hech qachon
  -- UAPP'ga grant qilinmaydi, veb/JSP qatlamidan chaqirib bo'lmaydi.
  Procedure Open_Debug_Session
  (
    i_Cb_Code    in varchar2 default null,
    i_Local_Code in varchar2 default null,
    i_Reason     in varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Job: rejalashtirilgan (DBMS_SCHEDULER) job ichidan chaqiriladi - JOB_USER
  -- (user_id=-200) kontekstini o'rnatadi. Faqat haqiqiy scheduler job
  -- ichida ishlaydi (BG_JOB_ID tekshiruvi). Set_System_Actor'dan farqli -
  -- maxsus, discoverable nom va job-ekanligini tekshiruvchi qo'shimcha
  -- himoya bilan. i_Cb_Code/i_Local_Code - Open_Debug_Session bilan bir xil
  -- uchta rejim (LOCAL/CB/FULL, Core_Locals orqali tekshiriladi) va bir
  -- sessiyada istalgancha marta qayta chaqirilishi mumkin. oper_day ham
  -- shu yerda o'rnatiladi (ilgari job'larda umuman yo'q edi).
  Procedure Open_Job_Actor
  (
    i_Cb_Code    in varchar2 default null,
    i_Local_Code in varchar2 default null
  );
  ----------------------------------------------------------------------------------------------------
end Auth_Session;
/
create or replace package body Auth_Session is
  c_Context       constant varchar2(30) := 'UAPP';
  c_Debug_User_Id constant number := -100;
  c_Job_User_Id   constant number := -200;
  -- Resolve_Branch_Mode / Open_Debug_Session / Open_Job_Actor guardrail xato kodlari
  c_Err_Both_Codes_Given  constant number := -20060;
  c_Err_Bad_Local_Code    constant number := -20061;
  c_Err_Bad_Cb_Code       constant number := -20062;
  c_Err_No_Head_Office    constant number := -20063;
  c_Err_Not_Core_Schema   constant number := -20050;
  c_Err_Reason_Too_Short  constant number := -20051;
  c_Err_Not_Scheduler_Job constant number := -20054;
  c_Err_Debug_User_Inactive constant number := -20052;
  ----------------------------------------------------------------------------------------------------
  -- Open_Debug_Session va Open_Job_Actor uchun umumiy: i_Cb_Code/i_Local_Code'dan LOCAL/CB/FULL
  -- rejimini va Abs_Branches orqali mos yozuvni aniqlaydi. i_Fail_On_Empty_Full=false bo'lsa
  -- (Open_Job_Actor), FULL rejimda bosh ofis topilmasa ham xato bermay davom etadi (o_Cb_Code/
  -- o_Local_Code NULL qoladi - job uchun ular faqat ma'lumot, dostup FULL bayrog'iga bog'liq).
  Procedure Resolve_Branch_Mode
  (
    i_Cb_Code            in varchar2,
    i_Local_Code         in varchar2,
    i_Fail_On_Empty_Full in boolean,
    o_Code               out Abs_Branches.Code%type,
    o_Cb_Code            out Abs_Branches.Cb_Code%type,
    o_Local_Code         out Abs_Branches.Local_Code%type,
    o_Mode               out varchar2
  ) is
  begin
    if i_Cb_Code is not null and i_Local_Code is not null then
      Raise_Application_Error(c_Err_Both_Codes_Given,
                              'i_Cb_Code va i_Local_Code''dan faqat bittasi beriladi, ikkalasi emas.');
    end if;
    if i_Local_Code is not null then
      -- LOCAL rejim: faqat shu filialga dostup, cb_code avtomatik olinadi.
      o_Mode := 'LOCAL';
      begin
        select Code, Cb_Code, Local_Code
          into o_Code, o_Cb_Code, o_Local_Code
          from Abs_Branches
         where Local_Code = i_Local_Code
           and Condition = 'A';
      exception
        when No_Data_Found then
          Raise_Application_Error(c_Err_Bad_Local_Code, 'Noto''g''ri yoki nofaol local_code: ' || i_Local_Code);
      end;
    elsif i_Cb_Code is not null then
      -- CB rejim: shu bank ostidagi barcha locallarga dostup, kontekst uchun bosh ofis olinadi.
      o_Mode := 'CB';
      begin
        select Code, Cb_Code, Local_Code
          into o_Code, o_Cb_Code, o_Local_Code
          from Abs_Branches
         where Cb_Code = i_Cb_Code
           and Code_Header is null
           and Condition = 'A';
      exception
        when No_Data_Found then
          Raise_Application_Error(c_Err_Bad_Cb_Code, 'Noto''g''ri yoki nofaol cb_code (bosh ofis topilmadi): ' || i_Cb_Code);
      end;
    else
      -- FULL rejim: cheklovsiz, istalgan local_code'ga dostup. Kontekst/audit uchun
      -- bankning istalgan bosh ofisi ishlatiladi (dostup FULL rejimda bu qiymatga
      -- bog'liq emas - Core_Locals faqat o_Mode='FULL'ni tekshiradi).
      o_Mode := 'FULL';
      begin
        select Code, Cb_Code, Local_Code
          into o_Code, o_Cb_Code, o_Local_Code
          from Abs_Branches
         where Code_Header is null
           and Condition = 'A'
           and rownum = 1;
      exception
        when No_Data_Found then
          if i_Fail_On_Empty_Full then
            Raise_Application_Error(c_Err_No_Head_Office, 'Bosh ofis topilmadi - Abs_Branches bo''sh yoki nofaol.');
          end if;
      end;
    end if;
  end Resolve_Branch_Mode;
  ----------------------------------------------------------------------------------------------------
  Procedure Set_Context(i_Row Auth_Sessions%rowtype) is
  begin
    Sys.Dbms_Session.Set_Context(c_Context, 'user_id', i_Row.User_Id);
    Sys.Dbms_Session.Set_Context(c_Context, 'cb_code', i_Row.Cb_Code);
    Sys.Dbms_Session.Set_Context(c_Context, 'local_code', i_Row.Local_Code);
    Sys.Dbms_Session.Set_Context(c_Context, 'user_location', i_Row.Client_Ip);
    Sys.Dbms_Session.Set_Context(c_Context, 'lang', i_Row.Lang);
    Sys.Dbms_Session.Set_Context(c_Context, 'oper_day', to_char(Trunc(sysdate), 'dd.mm.yyyy'));
    -- Haqiqiy foydalanuvchi sessiyasi hech qachon debug/job'ning FULL/CB/LOCAL
    -- rejimini meros qilib olmasin (Core_Locals shu atributni o'qiydi).
    Sys.Dbms_Session.Set_Context(c_Context, 'local_access_mode', null);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Clear_Context is
  begin
    Sys.Dbms_Session.Clear_Context(c_Context);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Set_System_Actor(i_User_Id in number default 0) is
  begin
    Sys.Dbms_Session.Set_Context(c_Context, 'user_id', i_User_Id);
    -- Faqat shu user_id'ning haqiqiy grantlari ishlaydi - debug/job'dan
    -- meros qolgan FULL/CB/LOCAL rejim bo'lmasin.
    Sys.Dbms_Session.Set_Context(c_Context, 'local_access_mode', null);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Clear_System_Actor is
  begin
    Sys.Dbms_Session.Clear_Context(c_Context, Attribute => 'user_id');
  end;
  ----------------------------------------------------------------------------------------------------
  -- Пометить сессию истёкшей (autonomous: не трогает вызывающую транзакцию).
  Procedure Mark_Expired(i_Hash varchar2) is
    pragma autonomous_transaction;
  begin
    update Auth_Sessions
       set State        = Auth_Const.c_Sess_Expired,
           Closed_On    = sysdate,
           Close_Reason = Auth_Const.c_Rsn_Session_Expired
     where Session_Id_Hash = i_Hash
       and State = Auth_Const.c_Sess_Active;
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
  -- Сдвинуть окно бездействия (autonomous: не трогает вызывающую транзакцию).
  Procedure Slide_Idle
  (
    i_Hash    varchar2,
    i_Abs_Exp date
  ) is
    pragma autonomous_transaction;
  begin
    update Auth_Sessions
       set Last_Seen_On    = sysdate,
           Idle_Expires_On = Least(sysdate + Auth_Const.c_Sess_Idle_Min / 1440, i_Abs_Exp)
     where Session_Id_Hash = i_Hash;
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Create_Session
  (
    i_User_Id    in number,
    i_Provider   in varchar2,
    i_Cb_Code    in varchar2,
    i_Local_Code in varchar2,
    i_Lang       in varchar2,
    i_Client_Ip  in varchar2,
    i_User_Agent in varchar2,
    o_Token      out varchar2,
    o_Ttl_Sec    out number
  ) is
    pragma autonomous_transaction;
    v_User_Type_Id Core_Users.User_Type_Id%type;
  begin
    begin
      select User_Type_Id
        into v_User_Type_Id
        from Core_Users
       where User_Id = i_User_Id;
    exception
      when No_Data_Found then
        v_User_Type_Id := null;
    end;
    o_Token   := Auth_Util.Random_Token(Auth_Const.c_Token_Bytes);
    o_Ttl_Sec := Auth_Const.c_Sess_Idle_Min * 60;
    insert into Auth_Sessions
      (Session_Id_Hash,
       User_Id,
       Provider_Type,
       Cb_Code,
       Local_Code,
       Lang,
       Client_Ip,
       User_Agent,
       Created_On,
       Last_Seen_On,
       Idle_Expires_On,
       Abs_Expires_On,
       State)
    values
      (Auth_Util.Hash_Sha256(o_Token),
       i_User_Id,
       i_Provider,
       i_Cb_Code,
       i_Local_Code,
       i_Lang,
       Substr(i_Client_Ip, 1, 45),
       Substr(i_User_Agent, 1, 400),
       sysdate,
       sysdate,
       sysdate + Auth_Const.c_Sess_Idle_Min / 1440,
       sysdate + Auth_Const.c_Sess_Abs_Min / 1440,
       Auth_Const.c_Sess_Active);
    commit;
    -- Login muvaffaqiyatida UAPP kontekstini shu (login) sessiyasida o'rnatamiz - keyingi
    -- so'rovlarda Core.User_Env.Get_* ishlashi uchun (sidebar menyu, core_dml audit ustunlari
    -- va h.k.). Qiymatlar autentifikatsiyalangan login natijasidan olinadi (client parametri
    -- EMAS - spoofing'ga qarshi). Faqat CORE.AUTH_SESSION UAPP'ni o'rnata oladi, shu bois shu yerda.
    Sys.Dbms_Session.Set_Context(c_Context, 'user_id', i_User_Id);
    Sys.Dbms_Session.Set_Context(c_Context, 'cb_code', i_Cb_Code);
    Sys.Dbms_Session.Set_Context(c_Context, 'local_code', i_Local_Code);
    Sys.Dbms_Session.Set_Context(c_Context, 'user_type_id', v_User_Type_Id);
    Sys.Dbms_Session.Set_Context(c_Context, 'local_access_mode', null);
    Sys.Dbms_Session.Set_Context(c_Context, 'user_location', Substr(i_Client_Ip, 1, 45));
    Sys.Dbms_Session.Set_Context(c_Context, 'lang', i_Lang);
    Sys.Dbms_Session.Set_Context(c_Context, 'oper_day', to_char(Trunc(sysdate), 'dd.mm.yyyy'));
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Validate
  (
    i_Token     in varchar2,
    i_Client_Ip in varchar2,
    o_User_Id   out number,
    o_Reason    out varchar2
  ) return boolean is
    v_Hash        varchar2(64);
    v_Row         Auth_Sessions%rowtype;
    v_Active_Cnt  number;
  begin
    -- Har chaqiruv boshida tozalanadi - pool'langan ulanishda oldingi
    -- muvaffaqiyatli so'rovdan qolgan UAPP konteksti keyingi rad javobida
    -- ham "ko'rinib" qolmasin (Set_Context muvaffaqiyat yo'lida hammasini
    -- qayta o'rnatadi, shuning uchun bu xavfsiz).
    Clear_Context;
    o_Reason := Auth_Const.c_Rsn_Session_Invalid;
    --
    if i_Token is null then
      return false;
    end if;
    --
    v_Hash := Auth_Util.Hash_Sha256(i_Token);
    -- читаем без FOR UPDATE: не держим блокировку строки между запросами
    begin
      select *
        into v_Row
        from Auth_Sessions
       where Session_Id_Hash = v_Hash;
    exception
      when No_Data_Found then
        return false;
    end;
    --
    if v_Row.State != Auth_Const.c_Sess_Active then
      o_Reason := Auth_Const.c_Rsn_Session_Invalid;
      return false;
    end if;
    --
    if v_Row.Abs_Expires_On < sysdate or v_Row.Idle_Expires_On < sysdate then
      Mark_Expired(v_Hash);
      o_Reason := Auth_Const.c_Rsn_Session_Expired;
      return false;
    end if;
    -- троттлинг: окно бездействия сдвигаем не чаще раза в минуту
    -- (иначе каждый параллельный запрос писал бы в одну строку)
    if v_Row.Last_Seen_On < sysdate - 60 / 86400 then
      Slide_Idle(v_Hash, v_Row.Abs_Expires_On);
    end if;
    -- смена IP в рамках сессии: фиксируем в аудите, но НЕ блокируем
    -- (мобильные сети меняют IP; решение о жёсткой привязке - на уровне политики)
    if i_Client_Ip is not null and v_Row.Client_Ip is not null and v_Row.Client_Ip != i_Client_Ip then
      Auth_Audit.Log(Auth_Const.c_Ev_Session_Fail,
                     'N',
                     null,
                     v_Row.User_Id,
                     v_Row.Provider_Type,
                     Auth_Const.c_Rsn_Ip_Changed || ' ' || v_Row.Client_Ip,
                     i_Client_Ip,
                     null,
                     v_Hash);
    end if;
    --
    -- Init endi UAPP-ga oynani sozlagandan keyin foydalanuvchi holatini qayta
    -- tekshirmaydi (o'sha paket o'chirildi) - shu tekshiruv shu yerda saqlanadi:
    -- deaktivatsiya/access-denied bo'lgan foydalanuvchi sessiyasi keyingi
    -- so'rovda ham ishlab qolmasligi kerak (faqat login vaqtida emas).
    select count(*)
      into v_Active_Cnt
      from Core_Users u
     where u.User_Id = v_Row.User_Id
       and u.State = 'A'
       and u.Is_Access_Denied = 'N'
       and Trunc(sysdate) between u.Activate_Date and u.Deactivate_Date;
    if v_Active_Cnt = 0 then
      Auth_Audit.Log(Auth_Const.c_Ev_Session_Fail,
                     'N',
                     null,
                     v_Row.User_Id,
                     v_Row.Provider_Type,
                     Auth_Const.c_Rsn_User_Not_Active,
                     i_Client_Ip,
                     null,
                     v_Hash);
      Auth_Session.close(i_Token, Auth_Const.c_Rsn_User_Not_Active);
      o_Reason := Auth_Const.c_Rsn_User_Not_Active;
      return false;
    end if;
    --
    Set_Context(v_Row);
    o_User_Id := v_Row.User_Id;
    o_Reason  := Auth_Const.c_Rsn_Ok;
    return true;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure close
  (
    i_Token  varchar2,
    i_Reason varchar2
  ) is
    pragma autonomous_transaction;
  begin
    update Auth_Sessions
       set State        = Auth_Const.c_Sess_Closed,
           Closed_On    = sysdate,
           Close_Reason = i_Reason
     where Session_Id_Hash = Auth_Util.Hash_Sha256(i_Token)
       and State = Auth_Const.c_Sess_Active;
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Purge_Expired is
    pragma autonomous_transaction;
  begin
    delete from Auth_Sessions
     where Abs_Expires_On < sysdate - 7;
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
  -- Debug: sqlplus'dan to'g'ridan-to'g'ri chaqirish uchun (auth/create_debug_user.sql
  -- bilan yaratilgan maxsus DEBUG_USER, user_id=c_Debug_User_Id). Login/parol
  -- tekshirmaydi - shuning uchun faqat CORE sxema egasi (SESSION_USER) chaqira
  -- oladi va har chaqiruv AUTH_DEBUG_SESSION_LOG'ga o'chmas tarzda yoziladi.
  Procedure Open_Debug_Session
  (
    i_Cb_Code    in varchar2 default null,
    i_Local_Code in varchar2 default null,
    i_Reason     in varchar2
  ) is
    v_Code       Abs_Branches.Code%type;
    v_Cb_Code    Abs_Branches.Cb_Code%type;
    v_Local_Code Abs_Branches.Local_Code%type;
    v_Mode       varchar2(10);
    --
    Procedure Write_Log is
      pragma autonomous_transaction;
    begin
      insert into Auth_Debug_Session_Log
        (Log_Id,
         Event_On,
         Db_Session_User,
         Os_User,
         Host,
         Client_Ip,
         Branch_Code,
         Cb_Code,
         Local_Code,
         Reason)
      values
        (Auth_Debug_Session_Log_Sq.Nextval,
         sysdate,
         Sys_Context('userenv', 'session_user'),
         Sys_Context('userenv', 'os_user'),
         Sys_Context('userenv', 'host'),
         Sys_Context('userenv', 'ip_address'),
         v_Code,
         v_Cb_Code,
         v_Local_Code,
         i_Reason);
      commit;
    end;
  begin
    if Sys_Context('userenv', 'session_user') != 'CORE' then
      Raise_Application_Error(c_Err_Not_Core_Schema,
                              'Open_Debug_Session faqat CORE sxemasi sessiyasidan chaqirilishi mumkin.');
    end if;
    if i_Reason is null or Length(trim(i_Reason)) < 10 then
      Raise_Application_Error(c_Err_Reason_Too_Short,
                              'i_Reason kamida 10 belgidan iborat, sababni tushuntiruvchi bo''lishi shart.');
    end if;
    Resolve_Branch_Mode(i_Cb_Code, i_Local_Code, true, v_Code, v_Cb_Code, v_Local_Code, v_Mode);
    Write_Log;
    declare
      v_Active_Cnt number;
    begin
      select count(*)
        into v_Active_Cnt
        from Core_Users u
       where u.User_Id = c_Debug_User_Id
         and u.State = 'A'
         and u.Is_Access_Denied = 'N'
         and Trunc(sysdate) between u.Activate_Date and u.Deactivate_Date;
      if v_Active_Cnt = 0 then
        Raise_Application_Error(c_Err_Debug_User_Inactive, 'DEBUG_USER (user_id=' || c_Debug_User_Id ||
                                ') topilmadi yoki aktiv emas - avval auth/create_debug_user.sql''ni ishga tushiring.');
      end if;
    end;
    Sys.Dbms_Session.Set_Context(c_Context, 'user_id', c_Debug_User_Id);
    Sys.Dbms_Session.Set_Context(c_Context, 'cb_code', v_Cb_Code);
    Sys.Dbms_Session.Set_Context(c_Context, 'local_code', v_Local_Code);
    Sys.Dbms_Session.Set_Context(c_Context, 'local_access_mode', v_Mode);
    Sys.Dbms_Session.Set_Context(c_Context, 'user_location', 'DEBUG-SESSION');
    Sys.Dbms_Session.Set_Context(c_Context, 'lang', 'ru');
    Sys.Dbms_Session.Set_Context(c_Context, 'oper_day', to_char(Trunc(sysdate), 'dd.mm.yyyy'));
  end;
  ----------------------------------------------------------------------------------------------------
  -- Job: rejalashtirilgan (DBMS_SCHEDULER) job'lar uchun - auth/create_job_user.sql
  -- bilan yaratilgan JOB_USER (user_id=c_Job_User_Id) kontekstini o'rnatadi.
  -- Faqat haqiqiy scheduler job ichidan chaqirilganda ishlaydi (BG_JOB_ID
  -- bo'sh bo'lmasligi tekshiriladi - bu SESSION_USER tekshiruvidan farqli,
  -- CORE'ning ANY-huquqlariga bog'liq emas, soxtalashtirib bo'lmaydi).
  -- Open_Debug_Session'dan farqli - sabab/filial talab qilinmaydi va
  -- AUTH_DEBUG_SESSION_LOG'ga yozilmaydi (bu inson-debug uchun, job uchun
  -- emas - job'ning o'zi DBA_SCHEDULER_JOBS orqali allaqachon ko'rinadi).
  Procedure Open_Job_Actor
  (
    i_Cb_Code    in varchar2 default null,
    i_Local_Code in varchar2 default null
  ) is
    v_Code       Abs_Branches.Code%type;
    v_Cb_Code    Abs_Branches.Cb_Code%type;
    v_Local_Code Abs_Branches.Local_Code%type;
    v_Mode       varchar2(10);
  begin
    if Sys_Context('userenv', 'bg_job_id') is null then
      Raise_Application_Error(c_Err_Not_Scheduler_Job,
                              'Open_Job_Actor faqat DBMS_SCHEDULER job ichidan chaqirilishi mumkin.');
    end if;
    Resolve_Branch_Mode(i_Cb_Code, i_Local_Code, false, v_Code, v_Cb_Code, v_Local_Code, v_Mode);
    Sys.Dbms_Session.Set_Context(c_Context, 'user_id', c_Job_User_Id);
    Sys.Dbms_Session.Set_Context(c_Context, 'cb_code', v_Cb_Code);
    Sys.Dbms_Session.Set_Context(c_Context, 'local_code', v_Local_Code);
    Sys.Dbms_Session.Set_Context(c_Context, 'local_access_mode', v_Mode);
    Sys.Dbms_Session.Set_Context(c_Context, 'oper_day', to_char(Trunc(sysdate), 'dd.mm.yyyy'));
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Session;
/
