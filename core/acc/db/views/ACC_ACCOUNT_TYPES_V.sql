--------------------------------------------------------------------------------
-- ACC_ACCOUNT_TYPES_V - "Тип счёта" ro'yxati uchun asosiy view (t:table from=).
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACC_ACCOUNT_TYPES_V AS
SELECT t.ACCOUNT_TYPE_ID,
       'СЧ-' || LPAD(TO_CHAR(t.ACCOUNT_TYPE_ID), 5, '0')      AS CODE,
       t.NAME,
       t.MODULE_CODE,
       m.MODULE_NAME,
       t.BALANCE_TYPE,
       t.STATE,
       (SELECT NAME FROM R_STATE_V WHERE CODE = t.STATE)      AS STATE_NAME,
       t.UNIQUE_CONTRACT_FLAG,
       (SELECT NAME FROM CORE_R_YES_NO WHERE CODE = t.UNIQUE_CONTRACT_FLAG) AS UNIQUE_CONTRACT_NAME,
       t.IS_OPEN_FLAG,
       (SELECT NAME FROM CORE_R_YES_NO WHERE CODE = t.IS_OPEN_FLAG) AS IS_OPEN_NAME,
       t.INCODE_TYPE,
       t.IS_VIRTUAL,
       (SELECT NAME FROM CORE_R_YES_NO WHERE CODE = t.IS_VIRTUAL) AS IS_VIRTUAL_NAME,
       t.OBJECT_CODE,
       (SELECT COUNT(*) FROM ACC_ACCOUNT_TYPE_CLIENTS c WHERE c.ACCOUNT_TYPE_ID = t.ACCOUNT_TYPE_ID) AS CHILD_COUNT,
       t.CREATED_ON, t.CREATED_BY, t.MODIFIED_ON, t.MODIFIED_BY
  FROM ACC_ACCOUNT_TYPES t, ACC_R_MODULES m
 WHERE t.MODULE_CODE = m.MODULE_CODE;
