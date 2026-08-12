create or replace package Util_Raw is
  Version constant char(14) := '->>24062014<<-';

  --
  type Hex_Bits_t is varray(4) of varchar2(1);
  Vhex_Bits constant Hex_Bits_t := Hex_Bits_t('1', '2', '4', '8');

  --
  c_Empty_Raw constant raw(1) := Hextoraw('00');

  -- Создаёт Raw-строку с установленным битом с индексом Bit_Index
  -- Параметр Bit_Index может иметь значения в интервале 0...131067
  -- в PL/SQL и 0...15999 в SQL
  Function Raw_From_Bit(Bit_Index pls_integer) return raw;

  -- Устанавливает бит с индексом Bit_Index заданной Raw-строки R
  -- Параметр Bit_Index может иметь значения в интервале 0...131067
  -- в PL/SQL и 0...15999 в SQL
  Function Set_Bit
  (
    r         raw,
    Bit_Index pls_integer
  ) return raw;

  -- Логическое умножение (AND) здух заданних в параметрах Raw-строк
  Function Bit_And
  (
    R1 raw,
    R2 raw
  ) return raw;

  -- Логическое сложение (OR) здух заданних в параметрах Raw-строк
  Function Bit_Or
  (
    R1 raw,
    R2 raw
  ) return raw;

  -- Логическое исключающее сложение (исключающий OR, или XOR) здух заданних
  -- в параметрах Raw-строк
  Function Bit_Xor
  (
    R1 raw,
    R2 raw
  ) return raw;

  -- Проверка наличия общих битов для обоих заданних в параметрах Raw-строк
  -- Логически умножает заданные Raw-строки и возвращает 1 при наличии хотя бы
  -- одного общего бита для обоих Raw-строк, иначе возвращает 0
  Function Has_Common_Bits
  (
    R1 raw,
    R2 raw
  ) return number;

  -- Проверяет, установлен ли бит с заданным индексом Bit_Index
  -- Возвращает 1, если бит с заданным индексом установлен, иначе возвращает 0
  Function Is_Bit_Set
  (
    r         raw,
    Bit_Index number
  ) return number;

  ----------------------------------------------------------------------------
  Function Empty_Raw return raw;

  ----------------------------------------------------------------------------
  --             Служебные (специальные) функции и процедуры                --
  ----------------------------------------------------------------------------

  -- Получить версию заголовка (спецификации) пакета
  Function Getversion return varchar2;

  -- Получить версию тела пакета
  Function Getversionofbody return varchar2;

