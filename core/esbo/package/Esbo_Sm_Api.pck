create or replace package Esbo_Sm_Api is

  -- Author  : B.URALOV
  -- Created : 06.04.2026 11:45:41
  -- Purpose : 
  Procedure Universal_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Psb_Service_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Fb_Service_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Esbo_Sm_Api;
/
create or replace package body Esbo_Sm_Api is
  Procedure Universal_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Esbo_Kernel.Universal_Api(Io_Hash   => Io_Hash,
                              o_Code    => o_Code,
                              o_Msg     => o_Msg,
                              o_Ora_Msg => o_Ora_Msg);
  end;
  ----
  --
  ----
  Procedure Psb_Service_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Esbo_Kernel.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
  end;
  ----
  --
  ----
  Procedure Fb_Service_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Esbo_Kernel.Fb_Service_Api(Io_Hash   => Io_Hash,
                               o_Code    => o_Code,
                               o_Msg     => o_Msg,
                               o_Ora_Msg => o_Ora_Msg);
  end;
end Esbo_Sm_Api;
/
