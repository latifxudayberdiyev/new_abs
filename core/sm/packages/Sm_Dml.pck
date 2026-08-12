create or replace package Sm_Dml is

  -- Author  : B.URALOV
  -- Created : 29.04.2025 16:04:31
  -- Purpose : 
  ----
  -- sm_object insert qilish
  ----
  Procedure Insert_Object(i_Object in Sm_Objects%rowtype);
  ---
  -- Sm_Action_Role_Rel insert qilish
  -----
  Procedure Insert_Action_Role_Rel(i_Role_Rel Sm_Action_Role_Rel%rowtype);
  ----
  -- Sm_Action_Role_Rel delete qilish
  -----
  Procedure Delete_Action_Role_Rel(i_Object_Code Sm_Action_Role_Rel.Object_Code%type);
  ----
  -- sm_processes insert qilish
  ----
  Procedure Insert_Process(i_Process in Sm_Processes%rowtype);

  ----
  -- sm_object_action_controls insert qilish
  -----
  Procedure Insert_Object_Action_Control(i_Object_Action Sm_Object_Action_Controls%rowtype);
  ----
  -- sm_object_action_controls insert qilish
  -----
  Procedure Update_Object_Action_Control(i_Object_Action Sm_Object_Action_Controls%rowtype);
  ----
  -- sm_process_events insert qilish
  ----
  Procedure Insert_Process_Event(i_Process_Event in Sm_Process_Events%rowtype);
  ----
  -- sm_process_protocols insert qilish
  ----
  Procedure Insert_Process_Protocol(i_Process_Protocols in Sm_Process_Protocols%rowtype);
  ----
  -- Sm_Process_Request_Repsonses insert qilish
  ----
  Procedure Insert_Process_Req_Res(i_Process_Req_Res in Sm_Process_Request_Responses%rowtype);
  ----
  -- Sm_Event_Procedures insert qilish
  ----
  Procedure Insert_Event_Procedure(i_Event_Procedure in Sm_Event_Procedures%rowtype);
  ----
  -- set in_json 
  ----
  Procedure Set_In_Json_Clob
  (
    i_In_Json_Clob in clob,
    i_Object_t     in Sm_Object_t,
    i_Process_Id   in number,
    i_Event_Code   in varchar2
  );
  ----
  -- set in_json 
  ----
  Procedure Set_Out_Json_Clob
  (
    i_Out_Json_Clob in clob,
    i_Process_Id    in number,
    i_Event_Code    in varchar2,
    i_State_Id      in number default null
  );
  ----
  -- process stateni set qilish
  ----
  Procedure Set_Process_State
  (
    i_Process_Id in number,
    i_State_Id   in number
  );
  ----
  -- sm_process_events update qilish
  ----
  Procedure Update_Process_Event(i_Process_Event in Sm_Process_Events%rowtype);
  ----
  -- sm_objectda update qilish
  ----
  Procedure Update_Object(i_Object in Sm_Objects%rowtype);
  ----
  -- Sm_Process_Request_Repsonses insert qilish
  ----
  /* Procedure Insert_Approver_Object_Rel(i_Approver_Object_Rel in Sm_r_Approver_Object_Rel%rowtype);
  ----
  -- sm_objectda update qilish
  ----
  Procedure Delete_Approver_Object_Rel(i_User_Id in number);*/
  ----
  -- insert SM_PARAM_PROTOCOLS
  ---- 
  Procedure Insert_Param_Protocol
  (
    i_Process_Code in varchar2,
    i_Code         in number,
    i_Msg          in varchar2,
    i_Param_Value  in varchar2
  );
  ----
  -- insert sm_child_objects_tmp
  ---- 
  Procedure Insert_Object_Child_Tmp
  (
    i_Object_Row in Sm_Objects%rowtype,
    i_Step       in number
  );
