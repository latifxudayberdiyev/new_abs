
  CREATE OR REPLACE EDITIONABLE FUNCTION "MPT_STATE_NAME" (i_State_Code varchar2) return varchar2 is
  v_Mll_Code Mpt_States.Name_Mll_Code%type;
begin
  if i_State_Code is null then
    return null;
  end if;

  select Name_Mll_Code
    into v_Mll_Code
    from Mpt_States
   where State_Code = i_State_Code;

  return Core.Mlt_Util.Get_Message(v_Mll_Code);
exception
  when others then
    return i_State_Code;
end Mpt_State_Name;

/

