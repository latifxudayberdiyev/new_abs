create or replace package Mlt_Sm_Api is

  -- Author  : AALIJONOV
  -- Created : 21.04.2026 16:28:15
  -- Purpose : sm api
  -------------------------------------------------------------------------------------------------------------  
  Procedure Get_Template(Io_Hash   in out nocopy Core.Hash_t,
                         o_Code    out number,
                         o_Msg     out varchar2,
                         o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label(Io_Hash   in out nocopy Core.Hash_t,
                      o_Code    out number,
                      o_Msg     out varchar2,
                      o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------                           
  Procedure Save_Template(Io_Hash   in out nocopy Core.Hash_t,
                          o_Code    out number,
                          o_Msg     out varchar2,
                          o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template_Fill_Stats(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
end Mlt_Sm_Api;
/
create or replace package body Mlt_Sm_Api is
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template(Io_Hash   in out nocopy Core.Hash_t,
                         o_Code    out number,
                         o_Msg     out varchar2,
                         o_Ora_Msg out varchar2) is
  begin
    Mlt_Kernel.Get_Template(Io_Hash   => Io_Hash,
                            o_Code    => o_Code,
                            o_Msg     => o_Msg,
                            o_Ora_Msg => o_Ora_Msg);
  end Get_Template;
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Get_Label(Io_Hash   in out nocopy Core.Hash_t,
                      o_Code    out number,
                      o_Msg     out varchar2,
                      o_Ora_Msg out varchar2) is
  begin
    Mlt_Kernel.Get_Label(Io_Hash   => Io_Hash,
                         o_Code    => o_Code,
                         o_Msg     => o_Msg,
                         o_Ora_Msg => o_Ora_Msg);
  end Get_Label;
  -------------------------------------------------------------------------------------------------------------   
  Procedure Save_Template(Io_Hash   in out nocopy Core.Hash_t,
                          o_Code    out number,
                          o_Msg     out varchar2,
                          o_Ora_Msg out varchar2) is
  begin
    Mlt_Kernel.Save_Template(Io_Hash   => Io_Hash,
                             o_Code    => o_Code,
                             o_Msg     => o_Msg,
                             o_Ora_Msg => o_Ora_Msg);
  end Save_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template_Fill_Stats(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2) is
  begin
    Mlt_Kernel.Get_Template_Fill_Stats(Io_Hash   => Io_Hash,
                                       o_Code    => o_Code,
                                       o_Msg     => o_Msg,
                                       o_Ora_Msg => o_Ora_Msg);
  end Get_Template_Fill_Stats;
  -------------------------------------------------------------------------------------------------------------
end Mlt_Sm_Api;
/
