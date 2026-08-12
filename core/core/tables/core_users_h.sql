----------------------------------------------------------------------------------------------------
--  CORE_USERS
CREATE TABLE CORE.CORE_USERS_H
(
  user_id                  NUMBER(9)     NOT NULL,
  cb_code                  VARCHAR2(5)   NOT NULL,
  local_code               VARCHAR2(5)   NOT NULL,
  user_type_id             NUMBER(2)     NOT NULL,
  name                     VARCHAR2(80)  NOT NULL,
  pinfl                    VARCHAR2(14),
  date_birth               DATE,
  hr_user_id               NUMBER(10),
  phone_number             VARCHAR2(15),
  email                    VARCHAR2(100),
  language                 VARCHAR2(3)   NOT NULL,
  theme_id                 NUMBER(6)     NOT NULL,
  is_access_denied         VARCHAR2(1)   NOT NULL,
  access_level_set         NUMBER(38)    NOT NULL,
  group_set                RAW(125)      NOT NULL,
  debug                    VARCHAR2(1)   NOT NULL,
  state                    VARCHAR2(1)   NOT NULL,
  activate_date            DATE          NOT NULL,
  deactivate_date          DATE          NOT NULL,
  created_by               NUMBER(9)     NOT NULL,
  created_on               DATE          NOT NULL,
  modified_by              NUMBER(9)     NOT NULL,
  modified_on              DATE          NOT NULL,
  virtual_fields           VARCHAR2(1000),
  action                   VARCHAR2(1) not null,
  action_date              DATE not null
)
TABLESPACE CORE_DATA;

-- Comments on table
COMMENT ON TABLE CORE.CORE_USERS_H IS 'Таблица пользователей';

-- Comments on columns
COMMENT ON COLUMN CORE.CORE_USERS_H.user_id            IS 'Идентификатор пользователя (уникальный)';
COMMENT ON COLUMN CORE.CORE_USERS_H.cb_code            IS 'Код БХМ';
COMMENT ON COLUMN CORE.CORE_USERS_H.local_code         IS 'Код локального структурного подразделения';
COMMENT ON COLUMN CORE.CORE_USERS_H.user_type_id       IS 'Тип пользователя';
COMMENT ON COLUMN CORE.CORE_USERS_H.name               IS 'Название пользователя';
COMMENT ON COLUMN CORE.CORE_USERS_H.pinfl              IS 'ПИНФЛ пользователя';
COMMENT ON COLUMN CORE.CORE_USERS_H.date_birth         IS 'Дата рождения пользователя';
COMMENT ON COLUMN CORE.CORE_USERS_H.hr_user_id         IS 'Идентификатор пользователя в HR системе';
COMMENT ON COLUMN CORE.CORE_USERS_H.phone_number       IS 'Мобильный номер телефона пользователя';
COMMENT ON COLUMN CORE.CORE_USERS_H.email              IS 'Электронный адрес пользователя';
COMMENT ON COLUMN CORE.CORE_USERS_H.language           IS 'Язык интерфейса';
COMMENT ON COLUMN CORE.CORE_USERS_H.theme_id           IS 'Идентификатор темы интерфейса';
COMMENT ON COLUMN CORE.CORE_USERS_H.is_access_denied   IS 'Доступ к системе запрещён (Y-Да, N-Нет)';
COMMENT ON COLUMN CORE.CORE_USERS_H.access_level_set   IS 'Битовая карта уровней доступа пользователя';
COMMENT ON COLUMN CORE.CORE_USERS_H.group_set          IS 'Битовая карта кодов групп доступа';
COMMENT ON COLUMN CORE.CORE_USERS_H.debug              IS 'Признак отладочного режима';
COMMENT ON COLUMN CORE.CORE_USERS_H.state              IS 'Состояние записи (A-Активный, P-Пассивный, S-Отложенный)';
COMMENT ON COLUMN CORE.CORE_USERS_H.activate_date      IS 'Дата активации записи';
COMMENT ON COLUMN CORE.CORE_USERS_H.deactivate_date    IS 'Дата деактивации записи';
COMMENT ON COLUMN CORE.CORE_USERS_H.created_by         IS 'Код пользователя, создавшего запись';
COMMENT ON COLUMN CORE.CORE_USERS_H.created_on         IS 'Дата и время создания записи';
COMMENT ON COLUMN CORE.CORE_USERS_H.modified_by        IS 'Код пользователя, выполнившего последнее изменение';
COMMENT ON COLUMN CORE.CORE_USERS_H.modified_on        IS 'Дата и время последнего изменения записи';
COMMENT ON COLUMN CORE.CORE_USERS_H.virtual_fields     IS 'Значения виртуальных полей, разделённые символом ASCII 1';
comment on column CORE.CORE_USERS_H.action             IS 'Действие';
comment on column CORE.CORE_USERS_H.action_date        IS 'Дата действия';

-- Check constraints
alter table CORE.CORE_USERS_H add constraint CORE_USERS_H_C1 check (action in ('I', 'U', 'D'));
