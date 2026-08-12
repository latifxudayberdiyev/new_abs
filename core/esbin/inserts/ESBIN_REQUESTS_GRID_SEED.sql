-- ESBIN "Kirituvchi ESB" bosh oynasi (requests.jsp) uchun t:dynamicGrid registratsiyasi.
-- PF_GRIDS_SEED.sql / ESBIN_GRIDS_SEED.sql'dagi Add_Label naqshiga mos.
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
  -- GRID_ID=14: ESBIN_REQUESTS (ESBIN_REQUESTS_V) - "Kirituvchi ESB" bosh ro'yxati
  ---------------------------------------------------------------------------
  insert into Core_Grids (Grid_Id, Grid_Code, Grid_Name, View_Name, Created_On, Created_Who,
                           Page_Count, Numbering, Without_Focus, Without_Cursor, Without_Sort_Button,
                           Without_Refresh_Button, Reset_Cursor, Hide_Filter_Button, Hide_Excel_Button,
                           Enter_Direction, Filter_Clause)
  values (14, 'ESBIN_REQUESTS', 'ESBIN so''rovlari', 'ESBIN_REQUESTS_V', sysdate, 'Bekhzod',
          20, 'Y', 'N', 'N', 'N', 'N', 'N', 'N', 'N', 'down', '1=1');

  Add_Label('LB_ESBIN_REQ_ID', 'ID', 'ID', 'ID', 'ID', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (14, 'ID', 1, 'number', 'N', 'N', 'Y', 1, v_Lbl, 'center', 'N');

  Add_Label('LB_ESBIN_REQ_EXT_ID', 'Внешний ID', 'Ташқи ID', 'Tashqi ID', 'External ID', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Size, Filter_Show_In_Grid, Filter_Label_Id)
  values (14, 'EXT_REQUEST_ID', 2, 'quote', 'N', 'N', 'Y', 2, v_Lbl, 'left', 'N',
          'Y', '_like_', 20, 'Y', v_Lbl);

  -- Filter_Option_Sql "code"/"name" deb nomlangan ustunlarni qaytarishi shart -
  -- Sql_Util.Get_Grid_Definition uni o'zi '<option value="'||code||'">'||name
  -- shakliga o'raydi (tayyor HTML emas, xom code/name juftligi kutiladi).
  Add_Label('LB_ESBIN_REQ_PARTNER', 'Партнер', 'Ҳамкор', 'Hamkor', 'Partner', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Option_Sql, Filter_Show_In_Grid, Filter_Label_Id)
  values (14, 'PARTNER_CODE', 3, 'quote', 'N', 'N', 'N', null, v_Lbl, null, 'N',
          'Y', '=', q'[select PARTNER_CODE as code, NAME as name from ESBIN_R_PARTNERS_V order by NAME]', 'Y', v_Lbl);

  Add_Label('LB_ESBIN_REQ_PARTNER_NAME', 'Партнер', 'Ҳамкор', 'Hamkor', 'Partner', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (14, 'PARTNER_NAME', 4, 'quote', 'N', 'N', 'Y', 3, v_Lbl, 'left', 'N');

  Add_Label('LB_ESBIN_REQ_USER', 'Пользователь', 'Фойдаланувчи', 'Foydalanuvchi', 'User', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (14, 'USER_NAME', 5, 'quote', 'N', 'N', 'Y', 4, v_Lbl, 'left', 'N');

  Add_Label('LB_ESBIN_REQ_METHOD', 'Метод', 'Метод', 'Metod', 'Method', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Option_Sql, Filter_Show_In_Grid, Filter_Label_Id)
  values (14, 'METHOD_CODE', 6, 'quote', 'N', 'N', 'N', null, v_Lbl, null, 'N',
          'Y', '=', q'[select METHOD_CODE as code, NAME as name from ESBIN_R_METHODS_V order by NAME]', 'Y', v_Lbl);

  Add_Label('LB_ESBIN_REQ_METHOD_NAME', 'Метод', 'Метод', 'Metod', 'Method', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (14, 'METHOD_NAME', 7, 'quote', 'N', 'N', 'Y', 5, v_Lbl, 'left', 'N');

  Add_Label('LB_ESBIN_REQ_SYNC_TYPE', 'Тип', 'Тури', 'Turi', 'Type', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (14, 'SYNC_TYPE', 8, 'quote', 'N', 'N', 'Y', 6, v_Lbl, 'center', 'N');

  -- STATE_LABEL - ESBIN_REQUESTS_V computed column (Mll_Core_Api.Get_Label orqali
  -- tarjima qilingan matn: 'ESBIN_STATE_'||STATE), raqamli kod emas - filtr ham
  -- shu tarjima qilingan matn bo'yicha ishlaydi (PF_CATEGORY.STATE_LABEL naqshiga mos).
  Add_Label('LB_ESBIN_REQ_STATE', 'Статус', 'Ҳолат', 'Holat', 'State', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer,
                                Is_Filter, Filter_Operator, Filter_Option_Sql, Filter_Show_In_Grid, Filter_Label_Id)
  values (14, 'STATE_LABEL', 9, 'quote', 'N', 'N', 'Y', 7, v_Lbl, 'center', 'N',
          'Y', '=', q'[select Mll_Core_Api.Get_Label('ESBIN','ESBIN_STATE_'||x) as code, Mll_Core_Api.Get_Label('ESBIN','ESBIN_STATE_'||x) as name from (select 'RECEIVED' x from dual union all select 'QUEUED' from dual union all select 'RUNNING' from dual union all select 'SUCCESS' from dual union all select 'ERROR' from dual)]', 'Y', v_Lbl);

  Add_Label('LB_ESBIN_REQ_CREATED_ON', 'Создано', 'Яратилган', 'Yaratilgan', 'Created', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (14, 'CREATED_ON', 10, 'datetime', 'N', 'N', 'Y', 8, v_Lbl, 'left', 'N');

  Add_Label('LB_ESBIN_REQ_DURATION', 'Длительность (мс)', 'Давомийлиги (мс)', 'Davomiyligi (ms)', 'Duration (ms)', v_Lbl);
  insert into Core_Grid_Fields (Grid_Id, Field_Name, Field_Order, Field_Type, Encrypted, Is_Sum, Is_Column, Column_Order, Column_Label_Id, Column_Align, Is_Footer)
  values (14, 'DURATION_MS', 11, 'number', 'N', 'N', 'Y', 9, v_Lbl, 'right', 'N');

  Commit;
END;
/
