----------------------------------------------------------------------------------------------------
--  AUTH_SESSIONS  -- Серверные сессии (без JWT). Хранится только ХЭШ токена.
CREATE TABLE CORE.AUTH_SESSIONS
(
  session_id_hash  VARCHAR2(64)  NOT NULL,
  user_id          NUMBER(9)     NOT NULL,
  provider_type    VARCHAR2(20)  NOT NULL,
  cb_code          VARCHAR2(5),
  local_code       VARCHAR2(5),
  lang             VARCHAR2(3),
  client_ip        VARCHAR2(45),
  user_agent       VARCHAR2(400),
  created_on       DATE          NOT NULL,
  last_seen_on     DATE          NOT NULL,
  idle_expires_on  DATE          NOT NULL,
  abs_expires_on   DATE          NOT NULL,
  state            VARCHAR2(1)   NOT NULL,
  closed_on        DATE,
  close_reason     VARCHAR2(40)
)
TABLESPACE CORE_DATA;

COMMENT ON TABLE  CORE.AUTH_SESSIONS                 IS 'Серверные сессии (токен хранится в виде хэша)';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.session_id_hash IS 'SHA-256 хэш непрозрачного токена сессии';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.user_id         IS 'Аутентифицированный пользователь (CORE.CORE_USERS)';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.provider_type   IS 'Использованный провайдер аутентификации (AD, LOCAL, ...)';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.cb_code         IS 'Код филиала пользователя (контекст)';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.local_code      IS 'Локальный код пользователя (контекст)';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.lang            IS 'Язык интерфейса (контекст)';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.client_ip       IS 'IP-адрес клиента при входе';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.user_agent      IS 'User-Agent клиента при входе';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.created_on      IS 'Дата и время создания сессии';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.last_seen_on    IS 'Дата и время последней активности';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.idle_expires_on IS 'Крайний срок по таймауту бездействия';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.abs_expires_on  IS 'Крайний срок по абсолютному таймауту';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.state           IS 'A-активная, C-закрыта (выход), E-истекла';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.closed_on       IS 'Дата и время закрытия';
COMMENT ON COLUMN CORE.AUTH_SESSIONS.close_reason    IS 'Код причины закрытия';

ALTER TABLE CORE.AUTH_SESSIONS ADD CONSTRAINT AUTH_SESSIONS_PK PRIMARY KEY (SESSION_ID_HASH) USING INDEX TABLESPACE CORE_INDEX;
ALTER TABLE CORE.AUTH_SESSIONS ADD CONSTRAINT AUTH_SESSIONS_F1 FOREIGN KEY (USER_ID) REFERENCES CORE.CORE_USERS (USER_ID);
ALTER TABLE CORE.AUTH_SESSIONS ADD CONSTRAINT AUTH_SESSIONS_C1 CHECK (state IN ('A', 'C', 'E'));

CREATE INDEX CORE.AUTH_SESSIONS_I1 ON CORE.AUTH_SESSIONS (USER_ID, STATE) TABLESPACE CORE_INDEX;
CREATE INDEX CORE.AUTH_SESSIONS_I2 ON CORE.AUTH_SESSIONS (ABS_EXPIRES_ON) TABLESPACE CORE_INDEX;
