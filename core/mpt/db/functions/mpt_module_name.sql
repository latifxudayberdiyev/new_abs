
  CREATE OR REPLACE EDITIONABLE FUNCTION "MPT_MODULE_NAME" (i_Mll_Code varchar2) return varchar2 is
begin
  if i_Mll_Code is null then
    return null;
  end if;

  return Core.Mlt_Util.Get_Message(i_Mll_Code);
exception
  when others then
    return i_Mll_Code;
end Mpt_Module_Name;
/

