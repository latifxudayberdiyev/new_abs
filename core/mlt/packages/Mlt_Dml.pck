create or replace package Mlt_Dml is

  -- Author  : AZIZBEK
  -- Created : 15.04.2026 10:01:04
  -- Purpose : Multi langugage tools DML
  -------------------------------------------------------------------------------------------------------------
  Function Is_Value_Changed(i_Old_Value in varchar2,
                            i_New_Value in varchar2) return boolean;
  -------------------------------------------------------------------------------------------------------------
  Function Is_Value_Changed(i_Old_Value in number, i_New_Value in number)
    return boolean;
  -------------------------------------------------------------------------------------------------------------    
  Procedure Add_Template(i_Message_Code        varchar2,
                         i_Description         varchar2,
                         i_Param_Count         number,
                         i_Format_String       varchar2,
                         i_Message_Mask_Lang1  varchar2,
                         i_Message_Mask_Lang2  varchar2,
                         i_Message_Mask_Lang3  varchar2,
                         i_Message_Mask_Lang4  varchar2,
                         i_Message_Mask_Lang5  varchar2,
                         i_Message_Mask_Lang6  varchar2,
                         i_Message_Mask_Lang7  varchar2,
                         i_Message_Mask_Lang8  varchar2,
                         i_Message_Mask_Lang9  varchar2,
                         i_Message_Mask_Lang10 varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Template(i_Template_Id         number,
                            i_Description         varchar2,
                            i_Param_Count         number,
                            i_Format_String       varchar2,
                            i_Message_Mask_Lang1  varchar2,
                            i_Message_Mask_Lang2  varchar2,
                            i_Message_Mask_Lang3  varchar2,
                            i_Message_Mask_Lang4  varchar2,
                            i_Message_Mask_Lang5  varchar2,
                            i_Message_Mask_Lang6  varchar2,
                            i_Message_Mask_Lang7  varchar2,
                            i_Message_Mask_Lang8  varchar2,
                            i_Message_Mask_Lang9  varchar2,
                            i_Message_Mask_Lang10 varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Template(i_Template_Id number);
  -------------------------------------------------------------------------------------------------------------
end Mlt_Dml;
/
create or replace package body Mlt_Dml is
  -------------------------------------------------------------------------------------------------------------
  Function Is_Value_Changed(i_Old_Value in varchar2,
                            i_New_Value in varchar2) return boolean is
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
  end Is_Value_Changed;
  -------------------------------------------------------------------------------------------------------------
  Function Is_Value_Changed(i_Old_Value in number, i_New_Value in number)
    return boolean is
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
  end Is_Value_Changed;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Template(i_Message_Code        varchar2,
                         i_Description         varchar2,
                         i_Param_Count         number,
                         i_Format_String       varchar2,
                         i_Message_Mask_Lang1  varchar2,
                         i_Message_Mask_Lang2  varchar2,
                         i_Message_Mask_Lang3  varchar2,
                         i_Message_Mask_Lang4  varchar2,
                         i_Message_Mask_Lang5  varchar2,
                         i_Message_Mask_Lang6  varchar2,
                         i_Message_Mask_Lang7  varchar2,
                         i_Message_Mask_Lang8  varchar2,
                         i_Message_Mask_Lang9  varchar2,
                         i_Message_Mask_Lang10 varchar2) is
    v_Row Mlt_Templates%rowtype;
  begin
    v_Row.Template_Id         := Mlt_Templates_Seq.Nextval;
    v_Row.Message_Code        := i_Message_Code;
    v_Row.Description         := i_Description;
    v_Row.Param_Count         := i_Param_Count;
    v_Row.Format_String       := i_Format_String;
    v_Row.Message_Mask_Lang1  := i_Message_Mask_Lang1;
    v_Row.Message_Mask_Lang2  := i_Message_Mask_Lang2;
    v_Row.Message_Mask_Lang3  := i_Message_Mask_Lang3;
    v_Row.Message_Mask_Lang4  := i_Message_Mask_Lang4;
    v_Row.Message_Mask_Lang5  := i_Message_Mask_Lang5;
    v_Row.Message_Mask_Lang6  := i_Message_Mask_Lang6;
    v_Row.Message_Mask_Lang7  := i_Message_Mask_Lang7;
    v_Row.Message_Mask_Lang8  := i_Message_Mask_Lang8;
    v_Row.Message_Mask_Lang9  := i_Message_Mask_Lang9;
    v_Row.Message_Mask_Lang10 := i_Message_Mask_Lang10;
    v_Row.Modified_By         := Core.User_Env.Get_User_Id;
    v_Row.Modified_On         := sysdate;
    --
    insert into Mlt_Templates
      (Template_Id,
       Message_Code,
       Description,
       Param_Count,
       Format_String,
       Message_Mask_Lang1,
       Message_Mask_Lang2,
       Message_Mask_Lang3,
       Message_Mask_Lang4,
       Message_Mask_Lang5,
       Message_Mask_Lang6,
       Message_Mask_Lang7,
       Message_Mask_Lang8,
       Message_Mask_Lang9,
       Message_Mask_Lang10,
       Modified_By,
       Modified_On)
    values
      (v_Row.Template_Id,
       v_Row.Message_Code,
       v_Row.Description,
       v_Row.Param_Count,
       v_Row.Format_String,
       v_Row.Message_Mask_Lang1,
       v_Row.Message_Mask_Lang2,
       v_Row.Message_Mask_Lang3,
       v_Row.Message_Mask_Lang4,
       v_Row.Message_Mask_Lang5,
       v_Row.Message_Mask_Lang6,
       v_Row.Message_Mask_Lang7,
       v_Row.Message_Mask_Lang8,
       v_Row.Message_Mask_Lang9,
       v_Row.Message_Mask_Lang10,
       v_Row.Modified_By,
       v_Row.Modified_On);
  end Add_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Template(i_Template_Id         number,
                            i_Description         varchar2,
                            i_Param_Count         number,
                            i_Format_String       varchar2,
                            i_Message_Mask_Lang1  varchar2,
                            i_Message_Mask_Lang2  varchar2,
                            i_Message_Mask_Lang3  varchar2,
                            i_Message_Mask_Lang4  varchar2,
                            i_Message_Mask_Lang5  varchar2,
                            i_Message_Mask_Lang6  varchar2,
                            i_Message_Mask_Lang7  varchar2,
                            i_Message_Mask_Lang8  varchar2,
                            i_Message_Mask_Lang9  varchar2,
                            i_Message_Mask_Lang10 varchar2) is
    v_Old_Row Mlt_Templates%rowtype;
    v_New_Row Mlt_Templates%rowtype;
  begin
    select *
      into v_Old_Row
      from Mlt_Templates
     where Template_Id = i_Template_Id;
    --
    v_New_Row                     := v_Old_Row;
    v_New_Row.Description         := i_Description;
    v_New_Row.Param_Count         := i_Param_Count;
    v_New_Row.Format_String       := i_Format_String;
    v_New_Row.Message_Mask_Lang1  := i_Message_Mask_Lang1;
    v_New_Row.Message_Mask_Lang2  := i_Message_Mask_Lang2;
    v_New_Row.Message_Mask_Lang3  := i_Message_Mask_Lang3;
    v_New_Row.Message_Mask_Lang4  := i_Message_Mask_Lang4;
    v_New_Row.Message_Mask_Lang5  := i_Message_Mask_Lang5;
    v_New_Row.Message_Mask_Lang6  := i_Message_Mask_Lang6;
    v_New_Row.Message_Mask_Lang7  := i_Message_Mask_Lang7;
    v_New_Row.Message_Mask_Lang8  := i_Message_Mask_Lang8;
    v_New_Row.Message_Mask_Lang9  := i_Message_Mask_Lang9;
    v_New_Row.Message_Mask_Lang10 := i_Message_Mask_Lang10;
    --
    if Is_Value_Changed(v_Old_Row.Description, v_New_Row.Description) or
       Is_Value_Changed(v_Old_Row.Param_Count, v_New_Row.Param_Count) or
       Is_Value_Changed(v_Old_Row.Format_String, v_New_Row.Format_String) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang1,
                        v_New_Row.Message_Mask_Lang1) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang2,
                        v_New_Row.Message_Mask_Lang2) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang3,
                        v_New_Row.Message_Mask_Lang3) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang4,
                        v_New_Row.Message_Mask_Lang4) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang5,
                        v_New_Row.Message_Mask_Lang5) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang6,
                        v_New_Row.Message_Mask_Lang6) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang7,
                        v_New_Row.Message_Mask_Lang7) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang8,
                        v_New_Row.Message_Mask_Lang8) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang9,
                        v_New_Row.Message_Mask_Lang9) or
       Is_Value_Changed(v_Old_Row.Message_Mask_Lang10,
                        v_New_Row.Message_Mask_Lang10) then
      --
      v_New_Row.Modified_By := Core.User_Env.Get_User_Id;
      v_New_Row.Modified_On := sysdate;
      --
      update Mlt_Templates t
         set t.Description         = v_New_Row.Description,
             t.Param_Count         = v_New_Row.Param_Count,
             t.Format_String       = v_New_Row.Format_String,
             t.Message_Mask_Lang1  = v_New_Row.Message_Mask_Lang1,
             t.Message_Mask_Lang2  = v_New_Row.Message_Mask_Lang2,
             t.Message_Mask_Lang3  = v_New_Row.Message_Mask_Lang3,
             t.Message_Mask_Lang4  = v_New_Row.Message_Mask_Lang4,
             t.Message_Mask_Lang5  = v_New_Row.Message_Mask_Lang5,
             t.Message_Mask_Lang6  = v_New_Row.Message_Mask_Lang6,
             t.Message_Mask_Lang7  = v_New_Row.Message_Mask_Lang7,
             t.Message_Mask_Lang8  = v_New_Row.Message_Mask_Lang8,
             t.Message_Mask_Lang9  = v_New_Row.Message_Mask_Lang9,
             t.Message_Mask_Lang10 = v_New_Row.Message_Mask_Lang10,
             t.Modified_By         = v_New_Row.Modified_By,
             t.Modified_On         = v_New_Row.Modified_On
       where t.Template_Id = i_Template_Id;
    end if;
  end Update_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Template(i_Template_Id number) is
  begin
    delete from Mlt_Templates where Template_Id = i_Template_Id;
  end Delete_Template;
  -------------------------------------------------------------------------------------------------------------

end Mlt_Dml;
/
