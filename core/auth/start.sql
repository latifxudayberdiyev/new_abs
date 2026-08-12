set define off;
--
prompt =====================================================================
prompt  AUTH subsystem install (Oracle 19c, schema CORE)
prompt  Pre-req (run once as SYS/DBA):
prompt    @@grants.sql                         -- DBMS_CRYPTO / DBMS_SESSION
prompt    (CREATE ANY CONTEXT privilege needed for the context step below)
prompt    @@audit_schema_setup.sql             -- CORE_AUDIT sxema (Auth_Session.pck
prompt    shu obyektlarga sinonim orqali murojaat qiladi - shundan OLDIN kerak)
prompt =====================================================================
prompt tables\...
@@tables\AUTH_LOGIN_NONCE.sql
@@tables\AUTH_LOGIN_STAGE.sql
@@tables\AUTH_SESSIONS.sql
@@tables\AUTH_AUDIT_LOG.sql
@@tables\AUTH_LOCKOUTS.sql
@@tables\AUTH_PASSWORD_RESETS.sql
/
prompt =====================================================================
prompt sequences\...
@@sequences\AUTH_AUDIT_LOG_SQ.sql
/
prompt =====================================================================
prompt packages\...   (order matters: Const -> Pepper -> Util -> ... -> Api)
prompt   NOTE: Auth_Pepper.pck ships with a placeholder secret (see .gitignore).
prompt         DBA must replace c_Pepper with a real random value before go-live.
@@packages\Auth_Const.spc
@@packages\Auth_Pepper.pck
@@packages\Auth_Util.pck
@@packages\Auth_Nonce.pck
@@packages\Auth_Lockout.pck
@@packages\Auth_Audit.pck
@@packages\Auth_Session.pck
@@packages\Auth_Kernel.pck
@@packages\Auth_Pwd_Kernel.pck
@@packages\Auth_Api.pck
@@packages\Auth_Legacy_Bridge.pck
/
prompt =====================================================================
prompt context\...    (depends on CORE.AUTH_SESSION; needs CREATE ANY CONTEXT)
@@contexts\UAPP.sql
/
prompt =====================================================================
prompt OPTIONAL: debug-session tooling (Auth_Session.Open_Debug_Session).
prompt   CORE sqlplus-only, hech qachon UAPP'ga grant qilinmaydi. Bir marta
prompt   sozlash uchun qo'lda ishga tushiring: @@create_debug_user.sql
prompt OPTIONAL: job-actor tooling (Auth_Session.Open_Job_Actor) - rejalash-
prompt   tirilgan job'lar uchun. Bir marta sozlash: @@create_job_user.sql
prompt =====================================================================
prompt recompile invalid objects
-- TODO: ..\sm\constant\compile.sql va invalid.sql repoda topilmadi (2026-07-08
-- audit) - shu fayllar tiklanguncha yoki bu qadam olib tashlanguncha izohga
-- olindi, aks holda start.sql shu yerda xato berib to'xtar edi.
--@@..\sm\constant\compile.sql;
prompt =====================================================================
prompt Check invalid objects ..
--@@..\sm\constant\invalid.sql;
--
set define on;
spool off;
