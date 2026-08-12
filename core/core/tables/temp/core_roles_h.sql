-- Create table
create table CORE.CORE_ROLES_H
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
  description      VARCHAR2(200),
  action           VARCHAR2(1) not null,
  action_date      DATE not null
)
tablespace CORE_DATA;
-- Add comments to the table 
comment on table CORE.CORE_ROLES_H                      is 'Справочник ролей';
-- Add comments to the columns 
comment on column CORE.CORE_ROLES_H.role_id             is 'Идентификационный номер роли (уникальный)';
comment on column CORE.CORE_ROLES_H.name                is 'Название роли';
comment on column CORE.CORE_ROLES_H.access_level_set    is 'Необходимый уровень доступа пользователя для доступа к данной роли';
comment on column CORE.CORE_ROLES_H.is_private          is 'Является ли роль собственным (невидимым) ролем пользователя (Y-Да, N-Нет)';
comment on column CORE.CORE_ROLES_H.state               is 'Состояние записи(A-Активный, P-Пассивный, S-Отложенный)';
comment on column CORE.CORE_ROLES_H.activate_date       is 'Дата активации записи';
comment on column CORE.CORE_ROLES_H.deactivate_date     is 'Дата деактивации записи';
comment on column CORE.CORE_ROLES_H.created_by          is 'Код пользователя, создавшего данный запись';
comment on column CORE.CORE_ROLES_H.created_on          is 'Дата и время создания записи';
comment on column CORE.CORE_ROLES_H.modified_by         is 'Код пользователя, выполнившего последнюю изменению записи';
comment on column CORE.CORE_ROLES_H.modified_on         is 'Дата и время последнего изменения записи';
comment on column CORE.CORE_ROLES_H.description         is 'Описание для пользователя';
comment on column CORE.CORE_ROLES_H.action              is 'Действие';
comment on column CORE.CORE_ROLES_H.action_date         is 'Дата действия';
-- Create/Recreate check constraints 
alter table CORE.CORE_ROLES_H add constraint CORE_ROLES_C1 check (state in ('I', 'U', 'D'));
