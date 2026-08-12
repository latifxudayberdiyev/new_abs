-- Create table
create table SM_ACTION_ROLE_REL_H
(
  role_id     NUMBER(5) not null,
  action_id   NUMBER(2) not null,
  object_code VARCHAR2(100) not null,
  step        NUMBER(2) not null,
  created_on  DATE not null,
  created_by  NUMBER(8) not null,
  modify_on   DATE not null,
  modify_by   NUMBER(8) not null,
  action      VARCHAR2(1) not null
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
