CREATE OR REPLACE VIEW PF_R_REFERENCE_VIEWS_V AS
SELECT t.ID,
       t.CODE,
       Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => t.ML_NAME_CODE) AS NAME,
       t.VIEW_NAME,
       t.MODULE_CODE,
       t.SORT_ORDER
  FROM PF_R_REFERENCE_VIEWS t
 ORDER BY t.SORT_ORDER, t.CODE;
