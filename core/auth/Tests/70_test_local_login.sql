----------------------------------------------------------------------------------------------------
--  Test: LOCAL provider password verification inside Auth_Kernel.Complete_Login
--  (PBKDF2 + app-pepper, see Auth_Util/Auth_Pepper), and the single-call
--  Auth_Legacy_Bridge.Login_Local facade used by legacy JSP.
--  Requires CORE.HASH_T body (see 00_setup_fixture.sql notes).
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;
set define off;

declare
  v_Pass  number := 0;
  v_Fail  number := 0;
  c_Uid   constant number := 999999903;
  c_Ident constant number := 999999903;
  c_Uname constant varchar2(32) := 'localloginuser';
  c_Pwd   constant varchar2(32) := 'CorrectPass1';
  v_h     Core.Hash_t;
  v_c     number;
  v_m     varchar2(400);
  v_o     varchar2(4000);
  v_Nonce varchar2(64);
  v_Stage varchar2(64);
  v_Cnt   number;
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
  -- Plays the role of the caller: nonce -> Begin_Login, returns stage_token.
  Function Make_Stage(i_Username varchar2) return varchar2 is
    h Core.Hash_t := Core.Hash_t();
    c number;
    m varchar2(400);
    o varchar2(4000);
    n varchar2(64);
  begin
    h.Put('client_ip', '127.0.0.1');
    h.Put('user_agent', 'JUnit');
    Core.Auth_Api.Issue_Nonce(h, c, m, o);
    n := h.Get_Optional_Varchar2('nonce');
    --
    h := Core.Hash_t();
    h.Put('username', i_Username);
    h.Put('nonce', n);
    h.Put('client_ip', '127.0.0.1');
    h.Put('user_agent', 'JUnit');
    Core.Auth_Api.Begin_Login(h, c, m, o);
    return h.Get_Optional_Varchar2('stage_token');
  end;
