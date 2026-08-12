create or replace package Auth_Pwd_Kernel is

  -- Author      : CROBS
  -- Created     : 19.05.2026
  -- Назначение  : Управление паролями для провайдера LOCAL (PBKDF2).
  --               AD-пароли не управляются здесь - пользователь AD меняет пароль
  --               через корпоративный AD-механизм; наша система к этому отношения
  --               не имеет.
  --
  --   ВНУТРЕННИЙ пакет - не выдаётся наружу. JSP вызывает через фасад CORE.AUTH_API
  --   (он пробрасывает в Auth_Pwd_Kernel).
  --
  --   Контракт: Core.Hash_t / o_Code (0=успех, 1=отказ, -999=ошибка системы).
  ----------------------------------------------------------------------------------------------------
  -- Самостоятельная смена пароля (LOCAL): пользователь знает старый пароль.
  -- in:  username, old_password, new_password, [acting_user_id], client_ip, user_agent
  Procedure Change_Password
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Админский сброс пароля (LOCAL): задаёт новый пароль без проверки старого,
  -- выставляет password_must_be_changed = 'Y'.
  -- in:  identity_id или (provider_type+provider_key), new_password, client_ip, user_agent
  Procedure Admin_Reset_Password
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- "Забыли пароль" - заявка на сброс. Возвращает одноразовый токен (доставляется
  -- email/sms на стороне JSP). Если пользователь не существует или не LOCAL -
  -- общий ответ без раскрытия (защита от перечисления).
  -- in:  username, client_ip, user_agent ; out (только при успехе): token, expires_in
  Procedure Request_Password_Reset
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Завершение сброса: проверяет токен, задаёт новый пароль, гасит токен.
  -- in:  token, new_password, client_ip, user_agent
  Procedure Reset_With_Token
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Обслуживание: удалить просроченные токены сброса (вызывать из планировщика).
  Procedure Purge_Expired;
  ----------------------------------------------------------------------------------------------------
