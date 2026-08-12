-- Create table
create table SM_ACTION_ROLE_REL
(
  role_id     NUMBER(5) not null,
  action_id   NUMBER(2) not null,
  object_code VARCHAR2(100) not null,
  step        NUMBER(2) not null,
  created_on  DATE not null,
  created_by  NUMBER(8) not null,
  modify_on   DATE not null,
  modify_by   NUMBER(8) not null
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
alter table SM_ACTION_ROLE_REL
  add constraint SM_ACTION_ROLE_REL_PK primary key (ROLE_ID, ACTION_ID, OBJECT_CODE)
  using index 
  tablespace CORE_DATA
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
