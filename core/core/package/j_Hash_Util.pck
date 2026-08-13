create or replace package j_Hash_Util is

  Procedure Set_Values
  (
    i_Param_Names        in Array_Varchar2,
    i_Param_Entity_Names in Array_Varchar2
  );

  Procedure Set_Value
  (
    i_Param_Names        in varchar2,
    i_Param_Entity_Names in varchar2
  );

  Function Can_Encrypt(i_Key in varchar2) return boolean;

  Function Encrypt
  (
    i_Key   in varchar2,
    i_Value in varchar2
  ) return varchar2;

  Function Encrypt
  (
    i_Key   in varchar2,
    i_Value in number
  ) return varchar2;

  Function Encrypt
  (
    i_Key    in varchar2,
    i_Value  in date,
    i_Format varchar2 := null
  ) return varchar2;

  Function Encrypt_Array_Elements
  (
    i_Key   in varchar2,
    i_Array in j_Array
  ) return j_Array;
end j_Hash_Util;
/
create or replace package body j_Hash_Util is

  Param_Names        Array_Varchar2;
  Param_Entity_Names Array_Varchar2;

  Procedure Initilize is
  begin
    Param_Names        := Array_Varchar2();
    Param_Entity_Names := Array_Varchar2();
  end;

  Procedure Set_Values
  (
    i_Param_Names        in Array_Varchar2,
    i_Param_Entity_Names in Array_Varchar2
  ) is
  begin

    Initilize;

    Param_Names        := i_Param_Names;
    Param_Entity_Names := i_Param_Entity_Names;
  exception
    when others then
      Raise_Application_Error(-20000,
                              'Error while setting values (parameter names and parameter entity names): ' ||
                              sqlerrm);
  end Set_Values;

  Procedure Set_Value
  (
    i_Param_Names        in varchar2,
    i_Param_Entity_Names in varchar2
  ) is
  begin

    Initilize;

    Param_Names.Extend;
    Param_Names(Param_Names.Last) := i_Param_Names;

    Param_Entity_Names.Extend;
    Param_Entity_Names(Param_Entity_Names.Last) := i_Param_Entity_Names;
  exception
    when others then
       Raise_Application_Error(-20000,
                      'Error while setting value (parameter names and parameter entity names): ' ||
                      sqlerrm);
  end Set_Value;

  Function Can_Encrypt(i_Key in varchar2) return boolean is
  begin
    if Param_Names is null then
      return false;
    end if;

    if i_Key member of Param_Names then
      return true;
    end if;

    return false;

  end Can_Encrypt;

  Function Get_Index
  (
    q in Array_Varchar2,
    c in varchar2
  ) return number is
    Ind number;
  begin
    select min(Rn)
      into Ind
      from (select Column_Value Cv, Rownum Rn
              from table(q))
     where Cv = c;

    return Ind;
  end Get_Index;

  Function Get_Entity_Name(i_Key in varchar2) return varchar2 is
    Ind         number;
    Entity_Name varchar2(32767);
  begin
    if Param_Names is null or Param_Entity_Names is null then
      Raise_Application_Error(-20000,
                      'Error while getting entity name(Param_Names or Param_Entity_Names is null )');
    end if;
    Ind := Get_Index(Param_Names, i_Key);

    Param_Entity_Names.Extend;
    Entity_Name := Param_Entity_Names(Ind);
    return Entity_Name;
  end Get_Entity_Name;

  Function Encrypt
  (
    i_Key   in varchar2,
    i_Value in varchar2
  ) return varchar2 is
    Entity_Name varchar2(32767);
  begin
    Entity_Name := Get_Entity_Name(i_Key);
    return Core_Secure_Util.Encrypt(i_Text => i_Value, i_Entity => Entity_Name);

  end Encrypt;

  Function Encrypt
  (
    i_Key   in varchar2,
    i_Value in number
  ) return varchar2 is
    Entity_Name varchar2(32767);
  begin
    Entity_Name := Get_Entity_Name(i_Key);
    return Core_Secure_Util.Encrypt(i_Text => i_Value, i_Entity => Entity_Name);

  end Encrypt;

  Function Encrypt
  (
    i_Key    in varchar2,
    i_Value  in date,
    i_Format varchar2 := null
  ) return varchar2 is
    Entity_Name varchar2(32767);
  begin
    Entity_Name := Get_Entity_Name(i_Key);
    return Core_Secure_Util.Encrypt(i_Text   => to_char(i_Value, Nvl(i_Format, 'dd.mm.yyyy')),
                                    i_Entity => Entity_Name);

  end Encrypt;

  Function Encrypt_Array_Elements
  (
    i_Key   in varchar2,
    i_Array in j_Array
  ) return j_Array is
    v_Array j_Array := j_Array();
  begin
    for i in 1 .. i_Array.Value.Count
    loop
      v_Array.Push(o => j_String(Encrypt(i_Key => i_Key, i_Value => i_Array.Value(i).To_String())));
    end loop;
    return v_Array;
  end Encrypt_Array_Elements;

end j_Hash_Util;
/
