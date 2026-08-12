----------------------------------------------------------------------------------------------------
--  Сквозной тест фасада CORE.AUTH_API (как его вызывает JSP).
--  Сценарий: Issue_Nonce -> Begin_Login(=stage) -> [AD provider fail-closed,
--            см. Auth_Kernel.Complete_Login] -> LOCAL Complete_Login -> Validate_Session
--            -> Logout, плюс негативные случаи.
--  Требует фикстуру (00_setup_fixture.sql) и контекст UAPP.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  v_Pass number := 0;
  v_Fail number := 0;
  c_Uid constant number := 999999901;
  -- LOCAL-провайдер (00_setup_fixture.sql) - AD сейчас fail-closed в Auth_Kernel.Complete_Login.
  c_Pwd constant varchar2(32) := 'CorrectPass1';
  v_h     Core.Hash_t;
  v_c     number;
  v_m     varchar2(400);
  v_o     varchar2(4000);
  v_Stage varchar2(64);
  v_Token varchar2(64);
  --------------------------------------------------
  Procedure Assert
  (
    i_Name varchar2,
    i_Cond boolean
  ) is
  begin
    if i_Cond then
      v_Pass := v_Pass + 1;
      Dbms_Output.Put_Line('  PASS  ' || i_Name);
    else
      v_Fail := v_Fail + 1;
      Dbms_Output.Put_Line('  FAIL  ' || i_Name);
    end if;
  end;
  --------------------------------------------------
  -- Полный пред-этап: nonce -> Begin_Login, возвращает stage-токен.
  Function Make_Stage(i_Username varchar2) return varchar2 is
    h Core.Hash_t := Core.Hash_t();
    c number;
    m varchar2(400);
    o varchar2(4000);
    v_Nonce varchar2(64);
  begin
    h.Put('client_ip', '127.0.0.1');
    h.Put('user_agent', 'JUnit');
    Core.Auth_Api.Issue_Nonce(h, c, m, o);
    v_Nonce := h.Get_Optional_Varchar2('nonce');
    --
    h := Core.Hash_t();
    h.Put('username', i_Username);
    h.Put('nonce', v_Nonce);
    h.Put('client_ip', '127.0.0.1');
    h.Put('user_agent', 'JUnit');
    Core.Auth_Api.Begin_Login(h, c, m, o);
    return h.Get_Optional_Varchar2('stage_token');
  end;
