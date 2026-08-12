
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_TEMPLATE_TYPES_V" ("TEMPLATE_CODE", "TEMPLATE_NAME", "LOCAL_CODE", "CBU_CODE", "BXM_NAME", "MODULE_CODE", "MODULE_NAME", "DESCRIPTION", "IS_ACTIVE", "STATE_NAME", "SM_RELATION_ID", "CREATED_BY", "MODIFIED_BY", "MODIFIED_BY_NAME", "MODIFIED_ON") AS
  select t.Template_Code,
       t.Template_Name,
       t.Local_Code,
       t.Cbu_Code,
       t.Bxm_Name,
       t.Module_Code,
       Mpt_Module_Name(m.Name_Mll_Code) as Module_Name,
       t.Description,
       t.Is_Active,
       Mpt_State_Name(t.Is_Active) as State_Name,
       t.Sm_Relation_Id,
       t.Created_By,
       t.Modified_By,
       u.Name as Modified_By_Name,
       t.Modified_On
  from Mpt_Template_Types t
  left join Core.Core_R_Modules m
    on m.Module_Code = t.Module_Code
  left join Core.Core_Users u
    on u.User_Id = t.Modified_By
;