end Auth_Pwd_Kernel;
/
create or replace package body Auth_Pwd_Kernel is

  c_Deny      constant number := 1;
  c_Sys_Error constant number := -999; -- header izohidagi tizim-xatosi kodi

  ----------------------------------------------------------------------------------------------------
  -- Минимальная политика пароля. Расширяемо.
  Function Is_Strong(i_Pwd varchar2) return boolean is
  begin
    if i_Pwd is null or Length(i_Pwd) < Auth_Const.c_Pwd_Min_Length then
      return false;
    end if;
    -- хотя бы одна цифра и одна буква
    if not Regexp_Like(i_Pwd, '[0-9]') or not Regexp_Like(i_Pwd, '[A-Za-z]') then
      return false;
    end if;
    return true;
  end;
  ----------------------------------------------------------------------------------------------------
  -- Внутреннее обновление пароля в CORE_USER_KEYS + аудит.
  Procedure Set_New_Password
  (
    i_Identity_Id  number,
    i_New_Password varchar2,
    i_Event        varchar2,
    i_Client_Ip    varchar2,
    i_User_Agent   varchar2
  ) is
    v_Key Core_User_Keys%rowtype;
  begin
    if not Core_Util.Load_User_Key(i_Identity_Id, v_Key) then
      return;
    end if;
    v_Key.Password                 := Auth_Util.Make_Local_Hash(i_New_Password);
    v_Key.Password_Must_Be_Changed := 'N';
    v_Key.Password_Expiry_Date     := null;
    Core_Dml.Update_User_Key(v_Key);
    Auth_Audit.Log(i_Event, 'Y', v_Key.Provider_Key, v_Key.User_Id,
                    v_Key.Provider_Type, Auth_Const.c_Rsn_Ok,
                    i_Client_Ip, i_User_Agent);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Change_Password
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Username varchar2(512)  := Auth_Util.Norm_Username(Io_Hash.Get_Varchar2('username'));
    v_Old      varchar2(1000) := Io_Hash.Get_Varchar2('old_password');
    v_New      varchar2(1000) := Io_Hash.Get_Varchar2('new_password');
    v_Ip       varchar2(45)   := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua       varchar2(400)  := Io_Hash.Get_Optional_Varchar2('user_agent');
    v_Key      Core_User_Keys%rowtype;
    v_Acting   number := Io_Hash.Get_Optional_Number('acting_user_id');
  begin
    o_Code := Core.Core_Const.c_Success_Code;

    if not Is_Strong(v_New) then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Changed, 'N', v_Username, null,
                      Auth_Const.c_Provider_Local,
                      Auth_Const.c_Rsn_Weak_Password, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Weak_Password;
      return;
    end if;

    if not Core_Util.Load_User_Key_By_Key(Auth_Const.c_Provider_Local, v_Username, v_Key) then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Changed, 'N', v_Username, null,
                      Auth_Const.c_Provider_Local,
                      Auth_Const.c_Rsn_Not_Provisioned, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
      return;
    end if;

    if v_Key.State != Auth_Const.c_State_Active then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Changed, 'N', v_Username, v_Key.User_Id,
                      Auth_Const.c_Provider_Local,
                      Auth_Const.c_Rsn_Key_Passive, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
      return;
    end if;

    -- если задан acting_user_id (из валидной сессии), он должен совпадать с владельцем ключа
    if v_Acting is not null and v_Acting != v_Key.User_Id then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Changed, 'N', v_Username, v_Key.User_Id,
                      Auth_Const.c_Provider_Local,
                      Auth_Const.c_Rsn_Access_Denied, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
      return;
    end if;

    if not Auth_Util.Verify_Local_Hash(v_Old, v_Key.Password) then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Changed, 'N', v_Username, v_Key.User_Id,
                      Auth_Const.c_Provider_Local,
                      Auth_Const.c_Rsn_Wrong_Old_Pwd, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Auth_Failed;
      return;
    end if;

    -- Bu chaqiruv login'dan keyingi standalone bridge orqali ham kelishi mumkin
    -- (change_password_first.jsp - hali main.jsp sessiyasi ochilmagan, shu DB
    -- ulanishida UAPP konteksti yo'q). Modified_By uchun foydalanuvchining o'zini
    -- (o'z parolini o'zi almashtiryapti) vaqtincha actor qilib belgilaymiz.
    Auth_Session.Set_System_Actor(v_Key.User_Id);
    Set_New_Password(v_Key.Identity_Id, v_New, Auth_Const.c_Ev_Pwd_Changed, v_Ip, v_Ua);
    Auth_Session.Clear_System_Actor;
    o_Msg := Auth_Const.c_Msg_Pwd_Changed;
  exception
    when others then
      Auth_Session.Clear_System_Actor;
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Admin_Reset_Password
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Id       number         := Io_Hash.Get_Optional_Number('identity_id');
    v_Provider varchar2(20)   := Io_Hash.Get_Optional_Varchar2('provider_type');
    v_Pkey     varchar2(512)  := Io_Hash.Get_Optional_Varchar2('provider_key');
    v_New      varchar2(1000) := Io_Hash.Get_Varchar2('new_password');
    v_Ip       varchar2(45)   := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua       varchar2(400)  := Io_Hash.Get_Optional_Varchar2('user_agent');
    v_Key      Core_User_Keys%rowtype;
    v_Found    boolean;
  begin
    o_Code := Core.Core_Const.c_Success_Code;

    if not Is_Strong(v_New) then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Admin_Set, 'N', v_Pkey, null,
                      v_Provider, Auth_Const.c_Rsn_Weak_Password, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Weak_Password;
      return;
    end if;

    if v_Id is not null then
      v_Found := Core_Util.Load_User_Key(v_Id, v_Key);
    elsif v_Provider is not null and v_Pkey is not null then
      v_Found := Core_Util.Load_User_Key_By_Key(v_Provider, v_Pkey, v_Key);
    else
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Admin_Set, 'N', v_Pkey, null,
                      v_Provider, Auth_Const.c_Rsn_Identity_Missing, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Sys_Error;
      return;
    end if;

    if not v_Found then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Admin_Set, 'N', v_Pkey, null,
                      v_Provider, Auth_Const.c_Rsn_Not_Provisioned, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_No_Access;
      return;
    end if;

    if v_Key.Provider_Type != Auth_Const.c_Provider_Local then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Admin_Set, 'N', v_Key.Provider_Key,
                      v_Key.User_Id, v_Key.Provider_Type, Auth_Const.c_Rsn_Not_Local,
                      v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Not_Local;
      return;
    end if;

    v_Key.Password                 := Auth_Util.Make_Local_Hash(v_New);
    v_Key.Password_Must_Be_Changed := 'Y';
    v_Key.Password_Expiry_Date     := null;
    Core_Dml.Update_User_Key(v_Key);

    Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Admin_Set, 'Y', v_Key.Provider_Key,
                    v_Key.User_Id, v_Key.Provider_Type,
                    Auth_Const.c_Rsn_Ok, v_Ip, v_Ua);
    o_Msg := Auth_Const.c_Msg_Pwd_Changed;
  exception
    when others then
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Request_Password_Reset
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    pragma autonomous_transaction;
    v_Username varchar2(512) := Auth_Util.Norm_Username(Io_Hash.Get_Varchar2('username'));
    v_Ip       varchar2(45)  := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua       varchar2(400) := Io_Hash.Get_Optional_Varchar2('user_agent');
    v_Key      Core_User_Keys%rowtype;
    v_Token    varchar2(64);
    v_Found    boolean;
  begin
    o_Code := Core.Core_Const.c_Success_Code;
    -- общий ответ всегда (без раскрытия существования пользователя)
    o_Msg := Auth_Const.c_Msg_Reset_Sent;

    v_Found := Core_Util.Load_User_Key_By_Key(Auth_Const.c_Provider_Local, v_Username, v_Key);
    if not v_Found or v_Key.State != Auth_Const.c_State_Active then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Req_Reset, 'N', v_Username, null,
                      Auth_Const.c_Provider_Local,
                      Auth_Const.c_Rsn_Not_Provisioned, v_Ip, v_Ua);
      commit;
      return;
    end if;

    -- invalidate previous active reset tokens (one active token per identity)
    update Auth_Password_Resets
       set Used = 'Y', Used_On = sysdate
     where Identity_Id = v_Key.Identity_Id
       and Used = 'N';
    v_Token := Auth_Util.Random_Token(Auth_Const.c_Token_Bytes);
    insert into Auth_Password_Resets
      (Token_Hash, Identity_Id, Issued_On, Expires_On, Used, Client_Ip)
    values
      (Auth_Util.Hash_Sha256(v_Token), v_Key.Identity_Id, sysdate,
       sysdate + Auth_Const.c_Reset_Ttl_Min / 1440, 'N',
       Substr(v_Ip, 1, 45));

    Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Req_Reset, 'Y', v_Username, v_Key.User_Id,
                    Auth_Const.c_Provider_Local, Auth_Const.c_Rsn_Ok, v_Ip, v_Ua);
    commit;

    -- токен возвращается только заявителю (JSP отправит email/sms)
    Io_Hash.Put('token', v_Token);
    Io_Hash.Put('expires_in', Auth_Const.c_Reset_Ttl_Min * 60);
  exception
    when others then
      rollback;
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Reset_With_Token
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Token   varchar2(64)   := Io_Hash.Get_Varchar2('token');
    v_New     varchar2(1000) := Io_Hash.Get_Varchar2('new_password');
    v_Ip      varchar2(45)   := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua      varchar2(400)  := Io_Hash.Get_Optional_Varchar2('user_agent');
    v_Hash    varchar2(64);
    v_IdentId number;
    v_Used    varchar2(1);
    v_Expires date;
  begin
    o_Code := Core.Core_Const.c_Success_Code;

    if not Is_Strong(v_New) then
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Weak_Password;
      return;
    end if;

    v_Hash := Auth_Util.Hash_Sha256(v_Token);
    begin
      select Identity_Id, Used, Expires_On
        into v_IdentId, v_Used, v_Expires
        from Auth_Password_Resets
       where Token_Hash = v_Hash
         for update;
    exception
      when no_data_found then
        Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Use_Reset, 'N', null, null,
                        null, Auth_Const.c_Rsn_Reset_Invalid, v_Ip, v_Ua);
        o_Code := c_Deny;
        o_Msg  := Auth_Const.c_Msg_Reset_Invalid;
        return;
    end;

    if v_Used = 'Y' then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Use_Reset, 'N', null, null,
                      null, Auth_Const.c_Rsn_Reset_Used, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Reset_Invalid;
      return;
    end if;
    if v_Expires < sysdate then
      Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Use_Reset, 'N', null, null,
                      null, Auth_Const.c_Rsn_Reset_Expired, v_Ip, v_Ua);
      o_Code := c_Deny;
      o_Msg  := Auth_Const.c_Msg_Reset_Invalid;
      return;
    end if;

    -- ключ должен быть активным (мог стать passive между запросом и сбросом)
    declare
      v_Key Core_User_Keys%rowtype;
    begin
      if not Core_Util.Load_User_Key(v_IdentId, v_Key)
         or v_Key.State != Auth_Const.c_State_Active then
        update Auth_Password_Resets
           set Used = 'Y', Used_On = sysdate
         where Token_Hash = v_Hash;
        Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Use_Reset, 'N', null, null,
                        null, Auth_Const.c_Rsn_Key_Passive, v_Ip, v_Ua);
        o_Code := c_Deny;
        o_Msg  := Auth_Const.c_Msg_Reset_Invalid;
        return;
      end if;
    end;

    -- гасим токен
    update Auth_Password_Resets
       set Used = 'Y', Used_On = sysdate
     where Token_Hash = v_Hash;

    -- Autentifikatsiyalanmagan chaqiruvchi (Get_User_Id = NULL), a Modified_By
    -- NOT NULL. Vaqtincha "SYSTEM USER" sifatida yozamiz, keyin darhol
    -- tozalaymiz (Auth_Session - c_Context'ning ishonchli egasi).
    Auth_Session.Set_System_Actor(0);
    Set_New_Password(v_IdentId, v_New, Auth_Const.c_Ev_Pwd_Use_Reset, v_Ip, v_Ua);
    Auth_Session.Clear_System_Actor;
    o_Msg := Auth_Const.c_Msg_Pwd_Changed;
  exception
    when others then
      Auth_Session.Clear_System_Actor;
      o_Code    := c_Sys_Error;
      o_Msg     := Auth_Const.c_Msg_Sys_Error;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Purge_Expired is
    pragma autonomous_transaction;
  begin
    delete from Auth_Password_Resets
     where Expires_On < sysdate - 1;
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Pwd_Kernel;
/
