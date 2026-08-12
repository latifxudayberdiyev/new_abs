create or replace package Core_Secure_Util is

  Procedure Set_Credentials
  (
    i_Secure_Key in raw,
    i_Iv         in raw
  );

  Function Encrypt
  (
    i_Text   varchar2,
    i_Entity varchar2
  ) return varchar2;

  Function Encrypt
  (
    i_Text   number,
    i_Entity varchar2
  ) return varchar2;

  Function Decrypt
  (
    i_Text   varchar2,
    i_Entity varchar2
  ) return varchar2;

end Core_Secure_Util;
/
create or replace package body Core_Secure_Util is

  -- Har bir chaqiruvda yangi, tasodifiy IV ishlatiladi (bir xil kalit+IV
  -- juftligi ikkinchi marta hech qachon ishlatilmasligi kerak). IV maxfiy
  -- emas - shifrmatn oldiga qo'shib yuboriladi.
  --
  -- CBC + autentifikatsiyasiz IV = xavfli: chaqiruvchi entity+id qismini
  -- (masalan o'zining id'sini) allaqachon bilgani uchun, IV baytlarini
  -- XOR qilib shifrmatnni o'zgartirmasdan ochiq matnni almashtirib yuborishi
  -- mumkin (kalitni bilmasa ham) - to'liq IDOR bypass. Shuning uchun
  -- HMAC-SHA256 tag qo'shiladi (encrypt-then-MAC): Decrypt tag mos kelmasa
  -- Dbms_Crypto.Decrypt'ni umuman chaqirmaydi.
  c_Iv_Len  constant pls_integer := 16;
  c_Tag_Len constant pls_integer := 16;
  c_Err_Code constant number := -20000; -- barcha Raise_Application_Error sitelari uchun umumiy

  Procedure Set_Credentials
  (
    i_Secure_Key in raw,
    i_Iv         in raw
  ) is
    v_Encryption_Type pls_integer := Dbms_Crypto.Encrypt_Aes256 + Dbms_Crypto.Chain_Cbc +
                                     Dbms_Crypto.Pad_None;
    v_Temp            raw(48);
    Key_Bytes_Raw     raw(32);
  begin
    if i_Secure_Key is null or i_Iv is null then
      Raise_Application_Error(c_Err_Code,
                              '??????? ??????(Credentials) ?? ????? ???? ???????.');
    end if;
    v_Temp := Dbms_Crypto.Mac(Src => Dbms_Crypto.Randombytes(2048),
                              Typ => Dbms_Crypto.Hash_Sh256,
                              Key => i_Secure_Key);

    Key_Bytes_Raw := Dbms_Crypto.Encrypt(Src => Utl_Raw.Substr(v_Temp, 1, 32),
                                         Typ => v_Encryption_Type,
                                         Key => Utl_Raw.Substr(v_Temp, -32));
    Dbms_Output.Put_Line(Utl_Raw.Length(Key_Bytes_Raw));
    Core_Secure_Env.g_Secure_Key := Key_Bytes_Raw;
    Core_Secure_Env.g_Iv         := i_Iv;

  exception
    when others then
      Raise_Application_Error(c_Err_Code,
                              '?????? ??? ????????? ??????? ??????(credentials), (key ? iv)');
  end Set_Credentials;

  Function Mac_Key return raw is
  begin
    return Dbms_Crypto.Mac(Src => Utl_Raw.Cast_To_Raw('CORE_SECURE_UTIL-MAC'),
                           Typ => Dbms_Crypto.Hmac_Sh256,
                           Key => Core_Secure_Env.g_Secure_Key);
  end;

  Function Encrypt(i_Text varchar2) return varchar2 as
    Encryption_Type pls_integer := Dbms_Crypto.Encrypt_Aes256 + Dbms_Crypto.Chain_Cbc +
                                   Dbms_Crypto.Pad_Pkcs5;
    v_Iv            raw(16) := Dbms_Crypto.Randombytes(c_Iv_Len);
    Encrypted_Raw   raw(4000);
    v_Tag           raw(16);
  begin
    if i_Text is null then
      return null;
    end if;

    Encrypted_Raw := Dbms_Crypto.Encrypt(Src => Utl_I18n.String_To_Raw(i_Text, 'AL32UTF8'),
                                         Typ => Encryption_Type,
                                         Key => Core_Secure_Env.g_Secure_Key,
                                         Iv  => v_Iv);
    v_Tag := Utl_Raw.Substr(Dbms_Crypto.Mac(Src => v_Iv || Encrypted_Raw,
                                            Typ => Dbms_Crypto.Hmac_Sh256,
                                            Key => Mac_Key),
                            1, c_Tag_Len);
    return replace(replace(Utl_Raw.Cast_To_Varchar2(Utl_Encode.Base64_Encode(v_Iv || v_Tag || Encrypted_Raw)),
                           Chr(13),
                           ''),
                   Chr(10),
                   '');
  end;

  Function Decrypt(i_Text varchar2) return varchar2 as
    Encryption_Type pls_integer := Dbms_Crypto.Encrypt_Aes256 + Dbms_Crypto.Chain_Cbc +
                                   Dbms_Crypto.Pad_Pkcs5;
    v_Raw          raw(4000);
    v_Iv           raw(16);
    v_Tag          raw(16);
    v_Cipher       raw(4000);
    v_Expected_Tag raw(16);
    Decrypted_Raw  raw(4000);
    Bad_Tag        exception;
  begin
    if i_Text is null then
      return null;
    end if;

    v_Raw := Utl_Encode.Base64_Decode(Utl_Raw.Cast_To_Raw(i_Text));
    if v_Raw is null or Utl_Raw.Length(v_Raw) <= c_Iv_Len + c_Tag_Len then
      raise Bad_Tag;
    end if;

    v_Iv     := Utl_Raw.Substr(v_Raw, 1, c_Iv_Len);
    v_Tag    := Utl_Raw.Substr(v_Raw, c_Iv_Len + 1, c_Tag_Len);
    v_Cipher := Utl_Raw.Substr(v_Raw, c_Iv_Len + c_Tag_Len + 1);

    v_Expected_Tag := Utl_Raw.Substr(Dbms_Crypto.Mac(Src => v_Iv || v_Cipher,
                                                     Typ => Dbms_Crypto.Hmac_Sh256,
                                                     Key => Mac_Key),
                                     1, c_Tag_Len);
    if Utl_Raw.Compare(v_Tag, v_Expected_Tag) != 0 then
      raise Bad_Tag;
    end if;

    Decrypted_Raw := Dbms_Crypto.Decrypt(Src => v_Cipher,
                                         Typ => Encryption_Type,
                                         Key => Core_Secure_Env.g_Secure_Key,
                                         Iv  => v_Iv);
    return Utl_I18n.Raw_To_Char(Data => Decrypted_Raw, Src_Charset => 'AL32UTF8');
  exception
    when Bad_Tag then
      Raise_Application_Error(c_Err_Code, 'Invalid or tampered encrypted value.');
  end;

  Function Decrypt
  (
    i_Text   varchar2,
    i_Entity varchar2
  ) return varchar2 as
    Decrypted_Value   varchar2(4000);
    Decrypted_Entity  varchar2(4000);
    Wrong_Entity_Name exception;
  begin
    if i_Text is null then
      return null;
    end if;

    Decrypted_Value := Decrypt(i_Text);

    if Instr(Decrypted_Value, Chr(1)) = 0 then
      raise Wrong_Entity_Name;
    end if;

    Decrypted_Entity := Substr(Decrypted_Value, 0, Instr(Decrypted_Value, Chr(1)) - 1);

    if (i_Entity != Decrypted_Entity) then
      raise Wrong_Entity_Name;
    end if;

    return Substr(Decrypted_Value, Instr(Decrypted_Value, Chr(1)) + 1, Length(Decrypted_Value));
  exception
    when Wrong_Entity_Name then
      Raise_Application_Error(c_Err_Code,
                              '???-?? ????? ?? ??? ? ????????????! ??????????, ????????? ???????????? ???????? ? ????????? ?????.');
    when others then
      Raise_Application_Error(c_Err_Code,
                              '???-?? ????? ?? ??? ? ????????????! ??????????, ????????? ???????????? ???????? ? ????????? ?????.');
  end;

  Function Encrypt
  (
    i_Text   number,
    i_Entity varchar2
  ) return varchar2 as
  begin
    if i_Text is null then
      return null;
    end if;
    return Encrypt(i_Entity || Chr(1) || to_char(i_Text));
  end;

  Function Encrypt
  (
    i_Text   varchar2,
    i_Entity varchar2
  ) return varchar2 as
  begin
    if i_Text is null then
      return null;
    end if;
    return Encrypt(i_Entity || Chr(1) || i_Text);
  end;
end Core_Secure_Util;
/
