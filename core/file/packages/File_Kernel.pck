
create or replace package File_Kernel is

-- Author  : B.URALOV
-- Purpose : Files - biznes-mantiq (Sm_Api'dan chaqiriladi).

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

end File_Kernel;
/
create or replace package body File_Kernel is
  ----------------------------------------------------------------------------------------------------
  Procedure Model_File
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Row  Files%rowtype;
    v_Data Core.Hash_t := Core.Hash_t();
  begin
    v_Row.File_Id := Io_Hash.Get_Number('file_id');
    --
    if File_Util.Load_File(i_File_Id => v_Row.File_Id, o_Row => v_Row) then
      v_Data.Put('file_id', v_Row.File_Id);
      v_Data.Put('file_token', v_Row.File_Token);
      v_Data.Put('doc_type', v_Row.Doc_Type);
      v_Data.Put('file_name', v_Row.File_Name);
      -- To'liq havola (host bilan) chaqiruvchi (JSP/tashqi qatlam) tomonidan yig'iladi,
      -- bu yerda faqat fayl serveridagi nisbiy manzil qaytariladi.
      v_Data.Put('file_url', v_Row.File_Url);
      v_Data.Put('state', v_Row.State);
      v_Data.Put('description', v_Row.Description);
      --
      Io_Hash.Put('data', v_Data);
      --
      o_Code := 0;
      o_Msg  := '';
    else
      o_Code := 1;
      o_Msg  := 'Bu ID:' || v_Row.File_Id || ' bilan FILE topilmadi!';
    end if;
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Substr(sqlerrm, 1, 500);
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Save_File
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Row       Files%rowtype;
    v_Cache     Core.Hash_t := Io_Hash.Get_Hash_t('sm_cache');
    v_Is_Create boolean;
  begin
    v_Is_Create       := (v_Cache.Get_Optional_Varchar2('is_create') = 'Y');
    v_Row.File_Id     := Io_Hash.Get_Optional_Number('file_id');
    v_Row.File_Token  := Io_Hash.Get_Optional_Varchar2('file_token');
    v_Row.Doc_Type    := Io_Hash.Get_Number('doc_type');
    v_Row.File_Name   := Io_Hash.Get_Varchar2('file_name');
    v_Row.Begin_Date  := Io_Hash.Get_Optional_Date('begin_date', Core.User_Env.Get_Format_Date);
    v_Row.End_Date    := Io_Hash.Get_Optional_Date('end_date', Core.User_Env.Get_Format_Date);
    v_Row.State       := Nvl(Io_Hash.Get_Optional_Number('state'), File_Const.c_State_Entered);
    v_Row.Description := Io_Hash.Get_Optional_Varchar2('description');
    v_Row.File_Url    := Io_Hash.Get_Optional_Varchar2('file_url');
    --
    if v_Is_Create then
      v_Row.File_Id := v_Cache.Get_Number('file_id');
      --
      File_Dml.Insert_File(v_Row);
    else
      File_Dml.Update_File(v_Row);
    end if;
    --
    o_Code := 0;
    o_Msg  := '';
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Substr(sqlerrm, 1, 500);
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Del_File
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_File_Id number;
  begin
    v_File_Id := Io_Hash.Get_Number('file_id');
    --
    File_Dml.Delete_File(i_File_Id => v_File_Id);
    --
    o_Code := 0;
    o_Msg  := '';
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Substr(sqlerrm, 1, 500);
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
end File_Kernel;
/
