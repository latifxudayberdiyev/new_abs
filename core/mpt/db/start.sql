-- ==========================================================================
-- MPT schema migration script
-- Generated from schema CORE @ new_abs (172.20.6.157) on 2026-07-29
-- Har bir obyekt o'z papkasida, alohida faylda (masalan
-- sequences\mpt_print_history_s1.sql, packages\Mpt_Admin_Api.pck).
--
-- Ishga tushirish: shu papkada turib, TARGET sxema ostida ulaning:
--   sqlplus target_user/pwd@tns_alias @start.sql
--
-- Tartib obyektlar orasidagi haqiqiy bog'liqlikka (USER_DEPENDENCIES)
-- asoslangan:
--   sequences -> tables -> indexes -> fk_constraints -> functions
--   -> packages -> views -> triggers -> grants
-- Sabab: MPT_*_V view'lari MPT_MODULE_NAME/MPT_STATE_NAME funksiyalariga,
-- MPT_PRINT_VARIABLES_T1 trigger'i esa MPT_PRINT_API paketiga bog'liq.
--
-- IMPORTANT - export qilinmagan tashqi bog'liqliklar (target muhitda
-- avvaldan mavjud bo'lishi kerak):
--   - Jadval MLT_LANGUAGES        (FK: fk_constraints dagi *_F3, *_F2)
--   - View  MLT_LANGUAGES_V       (views\mpt_languages_v.sql shu view ustida)
--   - Jadval CORE_R_MODULES       (FK: fk_constraints dagi *_F1)
--   - CORE.MLT_UTIL paketi va CORE.HASH_T tipi
--     (functions\mpt_module_name.sql, mpt_state_name.sql va
--      packages\Mpt_Admin_Api.pck ichida ishlatiladi)
--
-- DIQQAT (09-bosqich): grants\ papkasida har bir obyekt uchun alohida fayl.
-- Hozircha faqat keyin qo'shilgan obyektlar qamrab olingan. MPT'ning qolgan
-- obyektlari uchun UAPP synonym'lari new_abs muhitida avvaldan mavjud, lekin
-- bu repozitoriyga eksport qilinmagan: MPT_ADMIN_API, MPT_PRINT_SETTINGS,
-- MPT_PRINT_SETTINGS_V, MPT_PRODUCTS_V, MPT_MODULES_V, MPT_TEMPLATE_TYPES,
-- MPT_TEMPLATE_TYPES_V, MPT_GLOBAL_VARIABLES_V, MPT_VARIABLE_TYPES.
-- Toza muhitga ko'chirishda ular uchun ham grant/synonym kerak bo'ladi.
--
-- DIQQAT: 10 va 11-bosqichlardagi settings\menu va settings\sm_register
-- INSERT'lari CORE_R_MENUS/ADM_R_MENUS/SM_R_OBJECTS/SM_R_PROCESSES/
-- SM_R_TRANZITIONS jadvallariga yoziladi - bular MPT'ning o'z jadvallari
-- emas, umumiy CORE (framework) sxemasiga tegishli. Agar target muhitda
-- MPT biznes-sxemasi va CORE framework-sxemasi FIZIK JIHATDAN ALOHIDA
-- bo'lsa, shu ikki bosqichni shu faylda emas, CORE sxemasi ostida alohida
-- ishga tushirish kerak bo'ladi.
-- ==========================================================================

SET DEFINE OFF
SET SQLBLANKLINES ON
SET ECHO ON
SET FEEDBACK ON
WHENEVER SQLERROR CONTINUE

SPOOL start.log

PROMPT ==== 01: SEQUENCES ====
@@sequences/mpt_print_history_s1.sql
@@sequences/mpt_print_qr_codes_s1.sql
@@sequences/mpt_print_settings_s1.sql
@@sequences/mpt_print_setting_files_s1.sql
@@sequences/mpt_print_variables_s1.sql
@@sequences/mpt_print_variables_h_sq.sql
@@sequences/mpt_template_cell_mapping_s1.sql
@@sequences/mpt_template_types_s1.sql
@@sequences/mpt_template_types_h_sq.sql
@@sequences/mpt_template_var_mapping_doc_s1.sql
@@sequences/mpt_template_type_vars_s1.sql
@@sequences/mpt_translit_rule_s1.sql
@@sequences/mpt_print_settings_h_sq.sql
@@sequences/mpt_print_setting_files_h_sq.sql

PROMPT ==== 02: TABLES ====
@@tables/mpt_print_history.sql
@@tables/mpt_print_qr_codes.sql
@@tables/mpt_print_settings.sql
@@tables/mpt_print_setting_files.sql
@@tables/mpt_print_templates.sql
@@tables/mpt_print_variables.sql
@@tables/mpt_print_variables_h.sql
@@tables/mpt_states.sql
@@tables/mpt_actions.sql
@@tables/mpt_template_cell_mapping.sql
@@tables/mpt_template_groups.sql
@@tables/mpt_template_types.sql
@@tables/mpt_template_types_h.sql
@@tables/mpt_template_var_mapping_doc.sql
@@tables/mpt_template_type_vars.sql
@@tables/mpt_translit_rule.sql
@@tables/mpt_variable_types.sql
@@tables/mpt_print_settings_h.sql
@@tables/mpt_print_setting_files_h.sql

PROMPT ==== 02b: REFERENCE DATA (MPT_ACTIONS) ====
@@settings/mpt_actions/mpt_actions_data.sql

PROMPT ==== 03: INDEXES ====
@@indexes/mpt_print_history_i1.sql
@@indexes/mpt_print_history_i2.sql
@@indexes/mpt_print_qr_codes_i1.sql
@@indexes/mpt_print_variables_i1.sql

