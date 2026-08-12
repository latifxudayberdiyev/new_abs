----------------------------------------------------------------------------------------------------
--  CORE_USER_KEYS
CREATE TABLE CORE.CORE_USER_KEYS
(
  identity_id              NUMBER(9)     NOT NULL,
  user_id                  NUMBER(9)     NOT NULL,
  provider_type            VARCHAR2(20)  NOT NULL,
  provider_key             VARCHAR2(512) NOT NULL,
  is_required              VARCHAR2(1)   DEFAULT 'N' NOT NULL,
  password                 VARCHAR2(1000),
  password_must_be_changed VARCHAR2(1)   DEFAULT 'N',
  password_expiry_date     DATE,
  state                    VARCHAR2(1)   NOT NULL,
  modified_by              NUMBER(9)     NOT NULL,
  modified_on              DATE          NOT NULL,
  description              VARCHAR2(200)
)
TABLESPACE CORE_DATA;

-- Comments on table
COMMENT ON TABLE CORE.CORE_USER_KEYS IS 'Ключи аутентификации пользователей';

-- Comments on columns
COMMENT ON COLUMN CORE.CORE_USER_KEYS.identity_id              IS 'Идентификатор записи';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.user_id                  IS 'Идентификатор пользователя';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.provider_type            IS 'Тип аутентификации (LOCAL, AD, STX_KEY, GOOGLE ...)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.provider_key             IS 'Уникальный идентификатор пользователя во внешней системе';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.is_required              IS 'Обязательность аутентификации (Y-Да, N-Нет)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.password                 IS 'Зашифрованный пароль (только для LOCAL)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.password_must_be_changed IS 'Пользователь должен сменить пароль (Y-Да, N-Нет, только для LOCAL)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.password_expiry_date     IS 'Дата истечения срока действия пароля (только для LOCAL)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.state                    IS 'Состояние записи (A-Активный, P-Пассивный, S-Отложенный)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.modified_by              IS 'Код пользователя, выполнившего последнее изменение';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.modified_on              IS 'Дата и время последнего изменения записи';
COMMENT ON COLUMN CORE.CORE_USER_KEYS.description              IS 'Описание';

-- Primary key
ALTER TABLE CORE.CORE_USER_KEYS ADD CONSTRAINT CORE_USER_KEYS_PK PRIMARY KEY (IDENTITY_ID) USING INDEX TABLESPACE CORE_INDEX;

-- Foreign key
ALTER TABLE CORE.CORE_USER_KEYS ADD CONSTRAINT CORE_USER_KEYS_F1 FOREIGN KEY (USER_ID) REFERENCES CORE.CORE_USERS (USER_ID);

-- Unique
ALTER TABLE CORE.CORE_USER_KEYS ADD CONSTRAINT CORE_USER_KEYS_U1 UNIQUE (PROVIDER_TYPE, PROVIDER_KEY) USING INDEX TABLESPACE CORE_INDEX;

-- Index
CREATE INDEX CORE.CORE_USER_KEYS_I1 ON CORE.CORE_USER_KEYS (USER_ID) TABLESPACE CORE_INDEX;

-- Check constraints
ALTER TABLE CORE.CORE_USER_KEYS ADD CONSTRAINT CORE_USER_KEYS_C1 CHECK (state IN ('A', 'P', 'S'));
ALTER TABLE CORE.CORE_USER_KEYS ADD CONSTRAINT CORE_USER_KEYS_C2 CHECK (is_required IN ('Y', 'N'));
ALTER TABLE CORE.CORE_USER_KEYS ADD CONSTRAINT CORE_USER_KEYS_C3 CHECK (password_must_be_changed IN ('Y', 'N'));
