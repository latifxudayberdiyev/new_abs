-- Create table
create table CORE.ABS_BRANCHES
(
  code            VARCHAR2(5) not null,
  cb_code         VARCHAR2(5) not null,
  code_type       NUMBER(2) not null,
  code_header     VARCHAR2(5),
  code_bank       VARCHAR2(5) not null,
  local_code      VARCHAR2(5) not null,
  filial_code     VARCHAR2(5) not null,
  branch_id       NUMBER(5) not null,
  name            VARCHAR2(200) not null,
  filial_number   VARCHAR2(12),
  condition       VARCHAR2(1) not null,
  date_activ      DATE not null,
  date_deact      DATE,
  code_district   VARCHAR2(3) not null,
  address         VARCHAR2(200),
  city            VARCHAR2(200),
  has_balance     VARCHAR2(1) not null,
  union_code      VARCHAR2(5) not null,
  date_open       DATE not null,
  region_code     VARCHAR2(2),
  branch_uid      NUMBER(12) not null,
  activate_date   DATE,
  deactivate_date DATE,
  last_sync       DATE not null
)
tablespace CORE_DATA;
-- Create/Recreate indexes 
create index CORE.ABS_BRANCHES_I1 on CORE.ABS_BRANCHES (CODE_BANK, CODE_TYPE, CONDITION) tablespace CORE_DATA;
create index CORE.ABS_BRANCHES_I2 on CORE.ABS_BRANCHES (CB_CODE, CODE) tablespace CORE_DATA;
-- Create/Recreate primary, unique and foreign key constraints 
alter table CORE.ABS_BRANCHES add constraint CORE_BRANCHES_PK primary key (CODE) using index tablespace CORE_DATA;
