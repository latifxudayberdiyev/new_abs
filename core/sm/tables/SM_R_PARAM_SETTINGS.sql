-- Create table
create table SM_R_PARAM_SETTINGS
(
  param_key            VARCHAR2(100) not null,
  parent_param_key     VARCHAR2(100),
  param_type           VARCHAR2(100),
  param_check_function VARCHAR2(100),
  min_length           NUMBER(4) default 1,
  max_length           NUMBER(4)
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
alter table SM_R_PARAM_SETTINGS
  add constraint SM_R_PARAM_SETTINGS_PK primary key (PARAM_KEY)
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
