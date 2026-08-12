create or replace package Auth_Kernel is
  -- Author      : CROBS
  -- Created     : 19.05.2026
  -- Назначение  : ВНУТРЕННЯЯ логика аутентификации. Содержит всю бизнес-логику
  --               (nonce, блокировка, сопоставление личности, авторизация,
  --               сессия, аудит).
  --
  --   ВНИМАНИЕ: пакет никому не выдаётся (нет GRANT EXECUTE). Доступ к нему
  --   только через CORE.AUTH_API (права definer). Так при добавлении новых
  --   внутренних пакетов поверхность доступа не меняется - наружу всегда только
  --   один пакет AUTH_API.
  --
  --   Контракт совпадает с фасадом: Core.Hash_t / o_Code (0=успех, 1=отказ,
  --   -999=ошибка системы). Сообщение o_Msg всегда общее; детальные причины -
  --   только в CORE.AUTH_AUDIT_LOG.
  ----------------------------------------------------------------------------------------------------
  Procedure Issue_Nonce
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Шаг 3-4: гашение nonce + проверка блокировки. Вызывается до bind в AD.
  Procedure Begin_Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Шаг 6 (путь ошибки): вызывается фасадом при неудачном bind в AD.
  Procedure Register_Failure
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Шаг 7-9: вызывается после успешного bind в AD. Сопоставление личности,
  -- авторизация, сброс блокировки, создание сессии.
  Procedure Complete_Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Шаг 10: проверка сессии на каждый запрос + загрузка контекста UAPP.
  Procedure Validate_Session
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Logout
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
end Auth_Kernel;
/
create or replace package body Auth_Kernel is
  c_Deny      constant number := 1;
  c_Sys_Error constant number := -999; -- header izohidagi tizim-xatosi kodi
  ----------------------------------------------------------------------------------------------------
  Procedure Issue_Nonce
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Nonce varchar2(64);
    v_Ttl   number;
  begin
    o_Code := Core.Core_Const.c_Success_Code;
    --
    Auth_Nonce.Issue(i_Client_Ip  => Io_Hash.Get_Optional_Varchar2('client_ip'),
                     i_User_Agent => Io_Hash.Get_Optional_Varchar2('user_agent'),
                     o_Nonce      => v_Nonce,
                     o_Ttl_Sec    => v_Ttl);
    --
    Io_Hash.Put('nonce', v_Nonce);
    Io_Hash.Put('expires_in', v_Ttl);
  exception
    when others then
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Begin_Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Username  varchar2(100) := Auth_Util.Norm_Username(Io_Hash.Get_Varchar2('username'));
    v_Nonce     varchar2(64) := Io_Hash.Get_Optional_Varchar2('nonce');
    v_Ip        varchar2(45) := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua        varchar2(400) := Io_Hash.Get_Optional_Varchar2('user_agent');
    v_Reason    varchar2(40);
    v_Until     date;
    v_Stage     varchar2(64);
    v_Stage_Ttl number;
  begin
    o_Code := Core.Core_Const.c_Success_Code;
    -- 3. nonce (одноразовый, короткий TTL)
    v_Reason := Auth_Nonce.Consume(v_Nonce);
    if v_Reason != Auth_Const.c_Rsn_Ok then
      Auth_Audit.Log(Auth_Const.c_Ev_Nonce_Fail, 'N', v_Username, null, null, v_Reason, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
      return;
    end if;
    -- 4. блокировка (до обращения к AD - защищает реальную учётную запись AD)
    if Auth_Lockout.Is_Locked(v_Username, v_Until) then
      Auth_Audit.Log(Auth_Const.c_Ev_Locked,
                     'N',
                     v_Username,
                     null,
                     null,
                     Auth_Const.c_Rsn_Locked,
                     v_Ip,
                     v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed; -- общее: не раскрываем факт блокировки
      return;
    end if;
    -- успех nonce+lockout: выдаём stage-токен для Complete_Login
    Auth_Nonce.Issue_Stage(v_Username, v_Ip, v_Stage, v_Stage_Ttl);
    Io_Hash.Put('stage_token', v_Stage);
    Io_Hash.Put('can_proceed', 'Y');
  exception
    when others then
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Register_Failure
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Username varchar2(100) := Auth_Util.Norm_Username(Io_Hash.Get_Varchar2('username'));
    v_Ip       varchar2(45) := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua       varchar2(400) := Io_Hash.Get_Optional_Varchar2('user_agent');
    v_Reason   varchar2(40) := Nvl(Io_Hash.Get_Optional_Varchar2('reason_code'),
                                   Auth_Const.c_Rsn_Bad_Credentials);
  begin
    o_Code := Core.Core_Const.c_Success_Code;
    --
    Auth_Lockout.Register_Failure(v_Username);
    Auth_Audit.Log(Auth_Const.c_Ev_Login_Fail,
                   'N',
                   v_Username,
                   null,
                   Io_Hash.Get_Optional_Varchar2('provider_type'),
                   v_Reason,
                   v_Ip,
                   v_Ua);
    o_Code := c_Deny;
    o_Msg  := Auth_Const.c_Msg_Auth_Failed;
  exception
    when others then
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Complete_Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Username varchar2(100) := Auth_Util.Norm_Username(Io_Hash.Get_Varchar2('username'));
    v_Provider varchar2(20) := Nvl(Io_Hash.Get_Optional_Varchar2('provider_type'),
                                   Auth_Const.c_Provider_Local);
    v_Ip       varchar2(45) := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua       varchar2(400) := Io_Hash.Get_Optional_Varchar2('user_agent');
    v_Stage_Token varchar2(4000);
    v_User_Id    number;
    v_Key_St     varchar2(1);
    v_Local_Hash varchar2(1000);
    v_Pwd_Chg    varchar2(1);
    v_u          Core_Users%rowtype;
    v_Filial_Name varchar2(200);
    v_Cnt      number;
    v_Token    varchar2(64);
    v_Ttl      number;
    --------------------------------------------------
    Procedure Deny
    (
      i_Reason varchar2,
      i_Msg    varchar2
    ) is
    begin
      Auth_Audit.Log(Auth_Const.c_Ev_Login_Fail,
                     'N',
                     v_Username,
                     v_User_Id,
                     v_Provider,
                     i_Reason,
                     v_Ip,
                     v_Ua);
      o_Code := c_Deny;
      o_Msg  := i_Msg;
    end;
    --------------------------------------------------
  begin
    o_Code := Core.Core_Const.c_Success_Code;
    v_Stage_Token := Io_Hash.Get_Optional_Varchar2('stage_token');
    -- 6.5 stage-токен: подтверждает, что Begin_Login (nonce+lockout) и AD-bind пройдены.
    --     Без него Complete_Login нельзя вызвать в обход аутентификации.
    if Auth_Nonce.Consume_Stage(v_Stage_Token, v_Username) !=
       Auth_Const.c_Rsn_Ok then
      Auth_Audit.Log(Auth_Const.c_Ev_Stage_Fail, 'N', v_Username, null, v_Provider,
                      Auth_Const.c_Rsn_Stage_Invalid, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
      return;
    end if;
    -- 6.6 AD-login yo'li HOZIRCHA ATAYLAB YOPIQ. Ushbu protsedura provider_type='AD'
    -- qiymatini chaqiruvchidan ishonib oladi (haqiqiy LDAPS bind bu yerda EMAS,
    -- chaqiruvchi - JSP/Java - tomonida bajarilgan deb faraz qilinadi). Buni ishonib
    -- qolgan yagona chaqiruvchi (uz.crobs.auth.AuthDb.completeLogin, iabs\ibs\new\)
    -- haqiqatda hech qachon AD bind qilmasdan shu bayroqni qo'yardi - haqiqiy
    -- autentifikatsiya bypass edi (topildi, o'sha kod o'chirildi). Haqiqiy LDAPS-bind
    -- asosi tayyor (D:\github\core\auth\web\AdLdap.java), lekin uni Complete_Login'dan
    -- oldin chaqiradigan to'liq zanjir hali yozilmagan - shu zanjir tayyor va review'dan
    -- o'tmaguncha AD qat'iy rad etiladi (fail-closed).
    if v_Provider != Auth_Const.c_Provider_Local then
      Deny(Auth_Const.c_Rsn_Not_Local, Auth_Const.c_Msg_No_Access);
      return;
    end if;
    -- 7. сопоставление личности (pre-provisioned: должна уже быть в CORE_USER_KEYS)
    begin
      select User_Id, State, Password, Password_Must_Be_Changed
        into v_User_Id, v_Key_St, v_Local_Hash, v_Pwd_Chg
        from Core_User_Keys
       where Provider_Type = v_Provider
         and Provider_Key = v_Username;
    exception
      when No_Data_Found then
        Deny(Auth_Const.c_Rsn_Not_Provisioned, Auth_Const.c_Msg_No_Access);
        return;
      when Too_Many_Rows then
        -- дубль ключа (provider_type, provider_key) - аномалия данных
        Deny(Auth_Const.c_Rsn_Not_Provisioned, Auth_Const.c_Msg_No_Access);
        return;
    end;
    --
    if v_Key_St != Auth_Const.c_State_Active then
      Deny(Auth_Const.c_Rsn_Key_Passive, Auth_Const.c_Msg_No_Access);
      return;
    end if;
    -- 7.5. LOCAL: bind извне не было (в отличие от AD), пароль проверяется здесь
    -- (HTTPS защищает транспорт; хэш - PBKDF2 + app-pepper, см. Auth_Util).
    if v_Provider = Auth_Const.c_Provider_Local then
      if not Auth_Util.Verify_Local_Hash(Io_Hash.Get_Optional_Varchar2('password'), v_Local_Hash) then
        Auth_Lockout.Register_Failure(v_Username);
        Deny(Auth_Const.c_Rsn_Bad_Credentials, Auth_Const.c_Msg_Auth_Failed);
        return;
      end if;
    end if;
    -- 8. авторизация по CORE_USERS
    begin
      select *
        into v_u
        from Core_Users
       where User_Id = v_User_Id;
    exception
      when No_Data_Found then
        Deny(Auth_Const.c_Rsn_Not_Provisioned, Auth_Const.c_Msg_No_Access);
        return;
    end;
    --
    if v_u.State != Auth_Const.c_State_Active or
       Trunc(sysdate) not between v_u.Activate_Date and v_u.Deactivate_Date then
      Deny(Auth_Const.c_Rsn_User_Not_Active, Auth_Const.c_Msg_No_Access);
      return;
    end if;
    --
    if v_u.Is_Access_Denied = 'Y' then
      Deny(Auth_Const.c_Rsn_Access_Denied, Auth_Const.c_Msg_No_Access);
      return;
    end if;
    -- 8.5. API-hisoblarga (masalan ESBIN texnik userlariga - Core_Const.c_User_Type_Api)
    -- brauzer-login orqali kirish TAQIQLANADI - bu tur maxsus tashqi-tizim
    -- gateway'lari uchun, inson ishlaydigan UI uchun emas (ADM_REL_USER_MENUS/
    -- BUTTONS granti bo'lmasa ham, Menu_Type='PUBLIC' menyular har qanday
    -- login qilgan userga ochiq bo'lgani uchun bu haqiqiy chegara hisoblanadi).
    if v_u.User_Type_Id = Core.Core_Const.c_User_Type_Api then
      Deny(Auth_Const.c_Rsn_Api_User, Auth_Const.c_Msg_No_Access);
      return;
    end if;
    /*-- проверка активной роли (включить, когда появятся CORE_ROLES/CORE_REL_USER_ROLES)
    select count(*)
      into v_Cnt
      from Core_Rel_User_Roles r
      join Core_Roles Ro
        on Ro.Role_Id = r.Role_Id
     where r.User_Id = v_User_Id
       and r.State = Auth_Const.c_State_Active
       and Trunc(sysdate) between r.Activate_Date and
           Nvl(r.Deactivate_Date, to_date('31.12.9999', 'dd.mm.yyyy'))
       and Ro.State = Auth_Const.c_State_Active
       and Trunc(sysdate) between Ro.Activate_Date and Ro.Deactivate_Date;
    --
    if v_Cnt = 0 then
      Deny(Auth_Const.c_Rsn_No_Active_Role, Auth_Const.c_Msg_No_Access);
      return;
    end if;*/
    -- 8.5. отображаемое имя филиала (справочник Abs_Branches). ABS_BRANCHES_I2
    -- не гарантирует уникальность CB_CODE - берём первую строку, только для
    -- показа (не для авторизации). Нет строки - fallback на сам код.
    begin
      select Name
        into v_Filial_Name
        from (select Name from Abs_Branches where Cb_Code = v_u.Cb_Code)
       where rownum = 1;
    exception
      when No_Data_Found then
        v_Filial_Name := v_u.Cb_Code;
    end;
    -- 9. успех: сброс блокировки, создание сессии
    Auth_Lockout.Reset(v_Username);
    Auth_Session.Create_Session(i_User_Id    => v_User_Id,
                                i_Provider   => v_Provider,
                                i_Cb_Code    => v_u.Cb_Code,
                                i_Local_Code => v_u.Local_Code,
                                i_Lang       => v_u.Language,
                                i_Client_Ip  => v_Ip,
                                i_User_Agent => v_Ua,
                                o_Token      => v_Token,
                                o_Ttl_Sec    => v_Ttl);
    --
    Auth_Audit.Log(Auth_Const.c_Ev_Login_Ok,
                   'Y',
                   v_Username,
                   v_User_Id,
                   v_Provider,
                   Auth_Const.c_Rsn_Ok,
                   v_Ip,
                   v_Ua,
                   Auth_Util.Hash_Sha256(v_Token));
    --
    Io_Hash.Put('session_token', v_Token);
    Io_Hash.Put('expires_in', v_Ttl);
    Io_Hash.Put('user_id', v_User_Id);
    Io_Hash.Put('name', v_u.Name);
    Io_Hash.Put('lang', v_u.Language);
    Io_Hash.Put('cb_code', v_u.Cb_Code);
    Io_Hash.Put('local_code', v_u.Local_Code);
    Io_Hash.Put('filial_name', v_Filial_Name);
    Io_Hash.Put('must_change_password', Nvl(v_Pwd_Chg, 'N'));
  exception
    when others then
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Validate_Session
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Token varchar2(64) := Io_Hash.Get_Optional_Varchar2('session_token');
    v_Ip    varchar2(45) := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua    varchar2(400) := Io_Hash.Get_Optional_Varchar2('user_agent');
    v_Uid   number;
    v_Rsn   varchar2(40);
  begin
    o_Code := Core.Core_Const.c_Success_Code;
    --
    if not Auth_Session.Validate(v_Token, v_Ip, v_Uid, v_Rsn) then
      Auth_Audit.Log(Auth_Const.c_Ev_Session_Fail, 'N', null, null, null, v_Rsn, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Session;
      return;
    end if;
    --
    Io_Hash.Put('user_id', v_Uid);
  exception
    when others then
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Logout
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Token varchar2(64) := Io_Hash.Get_Optional_Varchar2('session_token');
  begin
    o_Code := Core.Core_Const.c_Success_Code;
    --
    if v_Token is not null then
      Auth_Session.Close(v_Token, Auth_Const.c_Ev_Logout);
      Auth_Audit.Log(Auth_Const.c_Ev_Logout,
                     'Y',
                     null,
                     null,
                     null,
                     Auth_Const.c_Rsn_Ok,
                     Io_Hash.Get_Optional_Varchar2('client_ip'),
                     Io_Hash.Get_Optional_Varchar2('user_agent'),
                     Auth_Util.Hash_Sha256(v_Token));
    end if;
    --
    Auth_Session.Clear_Context;
  exception
    when others then
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Kernel;
/
