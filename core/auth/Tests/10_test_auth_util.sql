----------------------------------------------------------------------------------------------------
--  Тест CORE.AUTH_UTIL. Запускать под CORE. Требует GRANT EXECUTE ... DBMS_CRYPTO TO CORE.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  v_Pass   number := 0;
  v_Fail   number := 0;
  v_T1     varchar2(200);
  v_T2     varchar2(200);
  v_H1     varchar2(200);
  v_Salt   varchar2(64);
  v_P1     varchar2(200);
  v_P2     varchar2(200);
  v_Stored varchar2(400);
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
  Dbms_Output.Put_Line('=== AUTH_UTIL ===');

  -- Random_Token: длина = 2*bytes, разные значения
  v_T1 := Core.Auth_Util.Random_Token(32);
  v_T2 := Core.Auth_Util.Random_Token(32);
  Assert('Random_Token длина 64 hex', Length(v_T1) = 64);
  Assert('Random_Token уникален', v_T1 != v_T2);
  Assert('Random_Token нижний регистр', v_T1 = Lower(v_T1));

  -- Hash_Sha256: детерминирован, 64 hex, разные входы -> разный хэш
  v_H1 := Core.Auth_Util.Hash_Sha256('abc');
  Assert('SHA256 длина 64', Length(v_H1) = 64);
  Assert('SHA256 детерминирован', v_H1 = Core.Auth_Util.Hash_Sha256('abc'));
  Assert('SHA256 чувствителен', v_H1 != Core.Auth_Util.Hash_Sha256('abd'));

  -- Norm_Username
  Assert('Norm_Username trim+lower', Core.Auth_Util.Norm_Username('  MAN_UTD  ') = 'man_utd');

  -- PBKDF2: детерминирован, соль/пароль влияют
  v_Salt := 'a1b2c3d4e5f60718';
  v_P1   := Core.Auth_Util.Pbkdf2_Sha512('secret', v_Salt, 2000);
  v_P2   := Core.Auth_Util.Pbkdf2_Sha512('secret', v_Salt, 2000);
  Assert('PBKDF2 детерминирован', v_P1 = v_P2);
  Assert('PBKDF2 от пароля', v_P1 != Core.Auth_Util.Pbkdf2_Sha512('secre7', v_Salt, 2000));
  Assert('PBKDF2 от соли',
         v_P1 != Core.Auth_Util.Pbkdf2_Sha512('secret', 'ffffffffffffffff', 2000));
  Assert('PBKDF2 от итераций',
         v_P1 != Core.Auth_Util.Pbkdf2_Sha512('secret', v_Salt, 3000));

  -- Make/Verify LOCAL hash (использует c_Pbkdf2_Iterations - может занять ~секунду)
  v_Stored := Core.Auth_Util.Make_Local_Hash('P@ssw0rd');
  Assert('Make_Local_Hash формат', Instr(v_Stored, 'pbkdf2_sha512$') = 1);
  Assert('Verify верный пароль',
         Core.Auth_Util.Verify_Local_Hash('P@ssw0rd', v_Stored));
  Assert('Verify неверный пароль',
         not Core.Auth_Util.Verify_Local_Hash('wrong', v_Stored));
  Assert('Verify мусор', not Core.Auth_Util.Verify_Local_Hash('x', 'garbage'));

  Dbms_Output.Put_Line('--- ИТОГ AUTH_UTIL: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
