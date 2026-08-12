-- Create table
create table ESBO_REQUESTS
(
  id            NUMBER(20) not null,
  request_id    VARCHAR2(100) not null,
  method_code   VARCHAR2(100) not null,
  request       CLOB not null,
  response      CLOB,
  response_code NUMBER(10),
  created_on    DATE,
  modify_on     DATE
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
create index ESBO_REQUESTS_I1 on ESBO_REQUESTS (METHOD_CODE)
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table ESBO_REQUESTS
  add constraint ESBO_REQUESTS_PK primary key (ID)
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
