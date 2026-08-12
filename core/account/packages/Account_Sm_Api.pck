create or replace package Account_Sm_Api is

  -- Author  : B.URALOV
  -- Created : 14.04.2026 16:22:13
  -- Purpose : 

  ----
  --
  ----
  Procedure Load_Account
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Load_Client_Accounts
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Load_Accounts_By_Mask
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Load_Account_By_Id
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Open_Account_Phys
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Open_Second_Jur_Acc
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Get_Client_Account_Protocols
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Account_Sm_Api;
/
create or replace package body Account_Sm_Api is

  ----
  --
  ----
  Procedure Load_Account
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Account_Kernel.Load_Account(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
  end;
  ----
  --
  ----
  Procedure Load_Client_Accounts
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Account_Kernel.Load_Client_Accounts(Io_Hash   => Io_Hash,
                                        o_Code    => o_Code,
                                        o_Msg     => o_Msg,
                                        o_Ora_Msg => o_Ora_Msg);
  end;
  ----
  --
  ----
  Procedure Load_Accounts_By_Mask
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Account_Kernel.Load_Accounts_By_Mask(Io_Hash   => Io_Hash,
                                         o_Code    => o_Code,
                                         o_Msg     => o_Msg,
                                         o_Ora_Msg => o_Ora_Msg);
  end;
  ----
  --
  ----
  Procedure Load_Account_By_Id
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Account_Kernel.Load_Account_By_Id(Io_Hash   => Io_Hash,
                                      o_Code    => o_Code,
                                      o_Msg     => o_Msg,
                                      o_Ora_Msg => o_Ora_Msg);
  end;
  ----
  --
  ----
  Procedure Open_Account_Phys
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Account_Kernel.Open_Account_Phys(Io_Hash   => Io_Hash,
                                     o_Code    => o_Code,
                                     o_Msg     => o_Msg,
                                     o_Ora_Msg => o_Ora_Msg);
  end;
  ----
  --
  ----
  Procedure Open_Second_Jur_Acc
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Account_Kernel.Open_Second_Jur_Acc(Io_Hash   => Io_Hash,
                                       o_Code    => o_Code,
                                       o_Msg     => o_Msg,
                                       o_Ora_Msg => o_Ora_Msg);
  end;
  ----
  --
  ----
  Procedure Get_Client_Account_Protocols
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    Account_Kernel.Get_Client_Account_Protocols(Io_Hash   => Io_Hash,
                                                o_Code    => o_Code,
                                                o_Msg     => o_Msg,
                                                o_Ora_Msg => o_Ora_Msg);
  end;
end Account_Sm_Api;
/
