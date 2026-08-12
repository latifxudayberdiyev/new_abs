create or replace package Sm_Kernel is

  -- Author  : B.URALOV
  -- Created : 28.04.2025 16:49:36
  -- Purpose : 
  ----
  --
  ----
  Function Lock_Process
  (
    i_Lock_Text      in varchar2,
    i_Do_Raise_Error in boolean,
    o_Handle         out varchar2,
    o_Msg            out varchar2
  ) return boolean;
  ----
  --
  ----
  Procedure Unlock_Process(i_Handle varchar2);
  ----
  --  eventni holga tekshirish yurgizish
  ----
  Procedure Run_Event_Hold_Procedure
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  );
  ----
  --  moduleda ixtiyoriy processni ishga tushuradi
  ----
  Procedure Set_Method
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  -- methodni qabul qilish
  ---- 
  Procedure Set_Method
  (
    i_Clob    in clob,
    o_Clob    out clob,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Sm_Kernel;
/
create or replace package body Sm_Kernel is
  ---
  -- xatolikni set qilish
  ---
  Function Put_Error
  (
    i_Operaion_Id in number,
    i_Error_Code  in number,
    i_Error_Msg   in varchar2
  ) return clob is
    result clob;
    v_Hash Hash_t := Hash_t();
  begin
  
    v_Hash.Put('operationId', i_Operaion_Id);
    v_Hash.Put('code', i_Error_Code);
    v_Hash.Put('msg', i_Error_Msg);
    result := v_Hash.Json_Clob;
    return result;
  end Put_Error;
  Procedure Set_Cache
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Sm_Hash Hash_t := Hash_t();
  begin
    --
    -- Sm_Init.Clear_Cache();
    --
    v_Sm_Hash.Put('is_create', Io_Object_t.Is_Create);
    v_Sm_Hash.Put(Io_Object_t.Relation_Key, Io_Object_t.Relation_Id);
    v_Sm_Hash.Put(Io_Object_t.Parent_Relation_Key, Io_Object_t.Parent_Relation_Id);
    v_Sm_Hash.Put('object_code', Io_Object_t.Object_Code);
    v_Sm_Hash.Put('parent_object_code', Io_Object_t.Parent_Object_Code);
    v_Sm_Hash.Put('parent_object_id', Io_Object_t.Parent_Object_Id);
    v_Sm_Hash.Put('object_id', Io_Object_t.Object_Id);
    v_Sm_Hash.Put('object_new_state', Io_Object_t.Object_State_New);
    Io_Hash.Put('sm_cache', v_Sm_Hash);
    --
    -- Sm_Init.Init_Object(Io_Object_t.Object_Id);
  end;
  ----
  --
  ----
  Function Lock_Process
  (
    i_Lock_Text      in varchar2,
    i_Do_Raise_Error in boolean,
    o_Handle         out varchar2,
    o_Msg            out varchar2
  ) return boolean is
  begin
  
    if Process_Mngr.Register(Handle => o_Handle, Processname => i_Lock_Text, Isunique => true) <> 0 then
      if i_Do_Raise_Error then
        declare
          v_Ml_Code number;
        begin
          Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                         i_Message_Code => 'SM_LOCK_BUSY',
                                         i_Params       => null,
                                         o_Code         => v_Ml_Code,
                                         o_Msg          => o_Msg);
        end;
      else
        return false;
      end if;
    end if;
    return true;
  end Lock_Process;
  ----
  --
  ----
  Procedure Unlock_Process(i_Handle varchar2) is
  begin
    if i_Handle is null then
      return;
    end if;
  
    Process_Mngr.Unregister(i_Handle);
  end Unlock_Process;
  ----
  -- jsonda kelgan relation idga asosan objectga tegishli obejct idni aniqlaydi agar mavjud bo'lmasa yangi id qaytaradi
  ----
  Function Get_Object_Id
  (
    i_Relation_Id in number,
    i_Object_Code in varchar2
  ) return number is
    v_Object_Id number(10);
  begin
    select t.Object_Id
      into v_Object_Id
      from Sm_Objects t
     where t.Relation_Id = i_Relation_Id
       and t.Object_Code = i_Object_Code;
    --
    return v_Object_Id;
  exception
    when No_Data_Found then
      return Sm_Util.Get_Next_Object_Id;
  end;
  ----
  -- process ma'umotlarini get qilish
  ----
  Function Check_Tranzition(Io_Object_t in out nocopy Sm_Object_t) return boolean is
  begin
    select t.Is_Approve
      into Io_Object_t.Is_Approve
      from Sm_r_Tranzitions t
     where t.Object_Code = Io_Object_t.Object_Code
       and t.Process_Code = Io_Object_t.Process_Code
       and t.Current_State = Io_Object_t.Cur_State
       and t.New_State = Io_Object_t.Object_State_New;
    return true;
  exception
    when others then
      Io_Object_t.o_Code := 101;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                       i_Message_Code => 'SM_TRANSITION_NOT_FOUND',
                                       i_Params       => null,
                                       o_Code         => v_Ml_Code,
                                       o_Msg          => Io_Object_t.o_Msg);
      end;
      Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || Dbms_Utility.Format_Error_Backtrace;
      return false;
  end;
  --
  Function Check_Tranzition_State
  (
    i_Object_Code  varchar2,
    i_Process_Code varchar2,
    i_Old_State    varchar2,
    o_Code         out number,
    o_Msg          out varchar2
  ) return boolean is
    v_Count      number;
    v_Is_Approve varchar2(10);
    v_States     varchar2(1000);
  begin
    select count(*)
      into v_Count
      from Sm_r_Tranzitions t
     where t.Object_Code = i_Object_Code
       and t.Process_Code = i_Process_Code;
    --
    if v_Count > 0 then
      for r in (select t.Current_State, Nvl(s.Description, t.Current_State) State_Name
                  from Sm_r_Tranzitions t, Sm_r_Object_States s
                 where t.Object_Code = s.Object_Code(+)
                   and t.Current_State = s.Code(+)
                   and t.Object_Code = i_Object_Code
                   and t.Process_Code = i_Process_Code)
      loop
        if r.Current_State = i_Old_State then
          v_Count := 0;
        end if;
        --
        if v_States is null then
          v_States := r.State_Name;
        else
          v_States := Substr(v_States || ', ' || r.State_Name, 1, 1000);
        end if;
      end loop;
      --
      select t.Is_Approve
        into v_Is_Approve
        from Sm_r_Tranzitions t
       where t.Object_Code = i_Object_Code
         and t.Process_Code = i_Process_Code
         and t.Current_State = i_Old_State
         and Rownum = 1;
      --
      if v_Count != 0 then
        o_Code := 102;
        declare
          v_Ml_Code number;
        begin
          Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                         i_Message_Code => 'SM_INVALID_OBJECT_STATE',
                                         i_Param1       => v_States,
                                         o_Code         => v_Ml_Code,
                                         o_Msg          => o_Msg);
        end;
        return true;
      elsif v_Is_Approve = 'Y' then
        o_Code := -1;
        return true;
      else
        o_Code := 0;
        return true;
      end if;
    else
      return false;
    end if;
  end;
  ----
  -- process ma'umotlarini get qilish
  ----
  Function Get_Object_By_Rel
  (
    Io_Object_t in out nocopy Sm_Object_t,
    o_Object    out Sm_Objects%rowtype
  ) return boolean is
  begin
    --
    select t.*
      into o_Object
      from Sm_Objects t
     where t.Relation_Id = Io_Object_t.Relation_Id
       and t.Object_Code = Io_Object_t.Object_Code;
    return true;
  exception
    when No_Data_Found then
      return false;
    when others then
      Io_Object_t.o_Code    := -999;
      Io_Object_t.o_Msg     := sqlerrm;
      Io_Object_t.o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
      return false;
  end;
  ----
  -- parent object idni aniqlash
  ----
  Function Get_Par_Object_Id(Io_Object_t in out nocopy Sm_Object_t) return boolean is
  begin
    if Io_Object_t.Parent_Object_Code = Sm_Const.c_Parent_Root then
      Io_Object_t.Parent_Object_Id   := 0;
      Io_Object_t.Parent_Relation_Id := 0;
      return true;
    end if;
    --
    select t.Object_Id
      into Io_Object_t.Parent_Object_Id
      from Sm_Objects t
     where t.Relation_Id = Io_Object_t.Parent_Relation_Id
       and t.Object_Code = Io_Object_t.Parent_Object_Code;
    return true;
  exception
    when others then
      Io_Object_t.o_Code := 102;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                       i_Message_Code => 'SM_PARENT_OBJECT_NOT_FOUND',
                                       i_Params       => null,
                                       o_Code         => v_Ml_Code,
                                       o_Msg          => Io_Object_t.o_Msg);
      end;
      Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || Dbms_Utility.Format_Error_Backtrace;
      return false;
  end;
  ----
  -- procedure addresini qaytaradi
  ----
  Function Get_Procedure_Name(i_Procedure_Code in varchar2) return varchar2 is
    result varchar2(100);
  begin
    select t.Procedure_Name
      into result
      from Sm_r_Procedures t
     where t.Procedure_Code = i_Procedure_Code
       and t.State = Core_Const.c_State_Active;
    return result;
  exception
    when others then
      return '';
  end;
  ----
  -- eventga biriktirilgan procedurelarni aniqlash
  ----
  Function Get_Procedure_Codes(i_Event_Code in varchar2) return Array_Varchar2 is
    result Array_Varchar2 := Array_Varchar2();
  begin
    select e.Procedure_Code
      bulk collect
      into result
      from Sm_r_Event_Procedures e
     where e.Event_Code = i_Event_Code
       and e.State = Core_Const.c_State_Active
     order by e.Order_By;
    return result;
  end;
  ----
  -- processga biriktirilgan eventlarni aniqlash
  ----
  Function Get_Events(i_Process_Code in varchar2) return Array_Varchar2 is
    result Array_Varchar2 := Array_Varchar2();
  begin
    select e.Event_Code
      bulk collect
      into result
      from Sm_r_Process_Events e
     where e.Process_Code = i_Process_Code
       and e.State = Core_Const.c_State_Active
     order by e.Order_By;
    return result;
  end;
  ----
  --  eventni holga tekshirish yurgizish
  ----
  Procedure Run_Event_Hold_Procedure
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Sql_Stm varchar2(1000);
  begin
    v_Sql_Stm := 'begin ' || Io_Object_t.Event_Hold_Check_Procedure || '(:1, :2, :3,:4); end;';
    execute immediate v_Sql_Stm
      using in out Io_Hash, out Io_Object_t.o_Code, out Io_Object_t.o_Msg, out Io_Object_t.o_Ora_Msg;
  
  exception
    when others then
      raise;
  end;
  ----
  -- process eventni yurgizish
  ----
  Procedure Run_Procedure
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Sql_Stm varchar2(1000);
  begin
    v_Sql_Stm := 'begin ' || Io_Object_t.Procedure_Name || '(:1, :2, :3,:4); end;';
    execute immediate v_Sql_Stm
      using in out Io_Hash, out Io_Object_t.o_Code, out Io_Object_t.o_Msg, out Io_Object_t.o_Ora_Msg;
  
  exception
    when others then
      Io_Object_t.Process_Run_State := 'E';
      raise;
  end;
  ----
  -- process protocolini yaratish
  ----
  Procedure Set_Process_Protocol(Io_Object_t in out nocopy Sm_Object_t) is
    v_Protocol Sm_Process_Protocols %rowtype;
  begin
    v_Protocol.Process_Id     := Io_Object_t.Process_Id;
    v_Protocol.Event_Code     := Io_Object_t.Event_Code;
    v_Protocol.Procedure_Code := Io_Object_t.Procedure_Code;
    v_Protocol.Err_Code       := Io_Object_t.o_Code;
    v_Protocol.Err_Msg        := Io_Object_t.o_Msg;
    v_Protocol.Ora_Err_Msg    := Io_Object_t.o_Ora_Msg;
    Sm_Dml.Insert_Process_Protocol(v_Protocol);
  end;
  ----
  -- process req res yaratish
  ----
  Procedure Set_Process_Req
  (
    i_Req_Hash  in out nocopy Hash_t,
    i_Res_Hash  in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Req Sm_Process_Request_Responses %rowtype;
  begin
    v_Req.Object_Id    := Io_Object_t.Object_Id;
    v_Req.Process_Id   := Io_Object_t.Process_Id;
    v_Req.Request      := i_Req_Hash.Json_Clob;
    v_Req.Response     := i_Res_Hash.Json_Clob;
    v_Req.Object_Code  := Io_Object_t.Object_Code;
    v_Req.Process_Code := Io_Object_t.Process_Code;
    v_Req.Event_Code   := Io_Object_t.Event_Code;
    Sm_Dml.Insert_Process_Req_Res(v_Req);
  end;
  ----
  -- process eventni yurgizish
  ----
  Procedure Set_Process_Event
  (
    Io_Object_t in out nocopy Sm_Object_t,
    i_Json_Clob in clob
  ) is
    v_Process_Event Sm_Process_Events%rowtype;
    v_Count         number := 0;
  begin
  
    v_Process_Event.Process_Id     := Io_Object_t.Process_Id;
    v_Process_Event.Event_Code     := Io_Object_t.Event_Code;
    v_Process_Event.Execution_Mode := Io_Object_t.Event_Execute_Mode;
    -- agar event yurgizilgan bo'lsa aniqlaymiz
    select count(*)
      into v_Count
      from Sm_Process_Events e
     where e.Process_Id = Io_Object_t.Process_Id
       and e.Event_Code = Io_Object_t.Event_Code;
    if v_Count > 0 then
      v_Process_Event.Out_Json_Clob := i_Json_Clob;
      Sm_Dml.Update_Process_Event(v_Process_Event);
      return;
    end if;
    -- yangi yaratilsa
    v_Process_Event.In_Json_Clob := i_Json_Clob;
    Sm_Dml.Insert_Process_Event(v_Process_Event);
  end;
  ----
  -- after process_codeni run qilish
  ----
  Procedure Run_After_Process
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_After_Hash Hash_t := Hash_t();
    v_In_Clob    clob;
    v_Out_Clob   clob;
  begin
    --Dbms_Output.Put_Line(Io_Hash.Json);
    if Io_Hash.Has('after_process_hash') then
      v_After_Hash := Io_Hash.Get_Optional_Hash_t('after_process_hash');
    else
      return;
    end if;
    --
    v_In_Clob := v_After_Hash.Json_Clob;
    --
    Sm_Kernel.Set_Method(i_Clob    => v_In_Clob,
                         o_Clob    => v_Out_Clob,
                         o_Code    => Io_Object_t.o_Code,
                         o_Msg     => Io_Object_t.o_Msg,
                         o_Ora_Msg => Io_Object_t.o_Ora_Msg);
  end;
  ----
  -- event procedureni yurgizish
  ----
  Procedure Run_Event_Procedures
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Has_Procedure boolean := false;
    Procedure Set_Procedures is
      v_Procedure_Row Sm_Event_Procedures%rowtype;
    begin
      for r in (select *
                  from Sm_r_Event_Procedures t
                 where t.Event_Code = Io_Object_t.Event_Code)
      loop
        v_Procedure_Row.Process_Id     := Io_Object_t.Process_Id;
        v_Procedure_Row.Event_Code     := r.Event_Code;
        v_Procedure_Row.Procedure_Code := r.Procedure_Code;
        v_Procedure_Row.State_Id       := Sm_Const.c_Event_State_Enter;
        v_Procedure_Row.Order_By       := r.Order_By;
        Sm_Dml.Insert_Event_Procedure(i_Event_Procedure => v_Procedure_Row);
        v_Has_Procedure := true;
      end loop;
    end;
  begin
    Set_Procedures();
    -- agar birorta procedure mavjud bo'lmasa xato qaytaramiz
    if not v_Has_Procedure then
      Io_Object_t.Process_Run_State := 'E';
      Io_Object_t.o_Code            := 109;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                       i_Message_Code => 'SM_NO_PROCEDURE_ON_EVENT',
                                       i_Param1       => Io_Object_t.Process_Code,
                                       o_Code         => v_Ml_Code,
                                       o_Msg          => Io_Object_t.o_Msg);
      end;
      Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || Dbms_Utility.Format_Error_Backtrace;
      return;
    end if;
    for r in (select *
                from Sm_Event_Procedures t
               where t.State_Id != Sm_Const.c_Event_State_Complate
                 and t.Process_Id = Io_Object_t.Process_Id
                 and t.Event_Code = Io_Object_t.Event_Code
               order by t.Order_By)
    loop
      Io_Object_t.Procedure_Code := r.Procedure_Code;
      -- procedureni aniqlaymiz
      Io_Object_t.Procedure_Name := Get_Procedure_Name(Io_Object_t.Procedure_Code);
      --
      if Io_Object_t.Procedure_Name is not null then
        -- run
        Run_Procedure(Io_Hash, Io_Object_t);
        -- o_codeni tekshiramiz xato bo'lsa to'xtaymiz
        if Io_Object_t.o_Code != Sm_Const.c_Success_Code then
          -- protocol yaratish
          Set_Process_Protocol(Io_Object_t);
          Io_Object_t.Process_Run_State := 'E';
          return;
        end if;
      else
        Io_Object_t.Process_Run_State := 'E';
        Io_Object_t.o_Code            := 110;
        declare
          v_Ml_Code number;
        begin
          Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                         i_Message_Code => 'SM_PROCEDURE_NAME_NOT_BOUND',
                                         i_Param1       => Io_Object_t.Procedure_Code,
                                         o_Code         => v_Ml_Code,
                                         o_Msg          => Io_Object_t.o_Msg);
        end;
        Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || Dbms_Utility.Format_Error_Backtrace;
        return;
      end if;
    end loop;
  end;
  ----
  -- process eventni yurgizish
  ----
  Procedure Run_Process_Event
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Has_Event boolean := false;
    Procedure Set_Events is
      v_Event_Row Sm_Process_Events%rowtype;
    begin
      for r in (select *
                  from Sm_r_Process_Events t
                 where t.Process_Code = Io_Object_t.Process_Code)
      loop
        v_Event_Row.Process_Id           := Io_Object_t.Process_Id;
        v_Event_Row.Event_Code           := r.Event_Code;
        v_Event_Row.Execution_Mode       := r.Execution_Mode;
        v_Event_Row.State_Id             := Sm_Const.c_Event_State_Enter;
        v_Event_Row.Order_By             := r.Order_By;
        v_Event_Row.Hold_Check_Procedure := r.Hold_Check_Procedure;
        Sm_Dml.Insert_Process_Event(i_Process_Event => v_Event_Row);
        v_Has_Event := true;
      end loop;
    end;
  begin
    -- eventlarni aniqlaymiz
    Set_Events();
    -- agar event mavjud bo' Lmasa Xatolik Qaytaramiz
    if not v_Has_Event then
      Io_Object_t.Process_Run_State := 'E';
      Io_Object_t.o_Code            := 108;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                       i_Message_Code => 'SM_EVENT_NOT_FOUND',
                                       i_Param1       => Io_Object_t.Process_Code,
                                       o_Code         => v_Ml_Code,
                                       o_Msg          => Io_Object_t.o_Msg);
      end;
      Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || Dbms_Utility.Format_Error_Backtrace;
      return;
    end if;
  
    -- event loop
    for r in (select *
                from Sm_Process_Events t
               where t.Process_Id = Io_Object_t.Process_Id
                 and t.State_Id != Sm_Const.c_Event_State_Complate
               order by t.Order_By)
    loop
      Io_Object_t.Event_Execute_Mode         := r.Execution_Mode;
      Io_Object_t.Event_Code                 := r.Event_Code;
      Io_Object_t.Event_Hold_Check_Procedure := r.Hold_Check_Procedure;
      Sm_Dml.Set_In_Json_Clob(i_In_Json_Clob => Io_Hash.Json_Clob,
                              i_Object_t     => Io_Object_t,
                              i_Process_Id   => Io_Object_t.Process_Id,
                              i_Event_Code   => Io_Object_t.Event_Code);
      --
      Run_Event_Procedures(Io_Hash, Io_Object_t);
      --
      if Io_Object_t.o_Code != Sm_Const.c_Success_Code then
        rollback;
        Io_Object_t.Event_State_Id := Sm_Const.c_Event_State_Error;
      else
        if Io_Object_t.Event_Execute_Mode != Sm_Const.c_Event_Mode_Standart then
          if Io_Object_t.Event_Execute_Mode = Sm_Const.c_Event_Mode_Event_By_Event then
            Io_Object_t.Event_State_Id := Sm_Const.c_Event_State_Complate;
          elsif Io_Object_t.Event_Execute_Mode = Sm_Const.c_Event_Mode_Event_Hold then
            Io_Object_t.Event_State_Id := Sm_Const.c_Event_State_Hold_Complate;
          end if;
          commit;
        end if;
      end if;
      --
      Sm_Dml.Set_Out_Json_Clob(i_Out_Json_Clob => Io_Hash.Json_Clob,
                               i_Process_Id    => Io_Object_t.Process_Id,
                               i_Event_Code    => Io_Object_t.Event_Code,
                               i_State_Id      => Io_Object_t.Event_State_Id);
      exit when Io_Object_t.Event_Execute_Mode = Sm_Const.c_Event_Mode_Event_Hold or Io_Object_t.Event_State_Id = Sm_Const.c_Event_State_Error;
    end loop;
    --
  
  end;
  ----
  ---
  ----
  Procedure Set_Process
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Process Sm_Processes%rowtype;
  begin
    v_Process.Process_Id   := Sm_Util.Get_Next_Process_Id;
    Io_Object_t.Process_Id := v_Process.Process_Id;
    v_Process.Object_Id    := Io_Object_t.Object_Id;
    v_Process.Process_Code := Io_Object_t.Process_Code;
    -- insert
    Sm_Dml.Insert_Process(v_Process);
    --   run process
    Run_Process_Event(Io_Hash, Io_Object_t);
  end;
  ----
  ---
  ----
  Procedure Set_Process_Get
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Process Sm_Processes%rowtype;
  
  begin
    Io_Object_t.o_Code := Sm_Const.c_Success_Code;
    if Io_Object_t.Relation_Key is not null then
      -- mavjud object
      Io_Object_t.Relation_Id        := Io_Hash.Get_Optional_Varchar2(Io_Object_t.Relation_Key);
      Io_Object_t.Parent_Relation_Id := Io_Hash.Get_Optional_Varchar2(Io_Object_t.Parent_Relation_Key);
      -- relation value mavjudligini tekshirish
      --
      if not Io_Hash.Has('sm_cache') then
        begin
          Io_Object_t.Object_Id := Sm_Util.Get_Object_Id(i_Relation_Id => Io_Object_t.Relation_Id,
                                                         i_Object_Code => Io_Object_t.Object_Code);
          Set_Cache(Io_Hash, Io_Object_t);
        exception
          when others then
            Io_Object_t.o_Code := 245;
            declare
              v_Ml_Code number;
            begin
              Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                             i_Message_Code => 'SM_OBJECT_NOT_FOUND_BY_RELATION',
                                             i_Param1       => Io_Object_t.Relation_Key,
                                             i_Param2       => to_char(Io_Object_t.Relation_Id),
                                             o_Code         => v_Ml_Code,
                                             o_Msg          => Io_Object_t.o_Msg);
            end;
            Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg;
            return;
        end;
      end if;
    end if;
    v_Process.Process_Id   := Sm_Util.Get_Next_Process_Id;
    Io_Object_t.Process_Id := v_Process.Process_Id;
    v_Process.Object_Id    := Io_Object_t.Object_Id;
    v_Process.Process_Code := Io_Object_t.Process_Code;
    -- insert
    Sm_Dml.Insert_Process(v_Process);
    --   run process
    Run_Process_Event(Io_Hash, Io_Object_t);
  end;
  ----
  ---  operasiya yaratish
  ----
  Procedure Set_Operation
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    --v_Object Sm_Objects%rowtype;
    /*Procedure Set_Cache is
      v_Sm_Hash Hash_t := Hash_t();
    begin
      v_Sm_Hash.Put('relation_id', Io_Object_t.Relation_Id);
      v_Sm_Hash.Put('object_code', Io_Object_t.Object_Code);
      v_Sm_Hash.Put('object_id', Io_Object_t.Object_Id);
      v_Sm_Hash.Put('parent_object_id', Io_Object_t.Parent_Object_Id);
      Io_Hash.Put('sm_cache', v_Sm_Hash);
    end;*/
  begin
    /* Io_Object_t.Relation_Id        := Io_Hash.Get_Optional_Varchar2(Io_Object_t.Relation_Key);
    Io_Object_t.Parent_Relation_Id := Io_Hash.Get_Optional_Varchar2(Io_Object_t.Parent_Relation_Key);*/
    -- object aniqlash
    /*  if Get_Object_By_Rel(Io_Object_t, v_Object) then
    Io_Object_t.Relation_Id := v_Object.Relation_Id;
    Io_Object_t.Object_Id   := v_Object.Object_Id;
    Io_Object_t.Object_Code := v_Object.Object_Code;
    -- set sm cache
    Set_Cache;*/
    -- set process
    Set_Process(Io_Hash, Io_Object_t);
    /*  else
      return;
    end if;*/
  end;
  ----
  ---
  ----
  Procedure Set_Object
  (
    Io_Hash     in out nocopy Hash_t,
    Io_Object_t in out nocopy Sm_Object_t
  ) is
    v_Object    Sm_Objects%rowtype;
    v_Old_State Sm_Objects.State%type;
    v_Data      Hash_t := Hash_t();
    Procedure Set_Data_Object is
      v_Data Hash_t := Hash_t();
    begin
      if Io_Hash.Has('data') then
        v_Data := Io_Hash.Get_Optional_Hash_t('data');
      end if;
      if not v_Data.Has('object_id') then
        v_Data.Put('object_id', Io_Object_t.Object_Id);
      end if;
      if not v_Data.Has(Io_Object_t.Relation_Key) then
        v_Data.Put(Io_Object_t.Relation_Key, Io_Object_t.Relation_Id);
      end if;
      Io_Hash.Put('data', v_Data);
    end;
  begin
    Io_Object_t.o_Code := Sm_Const.c_Success_Code;
    --
    if Io_Object_t.Relation_Key is not null then
      -- mavjud object
      Io_Object_t.Relation_Id        := Io_Hash.Get_Optional_Varchar2(Io_Object_t.Relation_Key);
      Io_Object_t.Parent_Relation_Id := Io_Hash.Get_Optional_Varchar2(Io_Object_t.Parent_Relation_Key);
      -- relation value mavjudligini tekshirish
      --
    
    end if;
  
    if Get_Object_By_Rel(Io_Object_t, v_Object) then
      --
      if Io_Object_t.Parent_Relation_Id != v_Object.Parent_Relation_Id then
        Io_Object_t.o_Code := 119;
        declare
          v_Ml_Code number;
        begin
          Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                         i_Message_Code => 'SM_PARENT_DATA_INCONSISTENT',
                                         i_Params       => null,
                                         o_Code         => v_Ml_Code,
                                         o_Msg          => Io_Object_t.o_Msg);
        end;
        Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || Dbms_Utility.Format_Error_Backtrace;
        return;
      end if;
      -- new data
      Io_Object_t.Cur_State := v_Object.State;
      v_Old_State           := v_Object.State;
      --
      if Io_Object_t.Object_State_New is null then
        Io_Object_t.Object_State_New := Io_Object_t.Cur_State;
      end if;
      --
      v_Object.State       := Io_Object_t.Object_State_New;
      v_Object.Is_Deal     := Io_Object_t.Is_Deal;
      v_Object.Action_Note := Nvl(Io_Hash.Get_Optional_Varchar2('description'),
                                  v_Object.Action_Note);
      Sm_Dml.Update_Object(v_Object);
      --
      Io_Object_t.Parent_Object_Id := v_Object.Parent_Object_Id;
      Io_Object_t.Is_Create        := 'N';
    else
      if Io_Object_t.Cur_State = 'START' and Io_Object_t.Relation_Id is null then
        if Io_Object_t.o_Code != Sm_Const.c_Success_Code then
          return;
        end if;
        --
        if not Get_Par_Object_Id(Io_Object_t) then
          return;
        end if;
        v_Object.Parent_Object_Id   := Io_Object_t.Parent_Object_Id;
        v_Object.Parent_Relation_Id := Io_Object_t.Parent_Relation_Id;
        v_Object.State              := Io_Object_t.Object_State_New;
        v_Object.Is_Deal            := Io_Object_t.Is_Deal;
        v_Object.Local_Code         := Io_Hash.Get_Optional_Varchar2('local_code');
        v_Object.Object_Id          := Sm_Util.Get_Next_Object_Id;
        v_Object.Object_Code        := Io_Object_t.Object_Code;
        Io_Object_t.Cur_State       := Sm_Const.c_State_Start;
        v_Old_State                 := Io_Object_t.Cur_State;
        --Io_Object_t.Object_State_New := v_Object.State;
        v_Object.Relation_Id  := Sm_Util.Get_Next_Id_By_Getter(Io_Object_t.Seq_Getter);
        v_Object.Action_Note  := Io_Hash.Get_Optional_Varchar2('description');
        Io_Object_t.Is_Create := 'Y';
        --
        -- insert
        Sm_Dml.Insert_Object(v_Object);
      else
        if Io_Object_t.Relation_Id is not null then
          Io_Object_t.Process_Run_State := 'E';
          Io_Object_t.o_Code            := 112;
          declare
            v_Ml_Code number;
          begin
            Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                           i_Message_Code => 'SM_OBJECT_NOT_FOUND',
                                           i_Param1       => Io_Object_t.Relation_Key,
                                           i_Param2       => to_char(Io_Object_t.Relation_Id),
                                           o_Code         => v_Ml_Code,
                                           o_Msg          => Io_Object_t.o_Msg);
          end;
          Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || Dbms_Utility.Format_Error_Backtrace;
        else
          Io_Object_t.Process_Run_State := 'E';
          Io_Object_t.o_Code            := 111;
          declare
            v_Ml_Code number;
          begin
            Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                           i_Message_Code => 'SM_CREATE_OPERATION_REQUIRED',
                                           i_Params       => null,
                                           o_Code         => v_Ml_Code,
                                           o_Msg          => Io_Object_t.o_Msg);
          end;
          Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || Dbms_Utility.Format_Error_Backtrace;
        end if;
        return;
      end if;
      --
    end if;
    -- check tranzition
    --
    if Check_Tranzition_State(i_Object_Code  => Io_Object_t.Object_Code,
                              i_Process_Code => Io_Object_t.Process_Code,
                              i_Old_State    => v_Old_State,
                              o_Code         => Io_Object_t.o_Code,
                              o_Msg          => Io_Object_t.o_Msg) then
      if Io_Object_t.o_Code = -1 then
        Io_Object_t.Is_Approve := 'Y';
        Io_Object_t.o_Code     := 0;
      elsif Io_Object_t.o_Code != Sm_Const.c_Success_Code then
        return;
      end if;
    elsif Io_Object_t.Object_State_New != Io_Object_t.Cur_State then
      if Check_Tranzition(Io_Object_t) then
        Io_Object_t.Has_Tranzition := 'Y';
      else
        Io_Object_t.Has_Tranzition := 'N';
        return;
      end if;
    end if;
    --
    Io_Object_t.Relation_Id := v_Object.Relation_Id;
    Io_Object_t.Object_Id   := v_Object.Object_Id;
    -- check approvers
    if Io_Object_t.Is_Approve = 'Y' then
      if not Sm_Control.Check_Object_Action_Control(Io_Hash => Io_Hash, Io_Object_t => Io_Object_t) then
        if Io_Object_t.o_Code != Sm_Const.c_Success_Code then
          return;
        end if;
      end if;
    end if;
    -- set cache
    Set_Cache(Io_Hash, Io_Object_t);
    -- set process
    Set_Process(Io_Hash, Io_Object_t);
    if Io_Object_t.o_Code = Sm_Const.c_Success_Code then
      Set_Data_Object;
    end if;
  end;
  ----
  --
  ----
  Procedure Rerun_Process
  (
    i_Process_Id in number,
    Io_Hash      in out nocopy Hash_t,
    Io_Object_t  in out nocopy Sm_Object_t,
    o_Code       out number,
    o_Msg        out varchar2
  ) is
    v_Process Sm_Processes%rowtype;
    v_Handle  varchar2(500);
    Ex        exception;
    Procedure Set_Data_Object is
      v_Data Hash_t := Hash_t();
    begin
      if Io_Hash.Has('data') then
        v_Data := Io_Hash.Get_Optional_Hash_t('data');
      end if;
      if not v_Data.Has('object_id') then
        v_Data.Put('object_id', Io_Object_t.Object_Id);
      end if;
      if not v_Data.Has(Io_Object_t.Relation_Key) then
        v_Data.Put(Io_Object_t.Relation_Key, Io_Object_t.Relation_Id);
      end if;
      Io_Hash.Put('data', v_Data);
    end;
  begin
    if not Lock_Process('LOCK_PROCESS_' || i_Process_Id, false, v_Handle, o_Msg) then
      o_Code := -2;
      return;
    end if;
    Sm_Init.Reinit_Process_Data(i_Process_Id => i_Process_Id,
                                o_Object_t   => Io_Object_t,
                                o_Last_Hash  => Io_Hash,
                                o_Code       => o_Code,
                                o_Msg        => o_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      raise Ex;
    end if;
    --
    Io_Object_t.o_Code := Sm_Const.c_Success_Code;
    --
    Set_Cache(Io_Hash, Io_Object_t);
    --
    v_Process := Sm_Util.Get_Process(i_Process_Id => i_Process_Id);
    if v_Process.State_Id = Sm_Const.c_Event_State_Complate then
      o_Code := 222;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                       i_Message_Code => 'SM_PROCESS_ALREADY_COMPLETED',
                                       i_Params       => null,
                                       o_Code         => v_Ml_Code,
                                       o_Msg          => o_Msg);
      end;
      raise Ex;
    elsif v_Process.State_Id = Sm_Const.c_Event_State_Hold_Complate then
      Run_Event_Hold_Procedure(Io_Hash, Io_Object_t);
      if o_Code != Sm_Const.c_Success_Code then
        raise Ex;
      end if;
    end if;
    --
    if Io_Object_t.Process_Type = Sm_Const.c_Process_Type_Get then
      Set_Process_Get(Io_Hash, Io_Object_t);
    else
      Set_Process(Io_Hash, Io_Object_t);
      --
      if Io_Object_t.o_Code = Sm_Const.c_Success_Code then
        Set_Data_Object;
      end if;
    end if;
    Unlock_Process(v_Handle);
  exception
    when Ex then
      Unlock_Process(v_Handle);
    when others then
      Unlock_Process(v_Handle);
      o_Code := -1;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                       i_Message_Code => 'SM_SYSTEM_ERROR',
                                       i_Params       => null,
                                       o_Code         => v_Ml_Code,
                                       o_Msg          => o_Msg);
      end;
      o_Msg := o_Msg || ':' || sqlerrm;
  end;

  ----
  -- MFI moduleda ixtiyoriy processni ishga tushuradi
  ----
  Procedure Set_Method
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Process_Code varchar2(100);
    v_Process_Id   number(20);
    v_r_Process    Sm_r_Processes%rowtype;
    v_r_Object     Sm_r_Objects%rowtype;
    v_Object_t     Sm_Object_t := Sm_Object_t.Init;
    --v_Savepoint_Name varchar2(200) := 'Process_';
  begin
    v_Process_Id := Io_Hash.Get_Optional_Number('process_id');
    if v_Process_Id is not null then
      Rerun_Process(v_Process_Id, Io_Hash, v_Object_t, o_Code, o_Msg);
      -- process stateni set qilish
      Sm_Dml.Set_Process_State(i_Process_Id => v_Object_t.Process_Id,
                               i_State_Id   => v_Object_t.Event_State_Id);
      return;
    end if;
    --
    begin
      v_Process_Code := Io_Hash.Get_Varchar2('process_code');
    exception
      when others then
        o_Code := -1;
        declare
          v_Ml_Code number;
        begin
          Mle_Core_Api.Get_Error_Message(i_Module_Code  => 'SM',
                                         i_Message_Code => 'SM_PROCESS_CODE_NOT_FOUND',
                                         i_Param1       => v_Process_Code,
                                         o_Code         => v_Ml_Code,
                                         o_Msg          => o_Msg);
        end;
        o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
        return;
    end;
    --
    --v_Savepoint_Name := v_Savepoint_Name || v_Process_Code;
    -- savepoint v_Savepoint_Name;
    -- paramerterlarni tekshirish
    if Sm_Control.Check_Process_Params(v_Process_Code) then
      o_Code := -1;
      o_Msg  := Sm_Control.Get_Json_Param_Errors;
      -- o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
      return;
    end if;
    -- get r_process
    v_r_Process := Sm_Util.Get_r_Process(i_Process_Code => v_Process_Code);
    -- get r_object
    v_r_Object := Sm_Util.Get_r_Object(i_Object_Code        => v_r_Process.Object_Code,
                                       i_Parent_Object_Code => v_r_Process.Parent_Object_Code);
    --
    v_Object_t.Object_Code         := v_r_Process.Object_Code;
    v_Object_t.Process_Code        := v_r_Process.Process_Code;
    v_Object_t.Process_Type        := v_r_Process.Process_Type;
    v_Object_t.Parent_Object_Code  := v_r_Process.Parent_Object_Code;
    v_Object_t.Relation_Key        := v_r_Process.Relation_Key;
    v_Object_t.Parent_Relation_Key := v_r_Process.Parent_Relation_Key;
    v_Object_t.Initioal_State      := v_r_Object.Initial_State;
    v_Object_t.Object_State_New    := v_r_Process.New_Object_State;
    v_Object_t.Is_Deal             := v_r_Process.Is_Deal;
    v_Object_t.Cur_State           := v_r_Object.Initial_State;
    v_Object_t.Seq_Getter          := v_r_Object.Sequence_Getter;
    if v_r_Process.Process_Type = Sm_Const.c_Process_Type_Post then
      -- set object
      Set_Object(Io_Hash, v_Object_t);
    elsif v_r_Process.Process_Type = Sm_Const.c_Process_Type_Operation then
      -- run process  for operation
      Set_Operation(Io_Hash, v_Object_t);
    else
      -- run process  for get
      Set_Process_Get(Io_Hash, v_Object_t);
    end if;
    -- process stateni set qilish
    Sm_Dml.Set_Process_State(i_Process_Id => v_Object_t.Process_Id,
                             i_State_Id   => v_Object_t.Event_State_Id);
    --- after process_codeni tekshiramiz
    /* if v_r_Process.After_Process_Code is not null and v_Object_t.o_Code = Sm_Const.c_Success_Code then
      Run_After_Process(Io_Hash, v_Object_t);
    end if;*/
    --
    /*  if v_Object_t.o_Code != Sm_Const.c_Success_Code then
      -- savepoint yoqamiz
      rollback to v_Savepoint_Name;
    end if;*/
    o_Code    := v_Object_t.o_Code;
    o_Msg     := v_Object_t.o_Msg;
    o_Ora_Msg := v_Object_t.o_Ora_Msg;
  exception
    when others then
      --   rollback to v_Savepoint_Name;
      o_Code    := -999;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----
  -- methodni qabul qilish
  ----
  Procedure Set_Method
  (
    i_Clob    in clob,
    o_Clob    out clob,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Hash       Hash_t := Hash_t();
    v_Params     Arraylist := Arraylist();
    v_Param_Hash Hash_t := Hash_t();
    v_Data       Hash_t := Hash_t();
    Ex           exception;
  begin
    -- parse json
    begin
      Json_Parser.Parse_Json(i_Clob, v_Hash, true);
    exception
      when others then
        o_Code    := -1;
        o_Msg     := 'invalid json';
        o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
        raise Ex;
    end;
    -- paramsni ajratib olish
    v_Params := v_Hash.Get_Arraylist('params');
    if v_Params.Count = 0 then
      o_Code    := -1;
      o_Msg     := 'params is not found';
      o_Ora_Msg := 'params is not found ' || Dbms_Utility.Format_Error_Backtrace;
      raise Ex;
    end if;
    --
    for i in 1 .. v_Params.Count
    loop
      v_Param_Hash := Treat(v_Params.Get_r_Hash_t(i) as Hash_t);
      v_Param_Hash.Put('data', v_Data);
      Set_Method(v_Param_Hash, o_Code, o_Msg, o_Ora_Msg);
      if o_Code != Sm_Const.c_Success_Code then
        raise Ex;
      end if;
      v_Data := v_Param_Hash.Get_Optional_Hash_t('data');
    end loop;
    --
    Core_Global.g_Null_Number_To_Null := true;
    o_Clob                            := v_Data.Json_Clob;
  exception
    when Ex then
      o_Clob := '{}';
      if o_Code is null then
        o_Code := -1;
      end if;
      if o_Msg is null then
        o_Msg := 'System error' || sqlerrm || Dbms_Utility.Format_Error_Backtrace;
      end if;
    when others then
      if o_Code is null then
        o_Code := -1;
      end if;
      if o_Msg is null then
        o_Msg := 'System error' || sqlerrm || Dbms_Utility.Format_Error_Backtrace;
      end if;
      o_Clob := '{}';
  end;
end Sm_Kernel;
/
