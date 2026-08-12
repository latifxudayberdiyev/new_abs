----------------------------------------------------------------------------------------------------
--  TO'LIQ MIGRATSIYA: R_% -> CBR_%, Ref_% -> Cbr_%, MODULE_CODE 'REF' -> 'CBR'.
--  Bu skript ESKI holatdagi (hali R_*/Ref_* nomlangan) bazaga qarshi ishlaydi.
--  Xavfsiz: mavjud bo'lmagan obyektlar uchun xatolarni yutib yuboradi (allaqachon
--  CBR_% ga o'tkazilgan bo'lsa ham qayta ishga tushirsa bo'ladi).
--  MUHIM: bu fayl UTF-8'da saqlangan (STATE_NAME uchun kirill matni bor) - sqlplus orqali
--  ishga tushirishda albatta NLS_LANG=AMERICAN_AMERICA.AL32UTF8 bilan chaqiring
--  (CL8MSWIN1251 emas!), aks holda kirill matni buzilib saqlanadi (mojibake).
----------------------------------------------------------------------------------------------------
set define off;
set serveroutput on size unlimited;

prompt =====================================================================
prompt 1) Jadvallarni RENAME qilish (R_% -> CBR_%, ma'lumot saqlanadi)
prompt =====================================================================
declare
  procedure safe_rename(p_old varchar2, p_new varchar2) is
  begin
    execute immediate 'rename ' || p_old || ' to ' || p_new;
    dbms_output.put_line('OK: ' || p_old || ' -> ' || p_new);
  exception
    when others then
      dbms_output.put_line('SKIP (' || p_old || '): ' || sqlerrm);
  end;
begin
  safe_rename('r_region','cbr_region');
  safe_rename('r_currency','cbr_currency');
  safe_rename('r_district','cbr_district');
  safe_rename('r_country','cbr_country');
  safe_rename('r_credit_source','cbr_credit_source');
  safe_rename('r_foreign_organization','cbr_foreign_organization');
  safe_rename('r_bank_corr','cbr_bank_corr');
  safe_rename('r_budget_accounts','cbr_budget_accounts');
  safe_rename('r_business_form','cbr_business_form');
  safe_rename('r_oked','cbr_oked');
  safe_rename('r_subject_type','cbr_subject_type');
  safe_rename('r_subject_sexual_identity','cbr_subject_sexual_identity');
  safe_rename('r_verifying_document_type','cbr_verifying_document_type');
  safe_rename('r_bank','cbr_bank');
  safe_rename('r_bank_type','cbr_bank_type');
  safe_rename('r_document','cbr_document');
  safe_rename('r_rez_cl','cbr_rez_cl');
  safe_rename('r_tax_organization','cbr_tax_organization');
  safe_rename('r_form_property','cbr_form_property');
  safe_rename('r_organization_legal_form','cbr_organization_legal_form');
  safe_rename('r_nation','cbr_nation');
  safe_rename('r_obraz','cbr_obraz');
  safe_rename('r_coato','cbr_coato');
  safe_rename('r_mahalla','cbr_mahalla');
  safe_rename('Ref_r_Procedures','Cbr_r_Procedures');
end;
/

prompt =====================================================================
prompt 2) Eski R_*_V view'larni tozalash (bo'lsa)
prompt =====================================================================
declare
  procedure safe_drop_view(p_name varchar2) is
  begin
    execute immediate 'drop view ' || p_name;
  exception
    when others then null;
  end;
begin
  safe_drop_view('r_region_v');
  safe_drop_view('r_currency_v');
  safe_drop_view('r_district_v');
  safe_drop_view('r_country_v');
  safe_drop_view('r_credit_source_v');
  safe_drop_view('r_foreign_organization_v');
  safe_drop_view('r_bank_corr_v');
  safe_drop_view('r_budget_accounts_v');
  safe_drop_view('r_business_form_v');
  safe_drop_view('r_oked_v');
  safe_drop_view('r_subject_type_v');
  safe_drop_view('r_subject_sexual_identity_v');
  safe_drop_view('r_verifying_document_type_v');
  safe_drop_view('r_bank_v');
  safe_drop_view('r_bank_type_v');
  safe_drop_view('r_document_v');
  safe_drop_view('r_rez_cl_v');
  safe_drop_view('r_tax_organization_v');
  safe_drop_view('r_form_property_v');
  safe_drop_view('r_organization_legal_form_v');
  safe_drop_view('r_nation_v');
  safe_drop_view('r_obraz_v');
  safe_drop_view('r_coato_v');
  safe_drop_view('r_mahalla_v');
