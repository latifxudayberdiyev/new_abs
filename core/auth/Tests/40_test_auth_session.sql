----------------------------------------------------------------------------------------------------
--  Тест CORE.AUTH_SESSION: создание, валидация, контекст UAPP, просрочка, закрытие.
--  Требует фикстуру (00_setup_fixture.sql) и контекст UAPP.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  v_Pass number := 0;
  v_Fail number := 0;
  c_Uid constant number := 999999901;
  v_Token varchar2(64);
  v_Ttl   number;
  v_Uid   number;
  v_Rsn   varchar2(40);
  v_Ok    boolean;
  v_Cnt   number;
  v_Token2 varchar2(64);
  v_Ttl2   number;
  v_Uid2   number;
  v_Rsn2   varchar2(40);
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
begin
  Dbms_Output.Put_Line('=== AUTH_SESSION ===');

  Core.Auth_Session.Create_Session(c_Uid,
                                   'AD',
                                   '00440',
                                   '01000',
                                   'ru',
                                   '127.0.0.1',
                                   'JUnit',
                                   v_Token,
                                   v_Ttl);
  Assert('Create вернул токен', v_Token is not null and Length(v_Token) > 0);

  -- сырого токена в таблице быть не должно (хранится только хэш)
  select count(*)
    into v_Cnt
    from Core.Auth_Sessions
   where Session_Id_Hash = v_Token;
  Assert('Токена нет в таблице (только хэш)', v_Cnt = 0);

  select count(*)
    into v_Cnt
    from Core.Auth_Sessions
   where Session_Id_Hash = Core.Auth_Util.Hash_Sha256(v_Token);
  Assert('Хэш токена есть', v_Cnt = 1);

  -- валидация + контекст
  v_Ok := Core.Auth_Session.Validate(v_Token, '127.0.0.1', v_Uid, v_Rsn);
  Assert('Validate OK', v_Ok);
  Assert('Validate user_id верен', v_Uid = c_Uid);
  Assert('SYS_CONTEXT user_id', Sys_Context('UAPP', 'user_id') = to_char(c_Uid));
  Assert('User_Env.Get_User_Id', Core.User_Env.Get_User_Id = c_Uid);
  Assert('User_Env.Get_Filial', Core.User_Env.Get_Filial_Code = '00440');

  -- Validate: har so'rovda foydalanuvchi holati qayta tekshiriladi (User_Context.pck
  -- o'chirilgandan keyin shu yerda saqlab qolingan xavfsizlik nazorati).
  Core.Auth_Session.Create_Session(c_Uid, 'AD', '00440', '01000', 'ru', '127.0.0.1', 'JUnit',
                                   v_Token2, v_Ttl2);
  update Core.Core_Users set Is_Access_Denied = 'Y' where User_Id = c_Uid;
  commit;
  v_Ok := Core.Auth_Session.Validate(v_Token2, '127.0.0.1', v_Uid2, v_Rsn2);
  Assert('Is_Access_Denied=Y bo''lgan userning sessiyasi rad etiladi', not v_Ok);
  Assert('sabab = USER_NOT_ACTIVE', v_Rsn2 = Core.Auth_Const.c_Rsn_User_Not_Active);
  select count(*)
    into v_Cnt
    from Core.Auth_Sessions
   where Session_Id_Hash = Core.Auth_Util.Hash_Sha256(v_Token2)
     and State = 'A';
  Assert('rad etilgan sessiya avtomatik yopiladi', v_Cnt = 0);
  update Core.Core_Users set Is_Access_Denied = 'N' where User_Id = c_Uid;
  commit;

  -- просрочка по idle
  update Core.Auth_Sessions
     set Idle_Expires_On = sysdate - 1 / 24
   where Session_Id_Hash = Core.Auth_Util.Hash_Sha256(v_Token);
  commit;
  v_Ok := Core.Auth_Session.Validate(v_Token, '127.0.0.1', v_Uid, v_Rsn);
  Assert('Просроченная сессия отклонена', not v_Ok);
  Assert('Причина = SESSION_EXPIRED', v_Rsn = Core.Auth_Const.c_Rsn_Session_Expired);
  Assert('Rad javobidan keyin UAPP tozalanadi', Sys_Context('UAPP', 'user_id') is null);

  -- новая сессия + закрытие (logout)
  Core.Auth_Session.Create_Session(c_Uid,
                                   'AD',
                                   '00440',
                                   '01000',
                                   'ru',
                                   '127.0.0.1',
                                   'JUnit',
                                   v_Token,
                                   v_Ttl);
  Core.Auth_Session.Close(v_Token, 'LOGOUT');
  v_Ok := Core.Auth_Session.Validate(v_Token, '127.0.0.1', v_Uid, v_Rsn);
  Assert('Закрытая сессия отклонена', not v_Ok);

  Core.Auth_Session.Clear_Context;
  Dbms_Output.Put_Line('--- ИТОГ AUTH_SESSION: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
