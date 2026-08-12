create or replace package Mlt_Util is
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Template(i_Template_Id number,
                            i_Is_Raise    boolean := true,
                            o_Template    out Mlt_Templates%rowtype);
  -------------------------------------------------------------------------------------------------------------  
  Procedure Select_Label(i_Label_Id number,
                         i_Is_Raise boolean := true,
                         o_Label    out Mll_Label_Codes%rowtype);
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_With_Message_Code(i_Message_Code varchar2,
                                     i_Is_Raise     boolean := true,
                                     o_Template     out Mlt_Templates%rowtype);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Message_By_Priority(i_Template in Mlt_Templates%rowtype,
                                    o_Result   out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Function Message_Mask_Lang(i_Message_Code varchar2,
                             i_Lang_Index   number := Mlt_Cache.Lang_Index)
    return varchar2;
  -------------------------------------------------------------------------------------------------------------
  Function Apply_Params(i_Template      varchar2,
                        i_Params        Array_Varchar2,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String)
    return varchar2;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Message(i_Message_Code  varchar2,
                       i_Lang_Index    number := Mlt_Cache.Lang_Index,
                       i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                       i_Params        Array_Varchar2 := null)
    return varchar2;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Message(i_Message_Code  varchar2,
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
                       i_Param10       varchar2 := null) return varchar2;
  -------------------------------------------------------------------------------------------------------------
  Function Count_Format(i_Text varchar2, i_Format_String varchar2)
    return number;
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Error_Code(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Is_Raise     boolean := true,
                              o_Error_Code   out Mlt_Error_Codes%rowtype);
  -------------------------------------------------------------------------------------------------------------  
  Procedure Get_Error_Message(i_Module_Code   varchar2,
                              i_Message_Code  varchar2,
                              i_Lang_Index    number := Mlt_Cache.Lang_Index,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              i_Params        Array_Varchar2 := null,
                              
                              o_Code out number,
                              o_Msg  out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Error_Message(i_Module_Code   varchar2,
                              i_Message_Code  varchar2,
                              i_Lang_Index    number := Mlt_Cache.Lang_Index,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              --
                              i_Param1  varchar2,
                              i_Param2  varchar2 := null,
                              i_Param3  varchar2 := null,
                              i_Param4  varchar2 := null,
                              i_Param5  varchar2 := null,
                              i_Param6  varchar2 := null,
                              i_Param7  varchar2 := null,
                              i_Param8  varchar2 := null,
                              i_Param9  varchar2 := null,
                              i_Param10 varchar2 := null,
                              --
                              o_Code out number,
                              o_Msg  out varchar2);
  -------------------------------------------------------------------------------------------------------------  
  Function Get_Next_Error_Code(i_Module_Code varchar2) return number;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Free_Error_Code(i_Module_Code varchar2) return number;
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Raise_Error(i_Module_Code   varchar2,
                        i_Message_Code  varchar2,
                        i_Lang_Index    number := Mlt_Cache.Lang_Index,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Params        Array_Varchar2 := null);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template_Fill_Stats(o_List out Core.Arraylist,
                                    i_Type varchar2 := null);
  -------------------------------------------------------------------------------------------------------------
end Mlt_Util;
/
create or replace package body Mlt_Util is
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Template(i_Template_Id number,
                            i_Is_Raise    boolean := true,
                            o_Template    out Mlt_Templates%rowtype) is
  begin
    select *
      into o_Template
      from Mlt_Templates
     where Template_Id = i_Template_Id;
  exception
    when No_Data_Found then
      if i_Is_Raise then
        raise;
      end if;
  end;
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Label(i_Label_Id number,
                         i_Is_Raise boolean := true,
                         o_Label    out Mll_Label_Codes%rowtype) is
  begin
    select * into o_Label from Mll_Label_Codes where Label_Id = i_Label_Id;
  exception
    when No_Data_Found then
      if i_Is_Raise then
        raise;
      end if;
  end;
  -------------------------------------------------------------------------------------------------------------  
  Procedure Select_With_Message_Code(i_Message_Code varchar2,
                                     i_Is_Raise     boolean := true,
                                     o_Template     out Mlt_Templates%rowtype) is
  begin
    select *
      into o_Template
      from Mlt_Templates
     where Message_Code = i_Message_Code
     fetch first 1 row only;
  exception
    when No_Data_Found then
      if i_Is_Raise then
        raise;
      end if;
  end;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Message_By_Priority(i_Template in Mlt_Templates%rowtype,
                                    o_Result   out varchar2) is
  begin
    if Mlt_Cache.Lang_Index_Array is null or
       Mlt_Cache.Lang_Index_Array.Count = 0 then
      select Lang_Index
        bulk collect
        into Mlt_Cache.Lang_Index_Array
        from Mlt_Languages
       where State = 'A'
       order by Priority;
    end if;
    o_Result := null;
    --
    for i in 1 .. Mlt_Cache.Lang_Index_Array.Count loop
      case Mlt_Cache.Lang_Index_Array(i)
        when 1 then
          o_Result := i_Template.Message_Mask_Lang1;
        when 2 then
          o_Result := i_Template.Message_Mask_Lang2;
        when 3 then
          o_Result := i_Template.Message_Mask_Lang3;
        when 4 then
          o_Result := i_Template.Message_Mask_Lang4;
        when 5 then
          o_Result := i_Template.Message_Mask_Lang5;
        when 6 then
          o_Result := i_Template.Message_Mask_Lang6;
        when 7 then
          o_Result := i_Template.Message_Mask_Lang7;
        when 8 then
          o_Result := i_Template.Message_Mask_Lang8;
        when 9 then
          o_Result := i_Template.Message_Mask_Lang9;
        when 10 then
          o_Result := i_Template.Message_Mask_Lang10;
      end case;
      --
      if o_Result is not null then
        return;
      end if;
    end loop;
  end;
  -------------------------------------------------------------------------------------------------------------  
  Function Message_Mask_Lang(i_Message_Code varchar2,
                             i_Lang_Index   number := Mlt_Cache.Lang_Index)
    return varchar2 is
    v_Template Mlt_Templates%rowtype;
    v_Result   varchar2(32760);
    v_Priority number;
  begin
    Select_With_Message_Code(i_Message_Code => i_Message_Code,
                             o_Template     => v_Template,
                             i_Is_Raise     => false);
    if v_Template.Template_Id is null then
      Raise_Application_Error(-20102, 'Message Code Not Found');
    end if;
    if i_Lang_Index is not null then
      select Priority
        into v_Priority
        from Mlt_Languages
       where Lang_Index = i_Lang_Index
         and State = 'A';
    end if;
    --
    case v_Priority
      when 1 then
        v_Result := v_Template.Message_Mask_Lang1;
      when 2 then
        v_Result := v_Template.Message_Mask_Lang2;
      when 3 then
        v_Result := v_Template.Message_Mask_Lang3;
      when 4 then
        v_Result := v_Template.Message_Mask_Lang4;
      when 5 then
        v_Result := v_Template.Message_Mask_Lang5;
      when 6 then
        v_Result := v_Template.Message_Mask_Lang6;
      when 7 then
        v_Result := v_Template.Message_Mask_Lang7;
      when 8 then
        v_Result := v_Template.Message_Mask_Lang8;
      when 9 then
        v_Result := v_Template.Message_Mask_Lang9;
      when 10 then
        v_Result := v_Template.Message_Mask_Lang10;
      else
        v_Result := v_Template.Message_Mask_Lang1;
    end case;
    --
    if v_Result is null then
      Get_Message_By_Priority(v_Template, v_Result);
    end if;
    --
    return v_Result;
  end;
  -------------------------------------------------------------------------------------------------------------
  Function Apply_Params(i_Template      varchar2,
                        i_Params        Array_Varchar2,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String)
    return varchar2 is
    v_Result varchar2(32760) := i_Template;
  begin
    if i_Format_String is null then
      Raise_Application_Error(-2001, 'format string cannot be null');
    end if;
    if Length(i_Format_String) != 1 then
      Raise_Application_Error(-2002, 'format must be exactly 1 character');
    end if;
    if i_Params is not null and i_Params.Count > 0 then
      if Instr(i_Template, i_Format_String || '1') = 0 then
        Raise_Application_Error(-20003, 'format dismatch');
      end if;
    end if;
    if i_Params is not null then
      for i in reverse 1 .. i_Params.Count loop
        if i_Params(i) is not null then
          v_Result := replace(v_Result, i_Format_String || i, i_Params(i));
        end if;
      end loop;
    end if;
    --
    return v_Result;
  end;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Message(i_Message_Code  varchar2,
                       i_Lang_Index    number := Mlt_Cache.Lang_Index,
                       i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                       i_Params        Array_Varchar2 := null)
    return varchar2 is
    v_Template Mlt_Templates%rowtype;
    v_Result   varchar2(4000);
  begin
    Select_With_Message_Code(i_Message_Code => i_Message_Code,
                             o_Template     => v_Template,
                             i_Is_Raise     => false);
    --
    if v_Template.Template_Id is null then
      Raise_Application_Error(-20102, 'Template Not Found');
    end if;
    --
    v_Result := Message_Mask_Lang(i_Message_Code => i_Message_Code,
                                  i_Lang_Index   => i_Lang_Index);
    --
    v_Result := Apply_Params(v_Result, i_Params, i_Format_String);
    return v_Result;
  exception
    when No_Data_Found then
      return 'Language not found: ' || i_Lang_Index;
  end;
  -------------------------------------------------------------------------------------------------------------

  Function Get_Message(i_Message_Code  varchar2,
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
                       i_Param10       varchar2 := null) return varchar2 is
    v_Params Array_Varchar2;
  begin
    v_Params := Array_Varchar2(i_Param1,
                               i_Param2,
                               i_Param3,
                               i_Param4,
                               i_Param5,
                               i_Param6,
                               i_Param7,
                               i_Param8,
                               i_Param9,
                               i_Param10);
    --
    return Get_Message(i_Message_Code  => i_Message_Code,
                       i_Lang_Index    => i_Lang_Index,
                       i_Format_String => i_Format_String,
                       i_Params        => v_Params);
  end;
  -------------------------------------------------------------------------------------------------------------
  Function Count_Format(i_Text varchar2, i_Format_String varchar2)
    return number is
    v_Result number;
  begin
    if i_Text is null or i_Format_String is null then
      return 0;
    end if;
    if Length(i_Format_String) = 0 then
      return 0;
    end if;
    v_Result := (Length(i_Text) -
                Length(replace(i_Text, i_Format_String, ''))) /
                Length(i_Format_String);
    return Trunc(v_Result);
  end Count_Format;
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Select_Error_Code(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Is_Raise     boolean := true,
                              o_Error_Code   out Mlt_Error_Codes%rowtype) is
  begin
    select *
      into o_Error_Code
      from Mlt_Error_Codes
     where Module_Code = i_Module_Code
       and Message_Code = i_Message_Code
     fetch first 1 row only;
  exception
    when No_Data_Found then
      if i_Is_Raise then
        raise;
      end if;
  end;
  -------------------------------------------------------------------------------------------------------------   
  Procedure Get_Error_Message(i_Module_Code   varchar2,
                              i_Message_Code  varchar2,
                              i_Lang_Index    number := Mlt_Cache.Lang_Index,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              --
                              i_Params Array_Varchar2 := null,
                              --
                              o_Code out number,
                              o_Msg  out varchar2) is
    v_Template Mlt_Templates%rowtype;
    v_Message  varchar2(32760);
  begin
    Select_With_Message_Code(i_Message_Code => i_Message_Code,
                             o_Template     => v_Template,
                             i_Is_Raise     => false);
    if v_Template.Template_Id is null then
      o_Code := -20102;
      o_Msg  := 'Template not found';
      return;
    end if;
    v_Message := Message_Mask_Lang(i_Message_Code => i_Message_Code,
                                   i_Lang_Index   => i_Lang_Index);
    v_Message := Apply_Params(i_Template      => v_Message,
                              i_Params        => i_Params,
                              i_Format_String => i_Format_String);
    --
    o_Msg := v_Message;
    select error_code
      into o_Code
      from Mlt_Error_Codes
     where Module_Code = i_Module_Code
       and Message_Code = i_Message_Code;
  exception
    when No_Data_Found then
      o_Code := -20104;
      o_Msg  := 'Error code not found';
      --
    when others then
      o_Code := -20199;
      o_Msg  := sqlerrm;
  end;
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Get_Error_Message(i_Module_Code   varchar2,
                              i_Message_Code  varchar2,
                              i_Lang_Index    number := Mlt_Cache.Lang_Index,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              --
                              i_Param1  varchar2,
                              i_Param2  varchar2 := null,
                              i_Param3  varchar2 := null,
                              i_Param4  varchar2 := null,
                              i_Param5  varchar2 := null,
                              i_Param6  varchar2 := null,
                              i_Param7  varchar2 := null,
                              i_Param8  varchar2 := null,
                              i_Param9  varchar2 := null,
                              i_Param10 varchar2 := null,
                              --
                              o_Code out number,
                              o_Msg  out varchar2) is
    v_Params Array_Varchar2;
  begin
    v_Params := Array_Varchar2(i_Param1,
                               i_Param2,
                               i_Param3,
                               i_Param4,
                               i_Param5,
                               i_Param6,
                               i_Param7,
                               i_Param8,
                               i_Param9,
                               i_Param10);
    --
    Get_Error_Message(i_Module_Code   => i_Module_Code,
                      i_Message_Code  => i_Message_Code,
                      i_Lang_Index    => i_Lang_Index,
                      i_Params        => v_Params,
                      i_Format_String => i_Format_String,
                      o_Code          => o_Code,
                      o_Msg           => o_Msg);
  end Get_Error_Message;
  ------------------------------------------------------------------------------------------------------------- 
  Function Get_Next_Error_Code(i_Module_Code varchar2) return number is
    v_Code number;
  begin
    select Nvl(max(error_code), 0) + 1
      into v_Code
      from Mlt_Error_Codes
     where Module_Code = i_Module_Code;
    return v_Code;
  end Get_Next_Error_Code;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Free_Error_Code(i_Module_Code varchar2) return number is
    v_Code number;
  begin
    select min(t.Error_Code + 1)
      into v_Code
      from Mlt_Error_Codes t
     where t.Module_Code = i_Module_Code
       and not exists (select 1
              from Mlt_Error_Codes T2
             where T2.Module_Code = t.Module_Code
               and T2.Error_Code = t.Error_Code + 1);
    if v_Code is null then
      return 1;
    end if;
    return v_Code;
  end;
  -------------------------------------------------------------------------------------------------------------
  Procedure Raise_Error(i_Module_Code   varchar2,
                        i_Message_Code  varchar2,
                        i_Lang_Index    number := Mlt_Cache.Lang_Index,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Params        Array_Varchar2 := null) is
    v_Code number;
    v_Msg  varchar2(4000);
  begin
    Get_Error_Message(i_Module_Code   => i_Module_Code,
                      i_Message_Code  => i_Message_Code,
                      i_Lang_Index    => i_Lang_Index,
                      i_Format_String => i_Format_String,
                      i_Params        => i_Params,
                      o_Code          => v_Code,
                      o_Msg           => v_Msg);
  
    Raise_Application_Error(-20000, v_Msg);
  end Raise_Error;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Template_Fill_Stats(o_List out Core.Arraylist,
                                    i_Type varchar2 := null) is
    v_Total  number;
    v_C1     number;
    v_C2     number;
    v_C3     number;
    v_C4     number;
    v_C5     number;
    v_C6     number;
    v_C7     number;
    v_C8     number;
    v_C9     number;
    v_C10    number;
    v_Filled number;
    v_Row    Core.Hash_t;
  begin
    select count(*),
           count(Message_Mask_Lang1),
           count(Message_Mask_Lang2),
           count(Message_Mask_Lang3),
           count(Message_Mask_Lang4),
           count(Message_Mask_Lang5),
           count(Message_Mask_Lang6),
           count(Message_Mask_Lang7),
           count(Message_Mask_Lang8),
           count(Message_Mask_Lang9),
           count(Message_Mask_Lang10)
      into v_Total,
           v_C1,
           v_C2,
           v_C3,
           v_C4,
           v_C5,
           v_C6,
           v_C7,
           v_C8,
           v_C9,
           v_C10
      from Mlt_Templates t
     where (i_Type is null or i_Type not in ('error', 'label'))
        or (i_Type = 'error' and exists
            (select 1
               from Mlt_Error_Codes e
              where e.Message_Code = t.Message_Code))
        or (i_Type = 'label' and exists
            (select 1
               from Mll_Label_Codes l
              where l.Message_Code = t.Message_Code));
    --
    o_List := Core.Arraylist();
    --
    for r in (select Lang_Index, Lang_Code, Name
                from Mlt_Languages
               where State = 'A'
               order by Priority) loop
    
      v_Filled := case r.Lang_Index
                    when 1 then
                     v_C1
                    when 2 then
                     v_C2
                    when 3 then
                     v_C3
                    when 4 then
                     v_C4
                    when 5 then
                     v_C5
                    when 6 then
                     v_C6
                    when 7 then
                     v_C7
                    when 8 then
                     v_C8
                    when 9 then
                     v_C9
                    when 10 then
                     v_C10
                  end;
    
      v_Row := Core.Hash_t();
      v_Row.Put('lang_index', r.Lang_Index);
      v_Row.Put('lang_code', r.Lang_Code);
      v_Row.Put('name', r.Name);
      v_Row.Put('total', v_Total);
      v_Row.Put('filled', v_Filled);
      v_Row.Put('pct_filled',
                case when v_Total = 0 then 0 else
                round(100 * v_Filled / v_Total, 1) end);
      --
      o_List.Push(v_Row);
    end loop;
  end Get_Template_Fill_Stats;
  -------------------------------------------------------------------------------------------------------------
end Mlt_Util;
/
