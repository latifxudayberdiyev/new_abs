
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_PRINT_VARIABLES_H_V" ("LOG_ID", "VARIABLE_CODE", "VAR_NAME", "MODULE_CODE", "MODULE_NAME", "VAR_TYPE", "TYPE_NAME", "VAR_SOURCE", "DESCRIPTION", "EXAMPLE_VALUE", "USAGE_NOTE", "IS_ACTIVE", "STATE_NAME", "ACTION_CODE", "ACTION_NAME", "MODIFIED_BY", "MODIFIED_BY_NAME", "MODIFIED_ON") AS
  SELECT h.Log_Id,
       h.Variable_Code,
       h.Var_Name,
       h.Module_Code,
       -- Module_Code null = o'zgaruvchi barcha modullar uchun amal qilgan
       Nvl(m.Module_Name, Mpt_Module_Name('MPT_VAR_MODULE_ALL')) as Module_Name,
       h.Var_Type,
       t.Type_Name,
       h.Var_Source,
       h.Description,
       h.Example_Value,
       h.Usage_Note,
       h.Is_Active,
       Mpt_State_Name(h.Is_Active) as State_Name,
       h.Action as Action_Code,
       Mpt_Action_Name(h.Action) as Action_Name,
       NVL(h.Modified_By, h.Created_By) as Modified_By,
       u.Name as Modified_By_Name,
       h.Action_Date as Modified_On
  FROM Mpt_Print_Variables_H h
  left join Mpt_Variable_Types t
    on t.Type_Code = h.Var_Type
  left join Mpt_Modules_V m
    on m.Module_Code = h.Module_Code
  left join Core.Core_Users u
    on u.User_Id = NVL(h.Modified_By, h.Created_By)
 WHERE h.Variable_Code = Core.User_Session.Get_Varchar2('mpt_variable_code')
 ORDER BY h.Log_Id DESC
;
