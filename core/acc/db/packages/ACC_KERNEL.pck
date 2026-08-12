--------------------------------------------------------------------------------
-- ACC_KERNEL - "Тип счёта" va дочерняя запись uchun barcha biznes-logika:
-- Core.Hash_t modeli bilan ishlash, validatsiya, JSON snapshot va tarix
-- yozuvlari. O'qish (rowtype/mavjudlik) uchun ACC_UTIL, yozish (DML) uchun
-- ACC_DML paketini chaqiradi - o'zida xom SELECT/INSERT/UPDATE/DELETE yo'q.
--
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating
-- (kirill literallari - 'Баланс','Внебаланс' va h.k. - buzilib qolmasligi uchun).
-- Kompilyatsiya tartibi: ACC_UTIL -> ACC_DML -> shu fayl (ACC_KERNEL) -> ACC_SM_API.
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ACC_KERNEL IS

  PROCEDURE Model_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                o_Code    OUT Number,
                                o_Msg     OUT Varchar2,
                                o_Ora_Msg OUT Varchar2);

  PROCEDURE Save_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                               o_Code    OUT Number,
                               o_Msg     OUT Varchar2,
                               o_Ora_Msg OUT Varchar2);

  PROCEDURE Delete_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                 o_Code    OUT Number,
                                 o_Msg     OUT Varchar2,
                                 o_Ora_Msg OUT Varchar2);

  PROCEDURE Model_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                       o_Code    OUT Number,
                                       o_Msg     OUT Varchar2,
                                       o_Ora_Msg OUT Varchar2);

  PROCEDURE Save_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                      o_Code    OUT Number,
                                      o_Msg     OUT Varchar2,
                                      o_Ora_Msg OUT Varchar2);

  PROCEDURE Delete_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                        o_Code    OUT Number,
                                        o_Msg     OUT Varchar2,
                                        o_Ora_Msg OUT Varchar2);

  PROCEDURE Model_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                           o_Code    OUT Number,
                           o_Msg     OUT Varchar2,
                           o_Ora_Msg OUT Varchar2);

  PROCEDURE Save_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                          o_Code    OUT Number,
                          o_Msg     OUT Varchar2,
                          o_Ora_Msg OUT Varchar2);

  PROCEDURE Delete_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                            o_Code    OUT Number,
                            o_Msg     OUT Varchar2,
                            o_Ora_Msg OUT Varchar2);

  PROCEDURE Model_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                  o_Code    OUT Number,
                                  o_Msg     OUT Varchar2,
                                  o_Ora_Msg OUT Varchar2);

  PROCEDURE Save_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                 o_Code    OUT Number,
                                 o_Msg     OUT Varchar2,
                                 o_Ora_Msg OUT Varchar2);

  PROCEDURE Delete_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                   o_Code    OUT Number,
                                   o_Msg     OUT Varchar2,
                                   o_Ora_Msg OUT Varchar2);

END ACC_KERNEL;
/

