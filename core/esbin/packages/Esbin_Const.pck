create or replace package Esbin_Const is

  -- Author  : B.URALOV
  -- Purpose : ESBIN (inbound ESB) doimiylari
  c_Success_Code constant number := 0;

  c_State_Received constant varchar2(20) := 'RECEIVED';
  c_State_Queued    constant varchar2(20) := 'QUEUED';
  c_State_Running   constant varchar2(20) := 'RUNNING';
  c_State_Success   constant varchar2(20) := 'SUCCESS';
  c_State_Error     constant varchar2(20) := 'ERROR';

  c_Sync_Type_S constant varchar2(1) := 'S';
  c_Sync_Type_A constant varchar2(1) := 'A';

  c_Request_Type_Get  constant varchar2(10) := 'GET';
  c_Request_Type_Post constant varchar2(10) := 'POST';

  c_Method_Get_Result constant varchar2(100) := 'GET_REQUEST_RESULT';

  -- Auth_Lockout.Is_Locked/Register_Failure/Reset ishlatadigan AUTH_LOCKOUTS.USERNAME
  -- maydoni umumiy (barcha subsystemlar orasida bo'lishiladi) - shu prefiks bilan
  -- ESBIN login urinishlari boshqa provayderlar bilan to'qnashmaydi.
  c_Lockout_Ns constant varchar2(10) := 'ESBIN:';

  -- Partnerda TOKEN_TTL_MIN override bo'lmasa ishlatiladigan standart token
  -- muddati (daqiqada). 480 = 8 soat.
  c_Token_Ttl_Min constant pls_integer := 480;

end Esbin_Const;
/
