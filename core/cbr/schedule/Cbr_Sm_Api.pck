----------------------------------------------------------------------------------------------------
--  Cbr_Sm_Api: SM (Core_Api.Execute_Process_Clob) dispetcheri chaqiradigan "yupqa" protseduralar.
--  Har biri Sm_Kernel talab qiladigan qat'iy signatura bilan: (Io_Hash, o_Code, o_Msg, o_Ora_Msg).
--  Haqiqiy ish Cbr_Schedule_Kernel'da bajariladi - bu paket faqat Hash_t <-> parametr ko'prigi.
----------------------------------------------------------------------------------------------------
create or replace package Cbr_Sm_Api is
  Procedure Manual_Refresh
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  Procedure Set_Schedule
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Cbr_Sm_Api;
/
create or replace package body Cbr_Sm_Api is

  Procedure Manual_Refresh
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    o_Ora_Msg := null;
    Cbr_Schedule_Kernel.Manual_Refresh(
      i_Ref_Id => Io_Hash.Get_Number('ref_id'),
      o_Code   => o_Code,
      o_Msg    => o_Msg
    );
  exception
    when others then
      o_Code    := -999;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;

  Procedure Set_Schedule
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    o_Ora_Msg := null;
    Cbr_Schedule_Kernel.Set_Schedule(
      i_Ref_Id    => Io_Hash.Get_Number('ref_id'),
      i_Interval  => Io_Hash.Get_Optional_Varchar2('interval')
    );
    o_Code := Core_Const.c_Success_Code;
    o_Msg  := null;
  exception
    when others then
      o_Code    := -999;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;

end Cbr_Sm_Api;
/
