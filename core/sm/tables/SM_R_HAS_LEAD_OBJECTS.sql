-- Create table
create table SM_R_HAS_LEAD_OBJECTS
(
  object_code VARCHAR2(100) not null
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
alter table SM_R_HAS_LEAD_OBJECTS
  add constraint SM_R_HAS_LEAD_OBJECTS_PK primary key (OBJECT_CODE)
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
