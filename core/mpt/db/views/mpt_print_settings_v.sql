
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_PRINT_SETTINGS_V" ("SETTING_ID", "SETTING_NAME", "MODULE_CODE", "MODULE_NAME", "TEMPLATE_CODE", "TEMPLATE_NAME", "FILE_TYPE", "FILE_FORMAT", "OPEN_AS_PDF", "ACTIVATION_DATE", "DEACTIVATION_DATE", "DESCRIPTION", "IS_ACTIVE", "STATE_NAME", "OPER_DAY", "MODIFIED_BY", "MODIFIED_ON") AS
  select s.Setting_Id,
         s.Setting_Name,
         s.Module_Code,
         Mpt_Module_Name(m.Name_Mll_Code) as Module_Name,
         s.Template_Code,
         c.Template_Name,
         s.File_Type,
         s.File_Format,
         s.Open_As_Pdf,
         s.Activation_Date,
         s.Deactivation_Date,
         s.Description,
         s.Is_Active,
         Mpt_State_Name(s.Is_Active) as State_Name,
         s.Oper_Day,
         s.Modified_By,
         s.Modified_On
    from Mpt_Print_Settings s
    left join Core.Core_R_Modules m
      on m.Module_Code = s.Module_Code
    left join Mpt_Template_Types c
      on c.Template_Code = s.Template_Code
;

