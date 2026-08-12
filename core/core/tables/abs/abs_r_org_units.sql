-- Create table
create table CORE.ABS_R_ORG_UNITS
(
  org_unit_id      NUMBER(6) not null,
  org_unit_name    VARCHAR2(50) not null,
  label            VARCHAR2(200) not null,
  org_unit_level   NUMBER(4) not null,
  access_level_set NUMBER(6) not null,
  state            VARCHAR2(1) not null,
  activate_date    DATE not null,
  deactivate_date  DATE not null,
  description      VARCHAR2(200),
  type_filial      VARCHAR2(1) not null,
  last_sync        DATE not null
) tablespace CORE_DATA;
-- Add comments to the table 
comment on table CORE.ABS_R_ORG_UNITS                       is 'Справочник подразделений банка';
-- Add comments to the columns 
comment on column CORE.ABS_R_ORG_UNITS.org_unit_id          is 'Код подразделения (уникальный)';
comment on column CORE.ABS_R_ORG_UNITS.org_unit_name        is 'Символьное обозначение типа подразделения (распознаваемое приложениями)';
comment on column CORE.ABS_R_ORG_UNITS.label                is 'Название подразделения';
comment on column CORE.ABS_R_ORG_UNITS.org_unit_level       is 'Уровень подразделения в иерархии организации';
comment on column CORE.ABS_R_ORG_UNITS.access_level_set     is 'Битовая карта разрешенных уровней доступа для пользователей данного подразделения';
comment on column CORE.ABS_R_ORG_UNITS.state                is 'Состояние записи (A-Активный, P-Пассивный, S-Отложенный)';
comment on column CORE.ABS_R_ORG_UNITS.activate_date        is 'Дата активации записи';
comment on column CORE.ABS_R_ORG_UNITS.deactivate_date      is 'Дата деактивации записи';
comment on column CORE.ABS_R_ORG_UNITS.description          is 'Описание для пользователя';
comment on column CORE.ABS_R_ORG_UNITS.last_sync            is 'Последная дата обновления';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CORE.ABS_R_ORG_UNITS add constraint ABS_R_ORG_UNITS_PK primary key (ORG_UNIT_ID) using index tablespace CORE_INDEX;
