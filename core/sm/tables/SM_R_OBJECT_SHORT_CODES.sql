-- Create table
create table SM_R_OBJECT_SHORT_CODES
(
  object_code VARCHAR2(50) not null,
  short_code  VARCHAR2(5) not null
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
create unique index SM_R_OBJECT_SHORT_CODES_U1 on SM_R_OBJECT_SHORT_CODES (OBJECT_CODE)
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
create unique index SM_R_OBJECT_SHORT_CODES_U2 on SM_R_OBJECT_SHORT_CODES (SHORT_CODE)
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
