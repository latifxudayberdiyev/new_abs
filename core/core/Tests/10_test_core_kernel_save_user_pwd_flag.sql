----------------------------------------------------------------------------------------------------
--  Core_Kernel.Save_User -> Handle_Keys: 'password_must_be_changed' UPDATE yo'lida
--  inputdan qabul qilinishini tekshiradi (parol o'zgarmasa ham).
--  Bug: bu maydon avval faqat INSERT'da qo'llanardi, UPDATE'da e'tiborsiz qolardi.
--  Ishga tushirish: sqlplus core/*** @core/Tests/10_test_core_kernel_save_user_pwd_flag.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;
set define off;

declare
  v_Pass  number := 0;
  v_Fail  number := 0;
  c_Uid   constant number := 999999930;
  c_Ident constant number := 999999930;
  v_Hash  Core.Hash_t;
  v_Key   Core.Hash_t;
  v_Keys  Core.Arraylist;
  v_Row   Core.Core_User_Keys%rowtype;
  v_c     number;
  v_m     varchar2(400);
  v_o     varchar2(4000);
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
  --------------------------------------------------
  Procedure Save_And_Set_Flag(i_Flag varchar2) is
  begin
    v_Hash := Core.Hash_t();
    v_Hash.Put('sm_cache', Core.Hash_t()); -- is_create yo'q -> UPDATE yo'li
    v_Hash.Put('user_id', c_Uid);
    v_Hash.Put('cb_code', '00440');
    v_Hash.Put('local_code', '01000');
    v_Hash.Put('full_name', 'CORE KERNEL TEST USER');
    v_Hash.Put('pinfl', '00000000000000');
    v_Hash.Put('is_access_denied', 'N');
    v_Hash.Put('state', 'A');
    v_Hash.Put('activate_date', to_char(trunc(sysdate) - 1, 'dd.mm.yyyy'));
    v_Hash.Put('virtual_fields', 'X');
    --
    v_Key := Core.Hash_t();
    v_Key.Put('identity_id', c_Ident);
    v_Key.Put('password_must_be_changed', i_Flag); -- parol YO'Q, faqat flag
    v_Keys := Core.Arraylist();
    v_Keys.Push(v_Key);
    v_Hash.Put('keys', v_Keys);
    --
    Core.Core_Kernel.Save_User(v_Hash, v_c, v_m, v_o);
  end;
begin
  Dbms_Output.Put_Line('=== CORE_KERNEL Save_User: password_must_be_changed flag ===');

  --==== setup ====================================================
  delete from Core.Core_User_Keys_h where Identity_Id = c_Ident;
  delete from Core.Core_User_Keys   where Identity_Id = c_Ident;
  delete from Core.Core_Users_h     where User_Id = c_Uid;
  delete from Core.Core_Users       where User_Id = c_Uid;

  insert into Core.Core_Users
    (User_Id, Cb_Code, Local_Code, User_Type_Id, Name, Language, Theme_Id,
     Is_Access_Denied, Access_Level_Set, Group_Set, Debug, State,
     Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
  values
    (c_Uid, '00440', '01000', 0, 'CORE KERNEL TEST USER', 'ru', 0,
     'N', 0, Hextoraw('00'), 'N', 'A',
     Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
     0, sysdate, 0, sysdate);

  insert into Core.Core_User_Keys
    (Identity_Id, User_Id, Provider_Type, Provider_Key, Is_Required,
     Password, Password_Must_Be_Changed, State, Modified_By, Modified_On, Description)
  values
    (c_Ident, c_Uid, 'LOCAL', 'kerneltestuser', 'N',
     null, 'N', 'A', 0, sysdate, 'CORE_KERNEL test fixture');
  commit;

  -- Core.User_Env.Get_User_Id UAPP kontekstidan o'qiydi (Core_Dml.Update_User buni
  -- Modified_By uchun talab qiladi); sqlplus'dan chaqirilganda buni Set_System_Actor bilan
  -- qo'lda o'rnatamiz.
  Core.Auth_Session.Set_System_Actor(0);

  --==== 1. 'N' -> 'Y': parolsiz update, flag yoqilishi kerak =========
  Save_And_Set_Flag('Y');
  Assert('Save_User: OK (N->Y)', v_c = 0);

  select * into v_Row from Core.Core_User_Keys where Identity_Id = c_Ident;
  Assert('password_must_be_changed = Y (parolsiz update)', v_Row.Password_Must_Be_Changed = 'Y');

  --==== 2. 'Y' -> 'N': parolsiz update, flag o'chirilishi kerak ======
  Save_And_Set_Flag('N');
  Assert('Save_User: OK (Y->N)', v_c = 0);

  select * into v_Row from Core.Core_User_Keys where Identity_Id = c_Ident;
  Assert('password_must_be_changed = N (parolsiz update)', v_Row.Password_Must_Be_Changed = 'N');

  --==== teardown ==================================================
  Core.Auth_Session.Clear_System_Actor;
  delete from Core.Core_User_Keys_h where Identity_Id = c_Ident;
  delete from Core.Core_User_Keys   where Identity_Id = c_Ident;
  delete from Core.Core_Users_h     where User_Id = c_Uid;
  delete from Core.Core_Users       where User_Id = c_Uid;
  commit;

  Dbms_Output.Put_Line('--- Test CORE_KERNEL_PWD_FLAG: PASS=' || v_Pass || ' FAIL=' || v_Fail);
end;
/
set define on;
