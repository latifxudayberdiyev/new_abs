-- Create table
create table SM_R_PROCESS_PARAM_REL
(
  process_code VARCHAR2(100) not null,
  param_key    VARCHAR2(100) not null,
  is_required  VARCHAR2(1) default 'Y' not null,
  state        VARCHAR2(1) default 'A' not null
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
alter table SM_R_PROCESS_PARAM_REL
  add constraint SM_R_PROCESS_PARAM_REL_PK primary key (PROCESS_CODE, PARAM_KEY)
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
alter table SM_R_PROCESS_PARAM_REL
  add constraint SM_R_PROCESS_PARAM_REL_C1
  check (state in ('A', 'P'));