PROMPT ==== 04: FK CONSTRAINTS ====
@@fk_constraints/mpt_print_history_f1.sql
@@fk_constraints/mpt_print_history_f2.sql
@@fk_constraints/mpt_print_history_f3.sql
@@fk_constraints/mpt_print_qr_codes_f1.sql
@@fk_constraints/mpt_print_qr_codes_f2.sql
@@fk_constraints/mpt_print_settings_f1.sql
@@fk_constraints/mpt_print_settings_f2.sql
@@fk_constraints/mpt_print_setting_files_f1.sql
@@fk_constraints/mpt_print_setting_files_f2.sql
@@fk_constraints/mpt_print_templates_f1.sql
@@fk_constraints/mpt_print_templates_f2.sql
@@fk_constraints/mpt_print_variables_f1.sql
@@fk_constraints/mpt_template_cell_mapping_f1.sql
@@fk_constraints/mpt_template_cell_mapping_f2.sql
@@fk_constraints/mpt_template_groups_f1.sql
@@fk_constraints/mpt_template_types_f1.sql
@@fk_constraints/mpt_template_var_mapping_doc_f1.sql
@@fk_constraints/mpt_template_var_mapping_doc_f2.sql
@@fk_constraints/mpt_template_type_vars_f1.sql

PROMPT ==== 05: FUNCTIONS ====
@@functions/mpt_module_name.sql
@@functions/mpt_state_name.sql
@@functions/mpt_action_name.sql
@@functions/mpt_url_escape.sql

PROMPT ==== 06: PACKAGES (spec + body) ====
@@packages/Mpt_Const.pck
@@packages/Mpt_Admin_Api.pck
@@packages/Mpt_Print_Api.pck
@@packages/Mpt_Print_Api_Ut.pck

PROMPT ==== 07: VIEWS ====
@@views/mpt_global_variables_v.sql
@@views/mpt_languages_v.sql
@@views/mpt_modules_v.sql
@@views/mpt_print_settings_v.sql
@@views/mpt_products_v.sql
@@views/mpt_template_types_v.sql
@@views/mpt_template_types_h_v.sql
@@views/mpt_print_variables_h_v.sql
@@views/mpt_template_type_vars_v.sql
@@views/mpt_print_settings_h_v.sql
@@views/mpt_print_setting_files_h_v.sql

PROMPT ==== 08: TRIGGERS ====
@@triggers/mpt_print_history_t1.sql
@@triggers/mpt_print_qr_codes_t1.sql
@@triggers/mpt_print_settings_t1.sql
@@triggers/mpt_print_setting_files_t1.sql
@@triggers/mpt_print_variables_t1.sql
@@triggers/mpt_template_cell_mapping_t1.sql
@@triggers/mpt_template_var_mapping_doc_t1.sql
@@triggers/mpt_template_type_vars_t1.sql
@@triggers/mpt_translit_rule_t1.sql

PROMPT ==== 09: GRANTS & SYNONYMS (ilova sxemasi - UAPP) ====
@@grants/mpt_languages_v.sql
@@grants/mpt_print_setting_files.sql
@@grants/mpt_template_types_h_v.sql
@@grants/mpt_print_variables_h_v.sql
@@grants/mpt_print_api.sql
@@grants/mpt_template_type_vars.sql
@@grants/mpt_print_settings_h_v.sql
@@grants/mpt_print_setting_files_h_v.sql

PROMPT ==== 10: SETTINGS - MENU ====
@@settings/menu/core_r_menus.sql
@@settings/menu/adm_r_menus.sql
@@settings/menu/adm_rel_user_menus.sql

PROMPT ==== 11: SETTINGS - SM_REGISTER ====
@@settings/sm_register/sm_r_objects.sql
@@settings/sm_register/sm_r_processes.sql
@@settings/sm_register/sm_r_tranzitions.sql

-- MLL/MLT registri: menyu va xabar matnlari. mll_label_codes'siz sidebar'da
-- nom o'rniga "<CODE> ni MLL ga qushing!!!" chiqadi (MLL_CORE_API.Get_Label).
-- mlt_* fayllar oddiy INSERT - qayta ishga tushirilganda ORA-00001 beradi,
-- WHENEVER SQLERROR CONTINUE tufayli skript to'xtamaydi.
PROMPT ==== 12: SETTINGS - MLL/MLT REGISTER ====
@@settings/mlt_register/mlt_templates.sql
@@settings/mlt_register/mlt_error_codes.sql
@@settings/menu/mll_label_codes.sql

-- Eski GROUP-darajali biriktiruvni (MPT_TEMPLATE_VAR_MAPPING_DOC) yangi
-- TUR-darajali jadvalga (MPT_TEMPLATE_TYPE_VARS) ko'chirish. NOT EXISTS bilan
-- himoyalangan - qayta ishga tushirsa bo'ladi. Toza muhitda manba bo'sh bo'lsa
-- hech narsa qilmaydi.
PROMPT ==== 13: MIGRATION - TYPE VARS ====
@@settings/mpt_template_type_vars/mpt_template_type_vars_migrate.sql

COMMIT;

PROMPT ==== DONE. Compilation errors bo'lsa quyida chiqadi: ====
SELECT OBJECT_TYPE, OBJECT_NAME, STATUS
FROM USER_OBJECTS
WHERE OBJECT_NAME LIKE 'MPT%' AND STATUS != 'VALID'
ORDER BY OBJECT_TYPE, OBJECT_NAME;

SPOOL OFF
