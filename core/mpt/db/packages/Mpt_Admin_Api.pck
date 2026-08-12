
  CREATE OR REPLACE EDITIONABLE PACKAGE "MPT_ADMIN_API" is

  -- Author  : SHUKUROV.O
  -- Created : 17.07.2026
  -- Purpose : PECHAT v4 - "Sozlamalar" admin ekrani uchun CRUD:
  --           product (MPT_TEMPLATE_GROUPS) qo'shish/tahrirlash,
  --           workflow holatini almashtirish, o'chirish. Chop
  --           pipeline (Mpt_Print_Api) bilan aralashtirilmaydi -
  --           bu paket faqat admin ekranining o'zi uchun.

  ------------------------------------------------------------------
  -- Public function and procedure declarations
  ------------------------------------------------------------------

  -- Faqat bog'liq shablon/mapping/tarix yozuvi bo'lmasa o'chiradi.
  Procedure Delete_Product(i_Group_Code in Mpt_Template_Groups.Group_Code%type);

  -- TEMPLATE_CODE mavjud bo'lsa UPDATE, bo'lmasa INSERT qiladi.
  Procedure Save_Template_Type
  (
    i_Template_Code in Mpt_Template_Types.Template_Code%type,
    i_Template_Name in Mpt_Template_Types.Template_Name%type,
    i_Module_Code   in Mpt_Template_Types.Module_Code%type,
    i_User_Id       in Mpt_Template_Types.Created_By%type,
    i_Description   in Mpt_Template_Types.Description%type default null,
    i_Is_Active     in Mpt_Template_Types.Is_Active%type default 'Y'
  );

  -- Faqat unga bog'langan product (MPT_TEMPLATE_GROUPS.TEMPLATE_CODE) bo'lmasa o'chiradi.
  Procedure Delete_Template_Type(i_Template_Code in Mpt_Template_Types.Template_Code%type);

  -- GROUP_CODE mavjud bo'lsa UPDATE, bo'lmasa INSERT qiladi (GROUP_CODE - unique).
  -- SETTING_ID null bo'lsa yangi yozuv INSERT qiladi (Setting_Id trigger
  -- orqali avtomatik generatsiya qilinadi), berilgan bo'lsa mavjud
  -- yozuvni UPDATE qiladi. o_Setting_Id har ikkala holatda ham (yangi
  -- yaratilgan yoki mavjud) yakuniy Setting_Id qiymatini qaytaradi -
  -- chaqiruvchi shu ID orqali Save_Print_Setting_File ni chaqiradi.
  Procedure Save_Print_Setting
  (
    i_Setting_Name    in Mpt_Print_Settings.Setting_Name%type,
    i_Module_Code     in Mpt_Print_Settings.Module_Code%type,
    i_Template_Code   in Mpt_Print_Settings.Template_Code%type,
    i_File_Type       in Mpt_Print_Settings.File_Type%type,
    i_File_Format     in Mpt_Print_Settings.File_Format%type,
    i_User_Id         in Mpt_Print_Settings.Modified_By%type,
    i_Setting_Id      in Mpt_Print_Settings.Setting_Id%type default null,
    i_Activation_Date in Mpt_Print_Settings.Activation_Date%type default null,
    i_Deactivation_Date in Mpt_Print_Settings.Deactivation_Date%type default null,
    i_Description     in Mpt_Print_Settings.Description%type default null,
    i_Is_Active       in Mpt_Print_Settings.Is_Active%type default 'Y',
    i_Open_As_Pdf     in Mpt_Print_Settings.Open_As_Pdf%type default 'N',
    o_Setting_Id      out Mpt_Print_Settings.Setting_Id%type
  );

  -- Boshqa jadval FK orqali bog'lanmaydi (chop pipeline runtime'da o'qiydi) -
  -- shunchaki o'chiradi.
  Procedure Delete_Print_Setting(i_Setting_Id in Mpt_Print_Settings.Setting_Id%type);

  -- Bitta til uchun yuklangan shablon faylining file-service'dagi
  -- FILE_ID sini MPT_PRINT_SETTING_FILES ga bog'laydi. (Setting_Id,
  -- Lang_Code) juftligi mavjud bo'lsa UPDATE (fayl qayta yuklangan),
  -- bo'lmasa INSERT qiladi.
  Procedure Save_Print_Setting_File
  (
    i_Setting_Id in Mpt_Print_Setting_Files.Setting_Id%type,
    i_Lang_Code  in Mpt_Print_Setting_Files.Lang_Code%type,
    i_File_Id    in Mpt_Print_Setting_Files.File_Id%type,
    i_File_Name  in Mpt_Print_Setting_Files.File_Name%type,
    i_User_Id    in Mpt_Print_Setting_Files.Modified_By%type
  );

  -- "Global o'zgaruvchilar" ekrani uchun - VARIABLE_CODE mavjud bo'lsa
  -- UPDATE, bo'lmasa INSERT. SCOPE='GLOBAL' qat'iy (bu ekran faqat global
  -- o'zgaruvchilar uchun), MODULE_CODE esa ixtiyoriy: null bo'lsa
  -- o'zgaruvchi barcha modullar uchun amal qiladi ("Barcha modullar").
  -- MPT_PRINT_VARIABLES_T1 trigger VARIABLE_CODE/SCOPE formatini
  -- (g_ prefiksi) o'zi tekshiradi. UPDATE'da MODIFIED_BY/MODIFIED_ON
  -- yangilanadi va MPT_PRINT_VARIABLES_H'ga tarix yoziladi
  -- (Log_Variable_History, xususiy protsedura).
  Procedure Save_Variable
  (
    i_Variable_Code  in Mpt_Print_Variables.Variable_Code%type,
    i_Var_Name       in Mpt_Print_Variables.Var_Name%type,
    i_Var_Type       in Mpt_Print_Variables.Var_Type%type,
    i_Var_Source     in Mpt_Print_Variables.Var_Source%type,
    i_User_Id        in Mpt_Print_Variables.Created_By%type,
    i_Var_Value      in Mpt_Print_Variables.Var_Value%type default null,
    i_Var_Query      in Mpt_Print_Variables.Var_Query%type default null,
    i_Description    in Mpt_Print_Variables.Description%type default null,
    i_Example_Value  in Mpt_Print_Variables.Example_Value%type default null,
    i_Usage_Note     in Mpt_Print_Variables.Usage_Note%type default null,
    i_Needs_Translit in Mpt_Print_Variables.Needs_Translit%type default 'N',
    i_Is_Required    in Mpt_Print_Variables.Is_Required%type default 'N',
    i_Is_Active      in Mpt_Print_Variables.Is_Active%type default 'Y',
    i_Module_Code    in Mpt_Print_Variables.Module_Code%type default null
  );

  -- Bog'liq shablon/mapping mavjudligini tekshirmaydi - FK mavjud bo'lsa
  -- Oracle o'zi ORA-02292 bilan bloklaydi (Print_Settings kabi). O'chirishdan
  -- oldin joriy qatorni MPT_PRINT_VARIABLES_H'ga ACTION='D' bilan yozadi.
  Procedure Delete_Variable(i_Variable_Code in Mpt_Print_Variables.Variable_Code%type);

  ------------------------------------------------------------------
  -- CORE.SM_ (Process/Workflow) dvigateli uchun ulash nuqtalari.
  -- Signature CORE.SM_KERNEL talab qiladigan qat'iy shaklda (Io_Hash,
  -- o_Code, o_Msg, o_Ora_Msg) - Sm_r_Procedures.Procedure_Name shu
  -- procedurelarga to'g'ridan-to'g'ri ishora qiladi, alohida adapter
  -- paketi yo'q. Har biri yuqoridagi Save_Template_Type/Delete_Template_Type ni
  -- chaqiradi - biznes logika takrorlanmaydi.
  ------------------------------------------------------------------

  -- process_type=GET: bitta shablon turini tahrirlash formasi uchun o'qiydi.
  Procedure Model_Category_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  -- process_type=POST: CREATE_TEMPLATE_TYPE va EDIT_TEMPLATE_TYPE ikkalasi
  -- ham shu procedurega ulanadi (Save_Template_Type o'zi upsert qiladi).
  Procedure Save_Category_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  -- process_type=POST: DELETE_TEMPLATE_TYPE.
  Procedure Delete_Category_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  -- Core.Mlt_Api.Get_Model_Clob bilan bir xil imzo/xulq-atvor - lekin
  -- UAPP'da CORE.MLT_API uchun grant/synonym yo'q (foydalanuvchi CORE
  -- obyektiga grant berishni istamadi), shu sabab Sm_Kernel.Set_Method'ni
  -- shu yerdan, to'g'ridan-to'g'ri (ikkalasi ham CORE sxemasida, synonym
  -- shart emas) chaqiramiz. JSP'da execJsonRequestFunction'ga
  -- "Mpt_Admin_Api.Get_Model_Clob" nomi bilan uzatiladi.
  Function Get_Model_Clob(i_Json clob) return clob;

  -- Core.Mlt_Api.Execute_Process_Clob bilan bir xil moslashuvchan
  -- xulq-atvor (Core.Core_Api.Execute_Process_Clob'dan farqli - u faqat
  -- {"params":[...]} o'ralgan JSON qabul qiladi, yassi JSON kelsa
  -- "ma'lumot topilmadi" (ORA-01403) bilan darhol yiqiladi). UAPP'da
  -- CORE.CORE_API/MLT_API uchun grant so'ralmagan, shuning uchun bu ham
  -- shu yerda, to'g'ridan-to'g'ri Sm_Kernel.Set_Method orqali amalga
  -- oshiriladi. JSP'da execJsonRequestProcedure'ga
  -- "Mpt_Admin_Api.Execute_Process_Clob" nomi bilan uzatiladi.
  Procedure Execute_Process_Clob(i_Json clob);

  -- process_type=GET: bitta global o'zgaruvchini tahrirlash formasi uchun o'qiydi.
  Procedure Model_Variable_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  -- process_type=POST: CREATE_GLOBAL_VARIABLE va EDIT_GLOBAL_VARIABLE
  -- ikkalasi ham shu procedurega ulanadi (Save_Variable o'zi upsert qiladi).
  Procedure Save_Variable_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  -- process_type=POST: DELETE_GLOBAL_VARIABLE.
  Procedure Delete_Variable_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  -- "Shablon turi o'zgaruvchilari" ekrani uchun - checkbox grid orqali
  -- tanlangan o'zgaruvchilar to'plamini shablon turiga (TEMPLATE_CODE)
  -- to'liq sinxronlaydi (dvs_settings.jsp'dagi checkbox-array naqshi bilan
  -- bir xil): i_Variable_Codes'da bor-u hali biriktirilmagan o'zgaruvchilar
  -- INSERT qilinadi, mavjud biriktiruvda bor-u i_Variable_Codes'da yo'qlari
  -- DELETE qilinadi. Bo'sh massiv (hammasi uncheck qilingan) - shu turning
  -- barcha biriktiruvlarini o'chiradi. Modal/SM shart emas - to'g'ridan-to'g'ri
  -- chaqiriladi. PLACEHOLDER MPT_TEMPLATE_TYPE_VARS_T1 trigger orqali
  -- [variable_code] shaklida avtomatik.
  Procedure Save_Type_Vars_Bulk
  (
    i_Template_Code  in Mpt_Template_Type_Vars.Template_Code%type,
    i_Variable_Codes in Core.Array_Varchar2,
    i_User_Id        in Mpt_Template_Type_Vars.Created_By%type
  );

  -- process_type=OPERATION (SAVE_PRINT_SETTING): "Shablon sozlamalari"
  -- formasini saqlaydi. OPERATION tanlangan (POST emas) - chunki eski,
  -- SM'siz yaratilgan yozuvlarni tahrirlashda POST SM_OBJECT_NOT_FOUND
  -- beradi; OPERATION esa obyekt-tracking qilmaydi, create/edit birxil
  -- ishlaydi. Save_Print_Setting o'zi upsert qiladi (i_Setting_Id null ->
  -- yangi). So'ng har til uchun yuklangan fayl maydonlarini (file-service
  -- file_id) after_process_hash ichiga solib qo'yadi - kernel keyin
  -- SAVE_SETTING_FILES processini shu hash bilan yuritadi.
  Procedure Save_Setting_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  -- process_type=OPERATION (SAVE_SETTING_FILES): SAVE_PRINT_SETTING ning
  -- AFTER_PROCESS_CODE'i. Kernel (SM_KERNEL.Run_After_Process) buni
  -- after_process_hash bilan chaqiradi. setting_id + har til file_<field>_id/
  -- _name maydonlarini o'qib, MPT_PRINT_SETTING_FILES ga bog'laydi
  -- (Save_Print_Setting_File orqali).
  Procedure Save_Setting_Files_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

