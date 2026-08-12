--------------------------------------------------------------------------------
-- ACC_ACCOUNT_MODULES_V - bank nomiga ochilgan hisobning qaysi modullarda
-- foydalanilishi ro'yxati, joriy tanlangan hisob bilan sessiya darajasida
-- filtrlanadi (User_Session.PUT_Number('acc_account_id', ...) orqali).
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACC_ACCOUNT_MODULES_V AS
SELECT m.ACCOUNT_MODULE_ID,
       m.ACCOUNT_ID,
       m.MODULE_CODE,
       r.MODULE_NAME,
       m.IS_ACTIVE_FLAG,
       DECODE(m.IS_ACTIVE_FLAG, 'Y','Да', 'N','Нет', m.IS_ACTIVE_FLAG)     AS IS_ACTIVE_NAME,
       m.CONNECTED_ON,
       m.DISCONNECTED_ON,
       m.CREATED_ON,
       m.CREATED_BY
  FROM ACC_ACCOUNT_MODULES m, ACC_R_MODULES r
 WHERE m.MODULE_CODE = r.MODULE_CODE
   AND m.ACCOUNT_ID = CORE.USER_SESSION.GET_NUMBER('acc_account_id');