end;
/

prompt =====================================================================
prompt 3) Yangi CBR_*_V view'larni yaratish
prompt =====================================================================
-- E'TIBOR: 19 ta rasmiy spravochnikning har birida STATE_NAME hisoblanadigan ustun bor
-- (STATE='A' -> 'Актив', qolgan barcha holatlar, jumladan NULL -> 'Пассив'). JSP katalogi
-- shu ustundan o'qiydi. 5 ta kompilyatsiya-uchun-kerak (19 talikka kirmaydigan) view'da
-- STATE_NAME yo'q.
create or replace view cbr_region_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_region t;
create or replace view cbr_currency_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_currency t;
create or replace view cbr_district_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_district t;
create or replace view cbr_country_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_country t;
create or replace view cbr_credit_source_v as select * from cbr_credit_source;
create or replace view cbr_foreign_organization_v as select * from cbr_foreign_organization;
create or replace view cbr_bank_corr_v as select * from cbr_bank_corr;
create or replace view cbr_budget_accounts_v as select * from cbr_budget_accounts;
create or replace view cbr_oked_v as select * from cbr_oked;
create or replace view cbr_subject_type_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_subject_type t;
create or replace view cbr_subject_sexual_identity_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_subject_sexual_identity t;
create or replace view cbr_verifying_document_type_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_verifying_document_type t;
create or replace view cbr_bank_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_bank t;
create or replace view cbr_bank_type_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_bank_type t;
create or replace view cbr_document_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_document t;
create or replace view cbr_rez_cl_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_rez_cl t;
create or replace view cbr_tax_organization_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_tax_organization t;
create or replace view cbr_form_property_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_form_property t;
create or replace view cbr_organization_legal_form_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_organization_legal_form t;

create or replace view cbr_business_form_v as
select r.*, Name_Rus as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_business_form r;

create or replace view cbr_nation_v as
select r.*, Nation_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_nation r;

create or replace view cbr_obraz_v as
select r.*, Obraz_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_obraz r;

create or replace view cbr_coato_v as
select r.*, Uzb_Lat_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_coato r;

create or replace view cbr_mahalla_v as
select r.*,
       Code_Uz_Cad as Code,
       Name_Uz     as Name,
       Date_Open   as Date_Activ,
       Date_Close  as Date_Deact,
       Active      as State,
       decode(r.Active,'A','Актив','Пассив') as State_Name
  from cbr_mahalla r;

