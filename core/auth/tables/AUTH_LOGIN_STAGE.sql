----------------------------------------------------------------------------------------------------
--  AUTH_LOGIN_STAGE  -- Промежуточный (stage) токен между Begin_Login и Complete_Login.
--  Begin_Login (nonce+lockout пройдены) выдаёт stage-токен; Complete_Login принимает
--  его только после успешного AD-bind. Так Complete_Login нельзя вызвать в обход
--  nonce/lockout/AD. Одноразовый, короткий TTL. Хранится ХЭШ токена.
CREATE TABLE CORE.AUTH_LOGIN_STAGE
(
  stage_hash   VARCHAR2(64)  NOT NULL,
  username     VARCHAR2(512) NOT NULL,
  client_ip    VARCHAR2(45),
  issued_on    DATE          NOT NULL,
  expires_on   DATE          NOT NULL,
  used         VARCHAR2(1)   DEFAULT 'N' NOT NULL,
  used_on      DATE
)
TABLESPACE CORE_DATA;

COMMENT ON TABLE  CORE.AUTH_LOGIN_STAGE             IS 'Stage-токен между Begin_Login и Complete_Login';
COMMENT ON COLUMN CORE.AUTH_LOGIN_STAGE.stage_hash  IS 'SHA-256 хэш одноразового stage-токена';
COMMENT ON COLUMN CORE.AUTH_LOGIN_STAGE.username    IS 'Нормализованный логин, для которого выдан токен';
COMMENT ON COLUMN CORE.AUTH_LOGIN_STAGE.client_ip   IS 'IP-адрес клиента';
COMMENT ON COLUMN CORE.AUTH_LOGIN_STAGE.issued_on   IS 'Дата и время выдачи';
COMMENT ON COLUMN CORE.AUTH_LOGIN_STAGE.expires_on  IS 'Дата и время истечения срока';
COMMENT ON COLUMN CORE.AUTH_LOGIN_STAGE.used        IS 'Признак использования (Y/N) - одноразовый';
COMMENT ON COLUMN CORE.AUTH_LOGIN_STAGE.used_on     IS 'Дата и время использования';

ALTER TABLE CORE.AUTH_LOGIN_STAGE ADD CONSTRAINT AUTH_LOGIN_STAGE_PK PRIMARY KEY (STAGE_HASH) USING INDEX TABLESPACE CORE_INDEX;
ALTER TABLE CORE.AUTH_LOGIN_STAGE ADD CONSTRAINT AUTH_LOGIN_STAGE_C1 CHECK (used IN ('Y', 'N'));

CREATE INDEX CORE.AUTH_LOGIN_STAGE_I1 ON CORE.AUTH_LOGIN_STAGE (EXPIRES_ON) TABLESPACE CORE_INDEX;
