create or replace package Auth_Util is
  -- Author      : CROBS
  -- Created     : 18.05.2026
  -- Изменён     : 01.07.2026 - убран client-side wire-proof (см. Auth_Pepper) -
  --               транспорт пароля защищает HTTPS, не самодельная криптография.
  --               Добавлен app-pepper поверх PBKDF2 (защита при утечке только БД).
  -- Назначение  : Криптографические помощники (только DBMS_CRYPTO - без Java / без JWT).
  ----------------------------------------------------------------------------------------------------
  -- прогрессивная блокировка по уровню: 1->5, 2->15, 3->30, 4+->60 (минут)
  Function Lock_Minutes(i_Level pls_integer) return pls_integer;
  ----------------------------------------------------------------------------------------------------
  -- Криптостойкий случайный токен, возвращается в нижнем регистре hex.
  Function Random_Token(i_Bytes pls_integer := 32) return varchar2;
  ----------------------------------------------------------------------------------------------------
  -- SHA-256 строки UTF-8, hex в верхнем регистре (хэширование токена сессии при хранении).
  Function Hash_Sha256(i_Text varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  -- Нормализация имени пользователя (нижний регистр / trim) - единый источник истины.
  Function Norm_Username(i_Username varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  -- PBKDF2-HMAC-SHA512, один производный блок, hex. Только для провайдера LOCAL.
  Function Pbkdf2_Sha512
  (
    i_Password   varchar2,
    i_Salt_Hex   varchar2,
    i_Iterations pls_integer := 120000
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  -- Сформировать / проверить хэш LOCAL:  pbkdf2_sha512$<iter>$<salt_hex>$<hash_hex>,
  -- где hash_hex = HMAC-SHA512(Auth_Pepper.c_Pepper, PBKDF2(password, salt, iter)).
  -- Pepper не хранится в БД - при утечке только базы (без исходников) offline
  -- перебор соли+хэша недостаточен для восстановления пароля.
  Function Make_Local_Hash(i_Password varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  Function Verify_Local_Hash
  (
    i_Password varchar2,
    i_Stored   varchar2
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
end Auth_Util;
/
create or replace package body Auth_Util is
  ----------------------------------------------------------------------------------------------------
  Function Lock_Minutes(i_Level pls_integer) return pls_integer is
  begin
    case
      when i_Level <= 1 then
        return 5;
      when i_Level = 2 then
        return 15;
      when i_Level = 3 then
        return 30;
      else
        return 60;
    end case;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Random_Token(i_Bytes pls_integer := 32) return varchar2 is
  begin
    return Lower(Rawtohex(Sys.Dbms_Crypto.Randombytes(i_Bytes)));
  end;
  ----------------------------------------------------------------------------------------------------
  Function Hash_Sha256(i_Text varchar2) return varchar2 is
  begin
    return Rawtohex(Sys.Dbms_Crypto.Hash(Utl_I18n.String_To_Raw(i_Text, 'AL32UTF8'),
                                         Sys.Dbms_Crypto.Hash_Sh256));
  end;
  ----------------------------------------------------------------------------------------------------
  Function Norm_Username(i_Username varchar2) return varchar2 is
  begin
    return Lower(trim(i_Username));
  end;
  ----------------------------------------------------------------------------------------------------
  Function Pbkdf2_Sha512
  (
    i_Password   varchar2,
    i_Salt_Hex   varchar2,
    i_Iterations pls_integer := 120000
  ) return varchar2 is
    v_Pwd  raw(2000) := Utl_I18n.String_To_Raw(i_Password, 'AL32UTF8');
    v_Salt raw(2000) := Hextoraw(i_Salt_Hex);
    v_u    raw(64);
    v_t    raw(64);
  begin
    -- PBKDF2 (RFC 8018), один блок i=1 : T = U1 xor U2 xor ... xor Uc
    v_u := Sys.Dbms_Crypto.Mac(Utl_Raw.Concat(v_Salt, Hextoraw('00000001')),
                               Sys.Dbms_Crypto.Hmac_Sh512,
                               v_Pwd);
    v_t := v_u;
    --
    for i in 2 .. i_Iterations
    loop
      v_u := Sys.Dbms_Crypto.Mac(v_u, Sys.Dbms_Crypto.Hmac_Sh512, v_Pwd);
      v_t := Utl_Raw.Bit_Xor(v_t, v_u);
    end loop;
    --
    return Lower(Rawtohex(v_t));
  end;
  ----------------------------------------------------------------------------------------------------
  -- app-pepper поверх PBKDF2-выхода: HMAC-SHA512(pepper, pbkdf2_hex). Ключ -
  -- Auth_Pepper.c_Pepper (deploy-only константа, не в git, см. Auth_Pepper.pck).
  Function Peppered_Hash(i_Pbkdf2_Hex varchar2) return varchar2 is
  begin
    return Lower(Rawtohex(Sys.Dbms_Crypto.Mac(Utl_I18n.String_To_Raw(i_Pbkdf2_Hex, 'AL32UTF8'),
                                              Sys.Dbms_Crypto.Hmac_Sh512,
                                              Utl_I18n.String_To_Raw(Auth_Pepper.c_Pepper, 'AL32UTF8'))));
  end;
  ----------------------------------------------------------------------------------------------------
  Function Make_Local_Hash(i_Password varchar2) return varchar2 is
    v_Salt varchar2(64) := Lower(Rawtohex(Sys.Dbms_Crypto.Randombytes(Auth_Const.c_Pbkdf2_Salt_Bytes)));
  begin
    return 'pbkdf2_sha512$' || Auth_Const.c_Pbkdf2_Iterations || '$' || v_Salt || '$' ||
           Peppered_Hash(Pbkdf2_Sha512(i_Password, v_Salt, Auth_Const.c_Pbkdf2_Iterations));
  end;
  ----------------------------------------------------------------------------------------------------
  Function Verify_Local_Hash
  (
    i_Password varchar2,
    i_Stored   varchar2
  ) return boolean is
    v_Iter pls_integer;
    v_Salt varchar2(256);
    v_Hash varchar2(256);
    v_Calc varchar2(256);
  begin
    -- проверка формата хранимого хэша
    if i_Stored is null or Instr(i_Stored, 'pbkdf2_sha512$') != 1 then
      return false;
    end if;
    --
    v_Iter := to_number(Regexp_Substr(i_Stored, '[^$]+', 1, 2));
    v_Salt := Regexp_Substr(i_Stored, '[^$]+', 1, 3);
    v_Hash := Regexp_Substr(i_Stored, '[^$]+', 1, 4);
    v_Calc := Peppered_Hash(Pbkdf2_Sha512(i_Password, v_Salt, v_Iter));
    -- сравнение с учётом длины (приближённо постоянное время)
    if Length(v_Calc) != Length(v_Hash) then
      return false;
    end if;
    --
    return v_Calc = v_Hash;
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Util;
/
