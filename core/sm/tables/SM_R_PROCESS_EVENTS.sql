-- Create table
create table SM_R_PROCESS_EVENTS
(
  process_code         VARCHAR2(100) not null,
  event_code           VARCHAR2(100) not null,
  order_by             NUMBER(1) not null,
  state                VARCHAR2(1) not null,
  execution_mode       VARCHAR2(10) default 'S' not null,
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
-- Create/Recreate primary, unique and foreign key constraints 
alter table SM_R_PROCESS_EVENTS
  add constraint SM_R_PROCESS_EVENTS_PK primary key (PROCESS_CODE, EVENT_CODE)
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
alter table SM_R_PROCESS_EVENTS
  add constraint SM_R_PROCESS_EVENTS_FK2 foreign key (EVENT_CODE)
  references SM_R_EVENTS (EVENT_CODE);
-- Create/Recreate check constraints 
alter table SM_R_PROCESS_EVENTS
  add constraint SM_R_PROCEDURE_EVENTS_C1
  check (state in ('A', 'P'));
