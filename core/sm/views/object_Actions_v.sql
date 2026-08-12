create or replace view object_actions_v as
select t.Label, t.Module_Code, t.Object_Name, t.Code
  from r_References_v t
 where t.State = Core.Core_Const.Get_State_Active
   and t.Object_Name = 'OBJECT_ACTION'
 order by t.Order_Num;
