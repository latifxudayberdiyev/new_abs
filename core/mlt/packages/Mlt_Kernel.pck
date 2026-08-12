create or replace package Mlt_Kernel is
  -- Author  : ASILBEK
  -- Created : 15.04.2026 10:01:04
  -- Purpose : Multi langugage tools DML
  -------------------------------------------------------------------------------------------------------------
  Procedure Set_Lang_Index(i_Lang_Index number,
                           o_Msg        out varchar2,
                           o_Code       out number);
  -------------------------------------------------------------------------------------------------------------
  Procedure Clear_Lang_Index;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Template(Io_Hash in out nocopy Core.Hash_t,
                         o_Code  out number,
                         o_Msg   out varchar2);
  -------------------------------------------------------------------------------------------------------------
  /* Procedure Add_Template_Array
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );  */
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
                            i_Message_Mask_Lang10 varchar2,
                            o_Code                out number,
                            o_Msg                 out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Template(i_Template_Id number,
                            o_Code        out number,
                            o_Msg         out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template(Io_Hash in out nocopy Core.Hash_t,
                          o_Code  out number,
                          o_Msg   out varchar2,
                          o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Message(i_Message_Code  varchar2,
                        i_Lang_Index    number := null,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Params        Array_Varchar2 := null,
                        o_Msg           out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Message(i_Message_Code  varchar2,
                        i_Lang_Index    number := Mlt_Cache.Lang_Index,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Param1        varchar2,
                        i_Param2        varchar2 := null,
                        i_Param3        varchar2 := null,
                        i_Param4        varchar2 := null,
                        i_Param5        varchar2 := null,
                        i_Param6        varchar2 := null,
                        i_Param7        varchar2 := null,
                        i_Param8        varchar2 := null,
                        i_Param9        varchar2 := null,
                        i_Param10       varchar2 := null,
                        o_Msg           out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template(Io_Hash in out nocopy Core.Hash_t,
                         o_Code  out number,
                         o_Msg   out varchar2,
                         o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label(Io_Hash in out nocopy Core.Hash_t,
                      o_Code  out number,
                      o_Msg   out varchar2,
                      o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template_Fill_Stats(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
end Mlt_Kernel;
/
create or replace package body Mlt_Kernel is
  -------------------------------------------------------------------------------------------------------------
  Procedure Set_Lang_Index(i_Lang_Index number,
                           o_Msg        out varchar2,
                           o_Code       out number) is
    v_Count number;
  begin
    if i_Lang_Index is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'LANG_INDEX_REQUIRED',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    select count(*)
      into v_Count
      from Mlt_Languages
     where Lang_Index = i_Lang_Index
       and State = 'A';
    if v_Count = 0 then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'INVALID_LANG_INDEX',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    Mlt_Cache.Lang_Index := i_Lang_Index;
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  end Set_Lang_Index;
  -------------------------------------------------------------------------------------------------------------
  Procedure Clear_Lang_Index is
  begin
    Mlt_Cache.Lang_Index := null;
  end Clear_Lang_Index;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Template(Io_Hash in out nocopy Core.Hash_t,
                         o_Code  out number,
                         o_Msg   out varchar2) is
    v_Data          Core.Hash_t := Io_Hash;
    v_Message_Code  varchar2(100);
    v_Description   varchar2(500);
    v_Param_Count   number;
    v_Format_String varchar2(10);
    --
    v_L1       varchar2(4000);
    v_L2       varchar2(4000);
    v_L3       varchar2(4000);
    v_L4       varchar2(4000);
    v_L5       varchar2(4000);
    v_L6       varchar2(4000);
    v_L7       varchar2(4000);
    v_L8       varchar2(4000);
    v_L9       varchar2(4000);
    v_L10      varchar2(4000);
    v_Template Mlt_Templates%rowtype;
  begin
    v_Message_Code := v_Data.Get_Varchar2('message_code');
    v_Description  := v_Data.Get_Varchar2('description');
    v_Param_Count  := v_Data.Get_Number('param_count');
  
    v_Format_String := Nvl(v_Data.Get_Optional_Varchar2('format_string'),
                           Mlt_Const.c_Default_Format_String);
    --
    v_L1  := v_Data.Get_Varchar2('lang1');
    v_L2  := v_Data.Get_Optional_Varchar2('lang2');
    v_L3  := v_Data.Get_Optional_Varchar2('lang3');
    v_L4  := v_Data.Get_Optional_Varchar2('lang4');
    v_L5  := v_Data.Get_Optional_Varchar2('lang5');
    v_L6  := v_Data.Get_Optional_Varchar2('lang6');
    v_L7  := v_Data.Get_Optional_Varchar2('lang7');
    v_L8  := v_Data.Get_Optional_Varchar2('lang8');
    v_L9  := v_Data.Get_Optional_Varchar2('lang9');
    v_L10 := v_Data.Get_Optional_Varchar2('lang10');
    --
    if v_Message_Code is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'MESSAGE_CODE_REQUIRED',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    if v_Message_Code != Upper(v_Message_Code) then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'MESSAGE_UPPER',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    Mlt_Util.Select_With_Message_Code(i_Message_Code => v_Message_Code,
                                      o_Template     => v_Template,
                                      i_Is_Raise     => false);
    if v_Template.Message_Code is not null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'ALREADY_EXISTS',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --- Insert
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
  
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end Add_Template;
  -------------------------------------------------------------------------------------------------------------
  /*Procedure Add_Template_Array
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Data          Core.Hash_t := Io_Hash;
    v_Message_Code  varchar2(100);
    v_Description   varchar2(500);
    v_Param_Count   number;
    v_Format_String varchar2(10);
    v_Masks         Core.Arraylist;
  
    v_L1       varchar2(4000);
    v_L2       varchar2(4000);
    v_L3       varchar2(4000);
    v_L4       varchar2(4000);
    v_L5       varchar2(4000);
    v_L6       varchar2(4000);
    v_L7       varchar2(4000);
    v_L8       varchar2(4000);
    v_L9       varchar2(4000);
    v_L10      varchar2(4000);
    v_Template Mlt_Templates%rowtype;
  begin
    v_Message_Code := v_Data.Get_Varchar2('message_code');
    v_Description  := v_Data.Get_Varchar2('description');
    v_Param_Count  := v_Data.Get_Number('param_count');
  
    Mlt_Util.Select_With_Message_Code(i_Message_Code => v_Message_Code,
                                      o_Template     => v_Template,
                                      i_Is_Raise     => false);
    if v_Template.Message_Code is not null then
      Raise_Application_Error(-20102, 'Message code already exists');
    end if;
    v_Masks:=v_Data.Get_Arraylist('message_masks');
    --
    if v_Masks is not null and v_Masks.count>0 then
      for i in 1 .. Least(v_Masks.Count, 10)
      loop
        case i
          when 1 then
            v_L1 := v_Masks.Get(i);
          when 2 then
            v_L2 := v_Masks.Get(i);
          when 3 then
            v_L3 := v_Masks.Get(i);
          when 4 then
            v_L4 := v_Masks.Get(i);
          when 5 then
            v_L5 := v_Masks.Get(i);
          when 6 then
            v_L6 := v_Masks.Get(i);
          when 7 then
            v_L7 := v_Masks.Get(i);
          when 8 then
            v_L8 := v_Masks.Get(i);
          when 9 then
            v_L9 := v_Masks.Get(i);
          when 10 then
            v_L10 := v_Masks.Get(i);
        end case;
      end loop;
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
  
  end;  */
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
                            i_Message_Mask_Lang10 varchar2,
                            o_Code                out number,
                            o_Msg                 out varchar2) is
    v_Template Mlt_Templates%rowtype;
  begin
    Mlt_Util.Select_Template(i_Template_Id => i_Template_Id,
                             o_Template    => v_Template,
                             i_Is_Raise    => false);
    if v_Template.Template_Id is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'TEMPLATE_NOT_FOUND',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
    end if;
    --
    Mlt_Dml.Update_Template(i_Template_Id,
                            i_Description,
                            i_Param_Count,
                            i_Format_String,
                            i_Message_Mask_Lang1,
                            i_Message_Mask_Lang2,
                            i_Message_Mask_Lang3,
                            i_Message_Mask_Lang4,
                            i_Message_Mask_Lang5,
                            i_Message_Mask_Lang6,
                            i_Message_Mask_Lang7,
                            i_Message_Mask_Lang8,
                            i_Message_Mask_Lang9,
                            i_Message_Mask_Lang10);
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  
  end Update_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Template(i_Template_Id number,
                            o_Code        out number,
                            o_Msg         out varchar2) is
    v_Template Mlt_Templates%rowtype;
  begin
    Mlt_Util.Select_Template(i_Template_Id => i_Template_Id,
                             o_Template    => v_Template,
                             i_Is_Raise    => false);
    if v_Template.Template_Id is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'TEMPLATE_NOT_FOUND',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    Mlt_Dml.Delete_Template(i_Template_Id);
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  end Delete_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template(Io_Hash   in out nocopy Core.Hash_t,
                          o_Code    out number,
                          o_Msg     out varchar2,
                          o_Ora_Msg out varchar2) is
    v_Data Core.Hash_t := Io_Hash;
    --v_Cache Core.Hash_t;
    --
    v_Message_Code  varchar2(100);
    v_Description   varchar2(500);
    v_Param_Count   number;
    v_Format_String varchar2(10);
    --
    v_Is_Create boolean;
    v_Template  Mlt_Templates%rowtype;
    v_Masks     Core.Array_Varchar2;
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
  begin
    --v_Cache := Io_Hash.Get_Hash_t('sm_cache');
    --v_Is_Create := (v_Cache.Get_Optional_Varchar2('is_create', 'Y') = 'Y');
    --v_Cache.Put('is_create', 'N');
    --
    v_Message_Code := v_Data.Get_Varchar2('message_code');
    v_Is_Create    := v_Data.Get_Optional_Number('template_id') is null;
    v_Description  := v_Data.Get_Varchar2('description');
    v_Param_Count  := v_Data.Get_Number('param_count');
    --
    v_Format_String := Nvl(v_Data.Get_Optional_Varchar2('format_string'),
                           Mlt_Const.c_Default_Format_String);
    v_Masks         := v_Data.Get_Array_Varchar2('message_masks');
    --
    if v_Param_Count > 0 and v_Masks is not null then
      for i in 1 .. Least(v_Masks.Count, 10) loop
        if v_Masks(i) is not null then
          if Mlt_Util.Count_Format(v_Masks(i), v_Format_String) !=
             v_Param_Count then
            Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                       i_Message_Code => 'INVALID_FORMAT_COUNT',
                                       i_Params       => Array_Varchar2(to_char(i),
                                                                        to_char(v_Param_Count)),
                                       o_Code         => o_Code,
                                       o_Msg          => o_Msg);
            return;
          end if;
        end if;
      end loop;
    end if;
    --
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
    --
    if v_Is_Create then
      Mlt_Util.Select_With_Message_Code(i_Message_Code => v_Message_Code,
                                        o_Template     => v_Template,
                                        i_Is_Raise     => false);
      if v_Template.Message_Code is not null then
        Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                   i_Message_Code => 'ALREADY_EXISTS',
                                   i_Params       => Array_Varchar2(v_Message_Code),
                                   o_Code         => o_Code,
                                   o_Msg          => o_Msg);
        return;
      end if;
      --
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
    else
      Mlt_Util.Select_With_Message_Code(i_Message_Code => v_Message_Code,
                                        o_Template     => v_Template,
                                        i_Is_Raise     => false);
      Mlt_Dml.Update_Template(i_Template_Id         => v_Data.Get_Number('template_id'),
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
    end if;
    --
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Save_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Message(i_Message_Code  varchar2,
                        i_Lang_Index    number := null,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Params        Array_Varchar2 := null,
                        o_Msg           out varchar2) is
  begin
    o_Msg := Mlt_Util.Get_Message(i_Message_Code  => i_Message_Code,
                                  i_Lang_Index    => i_Lang_Index,
                                  i_Params        => i_Params,
                                  i_Format_String => i_Format_String);
  exception
    when others then
      o_Msg := sqlerrm;
  end Get_Message;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Message(i_Message_Code  varchar2,
                        i_Lang_Index    number := Mlt_Cache.Lang_Index,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Param1        varchar2,
                        i_Param2        varchar2 := null,
                        i_Param3        varchar2 := null,
                        i_Param4        varchar2 := null,
                        i_Param5        varchar2 := null,
                        i_Param6        varchar2 := null,
                        i_Param7        varchar2 := null,
                        i_Param8        varchar2 := null,
                        i_Param9        varchar2 := null,
                        i_Param10       varchar2 := null,
                        o_Msg           out varchar2) is
  begin
    o_Msg := Mlt_Util.Get_Message(i_Message_Code  => i_Message_Code,
                                  i_Lang_Index    => i_Lang_Index,
                                  i_Format_String => i_Format_String,
                                  i_Param1        => i_Param1,
                                  i_Param2        => i_Param2,
                                  i_Param3        => i_Param3,
                                  i_Param4        => i_Param4,
                                  i_Param5        => i_Param5,
                                  i_Param6        => i_Param6,
                                  i_Param7        => i_Param7,
                                  i_Param8        => i_Param8,
                                  i_Param9        => i_Param9,
                                  i_Param10       => i_Param10);
  exception
    when others then
      o_Msg := sqlerrm;
  end Get_Message;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template(Io_Hash   in out nocopy Core.Hash_t,
                         o_Code    out number,
                         o_Msg     out varchar2,
                         o_Ora_Msg out varchar2) is
    v_Template Mlt_Templates%rowtype;
    v_Error    Mlt_Error_Codes%rowtype;
    v_Data     Core.Hash_t := Core.Hash_t();
    --v_Cache    Core.Hash_t       := Core.Hash_t();
  begin
    Mlt_Util.Select_Template(i_Template_Id => Io_Hash.Get_Number('template_id'),
                             i_Is_Raise    => false,
                             o_Template    => v_Template);
    if v_Template.Template_Id is null then
      o_Code := 1;
      o_Msg  := 'Template topilmadi: ' || Io_Hash.Get_Number('template_id');
      return;
    end if;
    -- module_code va error_code faqat ko'rsatish uchun, o'zgarmaydi
    select *
      into v_Error
      from Mlt_Error_Codes
     where Message_Code = v_Template.Message_Code
     fetch first 1 row only;
    --
    v_Data.Put('template_id', v_Template.Template_Id);
    v_Data.Put('message_code', v_Template.Message_Code);
    v_Data.Put('description', v_Template.Description);
    v_Data.Put('param_count', v_Template.Param_Count);
    v_Data.Put('format_string', v_Template.Format_String);
    v_Data.Put('module_code', v_Error.Module_Code);
    v_Data.Put('error_code', v_Error.Error_Code);
    v_Data.Put('error_id', v_Error.Error_Id);
    v_Data.Put('message_mask_lang1', v_Template.Message_Mask_Lang1);
    v_Data.Put('message_mask_lang2', v_Template.Message_Mask_Lang2);
    v_Data.Put('message_mask_lang3', v_Template.Message_Mask_Lang3);
    v_Data.Put('message_mask_lang4', v_Template.Message_Mask_Lang4);
    v_Data.Put('message_mask_lang5', v_Template.Message_Mask_Lang5);
    v_Data.Put('message_mask_lang6', v_Template.Message_Mask_Lang6);
    v_Data.Put('message_mask_lang7', v_Template.Message_Mask_Lang7);
    v_Data.Put('message_mask_lang8', v_Template.Message_Mask_Lang8);
    v_Data.Put('message_mask_lang9', v_Template.Message_Mask_Lang9);
    v_Data.Put('message_mask_lang10', v_Template.Message_Mask_Lang10);
    -- edit rejimi uchun sm_cache
    --v_Cache.Put('is_create', 'N');
    -- v_Data.Put('sm_cache', v_Cache);
    Io_Hash.Put('data', v_Data);
    o_Code := 0;
    o_Msg  := '';
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Substr(sqlerrm, 1, 500);
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Get_Template;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label(Io_Hash   in out nocopy Core.Hash_t,
                      o_Code    out number,
                      o_Msg     out varchar2,
                      o_Ora_Msg out varchar2) is
    v_Template Mlt_Templates%rowtype;
    v_Label    Mll_Label_Codes%rowtype;
    v_Data     Core.Hash_t := Core.Hash_t();
    --v_Cache    Core.Hash_t       := Core.Hash_t();
  begin
    Mlt_Util.Select_Template(i_Template_Id => Io_Hash.Get_Number('template_id'),
                             i_Is_Raise    => false,
                             o_Template    => v_Template);
    --
    if v_Template.Template_Id is null then
      o_Code := 1;
      o_Msg  := 'Template topilmadi: ' || Io_Hash.Get_Number('template_id');
      return;
    end if;
    --
    select *
      into v_Label
      from Mll_Label_Codes
     where Message_Code = v_Template.Message_Code
     fetch first 1 row only;
    --
    v_Data.Put('template_id', v_Template.Template_Id);
    v_Data.Put('message_code', v_Template.Message_Code);
    v_Data.Put('description', v_Template.Description);
    v_Data.Put('param_count', v_Template.Param_Count);
    v_Data.Put('format_string', v_Template.Format_String);
    v_Data.Put('module_code', v_Label.Module_Code);
    v_Data.Put('label_description', v_Label.Description);
    v_Data.Put('field_hint', v_Label.Field_Hint);
    v_Data.Put('label_id', v_Label.Label_Id);
    v_Data.Put('message_mask_lang1', v_Template.Message_Mask_Lang1);
    v_Data.Put('message_mask_lang2', v_Template.Message_Mask_Lang2);
    v_Data.Put('message_mask_lang3', v_Template.Message_Mask_Lang3);
    v_Data.Put('message_mask_lang4', v_Template.Message_Mask_Lang4);
    v_Data.Put('message_mask_lang5', v_Template.Message_Mask_Lang5);
    v_Data.Put('message_mask_lang6', v_Template.Message_Mask_Lang6);
    v_Data.Put('message_mask_lang7', v_Template.Message_Mask_Lang7);
    v_Data.Put('message_mask_lang8', v_Template.Message_Mask_Lang8);
    v_Data.Put('message_mask_lang9', v_Template.Message_Mask_Lang9);
    v_Data.Put('message_mask_lang10', v_Template.Message_Mask_Lang10);
    -- edit rejimi uchun sm_cache
    --v_Cache.Put('is_create', 'N');
    -- v_Data.Put('sm_cache', v_Cache);
    Io_Hash.Put('data', v_Data);
    o_Code := 0;
    o_Msg  := '';
  exception
    when others then
      o_Code    := -999;
      o_Msg     := Substr(sqlerrm, 1, 500);
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Get_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template_Fill_Stats(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2) is
    v_Result Core.Hash_t := Core.Hash_t();
    v_List   Core.Arraylist;
    v_Type   varchar2(20);
  begin
    v_Type := Io_Hash.Get_Optional_Varchar2('type'); -- 'error', 'label', null
    --
    Mlt_Util.Get_Template_Fill_Stats(o_List => v_List, i_Type => v_Type);
  
    v_Result.Put('list', v_List);
    v_Result.Put('type', Nvl(v_Type, 'all')); -- qaysi tip ekanini ham qaytaramiz
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
  end Get_Template_Fill_Stats;
  -------------------------------------------------------------------------------------------------------------
end Mlt_Kernel;
/
