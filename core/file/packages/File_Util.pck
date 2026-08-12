
create or replace package File_Util is

-- Author  : B.URALOV
-- Purpose : Files - selectlar/o'qish funksiyalari.

Function Load_File
(
  i_File_Id number,
  o_Row     out Files%rowtype
) return boolean;

end File_Util;
/
create or replace package body File_Util is
  ----------------------------------------------------------------------------------------------------
  Function Load_File
  (
    i_File_Id number,
    o_Row     out Files%rowtype
  ) return boolean is
  begin
    select *
      into o_Row
      from Files t
     where t.File_Id = i_File_Id;
    --
    return true;
  exception
    when No_Data_Found then
      return false;
  end;
  ----------------------------------------------------------------------------------------------------
end File_Util;
/
