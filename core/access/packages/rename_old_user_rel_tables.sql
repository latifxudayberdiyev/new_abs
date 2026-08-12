-- Safety step before dropping the old, orphaned user-menu/button grant tables.
-- Confirmed via live DB inspection (2026-07-29):
--   - CORE_REL_USER_MENUS (51 rows) / CORE_REL_USER_BUTTONS (0 rows) have NO live callers left.
--   - The only PL/SQL still mentioning them is a dead comment in CORE_SIDEBAR, plus the
--     orphaned USER_DML / USER_KERNEL / USER_UTIL packages, which nothing calls anymore
--     (checked all_dependencies in the live DB and grepped the new_abs/iabs source trees).
--   - The live admin-grant path (adm_user_access.jsp) goes through ADM_USER_DML / ADM_USER_KERNEL,
--     which write ADM_REL_USER_MENUS / ADM_REL_USER_BUTTONS instead (already fixed in fix_adm_core_link.sql).
--   - No FK constraints, views, synonyms, or triggers reference these tables.
--
-- This just renames them (fully reversible) instead of dropping outright. After a burn-in
-- period with no errors, DROP TABLE ..._BAK_20260729 can follow as a separate, deliberate step.

alter table CORE_REL_USER_MENUS rename to CORE_REL_USER_MENUS_BAK_20260729;
alter table CORE_REL_USER_BUTTONS rename to CORE_REL_USER_BUTTONS_BAK_20260729;

-- commit;
