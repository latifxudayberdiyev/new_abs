create or replace package Sm_Init is

  -- Author  : B.URALOV
  -- Created : 05.09.2025 08:57:31
  -- Purpose : 
  ----
  --
  ----\
  Procedure Clear_Cache;
  ----
  --
  ----\
  Procedure Reinit_Process_Data
  (
    i_Process_Id in number,
    o_Object_t   out Sm_Object_t,
    o_Last_Hash  out Hash_t,
    o_Code       out number,
    o_Msg        out varchar2
  );
end Sm_Init;
/
create or replace package body Sm_Init is
  ----
  --
  ----\
  Procedure Clear_Cache is
  begin
    null;
  end;
  ----
  --
  ----
  Procedure Reinit_Process_Data
  (
    i_Process_Id in number,
    o_Object_t   out Sm_Object_t,
    o_Last_Hash  out Hash_t,
    o_Code       out number,
    o_Msg        out varchar2
  ) is
    v_Process_Event Sm_Process_Events%rowtype;
  begin
    v_Process_Event := Sm_Util.Get_Process_Event(i_Process_Id => i_Process_Id);
    o_Object_t      := Sm_Util.Sm_Obj_Json_To_Obj(p_Json => v_Process_Event.Object_t_Json);
    Json_Parser.Parse_Json(v_Process_Event.In_Json_Clob, o_Last_Hash);
  exception
    when others then      o_Code := 211;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_PROCESS_NOT_FOUND', i_Params => null, o_Code => v_Ml_Code, o_Msg => o_Msg);
      end;
  end;
end Sm_Init;
/
