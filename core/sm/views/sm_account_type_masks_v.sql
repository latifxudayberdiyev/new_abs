create or replace force view sm_account_type_masks_v as
select t.Account_Type_Id, Substr(m.Mask, 1, 5) Mask, Core.Ml_Label(t.Name) as name
  from Account_Types t, Account_Type_Masks m
 where m.Account_Type_Id = t.Account_Type_Id
   and t.Account_Type_Id > 0
   and t.State = Core.Core_Const.Get_State_Active
   and t.Object_Code = Sm_Const.Get_Object_Code_Tranche;
