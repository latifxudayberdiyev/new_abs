--drop table mle_history;
--
-- MLE (error code) + MLT (template) o'zgarishlarining birlashgan tarixi.
-- Har bir qator - bitta saqlash amalidagi to'liq snapshot (error + template birga).
create table mle_history (
  log_id                   number(12) not null,
  --- MLE (mlt_error_codes)
  error_id                 number(12),
  module_code              varchar2(10),
  error_code               number(5),
  message_code             varchar2(100),
  description              varchar2(1000 char),
  --- MLT (mlt_templates)
  template_id              number(12),
  template_description     varchar2(1000 char),
  param_count              number(2),
  format_string            varchar2(1),
  message_mask_lang1       varchar2(1000 char),
  message_mask_lang2       varchar2(1000 char),
  message_mask_lang3       varchar2(1000 char),
  message_mask_lang4       varchar2(1000 char),
  message_mask_lang5       varchar2(1000 char),
  message_mask_lang6       varchar2(1000 char),
  message_mask_lang7       varchar2(1000 char),
  message_mask_lang8       varchar2(1000 char),
  message_mask_lang9       varchar2(1000 char),
  message_mask_lang10      varchar2(1000 char),
  --- audit
  modified_by              number(12),
  modified_on              date,
  action                   varchar2(10) not null,
  action_date              date not null
) tablespace CORE_DATA;
--
alter table mle_history
  add constraint mle_history_pk primary key (log_id)
  using index tablespace CORE_INDEX;
--
create index mle_history_i1 on mle_history (error_id)
  tablespace CORE_INDEX;

comment on table mle_history is 'MLE error code va MLT template o''zgarishlarining birlashgan tarixi (audit log)';
comment on column mle_history.log_id is 'Tarix yozuvining unikal identifikatori';
comment on column mle_history.error_id is 'Mlt_Error_Codes.Error_Id - tarixni shu bo''yicha qidiriladi';
comment on column mle_history.description is 'Error code tavsifi (mlt_error_codes.description)';
comment on column mle_history.template_description is 'Template tavsifi (mlt_templates.description)';
comment on column mle_history.action is 'Amal turi: INSERT / UPDATE / DELETE';
comment on column mle_history.action_date is 'Amal bajarilgan vaqt';
