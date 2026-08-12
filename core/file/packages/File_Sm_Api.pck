
create or replace package File_Sm_Api is

-- Author  : B.URALOV
-- Purpose : SM_R_PROCEDURES'dan chaqiriladigan yagona kirish nuqtasi -
--           har bir protsedura mos File_Kernel protsedurasiga bir qatorlik o'tkazgich.

Procedure Model_File
(
  Io_Hash   in out nocopy Core.Hash_t,
  o_Code    out number,
  o_Msg     out varchar2,
  o_Ora_Msg out varchar2
);

Procedure Save_File
(
  Io_Hash   in out nocopy Core.Hash_t,
  o_Code    out number,
  o_Msg     out varchar2,
  o_Ora_Msg out varchar2
);

Procedure Del_File
(
  Io_Hash   in out nocopy Core.Hash_t,
  o_Code    out number,
  o_Msg     out varchar2,
  o_Ora_Msg out varchar2
);

end File_Sm_Api;
/
create or replace package body File_Sm_Api is
  ----------------------------------------------------------------------------------------------------
  Procedure Model_File
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    File_Kernel.Model_File(Io_Hash   => Io_Hash,
                           o_Code    => o_Code,
                           o_Msg     => o_Msg,
                           o_Ora_Msg => o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Save_File
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    File_Kernel.Save_File(Io_Hash   => Io_Hash,
                          o_Code    => o_Code,
                          o_Msg     => o_Msg,
                          o_Ora_Msg => o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Del_File
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    File_Kernel.Del_File(Io_Hash   => Io_Hash,
                         o_Code    => o_Code,
                         o_Msg     => o_Msg,
                         o_Ora_Msg => o_Ora_Msg);
  end;
  ----------------------------------------------------------------------------------------------------
end File_Sm_Api;
/
