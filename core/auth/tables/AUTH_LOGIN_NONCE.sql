----------------------------------------------------------------------------------------------------
--  AUTH_LOGIN_NONCE  -- Одноразовый токен входа (защита от replay / CSRF)
CREATE TABLE CORE.AUTH_LOGIN_NONCE
(
  nonce       VARCHAR2(64)  NOT NULL,
  client_ip   VARCHAR2(45),
  user_agent  VARCHAR2(400),
  issued_on   DATE          NOT NULL,
  expires_on  DATE          NOT NULL,
  used        VARCHAR2(1)   DEFAULT 'N' NOT NULL,
  used_on     DATE
)
TABLESPACE CORE_DATA;

COMMENT ON TABLE  CORE.AUTH_LOGIN_NONCE            IS 'Одноразовый токен входа (защита от replay/CSRF)';
COMMENT ON COLUMN CORE.AUTH_LOGIN_NONCE.nonce      IS 'Случайный одноразовый токен (hex)';
COMMENT ON COLUMN CORE.AUTH_LOGIN_NONCE.client_ip  IS 'IP-адрес клиента, запросившего токен';
COMMENT ON COLUMN CORE.AUTH_LOGIN_NONCE.user_agent IS 'User-Agent клиента';
COMMENT ON COLUMN CORE.AUTH_LOGIN_NONCE.issued_on  IS 'Дата и время выдачи';
COMMENT ON COLUMN CORE.AUTH_LOGIN_NONCE.expires_on IS 'Дата и время истечения срока';
COMMENT ON COLUMN CORE.AUTH_LOGIN_NONCE.used       IS 'Признак использования (Y/N) — одноразовый';
COMMENT ON COLUMN CORE.AUTH_LOGIN_NONCE.used_on    IS 'Дата и время использования';

ALTER TABLE CORE.AUTH_LOGIN_NONCE ADD CONSTRAINT AUTH_LOGIN_NONCE_PK PRIMARY KEY (NONCE) USING INDEX TABLESPACE CORE_INDEX;
ALTER TABLE CORE.AUTH_LOGIN_NONCE ADD CONSTRAINT AUTH_LOGIN_NONCE_C1 CHECK (used IN ('Y', 'N'));

CREATE INDEX CORE.AUTH_LOGIN_NONCE_I1 ON CORE.AUTH_LOGIN_NONCE (EXPIRES_ON) TABLESPACE CORE_INDEX;
