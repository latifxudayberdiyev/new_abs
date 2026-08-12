-- Create table
create table SM_R_PROCESSES
(
  process_code        VARCHAR2(100) not null,
  object_code         VARCHAR2(100) not null,
  parent_object_code  VARCHAR2(100),
  state               VARCHAR2(1),
  relation_key        VARCHAR2(100),
  parent_relation_key VARCHAR2(100),
  created_on          DATE not null,
  created_developer   VARCHAR2(200) not null,
  set_log             VARCHAR2(1) default 'Y' not null,
  new_object_state    VARCHAR2(50),
  process_type        VARCHAR2(10) not null,
  before_process_code VARCHAR2(100),
  after_process_code  VARCHAR2(100),
  description         VARCHAR2(200),
  is_deal             VARCHAR2(1)
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
alter table SM_R_PROCESSES
  add constraint SM_R_PROCESSES_PK primary key (PROCESS_CODE)
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
alter table SM_R_PROCESSES
  add constraint SM_R_PROCESSES_FK1 foreign key (OBJECT_CODE, PARENT_OBJECT_CODE)
  references SM_R_OBJECTS (OBJECT_CODE, PARENT_OBJECT_CODE);
-- Create/Recreate check constraints
alter table SM_R_PROCESSES
  add constraint SM_R_PROCESSES_C1
  check (state in ('A', 'P'));
alter table SM_R_PROCESSES
  add constraint SM_R_PROCESSES_C2
  check (is_deal in ('Y', 'N'));
