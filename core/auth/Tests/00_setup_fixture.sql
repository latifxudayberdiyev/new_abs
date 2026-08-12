----------------------------------------------------------------------------------------------------
--  “естова€ фикстура дл€ подсистемы AUTH. «апускать под CORE.
--  —оздаЄт тестового пользовател€ 'testuser' (provider AD и LOCAL), роль и св€зь.
--  ID выбраны заведомо высокими, чтобы не пересекатьс€ с боевыми данными.
--  LOCAL-пароль тестового пользовател€: CorrectPass1 (см. 50_test_auth_api_flow.sql,
--  провайдер AD сейчас fail-closed в Auth_Kernel.Complete_Login - см. тот файл).
----------------------------------------------------------------------------------------------------
set define off;
set serveroutput on size unlimited;

declare
  c_User_Id        constant number := 999999901;
  c_Role_Id        constant number := 999901;
  c_Ident_Id       constant number := 999999901;
  c_Ident_Id_Local constant number := 999999904;
begin
  -- чистим возможные остатки
 -- delete from Core.Core_Rel_User_Roles where User_Id = c_User_Id;
  delete from Core.Core_User_Keys      where Identity_Id in (c_Ident_Id, c_Ident_Id_Local);
 -- delete from Core.Core_Roles          where Role_Id = c_Role_Id;
  delete from Core.Core_Users          where User_Id = c_User_Id;

  insert into Core.Core_Users
    (User_Id, Cb_Code, Local_Code, User_Type_Id, Name, Language, Theme_Id,
     Is_Access_Denied, Access_Level_Set, Group_Set, Debug, State,
     Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_User_Id, '00440', '01000', 0, 'AUTH TEST USER', 'ru', 0,
     'N', 0, Hextoraw('00'), 'N', 'A',
     Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
     0, sysdate, 0, sysdate);

 /* insert into Core.Core_Roles
    (Role_Id, Name, Access_Level_Set, Is_Private, State,
     Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_Role_Id, 'AUTH TEST ROLE', 0, 'N', 'A',
     Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
     0, sysdate, 0, sysdate);

  insert into Core.Core_Rel_User_Roles
    (User_Id, Role_Id, State, Activate_Date, Deactivate_Date,
     Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_User_Id, c_Role_Id, 'A', Trunc(sysdate) - 1, null,
     0, sysdate, 0, sysdate);*/

  insert into Core.Core_User_Keys
    (Identity_Id, User_Id, Provider_Type, Provider_Key, Is_Required,
     Password, Password_Must_Be_Changed, State, Modified_By, Modified_On, Description)
  values
    (c_Ident_Id, c_User_Id, 'AD', 'testuser', 'N',
     null, 'N', 'A', 0, sysdate, 'AUTH test fixture');

  -- AD provider hozircha Auth_Kernel.Complete_Login'da fail-closed (LDAPS bind
  -- hali ulanmagan) - shu sababli sinov login uchun LOCAL kalit ham beriladi.
  insert into Core.Core_User_Keys
    (Identity_Id, User_Id, Provider_Type, Provider_Key, Is_Required,
     Password, Password_Must_Be_Changed, State, Modified_By, Modified_On, Description)
  values
    (c_Ident_Id_Local, c_User_Id, 'LOCAL', 'testuser', 'N',
     Core.Auth_Util.Make_Local_Hash('CorrectPass1'), 'N', 'A', 0, sysdate, 'AUTH test fixture (LOCAL)');

  commit;
  Dbms_Output.Put_Line('FIXTURE: создан testuser (user_id=' || c_User_Id || ')');
end;
/
