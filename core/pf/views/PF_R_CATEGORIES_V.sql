CREATE OR REPLACE VIEW PF_R_CATEGORIES_V ("ID", "CODE", "NAME", "STATE", "STATE_LABEL", "ATTR_COUNT", "PRODUCT_COUNT") AS
SELECT t.ID,
       t.CODE,
       Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => t.ML_NAME_CODE) AS NAME,
       t.STATE,
       CASE t.STATE
         WHEN 'A' THEN Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => 'PF_CATEGORY_STATE_ACTIVE')
         WHEN 'P' THEN Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => 'PF_CATEGORY_STATE_PASSIVE')
       END AS STATE_LABEL,
       (select count(*) from PF_R_ATTRIBUTE_CATEGORIES a where a.CATEGORY_ID = t.ID) AS ATTR_COUNT,
       (select count(*) from PF_PRODUCTS p where p.CATEGORY_ID = t.ID) AS PRODUCT_COUNT
  FROM PF_R_CATEGORIES t;
