create or replace package User_Session is

  -- Author  :
  -- Created : 23-Jul-26 11:39:26 AM
  -- Purpose : 

  Params Hash_t := Hash_t();

  ------------------------------------------------------------------------------------------------------
  Procedure Set_All(Request Hash_t);
  ------------------------------------------------------------------------------------------------------
  Procedure Put_Varchar2(i_Key varchar2, i_Value varchar2);
  ------------------------------------------------------------------------------------------------------
  Procedure Put_Number(i_Key varchar2, i_Value number);
  ------------------------------------------------------------------------------------------------------
  Procedure Put_Date(i_Key varchar2, i_Value date);
  ------------------------------------------------------------------------------------------------------
  Procedure Put_Array_Varchar2(i_Key varchar2, i_Value Array_Varchar2);
  ------------------------------------------------------------------------------------------------------
  Procedure Put_Array_Number(i_Key varchar2, i_Value Array_Number);
  ------------------------------------------------------------------------------------------------------
  Procedure Put_Array_Date(i_Key varchar2, i_Value Array_Date);
  ------------------------------------------------------------------------------------------------------
  Procedure Put_Json(Io_Hash   in out nocopy Core.Hash_t,
                     o_Code    out number,
                     o_Msg     out varchar2,
                     o_Ora_Msg out varchar2);
  ------------------------------------------------------------------------------------------------------
  Function Get_Varchar2(i_Key varchar2) return varchar2;
  ------------------------------------------------------------------------------------------------------
  Function Get_Number(i_Key varchar2, i_Format varchar2 := null)
    return number;
  ------------------------------------------------------------------------------------------------------
  Function Get_Date(i_Key varchar2, i_Format varchar2 := null) return date;
  ------------------------------------------------------------------------------------------------------
  Function Get_Array_Varchar2(i_Key varchar2) return Array_Varchar2;
  ------------------------------------------------------------------------------------------------------
  Function Get_Array_Number(i_Key varchar2, i_Format varchar2 := null)
    return Array_Number;
  ------------------------------------------------------------------------------------------------------
  Function Get_Array_Date(i_Key varchar2, i_Format varchar2 := null)
    return Array_Date;
  ------------------------------------------------------------------------------------------------------
  Procedure Remove(i_Key varchar2);
  ------------------------------------------------------------------------------------------------------
  Procedure Clear;

