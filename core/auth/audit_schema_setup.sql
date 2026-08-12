----------------------------------------------------------------------------------------------------
--  CORE_AUDIT - AUTH_DEBUG_SESSION_LOG uchun alohida sxema.
--
--  SABAB (Opus xavfsizlik auditi, topilma H1): jadval avval CORE sxemasida
--  edi, faqat UPDATE/DELETE trigger bilan himoyalangan - lekin CORE sxema
--  egasi TRUNCATE TABLE (trigger'ni umuman ishga tushirmaydi), yoki
--  trigger'ni DISABLE/DROP qilib, keyin DELETE qilishi mumkin edi. Bu esa
--  "CORE egasi debug-sessiya audit izini o'chira olmasin" degan asosiy
--  maqsadga zid edi.
--
--  Yechim: jadval/sequence CORE_AUDIT sxemasida yaratiladi. CORE_AUDIT'ga
--  CREATE SESSION UMUMAN berilmaydi - hech kim (CORE ham) bu sxemaga
--  to'g'ridan-to'g'ri ulana olmaydi. CORE'ga faqat INSERT (jadvalga) va
--  SELECT (sequence uchun) grant qilinadi - oddiy (ANY-huquqsiz) sessiya
--  uchun TRUNCATE/DROP/UPDATE/DELETE imkonsiz.
--
--  Ishga tushirish: SYS/SYSDBA sifatida, bir marta (auth/start.sql yoki
--  deploy_all.sql'dan OLDIN - Auth_Session.pck shu obyektlarga sinonim
--  orqali murojaat qiladi).
----------------------------------------------------------------------------------------------------

-- ESLATMA: kuchli, o'zingiz tanlagan parol bilan yarating (bu yerga
-- yozilmaydi - xavfsizlik uchun). CREATE SESSION ATAYLAB berilmaydi.
--   create user CORE_AUDIT identified by <kuchli_parol>
--     default tablespace CORE_DATA
--     quota unlimited on CORE_DATA
--     quota unlimited on CORE_INDEX;

CREATE TABLE CORE_AUDIT.AUTH_DEBUG_SESSION_LOG
(
  log_id           NUMBER(12)    NOT NULL,
  event_on         DATE          NOT NULL,
  db_session_user  VARCHAR2(30)  NOT NULL,
  os_user          VARCHAR2(60),
  host             VARCHAR2(120),
  client_ip        VARCHAR2(45),
  branch_code      VARCHAR2(5)   NOT NULL,
  cb_code          VARCHAR2(5)   NOT NULL,
  local_code       VARCHAR2(5)   NOT NULL,
  reason           VARCHAR2(500) NOT NULL
)
TABLESPACE CORE_DATA;

COMMENT ON TABLE  CORE_AUDIT.AUTH_DEBUG_SESSION_LOG                 IS 'Open_Debug_Session chaqiruvlari audit izi (CORE - faqat INSERT)';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.log_id          IS 'Yagona identifikator (AUTH_DEBUG_SESSION_LOG_SQ)';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.event_on        IS 'Debug-sessiya ochilgan sana/vaqt';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.db_session_user IS 'DB sessiyasi ulangan foydalanuvchi (SYS_CONTEXT USERENV SESSION_USER)';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.os_user         IS 'Mijoz OS foydalanuvchisi (spoof qilinishi mumkin - faqat ma''lumot uchun)';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.host            IS 'Mijoz host nomi';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.client_ip       IS 'Mijoz IP manzili';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.branch_code     IS 'So''ralgan filial kodi (Abs_Branches.code)';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.cb_code         IS 'Filialning cb_code qiymati (Abs_Branches''dan topilgan)';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.local_code      IS 'Filialning local_code qiymati (Abs_Branches''dan topilgan)';
COMMENT ON COLUMN CORE_AUDIT.AUTH_DEBUG_SESSION_LOG.reason          IS 'Majburiy - nima uchun debug-sessiya ochilgani';

ALTER TABLE CORE_AUDIT.AUTH_DEBUG_SESSION_LOG ADD CONSTRAINT AUTH_DEBUG_SESSION_LOG_PK PRIMARY KEY (LOG_ID) USING INDEX TABLESPACE CORE_INDEX;

CREATE INDEX CORE_AUDIT.AUTH_DEBUG_SESSION_LOG_I1 ON CORE_AUDIT.AUTH_DEBUG_SESSION_LOG (EVENT_ON) TABLESPACE CORE_INDEX;

-- ESLATMA: bu yerda ataylab UPDATE/DELETE trigger YO'Q. Sinovda tasdiqlandi
-- (2026-07-22) - CORE'da mavjud CREATE ANY TRIGGER tizim huquqi tufayli
-- CORE trigger'ni istalgan payt qayta yozib (no-op qilib) chetlab o'ta oladi,
-- keyin o'zining DELETE ANY TABLE huquqi bilan yozuvni o'chiradi - ya'ni
-- trigger CORE'ga qarshi haqiqiy himoya bermaydi, faqat keraksiz
-- murakkablik qo'shadi. Asosiy himoya - CORE'da UPDATE/DELETE grantining
-- umuman yo'qligi (pastda): oddiy, ANY-huquqsiz sessiya uchun bu yetarli;
-- CORE'ning o'zidagi keng ANY-huquqlar - alohida, kattaroq masala
-- (bu skript doirasidan tashqarida).

-- Create sequence
CREATE SEQUENCE CORE_AUDIT.AUTH_DEBUG_SESSION_LOG_SQ
MINVALUE 1
MAXVALUE 999999999999
START WITH 1
INCREMENT BY 1
CACHE 20;

-- CORE'ga FAQAT INSERT (jadval) va SELECT (sequence.nextval uchun) -
-- UPDATE/DELETE/ALTER/DROP huquqlari YO'Q, shuning uchun TRUNCATE TABLE,
-- trigger'ni DISABLE qilish yoki DROP TABLE CORE tomonidan BAJARILA OLMAYDI.
GRANT INSERT ON CORE_AUDIT.AUTH_DEBUG_SESSION_LOG TO CORE;
GRANT SELECT ON CORE_AUDIT.AUTH_DEBUG_SESSION_LOG_SQ TO CORE;

-- Auth_Session.pck'dagi mavjud kod (Auth_Debug_Session_Log, .Sq.nextval)
-- o'zgartirilmasdan ishlashi uchun - CORE ichida xuddi shu nom bilan
-- ko'rinadi (Oracle nom-hal qilish uchun sinonim shart).
CREATE OR REPLACE SYNONYM CORE.AUTH_DEBUG_SESSION_LOG    FOR CORE_AUDIT.AUTH_DEBUG_SESSION_LOG;
CREATE OR REPLACE SYNONYM CORE.AUTH_DEBUG_SESSION_LOG_SQ FOR CORE_AUDIT.AUTH_DEBUG_SESSION_LOG_SQ;

PROMPT === Tayyor: CORE_AUDIT.AUTH_DEBUG_SESSION_LOG - CORE faqat INSERT qila oladi. ===
