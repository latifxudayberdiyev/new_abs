----------------------------------------------------------------------------------------------------
--  CBR spravochniklari uchun "qo'lda yangilash" va "interval belgilash" amallarini SM (Sostoyaniya
--  Menedjeri / State Manager) ro'yxatiga qo'shish. Bank tizimidagi har bir amal Core_Api.Execute_
--  Process_Clob umumiy dispetcheri orqali o'tadi; haqiqiy PL/SQL protsedura SM_R_* jadvallari orqali
--  process_code bo'yicha topiladi (to'g'ridan-to'g'ri chaqirilmaydi). Shu sababli:
--    1) SM_R_OBJECTS/SM_R_PROCESSES/SM_R_EVENTS/SM_R_PROCESS_EVENTS/SM_R_PROCEDURES/
--       SM_R_EVENT_PROCEDURES ga ro'yxatga olamiz (OPERATION turi - obyekt holati o'tishisiz,
--       oddiy amal);
--    2) CORE_R_MENU_BUTTONS + ADM_REL_USER_BUTTONS orqali ruxsat beramiz (menu_id=8001 - CBR
--       katalogi sahifasi);
--    3) Haqiqiy ish Cbr_Sm_Api.pck ichida, Cbr_Schedule_Kernel'ni chaqiradigan yupqa "wrapper"
--       protseduralar orqali bajariladi.
----------------------------------------------------------------------------------------------------
set define off;

prompt =====================================================================
prompt 1) SM_R_OBJECTS: CBR_REFERENCE obyekti
prompt =====================================================================
declare
  procedure safe_ins(p_sql varchar2) is
  begin
    execute immediate p_sql;
  exception
    when others then
      if sqlcode != -1 then raise; end if; -- -1 = unique constraint (allaqachon bor)
  end;
begin
  safe_ins(q'[insert into SM_R_OBJECTS (object_code, parent_object_code, initial_state, sequence_getter, created_on, created_developer, state)
              values ('CBR_REFERENCE', 'ROOT', null, null, sysdate, 'CBR', 'A')]');
end;
/

prompt =====================================================================
prompt 2) SM_R_PROCESSES: CBR_MANUAL_REFRESH, CBR_SET_SCHEDULE (OPERATION turi)
prompt =====================================================================
declare
  procedure safe_ins(p_sql varchar2) is
  begin
    execute immediate p_sql;
  exception
    when others then
      if sqlcode != -1 then raise; end if;
  end;
begin
  safe_ins(q'[insert into SM_R_PROCESSES (process_code, object_code, parent_object_code, state, relation_key, created_on, created_developer, process_type, set_log, description)
              values ('CBR_MANUAL_REFRESH', 'CBR_REFERENCE', 'ROOT', 'A', 'ref_id', sysdate, 'CBR', 'OPERATION', 'Y', 'CBR spravochnikni qo''lda (darhol) yangilash')]');
  safe_ins(q'[insert into SM_R_PROCESSES (process_code, object_code, parent_object_code, state, relation_key, created_on, created_developer, process_type, set_log, description)
              values ('CBR_SET_SCHEDULE', 'CBR_REFERENCE', 'ROOT', 'A', 'ref_id', sysdate, 'CBR', 'OPERATION', 'Y', 'CBR spravochnik uchun avtomatik yangilanish intervalini belgilash')]');
end;
/

prompt =====================================================================
prompt 3) SM_R_EVENTS va SM_R_PROCESS_EVENTS
prompt =====================================================================
declare
  procedure safe_ins(p_sql varchar2) is
  begin
    execute immediate p_sql;
  exception
    when others then
      if sqlcode != -1 then raise; end if;
  end;
begin
  safe_ins(q'[insert into SM_R_EVENTS (event_code, state) values ('CBR_MANUAL_REFRESH_EVT', 'A')]');
  safe_ins(q'[insert into SM_R_EVENTS (event_code, state) values ('CBR_SET_SCHEDULE_EVT', 'A')]');
  safe_ins(q'[insert into SM_R_PROCESS_EVENTS (process_code, event_code, order_by, state, execution_mode)
              values ('CBR_MANUAL_REFRESH', 'CBR_MANUAL_REFRESH_EVT', 1, 'A', 'S')]');
  safe_ins(q'[insert into SM_R_PROCESS_EVENTS (process_code, event_code, order_by, state, execution_mode)
              values ('CBR_SET_SCHEDULE', 'CBR_SET_SCHEDULE_EVT', 1, 'A', 'S')]');
end;
/

prompt =====================================================================
prompt 4) SM_R_PROCEDURES va SM_R_EVENT_PROCEDURES: Cbr_Sm_Api'ga bog'lash
prompt =====================================================================
declare
  procedure safe_ins(p_sql varchar2) is
  begin
    execute immediate p_sql;
  exception
    when others then
      if sqlcode != -1 then raise; end if;
  end;
