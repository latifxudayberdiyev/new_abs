----------------------------------------------------------------------------------------------------
--  CORE_R_API_READS ro'yxatga olish - "bitta eshik" (Core_Api.Get_Page_Init) orqali
--  chaqiriladigan sahifa-init o'qishlari. Idempotent.
--
--  dashboard_home: menu_id MENU_DASHBOARD'dan (seed_users_menu.sql avval ishga
--  tushirilgan bo'lishi kerak) dinamik olinadi - shu bilan dashboard birinchi marta
--  CORE_REL_USER_MENUS orqali haqiqiy ruxsat-nazoratiga ega bo'ladi (avval yo'q edi).
--
--  Ishga tushirish: CORE schema egasi sifatida, ui/seed/seed_users_menu.sql'dan KEYIN.
----------------------------------------------------------------------------------------------------
declare
  v_cnt          number;
  v_dashboard_id number;
begin
  select menu_id into v_dashboard_id from Core_R_Menus where name_mll_code = 'MENU_DASHBOARD';

  select count(*) into v_cnt from Core_R_Api_Reads where read_code = 'dashboard_home';
  if v_cnt = 0 then
    insert into Core_R_Api_Reads
      (read_code, procedure_name, menu_id, requires_context, description, state,
       created_by, created_on, modify_by, modify_on)
    values
      ('dashboard_home', 'CORE.CORE_DASHBOARD.GET_HOME', v_dashboard_id, 'Y',
       'dashboard.jsp - KPI/grafik ma''lumotlari (Core_Api.Get_Page_Init orqali)', 'A',
       0, sysdate, 0, sysdate);
    dbms_output.put_line('dashboard_home ro''yxatdan o''tkazildi (menu_id=' || v_dashboard_id || ').');
  else
    dbms_output.put_line('dashboard_home allaqachon mavjud - o''tkazib yuborildi.');
  end if;
  commit;
exception
  when No_Data_Found then
    dbms_output.put_line('XATO: MENU_DASHBOARD topilmadi - avval ui/seed/seed_users_menu.sql ishga tushiring.');
    raise;
end;
/

prompt === Tayyor. Tekshirish: select * from Core_R_Api_Reads; ===
