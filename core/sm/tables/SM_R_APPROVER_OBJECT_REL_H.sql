-- Create table
create table SM_R_APPROVER_OBJECT_REL_H
(
  user_id     NUMBER(8),
  object_code VARCHAR2(100),
  state       VARCHAR2(1),
  created_on  DATE,
  created_by  NUMBER(10),
  modify_on   DATE,
  modify_by   NUMBER(8),
  action_code VARCHAR2(1)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes 
create index SM_R_APPROVER_OBJECT_REL_H_U1 on SM_R_APPROVER_OBJECT_REL_H (USER_ID, OBJECT_CODE, MODIFY_ON)
  tablespace CORE_index
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate check constraints 
alter table SM_R_APPROVER_OBJECT_REL_H
  add constraint SM_R_APPROVER_OBJECT_REL_H_C1
  check (state in ('A', 'P'));
