-- Create table
create table ESBO_SERVICE_SETTINGS
(
  service_code VARCHAR2(50) not null,
  param_code   VARCHAR2(50) not null,
  param_value  VARCHAR2(200),
  description  VARCHAR2(300),
  created_on   DATE
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
alter table ESBO_SERVICE_SETTINGS
  add constraint ESBO_SERVICE_SETTINGS_PK primary key (SERVICE_CODE, PARAM_CODE)
  using index
  tablespace CORE_INDEX
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