begin
  Dbms_Output.Put_Line('=== AUTH_API (сквозной) ===');

  ------------------------------------------------------------------ happy path
  v_Stage := Make_Stage('testuser');
  Assert('Begin_Login выдал stage-токен', v_Stage is not null);

  -- AD провайдер сейчас fail-closed (Auth_Kernel.Complete_Login, LDAPS bind ещё
  -- не подключён к цепочке вызова) - любой Complete_Login с provider_type='AD'
  -- должен получить отказ, даже с валидным stage-токеном.
  v_h := Core.Hash_t();
  v_h.Put('username', 'testuser');
  v_h.Put('stage_token', v_Stage);
  v_h.Put('provider_type', 'AD');
  v_h.Put('client_ip', '127.0.0.1');
  v_h.Put('user_agent', 'JUnit');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('AD provider hozircha yopiq -> deny', v_c = 1);

  -- повторное использование того же stage-токена -> отказ (уже потреблён выше)
  v_h := Core.Hash_t();
  v_h.Put('username', 'testuser');
  v_h.Put('stage_token', v_Stage);
  v_h.Put('provider_type', 'AD');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('Повтор stage-токена -> deny', v_c = 1);

  -- Complete_Login без stage-токена -> отказ (обход аутентификации невозможен)
  v_h := Core.Hash_t();
  v_h.Put('username', 'testuser');
  v_h.Put('provider_type', 'AD');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('Complete_Login без stage -> deny', v_c = 1);

  -- LOCAL провайдер (00_setup_fixture.sql провижионит его для c_Uid) - реальный
  -- успешный логин, чтобы получить v_Token для разделов сессии/logout ниже
  -- (AD-путь теперь всегда deny, токен оттуда взять неоткуда).
  v_Stage := Make_Stage('testuser');
  v_h := Core.Hash_t();
  v_h.Put('username', 'testuser');
  v_h.Put('password', c_Pwd);
  v_h.Put('stage_token', v_Stage);
  v_h.Put('provider_type', 'LOCAL');
  v_h.Put('client_ip', '127.0.0.1');
  v_h.Put('user_agent', 'JUnit');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('Complete_Login LOCAL OK (code=0)', v_c = 0);
  v_Token := v_h.Get_Optional_Varchar2('session_token');
  Assert('Выдан session_token', v_Token is not null);
  Assert('user_id в ответе', v_h.Get_Optional_Number('user_id') = c_Uid);

  ------------------------------------------------------------------ сессия
  v_h := Core.Hash_t();
  v_h.Put('session_token', v_Token);
  v_h.Put('client_ip', '127.0.0.1');
  Core.Auth_Api.Validate_Session(v_h, v_c, v_m, v_o);
  Assert('Validate_Session OK', v_c = 0);
  Assert('Контекст загружен', Core.User_Env.Get_User_Id = c_Uid);

  v_h := Core.Hash_t();
  v_h.Put('session_token', v_Token);
  Core.Auth_Api.Logout(v_h, v_c, v_m, v_o);
  Assert('Logout OK', v_c = 0);

  v_h := Core.Hash_t();
  v_h.Put('session_token', v_Token);
  v_h.Put('client_ip', '127.0.0.1');
  Core.Auth_Api.Validate_Session(v_h, v_c, v_m, v_o);
  Assert('После logout сессия невалидна', v_c = 1);

  ------------------------------------------------------------------ негативные
  -- повторное использование nonce
  declare
    h Core.Hash_t := Core.Hash_t();
    c number; m varchar2(400); o varchar2(4000); v_Nonce varchar2(64);
  begin
    h.Put('client_ip', '127.0.0.1');
    Core.Auth_Api.Issue_Nonce(h, c, m, o);
    v_Nonce := h.Get_Optional_Varchar2('nonce');
    h := Core.Hash_t(); h.Put('username', 'testuser'); h.Put('nonce', v_Nonce);
    Core.Auth_Api.Begin_Login(h, c, m, o);
    h := Core.Hash_t(); h.Put('username', 'testuser'); h.Put('nonce', v_Nonce);
    Core.Auth_Api.Begin_Login(h, c, m, o);
    Assert('Повтор nonce -> deny (code=1)', c = 1);
    Assert('Сообщение общее', m = Core.Auth_Const.c_Msg_Auth_Failed);
  end;

  -- неизвестный пользователь (не provisioned) - полный flow со stage
  v_Stage := Make_Stage('nosuchuser');
  v_h := Core.Hash_t();
  v_h.Put('username', 'nosuchuser');
  v_h.Put('stage_token', v_Stage);
  v_h.Put('provider_type', 'LOCAL');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('Не provisioned -> deny', v_c = 1);

  -- доступ запрещён (is_access_denied=Y)
  update Core.Core_Users set Is_Access_Denied = 'Y' where User_Id = c_Uid;
  commit;
  v_Stage := Make_Stage('testuser');
  v_h := Core.Hash_t();
  v_h.Put('username', 'testuser');
  v_h.Put('password', c_Pwd);
  v_h.Put('stage_token', v_Stage);
  v_h.Put('provider_type', 'LOCAL');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('is_access_denied=Y -> deny', v_c = 1);
  update Core.Core_Users set Is_Access_Denied = 'N' where User_Id = c_Uid;
  commit;

  Dbms_Output.Put_Line('--- ИТОГ AUTH_API: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
