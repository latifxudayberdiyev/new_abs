----------------------------------------------------------------------------------------------------
--  AUTH_LOCKOUT  -- Контроль перебора по имени пользователя (срабатывает ДО bind в AD)
CREATE TABLE CORE.AUTH_LOCKOUTS
(
  username       VARCHAR2(100) NOT NULL,
  fail_count     NUMBER(6)     DEFAULT 0 NOT NULL,
  lock_level     NUMBER(3)     DEFAULT 0 NOT NULL,
  first_fail_on  DATE,
  last_fail_on   DATE,
  locked_until   DATE,
  modified_on    DATE          NOT NULL
)
TABLESPACE CORE_DATA;

COMMENT ON TABLE  CORE.AUTH_LOCKOUTS               IS 'Состояние блокировки от перебора по имени пользователя';
COMMENT ON COLUMN CORE.AUTH_LOCKOUTS.username      IS 'Имя пользователя в нижнем регистре';
COMMENT ON COLUMN CORE.AUTH_LOCKOUTS.fail_count    IS 'Количество последовательных неудачных попыток';
COMMENT ON COLUMN CORE.AUTH_LOCKOUTS.lock_level    IS 'Уровень прогрессивной блокировки (0..n)';
COMMENT ON COLUMN CORE.AUTH_LOCKOUTS.first_fail_on IS 'Первая неудача текущей серии';
COMMENT ON COLUMN CORE.AUTH_LOCKOUTS.last_fail_on  IS 'Дата и время последней неудачи';
COMMENT ON COLUMN CORE.AUTH_LOCKOUTS.locked_until  IS 'Заблокировано до этого времени (NULL = не заблокировано)';
COMMENT ON COLUMN CORE.AUTH_LOCKOUTS.modified_on   IS 'Дата и время последнего изменения';

ALTER TABLE CORE.AUTH_LOCKOUTS ADD CONSTRAINT AUTH_LOCKOUTS_PK PRIMARY KEY (USERNAME) USING INDEX TABLESPACE CORE_INDEX;
