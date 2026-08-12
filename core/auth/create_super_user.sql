----------------------------------------------------------------------------------------------------
--  LOCAL provider super_user yaratish/qayta o'rnatish.
--  Login: super_user   Parol: SuperPass123   (User_Id/parolni pastda o'zgartirishingiz mumkin)
--  Ishga tushirish: sqlplus core/*** @core/auth/create_super_user.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  c_User_Id  constant number        := 900001;
  c_Ident_Id constant number        := 900001;
  c_Username constant varchar2(32)  := 'super_user';
  c_Password constant varchar2(32)  := 'SuperPass123';
begin
  delete from Core.Core_User_Keys where Identity_Id = c_Ident_Id;
  delete from Core.Core_Users     where User_Id = c_User_Id;

  insert into Core.Core_Users
    (User_Id, Cb_Code, Local_Code, User_Type_Id, Name, Language, Theme_Id,
     Is_Access_Denied, Access_Level_Set, Group_Set, Debug, State,
     Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_User_Id, '00440', '01000', 0, 'SUPER USER', 'ru', 0,
     'N', 0, Hextoraw('00'), 'N', 'A',
     Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
     0, sysdate, 0, sysdate);

  insert into Core.Core_User_Keys
    (Identity_Id, User_Id, Provider_Type, Provider_Key, Is_Required,
     Password, Password_Must_Be_Changed, State, Modified_By, Modified_On, Description)
  values
    (c_Ident_Id, c_User_Id, 'LOCAL', Lower(c_Username), 'Y',
     Core.Auth_Util.Make_Local_Hash(c_Password), 'N', 'A', 0, sysdate, 'Super user (LOCAL)');

  commit;
  Dbms_Output.Put_Line('OK: super_user tayyor. Login=' || c_Username || '  Parol=' || c_Password);
exception
  when others then
    rollback;
    Dbms_Output.Put_Line('XATO: ' || sqlerrm);
    raise;
end;
/
