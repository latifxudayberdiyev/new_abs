-- Create table
create table MLT_TEMPLATES
(
  template_id          NUMBER(12) default "CORE"."MLT_TEMPLATES_SEQ"."NEXTVAL" not null,
  message_code         VARCHAR2(100) not null,
  description          VARCHAR2(1000 CHAR) not null,
  param_count          NUMBER(2) not null,
  format_string        VARCHAR2(1) not null,
  message_mask_lang1   VARCHAR2(1000 CHAR) not null,
  message_mask_lang2   VARCHAR2(1000 CHAR),
  message_mask_lang3   NVARCHAR2(1000),
  message_mask_lang4   NVARCHAR2(1000),
  message_mask_lang5   VARCHAR2(1000 CHAR),
  message_mask_lang6   VARCHAR2(1000 CHAR),
  message_mask_lang7   VARCHAR2(1000 CHAR),
  message_mask_lang8   VARCHAR2(1000 CHAR),
  message_mask_lang9   VARCHAR2(1000 CHAR),
  message_mask_lang10  VARCHAR2(1000 CHAR),
  modified_by          NUMBER(12),
  modified_on          DATE,
  t_message_mask_lang1 NVARCHAR2(1000),
  t_message_mask_lang4 NVARCHAR2(1000),
  t_message_mask_lang3 NVARCHAR2(1000)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table MLT_TEMPLATES
  is 'Таблица шаблонов сообщений с поддержкой нескольких языков (MLT)';
-- Add comments to the columns 
comment on column MLT_TEMPLATES.template_id
  is 'Уникальный идентификатор шаблона';
comment on column MLT_TEMPLATES.message_code
  is 'Код сообщения';
comment on column MLT_TEMPLATES.description
  is 'Описание шаблона сообщения';
comment on column MLT_TEMPLATES.param_count
  is 'Количество параметров в шаблоне (например $1, {2} и т.д.)';
comment on column MLT_TEMPLATES.format_string
  is 'Символ формата (например $, #,@ и т.д.)';
comment on column MLT_TEMPLATES.message_mask_lang1
  is 'Текст сообщения для языка RUS (LANG1)';
comment on column MLT_TEMPLATES.message_mask_lang2
  is 'Текст сообщения для языка UZC (LANG2)';
comment on column MLT_TEMPLATES.message_mask_lang3
  is 'Текст сообщения для языка UZL (LANG3)';
comment on column MLT_TEMPLATES.message_mask_lang4
  is 'Текст сообщения для языка ENG (LANG4)';
comment on column MLT_TEMPLATES.message_mask_lang5
  is 'Текст сообщения для языка KAR (LANG5)';
comment on column MLT_TEMPLATES.message_mask_lang6
  is 'Текст сообщения (определяется через mlt_languages)';
comment on column MLT_TEMPLATES.message_mask_lang7
  is 'Текст сообщения (определяется через mlt_languages)';
comment on column MLT_TEMPLATES.message_mask_lang8
  is 'Текст сообщения (определяется через mlt_languages)';
comment on column MLT_TEMPLATES.message_mask_lang9
  is 'Текст сообщения (определяется через mlt_languages)';
comment on column MLT_TEMPLATES.message_mask_lang10
  is 'Текст сообщения (определяется через mlt_languages)';
comment on column MLT_TEMPLATES.modified_by
  is 'O''zgartirgan foydalanuvchi ID';
comment on column MLT_TEMPLATES.modified_on
  is 'O''zgartirilgan sana';
-- Create/Recreate primary, unique and foreign key constraints 
alter table MLT_TEMPLATES
  add constraint MLT_TEMPLATES_PK primary key (TEMPLATE_ID)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
alter table MLT_TEMPLATES
  add constraint MLT_TEMPLATES_U1 unique (MESSAGE_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Grant/Revoke object privileges 
grant select on MLT_TEMPLATES to UAPP;