begin
  safe_ins(q'[insert into SM_R_PROCEDURES (procedure_code, procedure_name, state) values ('CBR_MANUAL_REFRESH', 'Cbr_Sm_Api.Manual_Refresh', 'A')]');
  safe_ins(q'[insert into SM_R_PROCEDURES (procedure_code, procedure_name, state) values ('CBR_SET_SCHEDULE', 'Cbr_Sm_Api.Set_Schedule', 'A')]');
  safe_ins(q'[insert into SM_R_EVENT_PROCEDURES (event_code, procedure_code, order_by, state)
              values ('CBR_MANUAL_REFRESH_EVT', 'CBR_MANUAL_REFRESH', 1, 'A')]');
  safe_ins(q'[insert into SM_R_EVENT_PROCEDURES (event_code, procedure_code, order_by, state)
              values ('CBR_SET_SCHEDULE_EVT', 'CBR_SET_SCHEDULE', 1, 'A')]');
end;
/

prompt =====================================================================
prompt 5) Menyu tugmalari (CORE_R_MENU_BUTTONS) + ko'p tillilik
prompt =====================================================================
declare
  procedure safe_ins(p_sql varchar2) is
  begin
    execute immediate p_sql;
  exception
    when others then
      if sqlcode != -1 then raise; end if;
  end;
begin
  safe_ins(q'[insert into mlt_templates (message_code, description, param_count, format_string, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
              values ('CBR_BTN_MANUAL_REFRESH', 'CBR: qo''lda yangilash tugmasi', 0, '$', 'Обновить сейчас', 'Ҳозир янгилаш', 'Hozir yangilash', 'Refresh now')]');
  safe_ins(q'[insert into mlt_templates (message_code, description, param_count, format_string, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
              values ('CBR_BTN_SET_SCHEDULE', 'CBR: interval saqlash tugmasi', 0, '$', 'Сохранить', 'Сақлаш', 'Saqlash', 'Save')]');
  safe_ins(q'[insert into mll_label_codes (label_id, module_code, message_code, description)
              values (mll_label_codes_seq.nextval, 'CBR', 'CBR_BTN_MANUAL_REFRESH', 'CBR: qo''lda yangilash tugmasi')]');
  safe_ins(q'[insert into mll_label_codes (label_id, module_code, message_code, description)
              values (mll_label_codes_seq.nextval, 'CBR', 'CBR_BTN_SET_SCHEDULE', 'CBR: interval saqlash tugmasi')]');

  safe_ins(q'[insert into CORE_R_MENU_BUTTONS (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state, button_type, process_code, created_by, created_on, modify_by, modify_on)
              values ('CBR', 8001, 10, 'CBR_MANUAL_REFRESH', 'CBR_BTN_MANUAL_REFRESH', 10, 'A', 'NAV', 'CBR_MANUAL_REFRESH', -1, sysdate, -1, sysdate)]');
  safe_ins(q'[insert into CORE_R_MENU_BUTTONS (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state, button_type, process_code, created_by, created_on, modify_by, modify_on)
              values ('CBR', 8001, 11, 'CBR_SET_SCHEDULE', 'CBR_BTN_SET_SCHEDULE', 11, 'A', 'NAV', 'CBR_SET_SCHEDULE', -1, sysdate, -1, sysdate)]');
end;
/

prompt =====================================================================
prompt 6) Foydalanuvchilarga ruxsat (ADM_REL_USER_BUTTONS, barcha uchun user_id=-1)
prompt =====================================================================
declare
  procedure safe_ins(p_sql varchar2) is
  begin
    execute immediate p_sql;
  exception
    when others then
      if sqlcode != -1 then raise; end if;
  end;
begin
  safe_ins(q'[insert into ADM_REL_USER_BUTTONS (user_id, button_id, menu_id, date_activate, date_deactivate, state, created_by, created_on, modify_by, modify_on)
              values (-1, 10, 8001, sysdate, to_date('31-12-9999','dd-mm-yyyy'), 'A', -1, sysdate, -1, sysdate)]');
  safe_ins(q'[insert into ADM_REL_USER_BUTTONS (user_id, button_id, menu_id, date_activate, date_deactivate, state, created_by, created_on, modify_by, modify_on)
              values (-1, 11, 8001, sysdate, to_date('31-12-9999','dd-mm-yyyy'), 'A', -1, sysdate, -1, sysdate)]');
end;
/

commit;

prompt =====================================================================
prompt Tekshirish
prompt =====================================================================
select process_code, object_code, process_type, state from sm_r_processes where process_code like 'CBR_%';
select module_code, menu_id, button_id, action_code, process_code from core_r_menu_buttons where module_code='CBR';

exit;
