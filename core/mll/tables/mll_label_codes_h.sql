--drop table mll_label_codes_h;
--
create table mll_label_codes_h (
  log_id           number(12) not null,
  label_id         number(12) not null,
  module_code      varchar2(10) not null,
  message_code     varchar2(100) not null,
  description      varchar2(1000 char) not null,
  field_hint       varchar2(1000),
  modified_by      number(12),
  modified_on      date,
  action           varchar2(10) not null,
  action_date      date not null
) tablespace CORE_DATA;
--
alter table mll_label_codes_h
  add constraint mll_label_codes_h_pk primary key (log_id)
  using index tablespace CORE_INDEX;

comment on table mll_label_codes_h is 'Mll_Label_Codes jadvali uchun o''zgartirishlar tarixi (audit log)';
comment on column mll_label_codes_h.log_id is 'Tarix yozuvining unikal identifikatori';
comment on column mll_label_codes_h.label_id is 'Mll_Label_Codes.Label_Id ga bog''liqlik (tarixni label_id bo''yicha qidirish uchun)';
comment on column mll_label_codes_h.action is    'Amal turi: INSERT / UPDATE / DELETE';
comment on column mll_label_codes_h.action_date is 'Amal bajarilgan vaqt';


drop table mll_label_codes_h
