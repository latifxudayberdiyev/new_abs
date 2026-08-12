----------------------------------------------------------------------------------------------------
--  Privileges required by the AUTH subsystem.  Run as SYS / DBA.
----------------------------------------------------------------------------------------------------
-- Strong randomness, SHA-256 (session token at rest) and HMAC-SHA512 (PBKDF2 for LOCAL).
GRANT EXECUTE ON SYS.DBMS_CRYPTO  TO CORE;
-- Trusted setter of the UAPP application context.
GRANT EXECUTE ON SYS.DBMS_SESSION TO CORE;
-- Daily cleanup job (see scheduler_purge_expired.sql).
GRANT CREATE JOB TO CORE;
----------------------------------------------------------------------------------------------------
--  UAPP (JSP/web-tier) uchun barcha EXECUTE/SELECT grant va private synonymlar
--  endi auth/grants_all_in_one.sql ga kochirildi (yagona manba, QISM A+B).
--  Bu yerda faqat yuqoridagi 3 ta SYS->CORE granti qoladi (deploy zanjiri -
--  start.sql - shularga tayanadi).
----------------------------------------------------------------------------------------------------