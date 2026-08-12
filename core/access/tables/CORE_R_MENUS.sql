-- Create table
create table CORE_R_MENUS
(
  module_code    VARCHAR2(100) not null,
  menu_id        NUMBER(10) not null,
  parent_menu_id VARCHAR2(10) not null,
  name_mll_code  VARCHAR2(100) not null,
  page_url       VARCHAR2(1000),
  order_by       NUMBER(3) not null,
  state          VARCHAR2(1) default 'A' not null,
  menu_type      VARCHAR2(20)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints 
alter table CORE_R_MENUS
  add constraint CORE_R_MENUS_PK primary key (MODULE_CODE, MENU_ID)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
