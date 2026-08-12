----------------------------------------------------------------------------------------------------
--  Тест CORE.AUTH_NONCE: выдача, одноразовость, повтор, несуществующий, просрочка.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  v_Pass  number := 0;
  v_Fail  number := 0;
  v_Nonce varchar2(64);
  v_Ttl   number;
  v_r     varchar2(40);
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
  Dbms_Output.Put_Line('=== AUTH_NONCE ===');

  -- выдача
  Core.Auth_Nonce.Issue('127.0.0.1', 'JUnit', v_Nonce, v_Ttl);
  Assert('Issue вернул nonce', v_Nonce is not null and Length(v_Nonce) > 0);
  Assert('Issue TTL = 60', v_Ttl = 60);

  -- первое гашение - OK
  v_r := Core.Auth_Nonce.Consume(v_Nonce);
  Assert('Consume первый раз OK', v_r = Core.Auth_Const.c_Rsn_Ok);

  -- повторное гашение - уже использован
  v_r := Core.Auth_Nonce.Consume(v_Nonce);
  Assert('Consume повтор -> USED', v_r = Core.Auth_Const.c_Rsn_Nonce_Used);

  -- несуществующий
  v_r := Core.Auth_Nonce.Consume('zzz_no_such_nonce');
  Assert('Consume чужой -> INVALID', v_r = Core.Auth_Const.c_Rsn_Nonce_Invalid);

  -- пустой
  v_r := Core.Auth_Nonce.Consume(null);
  Assert('Consume null -> MISSING', v_r = Core.Auth_Const.c_Rsn_Nonce_Missing);

  -- просрочка: вставим вручную просроченный nonce
  insert into Core.Auth_Login_Nonce
    (Nonce, Issued_On, Expires_On, Used)
  values
    ('expired_test_nonce', sysdate - 1, sysdate - 1 / 24, 'N');
  commit;
  v_r := Core.Auth_Nonce.Consume('expired_test_nonce');
  Assert('Consume просрочен -> EXPIRED', v_r = Core.Auth_Const.c_Rsn_Nonce_Expired);
  delete from Core.Auth_Login_Nonce
   where Nonce = 'expired_test_nonce';
  commit;

  Dbms_Output.Put_Line('--- ИТОГ AUTH_NONCE: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
