--drop table mll_history;
--
-- MLL (label) + MLT (template) o'zgarishlarining birlashgan tarixi.
-- Har bir qator - bitta saqlash amalidagi to'liq snapshot (label + template birga).
create table mll_history (
  log_id                   number(12) not null,
  --- MLL (mll_label_codes)
  label_id                 number(12),
  module_code              varchar2(10),
  message_code             varchar2(100),
  description              varchar2(1000 char),
  field_hint               varchar2(1000),
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
alter table mll_history
  add constraint mll_history_pk primary key (log_id)
  using index tablespace CORE_INDEX;
--
create index mll_history_i1 on mll_history (label_id)
  tablespace CORE_INDEX;

comment on table mll_history is 'MLL label va MLT template o''zgarishlarining birlashgan tarixi (audit log)';
comment on column mll_history.log_id is 'Tarix yozuvining unikal identifikatori';
comment on column mll_history.label_id is 'Mll_Label_Codes.Label_Id - tarixni shu bo''yicha qidiriladi';
comment on column mll_history.description is 'Label tavsifi (mll_label_codes.description)';
comment on column mll_history.template_description is 'Template tavsifi (mlt_templates.description)';
comment on column mll_history.action is 'Amal turi: INSERT / UPDATE / DELETE';
comment on column mll_history.action_date is 'Amal bajarilgan vaqt';
