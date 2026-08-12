-- MPT menyu label'lari MLL registri (CORE.MLL_LABEL_CODES).
-- MLL_CORE_API.Get_Label(module_code, message_code) shu jadvaldan qidiradi;
-- yozuv bo'lmasa yoki MODULE_CODE noto'g'ri bo'lsa menyu nomi o'rniga
-- "<CODE> ni MLL ga qushing!!!" chiqadi. Matnlar MLT_TEMPLATES da (mlt_templates.sql).
-- Qayta ishga tushirsa bo'ladi: mavjud yozuvning MODULE_CODE'ini ham to'g'rilaydi.

MERGE INTO CORE.MLL_LABEL_CODES d
USING (
  SELECT 8  AS LABEL_ID, 'MPT' AS MODULE_CODE, 'MANAGE_PRINT_TEMPLATE'     AS MESSAGE_CODE, 'MPT root menyu' AS DESCRIPTION FROM DUAL UNION ALL
  SELECT 9,  'MPT', 'MPT_MENU_SETTINGS',        'MPT sidebar - Sozlamalar'            FROM DUAL UNION ALL
  SELECT 10, 'MPT', 'MPT_MENU_PRODUCTS',        'MPT sidebar - Productlar'            FROM DUAL UNION ALL
  SELECT 11, 'MPT', 'MPT_MENU_TEMPLATE_TYPES',  'MPT sidebar - Shablon turlari'       FROM DUAL UNION ALL
  SELECT 12, 'MPT', 'MPT_MENU_MODULES',         'MPT sidebar - Modullar'              FROM DUAL UNION ALL
  SELECT 15, 'MPT', 'MPT_MENU_PRINT_SETTINGS',  'MPT sidebar - Shablon sozlamalari'   FROM DUAL UNION ALL
  SELECT 16, 'MPT', 'MPT_MENU_GLOBAL_VARIABLES','MPT sidebar - Global o''zgaruvchilar' FROM DUAL
) s
ON (d.LABEL_ID = s.LABEL_ID)
WHEN MATCHED THEN
  UPDATE SET d.MODULE_CODE = s.MODULE_CODE, d.MESSAGE_CODE = s.MESSAGE_CODE
WHEN NOT MATCHED THEN
  INSERT (LABEL_ID, MODULE_CODE, MESSAGE_CODE, DESCRIPTION)
  VALUES (s.LABEL_ID, s.MODULE_CODE, s.MESSAGE_CODE, s.DESCRIPTION);

COMMIT;
