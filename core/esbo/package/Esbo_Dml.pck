create or replace package Esbo_Dml is

  -- Author  : B.URALOV
  -- Created : 02.04.2026 13:59:46
  -- Purpose : 
  Procedure Set_Service_Token
  (
    i_Service_Code in varchar2,
    i_Token        in varchar2
  );
  Procedure Insert_Log(i_Row Esbo_Requests%rowtype);
  --Update log
  Procedure Update_Log(i_Row Esbo_Requests%rowtype);
end Esbo_Dml;
/
create or replace package body Esbo_Dml is
  Procedure Set_Service_Token
  (
    i_Service_Code in varchar2,
    i_Token        in varchar2
  ) is
    pragma autonomous_transaction;
  begin
    update Esbo_Service_Settings t
       set t.Param_Value = i_Token,
           t.Created_On  = sysdate
     where t.Service_Code = i_Service_Code
       and t.Param_Code = Esbo_Const.c_Pc_Token;
    if sql%rowcount = 0 then
      insert into Esbo_Service_Settings
        (Service_Code, Param_Code, Param_Value, Description, Created_On)
      values
        (i_Service_Code, Esbo_Const.c_Pc_Token, i_Token, 'token', sysdate);
    end if;
    commit;
  end;
  --Insert log
  Procedure Insert_Log(i_Row Esbo_Requests%rowtype) is
    pragma autonomous_transaction;
  begin
    insert into Esbo_Requests
    values i_Row;
    commit;
  end;
  --Update log
  Procedure Update_Log(i_Row Esbo_Requests%rowtype) is
    pragma autonomous_transaction;
  begin
    update Esbo_Requests
       set row = i_Row
     where Id = i_Row.Id;
    commit;
  end;
end Esbo_Dml;
/
