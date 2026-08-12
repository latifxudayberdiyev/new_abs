create or replace package Sm_Control is

  -- Author  : B.URALOV
  -- Created : 05.05.2025 10:56:52
  -- Purpose :
  ----
  -- approverlarni formaga chiqarish
  ----
  Procedure Get_Action_Role_Relation
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  -- approverlarni qo'shish
  ----
  Procedure Add_Action_Role_Relation
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  -- approverlarga objectlarni qo'shish
  ----
  Procedure Set_Object_Action_Control
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  -- userda shu object actioni uchun dostup borligini tekshiradi
  ----
  Procedure Is_User_Action_Allowed
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  -- keyni jsondan qiymatini olib beradi
  ----
  Function Get_Json_Param_Errors return varchar2;
  ----
  -- approverlarni qo'shish
  ----
  Function Check_Process_Params(i_Process_Code in varchar2) return boolean;
  ----
  -- approverlarni tekshirish
  ----
  Function Check_Object_Action_Control
  (
    Io_Hash     in out Core.Hash_t,
    Io_Object_t in out Sm_Object_t
  ) return boolean;
end Sm_Control;
/
create or replace package body Sm_Control is

  ----
  -- objectni reject qilish
  ----
  Procedure Reject_Object_Control(Io_Object_t in out Sm_Object_t) is
    v_Action_Control Sm_Object_Action_Controls%rowtype;
  begin
    Io_Object_t.o_Code := 0;

    v_Action_Control.Object_Code := Io_Object_t.Object_Code;
    v_Action_Control.Object_Id   := Io_Object_t.Object_Id;
    -- row
    v_Action_Control       := Sm_Util.Get_Object_Action_Control_Row(v_Action_Control.Object_Id,
                                                                    v_Action_Control.Object_Code);
    v_Action_Control.State := Core.Core_Const.c_State_Reject;
    Sm_Dml.Update_Object_Action_Control(v_Action_Control);
  exception
    when others then
      Io_Object_t.o_Code    := -999;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_SYSTEM_ERROR', i_Params => null, o_Code => v_Ml_Code, o_Msg => Io_Object_t.o_Msg);
      end;
      Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || sqlerrm || ' ' ||
                               Dbms_Utility.Format_Error_Backtrace;
  end;
  ----
  -- approverlarga objectlarni qo'shish
  ----
  Procedure Set_Object_Action_Control
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Action_Controls Sm_Object_Action_Controls%rowtype;
    v_Sm_Cache        Core.Hash_t := Core.Hash_t();
  begin
    o_Code := Sm_Const.c_Success_Code;
    --
    v_Sm_Cache                    := Io_Hash.Get_Optional_Hash_t('sm_cache');
    v_Action_Controls.Object_Code := v_Sm_Cache.Get_Optional_Varchar2('object_code');
    v_Action_Controls.Object_Id   := v_Sm_Cache.Get_Optional_Number('object_id');
    -- agar route object uchun yaratilmagan bo'lsa chiqib ketamiz
    if not Sm_Util.Has_Object_Action_Route(i_Object_Code => v_Action_Controls.Object_Code) then
      return;
    end if;
    -- row
    v_Action_Controls.Cur_Action_Id := Sm_Util.Get_First_Object_Action(i_Object_Code => v_Action_Controls.Object_Code);
    v_Action_Controls.Cur_Step      := 1;

    v_Action_Controls.State := Core.Core_Const.c_State_Passive;
    --
    Sm_Dml.Insert_Object_Action_Control(i_Object_Action => v_Action_Controls);
  exception
    when others then
      o_Code    := -999;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_SYSTEM_ERROR', i_Params => null, o_Code => v_Ml_Code, o_Msg => o_Msg);
      end;
      o_Ora_Msg := o_Msg || ' ' || sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----
  -- approverlarga objectlarni qo'shish
  ----
  Procedure Set_Next_Step_Action_Control(Io_Object_t in out Sm_Object_t) is
    v_Action_Controls Sm_Object_Action_Controls%rowtype;
  begin
    Io_Object_t.o_Code := Sm_Const.c_Success_Code;
    --
    v_Action_Controls.Object_Code := Io_Object_t.Object_Code;
    v_Action_Controls.Object_Id   := Io_Object_t.Object_Id;
    v_Action_Controls             := Sm_Util.Get_Object_Action_Control_Row(i_Object_Id   => v_Action_Controls.Object_Id,
                                                                           i_Object_Code => v_Action_Controls.Object_Code);
    --
    v_Action_Controls.Cur_Action_Id := Sm_Util.Get_Next_Object_Action(i_Object_Code => v_Action_Controls.Object_Code,
                                                                      i_Cur_Step    => v_Action_Controls.Cur_Action_Id);

    -- userda tegishli role borligi i tekshiramiz
   /* if not Sm_Util.Has_Object_Action_Role(i_Object_Code => v_Action_Controls.Object_Code,
                                          i_Action_Id   => v_Action_Controls.Cur_Action_Id,
                                          i_User_Id     => Core.User_Env.Get_User_Id) then
      Io_Object_t.o_Code    := 260;
      Io_Object_t.o_Msg     := 'У пользователя нет необходимой роли для выполнения этого действия.';
      Io_Object_t.o_Ora_Msg := 'У пользователя нет необходимой роли для выполнения этого действия.';
    end if;*/
    v_Action_Controls.Cur_Step := v_Action_Controls.Cur_Step + 1;
    v_Action_Controls.State := case
                                 when v_Action_Controls.Cur_Step =
                                      Sm_Util.Get_Max_Object_Action_Step(i_Object_Code => v_Action_Controls.Object_Code) then
                                  Core.Core_Const.c_State_Active
                                 else
                                  Core.Core_Const.c_State_Passive
                               end;
    --
    Sm_Dml.Update_Object_Action_Control(i_Object_Action => v_Action_Controls);
  exception
    when others then
      Io_Object_t.o_Code    := -999;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_SYSTEM_ERROR', i_Params => null, o_Code => v_Ml_Code, o_Msg => Io_Object_t.o_Msg);
      end;
      Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' || sqlerrm || ' ' ||
                               Dbms_Utility.Format_Error_Backtrace;
  end;
  ----
  -- approverlarni tekshirish
  ----
  Function Check_Object_Action_Control
  (
    Io_Object_t   in out Sm_Object_t,
    i_Is_Approved in varchar2
  ) return boolean is
  begin

    Io_Object_t.o_Code := Sm_Const.c_Success_Code;
    --
    if Sm_Util.Is_Approve_Object_Action(i_Object_Id   => Io_Object_t.Object_Id,
                                        i_Object_Code => Io_Object_t.Object_Code) then
      return true;
    end if;
    -- reject berilganini tekshirish
    if Sm_Util.Is_Reject_Object_Action(Io_Object_t.Object_Id, Io_Object_t.Object_Code) then      Io_Object_t.o_Code    := 226;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_OBJECT_REJECTED', i_Params => null, o_Code => v_Ml_Code, o_Msg => Io_Object_t.o_Msg);
      end;
      Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg || ' ' ||
                               Dbms_Utility.Format_Error_Backtrace;
      return false;
    end if;
    --
    if i_Is_Approved = 'Y' then
      Set_Next_Step_Action_Control(Io_Object_t);
      if Sm_Util.Is_Approve_Object_Action(i_Object_Id   => Io_Object_t.Object_Id,
                                          i_Object_Code => Io_Object_t.Object_Code) then
        return true;
      end if;
    else
      Reject_Object_Control(Io_Object_t => Io_Object_t);
    end if;

    return false;
    --
  end;
  ----
  -- approverlarni tekshirish
  ----
  Function Check_Object_Action_Control
  (
    Io_Hash     in out Core.Hash_t,
    Io_Object_t in out Sm_Object_t
  ) return boolean is
    v_Action_Id number;
  begin

    Io_Object_t.o_Code := Sm_Const.c_Success_Code;
    v_Action_Id        := Io_Hash.Get_Optional_Number('action_id');
    --
    if v_Action_Id is null then      Io_Object_t.o_Code    := 261;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_ACTION_ID_REQUIRED', i_Params => null, o_Code => v_Ml_Code, o_Msg => Io_Object_t.o_Msg);
      end;
      Io_Object_t.o_Ora_Msg := Io_Object_t.o_Msg;
      return false;
    end if;
   /* if not Sm_Util.Has_Object_Action_Role(i_Object_Code => Io_Object_t.Object_Code,
                                          i_Action_Id   => v_Action_Id,
                                          i_User_Id     => Core.User_Env.Get_User_Id) then
      Io_Object_t.o_Code    := 260;
      Io_Object_t.o_Msg     := 'У пользователя нет необходимой роли для выполнения этого действия.';
      Io_Object_t.o_Ora_Msg := 'У пользователя нет необходимой роли для выполнения этого действия.';
      return false;
    else
      return true;
    end if;*/
    --
  end;
  ----
  -- userda shu object actioni uchun dostup borligini tekshiradi
  ----
  Procedure Is_User_Action_Allowed
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_User_Id     number;
    v_Object_Code varchar2(200);
    v_Action_Id   number;
    v_Data        Core.Hash_t := Core.Hash_t();
  begin
    o_Code := Sm_Const.c_Success_Code;
    --
    v_User_Id     := Io_Hash.Get_Optional_Number('user_id');
    v_Object_Code := Io_Hash.Get_Optional_Varchar2('object_code');
    v_Action_Id   := Io_Hash.Get_Optional_Number('action_id');
    --
    -- userda tegishli role borligi i tekshiramiz
   /* if not Sm_Util.Has_Object_Action_Role(i_Object_Code => v_Object_Code,
                                          i_Action_Id   => v_Action_Id,
                                          i_User_Id     => v_User_Id) then
      v_Data.Put('allowed', 'false');
    else
      v_Data.Put('allowed', 'true');
    end if;*/
    Io_Hash.Put('data', v_Data);
  exception
    when others then
      o_Code    := -999;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_SYSTEM_ERROR', i_Params => null, o_Code => v_Ml_Code, o_Msg => o_Msg);
      end;
      o_Ora_Msg := o_Msg || ' ' || sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;

  ----
  -- approverlarni formaga chiqarish
  ----
  Procedure Get_Action_Role_Relation
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Roles       Core.Arraylist := Core.Arraylist();
    v_Role_Hash   Core.Hash_t := Core.Hash_t();
    v_Data        Core.Hash_t := Core.Hash_t();
    v_Object_Code varchar2(100);
  begin
    v_Object_Code := Io_Hash.Get_Optional_Varchar2('object_code');
    /* for s in (select b.Role_Id,
                     b.Action_Id,
                     (select Label
                        from Object_Actions_v t
                       where Code = b.Action_Id) Action_Label,
                     Nvl(b.Step, Rownum) Step
                from Sm_Action_Role_Rel b
               where b.Object_Code = v_Object_Code)
    loop
      v_Role_Hash := Core.Hash_t();
      v_Role_Hash.Put('role_id', s.Role_Id);
      v_Role_Hash.Put('action_id', s.Action_Id);
      v_Role_Hash.Put('action_label', s.Action_Label);
      v_Role_Hash.Put('step', s.Step);
      v_Roles.Push(v_Role_Hash);
      -- insert
    end loop;*/
    v_Data.Put('object_code', v_Object_Code);
    v_Data.Put('roles', v_Roles);
    Io_Hash.Put('data', v_Data);
    o_Code := 0;
    o_Msg  := '';
  exception
    when others then
      o_Code    := -999;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_SYSTEM_ERROR', i_Params => null, o_Code => v_Ml_Code, o_Msg => o_Msg);
      end;
      o_Ora_Msg := o_Msg || ' ' || sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----
  -- approverlarni qo'shish
  ----
  Procedure Add_Action_Role_Relation
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Role_Rel  Sm_Action_Role_Rel%rowtype;
    v_Roles     Core.Arraylist := Core.Arraylist();
    v_Role_Hash Core.Hash_t := Core.Hash_t();
  begin
    v_Roles                := Io_Hash.Get_Optional_Arraylist('roles');
    v_Role_Rel.Object_Code := Io_Hash.Get_Optional_Varchar2('object_code');
    -- delete all old data
    Sm_Dml.Delete_Action_Role_Rel(v_Role_Rel.Object_Code);
    for i in 1 .. v_Roles.Count
    loop
      v_Role_Hash          := Treat(v_Roles.Get_r_Hash_t(i) as Core.Hash_t);
      v_Role_Rel.Role_Id   := v_Role_Hash.Get_Optional_Number('role_id');
      v_Role_Rel.Action_Id := v_Role_Hash.Get_Optional_Number('action_id');
      v_Role_Rel.Step      := v_Role_Hash.Get_Optional_Number('step');
      -- insert
      Sm_Dml.Insert_Action_Role_Rel(v_Role_Rel);
    end loop;
    o_Code := 0;
    o_Msg  := '';
  exception
    when others then
      o_Code    := -999;
      declare
        v_Ml_Code number;
      begin
        Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_SYSTEM_ERROR', i_Params => null, o_Code => v_Ml_Code, o_Msg => o_Msg);
      end;
      o_Ora_Msg := o_Msg || ' ' || sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----
  -- parameter uzunligini tekshirish
  ----
  Function Check_Param_Length
  (
    i_Min_Length in number,
    i_Max_Length in number,
    i_Value      in varchar2
  ) return boolean is
    v_Length number := Length(i_Value);
  begin
    if v_Length > Nvl(i_Max_Length, 4000) or v_Length < Nvl(i_Min_Length, 0) then
      return false;
    end if;
    return true;
  end;
  ----
  -- paramter number bo'lsa uni numberga tekshirish
  ----
  Function Check_Number_Type(i_Param_Value in varchar2) return boolean is
    v_Number number;
  begin
    v_Number := to_number(i_Param_Value);
    return true;
    if v_Number is null then
      null; -- Hech qanday amalda ishlatilmaydi
    end if;
  exception
    when others then
      return false;
  end;
  ----
  -- paramter date bo'lsa uni datega tekshirish
  ----
  Function Check_Date_Type(i_Param_Value in varchar2) return boolean is
    v_Date date;
  begin
    v_Date := to_date(i_Param_Value);
    return true;
    if v_Date is null then
      null; -- Hech qanday amalda ishlatilmaydi
    end if;
  exception
    when others then
      return false;
  end;
  ----
  -- keyni jsonda mavjudligini tekshiramiz
  ----
  Function Has_Key_In_Json(i_Key in varchar2) return boolean is
    v_Count number := 0;
  begin
    select count(*)
      into v_Count
      from Core.Temp_Json_Data t
     where t.Key_Name = i_Key
       and Rownum = 1;
    if v_Count = 0 then
      return false;
    else
      return true;
    end if;
  end;
  ----
  -- kelgan jsonda xato mavjudligini tekshirish
  ----
  Function Has_Json_Err return boolean is
    v_Count number := 0;
  begin
    select count(*)
      into v_Count
      from Sm_Param_Protocols
     where Rownum = 1;
    if v_Count = 0 then
      return false;
    else
      return true;
    end if;
  end;
  ----
  -- keyni jsondan qiymatini olib beradi
  ----
  Function Get_Key_Value(i_Key in varchar2) return Core.Array_Varchar2 is
    v_Arr Core.Array_Varchar2 := Core.Array_Varchar2();
  begin
    select t.Key_Value
      bulk collect
      into v_Arr
      from Core.Temp_Json_Data t
     where t.Key_Name = i_Key;
    return v_Arr;
  end;
  ----
  -- keyni jsondan qiymatini olib beradi
  ----
  Function Get_Json_Param_Errors return varchar2 is
    v_Arr Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Err varchar2(3000);
  begin
    select t.Err_Msg
      bulk collect
      into v_Arr
      from Sm_Param_Protocols t;
    for i in v_Arr.First .. v_Arr.Last
    loop
      if Length(v_Err) >= 2500 then
        continue;
      else
        v_Err := v_Err || ' ' || v_Arr(i);
      end if;
    end loop;
    return v_Err;
  end;
  ----
  -- approverlarni qo'shish
  ----
  Function Check_Process_Params(i_Process_Code in varchar2) return boolean is
    v_Values Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Code   number := 0;
    v_Msg    varchar2(4000);
  begin
    for Params in (select s.*, t.Is_Required
                     from Sm_r_Process_Param_Rel t, Sm_r_Param_Settings s
                    where t.Process_Code = i_Process_Code
                      and t.State = Core.Core_Const.c_State_Active
                      and s.Param_Key = t.Param_Key)
    loop
      -- agar parameter IS_REQUIRED bo'lsa
      if Params.Is_Required = 'Y' and not Has_Key_In_Json(Params.Param_Key) then
        v_Code := '228';
      declare
          v_Ml_Code number;
        begin
          Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_PARAM_REQUIRED', i_Param1 => Params.Param_Key, o_Code => v_Ml_Code, o_Msg => v_Msg);
        end;
        Sm_Dml.Insert_Param_Protocol(i_Process_Code => i_Process_Code,
                                     i_Code         => v_Code,
                                     i_Msg          => v_Msg,
                                     i_Param_Value  => '');
      end if;
      v_Values := Get_Key_Value(Params.Param_Key);
      if v_Values.Count = 0 then
        continue;
      end if;
      -- qiymatlar ustida ishlash
      for i in 1 .. v_Values.Count
      loop
        -- number typega tekshirish
        if not Check_Number_Type(v_Values(i)) and Params.Param_Type = Sm_Const.c_Param_Type_Number then
          v_Code := '227';
      declare
            v_Ml_Code number;
          begin
            Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_PARAM_NOT_NUMBER', i_Param1 => Params.Param_Key, o_Code => v_Ml_Code, o_Msg => v_Msg);
          end;
          Sm_Dml.Insert_Param_Protocol(i_Process_Code => i_Process_Code,
                                       i_Code         => v_Code,
                                       i_Msg          => v_Msg,
                                       i_Param_Value  => v_Values(i));
        end if;
        -- date typega tekshirish
        if not Check_Date_Type(v_Values(i)) and Params.Param_Type = Sm_Const.c_Param_Type_Date then
          v_Code := '230';
      declare
            v_Ml_Code number;
          begin
            Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_PARAM_NOT_DATE', i_Param1 => Params.Param_Key, o_Code => v_Ml_Code, o_Msg => v_Msg);
          end;
          Sm_Dml.Insert_Param_Protocol(i_Process_Code => i_Process_Code,
                                       i_Code         => v_Code,
                                       i_Msg          => v_Msg,
                                       i_Param_Value  => v_Values(i));
        end if;
        -- qiymat uzunligini tekshiramiz
        if not Check_Param_Length(Params.Min_Length, Params.Max_Length, v_Values(i)) then
          v_Code := '229';
      declare
            v_Ml_Code number;
          begin
            Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_PARAM_OUT_OF_RANGE', i_Param1 => to_char(Params.Min_Length), i_Param2 => to_char(Params.Max_Length), i_Param3 => to_char(Length(v_Values(i))), o_Code => v_Ml_Code, o_Msg => v_Msg);
          end;
          Sm_Dml.Insert_Param_Protocol(i_Process_Code => i_Process_Code,
                                       i_Code         => v_Code,
                                       i_Msg          => v_Msg,
                                       i_Param_Value  => v_Values(i));
        end if;
      end loop;
    end loop;

    if Has_Json_Err then
      return true;
    else
      return false;
    end if;

  end;

end Sm_Control;
/
