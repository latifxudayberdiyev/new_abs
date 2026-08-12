create or replace package Esbin_Sm_Api is

  -- Author  : B.URALOV
  -- Purpose : SM_R_PROCEDURES uchun yupqa wrapper (Pf_Sm_Api naqshiga o'xshash)

  Procedure Model_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  Procedure Save_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  Procedure Attach_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  Procedure Revoke_Token
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

end Esbin_Sm_Api;
/
create or replace package body Esbin_Sm_Api is

  Procedure Model_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Esbin_Kernel.Model_User_Methods(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end Model_User_Methods;

  Procedure Save_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Esbin_Kernel.Save_User_Methods(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end Save_User_Methods;

  Procedure Attach_User_Methods
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Esbin_Kernel.Attach_User_Methods(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end Attach_User_Methods;

  Procedure Revoke_Token
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Esbin_Kernel.Revoke_Token(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end Revoke_Token;

end Esbin_Sm_Api;
/
