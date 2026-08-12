-- Create table
create table SM_OBJECT_ACTION_CONTROLS
(
  object_id     NUMBER(10) not null,
  object_code   VARCHAR2(100) not null,
  cur_action_id NUMBER(2) not null,
  cur_step      NUMBER(2) not null,
  created_on    DATE not null,
  created_by    NUMBER(8) not null,
  modify_on     DATE not null,
  modify_by     NUMBER(8) not null,
  state         VARCHAR2(1) default 'P' not null
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
alter table SM_OBJECT_ACTION_CONTROLS
  add constraint SM_OBJECT_ACTION_CONTROLS primary key (OBJECT_ID, OBJECT_CODE)
  using index 
  tablespace CORE_DATA
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
