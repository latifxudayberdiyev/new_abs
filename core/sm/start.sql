set define off;
--
prompt =====================================================================
prompt tables\...
@@tables\SM_ACTION_ROLE_REL.sql
@@tables\SM_ACTION_ROLE_REL_H.sql
@@tables\SM_APPROVED_OBJECTS.sql
@@tables\SM_APPROVERS.sql
@@tables\SM_APPROVERS_H.sql
@@tables\SM_CHILD_OBJECTS_TMP.sql
@@tables\SM_EVENT_PROCEDURES.sql
@@tables\SM_OBJECT_ACTION_CONTROLS.sql
@@tables\SM_OBJECT_ACTION_CONTROLS_H.sql
@@tables\SM_OBJECTS.sql
@@tables\SM_OBJECTS_H.sql
@@tables\SM_PARAM_PROTOCOLS.sql
@@tables\SM_PROCESS_EVENTS.sql
@@tables\SM_PROCESS_PROTOCOLS.sql
@@tables\SM_PROCESS_REQUEST_REPSONSES.sql
@@tables\SM_PROCESSES.sql
@@tables\SM_R_APPROVER_OBJECT_REL.sql
@@tables\SM_R_APPROVER_OBJECT_REL_H.sql
@@tables\SM_R_EVENT_PROCEDURES.sql
@@tables\SM_R_EVENTS.sql
@@tables\SM_R_HAS_LEAD_OBJECTS.sql
@@tables\SM_R_OBJECT_SHORT_CODES.sql
@@tables\SM_R_OBJECT_STATES.sql
@@tables\SM_R_OBJECTS.sql
@@tables\SM_R_PARAM_SETTINGS.sql
@@tables\SM_R_PROCEDURES.sql
@@tables\SM_R_PROCESS_EVENTS.sql
@@tables\SM_R_PROCESS_PARAM_REL.sql
@@tables\SM_R_PROCESSES.sql
@@tables\SM_R_TRANZITIONS.sql
/
prompt =====================================================================
prompt sequence\...
@@sequences\SM_OBJECTS_SQ.sql
@@sequences\SM_PROCESSES_SQ.sql
/
prompt =====================================================================
prompt types\...
@@types\SM_OBJECT_T.typ
/
prompt =====================================================================
prompt packages\...
@@packages\sm_api.pck
@@packages\Sm_Cache.pck
@@packages\Sm_Const.pck
@@packages\Sm_Control.pck
@@packages\Sm_Dml.pck
@@packages\sm_init.pck
@@packages\Sm_Kernel.pck
@@packages\Sm_Sender.pck
@@packages\Sm_Util.pck
/
prompt =====================================================================
prompt recompile invalid objects
-- TODO: constant/compile.sql va invalid.sql repoda topilmadi (2026-07-08
-- audit) - shu fayllar tiklanguncha yoki bu qadam olib tashlanguncha izohga
-- olindi, aks holda start.sql shu yerda xato berib to'xtar edi.
--@@constant/compile.sql;
prompt =====================================================================
prompt Check invalid objects ..
--@@constant/invalid.sql;
--
set define on;
spool off;
