SET LINESIZE 200
SET PAGESIZE 100
----------------------------------------------------------------------------------------------------
-- ESBIN_R_PARTNERS_H_ALTER_TOKEN_TTL.sql
--
-- ESBIN_R_PARTNERS.TOKEN_TTL_MIN uchun mos tarix ustuni - Esbin_Dml.Log_Partner_History
-- endi buni ham insert/select qiladi (boshqa snapshot ustunlari - NAME/STATE - kabi nullable).
--
-- DIQQAT - BU DDL / MIGRATSIYA: ishga tushirishdan OLDIN lead/reviewer tasdig'i SHART.
--
-- ROLLBACK:
--   ALTER TABLE ESBIN_R_PARTNERS_H DROP COLUMN TOKEN_TTL_MIN;
--
-- Run as CORE schema owner.
----------------------------------------------------------------------------------------------------

ALTER TABLE ESBIN_R_PARTNERS_H ADD (TOKEN_TTL_MIN NUMBER);

COMMENT ON COLUMN ESBIN_R_PARTNERS_H.TOKEN_TTL_MIN IS 'Amal vaqtidagi ESBIN_R_PARTNERS.TOKEN_TTL_MIN snapshot''i';

PROMPT === verify ===
SELECT column_name, data_type, nullable FROM user_tab_columns WHERE table_name = 'ESBIN_R_PARTNERS_H' ORDER BY column_id;