end Mpt_Admin_Api;
/
  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MPT_ADMIN_API" is

  ------------------------------------------------------------------
  -- Function and procedure implementations
  ------------------------------------------------------------------

  Procedure Delete_Product(i_Group_Code in Mpt_Template_Groups.Group_Code%type) is
    v_Ref_Count number;
  begin
    select count(*)
      into v_Ref_Count
      from dual
     where exists (select 1 from Mpt_Print_Templates where Group_Code = i_Group_Code)
        or exists (select 1 from Mpt_Template_Var_Mapping_Doc where Group_Code = i_Group_Code)
        or exists (select 1 from Mpt_Template_Cell_Mapping where Group_Code = i_Group_Code)
        or exists (select 1 from Mpt_Print_History where Group_Code = i_Group_Code);

    if v_Ref_Count > 0 then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_PRODUCT_HAS_DEPS',
        i_Params       => Core.Array_Varchar2(i_Group_Code));
      return;
    end if;

    delete from Mpt_Template_Groups where Group_Code = i_Group_Code;

    if sql%rowcount = 0 then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_PRODUCT_NOT_FOUND',
        i_Params       => Core.Array_Varchar2(i_Group_Code));
      return;
    end if;
  end Delete_Product;

  Procedure Log_Template_Type_History
  (
    i_Template_Code in Mpt_Template_Types.Template_Code%type,
    i_Action        in varchar2
  ) is
  begin
    insert into Mpt_Template_Types_H
      (Log_Id, Template_Code, Template_Name, Description, Is_Active,
       Created_By, Modified_By, Modified_On,
       Local_Code, Bxm_Name, Module_Code, Cbu_Code, Sm_Relation_Id,
       Action, Action_Date)
      select Mpt_Template_Types_H_Sq.Nextval,
             Template_Code, Template_Name, Description, Is_Active,
             Created_By, Modified_By, Modified_On,
             Local_Code, Bxm_Name, Module_Code, Cbu_Code, Sm_Relation_Id,
             i_Action, sysdate
        from Mpt_Template_Types
       where Template_Code = i_Template_Code;
  end Log_Template_Type_History;

  Procedure Save_Template_Type
  (
    i_Template_Code in Mpt_Template_Types.Template_Code%type,
    i_Template_Name in Mpt_Template_Types.Template_Name%type,
    i_Module_Code   in Mpt_Template_Types.Module_Code%type,
    i_User_Id       in Mpt_Template_Types.Created_By%type,
    i_Description   in Mpt_Template_Types.Description%type default null,
    i_Is_Active     in Mpt_Template_Types.Is_Active%type default 'Y'
  ) is
    v_Exists number;
  begin
    select count(*)
      into v_Exists
      from Mpt_Template_Types
     where Template_Code = i_Template_Code;

    if v_Exists = 0 then
      insert into Mpt_Template_Types
        (Template_Code, Template_Name, Module_Code,
         Description, Is_Active, Created_By)
      values
        (i_Template_Code, i_Template_Name, i_Module_Code,
         i_Description, i_Is_Active, i_User_Id);

      Log_Template_Type_History(i_Template_Code => i_Template_Code, i_Action => Mpt_Const.c_Log_Insert);
    else
      update Mpt_Template_Types
         set Template_Name = i_Template_Name,
             Module_Code   = i_Module_Code,
             Description   = i_Description,
             Is_Active     = i_Is_Active,
             Modified_By   = i_User_Id,
             Modified_On   = sysdate
       where Template_Code = i_Template_Code;

      Log_Template_Type_History(i_Template_Code => i_Template_Code, i_Action => Mpt_Const.c_Log_Update);
    end if;
  end Save_Template_Type;

  Procedure Delete_Template_Type(i_Template_Code in Mpt_Template_Types.Template_Code%type) is
    v_Ref_Count number;
  begin
    select count(*)
      into v_Ref_Count
      from Mpt_Template_Groups
     where Template_Code = i_Template_Code;

    if v_Ref_Count > 0 then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_TEMPLATE_TYPE_HAS_DEPS',
        i_Params       => Core.Array_Varchar2(i_Template_Code));
      return;
    end if;

    Log_Template_Type_History(i_Template_Code => i_Template_Code, i_Action => Mpt_Const.c_Log_Delete);

    delete from Mpt_Template_Types where Template_Code = i_Template_Code;

    if sql%rowcount = 0 then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_TEMPLATE_TYPE_NOT_FOUND',
        i_Params       => Core.Array_Varchar2(i_Template_Code));
      return;
    end if;
  end Delete_Template_Type;

  -- MPT_TEMPLATE_TYPES ekranidagi "Tarix" bilan bir xil naqsh -
  -- I/U/D holatidagi to'liq qatorni MPT_PRINT_SETTINGS_H'ga nusxalaydi.
  Procedure Log_Print_Setting_History
  (
    i_Setting_Id in Mpt_Print_Settings.Setting_Id%type,
    i_Action     in varchar2
  ) is
  begin
    insert into Mpt_Print_Settings_H
      (Log_Id, Setting_Id, Is_Active, Oper_Day, Modified_By, Modified_On,
       Setting_Name, Module_Code, Template_Code, File_Type, File_Format,
       Activation_Date, Description, Deactivation_Date, Open_As_Pdf,
       Action, Action_Date)
      select Mpt_Print_Settings_H_Sq.Nextval,
             Setting_Id, Is_Active, Oper_Day, Modified_By, Modified_On,
             Setting_Name, Module_Code, Template_Code, File_Type, File_Format,
             Activation_Date, Description, Deactivation_Date, Open_As_Pdf,
             i_Action, sysdate
        from Mpt_Print_Settings
       where Setting_Id = i_Setting_Id;
  end Log_Print_Setting_History;

  Procedure Save_Print_Setting
  (
    i_Setting_Name    in Mpt_Print_Settings.Setting_Name%type,
    i_Module_Code     in Mpt_Print_Settings.Module_Code%type,
    i_Template_Code   in Mpt_Print_Settings.Template_Code%type,
    i_File_Type       in Mpt_Print_Settings.File_Type%type,
    i_File_Format     in Mpt_Print_Settings.File_Format%type,
    i_User_Id         in Mpt_Print_Settings.Modified_By%type,
    i_Setting_Id      in Mpt_Print_Settings.Setting_Id%type default null,
    i_Activation_Date in Mpt_Print_Settings.Activation_Date%type default null,
    i_Deactivation_Date in Mpt_Print_Settings.Deactivation_Date%type default null,
    i_Description     in Mpt_Print_Settings.Description%type default null,
    i_Is_Active       in Mpt_Print_Settings.Is_Active%type default 'Y',
    i_Open_As_Pdf     in Mpt_Print_Settings.Open_As_Pdf%type default 'N',
    o_Setting_Id      out Mpt_Print_Settings.Setting_Id%type
  ) is
    v_Exists number := 0;
  begin
    -- i_Setting_Id berilgan bo'lsa ham yozuv mavjud bo'lmasligi mumkin
    -- (masalan SM OPERATION oldindan id bergan holat) - shuning uchun
    -- mavjudlikni tekshirib, INSERT/UPDATE qaroriga ta'sir qilamiz.
    if i_Setting_Id is not null then
      select count(*)
        into v_Exists
        from Mpt_Print_Settings
       where Setting_Id = i_Setting_Id;
    end if;

    if v_Exists = 0 then
      -- i_Setting_Id null bo'lsa trigger (MPT_PRINT_SETTINGS_S1) generatsiya
      -- qiladi; berilgan bo'lsa aynan shu ID bilan INSERT.
      insert into Mpt_Print_Settings
        (Setting_Id, Setting_Name, Module_Code, Template_Code, File_Type, File_Format,
         Activation_Date, Deactivation_Date, Description, Is_Active, Open_As_Pdf)
      values
        (i_Setting_Id, i_Setting_Name, i_Module_Code, i_Template_Code, i_File_Type, i_File_Format,
         i_Activation_Date, i_Deactivation_Date, i_Description, i_Is_Active,
         Nvl(i_Open_As_Pdf, 'N'))
      returning Setting_Id into o_Setting_Id;

      Log_Print_Setting_History(i_Setting_Id => o_Setting_Id, i_Action => Mpt_Const.c_Log_Insert);
    else
      update Mpt_Print_Settings
         set Setting_Name    = i_Setting_Name,
             Module_Code      = i_Module_Code,
             Template_Code    = i_Template_Code,
             File_Type        = i_File_Type,
             File_Format      = i_File_Format,
             Activation_Date  = i_Activation_Date,
             Deactivation_Date = i_Deactivation_Date,
             Description      = i_Description,
             Is_Active        = i_Is_Active,
             Open_As_Pdf      = Nvl(i_Open_As_Pdf, 'N'),
             Modified_By      = i_User_Id,
             Modified_On      = sysdate
       where Setting_Id = i_Setting_Id;

      if sql%rowcount = 0 then
        Core.Mle_Core_Api.Raise_Error(
          i_Module_Code  => 'MPT',
          i_Message_Code => 'MPT_PRINT_SETTING_NOT_FOUND',
          i_Params       => Core.Array_Varchar2(to_char(i_Setting_Id)));
        return;
      end if;

      o_Setting_Id := i_Setting_Id;

      Log_Print_Setting_History(i_Setting_Id => o_Setting_Id, i_Action => Mpt_Const.c_Log_Update);
    end if;
  end Save_Print_Setting;

  Procedure Delete_Print_Setting(i_Setting_Id in Mpt_Print_Settings.Setting_Id%type) is
  begin
    Log_Print_Setting_History(i_Setting_Id => i_Setting_Id, i_Action => Mpt_Const.c_Log_Delete);

    delete from Mpt_Print_Settings where Setting_Id = i_Setting_Id;

    if sql%rowcount = 0 then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_PRINT_SETTING_NOT_FOUND',
        i_Params       => Core.Array_Varchar2(to_char(i_Setting_Id)));
      return;
    end if;
  end Delete_Print_Setting;

  -- MPT_PRINT_SETTING_FILES uchun tarix - har bir shablon+til uchun
  -- biriktirilgan barcha fayllar (eski va yangi) shu yerda saqlanadi,
  -- shuning uchun keyinchalik almashtirilgan fayl ham yuklab olinishi mumkin.
  Procedure Log_Print_Setting_File_History
  (
    i_Setting_Id in Mpt_Print_Setting_Files.Setting_Id%type,
    i_Lang_Code  in Mpt_Print_Setting_Files.Lang_Code%type,
    i_Action     in varchar2
  ) is
  begin
    insert into Mpt_Print_Setting_Files_H
      (Log_Id, Setting_File_Id, Setting_Id, Lang_Code, File_Id, File_Name,
       Created_Date, Modified_By, Oper_Day, Action, Action_Date)
      select Mpt_Print_Setting_Files_H_Sq.Nextval,
             Setting_File_Id, Setting_Id, Lang_Code, File_Id, File_Name,
             Created_Date, Modified_By, Oper_Day, i_Action, sysdate
        from Mpt_Print_Setting_Files
       where Setting_Id = i_Setting_Id
         and Lang_Code   = i_Lang_Code;
  end Log_Print_Setting_File_History;

  Procedure Save_Print_Setting_File
  (
    i_Setting_Id in Mpt_Print_Setting_Files.Setting_Id%type,
    i_Lang_Code  in Mpt_Print_Setting_Files.Lang_Code%type,
    i_File_Id    in Mpt_Print_Setting_Files.File_Id%type,
    i_File_Name  in Mpt_Print_Setting_Files.File_Name%type,
    i_User_Id    in Mpt_Print_Setting_Files.Modified_By%type
  ) is
    v_Exists number;
  begin
    select count(*)
      into v_Exists
      from Mpt_Print_Setting_Files
     where Setting_Id = i_Setting_Id
       and Lang_Code   = i_Lang_Code;

    if v_Exists = 0 then
      insert into Mpt_Print_Setting_Files
        (Setting_Id, Lang_Code, File_Id, File_Name)
      values
        (i_Setting_Id, i_Lang_Code, i_File_Id, i_File_Name);

      Log_Print_Setting_File_History(i_Setting_Id => i_Setting_Id, i_Lang_Code => i_Lang_Code, i_Action => Mpt_Const.c_Log_Insert);
    else
      update Mpt_Print_Setting_Files
         set File_Id      = i_File_Id,
             File_Name    = i_File_Name,
             Modified_By  = i_User_Id,
             Oper_Day     = sysdate
       where Setting_Id = i_Setting_Id
         and Lang_Code   = i_Lang_Code;

      Log_Print_Setting_File_History(i_Setting_Id => i_Setting_Id, i_Lang_Code => i_Lang_Code, i_Action => Mpt_Const.c_Log_Update);
    end if;
  end Save_Print_Setting_File;

  -- MPT_TEMPLATE_TYPES ekranidagi "Tarix" bilan bir xil naqsh -
  -- I/U/D holatidagi to'liq qatorni MPT_PRINT_VARIABLES_H'ga nusxalaydi.
  Procedure Log_Variable_History
  (
    i_Variable_Code in Mpt_Print_Variables.Variable_Code%type,
    i_Action        in varchar2
  ) is
  begin
    insert into Mpt_Print_Variables_H
      (Log_Id, Variable_Code, Scope, Module_Code, Var_Name, Var_Type, Var_Source,
       Var_Value, Var_Query, Description, Example_Value, Usage_Note, Needs_Translit,
       Is_Required, Is_Active, Created_By, Created_Date, Sm_Relation_Id,
       Modified_By, Modified_On, Action, Action_Date)
      select Mpt_Print_Variables_H_Sq.Nextval,
             Variable_Code, Scope, Module_Code, Var_Name, Var_Type, Var_Source,
             Var_Value, Var_Query, Description, Example_Value, Usage_Note, Needs_Translit,
             Is_Required, Is_Active, Created_By, Created_Date, Sm_Relation_Id,
             Modified_By, Modified_On, i_Action, sysdate
        from Mpt_Print_Variables
       where Variable_Code = i_Variable_Code;
  end Log_Variable_History;

  Procedure Save_Variable
  (
    i_Variable_Code  in Mpt_Print_Variables.Variable_Code%type,
    i_Var_Name       in Mpt_Print_Variables.Var_Name%type,
    i_Var_Type       in Mpt_Print_Variables.Var_Type%type,
    i_Var_Source     in Mpt_Print_Variables.Var_Source%type,
    i_User_Id        in Mpt_Print_Variables.Created_By%type,
    i_Var_Value      in Mpt_Print_Variables.Var_Value%type default null,
    i_Var_Query      in Mpt_Print_Variables.Var_Query%type default null,
    i_Description    in Mpt_Print_Variables.Description%type default null,
    i_Example_Value  in Mpt_Print_Variables.Example_Value%type default null,
    i_Usage_Note     in Mpt_Print_Variables.Usage_Note%type default null,
    i_Needs_Translit in Mpt_Print_Variables.Needs_Translit%type default 'N',
    i_Is_Required    in Mpt_Print_Variables.Is_Required%type default 'N',
    i_Is_Active      in Mpt_Print_Variables.Is_Active%type default 'Y',
    i_Module_Code    in Mpt_Print_Variables.Module_Code%type default null
  ) is
    v_Exists number;
  begin
    select count(*)
      into v_Exists
      from Mpt_Print_Variables
     where Variable_Code = i_Variable_Code;

    if v_Exists = 0 then
      insert into Mpt_Print_Variables
        (Variable_Code, Scope, Module_Code, Var_Name, Var_Type, Var_Source, Var_Value,
         Var_Query, Description, Example_Value, Usage_Note, Needs_Translit, Is_Required,
         Is_Active, Created_By)
      values
        (i_Variable_Code, 'GLOBAL', i_Module_Code, i_Var_Name, i_Var_Type, i_Var_Source, i_Var_Value,
         i_Var_Query, i_Description, i_Example_Value, i_Usage_Note, i_Needs_Translit, i_Is_Required,
         i_Is_Active, i_User_Id);

      Log_Variable_History(i_Variable_Code => i_Variable_Code, i_Action => Mpt_Const.c_Log_Insert);
    else
      update Mpt_Print_Variables
         set Var_Name       = i_Var_Name,
             Module_Code     = i_Module_Code,
             Var_Type        = i_Var_Type,
             Var_Source      = i_Var_Source,
             Var_Value       = i_Var_Value,
             Var_Query       = i_Var_Query,
             Description     = i_Description,
             Example_Value   = i_Example_Value,
             Usage_Note      = i_Usage_Note,
             Needs_Translit  = i_Needs_Translit,
             Is_Required     = i_Is_Required,
             Is_Active       = i_Is_Active,
             Modified_By     = i_User_Id,
             Modified_On     = sysdate
       where Variable_Code = i_Variable_Code;

      Log_Variable_History(i_Variable_Code => i_Variable_Code, i_Action => Mpt_Const.c_Log_Update);
    end if;
  end Save_Variable;

  Procedure Delete_Variable(i_Variable_Code in Mpt_Print_Variables.Variable_Code%type) is
  begin
    Log_Variable_History(i_Variable_Code => i_Variable_Code, i_Action => Mpt_Const.c_Log_Delete);

    delete from Mpt_Print_Variables where Variable_Code = i_Variable_Code;

    if sql%rowcount = 0 then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_VARIABLE_NOT_FOUND',
        i_Params       => Core.Array_Varchar2(i_Variable_Code));
      return;
    end if;
  end Delete_Variable;

  ------------------------------------------------------------------
  -- CORE.SM_ ulash nuqtalari
  ------------------------------------------------------------------

  Procedure Model_Category_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Row    Mpt_Template_Types%rowtype;
    v_Data   Core.Hash_t := Core.Hash_t();
    v_Rel_Id number;
  begin
    o_Code   := 0;
    v_Rel_Id := Io_Hash.Get_Optional_Number('sm_relation_id');

    if v_Rel_Id is not null then
      select *
        into v_Row
        from Mpt_Template_Types
       where Sm_Relation_Id = v_Rel_Id;
    else
      -- SM_RELATION_ID hali berilmagan (masalan backfill'dan oldingi) qator -
      -- TEMPLATE_CODE bo'yicha zaxira qidiruv.
      select *
        into v_Row
        from Mpt_Template_Types
       where Template_Code = Io_Hash.Get_Varchar2('template_code');
    end if;

    v_Data.Put('template_code', v_Row.Template_Code);
    v_Data.Put('template_name', v_Row.Template_Name);
    v_Data.Put('module_code', v_Row.Module_Code);
    v_Data.Put('description', v_Row.Description);
    v_Data.Put('is_active', v_Row.Is_Active);
    v_Data.Put('sm_relation_id', v_Row.Sm_Relation_Id);

    Io_Hash.Put('data', v_Data);
  exception
    when no_data_found then
      o_Code    := -20030;
      o_Msg     := 'Shablon turi topilmadi (sm_relation_id).';
      o_Ora_Msg := o_Msg;
    when others then
      o_Code    := -1;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Model_Category_Sm;

  Procedure Save_Category_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Template_Code Mpt_Template_Types.Template_Code%type;
    v_Sm_Cache       Core.Hash_t;
    v_Rel_Id         number;
    v_Is_Edit        number;
    v_Exists         number;
  begin
    o_Code          := 0;
    v_Template_Code := Io_Hash.Get_Varchar2('template_code');
    v_Is_Edit       := Io_Hash.Get_Optional_Number('sm_relation_id');

    -- Yangi qo'shishda (v_Is_Edit null - hali SM_RELATION_ID yo'q) kod band
    -- bo'lsa jim UPDATE qilib yubormaymiz - aniq xatolik qaytaramiz
    -- (MLE orqali ro'yxatdan o'tgan: MPT_TEMPLATE_TYPE_EXISTS).
    if v_Is_Edit is null then
      select count(*)
        into v_Exists
        from Mpt_Template_Types
       where Template_Code = v_Template_Code;

      if v_Exists > 0 then
        Core.Mle_Core_Api.Raise_Error(
          i_Module_Code  => 'MPT',
          i_Message_Code => 'MPT_TEMPLATE_TYPE_EXISTS',
          i_Params       => Core.Array_Varchar2(v_Template_Code));
        return;
      end if;
    end if;

    Save_Template_Type(i_Template_Code => v_Template_Code,
                   i_Template_Name => Io_Hash.Get_Varchar2('template_name'),
                   i_Module_Code   => Io_Hash.Get_Varchar2('module_code'),
                   i_User_Id       => Nvl(Io_Hash.Get_Optional_Number('user_id'),
                                          Sm_Util.Get_Session_User_Id),
                   i_Description   => Io_Hash.Get_Optional_Varchar2('description'),
                   i_Is_Active     => Nvl(Io_Hash.Get_Optional_Varchar2('is_active'), 'Y'));

    -- SM tomonidan yangi obyekt uchun generatsiya qilingan raqam
    -- Io_Hash.sm_cache.sm_relation_id ichida keladi (Sm_Kernel.Set_Cache) -
    -- birinchi marta SM orqali saqlanayotgan qatorga shu raqamni yozib
    -- qo'yamiz (mavjud, oldindan SM'siz yaratilgan qatorlar uchun ham ishlaydi).
    if Io_Hash.Has('sm_cache') then
      v_Sm_Cache := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Rel_Id   := v_Sm_Cache.Get_Optional_Number('sm_relation_id');
      if v_Rel_Id is not null then
        update Mpt_Template_Types
           set Sm_Relation_Id = v_Rel_Id
         where Template_Code = v_Template_Code
           and Sm_Relation_Id is null;
      end if;
    end if;
  exception
    when others then
      o_Code    := -1;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Save_Category_Sm;

  Function Get_Model_Clob(i_Json clob) return clob is
    v_Hash       Core.Hash_t := Core.Hash_t();
    v_Params     Core.Arraylist;
    v_Param_Hash Core.Hash_t;
    v_Data       Core.Hash_t := Core.Hash_t();
    v_Code       number;
    v_Msg        varchar2(3000);
    v_Ora_Msg    varchar2(3000);
  begin
    v_Hash   := Json_Parser.Parse_Json(i_Json);
    v_Params := v_Hash.Get_Optional_Arraylist('params');
    --
    if v_Params is not null then
      for i in 1 .. v_Params.count loop
        v_Param_Hash := Treat(v_Params.Get_r_Hash_t(i) as Core.Hash_t);
        --
        if v_Param_Hash.Has('model_process_code') then
          v_Param_Hash.Put('process_code',
                           v_Param_Hash.Get_Varchar2('model_process_code'));
        end if;
        --
        v_Param_Hash.Put('data', v_Data);
        Sm_Kernel.Set_Method(v_Param_Hash, v_Code, v_Msg, v_Ora_Msg);
        --
        if v_Code != Sm_Const.c_Success_Code then
          Raise_Application_Error(-20000, v_Msg);
        end if;
        --
        v_Data := v_Param_Hash.Get_Optional_Hash_t('data');
      end loop;
    else
      if v_Hash.Has('model_process_code') then
        v_Hash.Put('process_code', v_Hash.Get_Varchar2('model_process_code'));
      end if;
      --
      v_Hash.Put('data', v_Data);
      Sm_Kernel.Set_Method(v_Hash, v_Code, v_Msg, v_Ora_Msg);
      --
      if v_Code != Sm_Const.c_Success_Code then
        Raise_Application_Error(-20000, v_Msg);
      end if;
      --
      v_Data := v_Hash.Get_Optional_Hash_t('data');
    end if;
    --
    return v_Data.Json_Clob;
  end Get_Model_Clob;

  Procedure Delete_Category_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    o_Code := 0;
    Delete_Template_Type(Io_Hash.Get_Varchar2('template_code'));
  exception
    when others then
      o_Code    := -1;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Delete_Category_Sm;

  Procedure Execute_Process_Clob(i_Json clob) is
    v_Hash     Core.Hash_t;
    v_Response clob;
    v_Code     number;
    v_Msg      varchar2(3000);
    v_Ora_Msg  varchar2(3000);
  begin
    v_Hash := Json_Parser.Parse_Json(i_Json);
    --
    if v_Hash.Has('params') then
      Sm_Kernel.Set_Method(i_Json, v_Response, v_Code, v_Msg, v_Ora_Msg);
    else
      -- yassi JSON: hash-variant orqali to'g'ridan-to'g'ri
      Sm_Kernel.Set_Method(v_Hash, v_Code, v_Msg, v_Ora_Msg);
    end if;
    --
    if v_Code != Sm_Const.c_Success_Code then
      Raise_Application_Error(-20000, v_Msg);
    end if;
  end Execute_Process_Clob;

  Procedure Model_Variable_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Row    Mpt_Print_Variables%rowtype;
    v_Data   Core.Hash_t := Core.Hash_t();
    v_Rel_Id number;
  begin
    o_Code   := 0;
    v_Rel_Id := Io_Hash.Get_Optional_Number('sm_relation_id');

    if v_Rel_Id is not null then
      select *
        into v_Row
        from Mpt_Print_Variables
       where Sm_Relation_Id = v_Rel_Id;
    else
      -- SM_RELATION_ID hali berilmagan qator - VARIABLE_CODE bo'yicha
      -- zaxira qidiruv.
      select *
        into v_Row
        from Mpt_Print_Variables
       where Variable_Code = Io_Hash.Get_Varchar2('variable_code');
    end if;

    v_Data.Put('variable_code', v_Row.Variable_Code);
    v_Data.Put('var_name', v_Row.Var_Name);
    v_Data.Put('module_code', v_Row.Module_Code);
    v_Data.Put('var_type', v_Row.Var_Type);
    v_Data.Put('var_source', v_Row.Var_Source);
    v_Data.Put('var_value', v_Row.Var_Value);
    v_Data.Put('var_query', v_Row.Var_Query);
    v_Data.Put('description', v_Row.Description);
    v_Data.Put('example_value', v_Row.Example_Value);
    v_Data.Put('usage_note', v_Row.Usage_Note);
    v_Data.Put('needs_translit', v_Row.Needs_Translit);
    v_Data.Put('is_required', v_Row.Is_Required);
    v_Data.Put('is_active', v_Row.Is_Active);
    v_Data.Put('sm_relation_id', v_Row.Sm_Relation_Id);

    Io_Hash.Put('data', v_Data);
  exception
    when no_data_found then
      o_Code    := -20031;
      o_Msg     := 'O''zgaruvchi topilmadi (sm_relation_id).';
      o_Ora_Msg := o_Msg;
    when others then
      o_Code    := -1;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Model_Variable_Sm;

  Procedure Save_Variable_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Variable_Code Mpt_Print_Variables.Variable_Code%type;
    v_Sm_Cache      Core.Hash_t;
    v_Rel_Id        number;
  begin
    o_Code          := 0;
    v_Variable_Code := Io_Hash.Get_Varchar2('variable_code');

    Save_Variable(i_Variable_Code  => v_Variable_Code,
                  i_Var_Name       => Io_Hash.Get_Varchar2('var_name'),
                  i_Var_Type       => Io_Hash.Get_Varchar2('var_type'),
                  i_Var_Source     => Io_Hash.Get_Varchar2('var_source'),
                  i_User_Id        => Nvl(Io_Hash.Get_Optional_Number('user_id'),
                                          Sm_Util.Get_Session_User_Id),
                  i_Var_Value      => Io_Hash.Get_Optional_Varchar2('var_value'),
                  i_Var_Query      => Io_Hash.Get_Optional_Varchar2('var_query'),
                  i_Description    => Io_Hash.Get_Optional_Varchar2('description'),
                  i_Example_Value  => Io_Hash.Get_Optional_Varchar2('example_value'),
                  i_Usage_Note     => Io_Hash.Get_Optional_Varchar2('usage_note'),
                  i_Needs_Translit => Nvl(Io_Hash.Get_Optional_Varchar2('needs_translit'), 'N'),
                  i_Is_Required    => Nvl(Io_Hash.Get_Optional_Varchar2('is_required'), 'N'),
                  i_Is_Active      => Nvl(Io_Hash.Get_Optional_Varchar2('is_active'), 'Y'),
                  -- bo'sh tanlov = "Barcha modullar" (Module_Code null)
                  i_Module_Code    => Io_Hash.Get_Optional_Varchar2('module_code'));

    -- CREATE'da SM tomonidan generatsiya qilingan raqamni qatorga yozish
    -- (Save_Category_Sm bilan bir xil naqsh).
    if Io_Hash.Has('sm_cache') then
      v_Sm_Cache := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Rel_Id   := v_Sm_Cache.Get_Optional_Number('sm_relation_id');
      if v_Rel_Id is not null then
        update Mpt_Print_Variables
           set Sm_Relation_Id = v_Rel_Id
         where Variable_Code = v_Variable_Code
           and Sm_Relation_Id is null;
      end if;
    end if;
  exception
    when others then
      o_Code    := -1;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Save_Variable_Sm;

  Procedure Delete_Variable_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    o_Code := 0;
    Delete_Variable(Io_Hash.Get_Varchar2('variable_code'));
  exception
    when others then
      o_Code    := -1;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Delete_Variable_Sm;

  ------------------------------------------------------------------
  -- Shablon turi <-> o'zgaruvchi biriktirish (Type Vars) - checkbox-array
  ------------------------------------------------------------------
  Procedure Save_Type_Vars_Bulk
  (
    i_Template_Code  in Mpt_Template_Type_Vars.Template_Code%type,
    i_Variable_Codes in Core.Array_Varchar2,
    i_User_Id        in Mpt_Template_Type_Vars.Created_By%type
  ) is
    v_Codes Core.Array_Varchar2 := Nvl(i_Variable_Codes, Core.Array_Varchar2());
  begin
    -- checkbox belgilangan-u hali yo'q bo'lganlarni qo'shish. Placeholder
    -- trigger orqali [variable_code].
    insert into Mpt_Template_Type_Vars (Template_Code, Variable_Code, Placeholder, Is_Active, Created_By)
    select i_Template_Code, t.column_value, '-', 'Y', i_User_Id
      from table(v_Codes) t
     where t.column_value not in (select Variable_Code
                                     from Mpt_Template_Type_Vars
                                    where Template_Code = i_Template_Code);

    -- checkbox belgisi olib tashlangan (yoki hech qachon bo'lmagan)
    -- mavjud biriktiruvlarni o'chirish. v_Codes bo'sh bo'lsa - shu
    -- turning barcha biriktiruvlari o'chadi (hammasi uncheck qilingan).
    delete from Mpt_Template_Type_Vars
     where Template_Code = i_Template_Code
       and Variable_Code not in (select t.column_value from table(v_Codes) t);
  end Save_Type_Vars_Bulk;

  Procedure Save_Setting_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_User_Id    number;
    v_Setting_Id Mpt_Print_Settings.Setting_Id%type;
    v_New_Id     Mpt_Print_Settings.Setting_Id%type;
    v_After      Core.Hash_t   := Core.Hash_t();
    v_Params     Core.Arraylist := Core.Arraylist();
    v_File_Hash  Core.Hash_t   := Core.Hash_t();
  begin
    o_Code       := 0;
    v_User_Id    := Nvl(Io_Hash.Get_Optional_Number('user_id'), Sm_Util.Get_Session_User_Id);
    -- create'da setting_id yo'q (Save_Print_Setting trigger orqali generatsiya
    -- qiladi va o_Setting_Id qaytaradi); edit'da formadan keladi.
    v_Setting_Id := Io_Hash.Get_Optional_Number('setting_id');

    Save_Print_Setting(
      i_Setting_Name      => Io_Hash.Get_Varchar2('setting_name'),
      i_Module_Code       => Io_Hash.Get_Varchar2('module_code'),
      i_Template_Code     => Io_Hash.Get_Varchar2('template_code'),
      i_File_Type         => Io_Hash.Get_Varchar2('file_type'),
      i_File_Format       => Io_Hash.Get_Varchar2('file_format'),
      i_User_Id           => v_User_Id,
      i_Setting_Id        => v_Setting_Id,
      i_Activation_Date   => To_Date(Io_Hash.Get_Optional_Varchar2('activation_date'), 'dd.mm.yyyy'),
      i_Deactivation_Date => To_Date(Io_Hash.Get_Optional_Varchar2('deactivation_date'), 'dd.mm.yyyy'),
      i_Description       => Io_Hash.Get_Optional_Varchar2('description'),
      i_Is_Active         => Nvl(Io_Hash.Get_Optional_Varchar2('is_active'), 'Y'),
      i_Open_As_Pdf       => Nvl(Io_Hash.Get_Optional_Varchar2('open_as_pdf'), 'N'),
      o_Setting_Id        => v_New_Id);

    -- after_process_hash quramiz: kernel buni SAVE_SETTING_FILES processi
    -- sifatida yuritadi. params[] ichida bitta hash - process_code + saqlash
    -- uchun kerakli maydonlar (setting_id, har til file_<field>_id/_name).
    v_File_Hash.Put('process_code', 'SAVE_SETTING_FILES');
    v_File_Hash.Put('setting_id', v_New_Id);
    v_File_Hash.Put('user_id', v_User_Id);
    for r in (select File_Field_Name from Mpt_Languages_V where Is_Active = 'Y') loop
      v_File_Hash.Put(r.File_Field_Name || '_id',
                      Io_Hash.Get_Optional_Varchar2(r.File_Field_Name || '_id'));
      v_File_Hash.Put(r.File_Field_Name || '_name',
                      Io_Hash.Get_Optional_Varchar2(r.File_Field_Name || '_name'));
    end loop;
    v_Params.Push(v_File_Hash);
    v_After.Put('params', v_Params);
    Io_Hash.Put('after_process_hash', v_After);
  exception
    when others then
      o_Code    := -1;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Save_Setting_Sm;

  Procedure Save_Setting_Files_Sm
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Setting_Id number;
    v_User_Id    number;
    v_File_Id    Mpt_Print_Setting_Files.File_Id%type;
    v_File_Name  Mpt_Print_Setting_Files.File_Name%type;
  begin
    o_Code       := 0;
    v_Setting_Id := Io_Hash.Get_Number('setting_id');
    v_User_Id    := Nvl(Io_Hash.Get_Optional_Number('user_id'), Sm_Util.Get_Session_User_Id);

    for r in (select File_Field_Name, Lang_Code
                from Mpt_Languages_V
               where Is_Active = 'Y') loop
      v_File_Id := Io_Hash.Get_Optional_Varchar2(r.File_Field_Name || '_id');
      -- fayl shu til uchun yuklanган bo'lsagina bog'laymiz; aks holda
      -- avvalgi biriktiruv tegilmay qoladi.
      if v_File_Id is not null then
        v_File_Name := Io_Hash.Get_Optional_Varchar2(r.File_Field_Name || '_name');
        Save_Print_Setting_File(
          i_Setting_Id => v_Setting_Id,
          i_Lang_Code  => r.Lang_Code,
          i_File_Id    => v_File_Id,
          i_File_Name  => v_File_Name,
          i_User_Id    => v_User_Id);
      end if;
    end loop;
  exception
    when others then
      o_Code    := -1;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Save_Setting_Files_Sm;

end Mpt_Admin_Api;
/
