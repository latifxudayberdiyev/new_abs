----------------------------------------------------------------------------------------------------
--  ONE-TIME CLEANUP SCRIPT - Auth_Api_Gateway HMAC-client mechanism removal.
--  Run as CORE schema owner. REVIEW BEFORE RUNNING - this script drops objects.
--
--  Background: Auth_Api_Gateway.pck (+ its dependency Auth_Api_Kernel.pck,
--  Auth_Api_Master_Key.pck, and the tables Auth_Api_Clients / Auth_Api_Request_Nonce)
--  implemented an HMAC-signed external-API-client mechanism. It was never deployed
--  to the dev database (confirmed via a USER_OBJECTS query - no AUTH_API_GATEWAY
--  object exists there) and has zero Java-side callers. It has been fully
--  superseded by the ESBIN subsystem (see esbin/docs/ARCHITECTURE.md). The
--  source files for Auth_Api_Gateway.pck, Auth_Api_Kernel.pck, Auth_Api_Master_Key.pck,
--  auth/tables/AUTH_API_CLIENTS.sql, auth/tables/AUTH_API_REQUEST_NONCE.sql,
--  auth/sequences/AUTH_API_CLIENT_SQ.sql and auth/create_api_client.sql have
--  already been removed from the repo; deploy_all.sql, auth/start.sql and
--  auth/grants_all_in_one.sql no longer reference them.
--
--  UPDATE 2026-08-10: the "Auth_Api_Gateway was never deployed" claim above was
--  confirmed FALSE for this local test DB (core_crobs@XEPDB1) - AUTH_API_GATEWAY
--  package+body exist there, VALID, created 2026-07-23. Added a DROP step for it
--  below. Also added a final section deleting the 3-place orphan test-client rows
--  (Core_Users -1001, the Sm_Objects row it created, verified unreferenced by any
--  Sm_Action_Role_Rel/Sm_Object_Action_Controls row and childless) since the
--  Auth_Api_Clients table drop alone does not touch those. Re-verify object
--  existence via USER_OBJECTS on whichever DB you run this against before relying
--  on either claim - deploy state drifts between environments.
--
--  This script drops what WAS deployed: Auth_Api_Gateway, Auth_Api_Kernel,
--  Auth_Api_Master_Key, and their two supporting tables + sequence. Object names
--  below were taken directly from the (now-deleted) DDL source files before
--  deletion - no names were guessed:
--    auth/tables/AUTH_API_CLIENTS.sql        -> table AUTH_API_CLIENTS
--                                                (PK/UK indexes drop automatically
--                                                 with the table, not listed separately)
--    auth/tables/AUTH_API_REQUEST_NONCE.sql  -> table AUTH_API_REQUEST_NONCE
--                                                (PK index + AUTH_API_REQUEST_NONCE_I1
--                                                 both drop automatically with the table)
--    auth/sequences/AUTH_API_CLIENT_SQ.sql   -> sequence AUTH_API_CLIENT_SQ
--                                                (sequences do NOT drop with a table -
--                                                 dropped explicitly below)
--
--  ROLLBACK: these DROP statements are irreversible in place (no data of value
--  is destroyed - Auth_Api_Clients/Auth_Api_Request_Nonce were never populated
--  by any real caller). If the HMAC-gateway design is ever needed again, restore
--  it from git history rather than reversing this script:
--    git show <pre-cleanup-commit>:auth/packages/Auth_Api_Kernel.pck
--    git show <pre-cleanup-commit>:auth/packages/Auth_Api_Master_Key.pck
--    git show <pre-cleanup-commit>:auth/tables/AUTH_API_CLIENTS.sql
--    git show <pre-cleanup-commit>:auth/tables/AUTH_API_REQUEST_NONCE.sql
--    git show <pre-cleanup-commit>:auth/sequences/AUTH_API_CLIENT_SQ.sql
--  and re-run those files (tables/sequence before packages). Auth_Api_Gateway.pck
--  itself is also still in git history if the whole design is revived - it was
--  never deployed here in the first place, so there is nothing to restore in the DB.
--
--  DEPLOY ORDER for this whole cleanup (do not run out of order):
--    1. Run this script (DROP steps below) as CORE.
--    2. Separately redeploy auth/packages/Auth_Kernel.pck (already edited outside
--       this script, not part of this cleanup - it now denies any provider_type
--       other than LOCAL in Complete_Login, fail-closed for AD until a real
--       LDAPS-bind chain is wired in).
--    3. Re-run auth/Tests/run_all.sql (50_test_auth_api_flow.sql was updated to
--       match the Auth_Kernel.pck change) to verify nothing broke.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

