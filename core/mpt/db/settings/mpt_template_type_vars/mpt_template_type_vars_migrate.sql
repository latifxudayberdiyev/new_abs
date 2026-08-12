-- ============================================================================
-- Migratsiya: eski GROUP-darajali biriktiruv (MPT_TEMPLATE_VAR_MAPPING_DOC,
-- group_code = 'mpt_setting_<id>') -> yangi TUR-darajali biriktiruv
-- (MPT_TEMPLATE_TYPE_VARS, template_code).
--
-- group_code -> MPT_PRINT_SETTINGS.SETTING_ID -> TEMPLATE_CODE bo'yicha
-- o'zgaruvchilar shablon turiga ko'chiriladi. PLACEHOLDER ni trigger
-- [variable_code] shaklida qayta yozadi. NOT EXISTS - qayta ishga tushirsa
-- bo'ladi (dublikat qo'shmaydi).
-- ============================================================================

INSERT INTO Mpt_Template_Type_Vars (Template_Code, Variable_Code, Placeholder, Is_Active, Created_By, Created_Date)
SELECT ps.Template_Code, d.Variable_Code, '-', d.Is_Active, d.Created_By, d.Created_Date
  FROM Mpt_Template_Var_Mapping_Doc d
  JOIN Mpt_Print_Settings ps
    ON 'mpt_setting_' || ps.Setting_Id = d.Group_Code
 WHERE ps.Template_Code IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM Mpt_Template_Type_Vars t
                    WHERE t.Template_Code = ps.Template_Code
                      AND t.Variable_Code = d.Variable_Code);

COMMIT;
