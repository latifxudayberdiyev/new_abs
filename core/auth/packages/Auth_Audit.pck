create or replace package Auth_Audit is
  -- Author      : CROBS
  -- Created     : 18.05.2026
  -- Назначение  : Журнал аудита аутентификации. Автономный, чтобы запись сохранялась
  --               даже при откате вызывающей транзакции.
  ----------------------------------------------------------------------------------------------------
  Procedure Log
  (
    i_Event_Type   varchar2,
    i_Success      varchar2,
    i_Username     varchar2 := null,
    i_User_Id      number   := null,
    i_Provider     varchar2 := null,
    i_Reason_Code  varchar2 := null,
    i_Client_Ip    varchar2 := null,
    i_User_Agent   varchar2 := null,
    i_Session_Hash varchar2 := null
  );
  ----------------------------------------------------------------------------------------------------
end Auth_Audit;
/
create or replace package body Auth_Audit is
  ----------------------------------------------------------------------------------------------------
  Procedure Log
  (
    i_Event_Type   varchar2,
    i_Success      varchar2,
    i_Username     varchar2 := null,
    i_User_Id      number   := null,
    i_Provider     varchar2 := null,
    i_Reason_Code  varchar2 := null,
    i_Client_Ip    varchar2 := null,
    i_User_Agent   varchar2 := null,
    i_Session_Hash varchar2 := null
  ) is
    pragma autonomous_transaction;
  begin
    insert into Auth_Audit_Log
      (Log_Id, Event_On, Event_Type, Username_Tried, User_Id, Provider_Type,
       Reason_Code, Success, Client_Ip, User_Agent, Session_Id_Hash)
    values
      (Auth_Audit_Log_Sq.Nextval,
       sysdate,
       i_Event_Type,
       Substr(i_Username, 1, 100),
       i_User_Id,
       i_Provider,
       Substr(i_Reason_Code, 1, 40),
       Nvl(i_Success, 'N'),
       Substr(i_Client_Ip, 1, 45),
       Substr(i_User_Agent, 1, 400),
       i_Session_Hash);
    commit;
  exception
    when others then
      -- аудит никогда не должен ломать процесс аутентификации
      rollback;
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Audit;
/
