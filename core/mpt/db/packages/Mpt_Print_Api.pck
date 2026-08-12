
  CREATE OR REPLACE EDITIONABLE PACKAGE "MPT_PRINT_API" is

  -- Author  : SHUKUROV.O
  -- Created : 13.07.2026
  -- Purpose : PECHAT v4 - shablon/o'zgaruvchi/QR ro'yxatga olish,
  --           o'zgaruvchi qiymatini hal qilish (til, translit,
  --           AMOUNT_IN_WORDS), transliteratsiya (UZL->UZC),
  --           chop tarixi va admin_qrcode_N avtomatik yaratish.

  ------------------------------------------------------------------
  -- Public function and procedure declarations
  ------------------------------------------------------------------

  -- Registratsiya protseduralari

  Procedure Register_Template_Group
  (
    i_Group_Code     in Mpt_Template_Groups.Group_Code%type,
    i_Group_Name     in Mpt_Template_Groups.Group_Name%type,
    i_Module_Code    in Mpt_Template_Groups.Module_Code%type,
    i_Retention_Days in Mpt_Template_Groups.History_Retention_Days%type,
    i_Created_By     in Mpt_Template_Groups.Created_By%type,
    i_Description    in Mpt_Template_Groups.Description%type default null
  );

  Procedure Register_Template
  (
    i_Template_Code    in Mpt_Print_Templates.Template_Code%type,
    i_Group_Code       in Mpt_Print_Templates.Group_Code%type,
    i_Lang_Code        in Mpt_Print_Templates.Lang_Code%type,
    i_File_Id          in Mpt_Print_Templates.File_Id%type,
    i_File_Format      in Mpt_Print_Templates.File_Format%type,
    i_Placeholder_Type in Mpt_Print_Templates.Placeholder_Type%type,
    i_Created_By       in Mpt_Print_Templates.Created_By%type,
    i_Version          in Mpt_Print_Templates.Version%type default 1
  );

  Procedure Register_Doc_Mapping
  (
    i_Group_Code    in Mpt_Template_Var_Mapping_Doc.Group_Code%type,
    i_Variable_Code in Mpt_Template_Var_Mapping_Doc.Variable_Code%type,
    i_Placeholder   in Mpt_Template_Var_Mapping_Doc.Placeholder%type,
    i_Created_By    in Mpt_Template_Var_Mapping_Doc.Created_By%type
  );

  Procedure Register_Cell_Mapping
  (
    i_Group_Code        in Mpt_Template_Cell_Mapping.Group_Code%type,
    i_Variable_Code     in Mpt_Template_Cell_Mapping.Variable_Code%type,
    i_Cell_Address      in Mpt_Template_Cell_Mapping.Cell_Address%type,
    i_Created_By        in Mpt_Template_Cell_Mapping.Created_By%type,
    i_Sheet_Name        in Mpt_Template_Cell_Mapping.Sheet_Name%type default 'Sheet1',
    i_Is_Dynamic_Row    in Mpt_Template_Cell_Mapping.Is_Dynamic_Row%type default 'N',
    i_Dynamic_Row_Param in Mpt_Template_Cell_Mapping.Dynamic_Row_Param%type default null,
    i_Is_Range          in Mpt_Template_Cell_Mapping.Is_Range%type default 'N',
    i_Is_Merged         in Mpt_Template_Cell_Mapping.Is_Merged%type default 'N',
    i_Is_Table_Start    in Mpt_Template_Cell_Mapping.Is_Table_Start%type default 'N'
  );

  Procedure Register_Qr_Code
  (
    i_Variable_Code    in Mpt_Print_Qr_Codes.Variable_Code%type,
    i_Group_Code       in Mpt_Print_Qr_Codes.Group_Code%type,
    i_Qr_Name          in Mpt_Print_Qr_Codes.Qr_Name%type,
    i_Content_Template in Mpt_Print_Qr_Codes.Qr_Content_Template%type,
    i_Position         in Mpt_Print_Qr_Codes.Qr_Position%type,
    i_Created_By       in Mpt_Print_Qr_Codes.Created_By%type,
    i_Qr_Size_Mm       in Mpt_Print_Qr_Codes.Qr_Size_Mm%type default 30,
    i_Cell_Address     in Mpt_Print_Qr_Codes.Cell_Address%type default null,
    i_Is_Every_Page    in Mpt_Print_Qr_Codes.Is_Every_Page%type default 'N',
    i_Error_Correction in Mpt_Print_Qr_Codes.Error_Correction%type default 'M'
  );

  -- Admin "YANGI QR" tugmasi bosilganda: keyingi admin_qrcode_N ni
  -- avtomatik topib, PRINT_VARIABLES + PRINT_QR_CODES'ga insert qiladi.
  Procedure Add_Qr_Code_Auto
  (
    i_Group_Code    in Mpt_Print_Qr_Codes.Group_Code%type,
    i_Created_By    in Mpt_Print_Variables.Created_By%type,
    i_Scope         in Mpt_Print_Variables.Scope%type default 'MODULE',
    i_Module_Code   in Mpt_Print_Variables.Module_Code%type default null,
    o_Variable_Code out Mpt_Print_Variables.Variable_Code%type
  );

  Procedure Add_Global_Variable
  (
    i_Code          in Mpt_Print_Variables.Variable_Code%type,
    i_Name          in Mpt_Print_Variables.Var_Name%type,
    i_Type          in Mpt_Print_Variables.Var_Type%type,
    i_Source        in Mpt_Print_Variables.Var_Source%type,
    i_Created_By    in Mpt_Print_Variables.Created_By%type,
    i_Value         in Mpt_Print_Variables.Var_Value%type default null,
    i_Query         in Mpt_Print_Variables.Var_Query%type default null,
    i_Description   in Mpt_Print_Variables.Description%type default null,
    i_Example_Value in Mpt_Print_Variables.Example_Value%type default null
  );

  Procedure Add_Module_Variable
  (
    i_Module_Code    in Mpt_Print_Variables.Module_Code%type,
    i_Code           in Mpt_Print_Variables.Variable_Code%type,
    i_Name           in Mpt_Print_Variables.Var_Name%type,
    i_Type           in Mpt_Print_Variables.Var_Type%type,
    i_Source         in Mpt_Print_Variables.Var_Source%type,
    i_Created_By     in Mpt_Print_Variables.Created_By%type,
    i_Value          in Mpt_Print_Variables.Var_Value%type default null,
    i_Query          in Mpt_Print_Variables.Var_Query%type default null,
    i_Description    in Mpt_Print_Variables.Description%type default null,
    i_Example_Value  in Mpt_Print_Variables.Example_Value%type default null,
    i_Needs_Translit in Mpt_Print_Variables.Needs_Translit%type default 'N'
  );

  Procedure Save_Print_History
  (
    i_Group_Code    in Mpt_Print_History.Group_Code%type,
    i_Template_Code in Mpt_Print_History.Template_Code%type,
    i_Module_Code   in Mpt_Print_History.Module_Code%type,
    i_Lang_Code     in Mpt_Print_History.Lang_Code%type,
    i_Printed_By    in Mpt_Print_History.Printed_By%type,
    i_Output_Format in Mpt_Print_History.Output_Format%type,
    i_Status        in Mpt_Print_History.Status%type,
    i_Record_Id     in Mpt_Print_History.Record_Id%type default null,
    i_Input_Params  in Mpt_Print_History.Input_Params%type default null,
    i_File_Id       in Mpt_Print_History.File_Id%type default null,
    i_Vars_Snapshot in Mpt_Print_History.Vars_Snapshot%type default null,
    i_Qr_Contents   in Mpt_Print_History.Qr_Contents%type default null,
    i_Error_Message in Mpt_Print_History.Error_Message%type default null
  );

  -- TEMPLATE_GROUPS.HISTORY_RETENTION_DAYS bo'yicha eskirgan
  -- PRINT_HISTORY yozuvlarini tozalaydi (nechta o'chirilgani
  -- DBMS_OUTPUT'ga yoziladi).
  Procedure Purge_Old_History;

  -- Eski PRINT_HISTORY yozuvining VARS_SNAPSHOT/QR_CONTENTS va
  -- boshqa maydonlarini ko'chirib, STATUS='REPRINTED' bilan yangi
  -- tarix yozuvi yaratadi (qayta chop etish, qiymatlarni qayta
  -- hisoblamasdan).
  Procedure Reprint
  (
    i_History_Id in Mpt_Print_History.History_Id%type,
    i_Printed_By in Mpt_Print_History.Printed_By%type
  );

  -- VARIABLE_CODE formatini tekshiradi (P2.5), noto'g'ri bo'lsa
  -- RAISE_APPLICATION_ERROR. MPT_PRINT_VARIABLES trigger'i shu
  -- protsedurani chaqiradi.
  Procedure Validate_Variable_Code
  (
    i_Variable_Code in Mpt_Print_Variables.Variable_Code%type,
    i_Scope         in Mpt_Print_Variables.Scope%type
  );

  -- Yadrodan (core) hodimning standart tilini oladi.
  Function Get_User_Lang(i_User_Id in number) return varchar2;

  -- Yadro tillar ro'yxatini (CORE_R_LANGUAGES / MLT_LANGUAGES) qaytaradi.
  Function Get_Languages return sys_refcursor;

  Function Get_Template_By_Group_Lang
  (
    i_Group_Code in Mpt_Print_Templates.Group_Code%type,
    i_Lang_Code  in Mpt_Print_Templates.Lang_Code%type
  ) return Mpt_Print_Templates%rowtype;

  -- Bitta o'zgaruvchining qiymatini hal qiladi (til, translit,
  -- AMOUNT_IN_WORDS hisobga olingan holda). i_user_id lang_code
  -- NULL bo'lganda get_user_lang() uchun va DYNAMIC so'rovlardagi
  -- :USER_ID bind uchun ishlatiladi.
  Function Resolve_Var_Value
  (
    i_Variable_Code in Mpt_Print_Variables.Variable_Code%type,
    i_Record_Id     in varchar2 default null,
    i_Lang_Code     in varchar2 default null,
    i_User_Id       in number default null,
    i_Params        in clob default null
  ) return varchar2;

  -- Guruhdagi barcha o'zgaruvchilarni hal qilib, JSON (CLOB)
  -- ko'rinishida qaytaradi.
  Function Get_All_Resolved_Vars
  (
    i_Group_Code in Mpt_Template_Groups.Group_Code%type,
    i_Record_Id  in varchar2 default null,
    i_Lang_Code  in varchar2 default null,
    i_User_Id    in number default null,
    i_Params     in clob default null
  ) return clob;

  Function Build_Qr_Content
  (
    i_Qr_Id     in Mpt_Print_Qr_Codes.Qr_Id%type,
    i_Vars_Json in clob
  ) return varchar2;

  -- Lotin (UZL) matnni kirill (UZC) alifbosiga o'giradi.
  Function Latin_To_Cyrillic(i_Text in varchar2) return varchar2;

  -- GROUP_CODE bo'yicha keyingi bo'sh admin_qrcode_N kodini qaytaradi
  -- (jadvalga insert qilmaydi - faqat hisoblaydi).
  Function Get_Next_Qr_Code(i_Group_Code in Mpt_Print_Qr_Codes.Group_Code%type) return varchar2;

