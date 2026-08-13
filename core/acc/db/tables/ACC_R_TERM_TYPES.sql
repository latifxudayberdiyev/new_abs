-- Create table
create table ACC_R_TERM_TYPES
(
  code VARCHAR2(10),
  name VARCHAR2(10)
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
