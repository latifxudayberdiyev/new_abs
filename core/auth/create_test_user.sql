----------------------------------------------------------------------------------------------------
--  Oddiy (admin bo'lmagan) test foydalanuvchi. Faqat Dashboard menyusiga
--  ruxsat berilgan - super_user'dan farqli, cheklangan huquqli sinov uchun.
--  Login: test_user   Parol: TestPass123
--  Ishga tushirish: sqlplus core/*** @auth/create_test_user.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  c_User_Id  constant number        := 0;
  c_Ident_Id constant number        := 0;
  c_Username constant varchar2(32)  := 'test_user';
  c_Password constant varchar2(32)  := 'TestPass123';
begin
  delete from Core.Core_User_Keys where Identity_Id = c_Ident_Id;
  delete from Core.Core_Users     where User_Id = c_User_Id;
  delete from Core.Adm_Rel_User_Menus where User_Id = c_User_Id;

  insert into Core.Core_Users
    (User_Id, Cb_Code, Local_Code, User_Type_Id, Name, Language, Theme_Id,
     Is_Access_Denied, Access_Level_Set, Group_Set, Debug, State,
     Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_User_Id, '00440', '01000', 0, 'TEST USER', 'ru', 0,
     'N', 0, Hextoraw('00'), 'N', 'A',
     Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
     0, sysdate, 0, sysdate);

  insert into Core.Core_User_Keys
    (Identity_Id, User_Id, Provider_Type, Provider_Key, Is_Required,
     Password, Password_Must_Be_Changed, State, Modified_By, Modified_On, Description)
  values
    (c_Ident_Id, c_User_Id, 'LOCAL', Lower(c_Username), 'Y',
     Core.Auth_Util.Make_Local_Hash(c_Password), 'N', 'A', 0, sysdate, 'Test user (LOCAL, cheklangan)');

  -- faqat Dashboard menyusiga ruxsat (menu_id=2, "Boshqaruv" guruhi emas)
  insert into Core.Adm_Rel_User_Menus
    (user_id, menu_id, date_activate, date_deactivate, state, created_by, created_on, modify_by, modify_on)
  values
    (c_User_Id, 2, trunc(sysdate) - 1, to_date('31.12.9999','dd.mm.yyyy'), 'A', c_User_Id, sysdate, c_User_Id, sysdate);

  commit;
  Dbms_Output.Put_Line('OK: test_user tayyor. Login=' || c_Username || '  Parol=' || c_Password);
exception
  when others then
    rollback;
    Dbms_Output.Put_Line('XATO: ' || sqlerrm);
    raise;
end;
/
