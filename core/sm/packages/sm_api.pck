create or replace package Sm_Api is

  -- Author  : B.URALOV
  -- Created : 05.09.2025 10:36:30
  -- Purpose : 
  Procedure Set_Lead_Object_Child
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Sm_Api;
/
create or replace package body Sm_Api is
  Procedure Set_Lead_Object_Child
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Object_Id number := Io_Hash.Get_Optional_Number('object_id');
  begin
    o_Code := Sm_Const.c_Success_Code;
  --  Sm_Init.Set_Lead_Object_Child(i_Object_Id => v_Object_Id);
  exception
    when others then
      o_Code    := -999;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_SYSTEM_ERROR', i_Params => null, o_Code => v_Ml_Code, o_Msg => o_Msg);
      end;
      o_Ora_Msg := o_Msg || ' ' || sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
end Sm_Api;

/
