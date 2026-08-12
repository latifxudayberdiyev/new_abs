-- Create table
create table SM_OBJECTS
(
  object_id          NUMBER(10) not null,
  parent_object_id   NUMBER(10),
  object_code        VARCHAR2(100) not null,
  state              VARCHAR2(50),
  relation_id        NUMBER(10) not null,
  parent_relation_id NUMBER(10),
  created_on         DATE not null,
  created_by         NUMBER(8) not null,
  modify_on          DATE not null,
  modify_by          NUMBER(8) not null,
  action_note        VARCHAR2(500),
  local_code         VARCHAR2(5),
  is_deal            VARCHAR2(1)
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
create index SM_OBJECTS_I1 on SM_OBJECTS (OBJECT_CODE, OBJECT_ID)
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
create unique index SM_OBJECTS_I2 on SM_OBJECTS (OBJECT_CODE, RELATION_ID)
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table SM_OBJECTS
  add constraint SM_OBJECTS_PK primary key (OBJECT_ID)
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
alter table SM_OBJECTS
  add constraint SM_OBJECTS_C1
  check (is_deal in ('Y', 'N'));
