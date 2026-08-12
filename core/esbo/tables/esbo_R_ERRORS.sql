-- Create table
create table ESBO_R_ERRORS
(
  code      NUMBER(20) not null,
  uz        VARCHAR2(1000),
  ru        VARCHAR2(1000),
  en        VARCHAR2(1000),
  module_id NUMBER(20) not null,
  author    NUMBER(20) not null,
  cr_on     DATE default sysdate
)
tablespace core_data
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
-- Add comments to the table 
comment on table ESBO_R_ERRORS
  is 'System errors reference';
-- Create/Recreate primary, unique and foreign key constraints 
alter table ESBO_R_ERRORS
  add constraint ESBO_R_ERRORS_PK primary key (CODE)
  using index
  tablespace core_index
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
