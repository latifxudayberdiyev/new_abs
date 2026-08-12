-- Create table
create table ADM_REL_USER_BUTTONS
(
  user_id         NUMBER(10) not null,
  button_id       NUMBER(10) not null,
  menu_id         NUMBER(10) not null,
  date_activate   DATE not null,
  date_deactivate DATE not null,
  state           VARCHAR2(1) not null,
  created_by      NUMBER(10) not null,
  created_on      DATE not null,
  modify_by       NUMBER(10) not null,
  modify_on       DATE not null
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table ADM_REL_USER_BUTTONS
  add constraint ADM_REL_USER_BUTTONS_PK primary key (USER_ID, BUTTON_ID, MENU_ID)
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
-- Create/Recreate check constraints 
alter table ADM_REL_USER_BUTTONS
  add constraint ADM_REL_USER_BUTTONS_C1
  check (state in ('A', 'P'));
