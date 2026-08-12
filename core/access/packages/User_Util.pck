create or replace package User_Util is

  -- Author  : B.URALOV
  -- Created : 23.06.2026 10:36:09
  -- Purpose : 
  Function Has_User_Menu
  (
    i_User_Id in number,
    i_Menu_Id in number
  ) return boolean;
end User_Util;
/
create or replace package body User_Util is
  Function Has_User_Menu
  (
    i_User_Id in number,
    i_Menu_Id in number
  ) return boolean is
    v_Count pls_integer := 0;
  begin
    select count(*)
      into v_Count
      from Core_Rel_User_Menus t
     where t.User_Id = i_User_Id
       and t.Menu_Id = i_Menu_Id
       and t.State = Core_Const.c_State_Active
       and Rownum = 1;
    if v_Count > 0 then
      return true;
    else
      return false;
    end if;
  end;
end User_Util;
/
