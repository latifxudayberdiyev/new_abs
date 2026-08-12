-- Foydalanuvchi <-> local_code (filial) dostup grantlari. ADM_REL_USER_MENUS/
-- ADM_REL_USER_BUTTONS bilan bir xil konvensiya (PK, date_activate/deactivate,
-- state, audit ustunlari) - Core_Locals.pck shundan o'qiydi (Has_Local_Access/
-- Assert_Local_Access). Boshqarish (admin UI) hali alohida ko'rib chiqiladi -
-- hozircha faqat DDL.
create table ADM_REL_USER_LOCALS
(
  user_id         NUMBER(10) not null,
  local_code      VARCHAR2(5) not null,
  date_activate   DATE not null,
  date_deactivate DATE not null,
  state           VARCHAR2(1) not null,
  created_by      NUMBER(10) not null,
  created_on      DATE not null,
  modify_by       NUMBER(10) not null,
  modify_on       DATE not null
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints
alter table ADM_REL_USER_LOCALS
  add constraint ADM_REL_USER_LOCALS_PK primary key (USER_ID, LOCAL_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate check constraints
alter table ADM_REL_USER_LOCALS
  add constraint ADM_REL_USER_LOCALS_C1
  check (state in ('A', 'P'));