end Mpt_Print_Api;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "MPT_PRINT_API" is

  -- E'TIBOR - tasdiqlash talab qilinadigan taxminlar:
  --   1. get_user_lang ichida CORE_R_UTIL.get_user_lang(i_user_id) va
  --      resolve_var_value ichida CORE_R_UTIL.amount_to_words(...)
  --      chaqirilmoqda - bu "yadro" (core) funksiyalarining ANIQ nomi
  --      va imzosi ushbu loyihada hali tasdiqlanmagan. Real muhitda
  --      ANIQ nom bilan almashtirilishi shart, aks holda PLS-00201
  --      xatosi bilan compile bo'lmaydi.
  --   2. get_languages MLT_LANGUAGES jadvalidan to'g'ridan-to'g'ri
  --      o'qiydi (bu jadval MPT_PRINT_TEMPLATES.LANG_CODE FK maqsadi
  --      sifatida allaqachon tasdiqlangan).

  ------------------------------------------------------------------
  -- Function and procedure implementations
  ------------------------------------------------------------------

  Procedure Register_Template_Group
  (
    i_Group_Code     in Mpt_Template_Groups.Group_Code%type,
    i_Group_Name     in Mpt_Template_Groups.Group_Name%type,
    i_Module_Code    in Mpt_Template_Groups.Module_Code%type,
    i_Retention_Days in Mpt_Template_Groups.History_Retention_Days%type,
    i_Created_By     in Mpt_Template_Groups.Created_By%type,
    i_Description    in Mpt_Template_Groups.Description%type default null
  ) is
  begin
    insert into Mpt_Template_Groups
      (Group_Code, Group_Name, Module_Code, History_Retention_Days, Description, Created_By)
    values
      (i_Group_Code, i_Group_Name, i_Module_Code, i_Retention_Days, i_Description, i_Created_By);
  end Register_Template_Group;

  Procedure Register_Template
  (
    i_Template_Code    in Mpt_Print_Templates.Template_Code%type,
    i_Group_Code       in Mpt_Print_Templates.Group_Code%type,
    i_Lang_Code        in Mpt_Print_Templates.Lang_Code%type,
    i_File_Id          in Mpt_Print_Templates.File_Id%type,
    i_File_Format      in Mpt_Print_Templates.File_Format%type,
    i_Placeholder_Type in Mpt_Print_Templates.Placeholder_Type%type,
    i_Created_By       in Mpt_Print_Templates.Created_By%type,
    i_Version          in Mpt_Print_Templates.Version%type default 1
  ) is
  begin
    insert into Mpt_Print_Templates
      (Template_Code,
       Group_Code,
       Lang_Code,
       File_Id,
       File_Format,
       Placeholder_Type,
       Version,
       Created_By)
    values
      (i_Template_Code,
       i_Group_Code,
       i_Lang_Code,
       i_File_Id,
       i_File_Format,
       i_Placeholder_Type,
       i_Version,
       i_Created_By);
  end Register_Template;

  Procedure Register_Doc_Mapping
  (
    i_Group_Code    in Mpt_Template_Var_Mapping_Doc.Group_Code%type,
    i_Variable_Code in Mpt_Template_Var_Mapping_Doc.Variable_Code%type,
    i_Placeholder   in Mpt_Template_Var_Mapping_Doc.Placeholder%type,
    i_Created_By    in Mpt_Template_Var_Mapping_Doc.Created_By%type
  ) is
  begin
    insert into Mpt_Template_Var_Mapping_Doc
      (Group_Code, Variable_Code, Placeholder, Created_By)
    values
      (i_Group_Code, i_Variable_Code, i_Placeholder, i_Created_By);
  end Register_Doc_Mapping;

  Procedure Register_Cell_Mapping
  (
    i_Group_Code        in Mpt_Template_Cell_Mapping.Group_Code%type,
    i_Variable_Code     in Mpt_Template_Cell_Mapping.Variable_Code%type,
    i_Cell_Address      in Mpt_Template_Cell_Mapping.Cell_Address%type,
    i_Created_By        in Mpt_Template_Cell_Mapping.Created_By%type,
    i_Sheet_Name        in Mpt_Template_Cell_Mapping.Sheet_Name%type default 'Sheet1',
    i_Is_Dynamic_Row    in Mpt_Template_Cell_Mapping.Is_Dynamic_Row%type default 'N',
    i_Dynamic_Row_Param in Mpt_Template_Cell_Mapping.Dynamic_Row_Param%type default null,
    i_Is_Range          in Mpt_Template_Cell_Mapping.Is_Range%type default 'N',
    i_Is_Merged         in Mpt_Template_Cell_Mapping.Is_Merged%type default 'N',
    i_Is_Table_Start    in Mpt_Template_Cell_Mapping.Is_Table_Start%type default 'N'
  ) is
  begin
    insert into Mpt_Template_Cell_Mapping
      (Group_Code,
       Variable_Code,
       Sheet_Name,
       Cell_Address,
       Is_Dynamic_Row,
       Dynamic_Row_Param,
       Is_Range,
       Is_Merged,
       Is_Table_Start,
       Created_By)
    values
      (i_Group_Code,
       i_Variable_Code,
       i_Sheet_Name,
       i_Cell_Address,
       i_Is_Dynamic_Row,
       i_Dynamic_Row_Param,
       i_Is_Range,
       i_Is_Merged,
       i_Is_Table_Start,
       i_Created_By);
  end Register_Cell_Mapping;

  Procedure Register_Qr_Code
  (
    i_Variable_Code    in Mpt_Print_Qr_Codes.Variable_Code%type,
    i_Group_Code       in Mpt_Print_Qr_Codes.Group_Code%type,
    i_Qr_Name          in Mpt_Print_Qr_Codes.Qr_Name%type,
    i_Content_Template in Mpt_Print_Qr_Codes.Qr_Content_Template%type,
    i_Position         in Mpt_Print_Qr_Codes.Qr_Position%type,
    i_Created_By       in Mpt_Print_Qr_Codes.Created_By%type,
    i_Qr_Size_Mm       in Mpt_Print_Qr_Codes.Qr_Size_Mm%type default 30,
    i_Cell_Address     in Mpt_Print_Qr_Codes.Cell_Address%type default null,
    i_Is_Every_Page    in Mpt_Print_Qr_Codes.Is_Every_Page%type default 'N',
    i_Error_Correction in Mpt_Print_Qr_Codes.Error_Correction%type default 'M'
  ) is
  begin
    insert into Mpt_Print_Qr_Codes
      (Variable_Code,
       Group_Code,
       Qr_Name,
       Qr_Size_Mm,
       Qr_Content_Template,
       Qr_Position,
       Cell_Address,
       Is_Every_Page,
       Error_Correction,
       Created_By)
    values
      (i_Variable_Code,
       i_Group_Code,
       i_Qr_Name,
       i_Qr_Size_Mm,
       i_Content_Template,
       i_Position,
       i_Cell_Address,
       i_Is_Every_Page,
       i_Error_Correction,
       i_Created_By);
  end Register_Qr_Code;

  Procedure Add_Global_Variable
  (
    i_Code          in Mpt_Print_Variables.Variable_Code%type,
    i_Name          in Mpt_Print_Variables.Var_Name%type,
    i_Type          in Mpt_Print_Variables.Var_Type%type,
    i_Source        in Mpt_Print_Variables.Var_Source%type,
    i_Created_By    in Mpt_Print_Variables.Created_By%type,
    i_Value         in Mpt_Print_Variables.Var_Value%type default null,
    i_Query         in Mpt_Print_Variables.Var_Query%type default null,
    i_Description   in Mpt_Print_Variables.Description%type default null,
    i_Example_Value in Mpt_Print_Variables.Example_Value%type default null
  ) is
  begin
    Validate_Variable_Code(i_Code, 'GLOBAL');

    insert into Mpt_Print_Variables
      (Variable_Code,
       Scope,
       Var_Name,
       Var_Type,
       Var_Source,
       Var_Value,
       Var_Query,
       Description,
       Example_Value,
       Created_By)
    values
      (i_Code,
       'GLOBAL',
       i_Name,
       i_Type,
       i_Source,
       i_Value,
       i_Query,
       i_Description,
       i_Example_Value,
       i_Created_By);
  end Add_Global_Variable;

  Procedure Add_Module_Variable
  (
    i_Module_Code    in Mpt_Print_Variables.Module_Code%type,
    i_Code           in Mpt_Print_Variables.Variable_Code%type,
    i_Name           in Mpt_Print_Variables.Var_Name%type,
    i_Type           in Mpt_Print_Variables.Var_Type%type,
    i_Source         in Mpt_Print_Variables.Var_Source%type,
    i_Created_By     in Mpt_Print_Variables.Created_By%type,
    i_Value          in Mpt_Print_Variables.Var_Value%type default null,
    i_Query          in Mpt_Print_Variables.Var_Query%type default null,
    i_Description    in Mpt_Print_Variables.Description%type default null,
    i_Example_Value  in Mpt_Print_Variables.Example_Value%type default null,
    i_Needs_Translit in Mpt_Print_Variables.Needs_Translit%type default 'N'
  ) is
  begin
    Validate_Variable_Code(i_Code, 'MODULE');

    insert into Mpt_Print_Variables
      (Variable_Code,
       Scope,
       Module_Code,
       Var_Name,
       Var_Type,
       Var_Source,
       Var_Value,
       Var_Query,
       Description,
       Example_Value,
       Needs_Translit,
       Created_By)
    values
      (i_Code,
       'MODULE',
       i_Module_Code,
       i_Name,
       i_Type,
       i_Source,
       i_Value,
       i_Query,
       i_Description,
       i_Example_Value,
       i_Needs_Translit,
       i_Created_By);
  end Add_Module_Variable;

  Procedure Save_Print_History
  (
    i_Group_Code    in Mpt_Print_History.Group_Code%type,
    i_Template_Code in Mpt_Print_History.Template_Code%type,
    i_Module_Code   in Mpt_Print_History.Module_Code%type,
    i_Lang_Code     in Mpt_Print_History.Lang_Code%type,
    i_Printed_By    in Mpt_Print_History.Printed_By%type,
    i_Output_Format in Mpt_Print_History.Output_Format%type,
    i_Status        in Mpt_Print_History.Status%type,
    i_Record_Id     in Mpt_Print_History.Record_Id%type default null,
    i_Input_Params  in Mpt_Print_History.Input_Params%type default null,
    i_File_Id       in Mpt_Print_History.File_Id%type default null,
    i_Vars_Snapshot in Mpt_Print_History.Vars_Snapshot%type default null,
    i_Qr_Contents   in Mpt_Print_History.Qr_Contents%type default null,
    i_Error_Message in Mpt_Print_History.Error_Message%type default null
  ) is
  begin
    insert into Mpt_Print_History
      (Group_Code,
       Template_Code,
       Module_Code,
       Lang_Code,
       Printed_By,
       Output_Format,
       Status,
       Record_Id,
       Input_Params,
       File_Id,
       Vars_Snapshot,
       Qr_Contents,
       Error_Message)
    values
      (i_Group_Code,
       i_Template_Code,
       i_Module_Code,
       i_Lang_Code,
       i_Printed_By,
       i_Output_Format,
       i_Status,
       i_Record_Id,
       i_Input_Params,
       i_File_Id,
       i_Vars_Snapshot,
       i_Qr_Contents,
       i_Error_Message);
  end Save_Print_History;

  Procedure Purge_Old_History is
  begin
    delete from Mpt_Print_History h
     where h.Print_Date < sysdate - (select g.History_Retention_Days
                                       from Mpt_Template_Groups g
                                      where g.Group_Code = h.Group_Code);

    -- Log: nechta record o'chirilgani (DBMS_SCHEDULER job orqali
    -- ishga tushirilganda bu chiqish job_run_details.OUTPUT'ga
    -- yoziladi; qo'lda ishga tushirilganda SET SERVEROUTPUT ON
    -- bilan ekranda ko'rinadi). Arxivga ko'chirish P2.7 spec'ida
    -- "optional" deb belgilangan - hozircha kiritilmagan (alohida
    -- ARCHIVE jadvali kerak bo'lardi).
    Dbms_Output.Put_Line('purge_old_history: ' || sql%rowcount || ' ta yozuv o''chirildi (' ||
                         to_char(sysdate, 'YYYY-MM-DD HH24:MI:SS') || ')');
  end Purge_Old_History;

  -- P2.7: eski tarix asosida qayta chop etish yozuvi
  Procedure Reprint
  (
    i_History_Id in Mpt_Print_History.History_Id%type,
    i_Printed_By in Mpt_Print_History.Printed_By%type
  ) is
    v_Old Mpt_Print_History%rowtype;
  begin
    select *
      into v_Old
      from Mpt_Print_History
     where History_Id = i_History_Id;

    insert into Mpt_Print_History
      (Group_Code,
       Template_Code,
       Module_Code,
       Lang_Code,
       Printed_By,
       Output_Format,
       Status,
       Record_Id,
       Input_Params,
       File_Id,
       Vars_Snapshot,
       Qr_Contents)
    values
      (v_Old.Group_Code,
       v_Old.Template_Code,
       v_Old.Module_Code,
       v_Old.Lang_Code,
       i_Printed_By,
       v_Old.Output_Format,
       'REPRINTED',
       v_Old.Record_Id,
       v_Old.Input_Params,
       v_Old.File_Id,
       v_Old.Vars_Snapshot,
       v_Old.Qr_Contents);
  exception
    when No_Data_Found then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_HISTORY_NOT_FOUND',
        i_Params       => Core.Array_Varchar2(to_char(i_History_Id)));
      return;
  end Reprint;

  -- P2.5: VARIABLE_CODE validatsiyasi
  Procedure Validate_Variable_Code
  (
    i_Variable_Code in Mpt_Print_Variables.Variable_Code%type,
    i_Scope         in Mpt_Print_Variables.Scope%type
  ) is
  begin
    if i_Variable_Code is null or Length(i_Variable_Code) > 100 then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_VARCODE_LEN',
        i_Params       => Core.Array_Varchar2(i_Variable_Code));
      return;
    end if;

    if not Regexp_Like(i_Variable_Code, '^[a-z][a-z0-9_]*$') then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_VARCODE_FORMAT',
        i_Params       => Core.Array_Varchar2(i_Variable_Code));
      return;
    end if;

    if i_Scope = 'GLOBAL' and i_Variable_Code not like 'g\_%' escape '\' then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_VARCODE_GLOBAL_PFX',
        i_Params       => Core.Array_Varchar2(i_Variable_Code));
      return;
    end if;

    if i_Scope = 'MODULE' and i_Variable_Code like 'g\_%' escape '\' then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_VARCODE_MODULE_PFX',
        i_Params       => Core.Array_Varchar2(i_Variable_Code));
      return;
    end if;
  end Validate_Variable_Code;

  Function Get_User_Lang(i_User_Id in number) return varchar2 is
    v_Lang varchar2(5);
  begin
    v_Lang := core.user_env.get_user_id; -- TODO: aniq core funksiya nomini tasdiqlang
    return v_Lang;
  exception
    when others then
      return 'UZL';
  end Get_User_Lang;

  Function Get_Languages return sys_refcursor is
    v_Cursor sys_refcursor;
  begin
    open v_Cursor for
      select *
        from Mlt_Languages;
    return v_Cursor;
  end Get_Languages;

  Function Get_Template_By_Group_Lang
  (
    i_Group_Code in Mpt_Print_Templates.Group_Code%type,
    i_Lang_Code  in Mpt_Print_Templates.Lang_Code%type
  ) return Mpt_Print_Templates%rowtype is
    v_Row Mpt_Print_Templates%rowtype;
  begin
    select *
      into v_Row
      from Mpt_Print_Templates
     where Group_Code = i_Group_Code
       and Lang_Code = i_Lang_Code
       and Is_Active = 'Y'
     order by Version desc
     fetch first 1 row only;

    return v_Row;
  exception
    when No_Data_Found then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_TEMPLATE_NOT_FOUND',
        i_Params       => Core.Array_Varchar2(i_Group_Code, i_Lang_Code));
      return v_Row;
  end Get_Template_By_Group_Lang;

  -- P2.2: lotin -> kirill transliteratsiya. Qoidalar MPT_TRANSLIT_RULE
  -- jadvalidan o'qiladi (hardcoded emas) - yangi qoida yoki istisno
  -- qo'shish uchun kod o'zgartirish shart emas, faqat jadvalga INSERT
  -- kifoya. SORT_ORDER ustuni digraflar (sh/ch/yo/ya/yu/ts/o'/g')
  -- bitta harfli qoidalardan OLDIN qo'llanishini kafolatlaydi.
  Function Latin_To_Cyrillic(i_Text in varchar2) return varchar2 is
    v_Text varchar2(4000) := i_Text;
  begin
    if v_Text is null then
      return null;
    end if;

    for r in (
      select Latin_Src, Cyril_Tgt, Case_Mode
      from Mpt_Translit_Rule
      where Is_Active = 'Y'
      order by Sort_Order, Rule_Id
    ) loop
      if r.Case_Mode = 'D' then
        -- 3 registr avtomatik hosil qilinadi: 'SH'/'Sh'/'sh'
        v_Text := replace(v_Text, upper(r.Latin_Src), upper(r.Cyril_Tgt));
        v_Text := replace(v_Text, initcap(r.Latin_Src), upper(r.Cyril_Tgt));
        v_Text := replace(v_Text, r.Latin_Src, r.Cyril_Tgt);
      else
        -- CASE_MODE='A' - aynan qanday yozilgan bo'lsa shunday qo'llanadi
        v_Text := replace(v_Text, r.Latin_Src, r.Cyril_Tgt);
      end if;
    end loop;

    return v_Text;
  end Latin_To_Cyrillic;

  Function Get_Next_Qr_Code(i_Group_Code in Mpt_Print_Qr_Codes.Group_Code%type) return varchar2 is
    v_Max_Num number;
  begin
    -- Eng katta mavjud admin_qrcode_N ni SONLI qiymat sifatida
    -- topamiz (matn bo'yicha ORDER BY DESC ishlatilmaydi - masalan
    -- 'admin_qrcode_10' 'admin_qrcode_2' dan alifbo bo'yicha oldin
    -- keladi va noto'g'ri natija berardi).
    select nvl(max(to_number(Regexp_Substr(Variable_Code, '[0-9]+$'))), 0)
      into v_Max_Num
      from Mpt_Print_Variables
     where Variable_Code like 'admin\_qrcode\_%' escape '\'
       and Var_Type = 'QR';

    return 'admin_qrcode_' ||(v_Max_Num + 1);
  end Get_Next_Qr_Code;

  -- P2.4: admin_qrcode_N avtomatik yaratish
  Procedure Add_Qr_Code_Auto
  (
    i_Group_Code    in Mpt_Print_Qr_Codes.Group_Code%type,
    i_Created_By    in Mpt_Print_Variables.Created_By%type,
    i_Scope         in Mpt_Print_Variables.Scope%type default 'MODULE',
    i_Module_Code   in Mpt_Print_Variables.Module_Code%type default null,
    o_Variable_Code out Mpt_Print_Variables.Variable_Code%type
  ) is
    v_New_Code Mpt_Print_Variables.Variable_Code%type;
    v_Num      varchar2(20);
  begin
    v_New_Code := Get_Next_Qr_Code(i_Group_Code);
    v_Num      := Regexp_Substr(v_New_Code, '[0-9]+$');

    insert into Mpt_Print_Variables
      (Variable_Code,
       Scope,
       Module_Code,
       Var_Name,
       Var_Type,
       Var_Source,
       Description,
       Needs_Translit,
       Is_Required,
       Created_By)
    values
      (v_New_Code,
       i_Scope,
       i_Module_Code,
       'Admin QR #' || v_Num,
       'QR',
       'STATIC',
       'Admin tomonidan avtomatik yaratilgan QR o''zgaruvchi',
       'N',
       'N',
       i_Created_By);

    insert into Mpt_Print_Qr_Codes
      (Variable_Code,
       Group_Code,
       Qr_Name,
       Qr_Size_Mm,
       Qr_Position,
       Is_Every_Page,
       Error_Correction,
       Created_By)
    values
      (v_New_Code, i_Group_Code, 'Admin QR #' || v_Num, 30, 'PLACEHOLDER', 'N', 'M', i_Created_By);

    o_Variable_Code := v_New_Code;
  exception
    when Dup_Val_On_Index then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_QR_CODE_EXISTS',
        i_Params       => Core.Array_Varchar2(v_New_Code));
      return;
  end Add_Qr_Code_Auto;

  -- P2.3: o'zgaruvchi qiymatini hal qilish
  Function Resolve_Var_Value
  (
    i_Variable_Code in Mpt_Print_Variables.Variable_Code%type,
    i_Record_Id     in varchar2 default null,
    i_Lang_Code     in varchar2 default null,
    i_User_Id       in number default null,
    i_Params        in clob default null
  ) return varchar2 is
    v_Var    Mpt_Print_Variables%rowtype;
    v_Lang   varchar2(5);
    v_Value  varchar2(4000);
    v_Amount number;
    v_Cursor integer;
    v_Ignore integer;
  begin
    -- 1. Variable info
    select *
      into v_Var
      from Mpt_Print_Variables
     where Variable_Code = i_Variable_Code;

    -- 2. Lang aniqlash
    v_Lang := nvl(i_Lang_Code, Get_User_Lang(i_User_Id));

    -- 3. VAR_SOURCE bo'yicha qiymat olish
    case v_Var.Var_Source
      when 'STATIC' then
        v_Value := v_Var.Var_Value;

      when 'DYNAMIC' then
        -- DBMS_SQL ishlatiladi, chunki VAR_QUERY har xil
        -- kombinatsiyada :REC_ID / :LANG_CODE / :USER_ID
        -- bind'lardan foydalanishi mumkin - EXECUTE IMMEDIATE
        -- ... USING bilan bind sonini oldindan bilish shart,
        -- DBMS_SQL esa faqat matnda haqiqatan mavjud bind'larni
        -- bog'laydi.
        begin
          v_Cursor := Dbms_Sql.Open_Cursor;
          Dbms_Sql.Parse(v_Cursor, v_Var.Var_Query, Dbms_Sql.Native);

          if Regexp_Like(v_Var.Var_Query, ':REC_ID', 'i') then
            Dbms_Sql.Bind_Variable(v_Cursor, ':REC_ID', i_Record_Id);
          end if;
          if Regexp_Like(v_Var.Var_Query, ':LANG_CODE', 'i') then
            Dbms_Sql.Bind_Variable(v_Cursor, ':LANG_CODE', v_Lang);
          end if;
          if Regexp_Like(v_Var.Var_Query, ':USER_ID', 'i') then
            Dbms_Sql.Bind_Variable(v_Cursor, ':USER_ID', i_User_Id);
          end if;

          Dbms_Sql.Define_Column(v_Cursor, 1, v_Value, 4000);
          v_Ignore := Dbms_Sql.Execute(v_Cursor);

          if Dbms_Sql.Fetch_Rows(v_Cursor) > 0 then
            Dbms_Sql.Column_Value(v_Cursor, 1, v_Value);
          else
            v_Value := null;
          end if;

          Dbms_Sql.Close_Cursor(v_Cursor);
        exception
          when others then
            if Dbms_Sql.Is_Open(v_Cursor) then
              Dbms_Sql.Close_Cursor(v_Cursor);
            end if;
            v_Value := null;
        end;

      when 'PARAMETER' then
        if i_Params is not null then
          v_Value := Json_Value(i_Params, '$."' || i_Variable_Code || '"');
        end if;

      else
        v_Value := null;
    end case;

    -- 4. AMOUNT_IN_WORDS - yadrodagi tayyor funksiyaga topshiriladi
    if v_Var.Var_Type = 'AMOUNT_IN_WORDS' and v_Value is not null then
      v_Amount := to_number(v_Value);
      v_Value  := 'core da shunday method yozib qo''yish kerak';---Core_r_Util.Amount_To_Words(v_Amount, null, v_Lang); -- TODO: aniq core funksiya nomini tasdiqlang
    end if;

    -- 5. Transliteratsiya (faqat UZL -> UZC, NEEDS_TRANSLIT='Y')
    if v_Var.Needs_Translit = 'Y' and v_Lang = 'UZC' and v_Value is not null then
      v_Value := Latin_To_Cyrillic(v_Value);
    end if;

    -- 6-7. Format o'zgartirilmaydi, NULL -> ''
    return nvl(v_Value, '');
  exception
    when No_Data_Found then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_VARIABLE_NOT_FOUND',
        i_Params       => Core.Array_Varchar2(i_Variable_Code));
      return null;
  end Resolve_Var_Value;

  -- Ichki yordamchi: guruhga tegishli, TABLE/QR bo'lmagan barcha
  -- o'zgaruvchilarni VARIABLE_CODE bo'yicha kalitlangan JSON'ga hal
  -- qiladi. build_qr_content shu xaritani ishlatadi (QR_CONTENT_TEMPLATE
  -- ichidagi [variable_code] o'rinbosarlari uchun).
  Function Build_Variable_Map
  (
    i_Group_Code in Mpt_Template_Groups.Group_Code%type,
    i_Record_Id  in varchar2,
    i_Lang_Code  in varchar2,
    i_User_Id    in number,
    i_Params     in clob
  ) return clob is
    v_Result clob;
    v_First  boolean := true;
  begin
    v_Result := '{';

    for v_Map in (select distinct m.Variable_Code, v.Var_Type
                    from Mpt_Template_Var_Mapping_Doc m
                    join Mpt_Print_Variables v
                      on v.Variable_Code = m.Variable_Code
                   where m.Group_Code = i_Group_Code
                     and m.Is_Active = 'Y'
                  union
                  select distinct m.Variable_Code, v.Var_Type
                    from Mpt_Template_Cell_Mapping m
                    join Mpt_Print_Variables v
                      on v.Variable_Code = m.Variable_Code
                   where m.Group_Code = i_Group_Code
                     and m.Is_Active = 'Y')
    loop
      if v_Map.Var_Type not in ('TABLE', 'QR') then
        if not v_First then
          v_Result := v_Result || ',';
        end if;
        v_Result := v_Result || '"' || v_Map.Variable_Code || '":"' ||
                    replace(Resolve_Var_Value(v_Map.Variable_Code,
                                              i_Record_Id,
                                              i_Lang_Code,
                                              i_User_Id,
                                              i_Params),
                            '"',
                            '\"') || '"';
        v_First  := false;
      end if;
    end loop;

    v_Result := v_Result || '}';
    return v_Result;
  end Build_Variable_Map;

  -- Ichki yordamchi: VAR_TYPE='TABLE' o'zgaruvchini ko'p qatorli JSON
  -- massiviga hal qiladi. VAR_QUERY bir nechta ustun/qator qaytarishi
  -- mumkin - ustun nomlari DBMS_SQL.DESCRIBE_COLUMNS orqali dinamik
  -- aniqlanadi (oldindan ma'lum emas).
  Function Resolve_Var_Table
  (
    i_Variable_Code in Mpt_Print_Variables.Variable_Code%type,
    i_Record_Id     in varchar2,
    i_Lang_Code     in varchar2,
    i_User_Id       in number
  ) return clob is
    v_Var       Mpt_Print_Variables%rowtype;
    v_Cursor    integer;
    v_Ignore    integer;
    v_Desc_Tab  Dbms_Sql.Desc_Tab;
    v_Col_Count integer;
    v_Col_Val   varchar2(4000);
    v_Result    clob;
    v_Row_First boolean := true;
    v_Col_First boolean;
  begin
    select *
      into v_Var
      from Mpt_Print_Variables
     where Variable_Code = i_Variable_Code;

    if v_Var.Var_Source != 'DYNAMIC' or v_Var.Var_Query is null then
      return '[]';
    end if;

    v_Cursor := Dbms_Sql.Open_Cursor;
    Dbms_Sql.Parse(v_Cursor, v_Var.Var_Query, Dbms_Sql.Native);

    if Regexp_Like(v_Var.Var_Query, ':REC_ID', 'i') then
      Dbms_Sql.Bind_Variable(v_Cursor, ':REC_ID', i_Record_Id);
    end if;
    if Regexp_Like(v_Var.Var_Query, ':LANG_CODE', 'i') then
      Dbms_Sql.Bind_Variable(v_Cursor, ':LANG_CODE', i_Lang_Code);
    end if;
    if Regexp_Like(v_Var.Var_Query, ':USER_ID', 'i') then
      Dbms_Sql.Bind_Variable(v_Cursor, ':USER_ID', i_User_Id);
    end if;

    Dbms_Sql.Describe_Columns(v_Cursor, v_Col_Count, v_Desc_Tab);

    for i in 1 .. v_Col_Count
    loop
      Dbms_Sql.Define_Column(v_Cursor, i, v_Col_Val, 4000);
    end loop;

    v_Ignore := Dbms_Sql.Execute(v_Cursor);

    v_Result := '[';
    while Dbms_Sql.Fetch_Rows(v_Cursor) > 0
    loop
      if not v_Row_First then
        v_Result := v_Result || ',';
      end if;

      v_Result    := v_Result || '{';
      v_Col_First := true;

      for i in 1 .. v_Col_Count
      loop
        Dbms_Sql.Column_Value(v_Cursor, i, v_Col_Val);
        if not v_Col_First then
          v_Result := v_Result || ',';
        end if;
        v_Result    := v_Result || '"' || Lower(v_Desc_Tab(i).Col_Name) || '":"' ||
                       replace(v_Col_Val, '"', '\"') || '"';
        v_Col_First := false;
      end loop;

      v_Result    := v_Result || '}';
      v_Row_First := false;
    end loop;
    v_Result := v_Result || ']';

    Dbms_Sql.Close_Cursor(v_Cursor);
    return v_Result;
  exception
    when others then
      if Dbms_Sql.Is_Open(v_Cursor) then
        Dbms_Sql.Close_Cursor(v_Cursor);
      end if;
      return '[]';
  end Resolve_Var_Table;

  -- P2.6: guruhning barcha o'zgaruvchilarini (oddiy, TABLE, QR)
  -- yagona JSON'ga hal qiladi: {"language":..,"placeholders":{...},
  -- "tables":{...},"qr_codes":[...]}. DOC shablonlar uchun
  -- "placeholders" TEMPLATE_VAR_MAPPING_DOC.PLACEHOLDER matni bilan,
  -- XLSX uchun "Sheet!Cell" bilan kalitlanadi.
  Function Get_All_Resolved_Vars
  (
    i_Group_Code in Mpt_Template_Groups.Group_Code%type,
    i_Record_Id  in varchar2 default null,
    i_Lang_Code  in varchar2 default null,
    i_User_Id    in number default null,
    i_Params     in clob default null
  ) return clob is
    v_Lang         varchar2(5);
    v_File_Format  Mpt_Print_Templates.File_Format%type;
    v_Placeholders clob;
    v_Tables       clob;
    v_Qr_Codes     clob;
    v_Var_Map      clob;
    v_Result       clob;
    v_Ph_First     boolean := true;
    v_Tbl_First    boolean := true;
    v_Qr_First     boolean := true;
  begin
    v_Lang := nvl(i_Lang_Code, Get_User_Lang(i_User_Id));

    -- 2. Template turini (DOC/XLSX) shu guruh+til bo'yicha aniqlash
    begin
      select File_Format
        into v_File_Format
        from Mpt_Print_Templates
       where Group_Code = i_Group_Code
         and Lang_Code = v_Lang
         and Is_Active = 'Y'
       order by Version desc
       fetch first 1 row only;
    exception
      when No_Data_Found then
        v_File_Format := null;
    end;

    v_Placeholders := '{';
    v_Tables       := '{';

    -- 3-4-5. DOC mapping (yoki format aniqlanmasa - fallback sifatida DOC).
    -- Biriktiruv endi SHABLON TURI darajasida: i_Group_Code ('mpt_setting_<id>')
    -- -> MPT_PRINT_SETTINGS.TEMPLATE_CODE -> MPT_TEMPLATE_TYPE_VARS. Ya'ni bir
    -- turdagi barcha shablonlar bir xil o'zgaruvchi to'plamini meros oladi.
    if v_File_Format is null or Upper(v_File_Format) in ('DOC', 'DOCX') then
      for v_Map in (select tv.Placeholder as Key_Text, tv.Variable_Code, v.Var_Type
                      from Mpt_Print_Settings ps
                      join Mpt_Template_Type_Vars tv
                        on tv.Template_Code = ps.Template_Code
                      join Mpt_Print_Variables v
                        on v.Variable_Code = tv.Variable_Code
                     where 'mpt_setting_' || ps.Setting_Id = i_Group_Code
                       and tv.Is_Active = 'Y')
      loop
        if not v_Ph_First then
          v_Placeholders := v_Placeholders || ',';
        end if;

        if v_Map.Var_Type = 'QR' then
          v_Placeholders := v_Placeholders || '"' || v_Map.Key_Text || '":null';
        elsif v_Map.Var_Type = 'TABLE' then
          v_Placeholders := v_Placeholders || '"' || v_Map.Key_Text || '":null';
          if not v_Tbl_First then
            v_Tables := v_Tables || ',';
          end if;
          v_Tables    := v_Tables || '"' || v_Map.Key_Text || '":' ||
                         Resolve_Var_Table(v_Map.Variable_Code, i_Record_Id, v_Lang, i_User_Id);
          v_Tbl_First := false;
        else
          v_Placeholders := v_Placeholders || '"' || v_Map.Key_Text || '":"' ||
                            replace(Resolve_Var_Value(v_Map.Variable_Code,
                                                      i_Record_Id,
                                                      v_Lang,
                                                      i_User_Id,
                                                      i_Params),
                                    '"',
                                    '\"') || '"';
        end if;

        v_Ph_First := false;
      end loop;
    end if;

    -- 3-4-5. Excel cell mapping
    if Upper(v_File_Format) = 'XLSX' then
      for v_Map in (select m.Sheet_Name || '!' || m.Cell_Address as Key_Text,
                           m.Variable_Code,
                           v.Var_Type
                      from Mpt_Template_Cell_Mapping m
                      join Mpt_Print_Variables v
                        on v.Variable_Code = m.Variable_Code
                     where m.Group_Code = i_Group_Code
                       and m.Is_Active = 'Y')
      loop
        if not v_Ph_First then
          v_Placeholders := v_Placeholders || ',';
        end if;

        if v_Map.Var_Type = 'QR' then
          v_Placeholders := v_Placeholders || '"' || v_Map.Key_Text || '":null';
        elsif v_Map.Var_Type = 'TABLE' then
          v_Placeholders := v_Placeholders || '"' || v_Map.Key_Text || '":null';
          if not v_Tbl_First then
            v_Tables := v_Tables || ',';
          end if;
          v_Tables    := v_Tables || '"' || v_Map.Key_Text || '":' ||
                         Resolve_Var_Table(v_Map.Variable_Code, i_Record_Id, v_Lang, i_User_Id);
          v_Tbl_First := false;
        else
          v_Placeholders := v_Placeholders || '"' || v_Map.Key_Text || '":"' ||
                            replace(Resolve_Var_Value(v_Map.Variable_Code,
                                                      i_Record_Id,
                                                      v_Lang,
                                                      i_User_Id,
                                                      i_Params),
                                    '"',
                                    '\"') || '"';
        end if;

        v_Ph_First := false;
      end loop;
    end if;

    v_Placeholders := v_Placeholders || '}';
    v_Tables       := v_Tables || '}';

    -- 6. QR kodlar - alohida massiv, build_qr_content orqali
    v_Var_Map := Build_Variable_Map(i_Group_Code, i_Record_Id, v_Lang, i_User_Id, i_Params);

    v_Qr_Codes := '[';
    for v_Qr in (select Qr_Id,
                        Variable_Code,
                        Qr_Size_Mm,
                        Qr_Position,
                        Is_Every_Page,
                        Error_Correction
                   from Mpt_Print_Qr_Codes
                  where Group_Code = i_Group_Code
                    and Is_Active = 'Y')
    loop
      if not v_Qr_First then
        v_Qr_Codes := v_Qr_Codes || ',';
      end if;

      v_Qr_Codes := v_Qr_Codes || '{"variable_code":"' || v_Qr.Variable_Code || '"' || ',"content":"' ||
                    replace(Build_Qr_Content(v_Qr.Qr_Id, v_Var_Map), '"', '\"') || '"' || ',"size_mm":' ||
                    v_Qr.Qr_Size_Mm || ',"position":"' || v_Qr.Qr_Position || '"' || ',"every_page":' || case
                      when v_Qr.Is_Every_Page = 'Y' then
                       'true'
                      else
                       'false'
                    end || ',"error_correction":"' || v_Qr.Error_Correction || '"}';

      v_Qr_First := false;
    end loop;
    v_Qr_Codes := v_Qr_Codes || ']';

    -- 7. Yakuniy JSON
    v_Result := '{"language":"' || v_Lang || '","placeholders":' || v_Placeholders || ',"tables":' ||
                v_Tables || ',"qr_codes":' || v_Qr_Codes || '}';

    return v_Result;
  end Get_All_Resolved_Vars;

  Function Build_Qr_Content
  (
    i_Qr_Id     in Mpt_Print_Qr_Codes.Qr_Id%type,
    i_Vars_Json in clob
  ) return varchar2 is
    v_Qr      Mpt_Print_Qr_Codes%rowtype;
    v_Content varchar2(4000);
    v_Code    varchar2(100);
    v_Start   pls_integer;
    v_End     pls_integer;
  begin
    select *
      into v_Qr
      from Mpt_Print_Qr_Codes
     where Qr_Id = i_Qr_Id;

    v_Content := v_Qr.Qr_Content_Template;

    -- [placeholder] larni i_vars_json'dagi qiymatlar bilan almashtirish
    v_Start := instr(v_Content, '[');
    while v_Start > 0
    loop
      v_End := instr(v_Content, ']', v_Start);
      exit when v_End = 0;

      v_Code    := substr(v_Content, v_Start + 1, v_End - v_Start - 1);
      v_Content := substr(v_Content, 1, v_Start - 1) ||
                   nvl(Json_Value(i_Vars_Json, '$."' || v_Code || '"'), '') ||
                   substr(v_Content, v_End + 1);

      v_Start := instr(v_Content, '[');
    end loop;

    return v_Content;
  exception
    when No_Data_Found then
      Core.Mle_Core_Api.Raise_Error(
        i_Module_Code  => 'MPT',
        i_Message_Code => 'MPT_QR_NOT_FOUND',
        i_Params       => Core.Array_Varchar2(to_char(i_Qr_Id)));
      return null;
  end Build_Qr_Content;

end Mpt_Print_Api;
/
