-- Create table
create table CORE_REL_USER_MENUS_H
(
  user_id         NUMBER(10) not null,
  menu_id         NUMBER(10) not null,
  date_activate   DATE not null,
  date_deactivate DATE not null,
  state           VARCHAR2(1) not null,
  created_by      NUMBER(10) not null,
  created_on      DATE not null,
  modify_by       NUMBER(10) not null,
  modify_on       DATE not null,
  dml_action      VARCHAR2(1)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate check constraints 
alter table CORE_REL_USER_MENUS_H
  add constraint CORE_REL_USER_MENUS_H_C1
  check (DML_ACTION in ('I', 'U', 'D'));
