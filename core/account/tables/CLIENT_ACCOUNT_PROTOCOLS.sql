-- Create table
create table CLIENT_ACCOUNT_PROTOCOLS
(
  code             VARCHAR2(30),
  operator_code    NUMBER(9),
  operator_name    VARCHAR2(4000),
  date_validate    DATE,
  date_modify      VARCHAR2(19),
  error_message    VARCHAR2(2000),
  what_changed     VARCHAR2(2000),
  parent_task_code NUMBER(6),
  parent_task_name VARCHAR2(4000),
  action_code      NUMBER(6),
  action_name      VARCHAR2(4000),
  change_sign      VARCHAR2(1),
  change_sign_name VARCHAR2(14)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes 
create index CLIENT_ACCOUNT_PROTOCOLS_I1 on CLIENT_ACCOUNT_PROTOCOLS (CODE)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
