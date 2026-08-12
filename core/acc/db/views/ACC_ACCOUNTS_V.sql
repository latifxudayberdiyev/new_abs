--------------------------------------------------------------------------------
-- ACC_ACCOUNTS_V - "Hisob raqamlar" ro'yxati uchun asosiy view (t:table from=).
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACC_ACCOUNTS_V AS
SELECT a.ACCOUNT_ID,
       a.ACCOUNT_CODE,
       a.ACCOUNT_TYPE_ID,
       t.NAME                                                              AS ACCOUNT_TYPE_NAME,
       ('СЧ-' || LPAD(TO_CHAR(a.ACCOUNT_TYPE_ID), 5, '0'))                 AS ACCOUNT_TYPE_CODE,
       a.OWNER_TYPE,
       DECODE(a.OWNER_TYPE, 'C','Клиент', 'B','Bank', a.OWNER_TYPE)        AS OWNER_TYPE_NAME,
       a.CLIENT_ID,
       p.FULL_NAME                                                        AS CLIENT_NAME,
       a.CODE_FILIAL,
       f.NAME                                                              AS FILIAL_NAME,
       a.CODE_CURRENCY,
       c.NAME                                                              AS CURRENCY_NAME,
       a.ABS_ACCOUNT_ID,
       a.ACCOUNT_STATUS,
       DECODE(a.ACCOUNT_STATUS, 'O','Открыт', 'C','Закрыт', 'B','Заблокирован', a.ACCOUNT_STATUS) AS ACCOUNT_STATUS_NAME,
       a.DATE_OPEN,
       a.DATE_CLOSE,
       (SELECT COUNT(*) FROM ACC_ACCOUNT_MODULES m WHERE m.ACCOUNT_ID = a.ACCOUNT_ID) AS MODULE_COUNT,
       a.CREATED_ON, a.CREATED_BY, a.MODIFIED_ON, a.MODIFIED_BY
  FROM ACC_ACCOUNTS a, ACC_ACCOUNT_TYPES t, ABS_BRANCHES f, CBR_CURRENCY_V c, CL_PHYS_PERSONS_V p
 WHERE a.ACCOUNT_TYPE_ID = t.ACCOUNT_TYPE_ID
   AND a.CODE_FILIAL = f.CODE (+)
   AND a.CODE_CURRENCY = c.CODE (+)
   AND a.CLIENT_ID = p.CLIENT_ID (+);
