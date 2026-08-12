-- Create table
create table SM_R_PROCEDURES
(
  procedure_code VARCHAR2(100) not null,
  procedure_name VARCHAR2(100) not null,
  state          VARCHAR2(1) not null
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
alter table SM_R_PROCEDURES
  add constraint SM_R_PROCEDURES_PK primary key (PROCEDURE_CODE)
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
alter table SM_R_PROCEDURES
  add constraint SM_R_PROCEDURES_C1
  check (state in ('A', 'P'));
