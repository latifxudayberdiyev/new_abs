-- Create table
create table SM_PROCESSES
(
  process_id   NUMBER(10) not null,
  object_id    NUMBER(10),
  process_code VARCHAR2(100) not null,
  created_on   DATE not null,
  created_by   NUMBER(8) not null,
  state_id     NUMBER(2)
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
create index SM_PROCESSES_I1 on SM_PROCESSES (OBJECT_ID, PROCESS_CODE)
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
alter table SM_PROCESSES
  add constraint SM_PROCESSES_PK primary key (PROCESS_ID)
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
