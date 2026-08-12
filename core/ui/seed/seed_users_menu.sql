----------------------------------------------------------------------------------------------------
--  Foydalanuvchilar (Users) sahifasi uchun sidebar menyu seed'i:
--  "Администрирование" guruhi -> "Дашборд" + "Пользователи".
--
--  Bu skript LOKAL test bazada qo'lda (ad-hoc) qo'shilgan menyu qatorlarini
--  qayta tiklaydi - hech qachon commit qilinmagan edi, shuning uchun real
--  bazada bu menyular ko'rinmadi. Idempotent: qayta ishga tushirish xavfsiz
--  (mavjud bo'lsa - o'tkazib yuboradi, mavjud MENU_ID/TEMPLATE_ID'larga
--  tegmaydi - kolliziyadan qochish uchun MAX+1 ishlatiladi).
--
--  Ishga tushirish: CORE schema egasi sifatida.
----------------------------------------------------------------------------------------------------

-- 1) Tarjima shablonlari (MLT_TEMPLATES) - agar yo'q bo'lsa
declare
  v_cnt number;
begin
  select count(*) into v_cnt from Mlt_Templates where message_code = 'MENU_ADMIN_GROUP';
  if v_cnt = 0 then
    insert into Mlt_Templates
      (template_id, message_code, description, param_count, format_string,
       message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
    values
      (Mlt_Templates_Seq.Nextval, 'MENU_ADMIN_GROUP', 'Sidebar: Administration group', 0, '$',
       'Администрирование', 'Boshqaruv', 'Boshqaruv', 'Administration');
    dbms_output.put_line('MENU_ADMIN_GROUP shabloni qo''shildi.');
  else
    dbms_output.put_line('MENU_ADMIN_GROUP shabloni allaqachon mavjud - o''tkazib yuborildi.');
  end if;

  select count(*) into v_cnt from Mlt_Templates where message_code = 'MENU_DASHBOARD';
  if v_cnt = 0 then
    insert into Mlt_Templates
      (template_id, message_code, description, param_count, format_string,
       message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
    values
      (Mlt_Templates_Seq.Nextval, 'MENU_DASHBOARD', 'Sidebar: Dashboard item', 0, '$',
       'Дашборд', 'Boshqaruv paneli', 'Boshqaruv paneli', 'Dashboard');
    dbms_output.put_line('MENU_DASHBOARD shabloni qo''shildi.');
  else
    dbms_output.put_line('MENU_DASHBOARD shabloni allaqachon mavjud - o''tkazib yuborildi.');
  end if;

  select count(*) into v_cnt from Mlt_Templates where message_code = 'MENU_USERS';
  if v_cnt = 0 then
    insert into Mlt_Templates
      (template_id, message_code, description, param_count, format_string,
       message_mask_lang1, message_mask_lang2)
    values
      (Mlt_Templates_Seq.Nextval, 'MENU_USERS', 'Sidebar: Users item', 0, '$',
       'Пользователи', 'Foydalanuvchilar');
    dbms_output.put_line('MENU_USERS shabloni qo''shildi.');
  else
    dbms_output.put_line('MENU_USERS shabloni allaqachon mavjud - o''tkazib yuborildi.');
  end if;
  commit;
end;
/

-- 2) Menyu daraxti (CORE_R_MENUS) - MENU_ID uchun sequence yo'q, shuning uchun
--    mavjud eng katta ID'dan keyingi qiymatlar ishlatiladi (kolliziyasiz).
declare
  v_cnt          number;
  v_admin_id     number;
  v_dashboard_id number;
  v_users_id     number;
begin
  select count(*) into v_cnt from Core_R_Menus where name_mll_code = 'MENU_ADMIN_GROUP';
  if v_cnt = 0 then
    select nvl(max(menu_id), 0) + 1 into v_admin_id from Core_R_Menus;
    insert into Core_R_Menus (module_code, menu_id, parent_menu_id, name_mll_code, page_url, order_by, state, menu_type)
    values ('CORE', v_admin_id, '0', 'MENU_ADMIN_GROUP', '#', 1, 'A', null);
    dbms_output.put_line('MENU_ADMIN_GROUP (menu_id=' || v_admin_id || ') qo''shildi.');
  else
    select menu_id into v_admin_id from Core_R_Menus where name_mll_code = 'MENU_ADMIN_GROUP';
    dbms_output.put_line('MENU_ADMIN_GROUP allaqachon mavjud (menu_id=' || v_admin_id || ') - o''tkazib yuborildi.');
  end if;

  select count(*) into v_cnt from Core_R_Menus where name_mll_code = 'MENU_DASHBOARD';
  if v_cnt = 0 then
    select nvl(max(menu_id), 0) + 1 into v_dashboard_id from Core_R_Menus;
    insert into Core_R_Menus (module_code, menu_id, parent_menu_id, name_mll_code, page_url, order_by, state, menu_type)
    values ('CORE', v_dashboard_id, to_char(v_admin_id), 'MENU_DASHBOARD', '/ibs/user/util/dashboard/dashboard.jsp?read_code=dashboard_home', 1, 'A', 'dashboard');
    dbms_output.put_line('MENU_DASHBOARD (menu_id=' || v_dashboard_id || ') qo''shildi.');
  else
    select menu_id into v_dashboard_id from Core_R_Menus where name_mll_code = 'MENU_DASHBOARD';
    dbms_output.put_line('MENU_DASHBOARD allaqachon mavjud (menu_id=' || v_dashboard_id || ') - o''tkazib yuborildi.');
  end if;

  select count(*) into v_cnt from Core_R_Menus where name_mll_code = 'MENU_USERS';
  if v_cnt = 0 then
    select nvl(max(menu_id), 0) + 1 into v_users_id from Core_R_Menus;
    insert into Core_R_Menus (module_code, menu_id, parent_menu_id, name_mll_code, page_url, order_by, state, menu_type)
    values ('CORE', v_users_id, to_char(v_admin_id), 'MENU_USERS', '/ibs/core/users.jsp', 2, 'A', null);
    dbms_output.put_line('MENU_USERS (menu_id=' || v_users_id || ') qo''shildi.');
  else
    select menu_id into v_users_id from Core_R_Menus where name_mll_code = 'MENU_USERS';
    dbms_output.put_line('MENU_USERS allaqachon mavjud (menu_id=' || v_users_id || ') - o''tkazib yuborildi.');
  end if;
  commit;

  -- 3) Foydalanuvchilarga menyu tayinlash (CORE_REL_USER_MENUS)
  --    PASTDAGI user_id'larni real bazadagi haqiqiy admin user_id'larga moslashtiring!
  --    (bu yerda -1/0 - lokal test bazadagi super_user/system_user edi, real
  --    bazada boshqacha bo'lishi mumkin - core_users jadvalidan tekshiring)
  for r in (select -1 as target_user_id from dual union all select 0 from dual) loop
    select count(*) into v_cnt from Core_Rel_User_Menus where user_id = r.target_user_id and menu_id = v_dashboard_id;
    if v_cnt = 0 then
      insert into Core_Rel_User_Menus (user_id, menu_id, date_activate, date_deactivate, state, created_by, created_on, modify_by, modify_on)
      values (r.target_user_id, v_dashboard_id, trunc(sysdate), to_date('31.12.9999','dd.mm.yyyy'), 'A', 0, sysdate, 0, sysdate);
      dbms_output.put_line('user_id=' || r.target_user_id || ' -> MENU_DASHBOARD tayinlandi.');
    end if;
  end loop;

  select count(*) into v_cnt from Core_Rel_User_Menus where user_id = -1 and menu_id = v_users_id;
  if v_cnt = 0 then
    insert into Core_Rel_User_Menus (user_id, menu_id, date_activate, date_deactivate, state, created_by, created_on, modify_by, modify_on)
    values (-1, v_users_id, trunc(sysdate), to_date('31.12.9999','dd.mm.yyyy'), 'A', 0, sysdate, 0, sysdate);
    dbms_output.put_line('user_id=-1 -> MENU_USERS tayinlandi.');
  end if;
  commit;
end;
/

prompt === Tayyor. Endi tizimga qayta kirib, sidebar'da "Администрирование" -> "Пользователи" ko'rinishini tekshiring. ===
