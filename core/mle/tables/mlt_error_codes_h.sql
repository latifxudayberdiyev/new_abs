create table mlt_error_codes_h (
  log_id           number(12) not null,
  error_id         number(12),
  module_code      varchar2(10) not null,
  error_code       number(5) not null,
  message_code     varchar2(100) not null,
  description      varchar2(1000 char) not null,
  modified_by      number(12),
  modified_on      date,
  action           varchar2(10) not null,
  action_date      date not null
) tablespace CORE_DATA;

alter table mlt_error_codes_h
  add constraint mlt_error_codes_h_pk primary key (log_id)
  using index tablespace CORE_INDEX;

comment on table mlt_error_codes_h is 'Mlt_Error_Codes jadvali uchun o''zgartirishlar tarixi (audit log)';
comment on column mlt_error_codes_h.log_id is 'Tarix yozuvining unikal identifikatori';
comment on column mlt_error_codes_h.error_id is 'Mlt_Error_Codes.Error_Id ga bog''liqlik (tarixni error_id bo''yicha qidirish uchun)';
comment on column mlt_error_codes_h.action is 'Amal turi: INSERT / UPDATE / DELETE';
comment on column mlt_error_codes_h.action_date is 'Amal bajarilgan vaqt';


drop table mlt_error_codes_h;