CREATE OR REPLACE PACKAGE BODY ACC_KERNEL IS

  ----------------------------------------------------------------------------
  PROCEDURE Model_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                o_Code    OUT Number,
                                o_Msg     OUT Varchar2,
                                o_Ora_Msg OUT Varchar2) IS
    v_Row  ACC_ACCOUNT_TYPES%Rowtype;
    v_Data Core.Hash_t := Core.Hash_t();
  BEGIN
    o_Code := 0;

    v_Row := Acc_Util.Select_Account_Type(Io_Hash.Get_Optional_Number('account_type_id'));

    v_Data.Put('account_type_id', v_Row.ACCOUNT_TYPE_ID);
    v_Data.Put('name', v_Row.NAME);
    v_Data.Put('module_code', v_Row.MODULE_CODE);
    v_Data.Put('balance_type', v_Row.BALANCE_TYPE);
    v_Data.Put('state', v_Row.STATE);
    v_Data.Put('unique_contract_flag', v_Row.UNIQUE_CONTRACT_FLAG);
    v_Data.Put('is_open_flag', v_Row.IS_OPEN_FLAG);
    v_Data.Put('incode_type', v_Row.INCODE_TYPE);
    v_Data.Put('is_virtual', v_Row.IS_VIRTUAL);
    v_Data.Put('object_code', v_Row.OBJECT_CODE);

    Io_Hash.Put('data', v_Data);
  EXCEPTION
    WHEN No_Data_Found THEN
      o_Code    := -20060;
      o_Msg     := 'Тип счёта топилмади.';
      o_Ora_Msg := o_Msg;
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Model_Account_Type;

  ----------------------------------------------------------------------------
  PROCEDURE Save_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                               o_Code    OUT Number,
                               o_Msg     OUT Varchar2,
                               o_Ora_Msg OUT Varchar2) IS
    v_Id               ACC_ACCOUNT_TYPES.ACCOUNT_TYPE_ID%Type;
    v_Name             ACC_ACCOUNT_TYPES.NAME%Type;
    v_Module_Code      ACC_ACCOUNT_TYPES.MODULE_CODE%Type;
    v_Balance_Code     Varchar2(10);
    v_Balance_Type     ACC_ACCOUNT_TYPES.BALANCE_TYPE%Type;
    v_State            ACC_ACCOUNT_TYPES.STATE%Type;
    v_Unique_Contract  ACC_ACCOUNT_TYPES.UNIQUE_CONTRACT_FLAG%Type;
    v_Is_Open          ACC_ACCOUNT_TYPES.IS_OPEN_FLAG%Type;
    v_Incode_Type      ACC_ACCOUNT_TYPES.INCODE_TYPE%Type;
    v_Is_Virtual       ACC_ACCOUNT_TYPES.IS_VIRTUAL%Type;
    v_Object_Code      ACC_ACCOUNT_TYPES.OBJECT_CODE%Type;
    v_User             Varchar2(50);
    v_Sm_Cache         Core.Hash_t;
    v_Is_New           Boolean;
    v_Action_Code      Varchar2(10);
    v_Rows             Number;
    v_After            Clob;
  BEGIN
    o_Code := 0;

    v_Id              := Io_Hash.Get_Optional_Number('account_type_id');
    v_Name             := Io_Hash.Get_Varchar2('name');
    v_Module_Code      := Io_Hash.Get_Varchar2('module_code');
    v_Balance_Code     := Nvl(Io_Hash.Get_Optional_Varchar2('balance_type'), 'BAL');
    v_Balance_Type     := Case When v_Balance_Code = 'OFB' Then 'Внебаланс' Else 'Баланс' End;
    v_State            := Nvl(Io_Hash.Get_Optional_Varchar2('state'), 'A');
    v_Unique_Contract  := Case When Io_Hash.Get_Optional_Varchar2('unique_contract_flag') = '1' Then 'Y' Else 'N' End;
    v_Is_Open          := Case When Io_Hash.Get_Optional_Varchar2('is_open_flag') = '1' Then 'Y' Else 'N' End;
    v_Incode_Type      := Nvl(Io_Hash.Get_Optional_Varchar2('incode_type'), 'D');
    v_Is_Virtual       := Case When Io_Hash.Get_Optional_Varchar2('is_virtual') = '1' Then 'Y' Else 'N' End;
    v_Object_Code      := Io_Hash.Get_Optional_Varchar2('object_code');
    v_User             := Nvl(Io_Hash.Get_Optional_Varchar2('user_id'), User);

    If Not Acc_Util.Exists_Module(v_Module_Code) Then
      o_Code    := -20061;
      o_Msg     := 'Кўрсатилган модул топилмади.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If v_Id Is Not Null Then
      v_Is_New := False;

      Acc_Dml.Update_Account_Type(i_Id                   => v_Id,
                                  i_Name                 => v_Name,
                                  i_Module_Code          => v_Module_Code,
                                  i_Balance_Type         => v_Balance_Type,
                                  i_State                => v_State,
                                  i_Unique_Contract_Flag => v_Unique_Contract,
                                  i_Is_Open_Flag         => v_Is_Open,
                                  i_Incode_Type          => v_Incode_Type,
                                  i_Is_Virtual           => v_Is_Virtual,
                                  i_Object_Code          => v_Object_Code,
                                  i_User                 => v_User,
                                  o_Rows_Updated         => v_Rows);

      If v_Rows = 0 Then
        o_Code    := -20060;
        o_Msg     := 'Тип счёта топилмади.';
        o_Ora_Msg := o_Msg;
        Return;
      End If;
    Else
      v_Is_New   := True;
      v_Sm_Cache := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Id       := v_Sm_Cache.Get_Optional_Number('account_type_id');

      Acc_Dml.Insert_Account_Type(i_Id                   => v_Id,
                                  i_Name                 => v_Name,
                                  i_Module_Code          => v_Module_Code,
                                  i_Balance_Type         => v_Balance_Type,
                                  i_State                => v_State,
                                  i_Unique_Contract_Flag => v_Unique_Contract,
                                  i_Is_Open_Flag         => v_Is_Open,
                                  i_Incode_Type          => v_Incode_Type,
                                  i_Is_Virtual           => v_Is_Virtual,
                                  i_Object_Code          => v_Object_Code,
                                  i_User                 => v_User);
    End If;

    v_Action_Code := Case When v_Is_New Then 'CREATE' Else 'UPDATE' End;

    v_After := Json_Object('name' Value v_Name, 'module_code' Value v_Module_Code,
                            'balance_type' Value v_Balance_Type, 'state' Value v_State,
                            'unique_contract_flag' Value v_Unique_Contract,
                            'is_open_flag' Value v_Is_Open);

    Acc_Dml.Insert_Account_Type_History(i_Account_Type_Id => v_Id,
                                        i_Action_Code     => v_Action_Code,
                                        i_User            => v_User,
                                        i_After_Snapshot  => v_After);
  EXCEPTION
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Save_Account_Type;

  ----------------------------------------------------------------------------
  PROCEDURE Delete_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                 o_Code    OUT Number,
                                 o_Msg     OUT Varchar2,
                                 o_Ora_Msg OUT Varchar2) IS
    v_Id   Number;
    v_Rows Number;
  BEGIN
    o_Code := 0;
    v_Id   := Io_Hash.Get_Optional_Number('account_type_id');

    Acc_Dml.Delete_Account_Type(i_Id => v_Id, o_Rows_Deleted => v_Rows);

    If v_Rows = 0 Then
      o_Code    := -20060;
      o_Msg     := 'Тип счёта топилмади.';
      o_Ora_Msg := o_Msg;
    End If;
  EXCEPTION
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Delete_Account_Type;

  ----------------------------------------------------------------------------
  PROCEDURE Model_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                       o_Code    OUT Number,
                                       o_Msg     OUT Varchar2,
                                       o_Ora_Msg OUT Varchar2) IS
    v_Row  ACC_ACCOUNT_TYPE_CLIENTS%Rowtype;
    v_Data Core.Hash_t := Core.Hash_t();
  BEGIN
    o_Code := 0;

    v_Row := Acc_Util.Select_Account_Type_Client(Io_Hash.Get_Optional_Number('account_type_client_id'));

    v_Data.Put('account_type_client_id', v_Row.ACCOUNT_TYPE_CLIENT_ID);
    v_Data.Put('account_type_id', v_Row.ACCOUNT_TYPE_ID);
    v_Data.Put('client_type', v_Row.CLIENT_TYPE);
    v_Data.Put('state', v_Row.STATE);
    v_Data.Put('code_coa', v_Row.CODE_COA);
    v_Data.Put('currency_code', v_Row.CURRENCY_CODE);

    Io_Hash.Put('data', v_Data);
  EXCEPTION
    WHEN No_Data_Found THEN
      o_Code    := -20062;
      o_Msg     := 'Дочерняя запись топилмади.';
      o_Ora_Msg := o_Msg;
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Model_Account_Type_Client;

  ----------------------------------------------------------------------------
  PROCEDURE Save_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                      o_Code    OUT Number,
                                      o_Msg     OUT Varchar2,
                                      o_Ora_Msg OUT Varchar2) IS
    v_Id            ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_CLIENT_ID%Type;
    v_Parent_Id     ACC_ACCOUNT_TYPE_CLIENTS.ACCOUNT_TYPE_ID%Type;
    v_Client_Type   ACC_ACCOUNT_TYPE_CLIENTS.CLIENT_TYPE%Type;
    v_State         ACC_ACCOUNT_TYPE_CLIENTS.STATE%Type;
    v_Code_Coa      ACC_ACCOUNT_TYPE_CLIENTS.CODE_COA%Type;
    v_Currency      ACC_ACCOUNT_TYPE_CLIENTS.CURRENCY_CODE%Type;
    v_User          Varchar2(50);
    v_Sm_Cache      Core.Hash_t;
    v_Is_New        Boolean;
    v_Child_Action  Varchar2(10);
    v_Rows          Number;
    v_After         Clob;
  BEGIN
    o_Code := 0;

    v_Id           := Io_Hash.Get_Optional_Number('account_type_client_id');
    v_Parent_Id    := Io_Hash.Get_Number('account_type_id');
    v_Client_Type  := Nvl(Io_Hash.Get_Optional_Varchar2('client_type'), 'C');
    v_State        := Nvl(Io_Hash.Get_Optional_Varchar2('state'), 'A');
    v_Code_Coa     := Io_Hash.Get_Varchar2('code_coa');
    v_Currency     := Nvl(Io_Hash.Get_Optional_Varchar2('currency_code'), '*');
    v_User         := Nvl(Io_Hash.Get_Optional_Varchar2('user_id'), User);

    If Not Acc_Util.Exists_Account_Type(v_Parent_Id) Then
      o_Code    := -20060;
      o_Msg     := 'Тип счёта (родитель) топилмади.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If v_Id Is Not Null Then
      v_Is_New := False;

      Acc_Dml.Update_Account_Type_Client(i_Id            => v_Id,
                                         i_Client_Type   => v_Client_Type,
                                         i_State         => v_State,
                                         i_Code_Coa      => v_Code_Coa,
                                         i_Currency_Code => v_Currency,
                                         i_User          => v_User,
                                         o_Rows_Updated  => v_Rows);

      If v_Rows = 0 Then
        o_Code    := -20062;
        o_Msg     := 'Дочерняя запись топилмади.';
        o_Ora_Msg := o_Msg;
        Return;
      End If;
    Else
      v_Is_New   := True;
      v_Sm_Cache := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Id       := v_Sm_Cache.Get_Optional_Number('account_type_client_id');

      Acc_Dml.Insert_Account_Type_Client(i_Id              => v_Id,
                                         i_Account_Type_Id => v_Parent_Id,
                                         i_Client_Type     => v_Client_Type,
                                         i_State           => v_State,
                                         i_Code_Coa        => v_Code_Coa,
                                         i_Currency_Code   => v_Currency,
                                         i_User            => v_User);
    End If;

    v_Child_Action := Case When v_Is_New Then 'ADD' Else 'EDIT' End;

    v_After := Json_Object('child_action' Value v_Child_Action,
                            'account_type_client_id' Value v_Id,
                            'client_type' Value v_Client_Type,
                            'code_coa' Value v_Code_Coa,
                            'currency_code' Value v_Currency,
                            'state' Value v_State);

    Acc_Dml.Insert_Account_Type_History(i_Account_Type_Id => v_Parent_Id,
                                        i_Action_Code     => 'UPDATE',
                                        i_User            => v_User,
                                        i_After_Snapshot  => v_After);
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      o_Code    := -20063;
      o_Msg     := 'Ушбу тип счёт учун бундай Коды COA (Баланс код) аллақачон мавжуд.';
      o_Ora_Msg := o_Msg;
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Save_Account_Type_Client;

  ----------------------------------------------------------------------------
  PROCEDURE Delete_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                        o_Code    OUT Number,
                                        o_Msg     OUT Varchar2,
                                        o_Ora_Msg OUT Varchar2) IS
    v_Id         Number;
    v_Client_Row ACC_ACCOUNT_TYPE_CLIENTS%Rowtype;
    v_Parent_Id  Number;
    v_User       Varchar2(50);
    v_Rows       Number;
    v_After      Clob;
  BEGIN
    o_Code := 0;
    v_Id   := Io_Hash.Get_Optional_Number('account_type_client_id');
    v_User := Nvl(Io_Hash.Get_Optional_Varchar2('user_id'), User);

    v_Client_Row := Acc_Util.Select_Account_Type_Client(v_Id);
    v_Parent_Id  := v_Client_Row.ACCOUNT_TYPE_ID;

    Acc_Dml.Delete_Account_Type_Client(i_Id => v_Id, o_Rows_Deleted => v_Rows);

    v_After := Json_Object('child_action' Value 'DELETE', 'account_type_client_id' Value v_Id);
    Acc_Dml.Insert_Account_Type_History(i_Account_Type_Id => v_Parent_Id,
                                        i_Action_Code     => 'UPDATE',
                                        i_User            => v_User,
                                        i_After_Snapshot  => v_After);
  EXCEPTION
    WHEN No_Data_Found THEN
      o_Code    := -20062;
      o_Msg     := 'Дочерняя запись топилмади.';
      o_Ora_Msg := o_Msg;
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Delete_Account_Type_Client;

  ----------------------------------------------------------------------------
  PROCEDURE Model_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                           o_Code    OUT Number,
                           o_Msg     OUT Varchar2,
                           o_Ora_Msg OUT Varchar2) IS
    v_Row  ACC_ACCOUNTS%Rowtype;
    v_Data Core.Hash_t := Core.Hash_t();
  BEGIN
    o_Code := 0;

    v_Row := Acc_Util.Select_Account(Io_Hash.Get_Optional_Number('account_id'));

    v_Data.Put('account_id', v_Row.ACCOUNT_ID);
    v_Data.Put('account_code', v_Row.ACCOUNT_CODE);
    v_Data.Put('account_type_id', v_Row.ACCOUNT_TYPE_ID);
    v_Data.Put('owner_type', v_Row.OWNER_TYPE);
    If v_Row.CLIENT_ID Is Not Null Then
      v_Data.Put('client_id', v_Row.CLIENT_ID);
    End If;
    v_Data.Put('code_filial', v_Row.CODE_FILIAL);
    v_Data.Put('code_currency', v_Row.CODE_CURRENCY);
    If v_Row.ABS_ACCOUNT_ID Is Not Null Then
      v_Data.Put('abs_account_id', v_Row.ABS_ACCOUNT_ID);
    End If;
    v_Data.Put('account_status', v_Row.ACCOUNT_STATUS);
    v_Data.Put('date_open', v_Row.DATE_OPEN);
    v_Data.Put('date_close', v_Row.DATE_CLOSE);

    Io_Hash.Put('data', v_Data);
  EXCEPTION
    WHEN No_Data_Found THEN
      o_Code    := -20070;
      o_Msg     := 'Хисоб рақами топилмади.';
      o_Ora_Msg := o_Msg;
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Model_Account;

  ----------------------------------------------------------------------------
  PROCEDURE Save_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                          o_Code    OUT Number,
                          o_Msg     OUT Varchar2,
                          o_Ora_Msg OUT Varchar2) IS
    v_Id              ACC_ACCOUNTS.ACCOUNT_ID%Type;
    v_Account_Code    ACC_ACCOUNTS.ACCOUNT_CODE%Type;
    v_Account_Type_Id ACC_ACCOUNTS.ACCOUNT_TYPE_ID%Type;
    v_Owner_Type      ACC_ACCOUNTS.OWNER_TYPE%Type;
    v_Client_Id       ACC_ACCOUNTS.CLIENT_ID%Type;
    v_Code_Filial     ACC_ACCOUNTS.CODE_FILIAL%Type;
    v_Code_Currency   ACC_ACCOUNTS.CODE_CURRENCY%Type;
    v_Abs_Account_Id  ACC_ACCOUNTS.ABS_ACCOUNT_ID%Type;
    v_Account_Status  ACC_ACCOUNTS.ACCOUNT_STATUS%Type;
    v_Date_Open       ACC_ACCOUNTS.DATE_OPEN%Type;
    v_Date_Close      ACC_ACCOUNTS.DATE_CLOSE%Type;
    v_User            Varchar2(50);
    v_Sm_Cache        Core.Hash_t;
    v_Rows            Number;
  BEGIN
    o_Code := 0;

    v_Id              := Io_Hash.Get_Optional_Number('account_id');
    v_Account_Code    := Io_Hash.Get_Varchar2('account_code');
    v_Account_Type_Id := Io_Hash.Get_Number('account_type_id');
    v_Owner_Type      := Io_Hash.Get_Varchar2('owner_type');
    v_Client_Id       := Case When v_Owner_Type = 'C' Then Io_Hash.Get_Optional_Number('client_id') Else Null End;
    v_Code_Filial     := Io_Hash.Get_Varchar2('code_filial');
    v_Code_Currency   := Io_Hash.Get_Varchar2('code_currency');
    v_Abs_Account_Id  := Io_Hash.Get_Optional_Number('abs_account_id');
    v_Account_Status  := Nvl(Io_Hash.Get_Optional_Varchar2('account_status'), 'O');
    v_Date_Open       := Nvl(Io_Hash.Get_Optional_Date('date_open', 'DD.MM.YYYY'), Sysdate);
    v_Date_Close      := Io_Hash.Get_Optional_Date('date_close', 'DD.MM.YYYY');
    v_User            := Nvl(Io_Hash.Get_Optional_Varchar2('user_id'), User);

    If Not Acc_Util.Exists_Account_Type(v_Account_Type_Id) Then
      o_Code    := -20071;
      o_Msg     := 'Кўрсатилган тип счёт топилмади.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If v_Owner_Type = 'C' Then
      If v_Client_Id Is Null Or Not Acc_Util.Exists_Client(v_Client_Id) Then
        o_Code    := -20072;
        o_Msg     := 'Клиент нотўғри кўрсатилган.';
        o_Ora_Msg := o_Msg;
        Return;
      End If;
    End If;

    If v_Id Is Not Null Then
      Acc_Dml.Update_Account(i_Id              => v_Id,
                             i_Account_Code    => v_Account_Code,
                             i_Account_Type_Id => v_Account_Type_Id,
                             i_Owner_Type      => v_Owner_Type,
                             i_Client_Id       => v_Client_Id,
                             i_Code_Filial     => v_Code_Filial,
                             i_Code_Currency   => v_Code_Currency,
                             i_Abs_Account_Id  => v_Abs_Account_Id,
                             i_Account_Status  => v_Account_Status,
                             i_Date_Open       => v_Date_Open,
                             i_Date_Close      => v_Date_Close,
                             i_User            => v_User,
                             o_Rows_Updated    => v_Rows);

      If v_Rows = 0 Then
        o_Code    := -20070;
        o_Msg     := 'Хисоб рақами топилмади.';
        o_Ora_Msg := o_Msg;
      End If;
    Else
      v_Sm_Cache  := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Id        := v_Sm_Cache.Get_Optional_Number('account_id');

      Acc_Dml.Insert_Account(i_Id              => v_Id,
                             i_Account_Code    => v_Account_Code,
                             i_Account_Type_Id => v_Account_Type_Id,
                             i_Owner_Type      => v_Owner_Type,
                             i_Client_Id       => v_Client_Id,
                             i_Code_Filial     => v_Code_Filial,
                             i_Code_Currency   => v_Code_Currency,
                             i_Abs_Account_Id  => v_Abs_Account_Id,
                             i_Account_Status  => v_Account_Status,
                             i_Date_Open       => v_Date_Open,
                             i_User            => v_User);
    End If;
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      o_Code    := -20073;
      o_Msg     := 'Ушбу счёт рақами (account_code) билан ёзув аллақачон мавжуд.';
      o_Ora_Msg := o_Msg;
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Save_Account;

  ----------------------------------------------------------------------------
  PROCEDURE Delete_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                            o_Code    OUT Number,
                            o_Msg     OUT Varchar2,
                            o_Ora_Msg OUT Varchar2) IS
    v_Id   Number;
    v_Rows Number;
  BEGIN
    o_Code := 0;
    v_Id   := Io_Hash.Get_Optional_Number('account_id');

    Acc_Dml.Delete_Account(i_Id => v_Id, o_Rows_Deleted => v_Rows);

    If v_Rows = 0 Then
      o_Code    := -20070;
      o_Msg     := 'Хисоб рақами топилмади.';
      o_Ora_Msg := o_Msg;
    End If;
  EXCEPTION
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Delete_Account;

  ----------------------------------------------------------------------------
  PROCEDURE Model_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                  o_Code    OUT Number,
                                  o_Msg     OUT Varchar2,
                                  o_Ora_Msg OUT Varchar2) IS
    v_Row  ACC_ACCOUNT_MODULES%Rowtype;
    v_Data Core.Hash_t := Core.Hash_t();
  BEGIN
    o_Code := 0;

    v_Row := Acc_Util.Select_Account_Module(Io_Hash.Get_Optional_Number('account_module_id'));

    v_Data.Put('account_module_id', v_Row.ACCOUNT_MODULE_ID);
    v_Data.Put('account_id', v_Row.ACCOUNT_ID);
    v_Data.Put('module_code', v_Row.MODULE_CODE);
    v_Data.Put('is_active_flag', v_Row.IS_ACTIVE_FLAG);

    Io_Hash.Put('data', v_Data);
  EXCEPTION
    WHEN No_Data_Found THEN
      o_Code    := -20074;
      o_Msg     := 'Модул боғланиши топилмади.';
      o_Ora_Msg := o_Msg;
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Model_Account_Module;

  ----------------------------------------------------------------------------
  PROCEDURE Save_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                 o_Code    OUT Number,
                                 o_Msg     OUT Varchar2,
                                 o_Ora_Msg OUT Varchar2) IS
    v_Id              ACC_ACCOUNT_MODULES.ACCOUNT_MODULE_ID%Type;
    v_Account_Id      ACC_ACCOUNT_MODULES.ACCOUNT_ID%Type;
    v_Module_Code     ACC_ACCOUNT_MODULES.MODULE_CODE%Type;
    v_Is_Active       ACC_ACCOUNT_MODULES.IS_ACTIVE_FLAG%Type;
    v_Disconnected_On ACC_ACCOUNT_MODULES.DISCONNECTED_ON%Type;
    v_User            Varchar2(50);
    v_Sm_Cache        Core.Hash_t;
    v_Rows            Number;
  BEGIN
    o_Code := 0;

    v_Id          := Io_Hash.Get_Optional_Number('account_module_id');
    v_Account_Id  := Io_Hash.Get_Number('account_id');
    v_Module_Code := Io_Hash.Get_Varchar2('module_code');
    v_Is_Active   := Case When Io_Hash.Get_Optional_Varchar2('is_active_flag') = '1' Then 'Y' Else 'N' End;
    v_User        := Nvl(Io_Hash.Get_Optional_Varchar2('user_id'), User);

    If Not Acc_Util.Exists_Account(v_Account_Id) Then
      o_Code    := -20070;
      o_Msg     := 'Хисоб рақами (ота ёзув) топилмади.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If v_Id Is Not Null Then
      If v_Is_Active = 'N' Then
        v_Disconnected_On := Sysdate;
      End If;

      Acc_Dml.Update_Account_Module(i_Id              => v_Id,
                                    i_Is_Active_Flag  => v_Is_Active,
                                    i_Disconnected_On => v_Disconnected_On,
                                    o_Rows_Updated    => v_Rows);

      If v_Rows = 0 Then
        o_Code    := -20074;
        o_Msg     := 'Модул боғланиши топилмади.';
        o_Ora_Msg := o_Msg;
      End If;
    Else
      v_Sm_Cache := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Id       := v_Sm_Cache.Get_Optional_Number('account_module_id');

      Acc_Dml.Insert_Account_Module(i_Id             => v_Id,
                                    i_Account_Id     => v_Account_Id,
                                    i_Module_Code    => v_Module_Code,
                                    i_Is_Active_Flag => v_Is_Active,
                                    i_User           => v_User);
    End If;
  EXCEPTION
    WHEN Dup_Val_On_Index THEN
      o_Code    := -20075;
      o_Msg     := 'Ушбу хисоб рақами учун бундай модул аллақачон боғланган.';
      o_Ora_Msg := o_Msg;
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Save_Account_Module;

  ----------------------------------------------------------------------------
  PROCEDURE Delete_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                   o_Code    OUT Number,
                                   o_Msg     OUT Varchar2,
                                   o_Ora_Msg OUT Varchar2) IS
    v_Id   Number;
    v_Rows Number;
  BEGIN
    o_Code := 0;
    v_Id   := Io_Hash.Get_Optional_Number('account_module_id');

    Acc_Dml.Delete_Account_Module(i_Id => v_Id, o_Rows_Deleted => v_Rows);

    If v_Rows = 0 Then
      o_Code    := -20074;
      o_Msg     := 'Модул боғланиши топилмади.';
      o_Ora_Msg := o_Msg;
    End If;
  EXCEPTION
    WHEN Others THEN
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  END Delete_Account_Module;

END ACC_KERNEL;
/
