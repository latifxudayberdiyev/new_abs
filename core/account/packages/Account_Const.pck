create or replace package Account_Const is

  -- Author  : B.URALOV
  -- Created : 03.06.2025 10:41:55
  -- Purpose : 

  c_Duration_Type_Long  constant varchar2(1) := 'L';
  c_Duration_Type_Short constant varchar2(1) := 'S';
  c_Subject_Type_Bank   constant varchar2(1) := 'B';
  c_Subject_Type_Client constant varchar2(1) := 'C';
  -- 
  c_Is_Mfi_Balance_y     constant varchar2(1) := 'Y';
  c_Is_Mfi_Balance_n     constant varchar2(1) := 'N';
  c_Is_Acc_Object_Type_y constant varchar2(1) := 'Y';
  c_Is_Acc_Object_Type_n constant varchar2(1) := 'N';
  c_Is_Virtual_Type      constant varchar2(1) := 'Y';
  c_Virtual_Type_Id      constant number(3) := 999;
  --
  c_Turnover_Type_All constant varchar2(3) := 'ALL';
  c_Turnover_Type_Obj constant varchar2(3) := 'OBJ';
  c_Header_Group_Code constant varchar2(3) := '003';
  c_Code_Sub_Account  constant varchar2(6) := '000000';
  c_Bank_Code         constant varchar2(3) := '003';
  c_Currncy_Code_Uzs  constant varchar2(3) := '000';
  -- functions

end Account_Const;
/
create or replace package body Account_Const is

end Account_Const;
/
