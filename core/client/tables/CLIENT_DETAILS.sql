-- Create table
create table CLIENT_DETAILS
(
  client_code VARCHAR2(8) not null,
  detail_json CLOB,
  modify_on   DATE
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
alter table CLIENT_DETAILS
  add constraint CLIENT_DETAILS_PK primary key (CLIENT_CODE)
  using index
  tablespace CORE_DATA
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
