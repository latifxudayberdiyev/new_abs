-- Create table
create table SM_OBJECTS_H
(
  object_id          NUMBER(10),
  parent_object_id   NUMBER(10),
  object_code        VARCHAR2(100),
  state              VARCHAR2(50),
  relation_id        NUMBER(10),
  parent_relation_id NUMBER(10),
  created_on         DATE,
  created_by         NUMBER(8),
  modify_on          DATE,
  modify_by          NUMBER(8),
  action_note        VARCHAR2(500),
  action             VARCHAR2(1),
  local_code         VARCHAR2(5),
  is_deal            VARCHAR2(1)
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
create unique index SM_OBJECTS_H_U1 on SM_OBJECTS_H (OBJECT_ID, MODIFY_ON)
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
alter table SM_OBJECTS_H
  add constraint SM_OBJECTS_H_C2
  check (action in ('I', 'U', 'D'));
