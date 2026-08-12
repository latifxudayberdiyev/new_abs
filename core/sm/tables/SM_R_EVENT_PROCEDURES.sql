-- Create table
create table SM_R_EVENT_PROCEDURES
(
  event_code     VARCHAR2(100) not null,
  procedure_code VARCHAR2(100) not null,
  order_by       NUMBER(1),
  state          VARCHAR2(1)
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
alter table SM_R_EVENT_PROCEDURES
  add constraint SM_R_EVENT_PROCEDURES_PK primary key (EVENT_CODE, PROCEDURE_CODE)
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
alter table SM_R_EVENT_PROCEDURES
  add constraint SM_R_EVENT_PROCEDURES_FK1 foreign key (EVENT_CODE)
  references SM_R_EVENTS (EVENT_CODE);
alter table SM_R_EVENT_PROCEDURES
  add constraint SM_R_EVENT_PROCEDURES_FK2 foreign key (PROCEDURE_CODE)
  references SM_R_PROCEDURES (PROCEDURE_CODE);
-- Create/Recreate check constraints 
alter table SM_R_EVENT_PROCEDURES
  add constraint SM_R_EVENT_PROCEDURES_C1
  check (state in ('A', 'P'));
