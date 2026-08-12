----------------------------------------------------------------------------------------------------
--  menu_button_wiring_v: CORE_R_MENU_BUTTONS <-> SM_R_PROCESSES noto'g'ri ulanishini (bad wiring)
--  ushlab olishini tekshiradi.
--  Bu qoida jadval CHECK cheklovi bo'la olmaydi (ikkita jadval orasidagi bog'liqlik) - shu sabab
--  alohida view sifatida amalga oshirilgan; bu test o'sha view'ning WRONG_MODEL_TYPE qoidasini
--  (model_process_code process_type='GET' bo'lmagan processga ishora qilsa) tekshiradi.
--  Sentinel qator: model_process_code ATAYLAB 'GET' bo'lmagan (process_type='POST') processga
--  ishora qiladi - process_code esa mavjud va to'g'ri (POST) processga ishora qiladi, shu bilan
--  MODEL_WITHOUT_PROCESS qoidasi ishga tushmasligi va faqat WRONG_MODEL_TYPE qatori qaytishi
--  ta'minlanadi.
--  Live-DB bog'liqligi: sentinel uchun SM_R_PROCESSES'da process_type != 'GET' bo'lgan holati
--  faol qator kerak (sm/inserts/SM_R_PROCESSES.sql seed faylida 'CREATE_USER', process_type='POST',
--  state='A' bor) - agar live bazada bo'lmasa, test FAIL emas, SKIP bo'ladi.
--  View o'zi hech qanday ma'lumot saqlamaydi (faqat query) - tozalash faqat sentinel
--  CORE_R_MENU_BUTTONS qatoriga tegishli.
--  DIQQAT (state='P'): sentinel qator ATAYLAB state='P' (passive) bilan yoziladi, 'A' EMAS -
--  menu_button_wiring_v FAQAT SM_R_PROCESSES.state (p1.state/p2.state) ni tekshiradi, button'ning
--  o'z state'iga (b.state) umuman qaramaydi - shu sabab state='P' bu view'ning WRONG_MODEL_TYPE
--  aniqlashiga ta'sir qilmaydi (pastdagi assert shuni tasdiqlaydi). Lekin Core_Api.Log_Process_Access
--  guard'i (Core_Api.pck) CORE_R_MENU_BUTTONS'ni process_code/model_process_code bo'yicha qidirganda
--  menu_id/button_id'ga QARAMAY, faqat "b.model_process_code = ... and b.state = 'A'" shartini
--  tekshiradi - agar bu sentinel qator state='A' bilan qolsa, xuddi shu process_code bilan real
--  trafik kelganida guard uni noto'g'ri "mapped" deb belgilaydi (production'da ADM_REL_USER_BUTTONS
--  bo'sh bo'lgani uchun MAPPED_DENIED/would_block='Y' bo'lib yoziladi, holbuki to'g'ri natija UNMAPPED
--  bo'lishi kerak) - shu bilan phase-2 uchun kerakli CORE_PROCESS_ACCESS_LOG ma'lumotini chalg'itadi.
--  state='P' bu poisoning'ni oldini oladi (C1 cheklovi state in ('A','P') buni ruxsat beradi).
--  Ishga tushirish: sqlplus core/*** @access/Tests/20_test_access_menu_button_wiring_v.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited
set define off;

declare
  v_Pass    number := 0;
  v_Fail    number := 0;
  c_Menu_Id constant number := 999999920;
  c_Btn_Id  constant number := 1;
  -- process_type != 'GET' bo'lgan, faol seed process (view shu literalga qarshi tekshiradi -
  -- access/views/menu_button_wiring_v.sql'dagi p2.process_type != 'GET' shartiga qarang).
  c_Non_Get_Process constant varchar2(100) := 'CREATE_USER';
  v_Exists_Cnt number;
  v_Problem    varchar2(30);
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
  Dbms_Output.Put_Line('=== menu_button_wiring_v: WRONG_MODEL_TYPE aniqlashi ===');

  select count(*) into v_Exists_Cnt from Sm_R_Processes where process_code = c_Non_Get_Process;
  if v_Exists_Cnt = 0 then
    Dbms_Output.Put_Line('  SKIP  Sm_R_Processes''da ''' || c_Non_Get_Process ||
                          ''' topilmadi (live seed yo''q) - butun test o''tkazib yuborildi');
  else
    --==== setup ====================================================
    delete from Core_R_Menu_Buttons where menu_id = c_Menu_Id;
    commit;

    -- process_code to'g'ri ishlatilgan (submit uchun POST process), model_process_code esa
    -- ATAYLAB xato - GET bo'lmagan processga ishora qiladi.
    insert into Core_R_Menu_Buttons
      (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state,
       button_type, process_code, model_process_code,
       created_by, created_on, modify_by, modify_on)
    values
      ('ZZZ_TEST', c_Menu_Id, c_Btn_Id, 'zzz_test_wiring_action', 'ZZZ_TEST_WIRING_BTN', 1, 'P',
       null, c_Non_Get_Process, c_Non_Get_Process,
       0, sysdate, 0, sysdate);
    commit;

    --==== assert: view sentinel qator uchun WRONG_MODEL_TYPE qaytaradi
    begin
      select problem_code
        into v_Problem
        from menu_button_wiring_v
       where menu_id = c_Menu_Id
         and button_id = c_Btn_Id;
      Assert('menu_button_wiring_v problem_code = WRONG_MODEL_TYPE', v_Problem = 'WRONG_MODEL_TYPE');
    exception
      when No_Data_Found then
        Assert('menu_button_wiring_v sentinel uchun qator qaytardi', false);
      when Too_Many_Rows then
        Assert('menu_button_wiring_v sentinel uchun faqat bitta qator (WRONG_MODEL_TYPE)', false);
    end;

    --==== teardown ================================================
    delete from Core_R_Menu_Buttons where menu_id = c_Menu_Id;
    commit;
  end if;

  Dbms_Output.Put_Line('--- Test ACCESS_MENU_BUTTON_WIRING_V: PASS=' || v_Pass || ' FAIL=' || v_Fail);
exception
  when others then
    delete from Core_R_Menu_Buttons where menu_id = c_Menu_Id;
    commit;
    raise;
end;
/
set define on;
