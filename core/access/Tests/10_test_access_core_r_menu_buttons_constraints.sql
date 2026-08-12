----------------------------------------------------------------------------------------------------
--  CORE_R_MENU_BUTTONS: process_code/model_process_code NULL-e'tibor va FK cheklovlarini tekshiradi.
--  Nima tekshiriladi:
--   1) Ikkalasi ham NULL - "faqat navigatsiya" tugmasi QONUNIY holat (dizaynning butun maqsadi -
--      har bir tugmaga majburiy process bog'lash CORE_R_API_READS anti-patternini takrorlamaydi).
--   2) process_code haqiqiy SM_R_PROCESSES qatoriga ishora qilsa - insert muvaffaqiyatli o'tishi kerak.
--   3) process_code mavjud bo'lmagan kodga ishora qilsa - CORE_R_MENU_BUTTONS_FK1 buzilib,
--      ORA-02291 chiqishi kerak (bu "xato kutilgan" testi).
--   4) state = 'X' (CORE_R_MENU_BUTTONS_C1 - state in ('A','P') - ruxsat etilmagan qiymat) -
--      check cheklovi buzilib, ORA-02290 chiqishi kerak (bu "xato kutilgan" testi).
--  Live-DB bog'liqligi: (2)-holat SM_R_PROCESSES'da 'CREATE_USER' qatori mavjudligini talab qiladi
--  (sm/inserts/SM_R_PROCESSES.sql seed faylida bor, lekin haqiqiy bazada tekshirilmagan/o'chirilgan
--  bo'lishi mumkin) - shu sabab avval count() bilan tekshiriladi, topilmasa test FAIL emas, SKIP bo'ladi.
--  DIQQAT (state='P'): sentinel qatorlar ATAYLAB state='P' (passive) bilan yoziladi, 'A' EMAS.
--  Core_Api.Log_Process_Access (process-code guard) CORE_R_MENU_BUTTONS'ni process_code bo'yicha
--  qidirganda menu_id/button_id'ga QARAMAYDI (faqat b.process_code = ... and b.state = 'A') - shu
--  sabab agar bu sentinel qator (process_code='CREATE_USER') state='A' bilan mavjud bo'lsa, xuddi shu
--  paytda real trafikda CREATE_USER chaqirilsa, guard uni "mapped" deb hisoblaydi (ADM_REL_USER_BUTTONS'da
--  granti bo'lmagani uchun esa MAPPED_DENIED/would_block='Y' deb yozadi) - bu esa hali production'da
--  ADM_REL_USER_BUTTONS bo'sh bo'lgani uchun to'g'ri natija UNMAPPED bo'lishi kerak bo'lgan holatni
--  buzib, phase-2 uchun kerakli CORE_PROCESS_ACCESS_LOG ma'lumotini chalg'itadi. state='P' bilan bu
--  qator guard so'rovlariga hech qachon mos kelmaydi (C1 cheklovi state in ('A','P') buni ruxsat beradi).
--  Ishga tushirish: sqlplus core/*** @access/Tests/10_test_access_core_r_menu_buttons_constraints.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited
set define off;

declare
  v_Pass    number := 0;
  v_Fail    number := 0;
  c_Menu_Id constant number := 999999910;
  c_Btn_1   constant number := 1; -- ikkalasi ham NULL ("faqat navigatsiya")
  c_Btn_2   constant number := 2; -- process_code = haqiqiy mavjud process (agar seed bo'lsa)
  c_Btn_3   constant number := 3; -- process_code = mavjud bo'lmagan kod (FK buzilishi kutiladi)
  c_Btn_4   constant number := 4; -- state = 'X' (C1 cheklovi buzilishi kutiladi)
  c_Existing_Process constant varchar2(100) := 'CREATE_USER';
  c_Bad_Process       constant varchar2(100) := 'ZZZ_DOES_NOT_EXIST_ZZZ';
  v_Exists_Cnt number;
  v_Cnt        number;
  v_Fk_Raised  boolean := false;
  v_C1_Raised  boolean := false;
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
  Dbms_Output.Put_Line('=== CORE_R_MENU_BUTTONS: NULL / FK cheklovlari ===');

  --==== setup: sentinel qatorlarni tozalash ========================
  delete from Core_R_Menu_Buttons where menu_id = c_Menu_Id;
  commit;

  --==== 1. Ikkalasi ham NULL - "faqat navigatsiya" tugmasi ==========
  insert into Core_R_Menu_Buttons
    (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state,
     button_type, process_code, model_process_code,
     created_by, created_on, modify_by, modify_on)
  values
    ('ZZZ_TEST', c_Menu_Id, c_Btn_1, 'zzz_test_nav_action', 'ZZZ_TEST_NAV_BTN', 1, 'P',
     null, null, null,
     0, sysdate, 0, sysdate);
  commit;

  select count(*)
    into v_Cnt
    from Core_R_Menu_Buttons
   where menu_id = c_Menu_Id
     and button_id = c_Btn_1
     and process_code is null
     and model_process_code is null;
  Assert('Ikkalasi ham NULL - navigatsiya-tugma insert muvaffaqiyatli', v_Cnt = 1);

  --==== 2. process_code = haqiqiy mavjud process (agar seed bo'lsa) ==
  select count(*) into v_Exists_Cnt from Sm_R_Processes where process_code = c_Existing_Process;
  if v_Exists_Cnt = 0 then
    Dbms_Output.Put_Line('  SKIP  process_code=' || c_Existing_Process ||
                          ' Sm_R_Processes''da topilmadi (live seed yo''q) - 2-holat o''tkazib yuborildi');
  else
    insert into Core_R_Menu_Buttons
      (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state,
       button_type, process_code, model_process_code,
       created_by, created_on, modify_by, modify_on)
    values
      ('ZZZ_TEST', c_Menu_Id, c_Btn_2, 'zzz_test_submit_action', 'ZZZ_TEST_SUBMIT_BTN', 2, 'P',
       null, c_Existing_Process, null,
       0, sysdate, 0, sysdate);
    commit;

    select count(*)
      into v_Cnt
      from Core_R_Menu_Buttons
     where menu_id = c_Menu_Id
       and button_id = c_Btn_2
       and process_code = c_Existing_Process;
    Assert('process_code = ' || c_Existing_Process || ' (mavjud) insert muvaffaqiyatli', v_Cnt = 1);
  end if;

  --==== 3. process_code = mavjud bo'lmagan kod - FK buzilishi kutiladi
  begin
    insert into Core_R_Menu_Buttons
      (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state,
       button_type, process_code, model_process_code,
       created_by, created_on, modify_by, modify_on)
    values
      ('ZZZ_TEST', c_Menu_Id, c_Btn_3, 'zzz_test_bad_action', 'ZZZ_TEST_BAD_BTN', 3, 'P',
       null, c_Bad_Process, null,
       0, sysdate, 0, sysdate);
    commit;
  exception
    when others then
      if Sqlcode = -2291 then -- ORA-02291: integrity constraint violated - parent key not found
        v_Fk_Raised := true;
      else
        raise;
      end if;
  end;
  Assert('process_code = ' || c_Bad_Process || ' (mavjud emas) FK xatosini chiqaradi (ORA-02291)',
         v_Fk_Raised);

  --==== 4. state = 'X' - CORE_R_MENU_BUTTONS_C1 check cheklovi buzilishi kutiladi ===
  begin
    insert into Core_R_Menu_Buttons
      (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state,
       button_type, process_code, model_process_code,
       created_by, created_on, modify_by, modify_on)
    values
      ('ZZZ_TEST', c_Menu_Id, c_Btn_4, 'zzz_test_bad_state_action', 'ZZZ_TEST_BAD_STATE_BTN', 4, 'X',
       null, null, null,
       0, sysdate, 0, sysdate);
    commit;
  exception
    when others then
      if Sqlcode = -2290 then -- ORA-02290: check constraint (CORE_R_MENU_BUTTONS_C1) violated
        v_C1_Raised := true;
      else
        raise;
      end if;
  end;
  Assert('state = ''X'' (ruxsat etilmagan) C1 check xatosini chiqaradi (ORA-02290)',
         v_C1_Raised);

  --==== teardown ==================================================
  delete from Core_R_Menu_Buttons where menu_id = c_Menu_Id;
  commit;

  Dbms_Output.Put_Line('--- Test ACCESS_CORE_R_MENU_BUTTONS_CONSTRAINTS: PASS=' || v_Pass || ' FAIL=' || v_Fail);
exception
  when others then
    delete from Core_R_Menu_Buttons where menu_id = c_Menu_Id;
    commit;
    raise;
end;
/
set define on;
