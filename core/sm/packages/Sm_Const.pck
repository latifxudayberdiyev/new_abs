create or replace package Sm_Const is
  -- Author  : B.URALOV
  -- Created : 30.04.2025 11:31:18
  -- Purpose : 
  ----------------------------------------------------------------------------------------------------
  c_Parent_Root            constant varchar2(4) := 'ROOT';
  c_Process_Type_Post      constant varchar2(4) := 'POST';
  c_Process_Type_Get       constant varchar2(4) := 'GET';
  c_Process_Type_Operation constant varchar2(9) := 'OPERATION';
  c_Success_Code           constant number := 0;
  c_State_Start            constant varchar2(5) := 'START';
  c_Param_Type_Number      constant varchar2(6) := 'NUMBER';
  c_Param_Type_Date        constant varchar2(4) := 'DATE';
  ----------------------------------------------------------------------------------------------------
  -- CD type
  c_Dc_Type_Income  constant varchar2(1) := 'C';
  c_Dc_Type_Expense constant varchar2(1) := 'D';
  ----------------------------------------------------------------------------------------------------
  -- operation
  c_Operation_State_Finish constant number(2) := 41;
  c_Max_Date               constant date := to_date('31.12.9999', 'dd.mm.yyyy');
  ----------------------------------------------------------------------------------------------------
  -- dml action code
  c_Dml_Action_Insert constant varchar2(1) := 'I';
  c_Dml_Action_Update constant varchar2(1) := 'U';
  c_Dml_Action_Delete constant varchar2(1) := 'D';
  ----------------------------------------------------------------------------------------------------
  --
  c_Is_Main_y constant varchar2(1) := 'Y';
  ----------------------------------------------------------------------------------------------------
  -- objectlar 
  c_Object_Code_File       constant varchar2(4) := 'FILE';
  c_Object_Code_Account    constant varchar2(7) := 'ACCOUNT';
  c_Object_Code_Commission constant varchar2(10) := 'COMMISSION';
  c_Object_Code_Perc       constant varchar2(4) := 'PERC';
  c_Object_Code_Graph      constant varchar2(5) := 'GRAPH';
  ----------------------------------------------------------------------------------------------------
  -- event state
  c_Event_State_Enter         constant number(1) := 0;
  c_Event_State_Complate      constant number(1) := 1;
  c_Event_State_Error         constant number(1) := 2;
  c_Event_State_Hold_Complate constant number(1) := 3;
  ----------------------------------------------------------------------------------------------------
  -- event mode
  c_Event_Mode_Standart       constant varchar2(1) := 'S';
  c_Event_Mode_Event_By_Event constant varchar2(3) := 'EBE';
  c_Event_Mode_Event_Hold     constant varchar2(2) := 'EH';
  ----------------------------------------------------------------------------------------------------
  -- currency
  c_Currency_Uzs constant varchar2(3) := '000';
  ----------------------------------------------------------------------------------------------------
  -- subject_type
  c_Subject_Type_Client constant varchar2(1) := 'C';
  c_Subject_Type_Bank   constant varchar2(1) := 'B';
  ----------------------------------------------------------------------------------------------------
  -- filial client_code
  c_Client_Code_Filial constant varchar2(8) := '00000440';
  c_Client_Code_Header constant varchar2(8) := '00009003';
  ----------------------------------------------------------------------------------------------------
  -- filial+code
  c_Code_Filial constant varchar2(5) := '00440';
  c_Code_Header constant varchar2(5) := '09003';
  ----------------------------------------------------------------------------------------------------
  -- mfi
  c_Crobs_Module_Id_Mfi   constant number(1) := 5;
  c_Crobs_Module_Code_Mfi constant varchar2(3) := 'MFI';
  c_Crobs_Module_Code_Tax constant varchar2(3) := 'TAX';
  ----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
end Sm_Const;
/
create or replace package body Sm_Const is
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
end Sm_Const;
/
