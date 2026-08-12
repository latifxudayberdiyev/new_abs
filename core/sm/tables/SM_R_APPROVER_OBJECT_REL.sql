-- Create table
create table SM_R_APPROVER_OBJECT_REL
(
  user_id     NUMBER(8),
  object_code VARCHAR2(100),
  state       VARCHAR2(1),
  created_on  DATE,
  created_by  NUMBER(10),
  modify_on   DATE,
  modify_by   NUMBER(8)
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
create unique index SM_R_APPROVER_OBJECT_REL_U1 on SM_R_APPROVER_OBJECT_REL (USER_ID, OBJECT_CODE)
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
alter table SM_R_APPROVER_OBJECT_REL
  add constraint SM_R_APPROVER_OBJECT_REL_C1
  check (state in ('A', 'P'));
