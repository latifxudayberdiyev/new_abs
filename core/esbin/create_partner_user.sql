----------------------------------------------------------------------------------------------------
--  ESBIN tashqi tizim uchun texnik (partner) user. Core_Users.User_Type_Id=1 (API USER) - shu turdagi
--  hisob Auth_Kernel.Complete_Login orqali BRAUZER LOGIN'DAN rad etiladi, faqat Esbin_Kernel.Login
--  (POST /api/esbin/v1/login) orqali kiradi.
--  Partner: TEST_PARTNER (ESBIN_R_PARTNERS'da allaqachon mavjud).
--
--  Login: esbin_test_partner   Parol: EsbTest_2026!Qx
--
--  Ishga tushirish: sqlplus core/*** @esbin/create_partner_user.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  c_User_Id      constant number       := 14;
  c_Ident_Id     constant number       := 14;
  c_Username     constant varchar2(32) := 'esbin_test_partner';
  c_Password     constant varchar2(32) := 'EsbTest_2026!Qx';
  c_Partner_Code constant varchar2(50) := 'TEST_PARTNER';
begin
  delete from Core.Esbin_R_Partner_Users where User_Id = c_User_Id;
  delete from Core.Core_User_Keys        where Identity_Id = c_Ident_Id;
  delete from Core.Core_Users            where User_Id = c_User_Id;

  insert into Core.Core_Users
    (User_Id, Cb_Code, Local_Code, User_Type_Id, Name, Language, Theme_Id,
     Is_Access_Denied, Access_Level_Set, Group_Set, Debug, State,
     Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_User_Id, '00440', '01000', Core.Core_Const.c_User_Type_Api, 'ESBIN TEST PARTNER', 'ru', 0,
     'N', 0, Hextoraw('00'), 'N', 'A',
     Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
     0, sysdate, 0, sysdate);

  insert into Core.Core_User_Keys
    (Identity_Id, User_Id, Provider_Type, Provider_Key, Is_Required,
     Password, Password_Must_Be_Changed, State, Modified_By, Modified_On, Description)
  values
    (c_Ident_Id, c_User_Id, 'LOCAL', Lower(c_Username), 'Y',
     Core.Auth_Util.Make_Local_Hash(c_Password), 'N', 'A', 0, sysdate, 'ESBIN partner texnik useri');

  -- DIQQAT: IP_ALLOWLIST '0.0.0.0/0' (cheklovsiz) - tashqi tizimning haqiqiy IP manzili
  -- ma'lum bo'lgach, DARHOL shu qatorni haqiqiy IP/CIDR ro'yxati bilan almashtirish KERAK
  -- (Esbin_Kernel.Login buni parol tekshirishdan OLDIN ishlatadi - xavfsizlik nazorati).
  insert into Core.Esbin_R_Partner_Users (Partner_Code, User_Id, State, Ip_Allowlist)
  values (c_Partner_Code, c_User_Id, 'A', '0.0.0.0/0');

  commit;
  Dbms_Output.Put_Line('OK: esbin_test_partner tayyor. Login=' || c_Username || '  Parol=' || c_Password);
  Dbms_Output.Put_Line('Partner=' || c_Partner_Code || '  User_Id=' || c_User_Id);
exception
  when others then
    rollback;
    Dbms_Output.Put_Line('XATO: ' || sqlerrm);
    raise;
end;
/
