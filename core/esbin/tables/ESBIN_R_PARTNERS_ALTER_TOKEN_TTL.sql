SET LINESIZE 200
SET PAGESIZE 100
----------------------------------------------------------------------------------------------------
-- ESBIN_R_PARTNERS_ALTER_TOKEN_TTL.sql
--
-- Partner darajasida token muddati override'i (NULL bo'lsa Esbin_Const.c_Token_Ttl_Min
-- ishlatiladi - Esbin_Kernel.Login shu qiymatni Nvl() bilan oladi).
--
-- DIQQAT - BU DDL / MIGRATSIYA: ishga tushirishdan OLDIN lead/reviewer tasdig'i SHART.
--
-- ROLLBACK:
--   ALTER TABLE ESBIN_R_PARTNERS DROP CONSTRAINT ESBIN_R_PARTNERS_C2;
--   ALTER TABLE ESBIN_R_PARTNERS DROP COLUMN TOKEN_TTL_MIN;
--
-- Run as CORE schema owner.
----------------------------------------------------------------------------------------------------

ALTER TABLE ESBIN_R_PARTNERS ADD (TOKEN_TTL_MIN NUMBER);
ALTER TABLE ESBIN_R_PARTNERS ADD CONSTRAINT ESBIN_R_PARTNERS_C2 CHECK (TOKEN_TTL_MIN IS NULL OR (TOKEN_TTL_MIN > 0 AND TOKEN_TTL_MIN <= 1440));

COMMENT ON COLUMN ESBIN_R_PARTNERS.TOKEN_TTL_MIN IS 'Shu partnerning texnik userlari uchun token muddati (daqiqada), standart Esbin_Const.c_Token_Ttl_Min ustidan override. NULL = standart qiymat ishlatiladi';

PROMPT === verify ===
SELECT column_name, data_type, nullable FROM user_tab_columns WHERE table_name = 'ESBIN_R_PARTNERS' ORDER BY column_id;
SELECT constraint_name, search_condition, status FROM user_constraints WHERE table_name = 'ESBIN_R_PARTNERS' AND constraint_name = 'ESBIN_R_PARTNERS_C2';
