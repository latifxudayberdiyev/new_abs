--------------------------------------------------------------------------------
-- ABS_BRANCHES_V - filiallar ro'yxati uchun faqat o'qish uchun view (acc_account.jsp
-- filial reference-picker qidiruvi ABS_BRANCHES jadvaliga to'g'ridan-to'g'ri emas,
-- shu view orqali kirishi kerak - UAPP sxemasi jadvalga to'g'ridan-to'g'ri huquqi yo'q).
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ABS_BRANCHES_V AS
SELECT b.CODE, b.NAME, b.CONDITION
  FROM ABS_BRANCHES b;
