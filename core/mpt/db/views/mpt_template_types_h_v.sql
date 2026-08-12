
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_TEMPLATE_TYPES_H_V" ("LOG_ID", "TEMPLATE_CODE", "TEMPLATE_NAME", "MODULE_CODE", "MODULE_NAME", "DESCRIPTION", "IS_ACTIVE", "STATE_NAME", "ACTION_CODE", "ACTION_NAME", "MODIFIED_BY", "MODIFIED_BY_NAME", "MODIFIED_ON") AS
  SELECT h.Log_Id,
       h.Template_Code,
       h.Template_Name,
       h.Module_Code,
       Mpt_Module_Name(m.Name_Mll_Code) as Module_Name,
       h.Description,
       h.Is_Active,
       Mpt_State_Name(h.Is_Active) as State_Name,
       h.Action,
       Mpt_Action_Name(h.Action) as Action_Name,
       NVL(h.Modified_By, h.Created_By) as Modified_By,
       u.Name as Modified_By_Name,
       h.Action_Date as Modified_On
  FROM Mpt_Template_Types_H h
  left join Core.Core_R_Modules m
    on m.Module_Code = h.Module_Code
  left join Core.Core_Users u
    on u.User_Id = NVL(h.Modified_By, h.Created_By)
 WHERE h.Template_Code = Core.User_Session.Get_Varchar2('mpt_template_type_code')
 ORDER BY h.Log_Id DESC
;

