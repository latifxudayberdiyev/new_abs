-- Create table
create table SM_R_OBJECT_STATES
(
  object_code VARCHAR2(100) not null,
  code        VARCHAR2(50) not null,
  description VARCHAR2(200)
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
alter table SM_R_OBJECT_STATES
  add constraint SM_R_OBJECT_STATES_PK primary key (CODE, OBJECT_CODE)
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
