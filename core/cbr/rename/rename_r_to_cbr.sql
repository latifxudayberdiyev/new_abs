----------------------------------------------------------------------------------------------------
--  R_% obyektlarini CBR_%ga o'zgartirish (24 jadval + 24 view). Ma'lumot saqlanadi.
----------------------------------------------------------------------------------------------------
-- Jadvallar
rename r_region to cbr_region;
rename r_currency to cbr_currency;
rename r_district to cbr_district;
rename r_country to cbr_country;
rename r_credit_source to cbr_credit_source;
rename r_foreign_organization to cbr_foreign_organization;
rename r_bank_corr to cbr_bank_corr;
rename r_budget_accounts to cbr_budget_accounts;
rename r_business_form to cbr_business_form;
rename r_oked to cbr_oked;
rename r_subject_type to cbr_subject_type;
rename r_subject_sexual_identity to cbr_subject_sexual_identity;
rename r_verifying_document_type to cbr_verifying_document_type;
rename r_bank to cbr_bank;
rename r_bank_type to cbr_bank_type;
rename r_document to cbr_document;
rename r_rez_cl to cbr_rez_cl;
rename r_tax_organization to cbr_tax_organization;
rename r_form_property to cbr_form_property;
rename r_organization_legal_form to cbr_organization_legal_form;
rename r_nation to cbr_nation;
rename r_obraz to cbr_obraz;
rename r_coato to cbr_coato;
rename r_mahalla to cbr_mahalla;

-- View'lar (eskilarini drop qilib, yangi nom bilan qayta yaratamiz - RENAME view'da ba'zan
-- muammo chiqarishi mumkin, shuning uchun DROP+CREATE ishonchliroq)
drop view r_region_v;
drop view r_currency_v;
drop view r_district_v;
drop view r_country_v;
drop view r_credit_source_v;
drop view r_foreign_organization_v;
drop view r_bank_corr_v;
drop view r_budget_accounts_v;
drop view r_business_form_v;
drop view r_oked_v;
drop view r_subject_type_v;
drop view r_subject_sexual_identity_v;
drop view r_verifying_document_type_v;
drop view r_bank_v;
drop view r_bank_type_v;
drop view r_document_v;
drop view r_rez_cl_v;
drop view r_tax_organization_v;
drop view r_form_property_v;
drop view r_organization_legal_form_v;
drop view r_nation_v;
drop view r_obraz_v;
drop view r_coato_v;
drop view r_mahalla_v;

create or replace view cbr_region_v as select * from cbr_region;
create or replace view cbr_currency_v as select * from cbr_currency;
create or replace view cbr_district_v as select * from cbr_district;
create or replace view cbr_country_v as select * from cbr_country;
create or replace view cbr_credit_source_v as select * from cbr_credit_source;
create or replace view cbr_foreign_organization_v as select * from cbr_foreign_organization;
create or replace view cbr_bank_corr_v as select * from cbr_bank_corr;
create or replace view cbr_budget_accounts_v as select * from cbr_budget_accounts;
create or replace view cbr_oked_v as select * from cbr_oked;
create or replace view cbr_subject_type_v as select * from cbr_subject_type;
create or replace view cbr_subject_sexual_identity_v as select * from cbr_subject_sexual_identity;
create or replace view cbr_verifying_document_type_v as select * from cbr_verifying_document_type;
create or replace view cbr_bank_v as select * from cbr_bank;
create or replace view cbr_bank_type_v as select * from cbr_bank_type;
create or replace view cbr_document_v as select * from cbr_document;
create or replace view cbr_rez_cl_v as select * from cbr_rez_cl;
create or replace view cbr_tax_organization_v as select * from cbr_tax_organization;
create or replace view cbr_form_property_v as select * from cbr_form_property;
create or replace view cbr_organization_legal_form_v as select * from cbr_organization_legal_form;

create or replace view cbr_business_form_v as
select r.*, Name_Rus as Name from cbr_business_form r;

create or replace view cbr_nation_v as
select r.*, Nation_Name as Name from cbr_nation r;

create or replace view cbr_obraz_v as
select r.*, Obraz_Name as Name from cbr_obraz r;

create or replace view cbr_coato_v as
select r.*, Uzb_Lat_Name as Name from cbr_coato r;

create or replace view cbr_mahalla_v as
select r.*,
       Code_Uz_Cad as Code,
       Name_Uz     as Name,
       Date_Open   as Date_Activ,
       Date_Close  as Date_Deact,
       Active      as State
  from cbr_mahalla r;
