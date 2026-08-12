create or replace package Mle_Util is

  -- Author  : AALIJONOV
  -- Created : 16.06.2026 9:24:33
  -- Purpose : 
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Error_Code(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Is_Raise     boolean := true,
                              o_Error_Code   out Mlt_Error_Codes%rowtype);
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Error_Code(i_Error_Id   number,
                              i_Is_Raise   boolean := true,
                              o_Error_Code out Mlt_Error_Codes%rowtype);
  -------------------------------------------------------------------------------------------------------------

  Procedure Add_Error_Stat(i_User_Id    number,
                           i_Error_Id   number,
                           i_Created_On date := sysdate);
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Result(io_Result      in out nocopy Core.Arraylist,
                       i_Period_Start date,
                       i_Period_Label varchar2,
                       i_Error_Id     number,
                       i_Module_Code  varchar2,
                       i_Error_Code   number,
                       i_Message_Code varchar2,
                       i_Description  varchar2,
                       i_Error_Count  number);
  -------------------------------------------------------------------------------------------------------------                       
  Procedure Get_Error_Stats(i_From_Date   date,
                            i_To_Date     date,
                            i_Period_Type varchar2,
                            i_User_Id     number := null,
                            i_Error_Id    number := null,
                            o_Result      out Core.Arraylist);
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
  Procedure Select_Fix_Note(i_Note_Id  number,
                            i_Is_Raise boolean := true,
                            o_Note     out Mlt_Fix_Notes%rowtype);
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Fix_Notes(i_Error_Id number := null,
                             o_List     out Core.Arraylist);
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Note_Reaction(i_Note_Id  number,
                                 i_User_Id  number,
                                 i_Is_Raise boolean := true,
                                 o_Reaction out Mlt_Note_Reactions%rowtype);
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Note_Reactions(i_Note_Id number := null,
                                  o_List    out Core.Arraylist);
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Note_Reaction_Counts(i_Note_Id  number,
                                        o_Likes    out number,
                                        o_Dislikes out number);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Error_Id(i_Error_Id number,
                                    o_List     out Core.Arraylist);
  -------------------------------------------------------------------------------------------------------------
