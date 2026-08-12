-- Create table
create table SM_PROCESS_PROTOCOLS
(
  process_id     NUMBER(10) not null,
  event_code     VARCHAR2(100) not null,
  procedure_code VARCHAR2(100) not null,
  err_code       NUMBER,
  err_msg        VARCHAR2(4000),
  ora_err_msg    VARCHAR2(4000),
  create_on      DATE not null
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
create index SM_PROCESS_PROTOCOLS_I1 on SM_PROCESS_PROTOCOLS (PROCESS_ID, EVENT_CODE, PROCEDURE_CODE)
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