prompt =====================================================================
prompt 4) MODULE_CODE 'REF' -> 'CBR' (mavjud bo'lsa)
prompt =====================================================================
update CORE_R_MODULES set module_code = 'CBR' where module_code = 'REF';
update CORE_R_MENUS set module_code = 'CBR' where module_code = 'REF';
update mll_label_codes set module_code = 'CBR' where message_code in ('REF_CB_MENU_GROUP','REF_CB_MENU_CATALOG','CBR_CB_MENU_GROUP','CBR_CB_MENU_CATALOG');
update mlt_templates set message_code = 'CBR_CB_MENU_GROUP' where message_code = 'REF_CB_MENU_GROUP';
update mlt_templates set message_code = 'CBR_CB_MENU_CATALOG' where message_code = 'REF_CB_MENU_CATALOG';
update mll_label_codes set message_code = 'CBR_CB_MENU_GROUP' where message_code = 'REF_CB_MENU_GROUP';
update mll_label_codes set message_code = 'CBR_CB_MENU_CATALOG' where message_code = 'REF_CB_MENU_CATALOG';
update CORE_R_MODULES set name_mll_code = 'CBR_CB_MENU_GROUP', short_name_mll_code = 'CBR_CB_MENU_GROUP' where module_code = 'CBR' and name_mll_code = 'REF_CB_MENU_GROUP';
update CORE_R_MENUS set name_mll_code = 'CBR_CB_MENU_GROUP' where module_code = 'CBR' and name_mll_code = 'REF_CB_MENU_GROUP';
update CORE_R_MENUS set name_mll_code = 'CBR_CB_MENU_CATALOG' where module_code = 'CBR' and name_mll_code = 'REF_CB_MENU_CATALOG';
commit;

prompt =====================================================================
prompt 5) Eski Ref_Dml / Ref_Kernel paketlarini tozalash (bo'lsa)
prompt =====================================================================
begin
  execute immediate 'drop package Ref_Dml';
exception when others then null;
end;
/
begin
  execute immediate 'drop package Ref_Kernel';
exception when others then null;
end;
/

prompt =====================================================================
prompt 6) Cbr_Dml paketi
prompt =====================================================================
create or replace package Cbr_Dml is
  Procedure Set_Ref_16(i_Row in cbr_Region%rowtype);
  Procedure Set_Ref_17(i_Row in cbr_Currency%rowtype);
  Procedure Set_Ref_52(i_Row in cbr_District%rowtype);
  Procedure Set_Ref_18(i_Row in cbr_Country%rowtype);
  Procedure Set_Ref_38(i_Row in cbr_Credit_Source%rowtype);
  Procedure Set_Ref_41(i_Row in cbr_Foreign_Organization%rowtype);
  Procedure Set_Ref_47(i_Row in cbr_Bank_Corr%rowtype);
  Procedure Set_Ref_29(i_Row in cbr_Budget_Accounts%rowtype);
  Procedure Set_Ref_93(i_Row in cbr_Business_Form%rowtype);
  Procedure Set_Ref_13(i_Row in cbr_Oked%rowtype);
  Procedure Set_Ref_6(i_Row in cbr_Subject_Type%rowtype);
  Procedure Set_Ref_7(i_Row in cbr_Subject_Sexual_Identity%rowtype);
  Procedure Set_Ref_8(i_Row in cbr_Verifying_Document_Type%rowtype);
  Procedure Set_Ref_12(i_Row in cbr_Bank%rowtype);
  Procedure Set_Ref_14(i_Row in cbr_Bank_Type%rowtype);
  Procedure Set_Ref_26(i_Row in cbr_Document%rowtype);
  Procedure Set_Ref_27(i_Row in cbr_Rez_Cl%rowtype);
  Procedure Set_Ref_54(i_Row in cbr_Tax_Organization%rowtype);
  Procedure Set_Ref_57(i_Row in cbr_Form_Property%rowtype);
  Procedure Set_Ref_63(i_Row in cbr_Organization_Legal_Form%rowtype);
  Procedure Set_Ref_72(i_Row in cbr_Nation%rowtype);
  Procedure Set_Ref_74(i_Row in cbr_Obraz%rowtype);
  Procedure Set_Ref_92(i_Row in cbr_Coato%rowtype);
  Procedure Set_Ref_125(i_Row in cbr_Mahalla%rowtype);
