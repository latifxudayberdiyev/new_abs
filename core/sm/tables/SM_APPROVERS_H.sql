-- Create table
create table SM_APPROVERS_H
(
  user_id    NUMBER(8) not null,
  name       VARCHAR2(100),
  created_on DATE,
  created_by NUMBER(8),
  modify_on  DATE,
  modify_by  NUMBER(8),
  state      VARCHAR2(1),
  org_level  VARCHAR2(1),
  action     VARCHAR2(1)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes 
create unique index SM_APPROVERS_H_U1 on SM_APPROVERS_H (USER_ID, MODIFY_ON)
  tablespace CORE_index
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate check constraints 
alter table SM_APPROVERS_H
  add constraint SM_APPROVERS_H_C1
  check (state in ('A', 'P'));
alter table SM_APPROVERS_H
  add constraint SM_APPROVERS_H_C2
  check (state in ('I', 'U', 'D'));
