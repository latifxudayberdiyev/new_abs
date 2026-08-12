create or replace view mfi_ROLES_V as 
select *
  from Crobs_V3.Core_Roles_v t
 where t.Module_Id = Sm_Const.Get_Crobs_Module_Id;
