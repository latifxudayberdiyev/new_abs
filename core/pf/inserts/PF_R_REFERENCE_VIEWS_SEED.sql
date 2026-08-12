DECLARE
  PROCEDURE Add_Reference_View
  (
    i_Code       varchar2,
    i_View_Name  varchar2,
    i_Module_Code varchar2,
    i_Sort_Order number,
    i_Ru         varchar2,
    i_Uz_Cyr     varchar2,
    i_Uz_Lat     varchar2,
    i_En         varchar2
  ) IS
    v_Id      number;
    v_Ml_Code number;
    v_Ml_Msg  varchar2(4000);
  BEGIN
    v_Id := Pf_R_Reference_View_Sq.nextval;

    insert into Pf_R_Reference_Views (Id, Code, Ml_Name_Code, View_Name, Module_Code, Sort_Order)
    values (v_Id, i_Code, 'PF_REFERENCE_VIEW_' || i_Code, i_View_Name, i_Module_Code, i_Sort_Order);

    Mll_Dev_Api.Save_Label_With_Template_Dev(i_Message_Code        => 'PF_REFERENCE_VIEW_' || i_Code,
                                              i_Description         => 'PF_REFERENCE_VIEW nomi',
                                              i_Param_Count         => 0,
                                              i_Format_String       => Mlt_Const.c_Default_Format_String,
                                              i_Message_Mask_Lang1  => i_Ru,
                                              i_Message_Mask_Lang2  => i_Uz_Cyr,
                                              i_Message_Mask_Lang3  => i_Uz_Lat,
                                              i_Message_Mask_Lang4  => i_En,
                                              i_Message_Mask_Lang5  => null,
                                              i_Message_Mask_Lang6  => null,
                                              i_Message_Mask_Lang7  => null,
                                              i_Message_Mask_Lang8  => null,
                                              i_Message_Mask_Lang9  => null,
                                              i_Message_Mask_Lang10 => null,
                                              i_Module_Code         => 'PF',
                                              i_Field_Hint          => null,
                                              o_Code                => v_Ml_Code,
                                              o_Msg                 => v_Ml_Msg);

    if v_Ml_Code is null then
      Raise_Application_Error(-20000, 'PF_R_REFERENCE_VIEWS seed: label xato (' || i_Code || '): ' || v_Ml_Msg);
    end if;
  END;
BEGIN
  Add_Reference_View('CATEGORY', 'PF_R_CATEGORIES_V', 'PF', 1,
    'Категории продуктов', 'Ма&#1203;сулот категориялари', 'Mahsulot kategoriyalari', 'Product categories');
  Add_Reference_View('DELIVERY_TYPE', 'PF_R_PRODUCT_DELIVERY_TYPES_V', 'PF', 2,
    'Типы доставки продукта', 'Ма&#1203;сулот етказиш турлари', 'Mahsulot yetkazish turlari', 'Product delivery types');

  Commit;
END;
/
