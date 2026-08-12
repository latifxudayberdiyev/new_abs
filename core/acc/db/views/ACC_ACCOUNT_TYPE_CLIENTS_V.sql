--------------------------------------------------------------------------------
-- ACC_ACCOUNT_TYPE_CLIENTS_V - дочерняя запись (Тип клиента / Коды COA / Валюта)
-- ro'yxati, joriy tanlangan "Тип счёта" bilan sessiya darajasida filtrlanadi
-- (User_Session.PUT_Number('acc_account_type_id', ...) orqali).
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACC_ACCOUNT_TYPE_CLIENTS_V AS
SELECT c.ACCOUNT_TYPE_CLIENT_ID,
       c.ACCOUNT_TYPE_ID,
       c.CLIENT_TYPE,
       DECODE(c.CLIENT_TYPE, 'C','Клиент', 'B','Bank', c.CLIENT_TYPE) AS CLIENT_TYPE_NAME,
       c.STATE,
       (SELECT NAME FROM R_STATE_V WHERE CODE = c.STATE)      AS STATE_NAME,
       c.CODE_COA,
       NVL(c.CURRENCY_CODE, '*')                               AS CURRENCY_CODE,
       c.CREATED_ON, c.CREATED_BY, c.MODIFIED_ON, c.MODIFIED_BY
  FROM ACC_ACCOUNT_TYPE_CLIENTS c
 WHERE c.ACCOUNT_TYPE_ID = CORE.USER_SESSION.GET_NUMBER('acc_account_type_id');
