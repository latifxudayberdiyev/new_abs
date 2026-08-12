create or replace package Account_Kernel is

  -- Author  : B.URALOV
  -- Created : 09.04.2026 16:32:36
  -- Purpose : 
  ----
  --
  ----
  Procedure Load_Accounts_By_Mask
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  Procedure Load_Client_Accounts
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  ----
  --
  ----
  Procedure Load_Account
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Load_Account_By_Id
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Open_Account_Phys
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Open_Second_Jur_Acc
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Get_Client_Account_Protocols
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Account_Kernel;
/
create or replace package body Account_Kernel is
  Procedure Load_Client_Accounts
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Client_Code varchar2(8);
    v_Method_Code varchar2(50) := 'GET_CLIENT_ACCOUNTS';
    v_Esbo_Req    Hash_t := Hash_t();
    v_Esbo_Res    Hash_t := Hash_t();
    v_Page_Number number(4) := 1;
    v_Page_Size   number(6) := 20;
    v_Acc_List    Arraylist := Arraylist();
    v_Acc_Row     Accounts%rowtype;
  begin
    o_Code        := Sm_Const.c_Success_Code;
    v_Client_Code := Io_Hash.Get_Optional_Varchar2('client_code');
    while 1 = 1
    loop
      --
      v_Esbo_Req.Put('client_code', v_Client_Code);
      v_Esbo_Req.Put('method_code', v_Method_Code);
      v_Esbo_Req.Put('page_number', v_Page_Number);
      v_Esbo_Req.Put('page_size', v_Page_Size);
      --
      Io_Hash.Put('esbo_request', v_Esbo_Req);
      --
      Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                  o_Code    => o_Code,
                                  o_Msg     => o_Msg,
                                  o_Ora_Msg => o_Ora_Msg);
      if o_Code != Sm_Const.c_Success_Code then
        return;
      end if;
      v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
      --
      v_Acc_List := v_Esbo_Res.Get_Optional_Arraylist('acc_list');
      for i in 1 .. v_Acc_List.Count
      loop
        v_Esbo_Res := Treat(v_Acc_List.Get_r_Hash_t(i) as Hash_t);
        --   Dbms_Output.Put_Line(v_Esbo_Res.Json);
        v_Acc_Row.Account_Code    := v_Esbo_Res.Get_Optional_Varchar2('full_acc_code');
        v_Acc_Row.Account_Id      := v_Esbo_Res.Get_Optional_Number('acc_id');
        v_Acc_Row.Client_Code     := v_Esbo_Res.Get_Optional_Varchar2('client_code');
        v_Acc_Row.Client_Uid      := v_Esbo_Res.Get_Optional_Number('client_uid');
        v_Acc_Row.Name            := v_Esbo_Res.Get_Optional_Varchar2('name');
        v_Acc_Row.Status          := v_Esbo_Res.Get_Optional_Varchar2('status');
        v_Acc_Row.Code_Coa        := v_Esbo_Res.Get_Optional_Varchar2('code_coa');
        v_Acc_Row.Currency_Code   := v_Esbo_Res.Get_Optional_Varchar2('currency_code');
        v_Acc_Row.Local_Code      := v_Esbo_Res.Get_Optional_Varchar2('local_code');
        v_Acc_Row.Cbu_Code        := v_Esbo_Res.Get_Optional_Number('branch_id');
        v_Acc_Row.Date_Open       := v_Esbo_Res.Get_Optional_Date('date_open');
        v_Acc_Row.Lead_Last_Date  := v_Esbo_Res.Get_Optional_Date('lead_last_date');
        v_Acc_Row.Condition       := v_Esbo_Res.Get_Optional_Varchar2('condition');
        v_Acc_Row.Saldo_In        := v_Esbo_Res.Get_Optional_Number('saldo_id');
        v_Acc_Row.Saldo_Out       := v_Esbo_Res.Get_Optional_Number('saldo_out');
        v_Acc_Row.Saldo_Unlead    := v_Esbo_Res.Get_Optional_Number('saldo_unlead');
        v_Acc_Row.Turnover_Debit  := v_Esbo_Res.Get_Optional_Number('turnover_debit');
        v_Acc_Row.Turnover_Credit := v_Esbo_Res.Get_Optional_Number('turnover_credit');
        v_Acc_Row.Sign_Registr    := v_Esbo_Res.Get_Optional_Varchar2('sign_registr');
        v_Acc_Row.Gruppa_Code     := v_Esbo_Res.Get_Optional_Varchar2('group_code');
        --
        Account_Dml.Set_Account(v_Acc_Row);
      end loop;
      if v_Acc_List.Count >= v_Page_Size then
        v_Page_Number := v_Page_Number + 1;
      else
        exit;
      end if;
    end loop;
  end;
  ----
  --
  ----
  Procedure Load_Accounts_By_Mask
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Code_Coa     varchar2(5);
    v_Account_Mask varchar2(20);
    v_Method_Code  varchar2(50) := 'GET_ACCOUNTS_DATA_BY_MASK';
    v_Esbo_Req     Hash_t := Hash_t();
    v_Esbo_Res     Hash_t := Hash_t();
    v_Page_Number  number(4) := 1;
    v_Page_Size    number(6) := 20;
    v_Acc_List     Arraylist := Arraylist();
    v_Acc_Row      Accounts%rowtype;
  begin
    o_Code         := Sm_Const.c_Success_Code;
    v_Code_Coa     := Io_Hash.Get_Optional_Varchar2('code_coa');
    v_Account_Mask := Io_Hash.Get_Optional_Varchar2('account_mask');
    while 1 = 1
    loop
      --
      v_Esbo_Req.Put('code_coa', v_Code_Coa);
      v_Esbo_Req.Put('account_mask', v_Account_Mask);
      v_Esbo_Req.Put('method_code', v_Method_Code);
      v_Esbo_Req.Put('page_number', v_Page_Number);
      v_Esbo_Req.Put('page_size', v_Page_Size);
      --
      Io_Hash.Put('esbo_request', v_Esbo_Req);
      --
      Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                  o_Code    => o_Code,
                                  o_Msg     => o_Msg,
                                  o_Ora_Msg => o_Ora_Msg);
      if o_Code != Sm_Const.c_Success_Code then
        return;
      end if;
      v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
      --
      v_Acc_List := v_Esbo_Res.Get_Optional_Arraylist('acc_list');
      for i in 1 .. v_Acc_List.Count
      loop
        v_Esbo_Res := Treat(v_Acc_List.Get_r_Hash_t(i) as Hash_t);
        --   Dbms_Output.Put_Line(v_Esbo_Res.Json);
        v_Acc_Row.Account_Code    := v_Esbo_Res.Get_Optional_Varchar2('full_acc_code');
        v_Acc_Row.Account_Id      := v_Esbo_Res.Get_Optional_Number('acc_id');
        v_Acc_Row.Client_Code     := v_Esbo_Res.Get_Optional_Varchar2('client_code');
        v_Acc_Row.Client_Uid      := v_Esbo_Res.Get_Optional_Number('client_uid');
        v_Acc_Row.Name            := v_Esbo_Res.Get_Optional_Varchar2('name');
        v_Acc_Row.Status          := v_Esbo_Res.Get_Optional_Varchar2('status');
        v_Acc_Row.Code_Coa        := v_Esbo_Res.Get_Optional_Varchar2('code_coa');
        v_Acc_Row.Currency_Code   := v_Esbo_Res.Get_Optional_Varchar2('currency_code');
        v_Acc_Row.Local_Code      := v_Esbo_Res.Get_Optional_Varchar2('local_code');
        v_Acc_Row.Cbu_Code        := v_Esbo_Res.Get_Optional_Number('branch_id');
        v_Acc_Row.Date_Open       := v_Esbo_Res.Get_Optional_Date('date_open');
        v_Acc_Row.Lead_Last_Date  := v_Esbo_Res.Get_Optional_Date('lead_last_date');
        v_Acc_Row.Condition       := v_Esbo_Res.Get_Optional_Varchar2('condition');
        v_Acc_Row.Saldo_In        := v_Esbo_Res.Get_Optional_Number('saldo_id');
        v_Acc_Row.Saldo_Out       := v_Esbo_Res.Get_Optional_Number('saldo_out');
        v_Acc_Row.Saldo_Unlead    := v_Esbo_Res.Get_Optional_Number('saldo_unlead');
        v_Acc_Row.Turnover_Debit  := v_Esbo_Res.Get_Optional_Number('turnover_debit');
        v_Acc_Row.Turnover_Credit := v_Esbo_Res.Get_Optional_Number('turnover_credit');
        v_Acc_Row.Sign_Registr    := v_Esbo_Res.Get_Optional_Varchar2('sign_registr');
        v_Acc_Row.Gruppa_Code     := v_Esbo_Res.Get_Optional_Varchar2('group_code');
        --
        Account_Dml.Set_Account(v_Acc_Row);
      end loop;
      if v_Acc_List.Count >= v_Page_Size then
        v_Page_Number := v_Page_Number + 1;
      else
        exit;
      end if;
    end loop;
  end;
  ----
  --
  ----
  Procedure Load_Account
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Acc_External varchar2(20);
    v_Method_Code  varchar2(50) := 'GET_ACCOUNT_DATA';
    v_Esbo_Req     Hash_t := Hash_t();
    v_Esbo_Res     Hash_t := Hash_t();
    v_Acc_Row      Accounts%rowtype;
  begin
    o_Code         := Sm_Const.c_Success_Code;
    v_Acc_External := Io_Hash.Get_Optional_Varchar2('account_external');
    --
    v_Esbo_Req.Put('account_external', v_Acc_External);
    v_Esbo_Req.Put('method_code', v_Method_Code);
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
    --   Dbms_Output.Put_Line(v_Esbo_Res.Json);
    v_Acc_Row.Account_Code    := v_Esbo_Res.Get_Optional_Varchar2('full_acc_code');
    v_Acc_Row.Account_Id      := v_Esbo_Res.Get_Optional_Number('acc_id');
    v_Acc_Row.Client_Code     := v_Esbo_Res.Get_Optional_Varchar2('client_code');
    v_Acc_Row.Client_Uid      := v_Esbo_Res.Get_Optional_Number('client_uid');
    v_Acc_Row.Name            := v_Esbo_Res.Get_Optional_Varchar2('name');
    v_Acc_Row.Status          := v_Esbo_Res.Get_Optional_Varchar2('status');
    v_Acc_Row.Code_Coa        := v_Esbo_Res.Get_Optional_Varchar2('code_coa');
    v_Acc_Row.Currency_Code   := v_Esbo_Res.Get_Optional_Varchar2('currency_code');
    v_Acc_Row.Local_Code      := v_Esbo_Res.Get_Optional_Varchar2('local_code');
    v_Acc_Row.Cbu_Code        := v_Esbo_Res.Get_Optional_Number('branch_id');
    v_Acc_Row.Date_Open       := v_Esbo_Res.Get_Optional_Date('date_open');
    v_Acc_Row.Lead_Last_Date  := v_Esbo_Res.Get_Optional_Date('lead_last_date');
    v_Acc_Row.Condition       := v_Esbo_Res.Get_Optional_Varchar2('condition');
    v_Acc_Row.Saldo_In        := v_Esbo_Res.Get_Optional_Number('saldo_id');
    v_Acc_Row.Saldo_Out       := v_Esbo_Res.Get_Optional_Number('saldo_out');
    v_Acc_Row.Saldo_Unlead    := v_Esbo_Res.Get_Optional_Number('saldo_unlead');
    v_Acc_Row.Turnover_Debit  := v_Esbo_Res.Get_Optional_Number('turnover_debit');
    v_Acc_Row.Turnover_Credit := v_Esbo_Res.Get_Optional_Number('turnover_credit');
    v_Acc_Row.Sign_Registr    := v_Esbo_Res.Get_Optional_Varchar2('sign_registr');
    v_Acc_Row.Gruppa_Code     := v_Esbo_Res.Get_Optional_Varchar2('group_code');
    Account_Dml.Set_Account(v_Acc_Row);
    --
  end;
  ----
  --
  ----
  Procedure Load_Account_By_Id
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Acc_Id      number(20);
    v_Method_Code varchar2(50) := 'GET_ACCOUNT_DATA_BY_ID';
    v_Esbo_Req    Hash_t := Hash_t();
    v_Esbo_Res    Hash_t := Hash_t();
    v_Acc_Row     Accounts%rowtype;
  begin
    o_Code   := Sm_Const.c_Success_Code;
    v_Acc_Id := Io_Hash.Get_Optional_Varchar2('account_id');
    --
    v_Esbo_Req.Put('account_id', v_Acc_Id);
    v_Esbo_Req.Put('method_code', v_Method_Code);
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
    --   Dbms_Output.Put_Line(v_Esbo_Res.Json);
    v_Acc_Row.Account_Code    := v_Esbo_Res.Get_Optional_Varchar2('full_acc_code');
    v_Acc_Row.Account_Id      := v_Esbo_Res.Get_Optional_Number('acc_id');
    v_Acc_Row.Client_Code     := v_Esbo_Res.Get_Optional_Varchar2('client_code');
    v_Acc_Row.Client_Uid      := v_Esbo_Res.Get_Optional_Number('client_uid');
    v_Acc_Row.Name            := v_Esbo_Res.Get_Optional_Varchar2('name');
    v_Acc_Row.Status          := v_Esbo_Res.Get_Optional_Varchar2('status');
    v_Acc_Row.Code_Coa        := v_Esbo_Res.Get_Optional_Varchar2('code_coa');
    v_Acc_Row.Currency_Code   := v_Esbo_Res.Get_Optional_Varchar2('currency_code');
    v_Acc_Row.Local_Code      := v_Esbo_Res.Get_Optional_Varchar2('local_code');
    v_Acc_Row.Cbu_Code        := v_Esbo_Res.Get_Optional_Number('branch_id');
    v_Acc_Row.Date_Open       := v_Esbo_Res.Get_Optional_Date('date_open');
    v_Acc_Row.Lead_Last_Date  := v_Esbo_Res.Get_Optional_Date('lead_last_date');
    v_Acc_Row.Condition       := v_Esbo_Res.Get_Optional_Varchar2('condition');
    v_Acc_Row.Saldo_In        := v_Esbo_Res.Get_Optional_Number('saldo_id');
    v_Acc_Row.Saldo_Out       := v_Esbo_Res.Get_Optional_Number('saldo_out');
    v_Acc_Row.Saldo_Unlead    := v_Esbo_Res.Get_Optional_Number('saldo_unlead');
    v_Acc_Row.Turnover_Debit  := v_Esbo_Res.Get_Optional_Number('turnover_debit');
    v_Acc_Row.Turnover_Credit := v_Esbo_Res.Get_Optional_Number('turnover_credit');
    v_Acc_Row.Sign_Registr    := v_Esbo_Res.Get_Optional_Varchar2('sign_registr');
    v_Acc_Row.Gruppa_Code     := v_Esbo_Res.Get_Optional_Varchar2('group_code');
    Account_Dml.Set_Account(v_Acc_Row);
    --
  end;
  ----
  --
  ----
  Procedure Open_Account_Phys
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Client_Code   varchar2(8);
    v_Code_Coa      varchar2(5);
    v_Code_Currency varchar2(3);
    v_Acc_Name      varchar2(300);
    v_Group_Code    varchar2(10);
    v_Local_Code    varchar2(5);
    v_Cbu_Code      number(5);
    v_Method_Code   varchar2(20) := 'OPEN_ACC_PHYS';
    v_Esbo_Req      Hash_t := Hash_t();
    v_Esbo_Res      Hash_t := Hash_t();
  begin
    o_Code          := Sm_Const.c_Success_Code;
    v_Client_Code   := Io_Hash.Get_Optional_Varchar2('client_code');
    v_Code_Coa      := Io_Hash.Get_Optional_Varchar2('code_coa');
    v_Code_Currency := Io_Hash.Get_Optional_Varchar2('currency_code');
    v_Acc_Name      := Io_Hash.Get_Optional_Varchar2('acc_name');
    v_Group_Code    := Io_Hash.Get_Optional_Varchar2('group_code');
    v_Local_Code    := Io_Hash.Get_Optional_Varchar2('local_code');
    v_Cbu_Code      := Io_Hash.Get_Optional_Number('cbu_code');
    --
    v_Esbo_Req.Put('method_code', v_Method_Code);
    v_Esbo_Req.Put('bankCode', Account_Const.c_Bank_Code);
    v_Esbo_Req.Put('codeFilial', Core_Const.c_Filial);
    v_Esbo_Req.Put('codeClient', v_Client_Code);
    v_Esbo_Req.Put('codeCoa', v_Code_Coa);
    v_Esbo_Req.Put('codeCurrency', v_Code_Currency);
    v_Esbo_Req.Put('nameAcc', v_Acc_Name);
    v_Esbo_Req.Put('codeGroup', v_Group_Code);
    v_Esbo_Req.Put('codeLocalStructure', v_Local_Code);
    v_Esbo_Req.Put('codeSubAccount', Account_Const.c_Code_Sub_Account);
    v_Esbo_Req.Put('condition', Core_Const.c_State_Active);
    v_Esbo_Req.Put('bxmCode', to_char(v_Cbu_Code));
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Fb_Service_Api(Io_Hash   => Io_Hash,
                               o_Code    => o_Code,
                               o_Msg     => o_Msg,
                               o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
    --
    Io_Hash.Put('account_external', v_Esbo_Res.Get_Optional_Varchar2('account'));
    Load_Account(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    --
  end;
  ----
  --
  ----
  Procedure Open_Second_Jur_Acc
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Client_Code   varchar2(8);
    v_Code_Coa      varchar2(5);
    v_Code_Currency varchar2(3);
    v_Acc_Name      varchar2(300);
    v_Group_Code    varchar2(10);
    v_Local_Code    varchar2(5);
    v_Cbu_Code      number(5);
    v_Method_Code   varchar2(50) := 'OPEN_SECOND_ACC_JUR_CLIENT';
    v_Esbo_Req      Hash_t := Hash_t();
    v_Esbo_Res      Hash_t := Hash_t();
  begin
    o_Code          := Sm_Const.c_Success_Code;
    v_Client_Code   := Io_Hash.Get_Optional_Varchar2('client_code');
    v_Code_Coa      := Io_Hash.Get_Optional_Varchar2('code_coa');
    v_Code_Currency := Io_Hash.Get_Optional_Varchar2('currency_code');
    v_Acc_Name      := Io_Hash.Get_Optional_Varchar2('acc_name');
    v_Group_Code    := Io_Hash.Get_Optional_Varchar2('group_code');
    v_Local_Code    := Io_Hash.Get_Optional_Varchar2('local_code');
    v_Cbu_Code      := Io_Hash.Get_Optional_Number('cbu_code');
    --
    v_Esbo_Req.Put('method_code', v_Method_Code);
    v_Esbo_Req.Put('bankCode', Account_Const.c_Bank_Code);
    v_Esbo_Req.Put('codeFilial', Core_Const.c_Filial);
    v_Esbo_Req.Put('clientCode', v_Client_Code);
    v_Esbo_Req.Put('codeCoa', v_Code_Coa);
    v_Esbo_Req.Put('codeCurrency', v_Code_Currency);
    v_Esbo_Req.Put('nameAcc', v_Acc_Name);
    v_Esbo_Req.Put('codeGroup', v_Group_Code);
    v_Esbo_Req.Put('codeLocalStructure', v_Local_Code);
    v_Esbo_Req.Put('codeSubAccount', Account_Const.c_Code_Sub_Account);
    v_Esbo_Req.Put('condition', Core_Const.c_State_Active);
    v_Esbo_Req.Put('bxmCode', to_char(v_Cbu_Code));
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Fb_Service_Api(Io_Hash   => Io_Hash,
                               o_Code    => o_Code,
                               o_Msg     => o_Msg,
                               o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
    --
    Io_Hash.Put('account_external', v_Esbo_Res.Get_Optional_Varchar2('accExternal'));
    Load_Account(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    --
  end;
  ----
  --
  ----
  Procedure Get_Client_Account_Protocols
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Account_Code  varchar2(30);
    v_Acc_Id        number(20);
    v_Method_Code   varchar2(50) := 'GET_CLIENT_ACCOUNT_PROTOCOLS';
    v_Esbo_Req      Hash_t := Hash_t();
    v_Esbo_Res      Hash_t := Hash_t();
    v_Page_Number   number(4) := 1;
    v_Page_Size     number(6) := 20;
    v_Protocol_List Arraylist := Arraylist();
    v_Protocol_Row  Client_Account_Protocols%rowtype;
  begin
    o_Code         := Sm_Const.c_Success_Code;
    v_Account_Code := Io_Hash.Get_Optional_Varchar2('code');
    v_Acc_Id       := Io_Hash.Get_Optional_Number('account_id');
    while 1 = 1
    loop
      --
      v_Esbo_Req.Put('code', v_Account_Code);
      v_Esbo_Req.Put('account_id', to_char(v_Acc_Id));
      v_Esbo_Req.Put('method_code', v_Method_Code);
      v_Esbo_Req.Put('page_number', v_Page_Number);
      v_Esbo_Req.Put('page_size', v_Page_Size);
      --
      Io_Hash.Put('esbo_request', v_Esbo_Req);
      --
      Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                  o_Code    => o_Code,
                                  o_Msg     => o_Msg,
                                  o_Ora_Msg => o_Ora_Msg);
      if o_Code != Sm_Const.c_Success_Code then
        return;
      end if;
      v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
      --
      v_Protocol_List := v_Esbo_Res.Get_Optional_Arraylist('protocol_list');
      --
      Account_Dml.Clear_Client_Account_Protocol(i_Code => v_Account_Code);
      --
      for i in 1 .. v_Protocol_List.Count
      loop
        v_Esbo_Res := Treat(v_Protocol_List.Get_r_Hash_t(i) as Hash_t);
        --   Dbms_Output.Put_Line(v_Esbo_Res.Json);
        v_Protocol_Row.Date_Modify      := v_Esbo_Res.Get_Optional_Varchar2('date_modify');
        v_Protocol_Row.Code             := v_Esbo_Res.Get_Optional_Varchar2('code');
        v_Protocol_Row.Date_Validate    := v_Esbo_Res.Get_Optional_Date('date_validate');
        v_Protocol_Row.Operator_Code    := v_Esbo_Res.Get_Optional_Number('operator_code');
        v_Protocol_Row.Operator_Name    := v_Esbo_Res.Get_Optional_Varchar2('operator_name');
        v_Protocol_Row.What_Changed     := v_Esbo_Res.Get_Optional_Varchar2('what_chaged');
        v_Protocol_Row.Change_Sign_Name := v_Esbo_Res.Get_Optional_Varchar2('change_sign_name');
        v_Protocol_Row.Change_Sign      := v_Esbo_Res.Get_Optional_Varchar2('change_sign');
        v_Protocol_Row.Parent_Task_Name := v_Esbo_Res.Get_Optional_Varchar2('parent_task_name');
        v_Protocol_Row.Parent_Task_Code := v_Esbo_Res.Get_Optional_Number('parent_task_code');
        v_Protocol_Row.Action_Code      := v_Esbo_Res.Get_Optional_Number('action_code');
        v_Protocol_Row.Action_Name      := v_Esbo_Res.Get_Optional_Varchar2('action_name');
        v_Protocol_Row.Error_Message    := v_Esbo_Res.Get_Optional_Varchar2('error_message');
        --
        Account_Dml.Set_Client_Account_Protocol(v_Protocol_Row);
      end loop;
      if v_Protocol_List.Count >= v_Page_Size then
        v_Page_Number := v_Page_Number + 1;
      else
        exit;
      end if;
    end loop;
  end;
end Account_Kernel;
/
