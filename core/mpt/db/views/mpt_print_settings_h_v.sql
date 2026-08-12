
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_PRINT_SETTINGS_H_V" ("LOG_ID", "SETTING_ID", "SETTING_NAME", "MODULE_CODE", "MODULE_NAME", "TEMPLATE_CODE", "TEMPLATE_NAME", "FILE_TYPE", "FILE_FORMAT", "ACTIVATION_DATE", "DEACTIVATION_DATE", "DESCRIPTION", "IS_ACTIVE", "STATE_NAME", "OPEN_AS_PDF", "ACTION_CODE", "ACTION_NAME", "MODIFIED_BY", "MODIFIED_BY_NAME", "ACTION_DATE") AS
  select h.Log_Id,
         h.Setting_Id,
         h.Setting_Name,
         h.Module_Code,
         Mpt_Module_Name(m.Name_Mll_Code) as Module_Name,
         h.Template_Code,
         t.Template_Name,
         h.File_Type,
         h.File_Format,
         h.Activation_Date,
         h.Deactivation_Date,
         h.Description,
         h.Is_Active,
         Mpt_State_Name(h.Is_Active) as State_Name,
         h.Open_As_Pdf,
         h.Action as Action_Code,
         Mpt_Action_Name(h.Action) as Action_Name,
         h.Modified_By,
         u.Name as Modified_By_Name,
         h.Action_Date
    from Mpt_Print_Settings_H h
    left join Core.Core_R_Modules m
      on m.Module_Code = h.Module_Code
    left join Mpt_Template_Types t
      on t.Template_Code = h.Template_Code
    left join Core.Core_Users u
      on u.User_Id = h.Modified_By
   where h.Setting_Id = Core.User_Session.Get_Varchar2('mpt_print_setting_id')
   order by h.Log_Id desc
;

