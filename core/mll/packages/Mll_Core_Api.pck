create or replace package Mll_Core_Api is

  -- Author  : AALIJONOV
  -- Created : 14.07.2026 9:52:55
  -- Purpose : 
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label(i_Module_Code   varchar2,
                      i_Message_Code  varchar2,
                      i_Lang_Index    number := Mlt_Cache.Lang_Index,
                      i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                      i_Params        Core.Array_Varchar2 := null,
                      o_Label         out varchar2,
                      o_Code          out number,
                      o_Msg           out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Function Get_Label(i_Module_Code   varchar2,
                     i_Message_Code  varchar2,
                     i_Lang_Index    number := Mlt_Cache.Lang_Index,
                     i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                     i_Params        Core.Array_Varchar2 := null)
    return varchar2;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label_By_Id(i_Label_Id      number,
                            i_Lang_Index    number := Mlt_Cache.Lang_Index,
                            i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                            i_Params        Core.Array_Varchar2 := null,
                            o_Label         out varchar2,
                            o_Code          out number,
                            o_Msg           out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Function Get_Label_By_Id(i_Label_Id      number,
                           i_Lang_Index    number := Mlt_Cache.Lang_Index,
                           i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                           i_Params        Core.Array_Varchar2 := null)
    return varchar2;
  -------------------------------------------------------------------------------------------------------------    
end Mll_Core_Api;
/
create or replace package body Mll_Core_Api is
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label(i_Module_Code   varchar2,
                      i_Message_Code  varchar2,
                      i_Lang_Index    number := Mlt_Cache.Lang_Index,
                      i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                      i_Params        Core.Array_Varchar2 := null,
                      o_Label         out varchar2,
                      o_Code          out number,
                      o_Msg           out varchar2) is
    v_Hash Core.Hash_t := Core.Hash_t();
  begin
    v_Hash.Put('module_code', i_Module_Code);
    v_Hash.Put('message_code', i_Message_Code);
    v_Hash.Put('lang_index', i_Lang_Index);
    v_Hash.Put('format_string', i_Format_String);
    if i_Params is not null then
      v_Hash.Put('params', i_Params);
    end if;
    --
    Mll_Kernel.Get_Label(Io_Hash => v_Hash,
                         o_Code  => o_Code,
                         o_Msg   => o_Msg);
    --
    if o_Code = 0 then
      o_Label := v_Hash.Get_Hash_t('data').Get_Varchar2('label');
    end if;
  exception
    when others then
      o_Code := -999;
      o_Msg  := Substr(sqlerrm, 1, 500);
  end Get_Label;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Label(i_Module_Code   varchar2,
                     i_Message_Code  varchar2,
                     i_Lang_Index    number := Mlt_Cache.Lang_Index,
                     i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                     i_Params        Core.Array_Varchar2 := null)
    return varchar2 is
    v_Label varchar2(4000);
    v_Code  number;
    v_Msg   varchar2(4000);
  begin
    Get_Label(i_Module_Code   => i_Module_Code,
              i_Message_Code  => i_Message_Code,
              i_Lang_Index    => i_Lang_Index,
              i_Format_String => i_Format_String,
              i_Params        => i_Params,
              o_Label         => v_Label,
              o_Code          => v_Code,
              o_Msg           => v_Msg);
    return v_Label;
  exception
    when others then
      return '[' || i_Module_Code || '.' || i_Message_Code || '] not found';
  end Get_Label;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Label_By_Id(i_Label_Id      number,
                            i_Lang_Index    number := Mlt_Cache.Lang_Index,
                            i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                            i_Params        Core.Array_Varchar2 := null,
                            o_Label         out varchar2,
                            o_Code          out number,
                            o_Msg           out varchar2) is
    v_Module_Code  mll_label_codes.module_code%type;
    v_Message_Code mll_label_codes.message_code%type;
  begin
    select module_code, message_code
      into v_Module_Code, v_Message_Code
      from mll_label_codes
     where label_id = i_Label_Id;
    --
    Get_Label(i_Module_Code   => v_Module_Code,
              i_Message_Code  => v_Message_Code,
              i_Lang_Index    => i_Lang_Index,
              i_Format_String => i_Format_String,
              i_Params        => i_Params,
              o_Label         => o_Label,
              o_Code          => o_Code,
              o_Msg           => o_Msg);
  exception
    when no_data_found then
      o_Code  := -1;
      o_Msg   := 'Label topilmadi: label_id = ' || i_Label_Id;
      o_Label := null;
    when others then
      o_Code  := -999;
      o_Msg   := Substr(sqlerrm, 1, 500);
      o_Label := null;
  end Get_Label_By_Id;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Label_By_Id(i_Label_Id      number,
                           i_Lang_Index    number := Mlt_Cache.Lang_Index,
                           i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                           i_Params        Core.Array_Varchar2 := null)
    return varchar2 is
    v_Label varchar2(4000);
    v_Code  number;
    v_Msg   varchar2(4000);
  begin
    Get_Label_By_Id(i_Label_Id      => i_Label_Id,
                    i_Lang_Index    => i_Lang_Index,
                    i_Format_String => i_Format_String,
                    i_Params        => i_Params,
                    o_Label         => v_Label,
                    o_Code          => v_Code,
                    o_Msg           => v_Msg);
    return v_Label;
  exception
    when others then
      return null;
  end Get_Label_By_Id;
  -------------------------------------------------------------------------------------------------------------
end Mll_Core_Api;
/
