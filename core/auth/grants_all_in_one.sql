----------------------------------------------------------------------------------------------------
--  BARCHA kerakli grant/synonym - bitta yagona, tartibli skript.
--  Repo boyicha tarqalib ketgan (auth/grants.sql, auth/fix_uapp_setup.sql va
--  boshqa joylardagi izohlarda qolib ketgan) barcha GRANT/SYNONYM shu yerga
--  yigildi. Idempotent - qayta ishga tushirish xavfsiz.
--
--  QISM A: SYS / SYSDBA sifatida ishga tushiring.
--  QISM B: CORE schema egasi sifatida ishga tushiring.
----------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------------------------
-- QISM A: SYS / SYSDBA
----------------------------------------------------------------------------------------------------

-- A1) CORE uchun kerakli tizim paketlari
-- DBMS_CRYPTO: PBKDF2/HMAC (parol xeshlash)
GRANT EXECUTE ON SYS.DBMS_CRYPTO  TO CORE;
-- DBMS_SESSION: UAPP kontekstini ornatish uchun
GRANT EXECUTE ON SYS.DBMS_SESSION TO CORE;
-- Auth_Session.Purge_Expired scheduler uchun
GRANT CREATE JOB TO CORE;

-- A2) UAPP ishonchli konteksti (faqat CORE.AUTH_SESSION ornata oladi)
-- ESLATMA: UAPP foydalanuvchisining ozi shu skriptda yaratilmaydi - u
-- allaqachon mavjud deb faraz qilinadi. Agar hali yoq bolsa, uni ozingiz
-- (kuchli, ozingiz tanlagan parol bilan) alohida yarating:
--   create user UAPP identified by <kuchli_parol> ...;
--   grant create session to UAPP;
declare
  v_cnt number;
begin
  select count(*) into v_cnt from dba_context where context = 'UAPP';
  if v_cnt = 0 then
    execute immediate 'create or replace context UAPP using CORE.AUTH_SESSION';
    dbms_output.put_line('UAPP context yaratildi.');
  else
    dbms_output.put_line('UAPP context allaqachon mavjud, otkazib yuborildi.');
  end if;
end;
/

prompt ==========================================================================
prompt QISM A tugadi. Endi QISM B ni CORE schema egasi sifatida ishga tushiring.
prompt ==========================================================================


----------------------------------------------------------------------------------------------------
-- QISM B: CORE schema egasi
----------------------------------------------------------------------------------------------------

-- B1) UAPP uchun kerakli paket/turlarga EXECUTE (private, PUBLIC emas)
-- auth_login.jsp, forgot/reset/change password
grant execute on CORE.AUTH_LEGACY_BRIDGE to UAPP;
-- Foydalanuvchilar (users.jsp/user.jsp), SM engine dispatch
grant execute on CORE.CORE_API to UAPP;
-- Foydalanuvchining local_code (filial) dostupini tekshirish (Core_Locals.Has_Local_Access/
-- Assert_Local_Access) - jadvalning o'ziga (ADM_REL_USER_LOCALS) EMAS, faqat shu paketga.
grant execute on CORE.CORE_LOCALS to UAPP;
-- main.jsp sidebar menyusi
grant execute on CORE.CORE_SIDEBAR to UAPP;
-- dashboard.jsp KPI/grafiklar
grant execute on CORE.CORE_DASHBOARD to UAPP;
grant execute on CORE.SQL_UTIL to UAPP;
grant execute on CORE.CORE_SECURE_UTIL to UAPP;
-- Get_User_Menu OUT parametri (JDBC registerArrayString)
grant execute on CORE.ARRAY_VARCHAR2 to UAPP;
grant execute on CORE.ARRAY_NUMBER to UAPP;
grant execute on CORE.ARRAY_DATE to UAPP;
-- AuthFilter/AuthDb.java: per-request session validation (Validate_Session)
grant execute on CORE.AUTH_API to UAPP;

