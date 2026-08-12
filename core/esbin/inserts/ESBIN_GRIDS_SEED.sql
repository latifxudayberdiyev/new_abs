-- ESBIN "Doступы" admin oynasi (esbin_users_grid.jsp / esbin_rel_methods.jsp) uchun
-- t:dynamicGrid registratsiyasi. PF_GRIDS_SEED.sql'dagi Add_Label naqshiga mos.
DECLARE
  v_Lbl number;

  PROCEDURE Add_Label
  (
    i_Code   varchar2,
    i_Ru     varchar2,
    i_Uz_Cyr varchar2,
    i_Uz_Lat varchar2,
    i_En     varchar2,
    o_Label_Id out number
  ) IS
    v_Ml_Code number;
    v_Ml_Msg  varchar2(4000);
  BEGIN
    Mll_Dev_Api.Save_Label_With_Template_Dev(i_Message_Code        => i_Code,
                                              i_Description         => i_Code,
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
                                              i_Module_Code         => 'ESBIN',
                                              i_Field_Hint          => null,
                                              o_Code                => v_Ml_Code,
                                              o_Msg                 => v_Ml_Msg);
    if v_Ml_Code is null then
      Raise_Application_Error(-20000, 'ESBIN grid label xato (' || i_Code || '): ' || v_Ml_Msg);
    end if;

    select Label_Id into o_Label_Id from Mll_Label_Codes where Module_Code = 'ESBIN' and Message_Code = i_Code;
  END;
BEGIN
  ---------------------------------------------------------------------------
  -- GRID_ID=12: ESBIN_USERS (ESBIN_R_PARTNER_USERS_V) - "Доступы" oynasining chap paneli
  ---------------------------------------------------------------------------
  insert into Core_Grids (Grid_Id, Grid_Code, Grid_Name, View_Name, Created_On, Created_Who,
                           Page_Count, Numbering, Without_Focus, Without_Cursor, Without_Sort_Button,
                           Without_Refresh_Button, Reset_Cursor, Hide_Filter_Button, Hide_Excel_Button,
                           Enter_Direction, Filter_Clause)
  values (12, 'ESBIN_USERS', 'ESBIN foydalanuvchilari', 'ESBIN_R_PARTNER_USERS_V', sysdate, 'Bekhzod',
          20, 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'down', '1=1');

  Add_Label('LB_ESBIN_USER_ID', 'Пользователь ID', 'Фойдаланувчи ID', 'Foydalanuvchi ID', 'User ID', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Mask, Filter_Size, Filter_Show_In_Grid, Filter_Label_Id)
  values (12, 'USER_ID', 1, 'number', 'N', 'N', 'Y', 1, v_Lbl, 'center', 'N',
          'Y', '=', 'number', 10, 'Y', v_Lbl);

  Add_Label('LB_ESBIN_PARTNER_NAME', 'Партнер', 'Ҳамкор', 'Hamkor', 'Partner', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (12, 'PARTNER_NAME', 2, 'quote', 'N', 'N', 'Y', 2, v_Lbl, 'left', 'N');

  Add_Label('LB_ESBIN_USER_NAME', 'Имя', 'Исми', 'Ismi', 'Name', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (12, 'USER_NAME', 3, 'quote', 'N', 'N', 'Y', 3, v_Lbl, 'left', 'N');

  ---------------------------------------------------------------------------
  -- GRID_ID=13: ESBIN_USER_METHODS (ESBIN_R_USER_METHODS_GRID_V) - o'ng panel
  -- (checkbox ustuni GRANTED (field_order=5, is_column='N') qiymatiga qarab
  -- oldindan belgilanadi - Component_Checked_By).
  ---------------------------------------------------------------------------
  insert into Core_Grids (Grid_Id, Grid_Code, Grid_Name, View_Name, Created_On, Created_Who,
                           Page_Count, Numbering, Without_Focus, Without_Cursor, Without_Sort_Button,
                           Without_Refresh_Button, Reset_Cursor, Hide_Filter_Button, Hide_Excel_Button,
                           Enter_Direction, Filter_Clause)
  values (13, 'ESBIN_USER_METHODS', 'ESBIN foydalanuvchi methodlari', 'ESBIN_R_USER_METHODS_GRID_V', sysdate, 'Bekhzod',
          50, 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'down', '1=1');

  Add_Label('LB_ESBIN_METHOD_CODE', 'Метод', 'Метод', 'Metod', 'Method', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Component_Type, Component_Name, Component_Checked_By)
  values (13, 'METHOD_CODE', 1, 'quote', 'N', 'N', 'Y', 1, v_Lbl, 'left', 'N',
          'checkbox', 'method_codes', 'GRANTED');

  Add_Label('LB_ESBIN_METHOD_NAME', 'Наименование', 'Номи', 'Nomi', 'Name', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Size, Filter_Show_In_Grid, Filter_Label_Id)
  values (13, 'NAME', 2, 'quote', 'N', 'N', 'Y', 3, v_Lbl, 'left', 'N',
          'Y', '_like_', 30, 'Y', v_Lbl);

  Add_Label('LB_ESBIN_REQUEST_TYPE', 'Тип', 'Тури', 'Turi', 'Type', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (13, 'REQUEST_TYPE', 3, 'quote', 'N', 'N', 'Y', 4, v_Lbl, 'center', 'N');

  Add_Label('LB_ESBIN_SYNC_TYPE', 'Синхр.', 'Синхр.', 'Sinx.', 'Sync', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (13, 'SYNCHRONIZE_TYPE', 4, 'quote', 'N', 'N', 'Y', 5, v_Lbl, 'center', 'N');

  -- GRANTED - grid ustuni sifatida ko'rsatilmaydi, faqat METHOD_CODE checkbox'ining
  -- oldindan belgilanishi (Component_Checked_By) uchun ishlatiladi.
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column)
  values (13, 'GRANTED', 5, 'number', 'N', 'N', 'N');

  -- METHOD_CODE_TXT - METHOD_CODE'ning ESBIN_R_USER_METHODS_GRID_V'dagi ikkinchi
  -- (matn/filtr) ko'rinishi. CORE_GRID_FIELDS PK (Grid_Id, Field_Name) bo'lgani
  -- uchun bitta grid ichida bir xil FIELD_NAME'ni checkbox VA matn sifatida
  -- ikki marta ro'yxatdan o'tkazib bo'lmaydi - shu sabab view'da alohida ustun
  -- (bir xil qiymat, boshqa nom) sifatida chiqarilgan.
  Add_Label('LB_ESBIN_METHOD_CODE_TXT', 'Метод', 'Метод', 'Metod', 'Method', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Size, Filter_Show_In_Grid, Filter_Label_Id)
  values (13, 'METHOD_CODE_TXT', 6, 'quote', 'N', 'N', 'Y', 2, v_Lbl, 'left', 'N',
          'Y', '_like_', 20, 'Y', v_Lbl);

  Commit;
END;
/
