create or replace package Auth_Api is
  -- Author      : CROBS
  -- Created     : 18.05.2026
  -- Изменён     : 19.05.2026 - проксирование операций со сменой пароля (LOCAL)
  -- Назначение  : ФАСАД аутентификации для слоя JSP. Единственная точка входа.
  --
  --   БЕЗОПАСНОСТЬ - "один вход":
  --     * наружу выдаётся GRANT EXECUTE ТОЛЬКО на этот пакет;
  --     * здесь НЕТ логики - только проброс в CORE.AUTH_KERNEL / AUTH_PWD_KERNEL;
  --     * внутренние пакеты НИКОМУ не выдаются (права definer);
  --     * добавление новых внутренних пакетов НЕ меняет поверхность доступа.
  --
  --   Контракт неизменен (JSP/AuthDb не трогаем): Core.Hash_t / o_Code
  --   (0=успех, 1=отказ, -999=ошибка системы).
  ----------------------------------------------------------------------------------------------------
  -- Login flow
  Procedure Issue_Nonce
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Begin_Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Register_Failure
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Complete_Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
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
  -- Password flow (только LOCAL; AD-пароли тут не управляются)
  Procedure Change_Password
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Request_Password_Reset
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Reset_With_Token
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
end Auth_Api;
/
create or replace package body Auth_Api is
  ----------------------------------------------------------------------------------------------------
  -- Только проброс. Логика - в AUTH_KERNEL / AUTH_PWD_KERNEL.
  ----------------------------------------------------------------------------------------------------
  Procedure Issue_Nonce
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Kernel.Issue_Nonce(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Begin_Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Kernel.Begin_Login(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Register_Failure
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Kernel.Register_Failure(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Complete_Login
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Kernel.Complete_Login(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Validate_Session
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Kernel.Validate_Session(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Logout
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Kernel.Logout(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Change_Password
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Pwd_Kernel.Change_Password(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Request_Password_Reset
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Pwd_Kernel.Request_Password_Reset(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Reset_With_Token
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Auth_Pwd_Kernel.Reset_With_Token(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Api;
/