end Mle_Util;
/
create or replace package body Mle_Util is
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
  Procedure Select_Error_Code(i_Error_Id   number,
                              i_Is_Raise   boolean := true,
                              o_Error_Code out Mlt_Error_Codes%rowtype) is
  begin
    select *
      into o_Error_Code
      from Mlt_Error_Codes
     where error_id = i_Error_Id
     fetch first 1 row only;
  exception
    when No_Data_Found then
      if i_Is_Raise then
        raise;
      end if;
  end;
  -------------------------------------------------------------------------------------------------------------  
  Procedure Add_Error_Stat(i_User_Id    number,
                           i_Error_Id   number,
                           i_Created_On date := sysdate) is
    Pragma autonomous_transaction;
  begin
    Mle_Dml.Add_Error_Stat(i_User_Id    => i_User_Id,
                           i_Error_Id   => i_Error_Id,
                           i_Created_On => Nvl(i_Created_On, sysdate));
    commit;
  end Add_Error_Stat;
  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Result(io_Result      in out nocopy Core.Arraylist,
                       i_Period_Start date,
                       i_Period_Label varchar2,
                       i_Error_Id     number,
                       i_Module_Code  varchar2,
                       i_Error_Code   number,
                       i_Message_Code varchar2,
                       i_Description  varchar2,
                       i_Error_Count  number) is
    v_Data Core.Hash_t := Core.Hash_t();
  begin
    if i_Error_Count > 0 then
      v_Data.Put('period_start', to_char(i_Period_Start, 'dd.mm.yyyy'));
      v_Data.Put('period_label', i_Period_Label);
      v_Data.Put('error_id', i_Error_Id);
      v_Data.Put('module_code', i_Module_Code);
      v_Data.Put('error_code', i_Error_Code);
      v_Data.Put('message_code', i_Message_Code);
      v_Data.Put('description', i_Description);
      v_Data.Put('error_count', i_Error_Count);
      --
      io_Result.Push(v_Data);
      --
    end if;
  end Add_Result;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Error_Stats(i_From_Date   date,
                            i_To_Date     date,
                            i_Period_Type varchar2,
                            i_User_Id     number := null,
                            i_Error_Id    number := null,
                            o_Result      out Core.Arraylist) is
    v_From_Date date;
    v_To_Date   date;
  begin
    o_Result := Core.Arraylist();
    --
    select Nvl(Trunc(Nvl(i_From_Date, min(t.Created_On))), Trunc(sysdate)),
           Nvl(Trunc(Nvl(i_To_Date, max(t.Created_On))), Trunc(sysdate))
      into v_From_Date, v_To_Date
      from Mlt_Error_Stat t
     where (i_User_Id is null or t.User_Id = i_User_Id)
       and (i_Error_Id is null or t.Error_Id = i_Error_Id);
    --
    if Upper(i_Period_Type) = 'DAILY' then
      for r in (select p.Period_Start,
                       to_char(p.Period_Start, 'dd.mm.yyyy') Period_Label,
                       s.Error_Id,
                       s.Module_Code,
                       s.Error_Code,
                       s.Message_Code,
                       s.Description,
                       Nvl(s.Error_Count, 0) Error_Count
                  from (select Trunc(v_From_Date) + level - 1 Period_Start
                          from dual
                        connect by level <=
                                   Trunc(v_To_Date) - Trunc(v_From_Date) + 1) p
                  left join (select Trunc(t.Created_On) Period_Start,
                                   t.Error_Id,
                                   e.Module_Code,
                                   e.Error_Code,
                                   e.Message_Code,
                                   e.Description,
                                   count(*) Error_Count
                              from Mlt_Error_Stat t
                              join Mlt_Error_Codes e
                                on e.Error_Id = t.Error_Id
                             where t.Created_On >= Trunc(v_From_Date)
                               and t.Created_On < Trunc(v_To_Date) + 1
                               and (i_User_Id is null or
                                   t.User_Id = i_User_Id)
                               and (i_Error_Id is null or
                                   t.Error_Id = i_Error_Id)
                             group by Trunc(t.Created_On),
                                      t.Error_Id,
                                      e.Module_Code,
                                      e.Error_Code,
                                      e.Message_Code,
                                      e.Description) s
                    on s.Period_Start = p.Period_Start
                 order by p.Period_Start, s.Module_Code, s.Error_Code) loop
        Add_Result(io_Result      => o_Result,
                   i_Period_Start => r.Period_Start,
                   i_Period_Label => r.Period_Label,
                   i_Error_Id     => r.Error_Id,
                   i_Module_Code  => r.Module_Code,
                   i_Error_Code   => r.Error_Code,
                   i_Message_Code => r.Message_Code,
                   i_Description  => r.Description,
                   i_Error_Count  => r.Error_Count);
      end loop;
      -- 
    elsif Upper(i_Period_Type) = 'WEEKLY' then
      for r in (select p.Period_Start,
                       to_char(p.Period_Start, 'yyyy') || '-W' ||
                       to_char(p.Period_Start, 'iw') Period_Label,
                       s.Error_Id,
                       s.Module_Code,
                       s.Error_Code,
                       s.Message_Code,
                       s.Description,
                       Nvl(s.Error_Count, 0) Error_Count
                  from (select Trunc(v_From_Date, 'IW') + (level - 1) * 7 Period_Start
                          from dual
                        connect by level <= (Trunc(v_To_Date, 'IW') -
                                   Trunc(v_From_Date, 'IW')) / 7 + 1) p
                  left join (select Trunc(t.Created_On, 'IW') Period_Start,
                                   t.Error_Id,
                                   e.Module_Code,
                                   e.Error_Code,
                                   e.Message_Code,
                                   e.Description,
                                   count(*) Error_Count
                              from Mlt_Error_Stat t
                              join Mlt_Error_Codes e
                                on e.Error_Id = t.Error_Id
                             where t.Created_On >= Trunc(v_From_Date)
                               and t.Created_On < Trunc(v_To_Date) + 1
                               and (i_User_Id is null or
                                   t.User_Id = i_User_Id)
                               and (i_Error_Id is null or
                                   t.Error_Id = i_Error_Id)
                             group by Trunc(t.Created_On, 'IW'),
                                      t.Error_Id,
                                      e.Module_Code,
                                      e.Error_Code,
                                      e.Message_Code,
                                      e.Description) s
                    on s.Period_Start = p.Period_Start
                 order by p.Period_Start, s.Module_Code, s.Error_Code) loop
        Add_Result(io_Result      => o_Result,
                   i_Period_Start => r.Period_Start,
                   i_Period_Label => r.Period_Label,
                   i_Error_Id     => r.Error_Id,
                   i_Module_Code  => r.Module_Code,
                   i_Error_Code   => r.Error_Code,
                   i_Message_Code => r.Message_Code,
                   i_Description  => r.Description,
                   i_Error_Count  => r.Error_Count);
      end loop;
      --
    else
      -- MONTHLY
      for r in (select p.Period_Start,
                       to_char(p.Period_Start, 'mm.yyyy') Period_Label,
                       s.Error_Id,
                       s.Module_Code,
                       s.Error_Code,
                       s.Message_Code,
                       s.Description,
                       Nvl(s.Error_Count, 0) Error_Count
                  from (select Add_Months(Trunc(v_From_Date, 'MM'), level - 1) Period_Start
                          from dual
                        connect by level <=
                                   Months_Between(Trunc(v_To_Date, 'MM'),
                                                  Trunc(v_From_Date, 'MM')) + 1) p
                  left join (select Trunc(t.Created_On, 'MM') Period_Start,
                                   t.Error_Id,
                                   e.Module_Code,
                                   e.Error_Code,
                                   e.Message_Code,
                                   e.Description,
                                   count(*) Error_Count
                              from Mlt_Error_Stat t
                              join Mlt_Error_Codes e
                                on e.Error_Id = t.Error_Id
                             where t.Created_On >= Trunc(v_From_Date)
                               and t.Created_On < Trunc(v_To_Date) + 1
                               and (i_User_Id is null or
                                   t.User_Id = i_User_Id)
                               and (i_Error_Id is null or
                                   t.Error_Id = i_Error_Id)
                             group by Trunc(t.Created_On, 'MM'),
                                      t.Error_Id,
                                      e.Module_Code,
                                      e.Error_Code,
                                      e.Message_Code,
                                      e.Description) s
                    on s.Period_Start = p.Period_Start
                 order by p.Period_Start, s.Module_Code, s.Error_Code) loop
        Add_Result(io_Result      => o_Result,
                   i_Period_Start => r.Period_Start,
                   i_Period_Label => r.Period_Label,
                   i_Error_Id     => r.Error_Id,
                   i_Module_Code  => r.Module_Code,
                   i_Error_Code   => r.Error_Code,
                   i_Message_Code => r.Message_Code,
                   i_Description  => r.Description,
                   i_Error_Count  => r.Error_Count);
      end loop;
    end if;
  end Get_Error_Stats;
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
    v_Template   Mlt_Templates%rowtype;
    v_Message    varchar2(32760);
    v_Error_Code Mlt_Error_Codes%rowtype;
  begin
    Mlt_Util.Select_With_Message_Code(i_Message_Code => i_Message_Code,
                                      o_Template     => v_Template,
                                      i_Is_Raise     => false);
    if v_Template.Template_Id is null then
      o_Code := -20102;
      o_Msg  := 'Template not found';
      return;
    end if;
    v_Message := Mlt_Util.Message_Mask_Lang(i_Message_Code => i_Message_Code,
                                            i_Lang_Index   => i_Lang_Index);
    v_Message := Mlt_Util.Apply_Params(i_Template      => v_Message,
                                       i_Params        => i_Params,
                                       i_Format_String => i_Format_String);
    --
    o_Msg := v_Message;
    select *
      into v_Error_Code
      from Mlt_Error_Codes
     where Module_Code = i_Module_Code
       and Message_Code = i_Message_Code;
  
    o_Code := v_Error_Code.Error_Code;
  
    if v_Error_Code.Error_Code != 0 then
      Add_Error_Stat(i_User_Id    => Core.User_Env.Get_User_Id,
                     i_Error_Id   => v_Error_Code.Error_Id,
                     i_Created_On => sysdate);
    end if;
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
    --
    Raise_Application_Error(-20000, v_Msg);
  end Raise_Error;
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Fix_Note(i_Note_Id  number,
                            i_Is_Raise boolean := true,
                            o_Note     out Mlt_Fix_Notes%rowtype) is
  begin
    select * into o_Note from Mlt_Fix_Notes where Note_Id = i_Note_Id;
  exception
    when No_Data_Found then
      if i_Is_Raise then
        raise;
      end if;
  end Select_Fix_Note;
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Fix_Notes(i_Error_Id number := null,
                             o_List     out Core.Arraylist) is
    v_Row      Core.Hash_t;
    v_Likes    number;
    v_Dislikes number;
    v_User_Id  number := Core.User_Env.Get_User_Id;
  begin
    o_List := Core.Arraylist();
    for r in (select f.*, u.name as created_by_name
                from Mlt_Fix_Notes f
                left join Users_V u
                  on u.user_id = f.created_by
               where i_Error_Id is null
                  or f.Error_Id = i_Error_Id
               order by f.Created_On desc) loop
      declare
        v_My_Reaction Mlt_Note_Reactions%rowtype;
      begin
        v_Row := Core.Hash_t();
        v_Row.Put('note_id', r.Note_Id);
        v_Row.Put('error_id', r.Error_Id);
        v_Row.Put('user_id', r.User_Id);
        v_Row.Put('note_text', r.Note_Text);
        v_Row.Put('is_sent', r.Is_Sent);
        v_Row.Put('created_by', r.Created_By);
        v_Row.Put('created_by_name',
                  Nvl(r.Created_By_Name, to_char(r.Created_By)));
        v_Row.Put('created_on', r.Created_On);
        --
        Select_Note_Reaction_Counts(i_Note_Id  => r.Note_Id,
                                    o_Likes    => v_Likes,
                                    o_Dislikes => v_Dislikes);
        v_Row.Put('likes', v_Likes);
        v_Row.Put('dislikes', v_Dislikes);
        --
        Select_Note_Reaction(i_Note_Id  => r.Note_Id,
                             i_User_Id  => v_User_Id,
                             i_Is_Raise => false,
                             o_Reaction => v_My_Reaction);
        v_Row.Put('my_reaction', v_My_Reaction.Reaction);
        o_List.Push(v_Row);
      end;
    end loop;
  end Select_Fix_Notes;
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Note_Reaction(i_Note_Id  number,
                                 i_User_Id  number,
                                 i_Is_Raise boolean := true,
                                 o_Reaction out Mlt_Note_Reactions%rowtype) is
  begin
    select *
      into o_Reaction
      from Mlt_Note_Reactions
     where Note_Id = i_Note_Id
       and User_Id = i_User_Id;
  exception
    when No_Data_Found then
      if i_Is_Raise then
        raise;
      end if;
  end Select_Note_Reaction;
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Note_Reactions(i_Note_Id number := null,
                                  o_List    out Core.Arraylist) is
    v_Row Core.Hash_t;
  begin
    o_List := Core.Arraylist();
    for r in (select *
                from Mlt_Note_Reactions
               where i_Note_Id is null
                  or Note_Id = i_Note_Id
               order by Created_On desc) loop
      v_Row := Core.Hash_t();
      v_Row.Put('reaction_id', r.Reaction_Id);
      v_Row.Put('note_id', r.Note_Id);
      v_Row.Put('user_id', r.User_Id);
      v_Row.Put('reaction', r.Reaction);
      v_Row.Put('created_on', r.Created_On);
      o_List.Push(v_Row);
    end loop;
  end Select_Note_Reactions;
  -------------------------------------------------------------------------------------------------------------
  Procedure Select_Note_Reaction_Counts(i_Note_Id  number,
                                        o_Likes    out number,
                                        o_Dislikes out number) is
  begin
    select count(case
                   when Reaction = 'L' then
                    1
                 end),
           count(case
                   when Reaction = 'D' then
                    1
                 end)
      into o_Likes, o_Dislikes
      from Mlt_Note_Reactions
     where Note_Id = i_Note_Id;
  end Select_Note_Reaction_Counts;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Error_Id(i_Error_Id number,
                                    o_List     out Core.Arraylist) is
    v_Row Core.Hash_t;
  begin
    o_List := Core.Arraylist();
    --
    for r in (select *
                from Mle_History
               where Error_Id = i_Error_Id
               order by Action_Date desc, Log_Id desc) loop
      v_Row := Core.Hash_t();
      v_Row.Put('log_id', r.Log_Id);
      v_Row.Put('action', r.Action);
      v_Row.Put('action_date', r.Action_Date);
      v_Row.Put('modified_by', r.Modified_By);
      v_Row.Put('modified_on', r.Modified_On);
      --- MLE
      v_Row.Put('error_id', r.Error_Id);
      v_Row.Put('module_code', r.Module_Code);
      v_Row.Put('error_code', r.Error_Code);
      v_Row.Put('message_code', r.Message_Code);
      v_Row.Put('description', r.Description);
      --- MLT
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
  end Get_History_By_Error_Id;
  -------------------------------------------------------------------------------------------------------------

end Mle_Util;
/
