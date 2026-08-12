----------------------------------------------------------------------------------------------------
-- 1. CORE_USERS
CREATE TABLE CORE.CORE_USERS
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
  virtual_fields           VARCHAR2(1000)
)
TABLESPACE CORE_DATA;

-- Comments on table
COMMENT ON TABLE CORE.CORE_USERS IS 'Таблица пользователей';

-- Comments on columns
COMMENT ON COLUMN CORE.CORE_USERS.user_id          IS 'Идентификатор пользователя (уникальный)';
COMMENT ON COLUMN CORE.CORE_USERS.cb_code          IS 'Код БХМ';
COMMENT ON COLUMN CORE.CORE_USERS.local_code       IS 'Код локального структурного подразделения';
COMMENT ON COLUMN CORE.CORE_USERS.user_type_id     IS 'Тип пользователя';
COMMENT ON COLUMN CORE.CORE_USERS.name             IS 'Название пользователя';
COMMENT ON COLUMN CORE.CORE_USERS.pinfl            IS 'ПИНФЛ пользователя';
COMMENT ON COLUMN CORE.CORE_USERS.date_birth       IS 'Дата рождения пользователя';
COMMENT ON COLUMN CORE.CORE_USERS.hr_user_id       IS 'Идентификатор пользователя в HR системе';
COMMENT ON COLUMN CORE.CORE_USERS.phone_number     IS 'Мобильный номер телефона пользователя';
COMMENT ON COLUMN CORE.CORE_USERS.email            IS 'Электронный адрес пользователя';
COMMENT ON COLUMN CORE.CORE_USERS.language         IS 'Язык интерфейса';
COMMENT ON COLUMN CORE.CORE_USERS.theme_id         IS 'Идентификатор темы интерфейса';
COMMENT ON COLUMN CORE.CORE_USERS.is_access_denied IS 'Доступ к системе запрещён (Y-Да, N-Нет)';
COMMENT ON COLUMN CORE.CORE_USERS.access_level_set IS 'Битовая карта уровней доступа пользователя';
COMMENT ON COLUMN CORE.CORE_USERS.group_set        IS 'Битовая карта кодов групп доступа';
COMMENT ON COLUMN CORE.CORE_USERS.debug            IS 'Признак отладочного режима';
COMMENT ON COLUMN CORE.CORE_USERS.state            IS 'Состояние записи (A-Активный, P-Пассивный, S-Отложенный)';
COMMENT ON COLUMN CORE.CORE_USERS.activate_date    IS 'Дата активации записи';
COMMENT ON COLUMN CORE.CORE_USERS.deactivate_date  IS 'Дата деактивации записи';
COMMENT ON COLUMN CORE.CORE_USERS.created_by       IS 'Код пользователя, создавшего запись';
COMMENT ON COLUMN CORE.CORE_USERS.created_on       IS 'Дата и время создания записи';
COMMENT ON COLUMN CORE.CORE_USERS.modified_by      IS 'Код пользователя, выполнившего последнее изменение';
COMMENT ON COLUMN CORE.CORE_USERS.modified_on      IS 'Дата и время последнего изменения записи';
COMMENT ON COLUMN CORE.CORE_USERS.virtual_fields   IS 'Значения виртуальных полей, разделённые символом ASCII 1';

-- Primary key
ALTER TABLE CORE.CORE_USERS ADD CONSTRAINT CORE_USERS_PK PRIMARY KEY (USER_ID) USING INDEX TABLESPACE CORE_INDEX;

-- Indexes
CREATE INDEX CORE.CORE_USERS_I1 ON CORE.CORE_USERS (CB_CODE, LOCAL_CODE) TABLESPACE CORE_INDEX;

-- Check constraints
ALTER TABLE CORE.CORE_USERS ADD CONSTRAINT CORE_USERS_C1 CHECK (state IN ('A', 'P', 'S'));
ALTER TABLE CORE.CORE_USERS ADD CONSTRAINT CORE_USERS_C2 CHECK (is_access_denied IN ('Y', 'N'));
ALTER TABLE CORE.CORE_USERS ADD CONSTRAINT CORE_USERS_C5 CHECK (TRUNC(activate_date) = activate_date);
ALTER TABLE CORE.CORE_USERS ADD CONSTRAINT CORE_USERS_C6 CHECK (TRUNC(deactivate_date) = deactivate_date);
