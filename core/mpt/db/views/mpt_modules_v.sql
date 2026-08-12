
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_MODULES_V" ("MODULE_CODE", "MODULE_NAME", "IS_ACTIVE", "STATE_NAME", "ORDER_BY") AS
  select m.Module_Code,
         Mpt_Module_Name(m.Name_Mll_Code) as Module_Name,
         decode(m.State, 'A', 'Y', 'N') as Is_Active,
         Mpt_State_Name(decode(m.State, 'A', 'Y', 'N')) as State_Name,
         m.Order_By
    from Core.Core_R_Modules m
;

