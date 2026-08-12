----------------------------------------------------------------------------------------------------
--  Запуск всех тестов AUTH по порядку. Выполнять как CORE.
--  Порядок установки: выполнить core/auth/start.sql и грант grants.sql (SYS).
--  Запуск:  sqlplus core/*** @core/auth/Tests/run_all.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;
set define off;
prompt =====================================================================
prompt  AUTH TESTS
prompt =====================================================================
@@00_setup_fixture.sql
@@10_test_auth_util.sql
@@20_test_auth_nonce.sql
@@30_test_auth_lockout.sql
@@40_test_auth_session.sql
@@50_test_auth_api_flow.sql
@@60_test_pwd_flow.sql
@@70_test_local_login.sql
@@99_teardown_fixture.sql
prompt =====================================================================
prompt  AUTH TESTS finished - смотрите итоговый PASS/FAIL выше
prompt =====================================================================
set define on;
