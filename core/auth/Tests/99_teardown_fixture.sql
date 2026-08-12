----------------------------------------------------------------------------------------------------
--  ”даление тестовой фикстуры и тестовых строк AUTH_*. «апускать под CORE.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  c_User_Id        constant number := 999999901;
  c_Role_Id        constant number := 999901;
  c_Ident_Id       constant number := 999999901;
  c_Ident_Id_Local constant number := 999999904;
begin
  delete from Core.Auth_Sessions
   where User_Id = c_User_Id;
  delete from Core.Auth_Audit_Log
   where User_Id = c_User_Id
      or Username_Tried in ('testuser', 'nosuchuser', 'lock_test_user');
  delete from Core.Auth_Lockouts
   where Username in ('testuser', 'lock_test_user');
  delete from Core.Auth_Login_Nonce
   where User_Agent = 'JUnit'
      or Nonce = 'expired_test_nonce';

  --delete from Core.Core_Rel_User_Roles where User_Id = c_User_Id;
  delete from Core.Core_User_Keys
   where Identity_Id in (c_Ident_Id, c_Ident_Id_Local);
  --delete from Core.Core_Roles where Role_Id = c_Role_Id;
  delete from Core.Core_Users
   where User_Id = c_User_Id;

  commit;
  Dbms_Output.Put_Line('TEARDOWN: тестовые данные удалены');
end;
/
