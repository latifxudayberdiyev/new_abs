-- ESBIN_REQUESTS_V.STATE_LABEL (tarjima qilingan holat matni) uchun MLL labellar.
-- PF_R_CATEGORIES_V.STATE_LABEL naqshiga mos (Mll_Core_Api.Get_Label orqali).
DECLARE
  v_Ml_Code number;
  v_Ml_Msg  varchar2(4000);

  PROCEDURE Add_Label(i_Code varchar2, i_Ru varchar2, i_Uz_Cyr varchar2, i_Uz_Lat varchar2, i_En varchar2) IS
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
      Raise_Application_Error(-20000, 'ESBIN state label xato (' || i_Code || '): ' || v_Ml_Msg);
    end if;
  END;
BEGIN
  Add_Label('ESBIN_STATE_RECEIVED', 'Получено', 'Қабул қилинди', 'Qabul qilindi', 'Received');
  Add_Label('ESBIN_STATE_QUEUED', 'В очереди', 'Навбатда', 'Navbatda', 'Queued');
  Add_Label('ESBIN_STATE_RUNNING', 'Выполняется', 'Бажарилмоқда', 'Bajarilmoqda', 'Running');
  Add_Label('ESBIN_STATE_SUCCESS', 'Успешно', 'Муваффақиятли', 'Muvaffaqiyatli', 'Success');
  Add_Label('ESBIN_STATE_ERROR', 'Ошибка', 'Хато', 'Xato', 'Error');
  Commit;
END;
/
