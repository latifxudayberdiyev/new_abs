-- Create table
create table SM_APPROVERS
(
  user_id    NUMBER(8) not null,
  name       VARCHAR2(100),
  created_on DATE,
  created_by NUMBER(8),
  modify_on  DATE,
  modify_by  NUMBER(8),
  state      VARCHAR2(1),
  org_level  VARCHAR2(1)
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
alter table SM_APPROVERS
  add constraint SM_APPROVERS_PK primary key (USER_ID)
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
alter table SM_APPROVERS
  add constraint SM_APPROVERS_C1
  check (state in ('A', 'P'));
