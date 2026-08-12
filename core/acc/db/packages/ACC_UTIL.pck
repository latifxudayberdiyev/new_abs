--------------------------------------------------------------------------------
-- ACC_UTIL - faqat o'qish (SELECT) uchun: rowtype qaytaruvchi selektorlar va
-- mavjudlikni tekshiruvchi funksiyalar. Yozish (DML) yo'q - u ACC_DML'da.
-- Bu paket faqat ACC_KERNEL tomonidan chaqiriladi.
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ACC_UTIL IS

  FUNCTION Select_Account_Type(i_Id IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type)
    RETURN ACC_ACCOUNT_TYPES%Rowtype;

  FUNCTION Select_Account_Type_Client(i_Id IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type)
    RETURN ACC_ACCOUNT_TYPE_CLIENTS%Rowtype;

  FUNCTION Exists_Module(i_Module_Code IN ACC_R_MODULES.MODULE_CODE%Type) RETURN Boolean;

  FUNCTION Exists_Account_Type(i_Id IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type) RETURN Boolean;

  FUNCTION Select_Account(i_Id IN ACC_ACCOUNTS.ACCOUNT_ID%Type)
    RETURN ACC_ACCOUNTS%Rowtype;

  FUNCTION Select_Account_Module(i_Id IN ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type)
    RETURN ACC_ACCOUNT_MODULES%Rowtype;

  FUNCTION Exists_Account(i_Id IN ACC_ACCOUNTS.ACCOUNT_ID%Type) RETURN Boolean;

  FUNCTION Exists_Client(i_Client_Id IN CL_PHYS_PERSONS.CLIENT_ID%Type) RETURN Boolean;

END ACC_UTIL;
/

CREATE OR REPLACE PACKAGE BODY ACC_UTIL IS

  FUNCTION Select_Account_Type(i_Id IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type)
    RETURN ACC_ACCOUNT_TYPES%Rowtype IS
    v_Row ACC_ACCOUNT_TYPES%Rowtype;
  BEGIN
    SELECT * INTO v_Row FROM ACC_ACCOUNT_TYPES WHERE ACCOUNT_TYPE_ID = i_Id;
    RETURN v_Row;
  END Select_Account_Type;

  FUNCTION Select_Account_Type_Client(i_Id IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type)
    RETURN ACC_ACCOUNT_TYPE_CLIENTS%Rowtype IS
    v_Row ACC_ACCOUNT_TYPE_CLIENTS%Rowtype;
  BEGIN
    SELECT * INTO v_Row FROM ACC_ACCOUNT_TYPE_CLIENTS WHERE ACCOUNT_TYPE_CLIENT_ID = i_Id;
    RETURN v_Row;
  END Select_Account_Type_Client;

  FUNCTION Exists_Module(i_Module_Code IN ACC_R_MODULES.MODULE_CODE%Type) RETURN Boolean IS
    v_Cnt Number;
  BEGIN
    SELECT COUNT(*) INTO v_Cnt FROM ACC_R_MODULES WHERE MODULE_CODE = i_Module_Code;
    RETURN v_Cnt > 0;
  END Exists_Module;

  FUNCTION Exists_Account_Type(i_Id IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type) RETURN Boolean IS
    v_Cnt Number;
  BEGIN
    SELECT COUNT(*) INTO v_Cnt FROM ACC_ACCOUNT_TYPES WHERE ACCOUNT_TYPE_ID = i_Id;
    RETURN v_Cnt > 0;
  END Exists_Account_Type;

  FUNCTION Select_Account(i_Id IN ACC_ACCOUNTS.ACCOUNT_ID%Type)
    RETURN ACC_ACCOUNTS%Rowtype IS
    v_Row ACC_ACCOUNTS%Rowtype;
  BEGIN
    SELECT * INTO v_Row FROM ACC_ACCOUNTS WHERE ACCOUNT_ID = i_Id;
    RETURN v_Row;
  END Select_Account;

  FUNCTION Select_Account_Module(i_Id IN ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type)
    RETURN ACC_ACCOUNT_MODULES%Rowtype IS
    v_Row ACC_ACCOUNT_MODULES%Rowtype;
  BEGIN
    SELECT * INTO v_Row FROM ACC_ACCOUNT_MODULES WHERE ACCOUNT_MODULE_ID = i_Id;
    RETURN v_Row;
  END Select_Account_Module;

  FUNCTION Exists_Account(i_Id IN ACC_ACCOUNTS.ACCOUNT_ID%Type) RETURN Boolean IS
    v_Cnt Number;
  BEGIN
    SELECT COUNT(*) INTO v_Cnt FROM ACC_ACCOUNTS WHERE ACCOUNT_ID = i_Id;
    RETURN v_Cnt > 0;
  END Exists_Account;

  FUNCTION Exists_Client(i_Client_Id IN CL_PHYS_PERSONS.CLIENT_ID%Type) RETURN Boolean IS
    v_Cnt Number;
  BEGIN
    SELECT COUNT(*) INTO v_Cnt FROM CL_PHYS_PERSONS WHERE CLIENT_ID = i_Client_Id;
    RETURN v_Cnt > 0;
  END Exists_Client;

END ACC_UTIL;
/
