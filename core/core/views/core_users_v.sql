create or replace force view core_users_v as
select u.User_Id,
       u.Cb_Code,
       u.Local_Code,
       u.User_Type_Id,
       (select t.Name
          from Core_R_User_Types t
         where t.Code = u.User_Type_Id) User_Type_Name,
       u.Name,
       u.Pinfl,
       u.Date_Birth,
       u.Hr_User_Id,
       (select k.Provider_Key
          from Core_User_Keys k
         where k.User_Id = u.User_Id
           and k.Provider_Type = 'LOCAL') Login,
       u.Phone_Number,
       u.Email,
       u.Language,
       u.Is_Access_Denied,
       (select Decode(u.Is_Access_Denied, 'Y', 'Да', 'N', 'Нет', u.Is_Access_Denied)
          from Dual) Is_Access_Denied_Name,
       u.State,
       (select Decode(u.State, 'A', 'Активен', 'P', 'Пассивен', u.State)
          from Dual) State_Name,
       u.Activate_Date,
       u.Deactivate_Date,
       u.Created_By,
       (select t.Name
          from Core_Users t
         where t.User_Id = u.Created_By) Created_By_Name,
       u.Created_On,
       u.Modified_By,
       (select t.Name
          from Core_Users t
         where t.User_Id = u.Modified_By) Modified_By_Name,
       u.Modified_On
  from Core_Users u;
