create or replace package Mle_Sm_Api is

  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Error_Stats(Io_Hash   in out nocopy Core.Hash_t,
                            o_Code    out number,
                            o_Msg     out varchar2,
                            o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Fix_Note(Io_Hash   in out nocopy Core.Hash_t,
                          o_Code    out number,
                          o_Msg     out varchar2,
                          o_Ora_Msg out varchar2);
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Save_Note_Reaction(Io_Hash   in out nocopy Core.Hash_t,
                               o_Code    out number,
                               o_Msg     out varchar2,
                               o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Fix_Note(Io_Hash   in out nocopy Core.Hash_t,
                         o_Code    out number,
                         o_Msg     out varchar2,
                         o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Note_Reaction(Io_Hash   in out nocopy Core.Hash_t,
                              o_Code    out number,
                              o_Msg     out varchar2,
                              o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template_With_Error(Io_Hash   in out nocopy Core.Hash_t,
                                     o_Code    out number,
                                     o_Msg     out varchar2,
                                     o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Error_Id(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
end Mle_Sm_Api;
/
create or replace package body Mle_Sm_Api is

  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Error_Stats(Io_Hash   in out nocopy Core.Hash_t,
                            o_Code    out number,
                            o_Msg     out varchar2,
                            o_Ora_Msg out varchar2) is
  begin
    Mle_Kernel.Get_Error_Stats(Io_Hash   => Io_Hash,
                               o_Code    => o_Code,
                               o_Msg     => o_Msg,
                               o_Ora_Msg => o_Ora_Msg);
  
  end Get_Error_Stats;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Fix_Note(Io_Hash   in out nocopy Core.Hash_t,
                          o_Code    out number,
                          o_Msg     out varchar2,
                          o_Ora_Msg out varchar2) is
  begin
    Mle_Kernel.Save_Fix_Note(Io_Hash   => Io_Hash,
                             o_Code    => o_Code,
                             o_Msg     => o_Msg,
                             o_Ora_Msg => o_Ora_Msg);
  end Save_Fix_Note;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Note_Reaction(Io_Hash   in out nocopy Core.Hash_t,
                               o_Code    out number,
                               o_Msg     out varchar2,
                               o_Ora_Msg out varchar2) is
  begin
    Mle_Kernel.Save_Note_Reaction(Io_Hash   => Io_Hash,
                                  o_Code    => o_code,
                                  o_Msg     => o_Msg,
                                  o_Ora_Msg => o_Ora_Msg);
  end Save_Note_Reaction;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Fix_Note(Io_Hash   in out nocopy Core.Hash_t,
                         o_Code    out number,
                         o_Msg     out varchar2,
                         o_Ora_Msg out varchar2) is
  begin
    Mle_Kernel.Get_Fix_Note(Io_Hash   => Io_Hash,
                            o_Code    => o_Code,
                            o_Msg     => o_Msg,
                            o_Ora_Msg => o_Ora_Msg);
  end Get_Fix_Note;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Note_Reaction(Io_Hash   in out nocopy Core.Hash_t,
                              o_Code    out number,
                              o_Msg     out varchar2,
                              o_Ora_Msg out varchar2) is
  begin
    Mle_Kernel.Get_Note_Reaction(Io_Hash   => Io_Hash,
                                 o_Code    => o_Code,
                                 o_Msg     => o_Msg,
                                 o_Ora_Msg => o_Ora_Msg);
  end Get_Note_Reaction;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template_With_Error(Io_Hash   in out nocopy Core.Hash_t,
                                     o_Code    out number,
                                     o_Msg     out varchar2,
                                     o_Ora_Msg out varchar2) is
  begin
    Mle_Kernel.Save_Template_With_Error(Io_Hash   => Io_Hash,
                                        o_Code    => o_Code,
                                        o_Msg     => o_Msg,
                                        o_Ora_Msg => o_Ora_Msg);
  end Save_Template_With_Error;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Error_Id(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2) is
  begin
    Mle_Kernel.Get_History_By_Error_Id(Io_Hash   => Io_Hash,
                                       o_Code    => o_Code,
                                       o_Msg     => o_Msg,
                                       o_Ora_Msg => o_Ora_Msg);
  end Get_History_By_Error_Id;
  -------------------------------------------------------------------------------------------------------------
end Mle_Sm_Api;
/
