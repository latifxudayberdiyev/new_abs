--------------------------------------------------------------------------------
-- ACC_R_CLASS_CATALOG_V - "Типы счетов — справочник" (illyustrativ referens
-- ro'yxati), har bir sinf uchun unga tegishli modullar ro'yxatini ham qo'shib
-- ko'rsatadi.
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
CREATE OR REPLACE VIEW ACC_R_CLASS_CATALOG_V AS
SELECT g.CATALOG_ID,
       g.CLASS_CODE,
       g.RANGE_FROM || ' - ' || g.RANGE_TO                    AS RANGE_DISP,
       g.CATALOG_NAME,
       g.CATALOG_DESC,
       (SELECT LISTAGG(gm.MODULE_CODE, ', ') WITHIN GROUP (ORDER BY gm.MODULE_CODE)
          FROM ACC_R_CLASS_CATALOG_MODULES gm
         WHERE gm.CATALOG_ID = g.CATALOG_ID)                  AS MODULES_LIST
  FROM ACC_R_CLASS_CATALOG g
 ORDER BY g.CLASS_CODE, g.RANGE_FROM;
