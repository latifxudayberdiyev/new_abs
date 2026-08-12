-- Create table
create table SM_R_OBJECTS
(
  object_code        VARCHAR2(100) not null,
  parent_object_code VARCHAR2(100) not null,
  initial_state      VARCHAR2(50),
  sequence_getter    VARCHAR2(100),
  created_on         DATE not null,
  created_developer  VARCHAR2(200) not null,
  state              VARCHAR2(1) not null
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
alter table SM_R_OBJECTS
  add constraint SM_R_OBJECTS_PK primary key (OBJECT_CODE, PARENT_OBJECT_CODE)
  using index 
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
alter table SM_R_OBJECTS
  add constraint SM_R_OBJECTS_C1
  check (state in ('A', 'P'));
