create or replace package Auth_Legacy_Bridge is
  -- Author      : CROBS
  -- Created     : 01.07.2026
  -- Изменён     : 01.07.2026 - убран client-side wire-proof, один вызов
  --               Login_Local вместо Issue_Nonce/Begin_Login/Complete_Login_Local.
  --               01.07.2026 - добавлен o_Filial_Name (справочник Abs_Branches).
  -- Назначение  : тонкий адаптер над CORE.AUTH_API (Core.Hash_t) для старых JSP
  --               (iabs/ibs), которые используют ServletCallableStatement и
  --               умеют регистрировать только строковые (VARCHAR2) IN/OUT
  --               параметры (registerString/getString), без поддержки
  --               объектных типов Oracle. Логика не дублируется - только
  --               упаковка/распаковка Hash_t и оркестрация шагов Auth_Api.
  --
  --               Пароль передаётся как есть (HTTPS защищает транспорт),
  --               внутри Auth_Kernel.Complete_Login сверяется с PBKDF2+pepper
  --               хэшем (см. Auth_Util). Nonce/stage-token - деталь Auth_Api,
  --               наружу (JSP) не выходит.
  ----------------------------------------------------------------------------------------------------
  -- Вход LOCAL-пользователя. o_Code: 0=успех, 1=отказ, -999=ошибка системы.
  Procedure Login_Local
  (
    i_Username             varchar2,
    i_Password             varchar2,
    i_Client_Ip            varchar2,
    i_User_Agent           varchar2,
    o_Session_Token        out varchar2,
    o_User_Id              out varchar2,
    o_Name                 out varchar2,
    o_Cb_Code              out varchar2,
    o_Local_Code           out varchar2,
    o_Filial_Name          out varchar2,
    o_Lang                 out varchar2,
    o_Must_Change_Password out varchar2,
    o_Code                 out varchar2,
    o_Msg                  out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- "Parolni unutdim" - so'rov. o_Code/o_Msg har doim umumiy (enumeration'ga
  -- qarshi) - token JSP'ga hech qachon qaytarilmaydi (yetkazish kanali -
  -- email/SMS - hali ulanmagan; token faqat Auth_Password_Resets'da qoladi).
  Procedure Request_Password_Reset
  (
    i_Username   varchar2,
    i_Client_Ip  varchar2,
    i_User_Agent varchar2,
    o_Code       out varchar2,
    o_Msg        out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Token orqali yangi parol o'rnatish (tiklash havolasi bosilgach).
  Procedure Reset_With_Token
  (
    i_Token        varchar2,
    i_New_Password varchar2,
    i_Client_Ip    varchar2,
    i_User_Agent   varchar2,
    o_Code         out varchar2,
    o_Msg          out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  -- Majburiy parol almashtirish (login.jsp'dan keyin, password_must_be_changed='Y'
  -- bo'lganda). Eski parolni (admin bergan vaqtinchalik parol) tasdiqlaydi.
  Procedure Change_Password
  (
    i_Username     varchar2,
    i_Old_Password varchar2,
    i_New_Password varchar2,
    i_Client_Ip    varchar2,
    i_User_Agent   varchar2,
    o_Code         out varchar2,
    o_Msg          out varchar2
  );
  ----------------------------------------------------------------------------------------------------
end Auth_Legacy_Bridge;
/
create or replace package body Auth_Legacy_Bridge is
  ----------------------------------------------------------------------------------------------------
  Procedure Login_Local
  (
    i_Username             varchar2,
    i_Password             varchar2,
    i_Client_Ip            varchar2,
    i_User_Agent           varchar2,
    o_Session_Token        out varchar2,
    o_User_Id              out varchar2,
    o_Name                 out varchar2,
    o_Cb_Code              out varchar2,
    o_Local_Code           out varchar2,
    o_Filial_Name          out varchar2,
    o_Lang                 out varchar2,
    o_Must_Change_Password out varchar2,
    o_Code                 out varchar2,
    o_Msg                  out varchar2
  ) is
    h            Core.Hash_t := Core.Hash_t();
    v_Code       number;
    v_Ora_Msg    varchar2(4000);
    v_Nonce      varchar2(64);
    v_Stage      varchar2(64);
    v_User_Id    number;
    v_Uapp_Token varchar2(64);
    v_Uapp_Ttl   number;
  begin
    -- 1) nonce (replay protection)
    h.Put('client_ip', i_Client_Ip);
    h.Put('user_agent', i_User_Agent);
    Auth_Api.Issue_Nonce(h, v_Code, o_Msg, v_Ora_Msg);
    v_Nonce := h.Get_Optional_Varchar2('nonce');

    -- 2) begin login: consumes nonce, checks lockout, issues stage token
    h := Core.Hash_t();
    h.Put('username', i_Username);
    h.Put('nonce', v_Nonce);
    h.Put('client_ip', i_Client_Ip);
    h.Put('user_agent', i_User_Agent);
    Auth_Api.Begin_Login(h, v_Code, o_Msg, v_Ora_Msg);
    o_Code := To_Char(v_Code);
    if v_Code != Core_Const.c_Success_Code then
      return;
    end if;
    v_Stage := h.Get_Optional_Varchar2('stage_token');

    -- 3) complete login: verifies PBKDF2+pepper password, creates session
    h := Core.Hash_t();
    h.Put('username', i_Username);
    h.Put('password', i_Password);
    h.Put('stage_token', v_Stage);
    h.Put('provider_type', Auth_Const.c_Provider_Local);
    h.Put('client_ip', i_Client_Ip);
    h.Put('user_agent', i_User_Agent);
    Auth_Api.Complete_Login(h, v_Code, o_Msg, v_Ora_Msg);
    o_Code := To_Char(v_Code);
    if v_Code = Core_Const.c_Success_Code then
      v_User_Id              := h.Get_Optional_Number('user_id');
      o_Session_Token        := h.Get_Optional_Varchar2('session_token');
      o_User_Id              := To_Char(v_User_Id);
      o_Name                 := h.Get_Optional_Varchar2('name');
      o_Cb_Code              := h.Get_Optional_Varchar2('cb_code');
      o_Local_Code           := h.Get_Optional_Varchar2('local_code');
      o_Filial_Name          := h.Get_Optional_Varchar2('filial_name');
      o_Lang                 := h.Get_Optional_Varchar2('lang');
      o_Must_Change_Password := h.Get_Optional_Varchar2('must_change_password');

      -- UAPP DB session-context'ni shu (dedicated, pool qilinmagan) connection'da
      -- o'rnatish kerak - Core.User_Env.Get_User_Id() va shunga bog'liq hamma narsa
      -- (Core_Sidebar.Get_User_Menu/Get_User_Page_Urls) shuni o'qiydi. Buni FAQAT
      -- Auth_Session o'rnata oladi (CREATE CONTEXT UAPP USING CORE.AUTH_SESSION),
      -- shuning uchun yangi wrapper yozish o'rniga uning mavjud, public
      -- Create_Session'ini chaqiramiz - u context'ni allaqachon o'zi ichida
      -- to'g'ri o'rnatadi (UAPP context, Core.User_Env shundan o'qiydi). LOCAL
      -- login (shu yer) buni oldin hech qachon chaqirmagan edi.
      Auth_Session.Create_Session(
        i_User_Id    => v_User_Id,
        i_Provider   => Auth_Const.c_Provider_Local,
        i_Cb_Code    => o_Cb_Code,
        i_Local_Code => o_Local_Code,
        i_Lang       => o_Lang,
        i_Client_Ip  => i_Client_Ip,
        i_User_Agent => i_User_Agent,
        o_Token      => v_Uapp_Token,
        o_Ttl_Sec    => v_Uapp_Ttl
      );
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Request_Password_Reset
  (
    i_Username   varchar2,
    i_Client_Ip  varchar2,
    i_User_Agent varchar2,
    o_Code       out varchar2,
    o_Msg        out varchar2
  ) is
    h         Core.Hash_t := Core.Hash_t();
    v_Code    number;
    v_Ora_Msg varchar2(4000);
  begin
    h.Put('username', i_Username);
    h.Put('client_ip', i_Client_Ip);
    h.Put('user_agent', i_User_Agent);
    Auth_Pwd_Kernel.Request_Password_Reset(h, v_Code, o_Msg, v_Ora_Msg);
    o_Code := To_Char(v_Code);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Reset_With_Token
  (
    i_Token        varchar2,
    i_New_Password varchar2,
    i_Client_Ip    varchar2,
    i_User_Agent   varchar2,
    o_Code         out varchar2,
    o_Msg          out varchar2
  ) is
    h         Core.Hash_t := Core.Hash_t();
    v_Code    number;
    v_Ora_Msg varchar2(4000);
  begin
    h.Put('token', i_Token);
    h.Put('new_password', i_New_Password);
    h.Put('client_ip', i_Client_Ip);
    h.Put('user_agent', i_User_Agent);
    Auth_Pwd_Kernel.Reset_With_Token(h, v_Code, o_Msg, v_Ora_Msg);
    o_Code := To_Char(v_Code);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Change_Password
  (
    i_Username     varchar2,
    i_Old_Password varchar2,
    i_New_Password varchar2,
    i_Client_Ip    varchar2,
    i_User_Agent   varchar2,
    o_Code         out varchar2,
    o_Msg          out varchar2
  ) is
    h         Core.Hash_t := Core.Hash_t();
    v_Code    number;
    v_Ora_Msg varchar2(4000);
  begin
    h.Put('username', i_Username);
    h.Put('old_password', i_Old_Password);
    h.Put('new_password', i_New_Password);
    h.Put('client_ip', i_Client_Ip);
    h.Put('user_agent', i_User_Agent);
    Auth_Pwd_Kernel.Change_Password(h, v_Code, o_Msg, v_Ora_Msg);
    o_Code := To_Char(v_Code);
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Legacy_Bridge;
/
