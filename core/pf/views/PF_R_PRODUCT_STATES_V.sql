CREATE OR REPLACE VIEW PF_R_PRODUCT_STATES_V AS
SELECT t.ID,
       t.CODE,
       Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => t.ML_NAME_CODE) AS NAME,
       t.SORT_ORDER
  FROM PF_R_PRODUCT_STATES t
 ORDER BY t.SORT_ORDER;