end Cbr_Dml;
/
create or replace package body Cbr_Dml is
  Procedure Set_Ref_16(i_Row in cbr_Region%rowtype) is
    v_Row cbr_Region%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Region t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Region values v_Row; end if;
  end;
  Procedure Set_Ref_17(i_Row in cbr_Currency%rowtype) is
    v_Row cbr_Currency%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Currency t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Currency values v_Row; end if;
  end;
  Procedure Set_Ref_52(i_Row in cbr_District%rowtype) is
    v_Row cbr_District%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_District t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_District values v_Row; end if;
  end;
  Procedure Set_Ref_18(i_Row in cbr_Country%rowtype) is
    v_Row cbr_Country%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Country t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Country values v_Row; end if;
  end;
  Procedure Set_Ref_41(i_Row in cbr_Foreign_Organization%rowtype) is
    v_Row cbr_Foreign_Organization%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Foreign_Organization t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Foreign_Organization values v_Row; end if;
  end;
  Procedure Set_Ref_38(i_Row in cbr_Credit_Source%rowtype) is
    v_Row cbr_Credit_Source%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Credit_Source t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Credit_Source values v_Row; end if;
  end;
  Procedure Set_Ref_47(i_Row in cbr_Bank_Corr%rowtype) is
    v_Row cbr_Bank_Corr%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank_Corr t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Bank_Corr values v_Row; end if;
  end;
  Procedure Set_Ref_29(i_Row in cbr_Budget_Accounts%rowtype) is
    v_Row cbr_Budget_Accounts%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Budget_Accounts t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Budget_Accounts values v_Row; end if;
  end;
  Procedure Set_Ref_93(i_Row in cbr_Business_Form%rowtype) is
    v_Row cbr_Business_Form%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Business_Form t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Business_Form values v_Row; end if;
  end;
  Procedure Set_Ref_13(i_Row in cbr_Oked%rowtype) is
    v_Row cbr_Oked%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Oked t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Oked values v_Row; end if;
  end;
  Procedure Set_Ref_6(i_Row in cbr_Subject_Type%rowtype) is
    v_Row cbr_Subject_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Subject_Type t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Subject_Type values v_Row; end if;
  end;
  Procedure Set_Ref_7(i_Row in cbr_Subject_Sexual_Identity%rowtype) is
    v_Row cbr_Subject_Sexual_Identity%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Subject_Sexual_Identity t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Subject_Sexual_Identity values v_Row; end if;
  end;
  Procedure Set_Ref_8(i_Row in cbr_Verifying_Document_Type%rowtype) is
    v_Row cbr_Verifying_Document_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Verifying_Document_Type t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Verifying_Document_Type values v_Row; end if;
  end;
  Procedure Set_Ref_12(i_Row in cbr_Bank%rowtype) is
    v_Row cbr_Bank%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Bank values v_Row; end if;
  end;
  Procedure Set_Ref_14(i_Row in cbr_Bank_Type%rowtype) is
    v_Row cbr_Bank_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank_Type t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Bank_Type values v_Row; end if;
  end;
  Procedure Set_Ref_26(i_Row in cbr_Document%rowtype) is
    v_Row cbr_Document%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Document t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Document values v_Row; end if;
  end;
  Procedure Set_Ref_27(i_Row in cbr_Rez_Cl%rowtype) is
    v_Row cbr_Rez_Cl%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Rez_Cl t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Rez_Cl values v_Row; end if;
  end;
  Procedure Set_Ref_54(i_Row in cbr_Tax_Organization%rowtype) is
    v_Row cbr_Tax_Organization%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Tax_Organization t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Tax_Organization values v_Row; end if;
  end;
  Procedure Set_Ref_57(i_Row in cbr_Form_Property%rowtype) is
    v_Row cbr_Form_Property%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Form_Property t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Form_Property values v_Row; end if;
  end;
  Procedure Set_Ref_63(i_Row in cbr_Organization_Legal_Form%rowtype) is
    v_Row cbr_Organization_Legal_Form%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Organization_Legal_Form t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Organization_Legal_Form values v_Row; end if;
  end;
  Procedure Set_Ref_72(i_Row in cbr_Nation%rowtype) is
    v_Row cbr_Nation%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Nation t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Nation values v_Row; end if;
  end;
  Procedure Set_Ref_74(i_Row in cbr_Obraz%rowtype) is
    v_Row cbr_Obraz%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Obraz t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Obraz values v_Row; end if;
  end;
  Procedure Set_Ref_92(i_Row in cbr_Coato%rowtype) is
    v_Row cbr_Coato%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Coato t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Coato values v_Row; end if;
  end;
  Procedure Set_Ref_125(i_Row in cbr_Mahalla%rowtype) is
    v_Row cbr_Mahalla%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Mahalla t set row = v_Row where t.Code_Uz_Cad = v_Row.Code_Uz_Cad;
    if sql%rowcount = 0 then insert into cbr_Mahalla values v_Row; end if;
  end;
end Cbr_Dml;
/

