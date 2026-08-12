create or replace package Account_Dml is

  -- Author  : B.URALOV
  -- Created : 10.04.2026 10:02:35
  -- Purpose : 
  Procedure Set_Account(i_Row Accounts%rowtype);
  ----
  --
  ----
  Procedure Clear_Client_Account_Protocol(i_Code in varchar2);
  ----
  --
  ----
  Procedure Set_Client_Account_Protocol(i_Row Client_Account_Protocols%rowtype);
end Account_Dml;
/
create or replace package body Account_Dml is
  Procedure Set_Account(i_Row Accounts%rowtype) is
  begin
    update Accounts t
       set t.Account_Code    = i_Row.Account_Code,
           t.Account_Id      = i_Row.Account_Id,
           t.Client_Code     = i_Row.Client_Code,
           t.Client_Uid      = i_Row.Client_Uid,
           t.Name            = i_Row.Name,
           t.Status          = i_Row.Status,
           t.Code_Coa        = i_Row.Code_Coa,
           t.Currency_Code   = i_Row.Currency_Code,
           t.Local_Code      = i_Row.Local_Code,
           t.Cbu_Code        = i_Row.Cbu_Code,
           t.Date_Open       = i_Row.Date_Open,
           t.Lead_Last_Date  = i_Row.Lead_Last_Date,
           t.Condition       = i_Row.Condition,
           t.Saldo_In        = i_Row.Saldo_In,
           t.Saldo_Out       = i_Row.Saldo_Out,
           t.Saldo_Unlead    = i_Row.Saldo_Unlead,
           t.Turnover_Debit  = i_Row.Turnover_Debit,
           t.Turnover_Credit = i_Row.Turnover_Credit,
           t.Sign_Registr    = i_Row.Sign_Registr,
           t.Gruppa_Code     = i_Row.Gruppa_Code,
           t.Modify_On       = sysdate,
           t.Modify_By       = -7
     where t.Account_Id = i_Row.Account_Id;
    --
    if sql%rowcount = 0 then
      insert into Accounts
        (Account_Code,
         Account_Id,
         Client_Code,
         Client_Uid,
         name,
         Status,
         Code_Coa,
         Currency_Code,
         Local_Code,
         Cbu_Code,
         Date_Open,
         Lead_Last_Date,
         Condition,
         Saldo_In,
         Saldo_Out,
         Saldo_Unlead,
         Turnover_Debit,
         Turnover_Credit,
         Sign_Registr,
         Gruppa_Code,
         Modify_On,
         Modify_By,
         Created_On,
         Created_By)
      values
        (i_Row.Account_Code,
         i_Row.Account_Id,
         i_Row.Client_Code,
         i_Row.Client_Uid,
         i_Row.Name,
         i_Row.Status,
         i_Row.Code_Coa,
         i_Row.Currency_Code,
         i_Row.Local_Code,
         i_Row.Cbu_Code,
         i_Row.Date_Open,
         i_Row.Lead_Last_Date,
         i_Row.Condition,
         i_Row.Saldo_In,
         i_Row.Saldo_Out,
         i_Row.Saldo_Unlead,
         i_Row.Turnover_Debit,
         i_Row.Turnover_Credit,
         i_Row.Sign_Registr,
         i_Row.Gruppa_Code,
         sysdate,
         -7,
         sysdate,
         -7);
    end if;
  end;
  ----
  --
  ----
  Procedure Clear_Client_Account_Protocol(i_Code in varchar2) is
  begin
    delete from Client_Account_Protocols t
     where t.Code = i_Code;
  end;
  ----
  --
  ----
  Procedure Set_Client_Account_Protocol(i_Row Client_Account_Protocols%rowtype) is
  begin
    insert into Client_Account_Protocols
    values i_Row;
  end;
end Account_Dml;
/
