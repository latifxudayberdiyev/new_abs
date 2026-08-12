-- Kategoriyalar va Parametrlar ro'yxat ekranlari uchun t:dynamicGrid registratsiyasi.
-- mlt/labels.jsp'dagi grid_id=5 namunasiga mos (CORE_GRIDS + CORE_GRID_FIELDS + ustun label'lari).
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
                                              i_Module_Code         => 'PF',
                                              i_Field_Hint          => null,
                                              o_Code                => v_Ml_Code,
                                              o_Msg                 => v_Ml_Msg);
    if v_Ml_Code is null then
      Raise_Application_Error(-20000, 'PF grid label xato (' || i_Code || '): ' || v_Ml_Msg);
    end if;

    select Label_Id into o_Label_Id from Mll_Label_Codes where Module_Code = 'PF' and Message_Code = i_Code;
  END;
BEGIN
  ---------------------------------------------------------------------------
  -- GRID_ID=6: PF_CATEGORY (PF_R_CATEGORIES_V)
  ---------------------------------------------------------------------------
  -- PF_R_CATEGORIES_V.STATE_LABEL bu ikkita label'ni ishlatadi (A/P kodini emas,
  -- tarjima qilingan matnni ko'rsatish uchun).
  Add_Label('PF_CATEGORY_STATE_ACTIVE', 'Активный', 'Фаол', 'Faol', 'Active', v_Lbl);
  Add_Label('PF_CATEGORY_STATE_PASSIVE', 'Пассивный', 'Пассив', 'Passiv', 'Passive', v_Lbl);

  insert into Core_Grids (Grid_Id, Grid_Code, Grid_Name, View_Name, Created_On, Created_Who,
                           Page_Count, Numbering, Without_Focus, Without_Cursor, Without_Sort_Button,
                           Without_Refresh_Button, Reset_Cursor, Hide_Filter_Button, Hide_Excel_Button,
                           Enter_Direction, Filter_Clause)
  values (6, 'PF_CATEGORY', 'Kategoriyalar', 'PF_R_CATEGORIES_V', sysdate, 'Bekhzod',
          20, 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'down', '1=1');

  Add_Label('LB_PF_CAT_ID', 'ID', 'ID', 'ID', 'ID', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (6, 'ID', 1, 'number', 'N', 'N', 'Y', 1, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_CAT_CODE', 'Код', 'Код', 'Kod', 'Code', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (6, 'CODE', 2, 'quote', 'N', 'N', 'Y', 2, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_CAT_NAME', 'Наименование', 'Номи', 'Nomi', 'Name', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (6, 'NAME', 3, 'quote', 'N', 'N', 'Y', 3, v_Lbl, 'center', 'N');

  -- STATE_LABEL (PF_R_CATEGORIES_V computed column) - ko'rsatiladigan matn ("Faol"/"Passiv"),
  -- raqamli A/P kod emas. Filter dropdown-style ('=' + FILTER_OPTION_SQL) - bu o'zi
  -- "filterControls is not found" xatosining sababi EMAS edi; haqiqiy sabab
  -- FILTER_SHOW_IN_GRID='Y' bo'lgani edi (pastdagi izohga qarang) - shu ustun
  -- qoldirilmagani uchun dropdown filter xavfsiz.
  Add_Label('LB_PF_CAT_STATE', 'Статус', 'Холати', 'Holati', 'Status', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Option_Sql)
  values (6, 'STATE_LABEL', 4, 'quote', 'N', 'N', 'Y', 4, v_Lbl, 'center', 'N',
          'Y', '=', q'[select '<option value=''' || Mll_Core_Api.Get_Label(i_Module_Code=>'PF', i_Message_Code=>'PF_CATEGORY_STATE_ACTIVE') || '''>' || Mll_Core_Api.Get_Label(i_Module_Code=>'PF', i_Message_Code=>'PF_CATEGORY_STATE_ACTIVE') || '</option><option value=''' || Mll_Core_Api.Get_Label(i_Module_Code=>'PF', i_Message_Code=>'PF_CATEGORY_STATE_PASSIVE') || '''>' || Mll_Core_Api.Get_Label(i_Module_Code=>'PF', i_Message_Code=>'PF_CATEGORY_STATE_PASSIVE') || '</option>' from dual]');

  Add_Label('LB_PF_CAT_ATTR_COUNT', 'Атрибутов', 'Атрибутлар', 'Atributlar', 'Attributes', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (6, 'ATTR_COUNT', 5, 'number', 'N', 'N', 'Y', 5, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_CAT_PRODUCT_COUNT', 'Продуктов', 'Ма&#1203;сулотлар', 'Mahsulotlar', 'Products', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (6, 'PRODUCT_COUNT', 6, 'number', 'N', 'N', 'Y', 6, v_Lbl, 'center', 'N');

  ---------------------------------------------------------------------------
  -- GRID_ID=7: PF_PARAMETER (PF_R_PARAMETERS_V)
  ---------------------------------------------------------------------------
  insert into Core_Grids (Grid_Id, Grid_Code, Grid_Name, View_Name, Created_On, Created_Who,
                           Page_Count, Numbering, Without_Focus, Without_Cursor, Without_Sort_Button,
                           Without_Refresh_Button, Reset_Cursor, Hide_Filter_Button, Hide_Excel_Button,
                           Enter_Direction, Filter_Clause)
  values (7, 'PF_PARAMETER', 'Parametrlar', 'PF_R_PARAMETERS_V', sysdate, 'Bekhzod',
          20, 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'Y', 'down', '1=1');

  Add_Label('LB_PF_PARAM_ID', 'ID', 'ID', 'ID', 'ID', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'ID', 1, 'number', 'N', 'N', 'Y', 1, v_Lbl, 'center', 'N');

  -- CODE/NAME - modal Filter oynasida _like_ qidiruv, INLINE emas (faqat
  -- ATTRIBUTE_ID grid ustida chiqadi - 2026-08-06 aniq ko'rsatma).
  Add_Label('LB_PF_PARAM_CODE', 'Код', 'Код', 'Kod', 'Code', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Size, Filter_Label_Id)
  values (7, 'CODE', 2, 'quote', 'N', 'N', 'Y', 2, v_Lbl, 'center', 'N',
          'Y', '_like_', 30, v_Lbl);

  Add_Label('LB_PF_PARAM_NAME', 'Наименование', 'Номи', 'Nomi', 'Name', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Size, Filter_Label_Id)
  values (7, 'NAME', 3, 'quote', 'N', 'N', 'Y', 3, v_Lbl, 'center', 'N',
          'Y', '_like_', 30, v_Lbl);

  -- ATTRIBUTE_ID - inline (FILTER_SHOW_IN_GRID) dropdown filtr, grid ustidagi
  -- alohida select sifatida chiqadi. Filtr yorlig'i ustun sarlavhasidan
  -- ATAYLAB boshqa ("Atribut", "Atribut ID" emas) - dropdown qiymatlari
  -- atribut NOMLARI (ID emas), "Atribut ID: NewAtt" chalkash edi.
  -- (2026-08-06: birinchi urinishda FILTER_LABEL_ID bo'sh qoldirilgani uchun
  -- butun select bo'sh/ishlamaydigan bo'lib chiqqan edi - label to'g'rilangach
  -- ishladi, shu sabab bu ikkalasi ajralmas juft.)
  -- FIELD_TYPE='quote' (raqamli ustun bo'lsa ham) ATAYLAB - Sql_Util
  -- 'number' turdagi filtrlarga qo'shimcha OPERATOR selektorini ("равно" va
  -- h.k.) ham chiqaradi, 2 ta alohida quti hosil qilib chalkashtiradi;
  -- 'quote' + tayyor option ro'yxati bitta toza select beradi.
  Add_Label('LB_PF_PARAM_ATTR_ID', 'ID атрибута', 'Атрибут ID', 'Atribut ID', 'Attribute ID', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Show_In_Grid, Filter_Option_Sql)
  values (7, 'ATTRIBUTE_ID', 4, 'quote', 'N', 'N', 'Y', 4, v_Lbl, 'center', 'N',
          'Y', '=', 'Y', q'[select ID as code, NAME as name from PF_R_ATTRIBUTES_V order by NAME]');

  Add_Label('LB_PF_PARAM_ATTR_FILTER', 'Атрибут', 'Атрибут', 'Atribut', 'Attribute', v_Lbl);
  update Core_Grid_Fields set Filter_Label_Id = v_Lbl where Grid_Id = 7 and Field_Order = 4;

  Add_Label('LB_PF_PARAM_ATTR_CODE', 'Код атрибута', 'Атрибут коди', 'Atribut kodi', 'Attribute code', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'ATTRIBUTE_CODE', 5, 'quote', 'N', 'N', 'Y', 5, v_Lbl, 'center', 'N');

  -- Filter: '_like_' - PF_R_ATTRIBUTES_V grid_id=8'dagi ishlab turgan naqshga mos (yuqoridagi
  -- STATE ustuni izohiga qarang).
  Add_Label('LB_PF_PARAM_ATTR_NAME', 'Атрибут', 'Атрибут', 'Atribut', 'Attribute', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator)
  values (7, 'ATTRIBUTE_NAME', 6, 'quote', 'N', 'N', 'Y', 6, v_Lbl, 'center', 'N',
          'Y', '_like_');

  Add_Label('LB_PF_PARAM_VALUE_TYPE', 'Тип значения', '&#1178;иймат тури', 'Qiymat turi', 'Value type', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'VALUE_TYPE', 7, 'quote', 'N', 'N', 'Y', 7, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_PARAM_INPUT_TYPE', 'Тип ввода', 'Киритиш тури', 'Kiritish turi', 'Input type', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'INPUT_TYPE', 8, 'quote', 'N', 'N', 'Y', 8, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_PARAM_CHANGE_POLICY', 'Политика изменения', '&#1038;згариш сиёсати', 'O''zgarish siyosati', 'Change policy', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'CHANGE_POLICY', 9, 'quote', 'N', 'N', 'Y', 9, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_PARAM_VALUE_FUNCTION', 'Функция', 'Функция', 'Funksiya', 'Function', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'VALUE_FUNCTION', 10, 'quote', 'N', 'N', 'Y', 10, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_PARAM_IS_REQUIRED', 'Обязательный', 'Мажбурий', 'Majburiy', 'Required', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'IS_REQUIRED', 11, 'number', 'N', 'N', 'Y', 11, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_PARAM_DEFAULT_VALUE', 'Значение по умолчанию', 'Стандарт &#1179;иймат', 'Standart qiymat', 'Default value', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'DEFAULT_VALUE', 12, 'quote', 'N', 'N', 'Y', 12, v_Lbl, 'center', 'N');

  Add_Label('LB_PF_PARAM_SORT_ORDER', 'Порядок', 'Тартиб', 'Tartib', 'Sort order', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (7, 'SORT_ORDER', 13, 'number', 'N', 'N', 'Y', 13, v_Lbl, 'center', 'N');

  Commit;
END;
/
