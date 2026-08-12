-- Create table
create table SM_R_TRANZITIONS
(
  object_code        VARCHAR2(100) not null,
  process_code       VARCHAR2(100) not null,
  current_state      VARCHAR2(50) not null,
  organization_level VARCHAR2(3),
  new_state          VARCHAR2(50) not null,
  is_approve         VARCHAR2(1) default 'N' not null
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
alter table SM_R_TRANZITIONS
  add constraint SM_R_TRANZITIONS_PK primary key (OBJECT_CODE, PROCESS_CODE, CURRENT_STATE, NEW_STATE)
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
alter table SM_R_TRANZITIONS
  add constraint SM_R_TRANZITIONS_FK1 foreign key (PROCESS_CODE)
  references SM_R_PROCESSES (PROCESS_CODE);
