DECLARE
  PROCEDURE Add_State
  (
    i_Code       varchar2,
    i_Sort_Order number,
    i_Ru         varchar2,
    i_Uz_Cyr     varchar2,
    i_Uz_Lat     varchar2,
    i_En         varchar2
  ) IS
    v_Id     number;
    v_Ml_Code number;
    v_Ml_Msg  varchar2(4000);
  BEGIN
    v_Id := Pf_R_Product_State_Sq.nextval;

    insert into Pf_R_Product_States (Id, Code, Ml_Name_Code, Sort_Order)
    values (v_Id, i_Code, 'PF_PRODUCT_STATE_' || i_Code, i_Sort_Order);

    Mll_Dev_Api.Save_Label_With_Template_Dev(i_Message_Code        => 'PF_PRODUCT_STATE_' || i_Code,
                                              i_Description         => 'PF_PRODUCT_STATE nomi',
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
      Raise_Application_Error(-20000, 'PF_R_PRODUCT_STATES seed: label xato (' || i_Code || '): ' || v_Ml_Msg);
    end if;
  END;
BEGIN
  Add_State('DRAFT', 1, 'Черновик', 'Лойи&#1203;а', 'Loyiha', 'Draft');
  Add_State('ON_APPROVAL', 2, 'На согласовании', 'Келишувда', 'Kelishuvda', 'On approval');
  Add_State('ACTIVE', 3, 'Активный', 'Фаол', 'Faol', 'Active');
  Add_State('SUSPENDED', 4, 'Приостановлен', 'Т&#1118;хтатилган', 'To''xtatilgan', 'Suspended');
  Add_State('ARCHIVED', 5, 'Архив', 'Архив', 'Arxiv', 'Archived');

  Commit;
END;
/
