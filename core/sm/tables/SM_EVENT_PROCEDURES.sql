-- Create table
create table SM_EVENT_PROCEDURES
(
  process_id     NUMBER(10) not null,
  event_code     VARCHAR2(100) not null,
  procedure_code VARCHAR2(100) not null,
  state_id       NUMBER(1) not null,
  order_by       NUMBER default 1 not null
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
create index SM_EVENT_PROCEDURES_U1 on SM_EVENT_PROCEDURES (PROCESS_ID, EVENT_CODE, PROCEDURE_CODE)
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
