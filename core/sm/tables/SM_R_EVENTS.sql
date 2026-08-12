-- Create table
create table SM_R_EVENTS
(
  event_code     VARCHAR2(100) not null,
  state          VARCHAR2(1) not null,
  execution_mode VARCHAR2(10) default 'S' not null
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
alter table SM_R_EVENTS
  add constraint SM_R_EVENTS_PK primary key (EVENT_CODE)
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
-- Create/Recreate check constraints 
alter table SM_R_EVENTS
  add constraint SM_R_EVENTS_C1
  check (state in ('A', 'P'));
alter table SM_R_EVENTS
  add constraint SM_R_EVENTS_C2
  check (execution_mode in ('S', 'EBE', 'EH'));
