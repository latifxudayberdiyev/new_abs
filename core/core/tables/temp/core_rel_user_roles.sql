-- Create table
create table CORE.CORE_REL_USER_ROLES
(
  user_id         NUMBER(9) not null,
  role_id         NUMBER(6) not null,
  state           VARCHAR2(1) not null,
  activate_date   DATE not null,
  deactivate_date DATE,
  created_by      NUMBER(9) not null,
  created_on      DATE not null,
  modified_by     NUMBER(9) not null,
  modified_on     DATE not null
)
tablespace CORE_DATA;
-- Add comments to the columns 
comment on column CORE.CORE_REL_USER_ROLES.user_id          is 'ID ползователя';
comment on column CORE.CORE_REL_USER_ROLES.role_id          is 'ID роле';
comment on column CORE.CORE_REL_USER_ROLES.state            is 'Состояние записи(A-Активный, P-Пассивный, S-Отложенный)';
comment on column CORE.CORE_REL_USER_ROLES.activate_date    is 'Дата активации записи';
comment on column CORE.CORE_REL_USER_ROLES.deactivate_date  is 'Дата деактивации записи';
comment on column CORE.CORE_REL_USER_ROLES.created_by       is 'Код пользователя, создавшего данный запись';
comment on column CORE.CORE_REL_USER_ROLES.created_on       is 'Дата и время создания записи';
comment on column CORE.CORE_REL_USER_ROLES.modified_by      is 'Код пользователя, выполнившего последнюю изменению записи';
comment on column CORE.CORE_REL_USER_ROLES.modified_on      is 'Дата и время последнего изменения записи';
-- Create/Recreate primary, unique and foreign key constraints 
alter table CORE.CORE_REL_USER_ROLES add constraint CORE_REL_USER_ROLES_PK primary key (USER_ID, ROLE_ID) using index tablespace CORE_INDEX;
alter table CORE.CORE_REL_USER_ROLES add constraint CORE_REL_USER_ROLES_F1 foreign key (USER_ID) references CORE.CORE_USERS (USER_ID);
alter table CORE.CORE_REL_USER_ROLES add constraint CORE_REL_USER_ROLES_F2 foreign key (ROLE_ID) references CORE.CORE_ROLES (ROLE_ID);
-- Create/Recreate check constraints 
alter table CORE.CORE_REL_USER_ROLES add constraint CORE_REL_USER_ROLES_C1 check (state in ('A', 'P', 'S'));
alter table CORE.CORE_REL_USER_ROLES add constraint CORE_REL_USER_ROLES_C2 check (activate_date = trunc(activate_date));
alter table CORE.CORE_REL_USER_ROLES add constraint CORE_REL_USER_ROLES_C3 check (deactivate_date = trunc(deactivate_date));
