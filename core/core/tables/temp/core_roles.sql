-- Create table
create table CORE.CORE_ROLES
(
  role_id          NUMBER(6) not null,
  name             VARCHAR2(200) not null,
  access_level_set NUMBER(6) not null,
  is_private       VARCHAR2(1) not null,
  state            VARCHAR2(1) not null,
  activate_date    DATE not null,
  deactivate_date  DATE not null,
  created_by       NUMBER(9) not null,
  created_on       DATE not null,
  modified_by      NUMBER(9) not null,
  modified_on      DATE not null,
  description      VARCHAR2(200)
)
tablespace CORE_DATA;
-- Add comments to the table 
comment on table CORE.CORE_ROLES                      is 'Справочник ролей';
-- Add comments to the columns 
comment on column CORE.CORE_ROLES.role_id             is 'Идентификационный номер роли (уникальный)';
comment on column CORE.CORE_ROLES.name                is 'Название роли';
comment on column CORE.CORE_ROLES.access_level_set    is 'Необходимый уровень доступа пользователя для доступа к данной роли';
comment on column CORE.CORE_ROLES.is_private          is 'Является ли роль собственным (невидимым) ролем пользователя (Y-Да, N-Нет)';
comment on column CORE.CORE_ROLES.state               is 'Состояние записи(A-Активный, P-Пассивный, S-Отложенный)';
comment on column CORE.CORE_ROLES.activate_date       is 'Дата активации записи';
comment on column CORE.CORE_ROLES.deactivate_date     is 'Дата деактивации записи';
comment on column CORE.CORE_ROLES.created_by          is 'Код пользователя, создавшего данный запись';
comment on column CORE.CORE_ROLES.created_on          is 'Дата и время создания записи';
comment on column CORE.CORE_ROLES.modified_by         is 'Код пользователя, выполнившего последнюю изменению записи';
comment on column CORE.CORE_ROLES.modified_on         is 'Дата и время последнего изменения записи';
comment on column CORE.CORE_ROLES.description         is 'Описание для пользователя';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CORE.CORE_ROLES add constraint CORE_ROLES_PK primary key (ROLE_ID) using index tablespace CORE_INDEX;
-- Create/Recreate check constraints 
alter table CORE.CORE_ROLES add constraint CORE_ROLES_C1 check (is_private in ('Y', 'N'));
alter table CORE.CORE_ROLES add constraint CORE_ROLES_C2 check (state in ('A', 'P', 'S'));
alter table CORE.CORE_ROLES add constraint CORE_ROLES_C3 check (activate_date=trunc(activate_date));
alter table CORE.CORE_ROLES add constraint CORE_ROLES_C4 check (deactivate_date=trunc(deactivate_date));
