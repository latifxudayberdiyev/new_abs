--------------------------------------------------------------------------------
-- ACC_R_MODULES_V - Bank moduli spravochnigi view'i (JSP'lar hech qachon
-- to'g'ridan-to'g'ri ACC_R_MODULES jadvalini emas, shu view'ni chaqiradi).
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACC_R_MODULES_V AS
SELECT MODULE_CODE, MODULE_NAME FROM ACC_R_MODULES;
