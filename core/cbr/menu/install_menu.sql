----------------------------------------------------------------------------------------------------
--  "Справочник" menyu guruhi + "Справочники ЦБ" bandi (MLL ko'p tillilik + CORE_R_MENUS).
----------------------------------------------------------------------------------------------------

-- 1) Ko'p tillilik shablonlari (RU, UZ-KIR, UZ-LAT, EN)
insert into mlt_templates (message_code, description, param_count, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
values ('CBR_CB_MENU_GROUP', 'CBR moduli menyu bo''limi sarlavhasi', 0, 'Справочник', 'Маълумотнома', 'Ma''lumotnoma', 'Reference');

insert into mlt_templates (message_code, description, param_count, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
values ('CBR_CB_MENU_CATALOG', 'Sidebar: Markaziy Bank spravochniklari', 0, 'Справочники ЦБ', 'Марказий банк маълумотномалари', 'Markaziy bank ma''lumotnomalari', 'Central Bank references');

-- 2) Label kodlari (MLL_LABEL_CODES_SEQ orqali)
insert into mll_label_codes (label_id, module_code, message_code, description)
values (mll_label_codes_seq.nextval, 'CBR', 'CBR_CB_MENU_GROUP', 'CBR moduli menyu bo''limi sarlavhasi');

insert into mll_label_codes (label_id, module_code, message_code, description)
values (mll_label_codes_seq.nextval, 'CBR', 'CBR_CB_MENU_CATALOG', 'Sidebar: Markaziy Bank spravochniklari');

-- 3) Menyu yozuvlari (guruh + band)
insert into CORE_R_MENUS (module_code, menu_id, parent_menu_id, name_mll_code, page_url, order_by, state)
values ('CBR', 8000, '0', 'CBR_CB_MENU_GROUP', '#', 8, 'A');

insert into CORE_R_MENUS (module_code, menu_id, parent_menu_id, name_mll_code, page_url, order_by, state)
values ('CBR', 8001, '8000', 'CBR_CB_MENU_CATALOG', '/ibs/cbr/cbr_catalog.jsp', 1, 'A');

commit;
