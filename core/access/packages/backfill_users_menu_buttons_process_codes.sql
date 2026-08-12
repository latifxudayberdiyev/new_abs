----------------------------------------------------------------------------------------------------
-- backfill_users_menu_buttons_process_codes.sql
--
-- One-time, idempotent backfill for the 5 users.jsp buttons (menu_id=3003, registered before
-- fix_menu_buttons_process_link.sql added PROCESS_CODE/MODEL_PROCESS_CODE). ACTION_CODE was
-- already set to the process code at registration time (CREATE_USER, EDIT_USER,
-- RESET_USER_PASSWORD, ADM_USER_LOCALS, ADM_USER_ACCESS - all POST per SM_R_PROCESSES) - this
-- just copies it into PROCESS_CODE. MODEL_PROCESS_CODE is set ONLY for EDIT_USER (button_id=2):
-- the edit form needs to read the current row (MODEL_USER, GET) before it can be submitted;
-- CREATE_USER opens a blank form (no model read) and the other three buttons (reset password,
-- locals, access) call their own JSP directly with no model-read step, per users.jsp's go()
-- calls (no model_process_code param).
--
-- Run as CORE schema owner, AFTER fix_menu_buttons_process_link.sql, BEFORE Core_Api.pck.
----------------------------------------------------------------------------------------------------
update CORE_R_MENU_BUTTONS
   set process_code = action_code
 where menu_id = 3003
   and process_code is null;

update CORE_R_MENU_BUTTONS
   set model_process_code = 'MODEL_USER'
 where menu_id = 3003
   and button_id = 2
   and model_process_code is null;

commit;

----------------------------------------------------------------------------------------------------
-- Verification - expect 5 rows, button_id=2 (EDIT_USER) the only one with model_process_code set.
----------------------------------------------------------------------------------------------------
column action_code format a25
column process_code format a25
column model_process_code format a15
select button_id, action_code, process_code, model_process_code
  from CORE_R_MENU_BUTTONS
 where menu_id = 3003
 order by button_id;
