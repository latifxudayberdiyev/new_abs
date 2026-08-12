----------------------------------------------------------------------------------------------------
--  Markaziy Bank spravochniklari uchun r_*_v taqdimot view'lari (r_region_v naqshiga mos).
--  Bular PF/boshqa modullarga bog'liq emas - mustaqil, faqat r_* jadvallarni ochib beradi.
----------------------------------------------------------------------------------------------------
create or replace view r_currency_v as select * from r_currency;
create or replace view r_district_v as select * from r_district;
create or replace view r_country_v as select * from r_country;
create or replace view r_credit_source_v as select * from r_credit_source;
create or replace view r_foreign_organization_v as select * from r_foreign_organization;
create or replace view r_bank_corr_v as select * from r_bank_corr;
create or replace view r_budget_accounts_v as select * from r_budget_accounts;
create or replace view r_business_form_v as select * from r_business_form;
create or replace view r_oked_v as select * from r_oked;
create or replace view r_subject_type_v as select * from r_subject_type;
create or replace view r_subject_sexual_identity_v as select * from r_subject_sexual_identity;
create or replace view r_verifying_document_type_v as select * from r_verifying_document_type;
create or replace view r_bank_v as select * from r_bank;
create or replace view r_bank_type_v as select * from r_bank_type;
create or replace view r_document_v as select * from r_document;
create or replace view r_rez_cl_v as select * from r_rez_cl;
create or replace view r_tax_organization_v as select * from r_tax_organization;
create or replace view r_form_property_v as select * from r_form_property;
create or replace view r_organization_legal_form_v as select * from r_organization_legal_form;
create or replace view r_nation_v as select * from r_nation;
create or replace view r_obraz_v as select * from r_obraz;
create or replace view r_coato_v as select * from r_coato;
create or replace view r_mahalla_v as select * from r_mahalla;
