create or replace type j_Hash under j_Object
(
  Key   j_Tkey,
  value j_Tarray,
  constructor Function j_Hash(self in out nocopy j_Hash) return self as result,
  member Procedure Put
  (
    Key   varchar2,
    value j_Object
  ),
  member Procedure Put

  (
    Key   varchar2,
    value varchar2
  ),
  member Procedure Put
  (
    Key   varchar2,
    value number
  ),
  member Procedure Put
  (
    Key    varchar2,
    value  date,
    Format varchar2 := null
  ),
  overriding member Function To_String return varchar2,
  member Function Json_Long_String return Long_String,
-- member Function Json_Clob return clob,
  member Function To_Array_Varchar2 return Array_Varchar2,
  member Function To_Clob return clob,
  member Function count return pls_integer
)
;
/
create or replace type body j_Hash as
  constructor Function j_Hash(self in out nocopy j_Hash) return self as result is
  begin
    Self.State := null;
    Key        := j_Tkey();
    value      := j_Tarray();
    return;
  end;
  -------------------------------------------
  member Procedure Put
  (
    self  in out nocopy j_Hash,
    Key   varchar2,
    value j_Object
  ) is
  begin
    Self.Key.Extend;
    Self.Key(Self.Key.Count) := Key;
    Self.Value.Extend;
    if (value is of(j_Array) and j_Hash_Util.Can_Encrypt(i_Key => Key)) then
      --Self.Value(Self.Value.Count) := j_String(J_Hash_Util.Encrypt(i_key => Key, i_value => value.to_string()));

      Self.Value(Self.Value.Count) := j_Hash_Util.Encrypt_Array_Elements(i_Key   => Key,
                                                                         i_Array => Treat(value as
                                                                                          j_Array));
    else
      Self.Value(Self.Value.Count) := value;
    end if;
  end;
  member Procedure Put
  (
    self  in out nocopy j_Hash,
    Key   varchar2,
    value varchar2
  ) is
    --sanitized_value varchar2(32767);
  begin
    --sanitized_value:= j_Hash_Util.Sanitize(i_value => value);
    if j_Hash_Util.Can_Encrypt(i_Key => Key) then
      Self.Put(Key, j_String(j_Hash_Util.Encrypt(i_Key => Key, i_Value => value)));
    else
      Self.Put(Key, j_String(value));
    end if;
  end;

  member Procedure Put
  (
    self  in out nocopy j_Hash,
    Key   varchar2,
    value number
  ) is
  begin
    if j_Hash_Util.Can_Encrypt(i_Key => Key) then
      Self.Put(Key, j_String(j_Hash_Util.Encrypt(i_Key => Key, i_Value => value)));
    else
      Self.Put(Key, j_Number(value));
    end if;
  end;

  member Procedure Put
  (
    Key    varchar2,
    value  date,
    Format varchar2 := null
  ) is
  begin
    Self.Put(Key, to_char(value, Nvl(Format, 'dd.mm.yyyy')));
  end;

  overriding member Function To_String return varchar2 is
    Tmp varchar2(32767);
  begin
    Tmp := '{';
    for i in 1 .. Key.Count
    loop
      Tmp := Tmp || Key(i) || ':' || value(i).To_String();
      if i <> Key.Last then
        Tmp := Tmp || ',';
      end if;
    end loop;
    return Tmp || '}';
  end;
  member Function Json_Long_String return Long_String is
    result Long_String := Long_String('{');
  begin
    for i in 1 .. Key.Count
    loop
      Result.Append(Key(i) || ':' || value(i).To_String());
      if i <> Key.Last then
        Result.Append(',');
      end if;
    end loop;
    Result.Append('}');
    return result;
  end;
  member Function To_Clob return clob is
  begin
    return Self.Json_Long_String().To_Clob();
  end;
  member Function To_Array_Varchar2 return Array_Varchar2 is
  begin
    return Self.Json_Long_String().To_String_Array();
  end; /*
  member Function To_Clob return clob is
    Tmp clob;
  begin
    Tmp := '{';
    for i in 1 .. Key.Count
    loop
      Tmp := Tmp || Key(i) || ':' || value(i).To_String();
      if i <> Key.Last then
        Tmp := Tmp || ',';
      end if;
    end loop;
    return Tmp || '}';
  end;*/
  member Function count return pls_integer is
  begin
    return Value.Count;
  end count;
  -------------------------------------------

end;
/
