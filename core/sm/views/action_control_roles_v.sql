create or replace view action_control_roles_v as
select Rr.Object_Code,
       Sm_Util.Get_Object_Name(i_Object_Code => Rr.Object_Code) as Object_Name,
       (select v.Label
          from r_References_v v
         where v.Module_Code = Sm_Const.Get_Crobs_Module_Code
           and v.Object_Name = 'OBJECT_ACTION'
           and v.Code = Rr.Action_Id) as Action_Name,
       Rr.Action_Id,
       Rr.Role_Id,
       Crobs_V3.Core_User.Get_Role_Name(Rr.Role_Id) as Role_Name
  from Sm_Action_Role_Rel Rr, Crobs_V3.Core_Roles r
 where r.Id = Rr.Role_Id;
