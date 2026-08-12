--------------------------------------------------------------------------------
-- ACC_DML - faqat "Тип счёта" va дочерняя запись jadvallariga DML (INSERT/
-- UPDATE/DELETE) amallarini bajaradigan qatlam. Hech qanday validatsiya yoki
-- Core.Hash_t bilan ishlash yo'q - bularning barchasi ACC_KERNEL'da.
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ACC_DML IS

  PROCEDURE Insert_Account_Type(i_Id                   IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type,
                                 i_Name                 IN ACC_ACCOUNT_TYPES.NAME%Type,
                                 i_Module_Code          IN ACC_ACCOUNT_TYPES.MODULE_CODE%Type,
                                 i_Balance_Type         IN ACC_ACCOUNT_TYPES.BALANCE_TYPE%Type,
                                 i_State                IN ACC_ACCOUNT_TYPES.STATE%Type,
                                 i_Unique_Contract_Flag IN ACC_ACCOUNT_TYPES.UNIQUE_CONTRACT_FLAG%Type,
                                 i_Is_Open_Flag         IN ACC_ACCOUNT_TYPES.IS_OPEN_FLAG%Type,
                                 i_Incode_Type          IN ACC_ACCOUNT_TYPES.INCODE_TYPE%Type,
                                 i_Is_Virtual           IN ACC_ACCOUNT_TYPES.IS_VIRTUAL%Type,
                                 i_Object_Code          IN ACC_ACCOUNT_TYPES.OBJECT_CODE%Type,
                                 i_User                 IN Varchar2);

  PROCEDURE Update_Account_Type(i_Id                   IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type,
                                 i_Name                 IN ACC_ACCOUNT_TYPES.NAME%Type,
                                 i_Module_Code          IN ACC_ACCOUNT_TYPES.MODULE_CODE%Type,
                                 i_Balance_Type         IN ACC_ACCOUNT_TYPES.BALANCE_TYPE%Type,
                                 i_State                IN ACC_ACCOUNT_TYPES.STATE%Type,
                                 i_Unique_Contract_Flag IN ACC_ACCOUNT_TYPES.UNIQUE_CONTRACT_FLAG%Type,
                                 i_Is_Open_Flag         IN ACC_ACCOUNT_TYPES.IS_OPEN_FLAG%Type,
                                 i_Incode_Type          IN ACC_ACCOUNT_TYPES.INCODE_TYPE%Type,
                                 i_Is_Virtual           IN ACC_ACCOUNT_TYPES.IS_VIRTUAL%Type,
                                 i_Object_Code          IN ACC_ACCOUNT_TYPES.OBJECT_CODE%Type,
                                 i_User                 IN Varchar2,
                                 o_Rows_Updated         OUT Number);

  PROCEDURE Delete_Account_Type(i_Id           IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type,
                                 o_Rows_Deleted OUT Number);

  PROCEDURE Insert_Account_Type_History(i_Account_Type_Id IN ACC_ACCOUNT_TYPE_HISTORY.ACCOUNT_TYPE_ID%Type,
                                         i_Action_Code     IN ACC_ACCOUNT_TYPE_HISTORY.ACTION_CODE%Type,
                                         i_User            IN Varchar2,
                                         i_After_Snapshot  IN Clob);

  PROCEDURE Insert_Account_Type_Client(i_Id              IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type,
                                        i_Account_Type_Id IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_ID%Type,
                                        i_Client_Type     IN ACC_ACCOUNT_TYPE_CLIENTS.CLIENT_TYPE%Type,
                                        i_State           IN ACC_ACCOUNT_TYPE_CLIENTS.STATE%Type,
                                        i_Code_Coa        IN ACC_ACCOUNT_TYPE_CLIENTS.CODE_COA%Type,
                                        i_Currency_Code   IN ACC_ACCOUNT_TYPE_CLIENTS.CURRENCY_CODE%Type,
                                        i_User            IN Varchar2);

  PROCEDURE Update_Account_Type_Client(i_Id            IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type,
                                        i_Client_Type   IN ACC_ACCOUNT_TYPE_CLIENTS.CLIENT_TYPE%Type,
                                        i_State         IN ACC_ACCOUNT_TYPE_CLIENTS.STATE%Type,
                                        i_Code_Coa      IN ACC_ACCOUNT_TYPE_CLIENTS.CODE_COA%Type,
                                        i_Currency_Code IN ACC_ACCOUNT_TYPE_CLIENTS.CURRENCY_CODE%Type,
                                        i_User          IN Varchar2,
                                        o_Rows_Updated  OUT Number);

  PROCEDURE Delete_Account_Type_Client(i_Id           IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type,
                                        o_Rows_Deleted OUT Number);

  PROCEDURE Insert_Account(i_Id              IN ACC_ACCOUNTS.ACCOUNT_ID%Type,
                            i_Account_Code    IN ACC_ACCOUNTS.ACCOUNT_CODE%Type,
                            i_Account_Type_Id IN ACC_ACCOUNTS.ACCOUNT_TYPE_ID%Type,
                            i_Owner_Type      IN ACC_ACCOUNTS.OWNER_TYPE%Type,
                            i_Client_Id       IN ACC_ACCOUNTS.CLIENT_ID%Type,
                            i_Code_Filial     IN ACC_ACCOUNTS.CODE_FILIAL%Type,
                            i_Code_Currency   IN ACC_ACCOUNTS.CODE_CURRENCY%Type,
                            i_Abs_Account_Id  IN ACC_ACCOUNTS.ABS_ACCOUNT_ID%Type,
                            i_Account_Status  IN ACC_ACCOUNTS.ACCOUNT_STATUS%Type,
                            i_Date_Open       IN ACC_ACCOUNTS.DATE_OPEN%Type,
                            i_User            IN Varchar2);

  PROCEDURE Update_Account(i_Id              IN ACC_ACCOUNTS.ACCOUNT_ID%Type,
                            i_Account_Code    IN ACC_ACCOUNTS.ACCOUNT_CODE%Type,
                            i_Account_Type_Id IN ACC_ACCOUNTS.ACCOUNT_TYPE_ID%Type,
                            i_Owner_Type      IN ACC_ACCOUNTS.OWNER_TYPE%Type,
                            i_Client_Id       IN ACC_ACCOUNTS.CLIENT_ID%Type,
                            i_Code_Filial     IN ACC_ACCOUNTS.CODE_FILIAL%Type,
                            i_Code_Currency   IN ACC_ACCOUNTS.CODE_CURRENCY%Type,
                            i_Abs_Account_Id  IN ACC_ACCOUNTS.ABS_ACCOUNT_ID%Type,
                            i_Account_Status  IN ACC_ACCOUNTS.ACCOUNT_STATUS%Type,
                            i_Date_Open       IN ACC_ACCOUNTS.DATE_OPEN%Type,
                            i_Date_Close      IN ACC_ACCOUNTS.DATE_CLOSE%Type,
                            i_User            IN Varchar2,
                            o_Rows_Updated    OUT Number);

  PROCEDURE Delete_Account(i_Id           IN ACC_ACCOUNTS.ACCOUNT_ID%Type,
                            o_Rows_Deleted OUT Number);

  PROCEDURE Insert_Account_Module(i_Id             IN ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type,
                                   i_Account_Id     IN ACC_ACCOUNT_MODULES.ACCOUNT_ID%Type,
                                   i_Module_Code    IN ACC_ACCOUNT_MODULES.MODULE_CODE%Type,
                                   i_Is_Active_Flag IN ACC_ACCOUNT_MODULES.IS_ACTIVE_FLAG%Type,
                                   i_User           IN Varchar2);

  PROCEDURE Update_Account_Module(i_Id              IN ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type,
                                   i_Is_Active_Flag  IN ACC_ACCOUNT_MODULES.IS_ACTIVE_FLAG%Type,
                                   i_Disconnected_On IN ACC_ACCOUNT_MODULES.DISCONNECTED_ON%Type,
                                   o_Rows_Updated    OUT Number);

  PROCEDURE Delete_Account_Module(i_Id           IN ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type,
                                   o_Rows_Deleted OUT Number);

