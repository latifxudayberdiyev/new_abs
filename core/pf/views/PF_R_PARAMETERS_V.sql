CREATE OR REPLACE VIEW PF_R_PARAMETERS_V AS
SELECT t.ID,
       t.CODE,
       Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => t.ML_NAME_CODE) AS NAME,
       t.ATTRIBUTE_ID,
       a.CODE AS ATTRIBUTE_CODE,
       Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => a.ML_NAME_CODE) AS ATTRIBUTE_NAME,
       t.VALUE_TYPE,
       t.INPUT_TYPE,
       t.CHANGE_POLICY,
       t.VALUE_FUNCTION,
       t.IS_REQUIRED,
       t.DEFAULT_VALUE,
       t.SORT_ORDER
  FROM PF_R_PARAMETERS t
  JOIN PF_R_ATTRIBUTES a ON a.ID = t.ATTRIBUTE_ID
 ORDER BY a.SORT_ORDER, t.SORT_ORDER, t.CODE;
