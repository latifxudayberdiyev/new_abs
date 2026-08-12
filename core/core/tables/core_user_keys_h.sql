----------------------------------------------------------------------------------------------------
--  CORE_USER_KEYS
CREATE TABLE CORE.CORE_USER_KEYS_H
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
  description              VARCHAR2(200),
  action                   VARCHAR2(1) not null,
  action_date              DATE not null
)
TABLESPACE CORE_DATA;

-- Comments on table
COMMENT ON TABLE CORE.CORE_USER_KEYS IS 'Ключи аутентификации пользователей';

-- Comments on columns
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.identity_id              IS 'Идентификатор записи';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.user_id                  IS 'Идентификатор пользователя';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.provider_type            IS 'Тип аутентификации (LOCAL, AD, STX_KEY, GOOGLE ...)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.provider_key             IS 'Уникальный идентификатор пользователя во внешней системе';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.is_required              IS 'Обязательность аутентификации (Y-Да, N-Нет)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.password                 IS 'Зашифрованный пароль (только для LOCAL)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.password_must_be_changed IS 'Пользователь должен сменить пароль (Y-Да, N-Нет, только для LOCAL)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.password_expiry_date     IS 'Дата истечения срока действия пароля (только для LOCAL)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.state                    IS 'Состояние записи (A-Активный, P-Пассивный, S-Отложенный)';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.modified_by              IS 'Код пользователя, выполнившего последнее изменение';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.modified_on              IS 'Дата и время последнего изменения записи';
COMMENT ON COLUMN CORE.CORE_USER_KEYS_H.description              IS 'Описание';
comment on column CORE.CORE_USER_KEYS_H.action                   IS 'Действие';
comment on column CORE.CORE_USER_KEYS_H.action_date              IS 'Дата действия';

-- Check constraints
alter table CORE.CORE_USER_KEYS_H add constraint CORE_USER_KEYS_H_C1 check (action in ('I', 'U', 'D'));
