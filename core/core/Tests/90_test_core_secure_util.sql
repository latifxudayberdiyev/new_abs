----------------------------------------------------------------------------------------------------
--  Test: Core_Secure_Util.Encrypt/Decrypt - random IV + encrypt-then-MAC.
--  Self-contained: sets its own test credentials (package globals are
--  per-session/UGA, so the app's own Set_Credentials call - normally done
--  at startup - is not visible to this session).
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  v_Pass  number := 0;
  v_Fail  number := 0;
  c_Id    constant number := 12345;
  v_Enc1  varchar2(4000);
  v_Enc2  varchar2(4000);
  v_Tampered varchar2(4000);
  v_Ok    boolean;
  --------------------------------------------------
  Procedure Assert(i_Name varchar2, i_Cond boolean) is
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
  Dbms_Output.Put_Line('=== Core_Secure_Util ===');

  Core_Secure_Util.Set_Credentials(i_Secure_Key => Dbms_Crypto.Randombytes(32),
                                   i_Iv         => Dbms_Crypto.Randombytes(16));

  -- 1. round-trip
  v_Enc1 := Core_Secure_Util.Encrypt(c_Id, 'TEST_ENTITY');
  Assert('round-trip decrypts to original id',
         Core_Secure_Util.Decrypt(v_Enc1, 'TEST_ENTITY') = To_Char(c_Id));

  -- 2. same value encrypted twice -> different ciphertext (random IV)
  v_Enc2 := Core_Secure_Util.Encrypt(c_Id, 'TEST_ENTITY');
  Assert('same id encrypted twice yields different ciphertext', v_Enc1 != v_Enc2);

  -- 3. wrong entity on decrypt -> rejected
  begin
    declare
      v_Dummy varchar2(4000);
    begin
      v_Dummy := Core_Secure_Util.Decrypt(v_Enc1, 'OTHER_ENTITY');
    end;
    Assert('wrong entity raises', false);
  exception
    when others then
      Assert('wrong entity raises', true);
  end;

  -- 4. tampered ciphertext (bit-flip the first IV byte, as a CBC bit-flip
  --    attack would attempt) -> rejected
  declare
    v_Full  raw(4000) := Utl_Encode.Base64_Decode(Utl_Raw.Cast_To_Raw(v_Enc1));
    v_First raw(1)    := Utl_Raw.Substr(v_Full, 1, 1);
    v_Rest  raw(4000) := Utl_Raw.Substr(v_Full, 2);
  begin
    v_Tampered := Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Encode(
                    Utl_Raw.Bit_Xor(v_First, 'FF') || v_Rest));
  end;
  begin
    declare
      v_Dummy varchar2(4000);
    begin
      v_Dummy := Core_Secure_Util.Decrypt(v_Tampered, 'TEST_ENTITY');
    end;
    Assert('tampered ciphertext raises (not silently decrypted)', false);
  exception
    when others then
      Assert('tampered ciphertext raises (not silently decrypted)', true);
  end;

  Dbms_Output.Put_Line('--- Core_Secure_Util tests: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
