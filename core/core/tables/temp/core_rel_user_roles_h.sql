-- Create table
create table CORE.CORE_REL_USER_ROLES_H
(
  user_id         NUMBER(9) not null,
  role_id         NUMBER(6) not null,
  state           VARCHAR2(1) not null,
  activate_date   DATE not null,
  deactivate_date DATE,
  created_by      NUMBER(9) not null,
  created_on      DATE not null,
  modified_by     NUMBER(9) not null,
  modified_on     DATE not null,
  action          VARCHAR2(1) not null,
  action_date     DATE not null
)
tablespace CORE_DATA;
-- Add comments to the columns 
comment on column CORE.CORE_REL_USER_ROLES_H.user_id          is 'ID ползователя';
comment on column CORE.CORE_REL_USER_ROLES_H.role_id          is 'ID роле';
comment on column CORE.CORE_REL_USER_ROLES_H.state            is 'Состояние записи(A-Активный, P-Пассивный, S-Отложенный)';
comment on column CORE.CORE_REL_USER_ROLES_H.activate_date    is 'Дата активации записи';
comment on column CORE.CORE_REL_USER_ROLES_H.deactivate_date  is 'Дата деактивации записи';
comment on column CORE.CORE_REL_USER_ROLES_H.created_by       is 'Код пользователя, создавшего данный запись';
comment on column CORE.CORE_REL_USER_ROLES_H.created_on       is 'Дата и время создания записи';
comment on column CORE.CORE_REL_USER_ROLES_H.modified_by      is 'Код пользователя, выполнившего последнюю изменению записи';
comment on column CORE.CORE_REL_USER_ROLES_H.modified_on      is 'Дата и время последнего изменения записи';
comment on column CORE.CORE_REL_USER_ROLES_H.action           is 'Действие';
comment on column CORE.CORE_REL_USER_ROLES_H.action_date      is 'Дата действия';
-- Create/Recreate check constraints 
alter table CORE.CORE_REL_USER_ROLES_H add constraint CORE_REL_USER_ROLES_H_C1 check (action in ('I', 'U', 'D'));
