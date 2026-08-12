-- Create table
create table SQL_DEBUG
(
  id          NUMBER(12) not null,
  user_key    VARCHAR2(50) not null,
  text        VARCHAR2(4000),
  request     HASHTABLE,
  test_sql    VARCHAR2(4000),
  rec_sql     VARCHAR2(4000),
  rec_form    VARCHAR2(4000),
  call_stack  VARCHAR2(4000),
  error_stack VARCHAR2(4000),
  created_on  DATE
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
create index SQL_DEBUG_I1 on SQL_DEBUG (USER_KEY)
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
alter table SQL_DEBUG
  add constraint SQL_DEBUG_PK primary key (ID)
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