end Sm_Dml;
/
create or replace package body Sm_Dml is
  ----
  -- active dateni o'zgartirish
  ----
  Procedure Change_Active_Date
  (
    i_Table_Name   in varchar2,
    i_Where_Clause in varchar2
  ) is
    v_Operday       date := Core.User_Env.Get_Oper_Day;
    v_New_Date      date := v_Operday + (sysdate - Trunc(sysdate));
    v_Char_New_Date varchar2(50) := to_char(v_New_Date, 'dd.mm.yyyy');
  begin
    execute immediate 'update ' || i_Table_Name || ' set date_deactive = to_date(''' ||
                      v_Char_New_Date || ''', ''dd.mm.yyyy'') where ' || i_Where_Clause ||
                      ' and date_deactive = 
                      to_date(''31.12.9999'', ''DD.MM.YYYY'') and rownum = 1';
  end;

  ----
  -- sm_objects_h insert qilish
  -----
  Procedure Insert_Action_Role_Rel_h
  (
    i_Role_Rel Sm_Action_Role_Rel%rowtype,
    i_Action   in varchar2
  ) is
  begin
    insert into Sm_Action_Role_Rel_h
      (Role_Id, Action_Id, Object_Code, Step, Created_On, Created_By, Modify_On, Modify_By, Action)
    values
      (i_Role_Rel.Role_Id,
       i_Role_Rel.Action_Id,
       i_Role_Rel.Object_Code,
       i_Role_Rel.Step,
       i_Role_Rel.Created_On,
       i_Role_Rel.Created_By,
       i_Role_Rel.Modify_On,
       i_Role_Rel.Modify_By,
       i_Action);
  end;
  ----
  -- sm_objects_h insert qilish
  -----
  Procedure Insert_Object_Action_Control_h
  (
    i_Object_Action Sm_Object_Action_Controls%rowtype,
    i_Action        in varchar2
  ) is
  begin
    insert into Sm_Object_Action_Controls_h
      (Object_Id,
       Object_Code,
       Cur_Action_Id,
       Cur_Step,
       Created_On,
       Created_By,
       Modify_On,
       Modify_By,
       Action)
    values
      (i_Object_Action.Object_Id,
       i_Object_Action.Object_Code,
       i_Object_Action.Cur_Action_Id,
       i_Object_Action.Cur_Step,
       i_Object_Action.Created_On,
       i_Object_Action.Created_By,
       i_Object_Action.Modify_On,
       i_Object_Action.Modify_By,
       i_Action);
  end;
  ----
  -- Sm_Action_Role_Rel insert qilish
  -----
  Procedure Insert_Action_Role_Rel(i_Role_Rel Sm_Action_Role_Rel%rowtype) is
    v_Role_Rel Sm_Action_Role_Rel%rowtype := i_Role_Rel;
  begin
    v_Role_Rel.Created_On := sysdate;
    v_Role_Rel.Created_By := Core.User_Env.Get_User_Id;
    v_Role_Rel.Modify_On  := sysdate;
    v_Role_Rel.Modify_By  := Core.User_Env.Get_User_Id;
    insert into Sm_Action_Role_Rel
    values v_Role_Rel;
    --
    Insert_Action_Role_Rel_h(v_Role_Rel, Sm_Const.c_Dml_Action_Insert);
  end;

  ----
  -- Sm_Action_Role_Rel delete qilish
  -----
  Procedure Delete_Action_Role_Rel(i_Object_Code Sm_Action_Role_Rel.Object_Code%type) is
  begin
    for r in (select *
                from Sm_Action_Role_Rel t
               where t.Object_Code = i_Object_Code)
    loop
      r.Modify_On := sysdate;
      r.Modify_By := Core.User_Env.Get_User_Id;
      delete from Sm_Action_Role_Rel t
       where t.Role_Id = r.Role_Id
         and t.Action_Id = r.Action_Id
         and t.Object_Code = r.Object_Code;
      --
      Insert_Action_Role_Rel_h(r, Sm_Const.c_Dml_Action_Delete);
    end loop;
  end;
  ----
  -- sm_object_action_controls insert qilish
  -----
  Procedure Insert_Object_Action_Control(i_Object_Action Sm_Object_Action_Controls%rowtype) is
    v_Object_Action Sm_Object_Action_Controls%rowtype := i_Object_Action;
  begin
    v_Object_Action.Created_On := sysdate;
    v_Object_Action.Created_By := Core.User_Env.Get_User_Id;
    v_Object_Action.Modify_On  := sysdate;
    v_Object_Action.Modify_By  := Core.User_Env.Get_User_Id;
    insert into Sm_Object_Action_Controls
    values v_Object_Action;
    --
    Insert_Object_Action_Control_h(v_Object_Action, Sm_Const.c_Dml_Action_Insert);
  end;
  ----
  -- sm_object_action_controls insert qilish
  -----
  Procedure Update_Object_Action_Control(i_Object_Action Sm_Object_Action_Controls%rowtype) is
    v_Object_Action Sm_Object_Action_Controls%rowtype := i_Object_Action;
  begin
    v_Object_Action.Modify_On := sysdate;
    v_Object_Action.Modify_By := Core.User_Env.Get_User_Id;
    update Sm_Object_Action_Controls t
       set row = v_Object_Action
     where t.Object_Id = v_Object_Action.Object_Id
       and t.Object_Code = v_Object_Action.Object_Code;
    --
    Insert_Object_Action_Control_h(v_Object_Action, Sm_Const.c_Dml_Action_Update);
  end;
  ----
  -- sm_objects_h insert qilish
  -----
  Procedure Insert_Object_h
  (
    i_Object Sm_Objects%rowtype,
    i_Action in varchar2
  ) is
  begin
    insert into Sm_Objects_h
      (Object_Id,
       Parent_Object_Id,
       Object_Code,
       State,
       Relation_Id,
       Parent_Relation_Id,
       Created_On,
       Created_By,
       Modify_On,
       Modify_By,
       Action_Note,
       Local_Code,
       Is_Deal,
       Action)
    values
      (i_Object.Object_Id,
       i_Object.Parent_Object_Id,
       i_Object.Object_Code,
       i_Object.State,
       i_Object.Relation_Id,
       i_Object.Parent_Relation_Id,
       i_Object.Created_On,
       i_Object.Created_By,
       i_Object.Modify_On,
       i_Object.Modify_By,
       i_Object.Action_Note,
       i_Object.Local_Code,
       i_Object.Is_Deal,
       i_Action);
  end;
  ----
  -- sm_object insert qilish
  ----
  Procedure Insert_Object(i_Object in Sm_Objects%rowtype) is
    v_Object Sm_Objects%rowtype := i_Object;
  begin
    v_Object.Modify_On  := sysdate;
    v_Object.Modify_By  := Core.User_Env.Get_User_Id;
    v_Object.Created_On := sysdate;
    v_Object.Created_By := Core.User_Env.Get_User_Id;
    insert into Sm_Objects
    values v_Object;
    -- insert history
    Insert_Object_h(v_Object, Sm_Const.c_Dml_Action_Insert);
  end;
  ----
  -- sm_processes insert qilish
  ----
  Procedure Insert_Process(i_Process in Sm_Processes%rowtype) is
    v_Process Sm_Processes%rowtype := i_Process;
  begin
    v_Process.Created_On := sysdate;
    v_Process.Created_By := Core.User_Env.Get_User_Id;
    insert into Sm_Processes
    values v_Process;
  end;
  ----
  -- sm_process_events update qilish
  ----
  Procedure Update_Process_Event(i_Process_Event in Sm_Process_Events%rowtype) is
  begin
    update Sm_Process_Events t
       set t.Out_Json_Clob = i_Process_Event.Out_Json_Clob
     where t.Process_Id = i_Process_Event.Process_Id
       and t.Event_Code = i_Process_Event.Event_Code;
  end;
  ----
  -- Sm_Event_Procedures insert qilish
  ----
  Procedure Insert_Event_Procedure(i_Event_Procedure in Sm_Event_Procedures%rowtype) is
    v_Event_Procedure Sm_Event_Procedures%rowtype := i_Event_Procedure;
  begin
    insert into Sm_Event_Procedures
    values v_Event_Procedure;
  end;
  ----
  -- set in_json 
  ----
  Procedure Set_In_Json_Clob
  (
    i_In_Json_Clob in clob,
    i_Object_t     in Sm_Object_t,
    i_Process_Id   in number,
    i_Event_Code   in varchar2
  ) is
    v_Obj_Clob clob;
  begin
    v_Obj_Clob := Sm_Util.Obj_t_To_Json(p_Obj => i_Object_t);
    update Sm_Process_Events t
       set t.In_Json_Clob  = i_In_Json_Clob,
           t.Object_t_Json = v_Obj_Clob
     where t.Process_Id = i_Process_Id
       and t.Event_Code = i_Event_Code;
  end;
  ----
  -- set in_json 
  ----
  Procedure Set_Out_Json_Clob
  (
    i_Out_Json_Clob in clob,
    i_Process_Id    in number,
    i_Event_Code    in varchar2,
    i_State_Id      in number default null
  ) is
  begin
    update Sm_Process_Events t
       set t.Out_Json_Clob = i_Out_Json_Clob,
           t.State_Id      = Nvl(i_State_Id, t.State_Id)
     where t.Process_Id = i_Process_Id
       and t.Event_Code = i_Event_Code;
  end;
  ----
  -- process stateni set qilish
  ----
  Procedure Set_Process_State
  (
    i_Process_Id in number,
    i_State_Id   in number
  ) is
    pragma autonomous_transaction;
  begin
    update Sm_Processes t
       set t.State_Id = i_State_Id
     where t.Process_Id = i_Process_Id;
    commit;
  end;
  ----
  -- sm_process_events insert qilish
  ----
  Procedure Insert_Process_Event(i_Process_Event in Sm_Process_Events%rowtype) is
    v_Process_Event Sm_Process_Events%rowtype := i_Process_Event;
  begin
    insert into Sm_Process_Events
    values v_Process_Event;
  end;
  ----
  -- sm_process_protocols insert qilish
  ----
  Procedure Insert_Process_Protocol(i_Process_Protocols in Sm_Process_Protocols%rowtype) is
    pragma autonomous_transaction;
    v_Process_Protocols Sm_Process_Protocols%rowtype := i_Process_Protocols;
  begin
    v_Process_Protocols.Create_On := sysdate;
    insert into Sm_Process_Protocols
    values v_Process_Protocols;
    commit;
  end;

  ----
  -- Sm_Process_Request_Repsonses insert qilish
  ----
  Procedure Insert_Process_Req_Res(i_Process_Req_Res in Sm_Process_Request_Responses%rowtype) is
    pragma autonomous_transaction;
    v_Process_Req_Res Sm_Process_Request_Responses%rowtype := i_Process_Req_Res;
  begin
    v_Process_Req_Res.Created_On := sysdate;
    v_Process_Req_Res.Created_By := Core.User_Context.User_Id;
    insert into Sm_Process_Request_Responses
    values v_Process_Req_Res;
    commit;
  end;
  ----
  -- sm_objectda update qilish
  ----
  Procedure Update_Object(i_Object in Sm_Objects%rowtype) is
    v_Object Sm_Objects%rowtype := i_Object;
  begin
    v_Object.Modify_On := sysdate;
    v_Object.Modify_By := Core.User_Env.Get_User_Id;
    update Sm_Objects t
       set row = v_Object
     where t.Object_Id = v_Object.Object_Id;
    -- insert history
    Insert_Object_h(v_Object, Sm_Const.c_Dml_Action_Update);
  end;

  ----
  -- Sm_Process_Request_Repsonses insert qilish
  ----
  /*Procedure Insert_Approver_Object_Rel_h
  (
    i_Approver_Object_Rel in Sm_r_Approver_Object_Rel%rowtype,
    i_Action_Code         in varchar2 default 'I'
  ) is
  begin
    insert into Sm_r_Approver_Object_Rel_h
      (User_Id, Object_Code, State, Created_On, Created_By, Modify_On, Modify_By, Action_Code)
    values
      (i_Approver_Object_Rel.User_Id,
       i_Approver_Object_Rel.Object_Code,
       i_Approver_Object_Rel.State,
       i_Approver_Object_Rel.Created_On,
       i_Approver_Object_Rel.Created_By,
       i_Approver_Object_Rel.Modify_On,
       i_Approver_Object_Rel.Modify_By,
       i_Action_Code);
    commit;
  end;
  ----
  -- Sm_Process_Request_Repsonses insert qilish
  ----
  Procedure Insert_Approver_Object_Rel(i_Approver_Object_Rel in Sm_r_Approver_Object_Rel%rowtype) is
    v_Approver_Object_Rel Sm_r_Approver_Object_Rel%rowtype := i_Approver_Object_Rel;
  begin
    v_Approver_Object_Rel.Created_On := sysdate;
    v_Approver_Object_Rel.Created_By := Core.user_context.Get_User_Id;
    v_Approver_Object_Rel.Modify_On  := sysdate;
    v_Approver_Object_Rel.Modify_By  := Core.user_context.Get_User_Id;
    insert into Sm_r_Approver_Object_Rel
    values v_Approver_Object_Rel;
    -- insert his
    Insert_Approver_Object_Rel_h(v_Approver_Object_Rel);
  end;
  ----
  -- sm_objectda update qilish
  ----
  Procedure Delete_Approver_Object_Rel(i_User_Id in number) is
  begin
    for r in (select *
                from Sm_r_Approver_Object_Rel Tt
               where Tt.User_Id = i_User_Id)
    loop
      r.Modify_On := sysdate;
      r.Modify_By := Core.user_context.Get_User_Id;
      -- insert his
      Insert_Approver_Object_Rel_h(r);
      --
      delete from Sm_r_Approver_Object_Rel t
       where t.User_Id = i_User_Id
         and t.Object_Code = r.Object_Code;
    end loop;
  end;*/
  ----
  -- insert SM_PARAM_PROTOCOLS
  ---- 
  Procedure Insert_Param_Protocol
  (
    i_Process_Code in varchar2,
    i_Code         in number,
    i_Msg          in varchar2,
    i_Param_Value  in varchar2
  ) is
  begin
    insert into Sm_Param_Protocols
      (Param_Key, Param_Value, Err_Code, Err_Msg)
    values
      (i_Process_Code, i_Param_Value, i_Code, i_Msg);
  end;

  ----
  -- insert sm_child_objects_tmp
  ---- 
  Procedure Insert_Object_Child_Tmp
  (
    i_Object_Row in Sm_Objects%rowtype,
    i_Step       in number
  ) is
  begin
    insert into Sm_Child_Objects_Tmp
      (Object_Id, Object_Code, Step, Parent_Object_Id, Parent_Object_Code)
    values
      (i_Object_Row.Object_Id,
       i_Object_Row.Object_Code,
       i_Step,
       i_Object_Row.Parent_Object_Id,
       Sm_Util.Get_Object_Code(i_Object_Id => i_Object_Row.Parent_Object_Id));
  end;
end Sm_Dml;
/
