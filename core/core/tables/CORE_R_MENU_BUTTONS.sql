-- Create table
create table CORE_R_MENU_BUTTONS
(
  module_code        VARCHAR2(100) not null,
  menu_id            NUMBER(10) not null,
  button_id          NUMBER(10) not null,
  action_code        VARCHAR2(200) not null,
  name_mll_code      VARCHAR2(100) not null,
  order_by           NUMBER(3) not null,
  state              VARCHAR2(1) default 'A' not null,
  button_type        VARCHAR2(10),
  button_menu_id     NUMBER(10),
  process_code       VARCHAR2(100),
  model_process_code VARCHAR2(100),
  created_by         NUMBER(10) not null,
  created_on         DATE not null,
  modify_by          NUMBER(10) not null,
  modify_on          DATE not null
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
-- Add comments to the columns 
comment on column CORE_R_MENU_BUTTONS.action_code
  is 'REL_MENU button yana menu ochishini anglatadi';
-- Create/Recreate indexes 
create index CORE_R_MENU_BUTTONS_I1 on CORE_R_MENU_BUTTONS (MODULE_CODE, MENU_ID)
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
create index CORE_R_MENU_BUTTONS_I2 on CORE_R_MENU_BUTTONS (PROCESS_CODE)
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
create index CORE_R_MENU_BUTTONS_I3 on CORE_R_MENU_BUTTONS (MODEL_PROCESS_CODE)
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table CORE_R_MENU_BUTTONS
  add constraint CORE_R_MENU_BUTTONS_PK primary key (MENU_ID, BUTTON_ID)
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
alter table CORE_R_MENU_BUTTONS
  add constraint CORE_R_MENU_BUTTONS_FK1 foreign key (PROCESS_CODE)
  references SM_R_PROCESSES (PROCESS_CODE);
alter table CORE_R_MENU_BUTTONS
  add constraint CORE_R_MENU_BUTTONS_FK2 foreign key (MODEL_PROCESS_CODE)
  references SM_R_PROCESSES (PROCESS_CODE);
-- Create/Recreate check constraints 
alter table CORE_R_MENU_BUTTONS
  add constraint CORE_R_MENU_BUTTONS_C1
  check (state in ('A', 'P'));
