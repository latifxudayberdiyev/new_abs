
create or replace package File_Dml is

-- Author  : B.URALOV
-- Purpose : Files - insert/update/delete va tarix (_H) yozuvlari.

Procedure Insert_File(Io_Row in out Files%rowtype);

Procedure Update_File(Io_Row in out Files%rowtype);

Procedure Delete_File(i_File_Id number);

end File_Dml;
/
create or replace package body File_Dml is
  ----------------------------------------------------------------------------------------------------
  Function Is_Value_Changed
  (
    i_Old_Value in varchar2,
    i_New_Value in varchar2
  ) return boolean is
  begin
    if i_Old_Value is null and i_New_Value is null then
      return false;
    elsif i_Old_Value is null or i_New_Value is null then
      return true;
    elsif i_Old_Value != i_New_Value then
      return true;
    else
      return false;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Log_File
  (
    i_Row    in Files%rowtype,
    i_Action in varchar2
  ) is
    v_Row Files_H%rowtype;
  begin
    v_Row.Log_Id      := Files_H_Sq.nextval;
    v_Row.File_Id     := i_Row.File_Id;
    v_Row.File_Token  := i_Row.File_Token;
    v_Row.Doc_Type    := i_Row.Doc_Type;
    v_Row.File_Name   := i_Row.File_Name;
    v_Row.Begin_Date  := i_Row.Begin_Date;
    v_Row.End_Date    := i_Row.End_Date;
    v_Row.State       := i_Row.State;
    v_Row.Created_By  := i_Row.Created_By;
    v_Row.Created_On  := i_Row.Created_On;
    v_Row.Modified_By := i_Row.Modified_By;
    v_Row.Modified_On := i_Row.Modified_On;
    v_Row.File_Url    := i_Row.File_Url;
    v_Row.Description := i_Row.Description;
    v_Row.Action      := i_Action;
    v_Row.Action_Date := sysdate;
    --
    insert into Files_H
    values v_Row;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Insert_File(Io_Row in out Files%rowtype) is
  begin
    Io_Row.Created_On  := sysdate;
    Io_Row.Created_By  := Core.User_Env.Get_User_Id;
    Io_Row.Modified_On := sysdate;
    Io_Row.Modified_By := Core.User_Env.Get_User_Id;
    --
    insert into Files
    values Io_Row;
    --
    Log_File(Io_Row, File_Const.c_Log_Insert);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Update_File(Io_Row in out Files%rowtype) is
    v_Old_Row Files%rowtype;
  begin
    if File_Util.Load_File(i_File_Id => Io_Row.File_Id, o_Row => v_Old_Row) then
      if Is_Value_Changed(v_Old_Row.File_Token, Io_Row.File_Token) or
         Is_Value_Changed(v_Old_Row.Doc_Type, Io_Row.Doc_Type) or
         Is_Value_Changed(v_Old_Row.File_Name, Io_Row.File_Name) or
         Is_Value_Changed(v_Old_Row.Begin_Date, Io_Row.Begin_Date) or
         Is_Value_Changed(v_Old_Row.End_Date, Io_Row.End_Date) or
         Is_Value_Changed(v_Old_Row.State, Io_Row.State) or
         Is_Value_Changed(v_Old_Row.Description, Io_Row.Description) or
         Is_Value_Changed(v_Old_Row.File_Url, Io_Row.File_Url) then
        Io_Row.Created_By  := v_Old_Row.Created_By;
        Io_Row.Created_On  := v_Old_Row.Created_On;
        Io_Row.Modified_On := sysdate;
        Io_Row.Modified_By := Core.User_Env.Get_User_Id;
        --
        update Files t
           set t.File_Token  = Io_Row.File_Token,
               t.Doc_Type    = Io_Row.Doc_Type,
               t.File_Name   = Io_Row.File_Name,
               t.Begin_Date  = Io_Row.Begin_Date,
               t.End_Date    = Io_Row.End_Date,
               t.State       = Io_Row.State,
               t.File_Url    = Io_Row.File_Url,
               t.Description = Io_Row.Description,
               t.Modified_By = Io_Row.Modified_By,
               t.Modified_On = Io_Row.Modified_On
         where t.File_Id = Io_Row.File_Id;
        --
        Log_File(Io_Row, File_Const.c_Log_Update);
      end if;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Delete_File(i_File_Id number) is
    v_Row Files%rowtype;
  begin
    if File_Util.Load_File(i_File_Id => i_File_Id, o_Row => v_Row) then
      v_Row.Modified_On := sysdate;
      v_Row.Modified_By := Core.User_Env.Get_User_Id;
      --
      Log_File(v_Row, File_Const.c_Log_Delete);
      --
      delete from Files t
       where t.File_Id = i_File_Id;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
end File_Dml;
/
