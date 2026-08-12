create table mlt_templates_h (
  log_id                   number(12) not null,
  template_id              number(12) not null,
  message_code             varchar2(100) not null,
  description              varchar2(1000 char) not null,
  param_count              number(2) not null,
  format_string            varchar2(1) not null,
  message_mask_lang1       varchar2(1000 char) not null,
  message_mask_lang2       varchar2(1000 char),
  message_mask_lang3       varchar2(1000 char),
  message_mask_lang4       varchar2(1000 char),
  message_mask_lang5       varchar2(1000 char),
  message_mask_lang6       varchar2(1000 char),
  message_mask_lang7       varchar2(1000 char),
  message_mask_lang8       varchar2(1000 char),
  message_mask_lang9       varchar2(1000 char),
  message_mask_lang10      varchar2(1000 char),
  modified_by              number(12),
  modified_on              date,
  action                   varchar2(10) not null,
  action_date              date not null
) tablespace CORE_DATA;

alter table mlt_templates_h
  add constraint mlt_templates_h_pk primary key (log_id)
  using index tablespace CORE_INDEX;

comment on table mlt_templates_h is 'Mlt_Templates jadvali uchun o''zgartirishlar tarixi (audit log)';
comment on column mlt_templates_h.log_id is 'Tarix yozuvining unikal identifikatori';
comment on column mlt_templates_h.action is 'Amal turi: INSERT / UPDATE / DELETE';
comment on column mlt_templates_h.action_date is 'Amal bajarilgan vaqt';

