create or replace package Process_Mngr is
  Version constant char(14) := '->>20072007<<-';

  -- Check_Running Writeprotocol error kodlari
  c_Err_Already_Active constant number := 20001; -- process allaqachon faol (bandmi)
  c_Err_Already_Queued constant number := 20002; -- process navbatda kutmoqda
  c_Err_Unknown_State  constant number := 20003; -- Register noma'lum holat qaytardi

  Function Check_Running
  (
    Handle   out varchar2,
    Procname varchar2
  ) return binary_integer;

  Function Getpercentdone
  (
    Targetname varchar2,
    Defvalue   binary_integer := null
  ) return binary_integer;

  Function Register
  (
    Handle      out varchar2,
    Processname varchar2,
    Isunique    boolean := true,
    Timeout     binary_integer := 15
  ) return binary_integer;

  Procedure Process_Start
  (
    Processname varchar2 := null,
    Actionname  varchar2 := null,
    Targetname  varchar2 := null
  );

  Procedure Process_Stop(Percentdone binary_integer := 100);

  Procedure Setpercentdone(Percentdone binary_integer);

  Procedure Unregister(Handle varchar2);

  Procedure Writeprotocol
  (
    Errorcode number,
    Procname  varchar2,
    Errormsg  varchar2
  );

end Process_Mngr;
/
create or replace package body Process_Mngr is
  Rindex      binary_integer := Dbms_Application_Info.Set_Session_Longops_Nohint;
  Slno        binary_integer;
  Action_Name varchar2(32) := null;
  Target_Name varchar2(32) := null;

  Function Check_Running
  (
    Handle   out varchar2,
    Procname varchar2
  ) return binary_integer is
  begin
    case Register(Handle, Procname, true)
      when 0 then
        return 0;
      when 1 then
        Writeprotocol(c_Err_Already_Active,
                      Procname,
                      'Ошибка запуска процедуры "' || Procname ||
                      '": Попытка повторного запуска процедуры внутри одного процесса (сессии).');
        return 1;
      when 2 then
        Writeprotocol(c_Err_Already_Queued,
                      Procname,
                      'Ошибка запуска процедуры "' || Procname ||
                      '": Процедура уже запущена другим процессом (сессией).');
        return 2;
    end case;
    Writeprotocol(c_Err_Unknown_State,
                  Procname,
                  'Ошибка запуска процедуры "' || Procname || '": Неизвестная ошибка.');
    return 3;
  end Check_Running;

  Function Getpercentdone
  (
    Targetname varchar2,
    Defvalue   binary_integer := null
  ) return binary_integer is
    result binary_integer;
  begin
    select t.Sofar
      into result
      from Gv$session_Longops t
     where t.Target_Desc = Targetname
       and Rownum = 1;
    return result;
  exception
    when others then
      return Defvalue;
  end Getpercentdone;

  Procedure Allocate_Unique_Autonomous
  (
    i_Process_Name in varchar2,
    o_Lock_Handle  out varchar2
  ) is
    pragma autonomous_transaction;
  begin
    Sys.Dbms_Lock.Allocate_Unique(i_Process_Name, o_Lock_Handle);
    commit;
  exception
    when others then
      rollback;
  end Allocate_Unique_Autonomous;

  Function Register
  (
    Handle      out varchar2,
    Processname varchar2,
    Isunique    boolean := true,
    Timeout     binary_integer := 15
  ) return binary_integer is
    Lockmode binary_integer := Dbms_Lock.s_Mode;
  begin
    if Isunique then
      Lockmode := Dbms_Lock.x_Mode;
    end if;
    $IF DBMS_DB_VERSION.VERSION < 12 $THEN
    Allocate_Unique_Autonomous('UPN_' || Processname, Handle);
    $ELSE
  
    Dbms_Lock.Allocate_Unique_Autonomous('UPN_' || Processname, Handle);
    $END
  
    return Dbms_Lock.Request(Handle, Lockmode, Timeout, false);
  end Register;

  Procedure Process_Start
  (
    Processname varchar2 := null,
    Actionname  varchar2 := null,
    Targetname  varchar2 := null
  ) is
  begin
    Rindex      := Dbms_Application_Info.Set_Session_Longops_Nohint;
    Action_Name := Substr(Nvl(Actionname, Processname), 1, 32);
    Target_Name := Substr(Nvl(Targetname, Action_Name), 1, 32);
    if Processname is not null then
      Dbms_Application_Info.Set_Module(Processname, Actionname);
    end if;
    Setpercentdone(0);
  end Process_Start;

  Procedure Process_Stop(Percentdone binary_integer := 100) is
  begin
    Setpercentdone(Percentdone);
  end Process_Stop;

  Procedure Setpercentdone(Percentdone binary_integer) is
  begin
    Dbms_Application_Info.Set_Action(Action_Name || ' (' || Percentdone || '%)');
    Dbms_Application_Info.Set_Session_Longops(Rindex,
                                              Slno,
                                              Action_Name,
                                              0,
                                              Sys_Context('USER', 'SESSIONID'),
                                              Percentdone,
                                              100,
                                              Target_Name,
                                              '%');
  end Setpercentdone;

  Procedure Unregister(Handle varchar2) is
    Dummy binary_integer;
  begin
    Dummy := Dbms_Lock.Release(Handle);
  end Unregister;

  Procedure Writeprotocol
  (
    Errorcode number,
    Procname  varchar2,
    Errormsg  varchar2
  ) is
    pragma autonomous_transaction;
  begin
    insert into Process_Protocol
      (Id, Proc_Name, error_code, Error_Msg)
    values
      (Seq_Process_Protocol.Nextval, Procname, Errorcode, Errormsg);
    commit;
  exception
    when others then
      null;
  end Writeprotocol;

end Process_Mngr;
/
