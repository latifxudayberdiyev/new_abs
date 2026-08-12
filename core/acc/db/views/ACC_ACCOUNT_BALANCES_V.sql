--------------------------------------------------------------------------------
-- ACC_ACCOUNT_BALANCES_V - hisobning joriy ostatka/oborot holati (faqat
-- ko'rish uchun - bu ma'lumot BANK ABS dan sinxronlanadi, qo'lda kiritilmaydi).
-- Joriy tanlangan hisob bilan sessiya darajasida filtrlanadi
-- (User_Session.PUT_Number('acc_account_id', ...) orqali).
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACC_ACCOUNT_BALANCES_V AS
SELECT b.ACCOUNT_BALANCE_ID,
       b.ACCOUNT_ID,
       b.SALDO_IN,
       b.SALDO_OUT,
       b.INCOME,
       b.EXPENSE,
       b.INCOME_ALL,
       b.EXPENSE_ALL,
       b.SYNC_DATE,
       b.CREATED_ON,
       b.MODIFIED_ON
  FROM ACC_ACCOUNT_BALANCES b
 WHERE b.ACCOUNT_ID = CORE.USER_SESSION.GET_NUMBER('acc_account_id');
