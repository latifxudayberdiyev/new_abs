----------------------------------------------------------------------------------------------------
--  Application context namespace "UAPP".
--  Only the trusted package CORE.AUTH_SESSION may set values in this namespace.
--  CORE.USER_ENV reads it via SYS_CONTEXT('UAPP', ...).
----------------------------------------------------------------------------------------------------
CREATE OR REPLACE CONTEXT UAPP USING CORE.AUTH_SESSION;
