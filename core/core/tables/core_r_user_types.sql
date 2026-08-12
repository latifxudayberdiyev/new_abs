----------------------------------------------------------------------------------------------------
-- CORE_R_USER_TYPES - foydalanuvchi turlari reestri (Core_Users.User_Type_Id -> shu yerdagi CODE).
-- Ilgari core/views/core_r_user_types.sql'da "select ... from dual" ko'rinishidagi view edi -
-- UAPP'da faqat SELECT granti bor edi, shu sabab core/seed/seed_user_types.sql'dagi INSERT
-- ORA-01031 bilan qulagan edi. Endi haqiqiy jadval.
----------------------------------------------------------------------------------------------------
-- Create table
create table CORE.CORE_R_USER_TYPES
(
  code     NUMBER(3)    not null,
  name     VARCHAR2(30) not null,
  order_by NUMBER(3)    not null,
  state    VARCHAR2(1)  default 'A' not null
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;

-- Create/Recreate primary, unique and foreign key constraints
alter table CORE.CORE_R_USER_TYPES
  add constraint CORE_R_USER_TYPES_PK primary key (CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;

-- Create/Recreate check constraints
alter table CORE.CORE_R_USER_TYPES
  add constraint CORE_R_USER_TYPES_C1
  check (state in ('A', 'P'));

-- Seed data (CODE=1 => Core_Const.c_User_Type_Api bilan mos kelishi shart)
insert into CORE.CORE_R_USER_TYPES (code, name, order_by, state) values (0, 'MBP USER', 0, 'A');
insert into CORE.CORE_R_USER_TYPES (code, name, order_by, state) values (1, 'API USER', 1, 'A');
commit;
