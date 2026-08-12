----------------------------------------------------------------------------------------------------
--  Тест парольного механизма (LOCAL): Change/Reset/Request через CORE.AUTH_API.
--  Самодостаточный: создаёт LOCAL-пользователя 'pwduser' (user_id=999999902) напрямую,
--  тестирует, удаляет. Требует валидный CORE.HASH_T body.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;
set define off;

declare
  v_Pass number := 0;
  v_Fail number := 0;
  c_Uid   constant number := 999999902;
  c_Ident constant number := 999999902;
  c_Uname constant varchar2(32) := 'pwduser';
  c_Pwd1  constant varchar2(32) := 'OldPass1';
  c_Pwd2  constant varchar2(32) := 'NewPass2';
  c_Pwd3  constant varchar2(32) := 'ResetPass3';
  v_h     Core.Hash_t;
  v_c     number;
  v_m     varchar2(400);
  v_o     varchar2(4000);
  v_Token varchar2(64);
  v_Cnt   number;
  v_Key   Core_User_Keys%rowtype;
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
  Dbms_Output.Put_Line('=== AUTH_PWD (LOCAL) ===');

  --==== setup ====================================================
  -- чистка возможных остатков
  delete from Core.Auth_Password_Resets
   where Identity_Id = c_Ident;
  delete from Core.Auth_Audit_Log
   where Username_Tried = c_Uname;
  delete from Core.Core_User_Keys
   where Identity_Id = c_Ident;
  delete from Core.Core_Users
   where User_Id = c_Uid;
  --
  insert into Core.Core_Users
    (User_Id,
     Cb_Code,
     Local_Code,
     User_Type_Id,
     name,
     language,
     Theme_Id,
     Is_Access_Denied,
     Access_Level_Set,
     Group_Set,
     Debug,
     State,
     Activate_Date,
     Deactivate_Date,
     Created_By,
     Created_On,
     Modified_By,
     Modified_On)
  values
    (c_Uid,
     '00440',
     '01000',
     0,
     'PWD TEST USER',
     'ru',
     0,
     'N',
     0,
     Hextoraw('00'),
     'N',
     'A',
     Trunc(sysdate) - 1,
     to_date('31.12.9999', 'dd.mm.yyyy'),
     0,
     sysdate,
     0,
     sysdate);

  insert into Core.Core_User_Keys
    (Identity_Id,
     User_Id,
     Provider_Type,
     Provider_Key,
     Is_Required,
     Password,
     Password_Must_Be_Changed,
     State,
     Modified_By,
     Modified_On,
     Description)
  values
    (c_Ident,
     c_Uid,
     'LOCAL',
     c_Uname,
     'N',
     Core.Auth_Util.Make_Local_Hash(c_Pwd1),
     'N',
     'A',
     0,
     sysdate,
     'PWD test fixture');
  commit;

  --==== 1. Change_Password: неверный старый пароль ===============
  v_h := Core.Hash_t();
  v_h.Put('username', c_Uname);
  v_h.Put('old_password', 'wrong_old');
  v_h.Put('new_password', c_Pwd2);
  v_h.Put('client_ip', '127.0.0.1');
  v_h.Put('user_agent', 'JUnit');
  Core.Auth_Api.Change_Password(v_h, v_c, v_m, v_o);
  Assert('Change_Password: неверный старый -> deny', v_c = 1);

  --==== 2. Change_Password: слабый новый пароль (нет цифры) ======
  v_h := Core.Hash_t();
  v_h.Put('username', c_Uname);
  v_h.Put('old_password', c_Pwd1);
  v_h.Put('new_password', 'weakpass');
  Core.Auth_Api.Change_Password(v_h, v_c, v_m, v_o);
  Assert('Change_Password: слабый пароль -> deny', v_c = 1);
  Assert('Сообщение = weak_password', v_m = Core.Auth_Const.c_Msg_Weak_Password);

  --==== 3. Change_Password: успех =================================
  v_h := Core.Hash_t();
  v_h.Put('username', c_Uname);
  v_h.Put('old_password', c_Pwd1);
  v_h.Put('new_password', c_Pwd2);
  v_h.Put('client_ip', '127.0.0.1');
  Core.Auth_Api.Change_Password(v_h, v_c, v_m, v_o);
  Assert('Change_Password: правильный старый -> OK', v_c = 0);

  -- хэш в БД соответствует новому паролю
  select *
    into v_Key
    from Core.Core_User_Keys
   where Identity_Id = c_Ident;
  Assert('Новый пароль сохранён (Verify=true)',
         Core.Auth_Util.Verify_Local_Hash(c_Pwd2, v_Key.Password));
  Assert('Старый пароль больше не подходит',
         not Core.Auth_Util.Verify_Local_Hash(c_Pwd1, v_Key.Password));
  Assert('must_be_changed = N после смены', v_Key.Password_Must_Be_Changed = 'N');

  -- история записалась
  select count(*)
    into v_Cnt
    from Core.Core_User_Keys_h
   where Identity_Id = c_Ident
     and Action = 'U';
  Assert('История CORE_USER_KEYS_H пополнилась', v_Cnt >= 1);

  -- аудит записался
  select count(*)
    into v_Cnt
    from Core.Auth_Audit_Log
   where Username_Tried = c_Uname
     and Event_Type = Core.Auth_Const.c_Ev_Pwd_Changed
     and Success = 'Y';
  Assert('AUTH_AUDIT_LOG: PASSWORD_CHANGED', v_Cnt = 1);

  --==== 4. Request_Password_Reset =================================
  v_h := Core.Hash_t();
  v_h.Put('username', c_Uname);
  v_h.Put('client_ip', '127.0.0.1');
  Core.Auth_Api.Request_Password_Reset(v_h, v_c, v_m, v_o);
  Assert('Request_Reset: OK (общий ответ)', v_c = 0);
  v_Token := v_h.Get_Optional_Varchar2('token');
  Assert('Получен токен', v_Token is not null and Length(v_Token) > 0);

  -- в таблице хранится ХЭШ, а не сам токен
  select count(*)
    into v_Cnt
    from Core.Auth_Password_Resets
   where Token_Hash = v_Token;
  Assert('Сырого токена в таблице нет', v_Cnt = 0);
  select count(*)
    into v_Cnt
    from Core.Auth_Password_Resets
   where Token_Hash = Core.Auth_Util.Hash_Sha256(v_Token)
     and Identity_Id = c_Ident
     and Used = 'N';
  Assert('Хэш токена есть, не использован', v_Cnt = 1);

  --==== 5. Request для несуществующего/AD - generic OK без токена ==
  v_h := Core.Hash_t();
  v_h.Put('username', 'nosuch_local_user');
  Core.Auth_Api.Request_Password_Reset(v_h, v_c, v_m, v_o);
  Assert('Request для несущ. -> OK без раскрытия', v_c = 0);
  Assert('Токен не выдан', v_h.Get_Optional_Varchar2('token') is null);

  --==== 6. Reset_With_Token: успех ===============================
  v_h := Core.Hash_t();
  v_h.Put('token', v_Token);
  v_h.Put('new_password', c_Pwd3);
  v_h.Put('client_ip', '127.0.0.1');
  Core.Auth_Api.Reset_With_Token(v_h, v_c, v_m, v_o);
  Assert('Reset_With_Token: OK', v_c = 0);

  select *
    into v_Key
    from Core.Core_User_Keys
   where Identity_Id = c_Ident;
  Assert('Пароль после сброса - новый',
         Core.Auth_Util.Verify_Local_Hash(c_Pwd3, v_Key.Password));

  --==== 7. Reset_With_Token: повтор того же токена -> deny ========
  v_h := Core.Hash_t();
  v_h.Put('token', v_Token);
  v_h.Put('new_password', 'AnotherPwd9');
  Core.Auth_Api.Reset_With_Token(v_h, v_c, v_m, v_o);
  Assert('Повторное использование токена -> deny', v_c = 1);

  --==== 8. Reset с несуществующим токеном -> deny =================
  v_h := Core.Hash_t();
  v_h.Put('token', 'zzz_no_such_reset_token');
  v_h.Put('new_password', 'AnotherPwd9');
  Core.Auth_Api.Reset_With_Token(v_h, v_c, v_m, v_o);
  Assert('Несуществующий токен -> deny', v_c = 1);

  --==== 9. Просроченный токен -> deny =============================
  insert into Core.Auth_Password_Resets
    (Token_Hash, Identity_Id, Issued_On, Expires_On, Used)
  values
    (Core.Auth_Util.Hash_Sha256('expired_test_reset_tok'),
     c_Ident,
     sysdate - 1,
     sysdate - 1 / 24,
     'N');
  commit;
  v_h := Core.Hash_t();
  v_h.Put('token', 'expired_test_reset_tok');
  v_h.Put('new_password', 'AnotherPwd9');
  Core.Auth_Api.Reset_With_Token(v_h, v_c, v_m, v_o);
  Assert('Просроченный токен -> deny', v_c = 1);

  --==== teardown ==================================================
  delete from Core.Auth_Password_Resets
   where Identity_Id = c_Ident;
  delete from Core.Auth_Audit_Log
   where Username_Tried = c_Uname
      or Username_Tried = 'nosuch_local_user';
  delete from Core.Core_User_Keys_h
   where Identity_Id = c_Ident;
  delete from Core.Core_User_Keys
   where Identity_Id = c_Ident;
  delete from Core.Core_Users_h
   where User_Id = c_Uid;
  delete from Core.Core_Users
   where User_Id = c_Uid;
  commit;

  Dbms_Output.Put_Line('--- ИТОГ AUTH_PWD: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
