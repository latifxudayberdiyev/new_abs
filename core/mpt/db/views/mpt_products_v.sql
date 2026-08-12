
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_PRODUCTS_V" ("GROUP_CODE", "GROUP_NAME", "PRODUCT_TYPE", "MODULE_CODE", "TEMPLATE_CODE", "TEMPLATE_NAME", "WORKFLOW_STATE", "IS_ACTIVE", "STATE_NAME", "DESCRIPTION", "HISTORY_RETENTION_DAYS", "PARAM_COUNT", "TEMPLATE_COUNT", "USE_COUNT", "CREATED_BY", "CREATED_DATE", "UPDATED_BY", "UPDATED_DATE") AS
  select g.Group_Code,
         g.Group_Name,
         g.Product_Type,
         g.Module_Code,
         g.Template_Code,
         c.Template_Name,
         g.Workflow_State,
         g.Is_Active,
         Mpt_State_Name(g.Is_Active) as State_Name,
         g.Description,
         g.History_Retention_Days,
         (select count(*)
            from Mpt_Template_Var_Mapping_Doc d
           where d.Group_Code = g.Group_Code)
         +
         (select count(*)
            from Mpt_Template_Cell_Mapping m
           where m.Group_Code = g.Group_Code)          as Param_Count,
         (select count(*)
            from Mpt_Print_Templates t
           where t.Group_Code = g.Group_Code)           as Template_Count,
         (select count(*)
            from Mpt_Print_History h
           where h.Group_Code = g.Group_Code)           as Use_Count,
         g.Created_By,
         g.Created_Date,
         g.Updated_By,
         g.Updated_Date
    from Mpt_Template_Groups g
    left join Mpt_Template_Types c
      on c.Template_Code = g.Template_Code
;

