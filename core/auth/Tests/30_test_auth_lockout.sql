----------------------------------------------------------------------------------------------------
--  Тест CORE.AUTH_LOCKOUT: накопление неудач, блокировка по порогу, сброс.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  v_Pass number := 0;
  v_Fail number := 0;
  c_u constant varchar2(100) := 'lock_test_user';
  v_Until date;
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
  Dbms_Output.Put_Line('=== AUTH_LOCKOUT ===');

  -- чистый старт
  delete from Core.Auth_Lockouts
   where Username = c_u;
  commit;

  Assert('Изначально не заблокирован',
         not Core.Auth_Lockout.Is_Locked(c_u, v_Until));

  -- 4 неудачи - ещё не заблокирован (порог 5)
  for i in 1 .. 4
  loop
    Core.Auth_Lockout.Register_Failure(c_u);
  end loop;
  Assert('После 4 неудач не заблокирован',
         not Core.Auth_Lockout.Is_Locked(c_u, v_Until));

  -- 5-я неудача -> блокировка
  Core.Auth_Lockout.Register_Failure(c_u);
  Assert('После 5 неудач заблокирован',
         Core.Auth_Lockout.Is_Locked(c_u, v_Until));
  Assert('locked_until в будущем', v_Until > sysdate);

  -- сброс -> разблокирован
  Core.Auth_Lockout.Reset(c_u);
  Assert('После Reset разблокирован',
         not Core.Auth_Lockout.Is_Locked(c_u, v_Until));

  delete from Core.Auth_Lockouts
   where Username = c_u;
  commit;
  Dbms_Output.Put_Line('--- ИТОГ AUTH_LOCKOUT: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
