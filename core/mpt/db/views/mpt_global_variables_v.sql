
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_GLOBAL_VARIABLES_V" ("VARIABLE_CODE", "VAR_NAME", "MODULE_CODE", "MODULE_NAME", "VAR_TYPE", "TYPE_NAME", "VAR_SOURCE", "VAR_VALUE", "VAR_QUERY", "DESCRIPTION", "EXAMPLE_VALUE", "USAGE_NOTE", "NEEDS_TRANSLIT", "IS_REQUIRED", "IS_ACTIVE", "STATE_NAME", "SM_RELATION_ID", "CREATED_BY", "CREATED_DATE", "MODIFIED_BY", "MODIFIED_BY_NAME", "MODIFIED_ON") AS
  select v.Variable_Code,
       v.Var_Name,
       v.Module_Code,
       -- Module_Code null = o'zgaruvchi barcha modullar uchun amal qiladi
       Nvl(m.Module_Name, Mpt_Module_Name('MPT_VAR_MODULE_ALL')) as Module_Name,
       v.Var_Type,
       t.Type_Name,
       v.Var_Source,
       v.Var_Value,
       v.Var_Query,
       v.Description,
       v.Example_Value,
       v.Usage_Note,
       v.Needs_Translit,
       v.Is_Required,
       v.Is_Active,
       Mpt_State_Name(v.Is_Active) as State_Name,
       v.Sm_Relation_Id,
       v.Created_By,
       v.Created_Date,
       v.Modified_By,
       u.Name as Modified_By_Name,
       v.Modified_On
  from Mpt_Print_Variables v
  left join Mpt_Variable_Types t
    on t.Type_Code = v.Var_Type
  left join Mpt_Modules_V m
    on m.Module_Code = v.Module_Code
  left join Core.Core_Users u
    on u.User_Id = v.Modified_By
 where v.Scope = 'GLOBAL'
;

