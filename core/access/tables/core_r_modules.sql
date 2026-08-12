-- Create table
create table CORE_R_MODULES
(
  module_code         VARCHAR2(100) not null,
  module_id           NUMBER(10) not null,
  parent_module_id    NUMBER(10) not null,
  name_mll_code       VARCHAR2(100) not null,
  short_name_mll_code VARCHAR2(100) not null,
  iabs_task_code      VARCHAR2(100),
  page_url            VARCHAR2(1000),
  order_by            NUMBER(3) not null,
  module_menu_type    VARCHAR2(20),
  state               VARCHAR2(1) default 'A' not null
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes 
create unique index CORE_R_MODULES_U1 on CORE_R_MODULES (MODULE_ID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints 
alter table CORE_R_MODULES
  add constraint CORE_R_MODULES_PK primary key (MODULE_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
