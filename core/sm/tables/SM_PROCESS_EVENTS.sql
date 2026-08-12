-- Create table
create table SM_PROCESS_EVENTS
(
  process_id           NUMBER(10) not null,
  event_code           VARCHAR2(100) not null,
  execution_mode       VARCHAR2(10) default 'S' not null,
  in_json_clob         CLOB,
  out_json_clob        CLOB,
  state_id             NUMBER default 0 not null,
  order_by             NUMBER default 1 not null,
  object_t_json        CLOB,
  hold_check_procedure VARCHAR2(100)
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
create index SM_PROCESS_EVENTS_I1 on SM_PROCESS_EVENTS (PROCESS_ID, EVENT_CODE)
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
create index SM_PROCESS_EVENTS_I2 on SM_PROCESS_EVENTS (PROCESS_ID, STATE_ID, ORDER_BY)
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
