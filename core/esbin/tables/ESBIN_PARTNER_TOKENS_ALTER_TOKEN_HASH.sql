SET LINESIZE 200
SET PAGESIZE 100
----------------------------------------------------------------------------------------------------
-- ESBIN_PARTNER_TOKENS_ALTER_TOKEN_HASH.sql
--
-- ESBIN_PARTNER_TOKENS jadvalini bearer-token oqimi uchun qayta quradi:
--   - ACCESS_TOKEN (xom token) -> ACCESS_TOKEN_HASH (SHA-256, xom token DB'da
--     hech qachon saqlanmaydi - Esbin_Util.Get_Token_User endi hash bo'yicha qidiradi)
--   - EXPIRES_ON (belgilangan muddatli tokenlar), REVOKED_ON/REVOKE_REASON
--     (aniq revoke belgisi - Get_Token_User shuni tekshiradi)
--   - ESBIN_PARTNER_TOKENS_IX1 endi UNIQUE (ikki foydalanuvchida bir xil hash bo'lishi mumkin emas)
--
-- DIQQAT - BU DDL / MIGRATSIYA: ishga tushirishdan OLDIN lead/reviewer tasdig'i SHART.
-- Bu subsystem hali live emas (git'ga ham commit qilinmagan) - lekin agar biror
-- dev/stage muhitida ESBIN_PARTNER_TOKENS'da qator bo'lsa, quyidagi UPDATE
-- backfill qadami ORA-02296 (NOT NULL/mavjud NULL qiymat)ni oldini olish uchun kerak.
--
-- ROLLBACK (agar migratsiya bekor qilinishi kerak bo'lsa - EXPIRES_ON/REVOKED_ON/
-- REVOKE_REASON'dagi ma'lumot yo'qoladi, chunki ular DROP qilinadi):
--   ALTER TABLE ESBIN_PARTNER_TOKENS RENAME COLUMN ACCESS_TOKEN_HASH TO ACCESS_TOKEN;
--   ALTER TABLE ESBIN_PARTNER_TOKENS DROP (EXPIRES_ON, REVOKED_ON, REVOKE_REASON);
--   DROP INDEX ESBIN_PARTNER_TOKENS_IX1;
--   CREATE INDEX ESBIN_PARTNER_TOKENS_IX1 ON ESBIN_PARTNER_TOKENS (ACCESS_TOKEN) TABLESPACE CORE_INDEX;
--
-- Run as CORE schema owner.
----------------------------------------------------------------------------------------------------

ALTER TABLE ESBIN_PARTNER_TOKENS RENAME COLUMN ACCESS_TOKEN TO ACCESS_TOKEN_HASH;

DROP INDEX ESBIN_PARTNER_TOKENS_IX1;

ALTER TABLE ESBIN_PARTNER_TOKENS ADD (EXPIRES_ON DATE, REVOKED_ON DATE, REVOKE_REASON VARCHAR2(40));

-- Backfill: agar bu muhitda allaqachon qator bo'lsa (bo'lmasligi kerak, lekin
-- xavfsizlik uchun) - aks holda keyingi MODIFY NOT NULL ORA-02296 bilan yiqiladi.
UPDATE ESBIN_PARTNER_TOKENS SET EXPIRES_ON = SYSDATE WHERE EXPIRES_ON IS NULL;

ALTER TABLE ESBIN_PARTNER_TOKENS MODIFY EXPIRES_ON NOT NULL;

CREATE UNIQUE INDEX ESBIN_PARTNER_TOKENS_IX1 ON ESBIN_PARTNER_TOKENS (ACCESS_TOKEN_HASH) TABLESPACE CORE_INDEX;

COMMENT ON COLUMN ESBIN_PARTNER_TOKENS.ACCESS_TOKEN_HASH IS 'Access token SHA-256 xeshi - xom token hech qachon DB''da saqlanmaydi';
COMMENT ON COLUMN ESBIN_PARTNER_TOKENS.EXPIRES_ON IS 'Tokenning belgilangan muddati (login vaqtida sysdate + ttl_min/1440 sifatida hisoblanadi)';
COMMENT ON COLUMN ESBIN_PARTNER_TOKENS.REVOKED_ON IS 'Aniq revoke qilingan vaqt - Esbin_Util.Get_Token_User buni tekshiradi (NULL bo''lishi kerak, aks holda token yaroqsiz)';
COMMENT ON COLUMN ESBIN_PARTNER_TOKENS.REVOKE_REASON IS 'Revoke sababi (masalan LOGOUT, ADMIN_REVOKE)';

PROMPT === verify ===
SELECT column_name, data_type, nullable FROM user_tab_columns WHERE table_name = 'ESBIN_PARTNER_TOKENS' ORDER BY column_id;
SELECT index_name, uniqueness FROM user_indexes WHERE table_name = 'ESBIN_PARTNER_TOKENS' AND index_name = 'ESBIN_PARTNER_TOKENS_IX1';
