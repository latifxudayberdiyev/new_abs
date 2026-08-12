-- Create table
create table TRANSACTS
(
  operation_id    NUMBER(12),
  lead_id NUMBER(12),
  abs_lead_id     NUMBER(12),
  abs_document_id NUMBER(12),
  order_number    NUMBER(2),
  account_id      NUMBER(12),
  currency_code   VARCHAR2(3),
  dc_type         VARCHAR2(1),
  state_id        NUMBER(3),
  oper_day        DATE,
  calendar_day    DATE,
  object_id       NUMBER(12),
  object_code     VARCHAR2(100),
  local_code      VARCHAR2(5),
  saldo_in        NUMBER(20),
  income          NUMBER(20),
  expense         NUMBER(20),
  saldo_out       NUMBER(20),
  eqv_saldo_in    NUMBER(20),
  eqv_saldo_out   NUMBER(20),
  income_all      NUMBER(20),
  expense_all     NUMBER(20),
  eqv_income_all  NUMBER(20),
  eqv_expense_all NUMBER(20)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes 
create index TRANSACTS_I1 on TRANSACTS (ABS_LEAD_ID)
  tablespace CORE_index
  pctfree 10
  initrans 2
  maxtrans 255;
create index TRANSACTS_I2 on TRANSACTS (OBJECT_ID, OBJECT_CODE)
  tablespace CORE_index
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index TRANSACTS_U1 on TRANSACTS (OPERATION_ID, ACCOUNT_ID)
  tablespace CORE_index
  pctfree 10
  initrans 2
  maxtrans 255;
