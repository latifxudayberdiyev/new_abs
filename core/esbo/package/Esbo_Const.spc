create or replace package Esbo_Const is

  -- Author  : B.URALOV
  -- Created : 02.04.2026 13:30:52
  -- Purpose : 
  c_Pc_Login         constant varchar2(5) := 'LOGIN';
  c_Pc_Password      constant varchar2(8) := 'PASSWORD';
  c_Pc_Dbo_Url       constant varchar2(7) := 'DBO_URL';
  c_Pc_Dbo_Host      constant varchar2(8) := 'DBO_HOST';
  c_Pc_Esb_Url       constant varchar2(8) := 'ESB_URL';
  c_Pc_Get_Token_Url constant varchar2(13) := 'GET_TOKEN_URL';
  c_Pc_Refresh_Time  constant varchar2(12) := 'REFRESH_TIME';
  c_Pc_Token         constant varchar2(5) := 'TOKEN';
  -- services
  c_Service_Psb constant varchar2(7) := 'PSB_ESB';
  c_Service_Fb  constant varchar2(6) := 'FB_ESB';
end Esbo_Const;
/
