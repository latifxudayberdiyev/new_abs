-- Pf_Api_Products (getProductByCategory / getProductByCode - ESBIN orqali
-- tashqi tizimlarga PF mahsulotlarini faqat o'qish uchun taqdim etuvchi API)
-- uchun SM registratsiyasi. MODEL_PF_PRODUCT'ning aynan bir xil zanjiriga mos
-- (SM_R_PROCESSES -> SM_R_PROCESS_EVENTS -> SM_R_EVENTS -> SM_R_EVENT_PROCEDURES
-- -> SM_R_PROCEDURES), faqat GET (o'qish), NEW_OBJECT_STATE=NULL.
DECLARE
  PROCEDURE Register_Get_Process
  (
    i_Process_Code varchar2,
    i_Event_Code   varchar2,
    i_Procedure_Code varchar2,
    i_Procedure_Name varchar2,
    i_Description  varchar2
  ) IS
  BEGIN
    -- Relation_Key = NULL qasddan: bu processlar bitta mavjud SM_OBJECTS
    -- yozuviga bog'liq emas (Sm_Kernel.Set_Method faqat Relation_Key NOT NULL
    -- bo'lganda relation_id'ni SM_OBJECTS'da qidiradi - MODEL_PF_PRODUCT kabi
    -- "existing entity" processlar uchun to'g'ri, lekin bu ikkalasi tashqi
    -- business-key (product_code/category_code) bo'yicha o'qiydi, PF_PRODUCT.ID
    -- bilan emas - shu sabab Relation_Key=NULL, aks holda "relation_id объект
    -- не обнаружен" xatosi bilan yiqiladi).
    insert into Sm_R_Processes
      (Process_Code, Object_Code, Parent_Object_Code, State, Relation_Key, Parent_Relation_Key,
       Created_On, Created_Developer, Set_Log, New_Object_State, Process_Type,
       Before_Process_Code, After_Process_Code, Description, Is_Deal)
    values
      (i_Process_Code, 'PF_PRODUCT', 'ROOT', 'A', null, null,
       sysdate, 'PF_INTEGRATION', 'Y', null, 'GET',
       null, null, i_Description, null);

    insert into Sm_R_Events (Event_Code, State) values (i_Event_Code, 'A');

    insert into Sm_R_Process_Events (Process_Code, Event_Code, Order_By, State, Execution_Mode, Hold_Check_Procedure)
    values (i_Process_Code, i_Event_Code, 1, 'A', 'S', null);

    insert into Sm_R_Procedures (Procedure_Code, Procedure_Name, State)
    values (i_Procedure_Code, i_Procedure_Name, 'A');

    insert into Sm_R_Event_Procedures (Event_Code, Procedure_Code, Order_By, State)
    values (i_Event_Code, i_Procedure_Code, 1, 'A');
  END;
BEGIN
  Register_Get_Process(
    i_Process_Code    => 'GET_PF_PRODUCTS_BY_CATEGORY',
    i_Event_Code      => 'GET_PF_PRODUCTS_BY_CATEGORY_EVT',
    i_Procedure_Code  => 'GET_PF_PRODUCTS_BY_CATEGORY',
    i_Procedure_Name  => 'Pf_Api_Products.Get_Products_By_Category',
    i_Description     => 'Kategoriya bo''yicha mahsulotlar ro''yxati (ESBIN/tashqi API)'
  );

  Register_Get_Process(
    i_Process_Code    => 'GET_PF_PRODUCT_BY_CODE',
    i_Event_Code      => 'GET_PF_PRODUCT_BY_CODE_EVT',
    i_Procedure_Code  => 'GET_PF_PRODUCT_BY_CODE',
    i_Procedure_Name  => 'Pf_Api_Products.Get_Product_By_Code',
    i_Description     => 'Mahsulot kodi bo''yicha to''liq tavsif (ESBIN/tashqi API)'
  );

  Commit;
END;
/
