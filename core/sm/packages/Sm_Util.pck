create or replace package Sm_Util is

  -- Author  : B.URALOV
  -- Created : 28.04.2025 16:50:05
  -- Purpose : 

  ----
  -- process sequence ni qaytarish
  ----
  Function Get_Next_Process_Id return number;
  ----
  -- objects sequence ni qaytarish
  ----
  Function Get_Next_Object_Id return number;
  ----
  -- object rowni qaytarish
  ----
  Function Get_r_Process(i_Process_Code in varchar2) return Sm_r_Processes%rowtype;
  ----
  -- object rowni qaytarish
  ----
  Function Get_r_Object
  (
    i_Object_Code        in varchar2,
    i_Parent_Object_Code in varchar2 default 'ROOT'
  ) return Sm_r_Objects%rowtype;
  ----
  -- relation orqali opject_idni aniqlash
  ----
  Function Get_Object_Id
  (
    i_Relation_Id in number,
    i_Object_Code in varchar2
  ) return number;
  ----
  -- object idga mos ota relation idni aniqlaydi
  ----
  Function Get_Parent_Relation_Id(i_Object_Id in number) return number;
  ----
  -- Objectga tegishli relation idni aniqlaydi
  ----
  Function Get_Relation_Id
  (
    i_Object_Relation_Key in varchar2,
    i_Hash                in Core.Hash_t
  ) return number;
  ----
  -- Objectga tegishli parent relation idni aniqlaydi
  ----
  Function Get_Parent_Relation_Id
  (
    i_p_Object_Relation_Key in varchar2,
    i_Hash                  in Core.Hash_t
  ) return number;
  ----
  -- seq getter bo'yicha id olish
  ----
  Function Get_Next_Id_By_Getter(i_Getter in varchar2) return number;
  ----
  -- contextdan user idni olish
  ----
  Function Get_Session_User_Id return number;

  ----
  -- objectga tegishli keyingi actionni qaytaradi
  ----
  Function Get_Max_Object_Action_Step(i_Object_Code in varchar2) return number;
  ----
  -- objectga tegishli keyingi actionni qaytaradi
  ----
  Function Has_Object_Action_Route(i_Object_Code in varchar2) return boolean;

  ----
  -- object, action roleni qaytaradi
  ----
  Function Get_Object_Action_Role
  (
    i_Object_Code in varchar2,
    i_Action_Id   in number
  ) return number;
  ----
  -- objectga tegishli keyingi actionni qaytaradi
  ----
  Function Get_Next_Object_Action
  (
    i_Object_Code in varchar2,
    i_Cur_Step    in number default 1
  ) return number;
  ----
  -- objectga tegishli keyingi actionni qaytaradi
  ----
  Function Get_First_Object_Action(i_Object_Code in varchar2) return number;
  ----
  -- objectni object_codeni aniqlash
  ----
  Function Get_Object_Action_Control_Row
  (
    i_Object_Id   in number,
    i_Object_Code in varchar2
  ) return Sm_Object_Action_Controls%rowtype;

  ----
  -- objectni object_codeni aniqlash
  ----
  Function Get_Object_Code(i_Object_Id in number) return varchar2;
  ----
  --  objectda reject borligini qaytaradi boolean
  ----
  Function Is_Reject_Object_Action
  (
    i_Object_Id   in Sm_Object_Action_Controls.Object_Id%type,
    i_Object_Code in Sm_Object_Action_Controls.Object_Code%type
  ) return boolean;
  ----
  --  objectda approve borligini qaytaradi boolean
  ----
  Function Is_Approve_Object_Action
  (
    i_Object_Id   in Sm_Object_Action_Controls.Object_Id%type,
    i_Object_Code in Sm_Object_Action_Controls.Object_Code%type
  ) return boolean;

  ----
  -- object_codeni short xolatini qaytaradi
  ----
  Function Get_Object_Short_Code(i_Object_Code Sm_r_Objects.Object_Code%type)
    return Sm_r_Object_Short_Codes.Short_Code%type;
  ----
  -- eventni execution modeni qaytaradi
  ----
  Function Get_Event_Execution_Mode
  (
    i_Process_Code in Sm_r_Processes.Process_Code%type,
    i_Event_Code   Sm_r_Events.Event_Code%type
  ) return Sm_r_Process_Events.Execution_Mode%type;
  ----
  -- object rowni qaytarish 
  ----
  Function Get_Object_Row(i_Object_Id Sm_Objects.Object_Id%type) return Sm_Objects%rowtype;
  ----
  -- process event rowni qaytarish 
  ----
  Function Get_Process_Event(i_Process_Id Sm_Process_Events.Process_Id%type)
    return Sm_Process_Events%rowtype;
  ----
  -- process rowni qaytarish 
  ----
  Function Get_Process(i_Process_Id Sm_Processes.Process_Id%type) return Sm_Processes%rowtype;
  ----
  -- object rowni qaytarish 
  ----
  Function Get_Object_Row_By_Rel
  (
    i_Relation_Id Sm_Objects.Relation_Id%type,
    i_Object_Code in Sm_Objects.Object_Code%type
  ) return Sm_Objects%rowtype;

  ----
  -- objectni descruptionni qaytarish 
  ----
  Function Get_Object_Note
  (
    i_Object_Code in Sm_r_Objects.Object_Code%type,
    i_Relation_Id in number
  ) return varchar2;
  ----
  --
  ----
  Function Sm_Obj_Json_To_Obj(p_Json clob) return Sm_Object_t;
  ----
  --
  ----
  Function Obj_t_To_Json(p_Obj Sm_Object_t) return clob;
