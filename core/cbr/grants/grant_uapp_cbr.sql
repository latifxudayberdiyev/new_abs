----------------------------------------------------------------------------------------------------
--  Eski r_*_v sinonimlarni tozalab, yangi cbr_*_v uchun grant+sinonim yaratish.
----------------------------------------------------------------------------------------------------
begin
  for r in (select synonym_name from all_synonyms where owner='UAPP' and table_owner='CORE' and synonym_name like 'R\_%\_V' escape '\') loop
    execute immediate 'drop synonym UAPP.' || r.synonym_name;
  end loop;
end;
/

grant select on cbr_region_v to UAPP;
grant select on cbr_currency_v to UAPP;
grant select on cbr_district_v to UAPP;
grant select on cbr_country_v to UAPP;
grant select on cbr_credit_source_v to UAPP;
grant select on cbr_foreign_organization_v to UAPP;
grant select on cbr_bank_corr_v to UAPP;
grant select on cbr_budget_accounts_v to UAPP;
grant select on cbr_business_form_v to UAPP;
grant select on cbr_oked_v to UAPP;
grant select on cbr_subject_type_v to UAPP;
grant select on cbr_subject_sexual_identity_v to UAPP;
grant select on cbr_verifying_document_type_v to UAPP;
grant select on cbr_bank_v to UAPP;
grant select on cbr_bank_type_v to UAPP;
grant select on cbr_document_v to UAPP;
grant select on cbr_rez_cl_v to UAPP;
grant select on cbr_tax_organization_v to UAPP;
grant select on cbr_form_property_v to UAPP;
grant select on cbr_organization_legal_form_v to UAPP;
grant select on cbr_nation_v to UAPP;
grant select on cbr_obraz_v to UAPP;
grant select on cbr_coato_v to UAPP;
grant select on cbr_mahalla_v to UAPP;

create or replace synonym UAPP.cbr_region_v for CORE.cbr_region_v;
create or replace synonym UAPP.cbr_currency_v for CORE.cbr_currency_v;
create or replace synonym UAPP.cbr_district_v for CORE.cbr_district_v;
create or replace synonym UAPP.cbr_country_v for CORE.cbr_country_v;
create or replace synonym UAPP.cbr_credit_source_v for CORE.cbr_credit_source_v;
create or replace synonym UAPP.cbr_foreign_organization_v for CORE.cbr_foreign_organization_v;
create or replace synonym UAPP.cbr_bank_corr_v for CORE.cbr_bank_corr_v;
create or replace synonym UAPP.cbr_budget_accounts_v for CORE.cbr_budget_accounts_v;
create or replace synonym UAPP.cbr_business_form_v for CORE.cbr_business_form_v;
create or replace synonym UAPP.cbr_oked_v for CORE.cbr_oked_v;
create or replace synonym UAPP.cbr_subject_type_v for CORE.cbr_subject_type_v;
create or replace synonym UAPP.cbr_subject_sexual_identity_v for CORE.cbr_subject_sexual_identity_v;
create or replace synonym UAPP.cbr_verifying_document_type_v for CORE.cbr_verifying_document_type_v;
create or replace synonym UAPP.cbr_bank_v for CORE.cbr_bank_v;
create or replace synonym UAPP.cbr_bank_type_v for CORE.cbr_bank_type_v;
create or replace synonym UAPP.cbr_document_v for CORE.cbr_document_v;
create or replace synonym UAPP.cbr_rez_cl_v for CORE.cbr_rez_cl_v;
create or replace synonym UAPP.cbr_tax_organization_v for CORE.cbr_tax_organization_v;
create or replace synonym UAPP.cbr_form_property_v for CORE.cbr_form_property_v;
create or replace synonym UAPP.cbr_organization_legal_form_v for CORE.cbr_organization_legal_form_v;
create or replace synonym UAPP.cbr_nation_v for CORE.cbr_nation_v;
create or replace synonym UAPP.cbr_obraz_v for CORE.cbr_obraz_v;
create or replace synonym UAPP.cbr_coato_v for CORE.cbr_coato_v;
create or replace synonym UAPP.cbr_mahalla_v for CORE.cbr_mahalla_v;