prompt =====================================================================
prompt 7) Cbr_Kernel paketi
prompt =====================================================================
create or replace package Cbr_Kernel is
  Procedure Set_Ref_52(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_16(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_17(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_18(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_38(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_41(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_47(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_29(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_93(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_13(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_6(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_7(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_8(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_12(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_14(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_26(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_27(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_54(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_57(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_63(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_72(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_74(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_92(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_125(i_Arr in Core.Array_Varchar2);
  Procedure Get_Reference_Cb
  (
    i_Reference_Id in number,
    o_Code         out number,
    o_Msg          out varchar2,
    i_Page_Size    in number default 10
  );
end Cbr_Kernel;
/
create or replace package body Cbr_Kernel is
  Function Get_Ref_Procedure_Name(i_Ref_Id in number) return varchar2 is
    result varchar2(200);
  begin
    select t.Procedure_Name into result from Cbr_r_Procedures t where t.Ref_Id = i_Ref_Id;
    return result;
  end;
  Procedure Set_Ref_16(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Region%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2); v_Row.Order_By := i_Arr(3);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_16(i_Row => v_Row);
  end;
  Procedure Set_Ref_17(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Currency%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Char_Code := i_Arr(2); v_Row.Name := i_Arr(3);
    v_Row.Scale := i_Arr(4); v_Row.Scale_Name := i_Arr(5); v_Row.Hard := i_Arr(6); v_Row.Allow := i_Arr(7);
    v_Row.Date_Activ := to_date(i_Arr(8), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State := i_Arr(10);
    Cbr_Dml.Set_Ref_17(i_Row => v_Row);
  end;
  Procedure Set_Ref_52(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_District%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2); v_Row.Region_Code := i_Arr(3);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_52(i_Row => v_Row);
  end;
  Procedure Set_Ref_18(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Country%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Char_Code := i_Arr(2); v_Row.Char_Ext_Code := i_Arr(3); v_Row.Name := i_Arr(4);
    v_Row.Currency_Code := i_Arr(5); v_Row.In_Sng := i_Arr(6);
    v_Row.Date_Activ := to_date(i_Arr(7), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(8), 'dd.mm.rr');
    v_Row.State := i_Arr(9);
    Cbr_Dml.Set_Ref_18(i_Row => v_Row);
  end;
  Procedure Set_Ref_38(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Credit_Source%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2); v_Row.Group_Code := i_Arr(3);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_38(i_Row => v_Row);
  end;
  Procedure Set_Ref_41(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Foreign_Organization%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Credit_Source_Code := i_Arr(2); v_Row.Name := i_Arr(3); v_Row.Label := i_Arr(7);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_41(i_Row => v_Row);
  end;
  Procedure Set_Ref_47(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank_Corr%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Swift_Code := i_Arr(2); v_Row.Name := i_Arr(3); v_Row.Country_Code := i_Arr(4);
    v_Row.Date_Activ := to_date(i_Arr(5), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State := i_Arr(7);
    Cbr_Dml.Set_Ref_47(i_Row => v_Row);
  end;
  Procedure Set_Ref_29(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Budget_Accounts%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Account_Code := i_Arr(2); v_Row.Inn := i_Arr(3); v_Row.Name := i_Arr(4);
    v_Row.Date_Activ := to_date(i_Arr(5), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State := i_Arr(7);
    Cbr_Dml.Set_Ref_29(i_Row => v_Row);
  end;
  Procedure Set_Ref_93(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Business_Form%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name_Rus := i_Arr(2); v_Row.Name_Uzb := i_Arr(3); v_Row.Group_Code := i_Arr(4);
    v_Row.Date_Activ := to_date(i_Arr(5), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State := i_Arr(7);
    Cbr_Dml.Set_Ref_93(i_Row => v_Row);
  end;
  Procedure Set_Ref_13(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Oked%rowtype;
  begin
    v_Row.Sction_Gr := i_Arr(1); v_Row.Section_Sy := i_Arr(2); v_Row.Sg_Name_Ru := i_Arr(3); v_Row.Sg_Name_Uz := i_Arr(4);
    v_Row.Section_Code := i_Arr(5); v_Row.Section_Name_Ru := i_Arr(6); v_Row.Section_Name_Uz := i_Arr(7);
    v_Row.Group_Code := i_Arr(8); v_Row.Group_Name_Ru := i_Arr(9); v_Row.Group_Name_Uz := i_Arr(10);
    v_Row.Class_Code := i_Arr(11); v_Row.Class_Name_Ru := i_Arr(12); v_Row.Class_Name_Uz := i_Arr(13);
    v_Row.Code := i_Arr(14); v_Row.Name_Ru := i_Arr(15); v_Row.Name_Uz := i_Arr(16);
    v_Row.Date_Activ := to_date(i_Arr(17), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(18), 'dd.mm.rr');
    v_Row.State := i_Arr(19);
    Cbr_Dml.Set_Ref_13(i_Row => v_Row);
  end;
  Procedure Set_Ref_6(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Subject_Type%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5); v_Row.Name_Uz := i_Arr(6);
    Cbr_Dml.Set_Ref_6(i_Row => v_Row);
  end;
  Procedure Set_Ref_7(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Subject_Sexual_Identity%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_7(i_Row => v_Row);
  end;
  Procedure Set_Ref_8(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Verifying_Document_Type%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_8(i_Row => v_Row);
  end;
  Procedure Set_Ref_12(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Bank_Type_Code := i_Arr(2); v_Row.Region_Code := i_Arr(3);
    v_Row.Header_Code := i_Arr(4); v_Row.Union_Code := i_Arr(5); v_Row.Tcr_Code := i_Arr(6); v_Row.Rkc_Code := i_Arr(7);
    v_Row.Name := i_Arr(8); v_Row.Adress := i_Arr(9); v_Row.Status_Code := i_Arr(10); v_Row.Account_Type := i_Arr(11);
    v_Row.Date_Open := to_date(i_Arr(12), 'dd.mm.rr'); v_Row.Date_Close := to_date(i_Arr(13), 'dd.mm.rr');
    v_Row.Active := i_Arr(14); v_Row.Email := i_Arr(15); v_Row.Server_Alias := i_Arr(16); v_Row.Connect_Type := i_Arr(17);
    v_Row.Allow_Currency := i_Arr(18);
    v_Row.Date_Activ := to_date(i_Arr(19), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(20), 'dd.mm.rr');
    v_Row.District_Code := i_Arr(21); v_Row.Num_Change_Office := i_Arr(22); v_Row.State := i_Arr(23);
    Cbr_Dml.Set_Ref_12(i_Row => v_Row);
  end;
  Procedure Set_Ref_14(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank_Type%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2); v_Row.Short_Name := i_Arr(3); v_Row.Country_Code := i_Arr(4);
    v_Row.Account_Type := i_Arr(5);
    v_Row.Date_Open := to_date(i_Arr(6), 'dd.mm.rr'); v_Row.Date_Close := to_date(i_Arr(7), 'dd.mm.rr');
    v_Row.Date_Activ := to_date(i_Arr(8), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State := i_Arr(10);
    Cbr_Dml.Set_Ref_14(i_Row => v_Row);
  end;
  Procedure Set_Ref_26(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Document%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_26(i_Row => v_Row);
  end;
  Procedure Set_Ref_27(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Rez_Cl%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_27(i_Row => v_Row);
  end;
  Procedure Set_Ref_54(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Tax_Organization%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_54(i_Row => v_Row);
  end;
  Procedure Set_Ref_57(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Form_Property%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.Active := i_Arr(5); v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_57(i_Row => v_Row);
  end;
  Procedure Set_Ref_63(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Organization_Legal_Form%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_63(i_Row => v_Row);
  end;
  Procedure Set_Ref_72(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Nation%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Nation_Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_72(i_Row => v_Row);
  end;
  Procedure Set_Ref_74(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Obraz%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Obraz_Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_74(i_Row => v_Row);
  end;
  Procedure Set_Ref_92(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Coato%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.District_Code := i_Arr(2); v_Row.District_Tax_Code := i_Arr(3);
    v_Row.Region_Code := i_Arr(4); v_Row.Rus_Name := i_Arr(5); v_Row.Uzb_Cyr_Name := i_Arr(6); v_Row.Uzb_Lat_Name := i_Arr(7);
    v_Row.Date_Activ := to_date(i_Arr(8), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State := i_Arr(10);
    Cbr_Dml.Set_Ref_92(i_Row => v_Row);
  end;
  Procedure Set_Ref_125(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Mahalla%rowtype;
  begin
    v_Row.Code_Uz_Cad := i_Arr(1); v_Row.Code_1c := i_Arr(2); v_Row.Inn := i_Arr(3); v_Row.Region_Id := i_Arr(4);
    v_Row.Soato_Id := i_Arr(5); v_Row.Distr := i_Arr(6); v_Row.Name_Uz := i_Arr(7); v_Row.Name_Ru := i_Arr(8);
    v_Row.Name_En := i_Arr(9);
    v_Row.Date_Open := to_date(i_Arr(10), 'dd.mm.rr'); v_Row.Date_Close := to_date(i_Arr(11), 'dd.mm.rr');
    v_Row.Active := i_Arr(12);
    Cbr_Dml.Set_Ref_125(i_Row => v_Row);
  end;
  Procedure Call_Reference(i_Arr in Core.Array_Varchar2, i_Ref_Id in number) is
    v_Procedure_Name varchar2(200);
    v_Sql_Stm        varchar2(3000);
  begin
    v_Procedure_Name := Get_Ref_Procedure_Name(i_Ref_Id);
    v_Sql_Stm := 'begin ' || v_Procedure_Name || '(:1); end;';
    execute immediate v_Sql_Stm using in i_Arr;
  end;
  Procedure Get_Reference_Cb
  (
    i_Reference_Id in number,
    o_Code         out number,
    o_Msg          out varchar2,
    i_Page_Size    in number default 10
  ) is
    Io_Hash         Core.Hash_t := Core.Hash_t();
    v_Req           Core.Hash_t := Core.Hash_t();
    v_Response_Hash Core.Hash_t := Core.Hash_t();
    v_Page_Number   number := 1;
    v_Page_Size     number := nvl(i_Page_Size, 10);
    v_Data_List     Core.Arraylist := Core.Arraylist();
    v_Detail_Arr    Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Ora_Msg       varchar2(4000);
  begin
    o_Code := Core_Const.c_Success_Code;
    o_Msg  := null;
    loop
      Io_Hash := Core.Hash_t();
      v_Req   := Core.Hash_t();
      v_Req.Put('service_code', 'FB_ESB');
      v_Req.Put('method_code', '1');
      v_Req.Put('referenceId', to_char(i_Reference_Id));
      v_Req.Put('pageSize', to_char(v_Page_Size));
      v_Req.Put('page', to_char(v_Page_Number));
      Io_Hash.Put('esbo_request', v_Req);
      Esbo_Kernel.Universal_Api(Io_Hash => Io_Hash, o_Code => o_Code, o_Msg => o_Msg, o_Ora_Msg => v_Ora_Msg);
      if o_Code != Core_Const.c_Success_Code then
        o_Msg := o_Msg || ' ' || v_Ora_Msg;
        return;
      end if;
      v_Response_Hash := Io_Hash.Get_Optional_Hash_t('esbo_response');
      v_Data_List     := v_Response_Hash.Get_Optional_Arraylist('data');
      if v_Data_List is null or v_Data_List.Count = 0 then exit; end if;
      for i in 1 .. v_Data_List.Count loop
        v_Detail_Arr := v_Data_List.Get_r_Array_Varchar2(i);
        Call_Reference(v_Detail_Arr, i_Reference_Id);
      end loop;
      if v_Data_List.Count < v_Page_Size then exit; end if;
      v_Page_Number := v_Page_Number + 1;
    end loop;
  exception
    when others then
      o_Code := -999;
      o_Msg  := 'System error ' || sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
end Cbr_Kernel;
/

prompt =====================================================================
prompt 8) UAPP uchun grant + sinonim (bo'lmasa xatosiz o'tkazib yuboriladi)
prompt =====================================================================
declare
  procedure safe_grant_syn(p_view varchar2) is
  begin
    execute immediate 'grant select on ' || p_view || ' to UAPP';
    execute immediate 'create or replace synonym UAPP.' || p_view || ' for CORE.' || p_view;
  exception
    when others then dbms_output.put_line('SKIP UAPP (' || p_view || '): ' || sqlerrm);
  end;
begin
  safe_grant_syn('cbr_region_v');
  safe_grant_syn('cbr_currency_v');
  safe_grant_syn('cbr_district_v');
  safe_grant_syn('cbr_country_v');
  safe_grant_syn('cbr_credit_source_v');
  safe_grant_syn('cbr_foreign_organization_v');
  safe_grant_syn('cbr_bank_corr_v');
  safe_grant_syn('cbr_budget_accounts_v');
  safe_grant_syn('cbr_business_form_v');
  safe_grant_syn('cbr_oked_v');
  safe_grant_syn('cbr_subject_type_v');
  safe_grant_syn('cbr_subject_sexual_identity_v');
  safe_grant_syn('cbr_verifying_document_type_v');
  safe_grant_syn('cbr_bank_v');
  safe_grant_syn('cbr_bank_type_v');
  safe_grant_syn('cbr_document_v');
  safe_grant_syn('cbr_rez_cl_v');
  safe_grant_syn('cbr_tax_organization_v');
  safe_grant_syn('cbr_form_property_v');
  safe_grant_syn('cbr_organization_legal_form_v');
  safe_grant_syn('cbr_nation_v');
  safe_grant_syn('cbr_obraz_v');
  safe_grant_syn('cbr_coato_v');
  safe_grant_syn('cbr_mahalla_v');
end;
/

prompt =====================================================================
prompt Tekshirish: kompilyatsiya holati
prompt =====================================================================
select object_name || ' (' || object_type || '): ' || status
  from user_objects
 where object_name in ('CBR_DML','CBR_KERNEL','CBR_R_PROCEDURES')
 order by object_name, object_type;

prompt Tayyor.
