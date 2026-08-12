create or replace package Mll_Dml is
  -------------------------------------------------------------------------------------------------------------
  -- Label + unga bog'liq template'ning joriy holatini Mll_History'ga bitta
  -- qator qilib yozadi. DELETE uchun o'chirishdan OLDIN chaqirilishi kerak.
  Procedure Log_Label_History(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Action       varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Label(i_Module_Code  varchar2,
                      i_Message_Code varchar2,
                      i_Description  varchar2,
                      i_Field_Hint   varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Label(i_Label_Id     number,
                         i_Module_Code  varchar2,
                         i_Message_Code varchar2,
                         i_Description  varchar2,
                         i_Field_Hint   varchar2);
  -------------------------------------------------------------------------------------------------------------  
  Procedure Delete_Label(i_Module_Code varchar2, i_Message_Code varchar2);
  -------------------------------------------------------------------------------------------------------------    
end Mll_Dml;
/
create or replace package body Mll_Dml is
  -------------------------------------------------------------------------------------------------------------
  Procedure Log_Label_History(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Action       varchar2) is
    v_Label    Mll_Label_Codes%rowtype;
    v_Template Mlt_Templates%rowtype;
  begin
    select *
      into v_Label
      from Mll_Label_Codes
     where Module_Code = i_Module_Code
       and Message_Code = i_Message_Code;
    --
    begin
      select *
        into v_Template
        from Mlt_Templates
       where Message_Code = v_Label.Message_Code
       fetch first 1 row only;
    exception
      when No_Data_Found then
        null;
    end;
    --
    insert into Mll_History
      (Log_Id,
       Label_Id,
       Module_Code,
       Message_Code,
       Description,
       Field_Hint,
       Template_Id,
       Template_Description,
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
       Modified_On,
       Action,
       Action_Date)
    values
      (Mll_History_Seq.Nextval,
       v_Label.Label_Id,
       v_Label.Module_Code,
       v_Label.Message_Code,
       v_Label.Description,
       v_Label.Field_Hint,
       v_Template.Template_Id,
       v_Template.Description,
       v_Template.Param_Count,
       v_Template.Format_String,
       v_Template.Message_Mask_Lang1,
       v_Template.Message_Mask_Lang2,
       v_Template.Message_Mask_Lang3,
       v_Template.Message_Mask_Lang4,
       v_Template.Message_Mask_Lang5,
       v_Template.Message_Mask_Lang6,
       v_Template.Message_Mask_Lang7,
       v_Template.Message_Mask_Lang8,
       v_Template.Message_Mask_Lang9,
       v_Template.Message_Mask_Lang10,
       Nvl(v_Label.Modified_By, Core.User_Env.Get_User_Id),
       Nvl(v_Label.Modified_On, sysdate),
       i_Action,
       sysdate);
  exception
    when No_Data_Found then
      null;
  end Log_Label_History;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Label(i_Module_Code  varchar2,
                      i_Message_Code varchar2,
                      i_Description  varchar2,
                      i_Field_Hint   varchar2) is
    v_Row Mll_Label_Codes%rowtype;
  begin
    v_Row.Label_Id     := Mll_Label_Codes_Seq.Nextval;
    v_Row.Module_Code  := i_Module_Code;
    v_Row.Message_Code := i_Message_Code;
    v_Row.Description  := i_Description;
    v_Row.Field_Hint   := i_Field_Hint;
    v_Row.Modified_By  := Core.User_Env.Get_User_Id;
    v_Row.Modified_On  := sysdate;
    --
    insert into Mll_Label_Codes
      (Label_Id,
       Module_Code,
       Message_Code,
       Description,
       Field_Hint,
       Modified_By,
       Modified_On)
    values
      (v_Row.Label_Id,
       v_Row.Module_Code,
       v_Row.Message_Code,
       v_Row.Description,
       v_Row.Field_Hint,
       v_Row.Modified_By,
       v_Row.Modified_On);
  end Add_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Label(i_Label_id     number,
                         i_Module_Code  varchar2,
                         i_Message_Code varchar2,
                         i_Description  varchar2,
                         i_Field_Hint   varchar2) is
    v_Row Mll_Label_Codes%rowtype;
  begin
    v_Row.Label_Id     := i_Label_id;
    v_Row.Module_Code  := i_Module_Code;
    v_Row.Message_Code := i_Message_Code;
    v_Row.Description  := i_Description;
    v_Row.Field_Hint   := i_Field_Hint;
    v_Row.Modified_By  := Core.User_Env.Get_User_Id;
    v_Row.Modified_On  := sysdate;
    --
    update Mll_Label_Codes
       set Module_Code  = v_Row.Module_Code,
           Message_Code = v_Row.Message_Code,
           Description  = v_Row.Description,
           Field_Hint   = v_Row.Field_Hint,
           Modified_By  = v_Row.Modified_By,
           Modified_On  = v_Row.Modified_On
     where Label_Id = v_Row.Label_Id;
  end Update_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Label(i_Module_Code varchar2, i_Message_Code varchar2) is
  begin
    delete from Mll_Label_Codes
     where Module_Code = i_Module_Code
       and Message_Code = i_Message_Code;
  end Delete_Label;
  -------------------------------------------------------------------------------------------------------------
end Mll_Dml;
/