prompt =====================================================================
prompt PRE-DROP CHECK - orphan rows from auth/create_api_client.sql (deleted)
prompt =====================================================================
prompt That script inserted into THREE places per client: Core.Core_Users
prompt (User_Id = -1000 - Auth_Api_Client_Sq.nextval), Core.Auth_Api_Clients,
prompt and Core.Sm_Objects. The DROP below removes Auth_Api_Clients, but does
prompt NOT touch Core_Users/Sm_Objects - if any client was ever created on this
prompt DB, those rows would survive as orphans (a user_id with no owning
prompt Auth_Api_Clients row and no key). Review this list BEFORE running the
prompt DROP steps - if it returns any rows, decide with the lead whether to
prompt delete them here or leave them (harmless but orphaned).

select u.user_id, u.name, u.created_on
  from Core.Core_Users u
 where u.user_id < -1000
 order by u.user_id;

prompt (compare against Core.Auth_Api_Clients while it still exists, if you
prompt need to know which client each orphan user_id belonged to)

select c.user_id, c.client_id, c.state
  from Core.Auth_Api_Clients c
 order by c.user_id;

prompt =====================================================================
prompt DROP dead HMAC-client-gateway objects (Auth_Api_Gateway superseded by ESBIN)
prompt =====================================================================

-- Auth_Api_Gateway: the public entry point. Drop first (nothing else depends on it).
begin
  execute immediate 'drop package Auth_Api_Gateway';
  dbms_output.put_line('DROPPED package Auth_Api_Gateway');
exception
  when others then
    if sqlcode = -4043 then
      dbms_output.put_line('SKIP: package Auth_Api_Gateway does not exist');
    else
      raise;
    end if;
end;
/

-- Auth_Api_Kernel: only caller was Auth_Api_Gateway.
begin
  execute immediate 'drop package Auth_Api_Kernel';
  dbms_output.put_line('DROPPED package Auth_Api_Kernel');
exception
  when others then
    if sqlcode = -4043 then
      dbms_output.put_line('SKIP: package Auth_Api_Kernel does not exist');
    else
      raise;
    end if;
end;
/

-- Auth_Api_Master_Key: only used by Auth_Api_Kernel.Decrypt_Secret.
begin
  execute immediate 'drop package Auth_Api_Master_Key';
  dbms_output.put_line('DROPPED package Auth_Api_Master_Key');
exception
  when others then
    if sqlcode = -4043 then
      dbms_output.put_line('SKIP: package Auth_Api_Master_Key does not exist');
    else
      raise;
    end if;
end;
/

-- Auth_Api_Clients: registry table for the dead HMAC mechanism only.
begin
  execute immediate 'drop table Auth_Api_Clients cascade constraints';
  dbms_output.put_line('DROPPED table Auth_Api_Clients');
exception
  when others then
    if sqlcode = -942 then
      dbms_output.put_line('SKIP: table Auth_Api_Clients does not exist');
    else
      raise;
    end if;
end;
/

-- Auth_Api_Request_Nonce: replay-protection table for the dead HMAC mechanism only.
begin
  execute immediate 'drop table Auth_Api_Request_Nonce cascade constraints';
  dbms_output.put_line('DROPPED table Auth_Api_Request_Nonce');
exception
  when others then
    if sqlcode = -942 then
      dbms_output.put_line('SKIP: table Auth_Api_Request_Nonce does not exist');
    else
      raise;
    end if;
end;
/

-- Auth_Api_Client_Sq: synthetic user_id generator for Auth_Api_Clients rows only.
-- Sequences do not drop automatically with their table - explicit DROP required.
begin
  execute immediate 'drop sequence Auth_Api_Client_Sq';
  dbms_output.put_line('DROPPED sequence Auth_Api_Client_Sq');
exception
  when others then
    if sqlcode = -2289 then
      dbms_output.put_line('SKIP: sequence Auth_Api_Client_Sq does not exist');
    else
      raise;
    end if;
end;
/

prompt =====================================================================
prompt DELETE orphan test-client rows (Core_Users -1001 + its Sm_Objects row)
prompt =====================================================================
prompt Verified before deleting: Sm_Objects row (Object_Code='USER', Created_By=-1001)
prompt has 0 children, 0 refs in Sm_Action_Role_Rel, 0 refs in Sm_Object_Action_Controls
prompt - inert, safe. Deleting Sm_Objects before Core_Users since it carries the FK.

delete from Sm_Objects where Created_By = -1001 and Object_Code = 'USER'
   and Object_Id not in (select Parent_Object_Id from Sm_Objects where Parent_Object_Id is not null);
delete from Core_Users where User_Id = -1001;
commit;

prompt =====================================================================
prompt DROP steps done. NEXT (do NOT run from this script):
prompt   1) redeploy auth/packages/Auth_Kernel.pck (already edited separately)
prompt   2) re-run auth/Tests/run_all.sql to verify AD fail-closed / LOCAL login
prompt      still pass (50_test_auth_api_flow.sql was updated for this)
prompt =====================================================================
