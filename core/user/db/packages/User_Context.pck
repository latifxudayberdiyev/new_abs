create or replace package User_Context is

  Procedure Init(i_User_Id number);
  Procedure Clear_Context;

  Function User_Id return number;
  Function Cb_Code return varchar2;
  Function Local_Code return varchar2;
  Function User_Name return varchar2;
  Function Language_Code return varchar2;
  Function Theme_Id return number;
  Function Is_Debug return varchar2;

  Function Has_Access
  (
    i_Access_Type varchar2,
    i_Access_Code varchar2
  ) return boolean;

  Function Has_Menu(i_Menu_Id number) return boolean;

  Function Has_Button
  (
    i_Menu_Id     number,
    i_Action_Code varchar2
  ) return boolean;

  Function Get_Menus return sys_refcursor;
  Function Get_Buttons return sys_refcursor;

  Procedure Check_Access
  (
    i_Access_Type varchar2,
    i_Access_Code varchar2
  );

  Procedure Check_Menu(i_Menu_Id number);

  Procedure Check_Button
  (
    i_Menu_Id     number,
    i_Action_Code varchar2
  );

  Function Oper_Day return date;

  Function Calendar_Day return date;

end User_Context;
/
create or replace package body User_Context is

  g_User_Id        core_Users.User_Id%type;
  g_Cb_Code       core_Users.Cb_Code%type;
  g_Local_Code    core_Users.Local_Code%type;
  g_User_Name     core_Users.Name%type;
  g_Language_Code core_Users.Language%type;
  g_Theme_Id      core_Users.Theme_Id%type;
  g_Debug         core_Users.Debug%type;
  g_Oper_Day      date := Trunc(sysdate);
  g_Calendar_Day  date := Trunc(sysdate);

  Procedure Clear_Context is
  begin
    delete from User_Accesses_Tmp;
    g_User_Id       := null;
    g_Cb_Code       := null;
    g_Local_Code    := null;
    g_User_Name     := null;
    g_Language_Code := null;
    g_Theme_Id      := null;
    g_Debug         := null;
  end Clear_Context;

  Procedure Load_User_Menus is
  begin
    insert into User_Accesses_Tmp
      (User_Id, Access_Type, Access_Code, Access_Name, Allow_Flag)
      select distinct g_User_Id, 'MODULE', Upper(m.Module_Code), m.Name_Mll_Code, 'Y'
        from ADM_REL_USER_MENUS Um
        join Core_r_Menus Mn
          on Mn.Menu_Id = Um.Menu_Id
         and Mn.State = 'A'
        join Core_r_Modules m
          on m.Module_Code = Mn.Module_Code
         and m.State = 'A'
       where Um.User_Id = g_User_Id
         and Um.State = 'A'
         and Trunc(sysdate) between Um.Date_Activate and Um.Date_Deactivate
      union
      select distinct g_User_Id, 'MENU', to_char(Mn.Menu_Id), Mn.Name_Mll_Code, 'Y'
        from ADM_REL_USER_MENUS Um
        join Core_r_Menus Mn
          on Mn.Menu_Id = Um.Menu_Id
         and Mn.State = 'A'
       where Um.User_Id = g_User_Id
         and Um.State = 'A'
         and Trunc(sysdate) between Um.Date_Activate and Um.Date_Deactivate;
  end Load_User_Menus;

  Procedure Load_User_Buttons is
  begin
    insert into User_Accesses_Tmp
      (User_Id, Access_Type, Access_Code, Access_Name, Allow_Flag)
      select distinct g_User_Id, 'BUTTON', Upper(b.Action_Code), b.Name_Mll_Code, 'Y'
        from ADM_REL_USER_BUTTONS Ub
        join Core_r_Menu_Buttons b
          on b.Menu_Id = Ub.Menu_Id
         and b.Button_Id = Ub.Button_Id
         and b.State = 'A'
        join Core_r_Menus Mn
          on Mn.Menu_Id = Ub.Menu_Id
         and Mn.State = 'A'
       where Ub.User_Id = g_User_Id
         and Ub.State = 'A'
         and Trunc(sysdate) between Ub.Date_Activate and Ub.Date_Deactivate
      union
      select distinct g_User_Id,
                      'MENU_BUTTON',
                      to_char(Ub.Menu_Id) || ':' || Upper(b.Action_Code),
                      b.Name_Mll_Code,
                      'Y'
        from ADM_REL_USER_BUTTONS Ub
        join Core_r_Menu_Buttons b
          on b.Menu_Id = Ub.Menu_Id
         and b.Button_Id = Ub.Button_Id
         and b.State = 'A'
        join Core_r_Menus Mn
          on Mn.Menu_Id = Ub.Menu_Id
         and Mn.State = 'A'
       where Ub.User_Id = g_User_Id
         and Ub.State = 'A'
         and Trunc(sysdate) between Ub.Date_Activate and Ub.Date_Deactivate;
  end Load_User_Buttons;

  Procedure Init(i_User_Id number) is
  begin
    Clear_Context;
    select u.User_Id, u.Cb_Code, u.Local_Code, u.Name, u.Language, u.Theme_Id, u.Debug
      into g_User_Id, g_Cb_Code, g_Local_Code, g_User_Name, g_Language_Code, g_Theme_Id, g_Debug
      from core_Users u
     where u.User_Id = i_User_Id
       and u.State = 'A'
       and u.Is_Access_Denied = 'N'
       and Trunc(sysdate) between u.Activate_Date and u.Deactivate_Date;
    Load_User_Menus;
    Load_User_Buttons;
  exception
    when No_Data_Found then
      Clear_Context;
      Raise_Application_Error(-20001, 'Foydalanuvchi topilmadi yoki aktiv emas');
  end Init;

  Function User_Id return number is
  begin
    return g_User_Id;
  end User_Id;

  Function Cb_Code return varchar2 is
  begin
    return g_Cb_Code;
  end Cb_Code;

  Function Local_Code return varchar2 is
  begin
    return g_Local_Code;
  end Local_Code;

  Function User_Name return varchar2 is
  begin
    return g_User_Name;
  end User_Name;

  Function Language_Code return varchar2 is
  begin
    return g_Language_Code;
  end Language_Code;

  Function Theme_Id return number is
  begin
    return g_Theme_Id;
  end Theme_Id;

  Function Is_Debug return varchar2 is
  begin
    return g_Debug;
  end Is_Debug;

  Function Has_Access
  (
    i_Access_Type varchar2,
    i_Access_Code varchar2
  ) return boolean is
    v_Count number;
  begin
    select count(*)
      into v_Count
      from User_Accesses_Tmp t
     where t.User_Id = g_User_Id
       and t.Access_Type = Upper(i_Access_Type)
       and t.Access_Code = Upper(i_Access_Code)
       and t.Allow_Flag = 'Y';
    return v_Count > 0;
  end Has_Access;

  Function Has_Menu(i_Menu_Id number) return boolean is
  begin
    return Has_Access('MENU', to_char(i_Menu_Id));
  end Has_Menu;

  Function Has_Button
  (
    i_Menu_Id     number,
    i_Action_Code varchar2
  ) return boolean is
  begin
    return Has_Access('MENU_BUTTON', to_char(i_Menu_Id) || ':' || Upper(i_Action_Code));
  end Has_Button;

  Function Get_Menus return sys_refcursor is
    v_Result sys_refcursor;
  begin
    open v_Result for
      select to_number(t.Access_Code) as Menu_Id, t.Access_Name as Menu_Name
        from User_Accesses_Tmp t
       where t.User_Id = g_User_Id
         and t.Access_Type = 'MENU'
         and t.Allow_Flag = 'Y'
       order by to_number(t.Access_Code);
    return v_Result;
  end Get_Menus;

  Function Get_Buttons return sys_refcursor is
    v_Result sys_refcursor;
  begin
    open v_Result for
      select to_number(Substr(t.Access_Code, 1, Instr(t.Access_Code, ':') - 1)) as Menu_Id,
             Substr(t.Access_Code, Instr(t.Access_Code, ':') + 1) as Action_Code,
             t.Access_Name as Button_Name
        from User_Accesses_Tmp t
       where t.User_Id = g_User_Id
         and t.Access_Type = 'MENU_BUTTON'
         and t.Allow_Flag = 'Y'
       order by to_number(Substr(t.Access_Code, 1, Instr(t.Access_Code, ':') - 1)),
                Substr(t.Access_Code, Instr(t.Access_Code, ':') + 1);
    return v_Result;
  end Get_Buttons;

  Procedure Check_Access
  (
    i_Access_Type varchar2,
    i_Access_Code varchar2
  ) is
  begin
    if not Has_Access(i_Access_Type, i_Access_Code) then
      Raise_Application_Error(-20002, 'Ruxsat yo''q: ' || i_Access_Type || ' / ' || i_Access_Code);
    end if;
  end Check_Access;

  Procedure Check_Menu(i_Menu_Id number) is
  begin
    if not Has_Menu(i_Menu_Id) then
      Raise_Application_Error(-20002, 'Menu uchun ruxsat yo''q: ' || i_Menu_Id);
    end if;
  end Check_Menu;

  Procedure Check_Button
  (
    i_Menu_Id     number,
    i_Action_Code varchar2
  ) is
  begin
    if not Has_Button(i_Menu_Id, i_Action_Code) then
      Raise_Application_Error(-20002,
                              'Button uchun ruxsat yo''q: ' || i_Menu_Id || ' / ' || i_Action_Code);
    end if;
  end Check_Button;

  Function Oper_Day return date is
  begin
    return g_Oper_Day;
  end;

  Function Calendar_Day return date is
  begin
    return g_Calendar_Day;
  end;

end User_Context;
/
