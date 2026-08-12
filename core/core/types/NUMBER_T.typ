CREATE OR REPLACE TYPE "NUMBER_T"                                          Force under Object_t
(

  v number,
------------------------------------------------------------------------------------------------------
  constructor Function Number_t
  (
    self in out nocopy Number_t,
    v    number
  ) return self as result,
------------------------------------------------------------------------------------------------------
  overriding member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2,
------------------------------------------------------------------------------------------------------
  overriding member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number,
------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Varchar2,
------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Number,
------------------------------------------------------------------------------------------------------
  overriding member Function Is_Number return boolean,
------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2,
  overriding member Function Json_Clob return clob,
------------------------------------------------------------------------------------------------------
  overriding member Function json_Long_String return Long_String
)
/
CREATE OR REPLACE TYPE BODY "NUMBER_T" is

  ------------------------------------------------------------------------------------------------------
  constructor Function Number_t
  (
    self in out nocopy Number_t,
    v    number
  ) return self as result is
  begin
    Self.Type := 'NUMBER';
    Self.v    := v;
    return;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return varchar2 is
  begin
    return Object_t.Format_Number(v, i_Format, i_Nlsparam);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return number is
  begin
    return v;
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Varchar2
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Varchar2 is
  begin
    return Array_Varchar2(Object_t.Format_Number(v, i_Format, i_Nlsparam));
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function As_Array_Number
  (
    i_Format   varchar2 := null,
    i_Nlsparam varchar2 := null
  ) return Array_Number is
  begin
    return Array_Number(v);
  end;

  ------------------------------------------------------------------------------------------------------
  overriding member Function Is_Number return boolean is
  begin
    return true;
  end;
  ------------------------------------------------------------------------------------------------------
  overriding member Function Json return varchar2 is
  begin
    return Object_t.Format_Number(v);
  end;
  ------------------------------------------------------------------------------------------------------
  overriding member Function Json_Clob return clob is
  begin
    return Object_t.Format_Number(v);
  end;
  ------------------------------------------------------------------------------------------------------
  overriding member Function json_Long_String return Long_String is
  begin
    return Long_String(Object_t.Format_Number(v));
  end;
end;
/
