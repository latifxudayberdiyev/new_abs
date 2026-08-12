-- Create table
create table PROCESS_PROTOCOL
(
  id         NUMBER(10) not null,
  proc_name  VARCHAR2(50),
  error_code NUMBER(5),
  error_msg  VARCHAR2(1000),
  raise_time DATE default SysDate
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
create index XPROCESS_PROTOCOL on PROCESS_PROTOCOL (RAISE_TIME)
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
alter table PROCESS_PROTOCOL
  add constraint XPKPROCESS_PROTOCOL primary key (ID)
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
