----------------------------------------------------------------------------------------------------
--  Diagnostika: "tizim xatosi" (auth_login.jsp) sababini tekshirish + tuzatish.
--  CORE foydalanuvchisi sifatida ishga tushiring: sqlplus core/<parol>@host:port/service
----------------------------------------------------------------------------------------------------
set pagesize 100
set linesize 200
column object_name format a30
column object_type format a20

prompt ===================================================================
prompt 1) Sxemada INVALID obyektlar bormi?
prompt ===================================================================
select object_name, object_type, status from user_objects where status != 'VALID' order by object_type, object_name;

prompt ===================================================================
prompt 2) Util_Raw mavjudmi va VALID mi? (Sql_Util shunga tayanadi)
prompt ===================================================================
select object_name, object_type, status from user_objects where object_name='UTIL_RAW' order by 2;

prompt ===================================================================
prompt 3) UAPP foydalanuvchisi mavjudmi?
prompt ===================================================================
select username, account_status from all_users where username='UAPP';

prompt ===================================================================
prompt 4) UAPP uchun kerakli private synonym'lar bormi?
prompt    (kerak: AUTH_LEGACY_BRIDGE, CORE_SIDEBAR, CORE_DASHBOARD, SQL_UTIL,
prompt     ARRAY_VARCHAR2, ARRAY_NUMBER, ARRAY_DATE, CORE_SECURE_UTIL)
prompt ===================================================================
select synonym_name, table_owner, table_name from all_synonyms where owner='UAPP' order by 1;

prompt ===================================================================
prompt 5) Oxirgi login urinishlari (auth_audit_log)
prompt ===================================================================
select event_on, event_type, username_tried, success, reason_code
  from Auth_Audit_Log order by event_on desc fetch first 15 rows only;

prompt ===================================================================
prompt XULOSA: agar (1) bo'sh bo'lmasa - shu obyektlarni tuzating.
prompt         agar (2) yo'q/INVALID - core/package/Util_Raw.pck ni deploy qiling
prompt         (asl vendor versiyasi kerak - o'zingiz taqdim etgan fayl).
prompt         agar (3) yo'q - auth/grants_all_in_one.sql (QISM A) ni SYS sifatida ishga tushiring.
prompt         agar (4) to'liq bo'lmasa - pastdagi FIX blokini SYSDBA sifatida ishga tushiring.
prompt ===================================================================
