create or replace package Mle_Kernel is

  -- Author  : AALIJONOV
  -- Created : 16.06.2026 9:13:08
  -- Purpose : 

  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Error_Code(i_Module_Code  varchar2,
                           i_Error_Code   number,
                           i_Message_Code varchar2,
                           i_Description  varchar2,
                           o_Code         out number,
                           o_Msg          out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Error_Code(i_Error_Id     number,
                              i_Module_Code  varchar2,
                              i_Error_Code   number,
                              i_Message_Code varchar2,
                              i_Description  varchar2,
                              o_Code         out number,
                              o_Msg          out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Error_Code(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              o_Code         out number,
                              o_Msg          out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Error_Stat(i_Stat_Id    number,
                              i_User_Id    number,
                              i_Error_Id   number,
                              i_Created_On date := sysdate,
                              o_Code       out number,
                              o_Msg        out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Error_Stats(Io_Hash   in out nocopy Core.Hash_t,
                            o_Code    out number,
                            o_Msg     out varchar2,
                            o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template_With_Error(Io_Hash   in out nocopy Core.Hash_t,
                                     o_Code    out number,
                                     o_Msg     out varchar2,
                                     o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template_With_Error(i_Message_Code  varchar2,
                                     i_Description   varchar2,
                                     i_Param_Count   number,
                                     i_Format_String varchar2,
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
                                     i_Error_Code  number := null,
                                     o_Code        out number,
                                     o_Msg         out varchar2);
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Get_Error_Message(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Lang_Index   number := Mlt_Cache.Lang_Index,
                              --
                              i_Params        Array_Varchar2 := null,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              --
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
  Procedure Connect_Error_Code(i_Module_Code  varchar2,
                               i_Message_Code varchar2,
                               i_Error_Code   number := null,
                               i_Description  varchar2,
                               --
                               o_Code out number,
                               o_Msg  out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Raise_Error(i_Module_Code   varchar2,
                        i_Message_Code  varchar2,
                        i_Lang_Index    number := Mlt_Cache.Lang_Index,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Params        Array_Varchar2 := null);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Fix_Note(Io_Hash   in out nocopy Core.Hash_t,
                          o_Code    out number,
                          o_Msg     out varchar2,
                          o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Note_Reaction(Io_Hash   in out nocopy Core.Hash_t,
                               o_Code    out number,
                               o_Msg     out varchar2,
                               o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Fix_Note(Io_Hash   in out nocopy Core.Hash_t,
                         o_Code    out number,
                         o_Msg     out varchar2,
                         o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Note_Reaction(Io_Hash   in out nocopy Core.Hash_t,
                              o_Code    out number,
                              o_Msg     out varchar2,
                              o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Error_Id(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2);
  -------------------------------------------------------------------------------------------------------------
end Mle_Kernel;
/
create or replace package body Mle_Kernel is

  -------------------------------------------------------------------------------------------------------------
  Procedure Add_Error_Code(i_Module_Code  varchar2,
                           i_Error_Code   number,
                           i_Message_Code varchar2,
                           i_Description  varchar2,
                           o_Code         out number,
                           o_Msg          out varchar2) is
    v_Error Mlt_Error_Codes%rowtype;
    v_Code  number;
  begin
    --
    if i_Message_Code != Upper(i_Message_Code) then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'MESSAGE_UPPER',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    if i_Error_Code is null then
      v_Code := Mle_Util.Get_Free_Error_Code(i_Module_Code);
      if v_Code is null then
        v_Code := Mle_Util.Get_Next_Error_Code(i_Module_Code => i_Module_Code);
      end if;
    else
      v_Code := i_Error_Code;
    end if;
    Mle_Util.Select_Error_Code(i_Module_Code  => i_Module_Code,
                               i_Message_Code => i_Message_Code,
                               i_Is_Raise     => false,
                               o_Error_Code   => v_Error);
    if v_Error.Error_Code is not null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'ALREADY_EXISTS',
                                 i_Params       => Array_Varchar2(to_char(i_Error_Code)),
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    Mle_Dml.Add_Error_Code(i_Module_Code  => i_Module_Code,
                           i_Error_Code   => v_Code,
                           i_Message_Code => i_Message_Code,
                           i_Description  => i_Description);
    --
    Mle_Dml.Log_Error_History(i_Module_Code  => i_Module_Code,
                              i_Message_Code => i_Message_Code,
                              i_Action       => 'INSERT');
    --
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end Add_Error_Code;
  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Error_Code(i_Error_Id     number,
                              i_Module_Code  varchar2,
                              i_Error_Code   number,
                              i_Message_Code varchar2,
                              i_Description  varchar2,
                              o_Code         out number,
                              o_Msg          out varchar2) is
    v_Error     Mlt_Error_Codes%rowtype;
    v_Dup_Error Mlt_Error_Codes%rowtype;
  begin
    -- yangilanayotgan qator error_id bo'yicha mavjudligini tekshirish
    Mle_Util.Select_Error_Code(i_Error_Id   => i_Error_Id,
                               i_Is_Raise   => false,
                               o_Error_Code => v_Error);
    if v_Error.Error_Id is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'NOT_FOUND',
                                 i_Params       => Array_Varchar2(to_char(i_Error_Id)),
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    -- yangi module_code+message_code kombinatsiyasi boshqa qatorga tegishli emasligini tekshirish
    Mle_Util.Select_Error_Code(i_Module_Code  => i_Module_Code,
                               i_Message_Code => i_Message_Code,
                               i_Is_Raise     => false,
                               o_Error_Code   => v_Dup_Error);
    if v_Dup_Error.Error_Id is not null and
       v_Dup_Error.Error_Id != i_Error_Id then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'ALREADY_EXISTS',
                                 i_Params       => Array_Varchar2(to_char(i_Error_Code)),
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    Mle_Dml.Update_Error_Code(i_Error_Id     => i_Error_Id,
                              i_Module_Code  => i_Module_Code,
                              i_Error_Code   => i_Error_Code,
                              i_Message_Code => i_Message_Code,
                              i_Description  => i_Description);
    --
    Mle_Dml.Log_Error_History(i_Module_Code  => i_Module_Code,
                              i_Message_Code => i_Message_Code,
                              i_Action       => 'UPDATE');
    --
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end Update_Error_Code;
  -------------------------------------------------------------------------------------------------------------
  Procedure Delete_Error_Code(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              o_Code         out number,
                              o_Msg          out varchar2) is
    v_Error Mlt_Error_Codes%rowtype;
  begin
    Mle_Util.Select_Error_Code(i_Module_Code  => i_Module_Code,
                               i_Message_Code => i_Message_Code,
                               i_Is_Raise     => false,
                               o_Error_Code   => v_Error);
    --if v_Error.Error_Code is not null then
    --  o_Msg := Mlt_Util.Get_Message(i_Message_Code => 'ALREADY_EXISTS',
    --                                i_Params       => Array_Varchar2(i_Message_Code));
    --  return;
    -- end if;
    --
    -- tarix o'chirishdan OLDIN yoziladi (keyin ma'lumot qolmaydi)
    Mle_Dml.Log_Error_History(i_Module_Code  => i_Module_Code,
                              i_Message_Code => i_Message_Code,
                              i_Action       => 'DELETE');
    --
    Mle_Dml.Delete_Error_Code(i_Module_Code  => i_Module_Code,
                              i_Message_Code => i_Message_Code);
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end Delete_Error_Code;

  -------------------------------------------------------------------------------------------------------------
  Procedure Update_Error_Stat(i_Stat_Id    number,
                              i_User_Id    number,
                              i_Error_Id   number,
                              i_Created_On date := sysdate,
                              o_Code       out number,
                              o_Msg        out varchar2) is
  begin
    Mle_Dml.Update_Error_Stat(i_Stat_Id    => i_Stat_Id,
                              i_User_Id    => i_User_Id,
                              i_Error_Id   => i_Error_Id,
                              i_Created_On => Nvl(i_Created_On, sysdate));
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end Update_Error_Stat;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Error_Stats(Io_Hash   in out nocopy Core.Hash_t,
                            o_Code    out number,
                            o_Msg     out varchar2,
                            o_Ora_Msg out varchar2) is
    v_From_Date   date;
    v_To_Date     date;
    v_Period_Type varchar2(20);
    v_User_Id     number;
    v_Error_Id    number;
    v_From_Text   varchar2(20);
    v_To_Text     varchar2(20);
    v_Result      Core.Arraylist;
    v_Data        Core.Hash_t := Core.Hash_t();
  begin
    v_From_Text := Io_Hash.Get_Optional_Varchar2('from_date');
    v_To_Text   := Io_Hash.Get_Optional_Varchar2('to_date');
    -- 
    if v_From_Text is not null then
      v_From_Date := to_date(v_From_Text, 'dd.mm.yyyy');
    end if;
    if v_To_Text is not null then
      v_To_Date := to_date(v_To_Text, 'dd.mm.yyyy');
    end if;
    --
    v_Period_Type := Upper(Nvl(Io_Hash.Get_Optional_Varchar2('period_type'),
                               'DAILY'));
    v_User_Id     := Io_Hash.Get_Optional_Number('user_id');
    v_Error_Id    := Io_Hash.Get_Optional_Number('error_id');
    --
    if v_From_Date is not null and v_To_Date is not null and
       v_From_Date > v_To_Date then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'INVALID_DATE_RANGE',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    -- 
    if v_Period_Type not in ('DAILY', 'WEEKLY', 'MONTHLY') then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'INVALID_PERIOD_TYPE',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    Mle_Util.Get_Error_Stats(i_From_Date   => v_From_Date,
                             i_To_Date     => v_To_Date,
                             i_Period_Type => v_Period_Type,
                             i_User_Id     => v_User_Id,
                             i_Error_Id    => v_Error_Id,
                             o_Result      => v_Result);
    --
    v_Data.Put('stats', v_Result);
    Io_Hash.Put('data', v_Data);
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
  end Get_Error_Stats;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template_With_Error(Io_Hash   in out nocopy Core.Hash_t,
                                     o_Code    out number,
                                     o_Msg     out varchar2,
                                     o_Ora_Msg out varchar2) is
    v_Data          Core.Hash_t := Io_Hash;
    v_Message_Code  varchar2(100);
    v_Description   varchar2(500);
    v_Param_Count   number;
    v_Error_Id      number;
    v_Format_String varchar2(10);
    v_Masks         Core.Array_Varchar2;
    v_Template      Mlt_Templates%rowtype;
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
    v_Module_Code varchar2(10);
    v_Error_Code  number := null;
    v_Code        number;
  begin
    v_Error_Id      := v_Data.Get_Optional_Number('error_id');
    v_Message_Code  := v_Data.Get_Varchar2('message_code');
    v_Description   := v_Data.Get_Varchar2('description');
    v_Param_Count   := v_Data.Get_Number('param_count');
    v_Format_String := Nvl(v_Data.Get_Optional_Varchar2('format_string'),
                           Mlt_Const.c_Default_Format_String);
    v_Masks         := v_Data.Get_Array_Varchar2('message_masks');
    --
    v_Module_Code := v_Data.Get_Varchar2('module_code');
    v_Error_Code  := v_Data.Get_Number('error_code');
    --
    Mlt_Util.Select_With_Message_Code(i_Message_Code => v_Message_Code,
                                      i_Is_Raise     => false,
                                      o_Template     => v_Template);
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
    if v_Error_Code is null then
      v_Code := Mle_Util.Get_Free_Error_Code(v_Module_Code);
    
      if v_Code is null then
        v_Code := Mle_Util.Get_Next_Error_Code(v_Module_Code);
      end if;
    else
      v_Code := v_Error_Code;
    end if;
    --
    if v_Error_Id is null then
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
      Mle_Dml.Add_Error_Code(i_Module_Code  => v_Module_Code,
                             i_Error_Code   => v_Code,
                             i_Message_Code => v_Message_Code,
                             i_Description  => v_Description);
      --
      Mle_Dml.Log_Error_History(i_Module_Code  => v_Module_Code,
                                i_Message_Code => v_Message_Code,
                                i_Action       => 'INSERT');
      --
    else
      if v_Template.Template_Id is null then
        Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                   i_Message_Code => 'TEMPLATE_NOT_FOUND',
                                   i_Params       => Array_Varchar2(v_Message_Code),
                                   o_Code         => o_Code,
                                   o_Msg          => o_Msg);
        return;
      end if;
      Mlt_Dml.Update_Template(i_Template_Id         => v_Template.Template_Id,
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
      Mle_Dml.Update_Error_Code(i_Error_Id     => v_Error_Id,
                                i_Module_Code  => v_Module_Code,
                                i_Error_Code   => v_Error_Code,
                                i_Message_Code => v_Message_Code,
                                i_Description  => v_Description);
      --
      Mle_Dml.Log_Error_History(i_Module_Code  => v_Module_Code,
                                i_Message_Code => v_Message_Code,
                                i_Action       => 'UPDATE');
    end if;
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template_With_Error(i_Message_Code  varchar2,
                                     i_Description   varchar2,
                                     i_Param_Count   number,
                                     i_Format_String varchar2,
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
                                     i_Error_Code  number := null,
                                     o_Code        out number,
                                     o_Msg         out varchar2) is
    v_Template Mlt_Templates%rowtype;
    v_Error    Mlt_Error_Codes%rowtype;
    --v_Action   varchar2(20);
    v_Code number;
  begin
    Mlt_Util.Select_With_Message_Code(i_Message_Code => i_Message_Code,
                                      i_Is_Raise     => false,
                                      o_Template     => v_Template);
    Mle_Util.Select_Error_Code(i_Module_Code  => i_Module_Code,
                               i_Message_Code => i_Message_Code,
                               i_Is_Raise     => false,
                               o_Error_Code   => v_Error);
  
    --
    if i_Error_Code is null then
      v_Code := Mle_Util.Get_Free_Error_Code(i_Module_Code);
    
      if v_Code is null then
        v_Code := Mle_Util.Get_Next_Error_Code(i_Module_Code);
      end if;
    else
      v_Code := i_Error_Code;
    end if;
    --
    if v_Template.Template_Id is null and v_Error.Error_Code is null then
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
      Mle_Dml.Add_Error_Code(i_Module_Code  => i_Module_Code,
                             i_Error_Code   => v_Code,
                             i_Message_Code => i_Message_Code,
                             i_Description  => i_Description);
      --
      Mle_Dml.Log_Error_History(i_Module_Code  => i_Module_Code,
                                i_Message_Code => i_Message_Code,
                                i_Action       => 'INSERT');
      --v_Action := 'CREATED';
      --
    elsif v_Template.Template_Id is not null and
          v_Error.Error_Code is not null then
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
      Mle_Dml.Update_Error_Code(i_Error_Id     => v_Error.Error_Id,
                                i_Module_Code  => i_Module_Code,
                                i_Error_Code   => v_Code,
                                i_Message_Code => i_Message_Code,
                                i_Description  => i_Description);
      --
      Mle_Dml.Log_Error_History(i_Module_Code  => i_Module_Code,
                                i_Message_Code => i_Message_Code,
                                i_Action       => 'UPDATE');
      -- v_Action := 'UPDATED';
    elsif v_Template.Template_Id is not null and v_Error.Error_Code is null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'SUCCESS',
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
    else
      o_Msg := 'biri bor biri yoq';
      return;
    end if;
    /*Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
    i_Message_Code => case
                        when v_Action = 'CREATED' then
                         'TEMPLATE_CREATED'
                        else
                         'TEMPLATE_UPDATED'
                      end,
    i_Params       => Array_Varchar2(i_Message_Code),
    o_Code         => o_Code,
    o_Msg          => o_Msg);
    */
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
  end;
  -------------------------------------------------------------------------------------------------------------    
  Procedure Get_Error_Message(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Lang_Index   number := Mlt_Cache.Lang_Index,
                              
                              i_Params        Array_Varchar2 := null,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              
                              o_Code out number,
                              o_Msg  out varchar2) is
  begin
    Mle_Util.Get_Error_Message(i_Module_Code   => i_Module_Code,
                               i_Message_Code  => i_Message_Code,
                               i_Lang_Index    => i_Lang_Index,
                               i_Params        => i_Params,
                               i_Format_String => i_Format_String,
                               o_Code          => o_Code,
                               o_Msg           => o_Msg);
  exception
    when others then
      o_Msg := sqlerrm;
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
  begin
    Mle_Util.Get_Error_Message(i_Module_Code   => i_Module_Code,
                               i_Message_Code  => i_Message_Code,
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
                               i_Param10       => i_Param10,
                               o_Code          => o_Code,
                               o_Msg           => o_Msg);
  end;
  -------------------------------------------------------------------------------------------------------------   
  Procedure Connect_Error_Code(i_Module_Code  varchar2,
                               i_Message_Code varchar2,
                               i_Error_Code   number := null,
                               i_Description  varchar2,
                               
                               o_Code out number,
                               o_Msg  out varchar2) is
    v_Error Mlt_Error_Codes%rowtype;
    v_Code  number;
  begin
    --
    Mle_Util.Select_Error_Code(i_Module_Code  => i_Module_Code,
                               i_Message_Code => i_Message_Code,
                               i_Is_Raise     => false,
                               o_Error_Code   => v_Error);
    --
    if v_Error.Error_Code is not null then
      Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'ALREADY_EXISTS',
                                 i_Params       => Array_Varchar2(to_char(i_Error_Code)),
                                 o_Code         => o_Code,
                                 o_Msg          => o_Msg);
      return;
    end if;
    --
    if i_Error_Code is null then
      v_Code := Mle_Util.Get_Free_Error_Code(i_Module_Code);
    
      if v_Code is null then
        v_Code := Mle_Util.Get_Next_Error_Code(i_Module_Code);
      end if;
    else
      v_Code := i_Error_Code;
    end if;
    --
    Mle_Dml.Add_Error_Code(i_Module_Code  => i_Module_Code,
                           i_Error_Code   => v_Code,
                           i_Message_Code => i_Message_Code,
                           i_Description  => i_Description);
    Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                               i_Message_Code => 'SUCCESS',
                               o_Code         => o_Code,
                               o_Msg          => o_Msg);
  exception
    when others then
      o_Code := -20999;
      o_Msg  := sqlerrm;
  end;
  -------------------------------------------------------------------------------------------------------------
  Procedure Raise_Error(i_Module_Code   varchar2,
                        i_Message_Code  varchar2,
                        i_Lang_Index    number := Mlt_Cache.Lang_Index,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Params        Array_Varchar2 := null) is
  begin
    Mle_Util.Raise_Error(i_Module_Code   => i_Module_Code,
                         i_Message_Code  => i_Message_Code,
                         i_Lang_Index    => i_Lang_Index,
                         i_Format_String => i_Format_String,
                         i_Params        => i_Params);
  end Raise_Error;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Fix_Note(Io_Hash   in out nocopy Core.Hash_t,
                          o_Code    out number,
                          o_Msg     out varchar2,
                          o_Ora_Msg out varchar2) is
    v_Data Core.Hash_t := Io_Hash;
    --
    v_Note_Id   number;
    v_Error_Id  number;
    v_Note_Text varchar2(4000);
    v_Is_Sent   varchar2(1);
    v_Is_Create boolean;
  begin
    v_Note_Id   := v_Data.Get_Optional_Number('note_id');
    v_Error_Id  := v_Data.Get_Number('error_id');
    v_Note_Text := v_Data.Get_Varchar2('note_text');
    v_Is_Sent   := Nvl(v_Data.Get_Optional_Varchar2('is_sent'), 'N');
    v_Is_Create := v_Note_Id is null;
    --
    if v_Is_Create then
      if v_Error_Id is null then
        o_Code := 2;
        o_Msg  := 'ErrorId bo''sh bo''lishi mumkin emas';
        return;
      end if;
      --
      Mle_Dml.Add_Fix_Note(i_User_Id    => 1,
                           i_Error_Id   => v_Error_Id,
                           i_Note_Text  => v_Note_Text,
                           i_Created_By => 1,
                           i_Created_On => sysdate,
                           i_Is_Sent    => v_Is_Sent);
    else
      Mle_Dml.Update_Fix_Note(i_Note_Id   => v_Note_Id,
                              i_Error_Id  => v_Error_Id,
                              i_Note_Text => v_Note_Text);
    end if;
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
  end Save_Fix_Note;
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Note_Reaction(Io_Hash   in out nocopy Core.Hash_t,
                               o_Code    out number,
                               o_Msg     out varchar2,
                               o_Ora_Msg out varchar2) is
    v_Data Core.Hash_t := Io_Hash;
    --
    v_Note_Id     number;
    v_Reaction    varchar2(1);
    v_User_Id     number := Core.User_Env.Get_User_Id;
    v_Reaction_Id number;
  begin
    v_Note_Id  := v_Data.Get_Number('note_id');
    v_Reaction := v_Data.Get_Varchar2('reaction');
    --
    if v_Note_Id is null then
      o_Code := 2;
      o_Msg  := 'NoteId bo''sh bo''lishi mumkin emas';
      return;
    end if;
    --
    if v_Reaction not in ('L', 'D') then
      o_Code := 3;
      o_Msg  := 'Reaction faqat L yoki D bo''lishi mumkin';
      return;
    end if;
    -- 
    begin
      select Reaction_Id
        into v_Reaction_Id
        from Mlt_Note_Reactions
       where Note_Id = v_Note_Id
         and User_Id = v_User_Id;
    exception
      when No_Data_Found then
        v_Reaction_Id := null;
    end;
    --
    if v_Reaction_Id is not null then
      Mle_Dml.Update_Note_Reaction(i_Reaction_Id => v_Reaction_Id,
                                   i_Note_Id     => v_Note_Id,
                                   i_User_Id     => v_User_Id,
                                   i_Reaction    => v_Reaction,
                                   i_Created_On  => sysdate);
    else
      Mle_Dml.Add_Note_Reaction(i_Note_Id    => v_Note_Id,
                                i_User_Id    => v_User_Id,
                                i_Reaction   => v_Reaction,
                                i_Created_On => sysdate);
    end if;
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
  end Save_Note_Reaction;
  -------------------------------------------------------------------------------------------------------------  
  Procedure Get_Fix_Note(Io_Hash   in out nocopy Core.Hash_t,
                         o_Code    out number,
                         o_Msg     out varchar2,
                         o_Ora_Msg out varchar2) is
    v_Data     Core.Hash_t := Io_Hash;
    v_Result   Core.Hash_t := Core.Hash_t();
    v_Note_Id  number;
    v_Error_Id number;
    v_Note     Mlt_Fix_Notes%rowtype;
    v_List     Core.Arraylist;
  begin
    v_Note_Id := v_Data.Get_Optional_Number('note_id');
    --
    if v_Note_Id is not null then
      Mle_Util.Select_Fix_Note(i_Note_Id  => v_Note_Id,
                               i_Is_Raise => false,
                               o_Note     => v_Note);
      --
      if v_Note.Note_Id is null then
        Mle_Util.Get_Error_Message(i_Module_Code  => 'MLT',
                                   i_Message_Code => 'NOTE_NOT_FOUND',
                                   i_Params       => Array_Varchar2(to_char(v_Note_Id)),
                                   o_Code         => o_Code,
                                   o_Msg          => o_Msg);
        return;
      end if;
      -- 
      v_Result.Put('note_id', v_Note.Note_Id);
      v_Result.Put('error_id', v_Note.Error_Id);
      v_Result.Put('user_id', v_Note.User_Id);
      v_Result.Put('note_text', v_Note.Note_Text);
      v_Result.Put('is_sent', v_Note.Is_Sent);
      v_Result.Put('created_by', v_Note.Created_By);
      v_Result.Put('created_on', v_Note.Created_On);
      --
      Io_Hash.Put('data', v_Result);
    else
      v_Error_Id := v_Data.Get_Optional_Number('error_id');
      --
      Mle_Util.Select_Fix_Notes(i_Error_Id => v_Error_Id, o_List => v_List);
    
      --
      v_Result.Put('list', v_List);
      Io_Hash.Put('data', v_Result);
    end if;
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
  end Get_Fix_Note;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Note_Reaction(Io_Hash   in out nocopy Core.Hash_t,
                              o_Code    out number,
                              o_Msg     out varchar2,
                              o_Ora_Msg out varchar2) is
    v_Data     Core.Hash_t := Io_Hash;
    v_Result   Core.Hash_t := Core.Hash_t();
    v_Note_Id  number;
    v_User_Id  number := Core.User_Env.Get_User_Id;
    v_Reaction Mlt_Note_Reactions%rowtype;
    v_List     Core.Arraylist;
    v_Likes    number;
    v_Dislikes number;
  begin
    v_Note_Id := v_Data.Get_Optional_Number('note_id');
    if v_Note_Id is not null then
      Mle_Util.Select_Note_Reaction_Counts(i_Note_Id  => v_Note_Id,
                                           o_Likes    => v_Likes,
                                           o_Dislikes => v_Dislikes);
      --
      v_Result.Put('likes', v_Likes);
      v_Result.Put('dislikes', v_Dislikes);
      Mle_Util.Select_Note_Reaction(i_Note_Id  => v_Note_Id,
                                    i_User_Id  => v_User_Id,
                                    i_Is_Raise => false,
                                    o_Reaction => v_Reaction);
      --
      if v_Reaction.Reaction_Id is not null then
        v_Result.Put('reaction_id', v_Reaction.Reaction_Id);
        v_Result.Put('note_id', v_Reaction.Note_Id);
        v_Result.Put('user_id', v_Reaction.User_Id);
        v_Result.Put('reaction', v_Reaction.Reaction);
        v_Result.Put('created_on', v_Reaction.Created_On);
      end if;
      Io_Hash.Put('data', v_Result);
    else
      Mle_Util.Select_Note_Reactions(i_Note_Id => null, o_List => v_List);
    
      v_Result.Put('list', v_List);
      Io_Hash.Put('data', v_Result);
    end if;
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
  end Get_Note_Reaction;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_History_By_Error_Id(Io_Hash   in out nocopy Core.Hash_t,
                                    o_Code    out number,
                                    o_Msg     out varchar2,
                                    o_Ora_Msg out varchar2) is
    v_Data     Core.Hash_t := Io_Hash;
    v_Result   Core.Hash_t := Core.Hash_t();
    v_List     Core.Arraylist;
    v_Error_Id number;
  begin
    v_Error_Id := v_Data.Get_Number('error_id');
    --
    Mle_Util.Get_History_By_Error_Id(i_Error_Id => v_Error_Id,
                                     o_List     => v_List);
    --
    v_Result.Put('list', v_List);
    v_Result.Put('error_id', v_Error_Id);
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
  end Get_History_By_Error_Id;
  -------------------------------------------------------------------------------------------------------------
end Mle_Kernel;
/
