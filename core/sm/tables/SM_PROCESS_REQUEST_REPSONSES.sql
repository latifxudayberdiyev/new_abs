-- Create table
create table SM_PROCESS_REQUEST_REPSONSES
(
  object_id    NUMBER(10),
  process_id   NUMBER(10),
  request      CLOB,
  response     CLOB,
  object_code  VARCHAR2(100),
  created_on   DATE,
  created_by   NUMBER(8),
  process_code VARCHAR2(100),
  event_code   VARCHAR2(100)
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
create index SM_PROCESS_REQUEST_REPSONSES_I1 on SM_PROCESS_REQUEST_REPSONSES (OBJECT_ID, OBJECT_CODE)
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
create index SM_PROCESS_REQUEST_REPSONSES_I2 on SM_PROCESS_REQUEST_REPSONSES (PROCESS_ID, PROCESS_CODE)
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