-- B2) Foydalanuvchilar (Users) grid/forma ishlatadigan view/lookuplarga SELECT
-- users.jsp: t:table from="core_users_v"
grant select on CORE.CORE_USERS_V to UAPP;
-- user.jsp: t:options / t:reference lookuplar
grant select on CORE.CORE_R_LOCAL_CODES    to UAPP;
grant select on CORE.CORE_R_USER_TYPES     to UAPP;
grant select on CORE.CORE_R_ACCESS_DENIEDS to UAPP;
grant select on CORE.CORE_R_HR_USERS       to UAPP;
grant select on CORE.R_STATE_V             to UAPP;
grant select on CORE.CORE_R_PROVIDER_TYPES to UAPP;
grant select on CORE.CORE_R_YES_NO         to UAPP;

-- B3) Private synonymlar (Oracle nom-hal qilish uchun, GRANT EXECUTE/SELECT yetarli emas)
create or replace synonym UAPP.AUTH_LEGACY_BRIDGE for CORE.AUTH_LEGACY_BRIDGE;
create or replace synonym UAPP.CORE_API           for CORE.CORE_API;
create or replace synonym UAPP.CORE_LOCALS        for CORE.CORE_LOCALS;
create or replace synonym UAPP.CORE_SIDEBAR       for CORE.CORE_SIDEBAR;
create or replace synonym UAPP.CORE_DASHBOARD     for CORE.CORE_DASHBOARD;
create or replace synonym UAPP.SQL_UTIL           for CORE.SQL_UTIL;
create or replace synonym UAPP.CORE_SECURE_UTIL   for CORE.CORE_SECURE_UTIL;
create or replace synonym UAPP.ARRAY_VARCHAR2     for CORE.ARRAY_VARCHAR2;
create or replace synonym UAPP.ARRAY_NUMBER       for CORE.ARRAY_NUMBER;
create or replace synonym UAPP.ARRAY_DATE         for CORE.ARRAY_DATE;
create or replace synonym UAPP.AUTH_API           for CORE.AUTH_API;
create or replace synonym UAPP.CORE_USERS_V           for CORE.CORE_USERS_V;
create or replace synonym UAPP.CORE_R_LOCAL_CODES     for CORE.CORE_R_LOCAL_CODES;
create or replace synonym UAPP.CORE_R_USER_TYPES      for CORE.CORE_R_USER_TYPES;
create or replace synonym UAPP.CORE_R_ACCESS_DENIEDS  for CORE.CORE_R_ACCESS_DENIEDS;
create or replace synonym UAPP.CORE_R_HR_USERS        for CORE.CORE_R_HR_USERS;
create or replace synonym UAPP.R_STATE_V              for CORE.R_STATE_V;
create or replace synonym UAPP.CORE_R_PROVIDER_TYPES  for CORE.CORE_R_PROVIDER_TYPES;
create or replace synonym UAPP.CORE_R_YES_NO          for CORE.CORE_R_YES_NO;

prompt ==========================================================================
prompt Tekshirish:
prompt ==========================================================================
select grantee, privilege, table_name
  from all_tab_privs
 where grantee = 'UAPP'
 order by table_name;

select synonym_name, table_owner, table_name
  from all_synonyms
 where owner = 'UAPP'
 order by synonym_name;

prompt === Tayyor. ===

----------------------------------------------------------------------------------------------------
-- ESLATMA (auth/grants.sql'dan kochirildi): main_request.jsp hali ham
-- CORE_MENU/CORE_ADM_API/CHAT_MES/SETUP va CORE_AC_OPER_DAYS_V ni chaqiradi -
-- bular hozircha bu repoda yoq (eski/tashqi obyektlar). Mavjud bolganda
-- ularga ham xuddi shu tarzda (B1/B2 uslubida) UAPP'ga EXECUTE/SELECT grant
-- + private synonym qoshilsin.
----------------------------------------------------------------------------------------------------
