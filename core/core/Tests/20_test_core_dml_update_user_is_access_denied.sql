----------------------------------------------------------------------------------------------------
--  Core_Dml.Update_User: Is_Access_Denied UPDATE'da yozilishini tekshiradi.
--  Bug: bu ustun Update_User'ning diff-check va SET ro'yxatida umuman yo'q edi -
--  Core_Kernel.Save_User orqali is_access_denied='N' yuborilsa ham bazaga tushmasdi.
--  Ishga tushirish: sqlplus core/*** @core/Tests/20_test_core_dml_update_user_is_access_denied.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited
set define off;

declare
  v_Pass number := 0;
  v_Fail number := 0;
  c_Uid  constant number := 999999940;
  v_Row  Core_Users%rowtype;
  --------------------------------------------------
  Procedure Assert
  (
    i_Name varchar2,
    i_Cond boolean
  ) is
  begin
    if i_Cond then
      v_Pass := v_Pass + 1;
      Dbms_Output.Put_Line('  PASS  ' || i_Name);
    else
      v_Fail := v_Fail + 1;
      Dbms_Output.Put_Line('  FAIL  ' || i_Name);
    end if;
  end;
begin
  Dbms_Output.Put_Line('=== CORE_DML Update_User: Is_Access_Denied ===');

  --==== setup ====================================================
  delete from Core_Users_h where User_Id = c_Uid;
  delete from Core_Users   where User_Id = c_Uid;

  insert into Core_Users
    (User_Id, Cb_Code, Local_Code, User_Type_Id, Name, Language, Theme_Id,
     Is_Access_Denied, Access_Level_Set, Group_Set, Debug, State,
     Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_Uid, '00440', '01000', 0, 'CORE DML TEST USER', 'ru', 0,
     'Y', 0, Hextoraw('00'), 'N', 'A',
     Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
     0, sysdate, 0, sysdate);
  commit;

  Core.Auth_Session.Set_System_Actor(0);

  --==== 1. Y -> N =================================================
  v_Row.User_Id          := c_Uid;
  v_Row.Cb_Code           := '00440';
  v_Row.Local_Code        := '01000';
  v_Row.User_Type_Id      := 0;
  v_Row.Name              := 'CORE DML TEST USER';
  v_Row.Language           := 'ru';
  v_Row.Theme_Id           := 0;
  v_Row.Access_Level_Set   := 0;
  v_Row.Group_Set          := Hextoraw('00');
  v_Row.Created_By         := 0;
  v_Row.Created_On         := sysdate;
  v_Row.Is_Access_Denied  := 'N';
  v_Row.Debug             := 'N';
  v_Row.State              := 'A';
  v_Row.Activate_Date      := Trunc(sysdate) - 1;
  v_Row.Deactivate_Date    := to_date('31.12.9999', 'dd.mm.yyyy');
  Core_Dml.Update_User(v_Row);
  commit;

  select * into v_Row from Core_Users where User_Id = c_Uid;
  Assert('Is_Access_Denied = N (Y->N update)', v_Row.Is_Access_Denied = 'N');

  --==== 2. N -> Y =================================================
  v_Row.Is_Access_Denied := 'Y';
  Core_Dml.Update_User(v_Row);
  commit;

  select * into v_Row from Core_Users where User_Id = c_Uid;
  Assert('Is_Access_Denied = Y (N->Y update)', v_Row.Is_Access_Denied = 'Y');

  --==== teardown ==================================================
  Core.Auth_Session.Clear_System_Actor;
  delete from Core_Users_h where User_Id = c_Uid;
  delete from Core_Users   where User_Id = c_Uid;
  commit;

  Dbms_Output.Put_Line('--- Test CORE_DML_IS_ACCESS_DENIED: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
set define on;
