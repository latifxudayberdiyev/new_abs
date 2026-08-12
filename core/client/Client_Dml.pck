create or replace package Client_Dml is

  -- Author  : B.URALOV
  -- Created : 05.05.2026 16:27:11
  -- Purpose : 
  Procedure Set_Physical_Client(i_Row Client_Individuals%rowtype);
  ----
  --
  ----
  Procedure Set_Client_Detail
  (
    i_Client_Code varchar2,
    i_Detail      clob
  );
  ----
  --
  ----
  Procedure Set_Proprietor_Client(i_Row Client_Proprietors%rowtype);
  ----
  --
  ----
  Procedure Set_Entities_Client(i_Row Client_Entities%rowtype);
end Client_Dml;
/
create or replace package body Client_Dml is
  Procedure Set_Physical_Client(i_Row Client_Individuals%rowtype) is
  begin
    update Client_Individuals t
       set t.Status          = i_Row.Status,
           t.Surname         = i_Row.Surname,
           t.First_Name      = i_Row.First_Name,
           t.Patronymic      = i_Row.Patronymic,
           t.Name            = i_Row.Name,
           t.Birthday        = i_Row.Birthday,
           t.Pinfl           = i_Row.Pinfl,
           t.Inn             = i_Row.Inn,
           t.Passport_Serial = i_Row.Passport_Serial,
           t.Passport_Number = i_Row.Passport_Number,
           t.Mobile_Phone    = i_Row.Mobile_Phone,
           t.Operator_Code   = i_Row.Operator_Code,
           t.Date_Open       = i_Row.Date_Open,
           t.Modify_On       = sysdate,
           t.Modify_By       = -7
     where t.Client_Code = i_Row.Client_Code;
    --
    if sql%rowcount = 0 then
      insert into Client_Individuals
        (Client_Id,
         Client_Uid,
         Client_Code,
         Status,
         Surname,
         First_Name,
         Patronymic,
         name,
         Birthday,
         Pinfl,
         Inn,
         Passport_Serial,
         Passport_Number,
         Mobile_Phone,
         Operator_Code,
         Date_Open,
         Modify_On,
         Modify_By)
      values
        (i_Row.Client_Id,
         i_Row.Client_Uid,
         i_Row.Client_Code,
         i_Row.Status,
         i_Row.Surname,
         i_Row.First_Name,
         i_Row.Patronymic,
         i_Row.Name,
         i_Row.Birthday,
         i_Row.Pinfl,
         i_Row.Inn,
         i_Row.Passport_Serial,
         i_Row.Passport_Number,
         i_Row.Mobile_Phone,
         i_Row.Operator_Code,
         i_Row.Date_Open,
         sysdate,
         -7);
    end if;
  end;
  ----
  --
  ----
  Procedure Set_Client_Detail
  (
    i_Client_Code varchar2,
    i_Detail      clob
  ) is
  begin
    update Client_Details t
       set t.Detail_Json = i_Detail,
           t.Modify_On   = sysdate
     where t.Client_Code = i_Client_Code;
    --
    if sql%rowcount = 0 then
      insert into Client_Details
        (Client_Code, Detail_Json, Modify_On)
      values
        (i_Client_Code, i_Detail, sysdate);
    end if;
  end;
  ----
  --
  ----
  Procedure Set_Proprietor_Client(i_Row Client_Proprietors%rowtype) is
  begin
    update Client_Proprietors t
       set t.Status              = i_Row.Status,
           t.Segment_Code        = i_Row.Segment_Code,
           t.Surname             = i_Row.Surname,
           t.First_Name          = i_Row.First_Name,
           t.Patronymic          = i_Row.Patronymic,
           t.Fio                 = i_Row.Fio,
           t.Birthday            = i_Row.Birthday,
           t.Pinfl               = i_Row.Pinfl,
           t.Inn                 = i_Row.Inn,
           t.Passport_Serial     = i_Row.Passport_Serial,
           t.Passport_Number     = i_Row.Passport_Number,
           t.Mobile_Phone        = i_Row.Mobile_Phone,
           t.Business_Name       = i_Row.Business_Name,
           t.Registration_Date   = i_Row.Registration_Date,
           t.Registration_Number = i_Row.Registration_Number,
           t.Director_Name       = i_Row.Director_Name,
           t.Director_Passport   = i_Row.Director_Passport,
           t.Accountant_Name     = i_Row.Accountant_Name,
           t.Accountant_Passport = i_Row.Accountant_Passport,
           t.Operator_Code       = i_Row.Operator_Code,
           t.Date_Open           = i_Row.Date_Open,
           t.Modify_On           = sysdate,
           t.Modify_By           = -7
     where t.Client_Code = i_Row.Client_Code;
    --
    if sql%rowcount = 0 then
      insert into Client_Proprietors
        (Client_Id,
         Client_Uid,
         Client_Code,
         Status,
         Segment_Code,
         Surname,
         First_Name,
         Patronymic,
         Fio,
         Birthday,
         Passport_Serial,
         Passport_Number,
         Pinfl,
         Inn,
         Mobile_Phone,
         Business_Name,
         Registration_Date,
         Registration_Number,
         Director_Name,
         Director_Passport,
         Accountant_Name,
         Accountant_Passport,
         Modify_On,
         Modify_By,
         Operator_Code,
         Date_Open)
      values
        (i_Row.Client_Id,
         i_Row.Client_Uid,
         i_Row.Client_Code,
         i_Row.Status,
         i_Row.Segment_Code,
         i_Row.Surname,
         i_Row.First_Name,
         i_Row.Patronymic,
         i_Row.Fio,
         i_Row.Birthday,
         i_Row.Passport_Serial,
         i_Row.Passport_Number,
         i_Row.Pinfl,
         i_Row.Inn,
         i_Row.Mobile_Phone,
         i_Row.Business_Name,
         i_Row.Registration_Date,
         i_Row.Registration_Number,
         i_Row.Director_Name,
         i_Row.Director_Passport,
         i_Row.Accountant_Name,
         i_Row.Accountant_Passport,
         sysdate,
         -7,
         i_Row.Operator_Code,
         i_Row.Date_Open);
    end if;
  end;
  ----
  --
  ----
  Procedure Set_Entities_Client(i_Row Client_Entities%rowtype) is
  begin
    update Client_Entities t
       set t.Status                  = i_Row.Status,
           t.Segment_Code            = i_Row.Segment_Code,
           t.Bic                     = i_Row.Bic,
           t.Is_Identification_Bdmab = i_Row.Is_Identification_Bdmab,
           t.Client_Type             = i_Row.Client_Type,
           t.Residency_Code          = i_Row.Residency_Code,
           t.Organization_Name       = i_Row.Organization_Name,
           t.Registration_Date       = i_Row.Registration_Date,
           t.Registration_Number     = i_Row.Registration_Number,
           t.Inn                     = i_Row.Inn,
           t.Director_Name           = i_Row.Director_Name,
           t.Director_Passport       = i_Row.Director_Passport,
           t.Accountant_Name         = i_Row.Accountant_Name,
           t.Accountant_Passport     = i_Row.Accountant_Passport,
           t.Phone                   = i_Row.Phone,
           t.Mobile_Phone            = i_Row.Mobile_Phone,
           t.Operator_Code           = i_Row.Operator_Code,
           t.Date_Open               = i_Row.Date_Open,
           t.Modify_On               = sysdate,
           t.Modify_By               = -7
     where t.Client_Code = i_Row.Client_Code;
    --
    if sql%rowcount = 0 then
      insert into Client_Entities
        (Client_Id,
         Client_Uid,
         Client_Code,
         Status,
         Segment_Code,
         Bic,
         Is_Identification_Bdmab,
         Client_Type,
         Residency_Code,
         Organization_Name,
         Registration_Number,
         Registration_Date,
         Inn,
         Director_Name,
         Director_Passport,
         Accountant_Name,
         Accountant_Passport,
         Phone,
         Mobile_Phone,
         Modify_On,
         Modify_By,
         Operator_Code,
         Date_Open)
      values
        (i_Row.Client_Id,
         i_Row.Client_Uid,
         i_Row.Client_Code,
         i_Row.Status,
         i_Row.Segment_Code,
         i_Row.Bic,
         i_Row.Is_Identification_Bdmab,
         i_Row.Client_Type,
         i_Row.Residency_Code,
         i_Row.Organization_Name,
         i_Row.Registration_Number,
         i_Row.Registration_Date,
         i_Row.Inn,
         i_Row.Director_Name,
         i_Row.Director_Passport,
         i_Row.Accountant_Name,
         i_Row.Accountant_Passport,
         i_Row.Phone,
         i_Row.Mobile_Phone,
         sysdate,
         -7,
         i_Row.Operator_Code,
         i_Row.Date_Open);
    end if;
  end;
end Client_Dml;
/
