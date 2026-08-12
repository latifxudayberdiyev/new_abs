create or replace package Mle_Dml is

  -- Author  : AALIJONOV
  -- Created : 16.06.2026 9:11:20
  -- Purpose :
  -------------------------------------------------------------------------------------------------------------
  -- Error code + unga bog'liq template'ning joriy holatini Mle_History'ga
  -- bitta qator qilib yozadi. DELETE uchun o'chirishdan OLDIN chaqirilishi kerak.
  Procedure Log_Error_History(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Action       varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Error_Code(i_Module_Code  varchar2,
                           i_Error_Code   number,
                           i_Message_Code varchar2,
                           i_Description  varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Error_Code(i_Error_Id     number,
                              i_Module_Code  varchar2,
                              i_Error_Code   number,
                              i_Message_Code varchar2,
                              i_Description  varchar2);
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Delete_Error_Code(i_Module_Code  varchar2,
                              i_Message_Code varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Error_Stat(i_User_Id    number,
                           i_Error_Id   number,
                           i_Created_On date);
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Error_Stat(i_Stat_Id    number,
                              i_User_Id    number,
                              i_Error_Id   number,
                              i_Created_On date);
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Fix_Note(i_User_Id    number,
                         i_Error_Id   number,
                         i_Note_Text  varchar2,
                         i_Created_By number,
                         i_Created_On date,
                         i_Is_Sent    varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Fix_Note(i_Note_Id   number,
                            i_Error_Id  number,
                            i_Note_Text varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Fix_Note(i_Note_Id number);
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Note_Reaction(i_Note_Id    number,
                              i_User_Id    number,
                              i_Reaction   varchar2,
                              i_Created_On date);
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Note_Reaction(i_Reaction_Id number,
                                 i_Note_Id     number,
                                 i_User_Id     number,
                                 i_Reaction    varchar2,
                                 i_Created_On  date);
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Note_Reaction(i_Reaction_Id number);
  -------------------------------------------------------------------------------------------------------------  
end Mle_Dml;
/
create or replace package body Mle_Dml is

  -------------------------------------------------------------------------------------------------------------
  Procedure Log_Error_History(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Action       varchar2) is
    v_Error    Mlt_Error_Codes%rowtype;
    v_Template Mlt_Templates%rowtype;
  begin
    select *
      into v_Error
      from Mlt_Error_Codes
     where Module_Code = i_Module_Code
       and Message_Code = i_Message_Code;
    --
    begin
      select *
        into v_Template
        from Mlt_Templates
       where Message_Code = v_Error.Message_Code
       fetch first 1 row only;
    exception
      when No_Data_Found then
        null;
    end;
    --
    insert into Mle_History
      (Log_Id,
       Error_Id,
       Module_Code,
       Error_Code,
       Message_Code,
       Description,
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
      (Mle_History_Seq.Nextval,
       v_Error.Error_Id,
       v_Error.Module_Code,
       v_Error.Error_Code,
       v_Error.Message_Code,
       v_Error.Description,
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
       Nvl(v_Error.Modified_By, Core.User_Env.Get_User_Id),
       Nvl(v_Error.Modified_On, sysdate),
       i_Action,
       sysdate);
  exception
    when No_Data_Found then
      null;
  end Log_Error_History;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Error_Code(i_Module_Code  varchar2,
                           i_Error_Code   number,
                           i_Message_Code varchar2,
                           i_Description  varchar2) is
    v_Row Mlt_Error_Codes%rowtype;
  begin
    v_Row.Error_Id     := mlt_error_codes_seq.Nextval;
    v_Row.Module_Code  := i_Module_Code;
    v_Row.Error_Code   := i_Error_Code;
    v_Row.Message_Code := i_Message_Code;
    v_Row.Description  := i_Description;
    v_Row.Modified_By  := Core.User_Env.Get_User_Id;
    v_Row.Modified_On  := sysdate;
    --
    insert into Mlt_Error_Codes
      (Error_Id,
       Module_Code,
       Error_Code,
       Message_Code,
       Description,
       Modified_By,
       Modified_On)
    values
      (v_Row.Error_Id,
       v_Row.Module_Code,
       v_Row.Error_Code,
       v_Row.Message_Code,
       v_Row.Description,
       v_Row.Modified_By,
       v_Row.Modified_On);
  end Add_Error_Code;
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Error_Code(i_Error_Id     number,
                              i_Module_Code  varchar2,
                              i_Error_Code   number,
                              i_Message_Code varchar2,
                              i_Description  varchar2) is
    v_Row Mlt_Error_Codes%rowtype;
  begin
    v_Row.Error_Id     := i_Error_Id;
    v_Row.Module_Code  := i_Module_Code;
    v_Row.Error_Code   := i_Error_Code;
    v_Row.Message_Code := i_Message_Code;
    v_Row.Description  := i_Description;
    v_Row.Modified_By  := Core.User_Env.Get_User_Id;
    v_Row.Modified_On  := sysdate;
    --
    update Mlt_Error_Codes
       set Message_Code = v_Row.Message_Code,
           Description  = v_Row.Description,
           error_code   = v_Row.Error_Code,
           module_code  = v_Row.Module_Code,
           Modified_By  = v_Row.Modified_By,
           Modified_On  = v_Row.Modified_On
     where error_id = v_Row.Error_Id;
  end Update_Error_Code;
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Error_Code(i_Module_Code  varchar2,
                              i_Message_Code varchar2) is
  begin
    delete from Mlt_Error_Codes
     where Module_Code = i_Module_Code
       and Message_Code = i_Message_Code;
  end Delete_Error_Code;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Error_Stat(i_User_Id    number,
                           i_Error_Id   number,
                           i_Created_On date) is
    PRAGMA AUTONOMOUS_TRANSACTION;
  begin
    insert into Mlt_Error_Stat
      (Stat_Id, User_Id, Error_Id, Created_On)
    values
      (Mlt_Error_Stat_Seq.Nextval, i_User_Id, i_Error_Id, i_Created_On);
    commit;
  end Add_Error_Stat;
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Error_Stat(i_Stat_Id    number,
                              i_User_Id    number,
                              i_Error_Id   number,
                              i_Created_On date) is
  begin
    update Mlt_Error_Stat
       set User_Id    = i_User_Id,
           Error_Id   = i_Error_Id,
           Created_On = i_Created_On
     where Stat_Id = i_Stat_Id;
  end Update_Error_Stat;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Fix_Note(i_User_Id    number,
                         i_Error_Id   number,
                         i_Note_Text  varchar2,
                         i_Created_By number,
                         i_Created_On date,
                         i_Is_Sent    varchar2) is
  begin
    insert into Mlt_Fix_Notes
      (Note_Id,
       User_Id,
       Error_Id,
       Note_Text,
       Created_By,
       Created_On,
       Is_Sent)
    values
      (Mlt_Fix_Notes_Seq.Nextval,
       i_User_Id,
       i_Error_Id,
       i_Note_Text,
       i_Created_By,
       i_Created_On,
       Nvl(i_Is_Sent, 'N'));
  end Add_Fix_Note;
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Fix_Note(i_Note_Id   number,
                            i_Error_Id  number,
                            i_Note_Text varchar2) is
  begin
    update Mlt_Fix_Notes
       set Error_Id = i_Error_Id, Note_Text = i_Note_Text
     where Note_Id = i_Note_Id;
  end Update_Fix_Note;
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Fix_Note(i_Note_Id number) is
  begin
    delete from Mlt_Fix_Notes where Note_Id = i_Note_Id;
  end Delete_Fix_Note;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Note_Reaction(i_Note_Id    number,
                              i_User_Id    number,
                              i_Reaction   varchar2,
                              i_Created_On date) is
  begin
    insert into Mlt_Note_Reactions
      (Reaction_Id, Note_Id, User_Id, Reaction, Created_On)
    values
      (Mlt_Note_Reactions_Seq.Nextval,
       i_Note_Id,
       i_User_Id,
       i_Reaction,
       i_Created_On);
  end Add_Note_Reaction;
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Note_Reaction(i_Reaction_Id number,
                                 i_Note_Id     number,
                                 i_User_Id     number,
                                 i_Reaction    varchar2,
                                 i_Created_On  date) is
  begin
    update Mlt_Note_Reactions
       set Note_Id    = i_Note_Id,
           User_Id    = i_User_Id,
           Reaction   = i_Reaction,
           Created_On = i_Created_On
     where Reaction_Id = i_Reaction_Id;
  end Update_Note_Reaction;
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Note_Reaction(i_Reaction_Id number) is
  begin
    delete from Mlt_Note_Reactions where Reaction_Id = i_Reaction_Id;
  end Delete_Note_Reaction;
  -------------------------------------------------------------------------------------------------------------  
end Mle_Dml;
/
