create or replace package User_Env is

  -- Author  : LATIF
  -- Created : 15.04.2025 11:58:57
  -- Purpose : 
  --====================================================
  Function Get_User_Id return number;
  --====================================================
  Function Get_User_Type_Id return number;
  --====================================================
  Function Get_Filial_Code return varchar2;
  --====================================================
  Function Get_User_Location return varchar2;
  --====================================================
  Function Get_Local_Code return varchar2;
  --====================================================
  Function Get_Lang return varchar2;
  --====================================================
  Function Get_Format_Date return varchar2;
  --====================================================
  Function Get_Oper_Day return date;
  --====================================================
  Function Get_Calendar_Day return date;
end User_Env;
/
create or replace package body User_Env is
  s_Context_Name varchar2(100) := 'UAPP';
  --====================================================
  Function Get_User_Id return number is
  begin
    return Sys_Context(s_Context_Name, 'user_id');
  end;
  --====================================================
  Function Get_User_Type_Id return number is
  begin
    return Sys_Context(s_Context_Name, 'user_type_id');
  end;
  --====================================================
  Function Get_Filial_Code return varchar2 is
  begin
    return Sys_Context(s_Context_Name, 'cb_code');
  end;
  --====================================================
  Function Get_User_Location return varchar2 is
  begin
    return Sys_Context(s_Context_Name, 'user_location');
  end;
  --====================================================
  Function Get_Local_Code return varchar2 is
  begin
    return Sys_Context(s_Context_Name, 'local_code');
  end;
  --====================================================
  Function Get_Lang return varchar2 is
  begin
    return Sys_Context(s_Context_Name, 'lang');
  end;
  --====================================================
  Function Get_Format_Date return varchar2 is
  begin
    return 'dd.mm.yyyy';
  end;
  --====================================================
  Function Get_Oper_Day return date is
  begin
    return Nvl(to_date(Sys_Context(s_Context_Name, 'oper_day'), 'dd.mm.yyyy'), Trunc(sysdate));
  end;
  --====================================================
  Function Get_Calendar_Day return date is
  begin
    return Trunc(sysdate);
  end;

end User_Env;
/
