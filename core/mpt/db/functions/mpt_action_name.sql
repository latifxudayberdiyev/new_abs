
  CREATE OR REPLACE EDITIONABLE FUNCTION "MPT_ACTION_NAME" (i_Action_Code varchar2) return varchar2 is
  v_Mll_Code Mpt_Actions.Name_Mll_Code%type;
begin
  if i_Action_Code is null then
    return null;
  end if;

  select Name_Mll_Code
    into v_Mll_Code
    from Mpt_Actions
   where Action_Code = i_Action_Code;

  return Core.Mlt_Util.Get_Message(v_Mll_Code);
exception
  when others then
    return i_Action_Code;
end Mpt_Action_Name;
/