end User_Session;
/
create or replace package body User_Session is

  c_Max_Count         constant pls_integer := 100;
  c_Reached_Max_Limit constant varchar2(100) := 'User session: Reached max limit';

  ------------------------------------------------------------------------------------------------------
  Procedure Set_All(Request Hash_t) is
  begin
    Params := Request;
  end Set_All;

  ------------------------------------------------------------------------------------------------------
  Procedure Put_Varchar2(i_Key varchar2, i_Value varchar2) is
  begin
    Params.Put(i_Key, i_Value);
  end Put_Varchar2;

  ------------------------------------------------------------------------------------------------------
  Procedure Put_Number(i_Key varchar2, i_Value number) is
  begin
    Params.Put(i_Key, i_Value);
  end Put_Number;

  ------------------------------------------------------------------------------------------------------
  Procedure Put_Date(i_Key varchar2, i_Value date) is
  begin
    Params.Put(i_Key, i_Value);
  end Put_Date;

  ------------------------------------------------------------------------------------------------------
  Procedure Put_Array_Varchar2(i_Key varchar2, i_Value Array_Varchar2) is
  begin
    if i_Value.Count > c_Max_Count then
      Raise_Application_Error(-20000, c_Reached_Max_Limit);
    end if;
    Params.Put(i_Key, i_Value);
  end Put_Array_Varchar2;

  ------------------------------------------------------------------------------------------------------
  Procedure Put_Array_Number(i_Key varchar2, i_Value Array_Number) is
  begin
    if i_Value.Count > c_Max_Count then
      Raise_Application_Error(-20000, c_Reached_Max_Limit);
    end if;
    Params.Put(i_Key, i_Value);
  end Put_Array_Number;

  ------------------------------------------------------------------------------------------------------
  Procedure Put_Array_Date(i_Key varchar2, i_Value Array_Date) is
  begin
    if i_Value.Count > c_Max_Count then
      Raise_Application_Error(-20000, c_Reached_Max_Limit);
    end if;
    Params.Put(i_Key, i_Value);
  end Put_Array_Date;

  ------------------------------------------------------------------------------------------------------
  /*
  {
    "method": "core.session.api",
    "params":[
      {
        "key": "MON_BEGIN_DATE",
        "value": "01.03.2025"
      },
      {
        "key": "MON_END_DATE",
        "value": "01.03.2025"
      }
    ]
  }
  */
  Procedure Put_Json(Io_Hash   in out nocopy Core.Hash_t,
                     o_Code    out number,
                     o_Msg     out varchar2,
                     o_Ora_Msg out varchar2) is
    v_Params     Core.Arraylist := Core.Arraylist();
    v_Param_Hash Core.Hash_t := Core.Hash_t();
  begin
    -- paramsni ajratib olish
    v_Params := Io_Hash.Get_Arraylist('params');
    if v_Params.Count = 0 then
      o_Code    := -1;
      o_Msg     := 'params is not found';
      o_Ora_Msg := 'params is not found ' ||
                   Dbms_Utility.Format_Error_Backtrace;
      return;
    end if;
    --
    for i in 1 .. v_Params.Count loop
      v_Param_Hash := Treat(v_Params.Get_r_Hash_t(i) as Core.Hash_t);
      Put_Varchar2(v_Param_Hash.Get_Varchar2('key'),
                   v_Param_Hash.Get_Varchar2('value'));
    end loop;
    o_Code := 0;
  end;

  ------------------------------------------------------------------------------------------------------
  Function Get_Varchar2(i_Key varchar2) return varchar2 is
  begin
    return Params.Get_Varchar2(i_Key);
  exception
    when No_Data_Found then
      return '';
  end Get_Varchar2;

  ------------------------------------------------------------------------------------------------------
  Function Get_Number(i_Key varchar2, i_Format varchar2 := null)
    return number is
  begin
    return Params.Get_Number(i_Key, i_Format);
  exception
    when No_Data_Found then
      return null;
  end Get_Number;

  ------------------------------------------------------------------------------------------------------
  Function Get_Date(i_Key varchar2, i_Format varchar2 := null) return date is
  begin
    return Params.Get_Date(i_Key, i_Format);
  exception
    when No_Data_Found then
      return null;
  end Get_Date;

  ------------------------------------------------------------------------------------------------------
  Function Get_Array_Varchar2(i_Key varchar2) return Array_Varchar2 is
  begin
    return Params.Get_Array_Varchar2(i_Key);
  exception
    when No_Data_Found then
      return Array_Varchar2();
  end Get_Array_Varchar2;

  ------------------------------------------------------------------------------------------------------
  Function Get_Array_Number(i_Key varchar2, i_Format varchar2 := null)
    return Array_Number is
  begin
    return Params.Get_Array_Number(i_Key, i_Format);
  exception
    when No_Data_Found then
      return Array_Number();
  end Get_Array_Number;

  ------------------------------------------------------------------------------------------------------
  Function Get_Array_Date(i_Key varchar2, i_Format varchar2 := null)
    return Array_Date is
  begin
    return Params.Get_Array_Date(i_Key, i_Format);
  exception
    when No_Data_Found then
      return Array_Date();
  end Get_Array_Date;

  ------------------------------------------------------------------------------------------------------
  Procedure Remove(i_Key varchar2) is
  begin
    Params.Remove(i_Key);
  end Remove;

  ------------------------------------------------------------------------------------------------------
  Procedure Clear is
  begin
    Params := Hash_t();
  end Clear;

end User_Session;
/