begin
  Dbms_Output.Put_Line('=== LOCAL LOGIN (Complete_Login + Auth_Legacy_Bridge.Login_Local) ===');

  --==== setup ======================================================
  -- Also clears any Auth_Sessions row left behind by a previous run that
  -- errored before reaching its own teardown (AUTH_SESSIONS_F1 would
  -- otherwise block the Core_Users delete below on a re-run).
  delete from Core.Auth_Sessions    where User_Id = c_Uid;
  delete from Core.Auth_Audit_Log   where Username_Tried = c_Uname;
  delete from Core.Auth_Lockouts    where Username = c_Uname;
  delete from Core.Core_User_Keys   where Identity_Id = c_Ident;
  delete from Core.Core_Users       where User_Id = c_Uid;

  insert into Core.Core_Users
    (User_Id, Cb_Code, Local_Code, User_Type_Id, name, language, Theme_Id,
     Is_Access_Denied, Access_Level_Set, Group_Set, Debug, State,
     Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_Uid, '00440', '01000', 0, 'LOCAL LOGIN TEST USER', 'ru', 0,
     'N', 0, Hextoraw('00'), 'N', 'A',
     Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
     0, sysdate, 0, sysdate);

  insert into Core.Core_User_Keys
    (Identity_Id, User_Id, Provider_Type, Provider_Key, Is_Required,
     Password, Password_Must_Be_Changed, State, Modified_By, Modified_On, Description)
  values
    (c_Ident, c_Uid, 'LOCAL', c_Uname, 'N',
     Core.Auth_Util.Make_Local_Hash(c_Pwd), 'N', 'A', 0, sysdate, 'LOCAL login test fixture');
  commit;

  --==== 0. Make_Local_Hash / Verify_Local_Hash round-trip through the pepper ==
  Assert('Make_Local_Hash format', Instr(Core.Auth_Util.Make_Local_Hash(c_Pwd), 'pbkdf2_sha512$') = 1);

  --==== 1. wrong password -> deny, lockout fail count grows =======
  v_Stage := Make_Stage(c_Uname);
  v_h := Core.Hash_t();
  v_h.Put('username', c_Uname);
  v_h.Put('password', 'wrong_password');
  v_h.Put('stage_token', v_Stage);
  v_h.Put('provider_type', 'LOCAL');
  v_h.Put('client_ip', '127.0.0.1');
  v_h.Put('user_agent', 'JUnit');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('Complete_Login LOCAL: wrong password -> deny', v_c = 1);

  select Fail_Count into v_Cnt from Core.Auth_Lockouts where Username = c_Uname;
  Assert('Wrong password increments lockout fail count', v_Cnt = 1);

  --==== 2. correct password -> OK (fresh stage token, previous one is single-use) ==
  v_Stage := Make_Stage(c_Uname);
  v_h := Core.Hash_t();
  v_h.Put('username', c_Uname);
  v_h.Put('password', c_Pwd);
  v_h.Put('stage_token', v_Stage);
  v_h.Put('provider_type', 'LOCAL');
  v_h.Put('client_ip', '127.0.0.1');
  v_h.Put('user_agent', 'JUnit');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('Complete_Login LOCAL: correct password -> OK', v_c = 0);
  Assert('session_token returned', v_h.Get_Optional_Varchar2('session_token') is not null);
  Assert('user_id correct', v_h.Get_Optional_Number('user_id') = c_Uid);
  Assert('must_change_password = N', v_h.Get_Optional_Varchar2('must_change_password') = 'N');

  --==== 3. must_change_password flag is propagated ================
  update Core.Core_User_Keys
     set Password_Must_Be_Changed = 'Y'
   where Identity_Id = c_Ident;
  commit;

  v_Stage := Make_Stage(c_Uname);
  v_h := Core.Hash_t();
  v_h.Put('username', c_Uname);
  v_h.Put('password', c_Pwd);
  v_h.Put('stage_token', v_Stage);
  v_h.Put('provider_type', 'LOCAL');
  v_h.Put('client_ip', '127.0.0.1');
  v_h.Put('user_agent', 'JUnit');
  Core.Auth_Api.Complete_Login(v_h, v_c, v_m, v_o);
  Assert('Complete_Login LOCAL: still OK with must_change_password=Y', v_c = 0);
  Assert('must_change_password = Y is surfaced', v_h.Get_Optional_Varchar2('must_change_password') = 'Y');

  update Core.Core_User_Keys
     set Password_Must_Be_Changed = 'N'
   where Identity_Id = c_Ident;
  commit;

  --==== 4. Auth_Legacy_Bridge.Login_Local (single-call scalar facade) =========
  declare
    v_Sess   varchar2(64);
    v_Uid2   varchar2(40);
    v_Name2  varchar2(200);
    v_Cb2    varchar2(20);
    v_Local2 varchar2(20);
    v_Filial2 varchar2(200);
    v_Lang2  varchar2(10);
    v_Mcp2   varchar2(1);
    v_Code2  varchar2(40);
    v_Msg2   varchar2(400);
  begin
    Core.Auth_Legacy_Bridge.Login_Local(c_Uname, c_Pwd, '127.0.0.1', 'JUnit',
                                        v_Sess, v_Uid2, v_Name2, v_Cb2, v_Local2, v_Filial2, v_Lang2,
                                        v_Mcp2, v_Code2, v_Msg2);
    Assert('Bridge.Login_Local: code=0', v_Code2 = '0');
    Assert('Bridge.Login_Local: session token returned', v_Sess is not null);
    Assert('Bridge.Login_Local: user_id as string', v_Uid2 = To_Char(c_Uid));
    Assert('Bridge.Login_Local: cb_code = 00440', v_Cb2 = '00440');
    Assert('Bridge.Login_Local: local_code = 01000', v_Local2 = '01000');
    Assert('Bridge.Login_Local: filial_name returned (fallback ok if no Abs_Branches row)',
           v_Filial2 is not null);
  end;

  declare
    v_Sess   varchar2(64);
    v_Uid2   varchar2(40);
    v_Name2  varchar2(200);
    v_Cb2    varchar2(20);
    v_Local2 varchar2(20);
    v_Filial2 varchar2(200);
    v_Lang2  varchar2(10);
    v_Mcp2   varchar2(1);
    v_Code2  varchar2(40);
    v_Msg2   varchar2(400);
  begin
    Core.Auth_Legacy_Bridge.Login_Local(c_Uname, 'wrong_password', '127.0.0.1', 'JUnit',
                                        v_Sess, v_Uid2, v_Name2, v_Cb2, v_Local2, v_Filial2, v_Lang2,
                                        v_Mcp2, v_Code2, v_Msg2);
    Assert('Bridge.Login_Local: wrong password -> code=1', v_Code2 = '1');
    Assert('Bridge.Login_Local: no session token on failure', v_Sess is null);
  end;

  --==== teardown ====================================================
  -- Complete_Login/Login_Local calls above each created a live row in
  -- Auth_Sessions (Create_Session) - delete those first or Core_Users
  -- delete fails on AUTH_SESSIONS_F1 (child record found).
  delete from Core.Auth_Sessions    where User_Id = c_Uid;
  delete from Core.Auth_Audit_Log   where Username_Tried = c_Uname;
  delete from Core.Auth_Lockouts    where Username = c_Uname;
  delete from Core.Core_User_Keys   where Identity_Id = c_Ident;
  delete from Core.Core_Users_h     where User_Id = c_Uid;
  delete from Core.Core_Users       where User_Id = c_Uid;
  commit;

  Dbms_Output.Put_Line('--- LOCAL LOGIN tests: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
