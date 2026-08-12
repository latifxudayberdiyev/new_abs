-- Create table
create table ESBO_R_METHODS
(
  service_code VARCHAR2(500) not null,
  method_code  VARCHAR2(100) not null,
  name         VARCHAR2(1000) not null,
  url          VARCHAR2(100) not null,
  timeout      NUMBER(10) not null,
  request_type VARCHAR2(10) not null,
  state        VARCHAR2(2) not null,
  created_on   DATE default sysdate not null,
  add_log      VARCHAR2(2) default 'Y'
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
alter table ESBO_R_METHODS
  add constraint ESBO_R_METHODS primary key (SERVICE_CODE, METHOD_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
