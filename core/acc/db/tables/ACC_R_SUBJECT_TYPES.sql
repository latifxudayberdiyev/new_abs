-- Create table
create table ACC_R_SUBJECT_TYPES
(
  code VARCHAR2(5),
  name VARCHAR2(20)
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
