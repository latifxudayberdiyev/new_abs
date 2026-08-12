create or replace package Mll_Sm_Api is
  -- Author  : AALIJONOV
  -- Created : 20.05.2026 9:26:27
  -------------------------------------------------------------------------------------------------------------  
  Procedure Save_Label(Io_Hash in out nocopy Core.Hash_t,
                       o_Code  out number,
                       o_Msg   out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Label(Io_Hash in out nocopy Core.Hash_t,
                         o_Code  out number,
                         o_Msg   out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label_With_Template(Io_Hash   in out nocopy Core.Hash_t,
                                     o_Code    out number,
                                     o_Msg     out varchar2,
                                     o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label(Io_Hash in out nocopy Core.Hash_t,
                      o_Code  out number,
                      o_Msg   out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Label_Id(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
/* Procedure Get_Label_with_template(
    Io_hash in out nocopy Core.Hash_t,
    o_Code out number,
    o_Msg out varchar2, 
    o_label out varchar2
    ); */
-------------------------------------------------------------------------------------------------------------    
end Mll_Sm_Api;
/
create or replace package body Mll_Sm_Api is
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label(Io_Hash in out nocopy Core.Hash_t,
                       o_Code  out number,
                       o_Msg   out varchar2) is
  begin
    Mll_Kernel.Save_Label(Io_Hash => Io_Hash,
                          o_Code  => o_Code,
                          o_Msg   => o_Msg);
  end Save_Label;
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Delete_Label(Io_Hash in out nocopy Core.Hash_t,
                         o_Code  out number,
                         o_Msg   out varchar2) is
  begin
    Mll_Kernel.Delete_Label(Io_Hash => Io_Hash,
                            o_Code  => o_Code,
                            o_Msg   => o_Msg);
  end Delete_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label_With_Template(Io_Hash   in out nocopy Core.Hash_t,
                                     o_Code    out number,
                                     o_Msg     out varchar2,
                                     o_Ora_Msg out varchar2) is
  begin
    Mll_Kernel.Save_Label_With_Template(Io_Hash   => Io_Hash,
                                        o_Code    => o_Code,
                                        o_Msg     => o_Msg,
                                        o_Ora_Msg => o_Ora_Msg);
  end Save_Label_With_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label(Io_Hash in out nocopy Core.Hash_t,
                      o_Code  out number,
                      o_Msg   out varchar2) is
  begin
    Mll_Kernel.Get_Label(Io_Hash => Io_Hash,
                         o_Code  => o_Code,
                         o_Msg   => o_Msg);
  end Get_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Label_Id(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2) is
  begin
    Mll_Kernel.Get_History_By_Label_Id(Io_Hash   => Io_Hash,
                                       o_Code    => o_Code,
                                       o_Msg     => o_Msg,
                                       o_Ora_Msg => o_Ora_Msg);
  end Get_History_By_Label_Id;
  -------------------------------------------------------------------------------------------------------------
end Mll_Sm_Api;
/