end Util_Raw;
/
create or replace package body Util_Raw is
  Versionofbody constant char(14) := '->>24062014<<-';

  -- Создаёт Raw-строку с установленным битом с индексом Bit_Index
  -- Параметр Bit_Index может иметь значения в интервале 0...131067
  -- в PL/SQL и 0...15999 в SQL
  Function Raw_From_Bit(Bit_Index pls_integer) return raw is
    Vhex_Pos pls_integer := Trunc(Bit_Index / 4);
  begin
    return Hextoraw(Rpad(Vhex_Bits(Bit_Index - 4 * Vhex_Pos + 1), Vhex_Pos + 1, '0'));
  end Raw_From_Bit;

  -- Устанавливает бит с индексом Bit_Index заданной Raw-строки R
  -- Параметр Bit_Index может иметь значения в интервале 0...131067
  -- в PL/SQL и 0...15999 в SQL
  Function Set_Bit
  (
    r         raw,
    Bit_Index pls_integer
  ) return raw is
    Vhex_Pos  pls_integer := Trunc(Bit_Index / 4);
    Vhex_Len  pls_integer := Vhex_Pos + 1;
    Vchar_Val varchar2(32767) := Rpad(Vhex_Bits(Bit_Index - 4 * Vhex_Pos + 1), Vhex_Len, '0');
    Vset_Len2 pls_integer := Length(Rawtohex(r));
  begin
    if Vset_Len2 = Vhex_Len then
      return Utl_Raw.Bit_Or(r, Hextoraw(Vchar_Val));
    elsif Vset_Len2 < Vhex_Len then
      return Utl_Raw.Bit_Or(Hextoraw(Lpad(Rawtohex(r), Vhex_Len, '0')), Hextoraw(Vchar_Val));
    else
      -- vSet_Len2 > vHex_Len
      return Utl_Raw.Bit_Or(r, Hextoraw(Lpad(Vchar_Val, Vset_Len2, '0')));
    end if;
  end Set_Bit;

  -- Логическое умножение (AND) здух заданних в параметрах Raw-строк
  Function Bit_And
  (
    R1 raw,
    R2 raw
  ) return raw is
    Vr1    varchar2(32767) := Rawtohex(R1);
    Vr2    varchar2(32767) := Rawtohex(R2);
    Vlenr1 pls_integer := Length(Vr1);
    Vlenr2 pls_integer := Length(Vr2);
  begin
    if Vlenr1 = Vlenr2 then
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_And(R1, R2)), '0'));
    elsif Vlenr1 > Vlenr2 then
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_And(Hextoraw(Substr(Vr1, 1, Vlenr2)), R2)), '0'));
    else
      -- vLenR1 < vLenR2
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_And(R1, Hextoraw(Substr(Vr2, 1, Vlenr1)))), '0'));
    end if;
  end Bit_And;

  -- Логическое сложение (OR) здух заданних в параметрах Raw-строк
  Function Bit_Or
  (
    R1 raw,
    R2 raw
  ) return raw is
    Vr1    varchar2(32767) := Rawtohex(R1);
    Vr2    varchar2(32767) := Rawtohex(R2);
    Vlenr1 pls_integer := Length(Vr1);
    Vlenr2 pls_integer := Length(Vr2);
  begin
    if Vlenr1 = Vlenr2 then
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_Or(R1, R2)), '0'));
    elsif Vlenr1 > Vlenr2 then
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_Or(Hextoraw(Substr(Vr1, 1, Vlenr2)), R2)), '0'));
    else
      -- vLenR1 < vLenR2
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_Or(R1, Hextoraw(Substr(Vr2, 1, Vlenr1)))), '0'));
    end if;
  end Bit_Or;

  -- Логическое исключающее сложение (исключающий OR, или XOR) здух заданних
  -- в параметрах Raw-строк
  Function Bit_Xor
  (
    R1 raw,
    R2 raw
  ) return raw is
    Vr1    varchar2(32767) := Rawtohex(R1);
    Vr2    varchar2(32767) := Rawtohex(R2);
    Vlenr1 pls_integer := Length(Vr1);
    Vlenr2 pls_integer := Length(Vr2);
  begin
    if Vlenr1 = Vlenr2 then
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_Xor(R1, R2)), '0'));
    elsif Vlenr1 > Vlenr2 then
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_Xor(Hextoraw(Substr(Vr1, 1, Vlenr2)), R2)), '0'));
    else
      -- vLenR1 < vLenR2
      return Hextoraw(Ltrim(Rawtohex(Utl_Raw.Bit_Xor(R1, Hextoraw(Substr(Vr2, 1, Vlenr1)))), '0'));
    end if;
  end Bit_Xor;

  -- Проверка наличия общих битов для обоих заданних в параметрах Raw-строк
  -- Логически умножает заданные Raw-строки и возвращает 1 при наличии хотя бы
  -- одного общего бита для обоих Raw-строк, иначе возвращает 0
  Function Has_Common_Bits
  (
    R1 raw,
    R2 raw
  ) return number is
    Vlenr1 pls_integer := Length(Rawtohex(R1));
    Vlenr2 pls_integer := Length(Rawtohex(R2));
  begin
    return case when case when Vlenr1 = Vlenr2 then Ltrim(Rawtohex(Utl_Raw.Bit_And(R1, R2)), '0') when Vlenr1 > Vlenr2 then Ltrim(Rawtohex(Utl_Raw.Bit_And(Hextoraw(Substr(Rawtohex(R1),
                                                                                                                                                                           -Vlenr2)),
                                                                                                                                                           R2)),
                                                                                                                                  '0') else Ltrim(Rawtohex(Utl_Raw.Bit_And(R1,
                                                                                                                                                                           Hextoraw(Substr(Rawtohex(R2),
                                                                                                                                                                                           -Vlenr1)))),
                                                                                                                                                  '0') end is null then 0 else 1 end;
  end Has_Common_Bits;

  -- Проверяет, установлен ли бит с заданным индексом Bit_Index
  -- Возвращает 1, если бит с заданным индексом установлен, иначе возвращает 0
  Function Is_Bit_Set
  (
    r         raw,
    Bit_Index number
  ) return number is
  begin
    return Dbms_Utility.Is_Bit_Set(r, Bit_Index);
  end Is_Bit_Set;

  ----------------------------------------------------------------------------
  Function Empty_Raw return raw is
  begin
    return c_Empty_Raw;
  end Empty_Raw;

  ----------------------------------------------------------------------------
  --             Служебные (специальные) функции и процедуры                --
  ----------------------------------------------------------------------------

  -- Получить версию заголовка (спецификации) пакета
  Function Getversion return varchar2 is
  begin
    return Version;
  end Getversion;

  -- Получить версию тела пакета
  Function Getversionofbody return varchar2 is
  begin
    return Versionofbody;
  end Getversionofbody;

end Util_Raw;
/
