--------------------------------------------------------------------------------
-- ACC_ACCOUNT_TYPE_HISTORY_V - "Тип счёта" o'zgarishlar tarixi, joriy
-- tanlangan yozuv bilan sessiya darajasida filtrlanadi
-- (User_Session.PUT_Number('acc_account_type_id', ...) orqali).
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACC_ACCOUNT_TYPE_HISTORY_V AS
SELECT h.HISTORY_ID,
       h.ACCOUNT_TYPE_ID,
       h.ACTION_CODE,
       DECODE(h.ACTION_CODE, 'CREATE','Создание', 'UPDATE','Изменение', 'DELETE','Удаление', h.ACTION_CODE) AS ACTION_NAME,
       h.MODIFIED_ON,
       h.MODIFIED_BY,
       h.BEFORE_SNAPSHOT,
       h.AFTER_SNAPSHOT
  FROM ACC_ACCOUNT_TYPE_HISTORY h
 WHERE h.ACCOUNT_TYPE_ID = CORE.USER_SESSION.GET_NUMBER('acc_account_type_id')
 ORDER BY h.MODIFIED_ON DESC;
