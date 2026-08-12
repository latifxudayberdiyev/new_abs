SET LINESIZE 200
SET PAGESIZE 100
----------------------------------------------------------------------------------------------------
-- ESBIN_R_PARTNER_USERS_ALTER_IP_ALLOWLIST.sql
--
-- Har bir texnik (partner) user uchun majburiy IP allowlist (vergul bilan
-- ajratilgan IPv4/CIDR ro'yxati) - Esbin_Kernel.Login (parol tekshirishdan OLDIN)
-- va Esbin_Util.Get_Token_User (har bir token lookup'da) tekshiradi.
--
-- Shuningdek: bitta texnik user bir vaqtning o'zida faqat bitta ACTIVE partnerga
-- tegishli bo'lishini ta'minlaydigan UNIQUE funksional indeks.
--
-- DIQQAT - BU DDL / MIGRATSIYA: ishga tushirishdan OLDIN lead/reviewer tasdig'i SHART.
-- MUHIM: IP_ALLOWLIST NOT NULL qilinadi - agar bu muhitda ESBIN_R_PARTNER_USERS'da
-- allaqachon qator bo'lsa, quyidagi MODIFY NOT NULL ORA-02296 bilan yiqiladi -
-- avval har bir mavjud qatorga haqiqiy allowlist qiymati backfill qiling
-- (bu skript o'zi taxminiy/soxta qiymat bilan backfill QILMAYDI - xato IP oralig'i
-- xavfsizlik teshigi bo'lishi mumkin, shuning uchun bu qadam qo'lda, review bilan).
--
-- ROLLBACK:
--   DROP INDEX ESBIN_R_PARTNER_USERS_U1;
--   ALTER TABLE ESBIN_R_PARTNER_USERS DROP CONSTRAINT ESBIN_R_PARTNER_USERS_C2;
--   ALTER TABLE ESBIN_R_PARTNER_USERS DROP COLUMN IP_ALLOWLIST;
--
-- Run as CORE schema owner.
----------------------------------------------------------------------------------------------------

ALTER TABLE ESBIN_R_PARTNER_USERS ADD (IP_ALLOWLIST VARCHAR2(1000));

-- Agar bu muhitda oldindan qator mavjud bo'lsa, quyidagi qator xato beradi -
-- shu holatda MODIFY'dan oldin har bir qatorga haqiqiy allowlist qo'yilishi SHART.
ALTER TABLE ESBIN_R_PARTNER_USERS MODIFY IP_ALLOWLIST NOT NULL;

ALTER TABLE ESBIN_R_PARTNER_USERS
  ADD CONSTRAINT ESBIN_R_PARTNER_USERS_C2
  CHECK (REGEXP_LIKE(IP_ALLOWLIST,
                      '^\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(/\d{1,2})?\s*(,\s*\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(/\d{1,2})?\s*)*$'));

COMMENT ON COLUMN ESBIN_R_PARTNER_USERS.IP_ALLOWLIST IS 'Vergul bilan ajratilgan IPv4/CIDR ro''yxati (masalan "10.1.2.3,10.1.2.0/24") - Login''da (parol tekshirishdan OLDIN) va har bir token lookup''da (Get_Token_User) tekshiriladi';

-- Bitta texnik user bir vaqtda faqat bitta ACTIVE partnerga tegishli bo'lishi kerak.
CREATE UNIQUE INDEX ESBIN_R_PARTNER_USERS_U1 ON ESBIN_R_PARTNER_USERS (CASE WHEN STATE = 'A' THEN USER_ID END);

PROMPT === verify ===
SELECT column_name, data_type, nullable FROM user_tab_columns WHERE table_name = 'ESBIN_R_PARTNER_USERS' ORDER BY column_id;
SELECT constraint_name, search_condition, status FROM user_constraints WHERE table_name = 'ESBIN_R_PARTNER_USERS' AND constraint_name = 'ESBIN_R_PARTNER_USERS_C2';
SELECT index_name, uniqueness FROM user_indexes WHERE table_name = 'ESBIN_R_PARTNER_USERS' AND index_name = 'ESBIN_R_PARTNER_USERS_U1';
