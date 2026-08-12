create or replace package Mll_Util is
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Label(i_Module_Code  varchar2,
                         i_Message_Code varchar2,
                         i_Is_Raise     boolean := true,
                         o_Label        out Mll_Label_Codes%rowtype);
  -------------------------------------------------------------------------------------------------------------
  Function Exists_Label(i_Module_Code varchar2, i_Message_Code varchar2)
    return boolean;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Label_Id(i_Label_Id number,
                                    o_List     out Core.Arraylist);
  -------------------------------------------------------------------------------------------------------------
/*Procedure Save_Label_With_Template_Dev
  (
    i_Message_Code  varchar2,
    i_Description   varchar2,
    i_Param_Count   number,
    i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
    --
    i_Message_Mask_Lang1  varchar2,
    i_Message_Mask_Lang2  varchar2,
    i_Message_Mask_Lang3  varchar2,
    i_Message_Mask_Lang4  varchar2,
    i_Message_Mask_Lang5  varchar2,
    i_Message_Mask_Lang6  varchar2,
    i_Message_Mask_Lang7  varchar2,
    i_Message_Mask_Lang8  varchar2,
    i_Message_Mask_Lang9  varchar2,
    i_Message_Mask_Lang10 varchar2,
    --
    i_Module_Code varchar2,
    i_Field_Hint  varchar2 := null,
    o_Code        out number,
    o_Msg         out varchar2
  );
  */
------------------------------------------------------------------------------------------------------------- 
/*Function Get_Label
  (
    i_Module_Code  varchar2,
    i_Message_Code varchar2
  ) return varchar2;
  */
-------------------------------------------------------------------------------------------------------------
end Mll_Util;
/
create or replace package body Mll_Util is
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Label(i_Module_Code  varchar2,
                         i_Message_Code varchar2,
                         i_Is_Raise     boolean := true,
                         o_Label        out Mll_Label_Codes%rowtype) is
  begin
    select *
      into o_Label
      from Mll_Label_Codes
     where Module_Code = i_Module_Code
       and Message_Code = i_Message_Code;
    --
  exception
    when No_Data_Found then
      if i_Is_Raise then
        raise;
      end if;
  end Select_Label;
  -------------------------------------------------------------------------------------------------------------
  Function Exists_Label(i_Module_Code varchar2, i_Message_Code varchar2)
    return boolean is
    v_Label Mll_Label_Codes%rowtype;
  begin
    Select_Label(i_Module_Code  => i_Module_Code,
                 i_Message_Code => i_Message_Code,
                 i_Is_Raise     => false,
                 o_Label        => v_Label);
    return v_Label.Label_Id is not null;
  end Exists_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Label_Id(i_Label_Id number,
                                    o_List     out Core.Arraylist) is
    v_Row Core.Hash_t;
  begin
    o_List := Core.Arraylist();
    --
    for r in (select *
                from Mll_History
               where Label_Id = i_Label_Id
               order by Action_Date desc, Log_Id desc) loop
      v_Row := Core.Hash_t();
      v_Row.Put('log_id', r.Log_Id);
      v_Row.Put('action', r.Action);
      v_Row.Put('action_date', r.Action_Date);
      v_Row.Put('modified_by', r.Modified_By);
      v_Row.Put('modified_on', r.Modified_On);
      --- 
      v_Row.Put('label_id', r.Label_Id);
      v_Row.Put('module_code', r.Module_Code);
      v_Row.Put('message_code', r.Message_Code);
      v_Row.Put('description', r.Description);
      v_Row.Put('field_hint', r.Field_Hint);
      --- 
      v_Row.Put('template_id', r.Template_Id);
      v_Row.Put('template_description', r.Template_Description);
      v_Row.Put('param_count', r.Param_Count);
      v_Row.Put('format_string', r.Format_String);
      v_Row.Put('message_mask_lang1', r.Message_Mask_Lang1);
      v_Row.Put('message_mask_lang2', r.Message_Mask_Lang2);
      v_Row.Put('message_mask_lang3', r.Message_Mask_Lang3);
      v_Row.Put('message_mask_lang4', r.Message_Mask_Lang4);
      v_Row.Put('message_mask_lang5', r.Message_Mask_Lang5);
      v_Row.Put('message_mask_lang6', r.Message_Mask_Lang6);
      v_Row.Put('message_mask_lang7', r.Message_Mask_Lang7);
      v_Row.Put('message_mask_lang8', r.Message_Mask_Lang8);
      v_Row.Put('message_mask_lang9', r.Message_Mask_Lang9);
      v_Row.Put('message_mask_lang10', r.Message_Mask_Lang10);
      --
      o_List.Push(v_Row);
    end loop;
  end Get_History_By_Label_Id;
  -------------------------------------------------------------------------------------------------------------
/* Procedure Save_Label_With_Template_Dev
  (
    i_Message_Code  varchar2,
    i_Description   varchar2,
    i_Param_Count   number,
    i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
    --
    i_Message_Mask_Lang1  varchar2,
    i_Message_Mask_Lang2  varchar2,
    i_Message_Mask_Lang3  varchar2,
    i_Message_Mask_Lang4  varchar2,
    i_Message_Mask_Lang5  varchar2,
    i_Message_Mask_Lang6  varchar2,
    i_Message_Mask_Lang7  varchar2,
    i_Message_Mask_Lang8  varchar2,
    i_Message_Mask_Lang9  varchar2,
    i_Message_Mask_Lang10 varchar2,
    --
    i_Module_Code varchar2,
    i_Field_Hint  varchar2 := null,
    o_Code        out number,
    o_Msg         out varchar2
  ) is
  begin
    mll_kernel.Save_Label_With_Template_DEV(i_Message_Code        => i_Message_Code,
                                            i_Description         => i_Description,
                                            i_Param_Count         => i_Param_Count,
                                            i_Format_String       => i_Format_String,
                                            i_Message_Mask_Lang1  => i_Message_Mask_Lang1,
                                            i_Message_Mask_Lang2  => i_Message_Mask_Lang2,
                                            i_Message_Mask_Lang3  => i_Message_Mask_Lang3,
                                            i_Message_Mask_Lang4  => i_Message_Mask_Lang4,
                                            i_Message_Mask_Lang5  => i_Message_Mask_Lang5,
                                            i_Message_Mask_Lang6  => i_Message_Mask_Lang6,
                                            i_Message_Mask_Lang7  => i_Message_Mask_Lang7,
                                            i_Message_Mask_Lang8  => i_Message_Mask_Lang8,
                                            i_Message_Mask_Lang9  => i_Message_Mask_Lang9,
                                            i_Message_Mask_Lang10 => i_Message_Mask_Lang10,
                                            i_Module_Code         => i_Module_Code,
                                            i_Field_Hint          => i_Field_Hint,
                                            o_Code                => o_Code,
                                            o_Msg                 => o_Msg );
  end;
  */
-------------------------------------------------------------------------------------------------------------
/*Function Get_Label
  (
    i_Module_Code  varchar2,
    i_Message_Code varchar2
  ) return varchar2 is
    v_Label Mll_Label_Codes%rowtype;
  begin
    Select_Label(i_Module_Code  => i_Module_Code,
                 i_Message_Code => i_Message_Code,
                 o_Label        => v_Label);
    return v_Label.Description;
  end Get_Label;
  */
------------------------------------------------------------------------------------------------------------- 
end Mll_Util;
/
