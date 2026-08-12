----------------------------------------------------------------------------------------------------
--  19 ta rasmiy cbr_*_v view'ga STATE_NAME ustunini qo'shish: STATE='A' bo'lsa 'Актив',
--  qolgan barcha holatlarda (shu jumladan NULL) 'Пассив'. JSP shu ustundan o'qiydi.
--  MUHIM: bu fayl UTF-8'da saqlangan - sqlplus orqali ishga tushirishda albatta
--  NLS_LANG=AMERICAN_AMERICA.AL32UTF8 bilan chaqiring (CL8MSWIN1251 emas!), aks holda
--  kirill matni buzilib saqlanadi (mojibake).
----------------------------------------------------------------------------------------------------
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

create or replace view cbr_region_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_region t;

create or replace view cbr_currency_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_currency t;

create or replace view cbr_country_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_country t;

create or replace view cbr_document_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_document t;

create or replace view cbr_rez_cl_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_rez_cl t;

create or replace view cbr_district_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_district t;

create or replace view cbr_tax_organization_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_tax_organization t;

create or replace view cbr_form_property_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_form_property t;

create or replace view cbr_organization_legal_form_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_organization_legal_form t;

create or replace view cbr_nation_v as
select r.*, Nation_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_nation r;

create or replace view cbr_obraz_v as
select r.*, Obraz_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_obraz r;

create or replace view cbr_coato_v as
select r.*, Uzb_Lat_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_coato r;

create or replace view cbr_business_form_v as
select r.*, Name_Rus as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_business_form r;

create or replace view cbr_mahalla_v as
select r.*,
       Code_Uz_Cad as Code,
       Name_Uz     as Name,
       Date_Open   as Date_Activ,
       Date_Close  as Date_Deact,
       Active      as State,
       decode(r.Active,'A','Актив','Пассив') as State_Name
  from cbr_mahalla r;

exit;