END ACC_DML;
/

CREATE OR REPLACE PACKAGE BODY ACC_DML IS

  PROCEDURE Insert_Account_Type(i_Id                   IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type,
                                 i_Name                 IN ACC_ACCOUNT_TYPES.NAME%Type,
                                 i_Module_Code          IN ACC_ACCOUNT_TYPES.MODULE_CODE%Type,
                                 i_Balance_Type         IN ACC_ACCOUNT_TYPES.BALANCE_TYPE%Type,
                                 i_State                IN ACC_ACCOUNT_TYPES.STATE%Type,
                                 i_Unique_Contract_Flag IN ACC_ACCOUNT_TYPES.UNIQUE_CONTRACT_FLAG%Type,
                                 i_Is_Open_Flag         IN ACC_ACCOUNT_TYPES.IS_OPEN_FLAG%Type,
                                 i_Incode_Type          IN ACC_ACCOUNT_TYPES.INCODE_TYPE%Type,
                                 i_Is_Virtual           IN ACC_ACCOUNT_TYPES.IS_VIRTUAL%Type,
                                 i_Object_Code          IN ACC_ACCOUNT_TYPES.OBJECT_CODE%Type,
                                 i_User                 IN Varchar2) IS
  BEGIN
    INSERT INTO ACC_ACCOUNT_TYPES
      (ACCOUNT_TYPE_ID, NAME, MODULE_CODE, BALANCE_TYPE, STATE, UNIQUE_CONTRACT_FLAG,
       IS_OPEN_FLAG, INCODE_TYPE, IS_VIRTUAL, OBJECT_CODE, CREATED_BY)
    VALUES
      (i_Id, i_Name, i_Module_Code, i_Balance_Type, i_State, i_Unique_Contract_Flag,
       i_Is_Open_Flag, i_Incode_Type, i_Is_Virtual, i_Object_Code, i_User);
  END Insert_Account_Type;

  PROCEDURE Update_Account_Type(i_Id                   IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type,
                                 i_Name                 IN ACC_ACCOUNT_TYPES.NAME%Type,
                                 i_Module_Code          IN ACC_ACCOUNT_TYPES.MODULE_CODE%Type,
                                 i_Balance_Type         IN ACC_ACCOUNT_TYPES.BALANCE_TYPE%Type,
                                 i_State                IN ACC_ACCOUNT_TYPES.STATE%Type,
                                 i_Unique_Contract_Flag IN ACC_ACCOUNT_TYPES.UNIQUE_CONTRACT_FLAG%Type,
                                 i_Is_Open_Flag         IN ACC_ACCOUNT_TYPES.IS_OPEN_FLAG%Type,
                                 i_Incode_Type          IN ACC_ACCOUNT_TYPES.INCODE_TYPE%Type,
                                 i_Is_Virtual           IN ACC_ACCOUNT_TYPES.IS_VIRTUAL%Type,
                                 i_Object_Code          IN ACC_ACCOUNT_TYPES.OBJECT_CODE%Type,
                                 i_User                 IN Varchar2,
                                 o_Rows_Updated         OUT Number) IS
  BEGIN
    UPDATE ACC_ACCOUNT_TYPES
       SET NAME = i_Name, MODULE_CODE = i_Module_Code, BALANCE_TYPE = i_Balance_Type,
           STATE = i_State, UNIQUE_CONTRACT_FLAG = i_Unique_Contract_Flag, IS_OPEN_FLAG = i_Is_Open_Flag,
           INCODE_TYPE = i_Incode_Type, IS_VIRTUAL = i_Is_Virtual, OBJECT_CODE = i_Object_Code,
           MODIFIED_ON = Sysdate, MODIFIED_BY = i_User
     WHERE ACCOUNT_TYPE_ID = i_Id;

    o_Rows_Updated := Sql%Rowcount;
  END Update_Account_Type;

  PROCEDURE Delete_Account_Type(i_Id           IN ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type,
                                 o_Rows_Deleted OUT Number) IS
  BEGIN
    DELETE FROM ACC_ACCOUNT_TYPES WHERE ACCOUNT_TYPE_ID = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  END Delete_Account_Type;

  PROCEDURE Insert_Account_Type_History(i_Account_Type_Id IN ACC_ACCOUNT_TYPE_HISTORY.ACCOUNT_TYPE_ID%Type,
                                         i_Action_Code     IN ACC_ACCOUNT_TYPE_HISTORY.ACTION_CODE%Type,
                                         i_User            IN Varchar2,
                                         i_After_Snapshot  IN Clob) IS
  BEGIN
    INSERT INTO ACC_ACCOUNT_TYPE_HISTORY (ACCOUNT_TYPE_ID, ACTION_CODE, MODIFIED_BY, AFTER_SNAPSHOT)
    VALUES (i_Account_Type_Id, i_Action_Code, i_User, i_After_Snapshot);
  END Insert_Account_Type_History;

  PROCEDURE Insert_Account_Type_Client(i_Id              IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type,
                                        i_Account_Type_Id IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_ID%Type,
                                        i_Client_Type     IN ACC_ACCOUNT_TYPE_CLIENTS.CLIENT_TYPE%Type,
                                        i_State           IN ACC_ACCOUNT_TYPE_CLIENTS.STATE%Type,
                                        i_Code_Coa        IN ACC_ACCOUNT_TYPE_CLIENTS.CODE_COA%Type,
                                        i_Currency_Code   IN ACC_ACCOUNT_TYPE_CLIENTS.CURRENCY_CODE%Type,
                                        i_User            IN Varchar2) IS
  BEGIN
    INSERT INTO ACC_ACCOUNT_TYPE_CLIENTS
      (ACCOUNT_TYPE_CLIENT_ID, ACCOUNT_TYPE_ID, CLIENT_TYPE, STATE, CODE_COA, CURRENCY_CODE, CREATED_BY)
    VALUES
      (i_Id, i_Account_Type_Id, i_Client_Type, i_State, i_Code_Coa, i_Currency_Code, i_User);
  END Insert_Account_Type_Client;

  PROCEDURE Update_Account_Type_Client(i_Id            IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type,
                                        i_Client_Type   IN ACC_ACCOUNT_TYPE_CLIENTS.CLIENT_TYPE%Type,
                                        i_State         IN ACC_ACCOUNT_TYPE_CLIENTS.STATE%Type,
                                        i_Code_Coa      IN ACC_ACCOUNT_TYPE_CLIENTS.CODE_COA%Type,
                                        i_Currency_Code IN ACC_ACCOUNT_TYPE_CLIENTS.CURRENCY_CODE%Type,
                                        i_User          IN Varchar2,
                                        o_Rows_Updated  OUT Number) IS
  BEGIN
    UPDATE ACC_ACCOUNT_TYPE_CLIENTS
       SET CLIENT_TYPE = i_Client_Type, STATE = i_State, CODE_COA = i_Code_Coa,
           CURRENCY_CODE = i_Currency_Code, MODIFIED_ON = Sysdate, MODIFIED_BY = i_User
     WHERE ACCOUNT_TYPE_CLIENT_ID = i_Id;

    o_Rows_Updated := Sql%Rowcount;
  END Update_Account_Type_Client;

  PROCEDURE Delete_Account_Type_Client(i_Id           IN ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type,
                                        o_Rows_Deleted OUT Number) IS
  BEGIN
    DELETE FROM ACC_ACCOUNT_TYPE_CLIENTS WHERE ACCOUNT_TYPE_CLIENT_ID = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  END Delete_Account_Type_Client;

  PROCEDURE Insert_Account(i_Id              IN ACC_ACCOUNTS.ACCOUNT_ID%Type,
                            i_Account_Code    IN ACC_ACCOUNTS.ACCOUNT_CODE%Type,
                            i_Account_Type_Id IN ACC_ACCOUNTS.ACCOUNT_TYPE_ID%Type,
                            i_Owner_Type      IN ACC_ACCOUNTS.OWNER_TYPE%Type,
                            i_Client_Id       IN ACC_ACCOUNTS.CLIENT_ID%Type,
                            i_Code_Filial     IN ACC_ACCOUNTS.CODE_FILIAL%Type,
                            i_Code_Currency   IN ACC_ACCOUNTS.CODE_CURRENCY%Type,
                            i_Abs_Account_Id  IN ACC_ACCOUNTS.ABS_ACCOUNT_ID%Type,
                            i_Account_Status  IN ACC_ACCOUNTS.ACCOUNT_STATUS%Type,
                            i_Date_Open       IN ACC_ACCOUNTS.DATE_OPEN%Type,
                            i_User            IN Varchar2) IS
  BEGIN
    INSERT INTO ACC_ACCOUNTS
      (ACCOUNT_ID, ACCOUNT_CODE, ACCOUNT_TYPE_ID, OWNER_TYPE, CLIENT_ID,
       CODE_FILIAL, CODE_CURRENCY, ABS_ACCOUNT_ID, ACCOUNT_STATUS, DATE_OPEN, CREATED_BY)
    VALUES
      (i_Id, i_Account_Code, i_Account_Type_Id, i_Owner_Type, i_Client_Id,
       i_Code_Filial, i_Code_Currency, i_Abs_Account_Id, i_Account_Status, i_Date_Open, i_User);
  END Insert_Account;

  PROCEDURE Update_Account(i_Id              IN ACC_ACCOUNTS.ACCOUNT_ID%Type,
                            i_Account_Code    IN ACC_ACCOUNTS.ACCOUNT_CODE%Type,
                            i_Account_Type_Id IN ACC_ACCOUNTS.ACCOUNT_TYPE_ID%Type,
                            i_Owner_Type      IN ACC_ACCOUNTS.OWNER_TYPE%Type,
                            i_Client_Id       IN ACC_ACCOUNTS.CLIENT_ID%Type,
                            i_Code_Filial     IN ACC_ACCOUNTS.CODE_FILIAL%Type,
                            i_Code_Currency   IN ACC_ACCOUNTS.CODE_CURRENCY%Type,
                            i_Abs_Account_Id  IN ACC_ACCOUNTS.ABS_ACCOUNT_ID%Type,
                            i_Account_Status  IN ACC_ACCOUNTS.ACCOUNT_STATUS%Type,
                            i_Date_Open       IN ACC_ACCOUNTS.DATE_OPEN%Type,
                            i_Date_Close      IN ACC_ACCOUNTS.DATE_CLOSE%Type,
                            i_User            IN Varchar2,
                            o_Rows_Updated    OUT Number) IS
  BEGIN
    UPDATE ACC_ACCOUNTS
       SET ACCOUNT_CODE = i_Account_Code, ACCOUNT_TYPE_ID = i_Account_Type_Id,
           OWNER_TYPE = i_Owner_Type, CLIENT_ID = i_Client_Id,
           CODE_FILIAL = i_Code_Filial, CODE_CURRENCY = i_Code_Currency,
           ABS_ACCOUNT_ID = i_Abs_Account_Id, ACCOUNT_STATUS = i_Account_Status,
           DATE_OPEN = i_Date_Open, DATE_CLOSE = i_Date_Close,
           MODIFIED_ON = Sysdate, MODIFIED_BY = i_User
     WHERE ACCOUNT_ID = i_Id;

    o_Rows_Updated := Sql%Rowcount;
  END Update_Account;

  PROCEDURE Delete_Account(i_Id           IN ACC_ACCOUNTS.ACCOUNT_ID%Type,
                            o_Rows_Deleted OUT Number) IS
  BEGIN
    DELETE FROM ACC_ACCOUNTS WHERE ACCOUNT_ID = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  END Delete_Account;

  PROCEDURE Insert_Account_Module(i_Id             IN ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type,
                                   i_Account_Id     IN ACC_ACCOUNT_MODULES.ACCOUNT_ID%Type,
                                   i_Module_Code    IN ACC_ACCOUNT_MODULES.MODULE_CODE%Type,
                                   i_Is_Active_Flag IN ACC_ACCOUNT_MODULES.IS_ACTIVE_FLAG%Type,
                                   i_User           IN Varchar2) IS
  BEGIN
    INSERT INTO ACC_ACCOUNT_MODULES
      (ACCOUNT_MODULE_ID, ACCOUNT_ID, MODULE_CODE, IS_ACTIVE_FLAG, CREATED_BY)
    VALUES
      (i_Id, i_Account_Id, i_Module_Code, i_Is_Active_Flag, i_User);
  END Insert_Account_Module;

  PROCEDURE Update_Account_Module(i_Id              IN ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type,
                                   i_Is_Active_Flag  IN ACC_ACCOUNT_MODULES.IS_ACTIVE_FLAG%Type,
                                   i_Disconnected_On IN ACC_ACCOUNT_MODULES.DISCONNECTED_ON%Type,
                                   o_Rows_Updated    OUT Number) IS
  BEGIN
    UPDATE ACC_ACCOUNT_MODULES
       SET IS_ACTIVE_FLAG = i_Is_Active_Flag, DISCONNECTED_ON = i_Disconnected_On
     WHERE ACCOUNT_MODULE_ID = i_Id;

    o_Rows_Updated := Sql%Rowcount;
  END Update_Account_Module;

  PROCEDURE Delete_Account_Module(i_Id           IN ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type,
                                   o_Rows_Deleted OUT Number) IS
  BEGIN
    DELETE FROM ACC_ACCOUNT_MODULES WHERE ACCOUNT_MODULE_ID = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  END Delete_Account_Module;

END ACC_DML;
/
