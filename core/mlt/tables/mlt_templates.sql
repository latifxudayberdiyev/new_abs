--drop table mlt_templates;
--
create table mlt_templates (
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
  message_mask_lang10      varchar2(1000 char)
) tablespace CORE_DATA;
--MLT_DATA, MLT_INDEX tablespaces not found
--
alter table mlt_templates
  add constraint mlt_templates_pk primary key (template_id)
  using index tablespace CORE_INDEX;
--
alter table mlt_templates
  add constraint mlt_templates_u1 unique (message_code)
  using index tablespace CORE_INDEX;
--
comment on table mlt_templates                      is 'Таблица шаблонов сообщений с поддержкой нескольких языков (MLT)';
comment on column mlt_templates.template_id         is 'Уникальный идентификатор шаблона';
comment on column mlt_templates.message_code        is 'Код сообщения';
comment on column mlt_templates.description         is 'Описание шаблона сообщения';
comment on column mlt_templates.param_count         is 'Количество параметров в шаблоне (например $1, {2} и т.д.)';
comment on column mlt_templates.format_string       is 'Символ формата (например $, #,@ и т.д.)';
comment on column mlt_templates.message_mask_lang1  is 'Текст сообщения для языка RUS (LANG1)';
comment on column mlt_templates.message_mask_lang2  is 'Текст сообщения для языка UZC (LANG2)';
comment on column mlt_templates.message_mask_lang3  is 'Текст сообщения для языка UZL (LANG3)';
comment on column mlt_templates.message_mask_lang4  is 'Текст сообщения для языка ENG (LANG4)';
comment on column mlt_templates.message_mask_lang5  is 'Текст сообщения для языка KAR (LANG5)';
comment on column mlt_templates.message_mask_lang6  is 'Текст сообщения (определяется через mlt_languages)';
comment on column mlt_templates.message_mask_lang7  is 'Текст сообщения (определяется через mlt_languages)';
comment on column mlt_templates.message_mask_lang8  is 'Текст сообщения (определяется через mlt_languages)';
comment on column mlt_templates.message_mask_lang9  is 'Текст сообщения (определяется через mlt_languages)';
comment on column mlt_templates.message_mask_lang10 is 'Текст сообщения (определяется через mlt_languages)';


alter table mlt_templates add (
  modified_by  number(12),
  modified_on  date
);

comment on column mlt_templates.modified_by is 'O''zgartirgan foydalanuvchi ID';
comment on column mlt_templates.modified_on is 'O''zgartirilgan sana';
