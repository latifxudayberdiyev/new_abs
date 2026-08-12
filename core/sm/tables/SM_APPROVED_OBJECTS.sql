-- Create table
create table SM_APPROVED_OBJECTS
(
  user_id            NUMBER(8) not null,
  object_code        VARCHAR2(100) not null,
  object_id          NUMBER(10) not null,
  object_state       VARCHAR2(50),
  min_approver_count NUMBER(4),
  created_on         DATE not null,
  modify_on          DATE not null,
  state              VARCHAR2(1) not null,
  created_by         NUMBER(8) not null
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
-- Create/Recreate indexes 
create unique index SM_APPROVED_OBJECTS_U1 on SM_APPROVED_OBJECTS (USER_ID, OBJECT_ID, OBJECT_CODE)
  tablespace CORE_index
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
alter table SM_APPROVED_OBJECTS
  add constraint SM_APPROVED_OBJECTS_C1
  check (state in ('A', 'P', 'R'));
