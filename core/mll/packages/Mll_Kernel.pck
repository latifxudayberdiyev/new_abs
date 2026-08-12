create or replace package Mll_Kernel is
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label(Io_Hash in out nocopy Core.Hash_t,
                       o_Code  out number,
                       o_Msg   out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Label(Io_Hash in out nocopy Core.Hash_t,
                         o_Code  out number,
                         o_Msg   out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label_With_Template(Io_Hash   in out nocopy Core.Hash_t,
                                     o_Code    out number,
                                     o_Msg     out varchar2,
                                     o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label_With_Template_DEV(i_Message_Code  varchar2,
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
                                         o_Msg         out varchar2);
  -------------------------------------------------------------------------------------------------------------   
  Procedure Get_Label(Io_Hash in out nocopy Core.Hash_t,
                      o_Code  out number,
                      o_Msg   out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Label_Id(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
end Mll_Kernel;
/
create or replace package body Mll_Kernel is
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label(Io_Hash in out nocopy Core.Hash_t,
                       o_Code  out number,
                       o_Msg   out varchar2) is
    v_Data      Core.Hash_t := Io_Hash;
    v_Cache     Core.Hash_t;
    v_Is_Create boolean;
    --
    v_Module_Code  varchar2(10);
    v_Message_Code varchar2(100);
    v_Description  varchar2(1000);
    v_Field_Hint   varchar2(1000);
    v_Label        Mll_Label_Codes%rowtype;
    --
    v_Action varchar2(20);
  begin
    v_Cache     := Io_Hash.Get_Hash_t('sm_cache');
    v_Is_Create := Nvl(v_Cache.Get_Optional_Varchar2('is_create', 'Y'), 'Y') = 'Y';
    --
    v_Module_Code  := v_Data.Get_Varchar2('module_code');
    v_Message_Code := v_Data.Get_Varchar2('message_code');
    v_Description  := v_Data.Get_Varchar2('description');
    v_Field_Hint   := v_Data.Get_Optional_Varchar2('field_hint');
    --
    if v_Module_Code is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'MODULE_CODE_REQUIRED',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    if v_Message_Code is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'MESSAGE_CODE_REQUIRED',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    if v_Description is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'DESCRIPTION_REQUIRED',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    Mll_Util.Select_Label(i_Module_Code  => v_Module_Code,
                          i_Message_Code => v_Message_Code,
                          i_Is_Raise     => false,
                          o_Label        => v_Label);
    --
    if v_Is_Create then
      if v_Label.Label_Id is not null then
        Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                   i_Message_Code => 'ALREADY_EXISTS',
                                   i_Params       => Array_Varchar2(v_Message_Code),
                                   o_Code         => o_Code,
                                   o_Msg          => o_Msg);
        return;
      end if;
      --
      Mll_Dml.Add_Label(i_Module_Code  => v_Module_Code,
                        i_Message_Code => v_Message_Code,
                        i_Description  => v_Description,
                        i_Field_Hint   => v_Field_Hint);
      --
      Mll_Dml.Log_Label_History(i_Module_Code  => v_Module_Code,
                                i_Message_Code => v_Message_Code,
                                i_Action       => 'INSERT');
      v_Action := 'CREATED';
    else
      if v_Label.Label_Id is null then
        Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                   i_Message_Code => 'NOT_FOUND',
                                   i_Params       => Array_Varchar2(v_Message_Code),
                                   o_Code         => o_Code,
                                   o_Msg          => o_Msg);
        return;
      end if;
      Mll_Dml.Update_Label(i_Label_Id     => v_Label.Label_Id,
                           i_Module_Code  => v_Module_Code,
                           i_Message_Code => v_Message_Code,
                           i_Description  => v_Description,
                           i_Field_Hint   => v_Field_Hint);
      --
      Mll_Dml.Log_Label_History(i_Module_Code  => v_Module_Code,
                                i_Message_Code => v_Message_Code,
                                i_Action       => 'UPDATE');
      v_Action := 'UPDATED';
    end if;
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => case
                                                   when v_Action = 'CREATED' then
                                                    'SUCCESS'
                                                   else
                                                    'SUCCESS'
                                                 end,
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end Save_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Label(Io_Hash in out nocopy Core.Hash_t,
                         o_Code  out number,
                         o_Msg   out varchar2) is
    v_Data         Core.Hash_t := Io_Hash;
    v_Module_Code  varchar2(10);
    v_Message_Code varchar2(100);
    v_Label        Mll_Label_Codes%rowtype;
  begin
    v_Module_Code  := v_Data.Get_Varchar2('module_code');
    v_Message_Code := v_Data.Get_Varchar2('message_code');
    --
    Mll_Util.Select_Label(i_Module_Code  => v_Module_Code,
                          i_Message_Code => v_Message_Code,
                          i_Is_Raise     => false,
                          o_Label        => v_Label);
    --
    if v_Label.Label_Id is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'NOT_FOUND',
                                 i_Params       => Array_Varchar2(v_Message_Code),
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    -- tarix o'chirishdan OLDIN yoziladi (keyin ma'lumot qolmaydi)
    Mll_Dml.Log_Label_History(i_Module_Code  => v_Module_Code,
                              i_Message_Code => v_Message_Code,
                              i_Action       => 'DELETE');
    --
    Mll_Dml.Delete_Label(i_Module_Code  => v_Module_Code,
                         i_Message_Code => v_Message_Code);
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end Delete_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label_With_Template(Io_Hash   in out nocopy Core.Hash_t,
                                     o_Code    out number,
                                     o_Msg     out varchar2,
                                     o_Ora_Msg out varchar2) is
    v_Data         Core.Hash_t := Io_Hash;
    v_Label_Id     number;
    v_Module_Code  varchar2(10);
    v_Message_Code varchar2(100);
    --
    v_Description   varchar2(500);
    v_Field_Hint    varchar2(1000);
    v_Param_Count   number;
    v_Format_String varchar2(10);
    --
    v_Masks Core.Array_Varchar2;
    --
    v_L1  varchar2(4000);
    v_L2  varchar2(4000);
    v_L3  varchar2(4000);
    v_L4  varchar2(4000);
    v_L5  varchar2(4000);
    v_L6  varchar2(4000);
    v_L7  varchar2(4000);
    v_L8  varchar2(4000);
    v_L9  varchar2(4000);
    v_L10 varchar2(4000);
    --
    v_Template Mlt_Templates%rowtype;
    v_Label    Mll_Label_Codes%rowtype;
    --v_Action   varchar2(20);
  begin
    v_Label_Id      := v_Data.Get_Optional_Number('label_id');
    v_Module_Code   := v_Data.Get_Varchar2('module_code');
    v_Message_Code  := v_Data.Get_Varchar2('message_code');
    v_Description   := v_Data.Get_Varchar2('description');
    v_Field_Hint    := v_Data.Get_Optional_Varchar2('field_hint');
    v_Param_Count   := v_Data.Get_Number('param_count');
    v_Format_String := Nvl(v_Data.Get_Optional_Varchar2('format_string'),
                           '$');
    v_Masks         := v_Data.Get_Array_Varchar2('message_masks');
    if v_Masks is not null then
      for i in 1 .. Least(v_Masks.Count, 10) loop
        case i
          when 1 then
            v_L1 := v_Masks(i);
          when 2 then
            v_L2 := v_Masks(i);
          when 3 then
            v_L3 := v_Masks(i);
          when 4 then
            v_L4 := v_Masks(i);
          when 5 then
            v_L5 := v_Masks(i);
          when 6 then
            v_L6 := v_Masks(i);
          when 7 then
            v_L7 := v_Masks(i);
          when 8 then
            v_L8 := v_Masks(i);
          when 9 then
            v_L9 := v_Masks(i);
          when 10 then
            v_L10 := v_Masks(i);
        end case;
      end loop;
    end if;
    Mlt_Util.Select_With_Message_Code(i_Message_Code => v_Message_Code,
                                      i_Is_Raise     => false,
                                      o_Template     => v_Template);
    Mll_Util.Select_Label(i_Module_Code  => v_Module_Code,
                          i_Message_Code => v_Message_Code,
                          i_Is_Raise     => false,
                          o_Label        => v_Label);
    if v_Label_Id is null then
      if v_Template.Template_Id is not null then
        Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                   i_Message_Code => 'ALREADY_EXISTS',
                                   i_Params       => Array_Varchar2(v_Message_Code),
                                   o_Code         => o_Code,
                                   o_Msg          => o_Msg);
        return;
      end if;
      Mlt_Dml.Add_Template(i_Message_Code        => v_Message_Code,
                           i_Description         => v_Description,
                           i_Param_Count         => v_Param_Count,
                           i_Format_String       => v_Format_String,
                           i_Message_Mask_Lang1  => v_L1,
                           i_Message_Mask_Lang2  => v_L2,
                           i_Message_Mask_Lang3  => v_L3,
                           i_Message_Mask_Lang4  => v_L4,
                           i_Message_Mask_Lang5  => v_L5,
                           i_Message_Mask_Lang6  => v_L6,
                           i_Message_Mask_Lang7  => v_L7,
                           i_Message_Mask_Lang8  => v_L8,
                           i_Message_Mask_Lang9  => v_L9,
                           i_Message_Mask_Lang10 => v_L10);
      Mll_Dml.Add_Label(i_Module_Code  => v_Module_Code,
                        i_Message_Code => v_Message_Code,
                        i_Description  => v_Description,
                        i_Field_Hint   => v_Field_Hint);
      --
      Mll_Dml.Log_Label_History(i_Module_Code  => v_Module_Code,
                                i_Message_Code => v_Message_Code,
                                i_Action       => 'INSERT');
      --v_Action := 'CREATED';
    else
      if v_Template.Template_Id is null then
        Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                   i_Message_Code => 'TEMPLATE_NOT_FOUND',
                                   i_Params       => Array_Varchar2(v_Message_Code),
                                   o_Code         => o_Code,
                                   o_Msg          => o_Msg);
        return;
      end if;
      --
      Mlt_Dml.Update_Template(i_Template_Id   => v_Template.Template_Id,
                              i_Description   => v_Description,
                              i_Param_Count   => v_Param_Count,
                              i_Format_String => v_Format_String,
                              --
                              i_Message_Mask_Lang1  => v_L1,
                              i_Message_Mask_Lang2  => v_L2,
                              i_Message_Mask_Lang3  => v_L3,
                              i_Message_Mask_Lang4  => v_L4,
                              i_Message_Mask_Lang5  => v_L5,
                              i_Message_Mask_Lang6  => v_L6,
                              i_Message_Mask_Lang7  => v_L7,
                              i_Message_Mask_Lang8  => v_L8,
                              i_Message_Mask_Lang9  => v_L9,
                              i_Message_Mask_Lang10 => v_L10);
      Mll_Dml.Update_Label(i_Label_Id     => v_Label_Id,
                           i_Module_Code  => v_Module_Code,
                           i_Message_Code => v_Message_Code,
                           i_Description  => v_Description,
                           i_Field_Hint   => v_Field_Hint);
      --
      Mll_Dml.Log_Label_History(i_Module_Code  => v_Module_Code,
                                i_Message_Code => v_Message_Code,
                                i_Action       => 'UPDATE');
      --v_Action := 'UPDATED';
    end if;
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Save_Label_With_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label_With_Template_DEV(i_Message_Code  varchar2,
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
                                         o_Msg         out varchar2) is
    v_Template Mlt_Templates%rowtype;
    v_Label    Mll_Label_Codes%rowtype;
    v_Action   varchar2(20);
  begin
    --
    Mlt_Util.Select_With_Message_Code(i_Message_Code => i_Message_Code,
                                      i_Is_Raise     => false,
                                      o_Template     => v_Template);
    Mll_Util.Select_Label(i_Module_Code  => i_Module_Code,
                          i_Message_Code => i_Message_Code,
                          i_Is_Raise     => false,
                          o_Label        => v_Label);
  
    --
    if v_Template.Template_Id is null and v_Label.Label_Id is null then
      Mlt_Dml.Add_Template(i_Message_Code        => i_Message_Code,
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
                           i_Message_Mask_Lang10 => i_Message_Mask_Lang10);
      Mll_Dml.Add_Label(i_Module_Code  => i_Module_Code,
                        i_Message_Code => i_Message_Code,
                        i_Description  => i_Description,
                        i_Field_Hint   => i_Field_Hint);
      --
      Mll_Dml.Log_Label_History(i_Module_Code  => i_Module_Code,
                                i_Message_Code => i_Message_Code,
                                i_Action       => 'INSERT');
      v_Action := 'CREATED';
      --
    elsif v_Template.Template_Id is not null and
          v_Label.Label_Id is not null then
      Mlt_Dml.Update_Template(i_Template_Id         => v_Template.Template_Id,
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
                              i_Message_Mask_Lang10 => i_Message_Mask_Lang10);
      Mll_Dml.Update_Label(i_Label_Id     => v_Label.Label_Id,
                           i_Module_Code  => i_Module_Code,
                           i_Message_Code => i_Message_Code,
                           i_Description  => i_Description,
                           i_Field_Hint   => i_Field_Hint);
      --
      Mll_Dml.Log_Label_History(i_Module_Code  => i_Module_Code,
                                i_Message_Code => i_Message_Code,
                                i_Action       => 'UPDATE');
      v_Action := 'UPDATED';
    elsif v_Template.Template_Id is not null and v_Label.Label_Id is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'SUCCESS',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
    else
      o_Msg := 'biri bor biri yoq';
      return;
    end if;
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => case
                                                   when v_Action = 'CREATED' then
                                                    'TEMPLATE_CREATED'
                                                   else
                                                    'TEMPLATE_UPDATED'
                                                 end,
                               i_Params       => Array_Varchar2(i_Message_Code),
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end;
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Get_Label(Io_Hash in out nocopy Core.Hash_t,
                      o_Code  out number,
                      o_Msg   out varchar2) is
    v_Data          Core.Hash_t := Io_Hash;
    v_Result        Core.Hash_t := Core.Hash_t();
    v_Module_Code   varchar2(10);
    v_Message_Code  varchar2(100);
    v_Lang_Index    number;
    v_Format_String varchar2(50);
    v_Core_Params   Core.Array_Varchar2; -- Get_Array_Varchar2 shu tipni qaytaradi
    v_Params        Array_Varchar2; -- Mlt_Util.Get_Message shu tipni kutadi
    v_Label         Mll_Label_Codes%rowtype;
    v_Label_Text    varchar2(4000);
  begin
    v_Module_Code  := v_Data.Get_Varchar2('module_code');
    v_Message_Code := v_Data.Get_Varchar2('message_code');
    --
    v_Lang_Index    := Nvl(v_Data.Get_Optional_Number('lang_index'), 3);
    v_Format_String := Nvl(v_Data.Get_Optional_Varchar2('format_string'),
                           '$');
    --
    begin
      v_Core_Params := v_Data.Get_Array_Varchar2('params');
    exception
      when others then
        v_Core_Params := null;
    end;
    --
    if v_Core_Params is not null and v_Core_Params.Count > 0 then
      v_Params := Array_Varchar2();
      v_Params.Extend(v_Core_Params.Count);
      for i in 1 .. v_Core_Params.Count loop
        v_Params(i) := v_Core_Params(i);
      end loop;
    end if;
    --
    Mll_Util.Select_Label(i_Module_Code  => v_Module_Code,
                          i_Message_Code => v_Message_Code,
                          i_Is_Raise     => false,
                          o_Label        => v_Label);
    --
    if v_Label.Label_Id is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'LABEL_NOT_FOUND',
                                 i_Params       => Array_Varchar2(v_Message_Code),
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    v_Label_Text := Mlt_Util.Get_Message(i_Message_Code  => v_Message_Code,
                                         i_Lang_Index    => v_Lang_Index,
                                         i_Format_String => v_Format_String,
                                         i_Params        => v_Params);
    --
    v_Result.Put('label', v_Label_Text);
    v_Result.Put('field_hint', v_Label.Field_Hint);
    Io_Hash.Put('data', v_Result);
    --
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Code := -999;
      o_Msg  := Substr(sqlerrm, 1, 500);
  end Get_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Label_Id(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2) is
    v_Data     Core.Hash_t := Io_Hash;
    v_Result   Core.Hash_t := Core.Hash_t();
    v_List     Core.Arraylist;
    v_Label_Id number;
  begin
    v_Label_Id := v_Data.Get_Number('label_id');
    --
    Mll_Util.Get_History_By_Label_Id(i_Label_Id => v_Label_Id,
                                     o_List     => v_List);
    --
    v_Result.Put('list', v_List);
    v_Result.Put('label_id', v_Label_Id);
    Io_Hash.Put('data', v_Result);
    --
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Substr(sqlerrm, 1, 500);
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Get_History_By_Label_Id;
  -------------------------------------------------------------------------------------------------------------
end Mll_Kernel;
/
