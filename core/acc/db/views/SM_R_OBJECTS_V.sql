--------------------------------------------------------------------------------
-- SM_R_OBJECTS_V - ish-jarayon (workflow) obyekt kodlari spravochnigi (faqat
-- o'qish uchun). account_type.jsp dagi "Код связанного объекта" (object_code)
-- select-box'i shu view orqali to'ldiriladi - JSP hech qachon SM_R_OBJECTS
-- jadvaliga to'g'ridan-to'g'ri murojaat qilmasligi kerak.
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW SM_R_OBJECTS_V AS
SELECT o.OBJECT_CODE, o.PARENT_OBJECT_CODE, o.STATE
  FROM SM_R_OBJECTS o
 WHERE o.STATE = 'A'
 ORDER BY o.OBJECT_CODE;
