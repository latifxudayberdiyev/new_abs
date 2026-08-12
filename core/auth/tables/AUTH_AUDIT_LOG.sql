----------------------------------------------------------------------------------------------------
--  AUTH_AUDIT_LOG  -- Журнал всех событий аутентификации (успех и отказ)
CREATE TABLE CORE.AUTH_AUDIT_LOG
(
  log_id           NUMBER(12)    NOT NULL,
  event_on         DATE          NOT NULL,
  event_type       VARCHAR2(30)  NOT NULL,
  username_tried   VARCHAR2(100),
  user_id          NUMBER(9),
  provider_type    VARCHAR2(20),
  reason_code      VARCHAR2(40),
  success          VARCHAR2(1)   NOT NULL,
  client_ip        VARCHAR2(45),
  user_agent       VARCHAR2(400),
  session_id_hash  VARCHAR2(64)
)
TABLESPACE CORE_DATA;

COMMENT ON TABLE  CORE.AUTH_AUDIT_LOG                  IS 'Журнал аудита аутентификации';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.log_id          IS 'Суррогатный идентификатор (AUTH_AUDIT_LOG_SQ)';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.event_on        IS 'Дата и время события';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.event_type      IS 'NONCE_FAIL, LOGIN_FAIL, LOGIN_OK, LOCKED, LOGOUT, SESSION_FAIL ...';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.username_tried  IS 'Имя пользователя, переданное клиентом';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.user_id         IS 'Определённый идентификатор пользователя (если известен)';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.provider_type   IS 'Провайдер аутентификации';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.reason_code     IS 'Детальная причина (только для аудита, клиенту не возвращается)';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.success         IS 'Y/N';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.client_ip       IS 'IP-адрес клиента';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.user_agent      IS 'User-Agent клиента';
COMMENT ON COLUMN CORE.AUTH_AUDIT_LOG.session_id_hash IS 'Хэш связанной сессии (если есть)';

ALTER TABLE CORE.AUTH_AUDIT_LOG ADD CONSTRAINT AUTH_AUDIT_LOG_PK PRIMARY KEY (LOG_ID) USING INDEX TABLESPACE CORE_INDEX;
ALTER TABLE CORE.AUTH_AUDIT_LOG ADD CONSTRAINT AUTH_AUDIT_LOG_C1 CHECK (success IN ('Y', 'N'));

CREATE INDEX CORE.AUTH_AUDIT_LOG_I1 ON CORE.AUTH_AUDIT_LOG (EVENT_ON) TABLESPACE CORE_INDEX;
CREATE INDEX CORE.AUTH_AUDIT_LOG_I2 ON CORE.AUTH_AUDIT_LOG (USERNAME_TRIED, EVENT_ON) TABLESPACE CORE_INDEX;