end Sm_Util;
/
create or replace package body Sm_Util is
  ----
  -- process sequence ni qaytarish
  ----
  Function Get_Next_Process_Id return number is
  begin
    return Sm_Processes_Sq.Nextval;
  end;
  ----
  -- objects sequence ni qaytarish
  ----
  Function Get_Next_Object_Id return number is
  begin
    return Sm_Objects_Sq.Nextval;
  end;
  ----
  -- process rowni qaytarish
  ----
  Function Get_r_Process(i_Process_Code in varchar2) return Sm_r_Processes%rowtype is
    v_Process Sm_r_Processes%rowtype;
  begin
    select t.*
      into v_Process
      from Sm_r_Processes t
     where t.Process_Code = i_Process_Code
       and t.State = Core.Core_Const.c_State_Active;
    return v_Process;
  exception
    when others then
      Raise_Application_Error(-20000,
                              'Процесс не найден. process_code:' || i_Process_Code);
  end;
  ----
  -- filialning local_codeni qaytaradi
  ----
  /* Function Get_Local_By_Filial(i_Filial_Code in varchar2) return varchar2 is
    result varchar2(5);
  begin
    select Local_Code
      into result
      from (select t.Local_Code
              from Mfi.Mfi_Branches t
             where t.Filial_Code = i_Filial_Code
             order by t.Local_Code)
     where Rownum = 1;
    return result;
  
  end;*/
  ----
  -- object rowni qaytarish
  ----
  Function Get_r_Object
  (
    i_Object_Code        in varchar2,
    i_Parent_Object_Code in varchar2 default 'ROOT'
  ) return Sm_r_Objects%rowtype is
    v_Object Sm_r_Objects%rowtype;
  begin
    select t.*
      into v_Object
      from Sm_r_Objects t
     where t.Object_Code = i_Object_Code
       and t.Parent_Object_Code = i_Parent_Object_Code
       and t.State = Core.Core_Const.c_State_Active;
    return v_Object;
  exception
    when others then
      Raise_Application_Error(-20001,
                              'Объект не найден. object_code:' || i_Object_Code);
  end;

  ----
  -- objectga tegishli keyingi actionni qaytaradi
  ----
  Function Get_Max_Object_Action_Step(i_Object_Code in varchar2) return number is
    result number(2);
  begin
  
    select max(t.Step)
      into result
      from Sm_Action_Role_Rel t
     where t.Object_Code = i_Object_Code;
    return result;
  end;

  ----
  -- objectga tegishli keyingi actionni qaytaradi
  ----
  Function Has_Object_Action_Route(i_Object_Code in varchar2) return boolean is
    v_Count number(1);
  begin
  
    select count(*)
      into v_Count
      from Sm_Action_Role_Rel t
     where t.Object_Code = i_Object_Code
       and Rownum = 1;
    if v_Count > 0 then
      return true;
    else
      return false;
    end if;
  end;
  ----
  -- userda shu object actioni uchun dostup borligini tekshiradi
  ----
  /* Function Has_Object_Action_Role
  (
    i_Object_Code in varchar2,
    i_Action_Id   in number,
    i_User_Id     in number
  ) return boolean is
    v_Count number(1);
  begin
  
    select count(*)
      into v_Count
      from Sm_Action_Role_Rel t, Crobs_V3.Core_User_Roles r
     where t.Object_Code = i_Object_Code
       and t.Action_Id = i_Action_Id
       and t.Role_Id = r.Role_Id
       and r.User_Id = i_User_Id
       and Rownum = 1;
    if v_Count > 0 then
      return true;
    else
      return false;
    end if;
  end;*/

  ----
  -- object, action roleni qaytaradi
  ----
  Function Get_Object_Action_Role
  (
    i_Object_Code in varchar2,
    i_Action_Id   in number
  ) return number is
    result number(10);
  begin
  
    select t.Role_Id
      into result
      from Sm_Action_Role_Rel t
     where t.Object_Code = i_Object_Code
       and t.Action_Id = i_Action_Id;
    return result;
  end;
  ----
  -- objectga tegishli keyingi actionni qaytaradi
  ----
  Function Get_Next_Object_Action
  (
    i_Object_Code in varchar2,
    i_Cur_Step    in number default 1
  ) return number is
    result number(2);
  begin
  
    select t.Action_Id
      into result
      from Sm_Action_Role_Rel t
     where t.Object_Code = i_Object_Code
       and t.Step = i_Cur_Step + 1;
    return result;
  end;

  ----
  -- objectga tegishli keyingi actionni qaytaradi
  ----
  Function Get_First_Object_Action(i_Object_Code in varchar2) return number is
    result number(2);
  begin
  
    select min(t.Action_Id)
      into result
      from Sm_Action_Role_Rel t
     where t.Object_Code = i_Object_Code;
    return result;
  end;
  ----
  -- Objectga tegishli relation idni aniqlaydi
  ----
  Function Get_Relation_Id
  (
    i_Object_Relation_Key in varchar2,
    i_Hash                in Core.Hash_t
  ) return number is
  begin
  
    return i_Hash.Get_Varchar2(i_Object_Relation_Key);
  end;
  ----
  -- Objectga tegishli parent relation idni aniqlaydi
  ----
  Function Get_Parent_Relation_Id
  (
    i_p_Object_Relation_Key in varchar2,
    i_Hash                  in Core.Hash_t
  ) return number is
  begin
  
    return i_Hash.Get_Varchar2(i_p_Object_Relation_Key);
  end;
  ----
  -- seq getter bo'yicha id olish
  ----
  Function Get_Next_Id_By_Getter(i_Getter in varchar2) return number is
    v_Id  number;
    v_Stm varchar2(500) := 'select ';
  begin
    if Instr(i_Getter, '.') > 0 then
      v_Stm := v_Stm || i_Getter || '  from dual';
    else
      v_Stm := v_Stm || i_Getter || '.NEXTVAL from dual';
    end if;
    execute immediate v_Stm
      into v_Id;
    return v_Id;
  end;
  ----
  -- contextdan user idni olish
  ----
  Function Get_Session_User_Id return number is
  begin
    return Sys_Context('USER_ENV', 'USER_ID');
  end;
  ----
  -- objectni object_codeni aniqlash
  ----
  Function Get_Object_Code(i_Object_Id in number) return varchar2 is
    result Sm_Objects.Object_Code%type;
  begin
    select t.Object_Code
      into result
      from Sm_Objects t
     where t.Object_Id = i_Object_Id;
    return result;
  end;
  ----
  -- relation orqali opject_idni aniqlash
  ----
  Function Get_Object_Id
  (
    i_Relation_Id in number,
    i_Object_Code in varchar2
  ) return number is
    result Sm_Objects.Object_Id%type;
  begin
    select t.Object_Id
      into result
      from Sm_Objects t
     where t.Relation_Id = i_Relation_Id
       and t.Object_Code = i_Object_Code;
    return result;
  end;

  ----
  -- object idga mos ota relation idni aniqlaydi
  ----
  Function Get_Parent_Relation_Id(i_Object_Id in number) return number is
    result Sm_Objects.Parent_Relation_Id%type;
  begin
    select t.Parent_Relation_Id
      into result
      from Sm_Objects t
     where t.Object_Id = i_Object_Id;
    return result;
  end;
  ----
  -- objectni object_codeni aniqlash
  ----
  Function Get_Object_Action_Control_Row
  (
    i_Object_Id   in number,
    i_Object_Code in varchar2
  ) return Sm_Object_Action_Controls%rowtype is
    result Sm_Object_Action_Controls%rowtype;
  begin
    select t.*
      into result
      from Sm_Object_Action_Controls t
     where t.Object_Id = i_Object_Id
       and t.Object_Code = i_Object_Code;
    return result;
  end;

  --
  --  objectda reject borligini qaytaradi boolean
  ----
  Function Is_Reject_Object_Action
  (
    i_Object_Id   in Sm_Object_Action_Controls.Object_Id%type,
    i_Object_Code in Sm_Object_Action_Controls.Object_Code%type
  ) return boolean is
    result  boolean := false;
    v_Count number := 0;
  begin
    select count(*)
      into v_Count
      from Sm_Object_Action_Controls t
     where t.Object_Id = i_Object_Id
       and t.Object_Code = i_Object_Code
       and t.State = Core.Core_Const.c_State_Reject
       and Rownum = 1;
    if v_Count > 0 then
      result := true;
    end if;
    return result;
  exception
    when others then
      return result;
  end;

  ----
  --  objectda approve borligini qaytaradi boolean
  ----
  Function Is_Approve_Object_Action
  (
    i_Object_Id   in Sm_Object_Action_Controls.Object_Id%type,
    i_Object_Code in Sm_Object_Action_Controls.Object_Code%type
  ) return boolean is
    result  boolean := false;
    v_Count number := 0;
  begin
    select count(*)
      into v_Count
      from Sm_Object_Action_Controls t
     where t.Object_Id = i_Object_Id
       and t.Object_Code = i_Object_Code
       and t.State = Core.Core_Const.c_State_Active
       and Rownum = 1;
    if v_Count > 0 then
      result := true;
    end if;
    return result;
  exception
    when others then
      return result;
  end;

  ----
  -- object_codeni short xolatini qaytaradi
  ----
  Function Get_Object_Short_Code(i_Object_Code Sm_r_Objects.Object_Code%type)
    return Sm_r_Object_Short_Codes.Short_Code%type is
    result Sm_r_Object_Short_Codes.Short_Code%type;
  begin
    select t.Short_Code
      into result
      from Sm_r_Object_Short_Codes t
     where t.Object_Code = i_Object_Code;
    return result;
  end;
  ----
  -- eventni execution modeni qaytaradi
  ----
  Function Get_Event_Execution_Mode
  (
    i_Process_Code in Sm_r_Processes.Process_Code%type,
    i_Event_Code   Sm_r_Events.Event_Code%type
  ) return Sm_r_Process_Events.Execution_Mode%type is
    result Sm_r_Process_Events.Execution_Mode%type;
  begin
    select t.Execution_Mode
      into result
      from Sm_r_Process_Events t
     where t.Event_Code = i_Event_Code
       and t.Process_Code = i_Process_Code;
    return result;
  end;
  ----
  -- object rowni qaytarish 
  ----
  Function Get_Object_Row(i_Object_Id Sm_Objects.Object_Id%type) return Sm_Objects%rowtype is
    result Sm_Objects%rowtype;
  begin
    select t.*
      into result
      from Sm_Objects t
     where t.Object_Id = i_Object_Id;
    return result;
  end;
  ----
  -- process event rowni qaytarish 
  ----
  Function Get_Process_Event(i_Process_Id Sm_Process_Events.Process_Id%type)
    return Sm_Process_Events%rowtype is
    result Sm_Process_Events%rowtype;
  begin
    select t.* --+ index_asc (t, SM_PROCESS_EVENTS_I2)
      into result
      from Sm_Process_Events t
     where t.Process_Id = i_Process_Id
       and t.State_Id in (Sm_Const.c_Event_State_Error, Sm_Const.c_Event_State_Enter)
       and Rownum = 1;
    return result;
  end;

  ----
  -- process rowni qaytarish 
  ----
  Function Get_Process(i_Process_Id Sm_Processes.Process_Id%type) return Sm_Processes%rowtype is
    result Sm_Processes%rowtype;
  begin
    select t.* --+ index_asc (t, SM_PROCESS_EVENTS_I2)
      into result
      from Sm_Processes t
     where t.Process_Id = i_Process_Id;
    return result;
  end;
  ----
  -- object rowni qaytarish 
  ----
  Function Get_Object_Row_By_Rel
  (
    i_Relation_Id Sm_Objects.Relation_Id%type,
    i_Object_Code in Sm_Objects.Object_Code%type
  ) return Sm_Objects%rowtype is
    result Sm_Objects%rowtype;
  begin
    select t.*
      into result
      from Sm_Objects t
     where t.Relation_Id = i_Relation_Id
       and t.Object_Code = i_Object_Code;
    return result;
  end;
  ----
  -- object nomini qaytarish 
  ----
  /*Function Get_Object_Name(i_Object_Code in Sm_r_Objects.Object_Code%type) return varchar2 is
    result varchar2(1000);
  begin
    select t.
      into result
      from Sm_r_Objects t
     where t.Object_Code = i_Object_Code
       and Rownum = 1;
    return result;
  end;*/
  ----
  -- objectni descruptionni qaytarish 
  ----
  Function Get_Object_Note
  (
    i_Object_Code in Sm_r_Objects.Object_Code%type,
    i_Relation_Id in number
  ) return varchar2 is
    result varchar2(500);
  begin
    select t.Action_Note
      into result
      from Sm_Objects t
     where t.Object_Code = i_Object_Code
       and t.Relation_Id = i_Relation_Id;
    return result;
  end;
  ----
  -- objectni bola shartnomalar arr qaytaradi
  ----
  Function Get_Object_Child_Ids
  (
    i_Object_Id    in number,
    i_Is_Only_Lead in boolean
  ) return Core.Array_Number is
    result Core.Array_Number := Core.Array_Number();
  begin
    if i_Is_Only_Lead then
      select t.Object_Id
        bulk collect
        into result
        from Sm_Objects t
       where t.Parent_Object_Id = i_Object_Id
         and t.Object_Code in (select Object_Code
                                 from Sm_r_Has_Lead_Objects);
    else
      select t.Object_Id
        bulk collect
        into result
        from Sm_Objects t
       where t.Parent_Object_Id = i_Object_Id;
    end if;
    return result;
  end;
  ----
  --
  ----
  Function Sm_Obj_Json_To_Obj(p_Json clob) return Sm_Object_t is
    v_Obj       Sm_Object_t := Sm_Object_t.Init();
    v_Sql       varchar2(32767);
    v_Type_Name varchar2(20) := 'SM_OBJECT_T';
  begin
    for r in (select Attr_Name, Attr_Type_Name
                from All_Type_Attrs
               where Type_Name = v_Type_Name
               order by Attr_No)
    loop
    
      v_Sql := 'DECLARE ' || '  v ' || v_Type_Name || ' := :1; ' || 'BEGIN ' || '  v.' ||
               r.Attr_Name || ' := ' || case r.Attr_Type_Name
                 when 'NUMBER' then
                  'TO_NUMBER(JSON_VALUE(:2, ''$.' || r.Attr_Name || '''));'
                 else
                  'JSON_VALUE(:2, ''$.' || r.Attr_Name || ''');'
               end || '  :1 := v; ' || 'END;';
    
      -- Faqat shu qator, yuqorida USING yo'q
      execute immediate v_Sql
        using in out v_Obj, in p_Json;
    
    end loop;
  
    return v_Obj;
  exception
    when others then
      Raise_Application_Error(-20001, 'sm_json_to_obj error: ' || sqlerrm);
  end;
  ----
  --
  ----
  Function Obj_t_To_Json(p_Obj Sm_Object_t) return clob is
    v_Json      clob;
    v_Val       varchar2(4000);
    v_First     boolean := true;
    v_Type_Name varchar2(20) := 'SM_OBJECT_T';
  
    -- Object fieldini dynamic o'qish
    Function Get_Field
    (
      p_Field varchar2,
      p_Ftype varchar2
    ) return varchar2 is
      v_Result varchar2(4000);
    begin
      execute immediate 'DECLARE ' || '  v ' || v_Type_Name || ' := :1; ' || 'BEGIN ' || '  :2 := ' ||
                        case p_Ftype
                          when 'NUMBER' then
                           'TO_CHAR(v.' || p_Field || ')'
                          else
                           'v.' || p_Field
                        end || '; ' || 'END;'
        using in p_Obj, out v_Result;
      return v_Result;
    exception
      when others then
        return null;
    end;
  
  begin
    v_Json := '{';
  
    for r in (select Attr_Name, Attr_Type_Name
                from All_Type_Attrs
               where Type_Name = Upper(v_Type_Name)
               order by Attr_No)
    loop
    
      v_Val := Get_Field(r.Attr_Name, r.Attr_Type_Name);
    
      if not v_First then
        v_Json := v_Json || ',';
      end if;
    
      v_Json := v_Json || '"' || r.Attr_Name || '":' || case
                  when v_Val is null then
                   '""'
                  when r.Attr_Type_Name = 'NUMBER' then
                   v_Val
                  else
                   '"' || replace(v_Val, '"', '\"') || '"'
                end;
    
      v_First := false;
    end loop;
  
    v_Json := v_Json || '}';
    return v_Json;
  end;
end Sm_Util;
/
