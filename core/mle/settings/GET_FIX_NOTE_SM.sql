/*
delete from sm_r_process_events where process_code='GET_FIX_NOTE' and event_code='GET_FIX_NOTE';
delete from sm_r_process_events where event_code='GET_FIX_NOTE';
delete from sm_r_event_procedures where event_code='GET_FIX_NOTE';
delete from sm_r_events where event_code='GET_FIX_NOTE';
delete from sm_r_processes where process_code = 'GET_FIX_NOTE';
*/

insert into Sm_R_Events
  (Event_Code, State)
values
  ('GET_FIX_NOTE', 'A');
--
insert into Sm_r_Procedures
  (Procedure_Code, Procedure_Name, State)
values
  ('GET_FIX_NOTE', 'Mle_Sm_Api.GET_FIX_NOTE', 'A');
--
insert into Sm_r_Event_Procedures
  (Event_Code, Procedure_Code, Order_By, State)
values
  ('GET_FIX_NOTE', 'GET_FIX_NOTE', 1, 'A');
--
insert into Sm_r_Processes
  (process_code,object_code,parent_object_code,state,relation_key,parent_relation_key,
created_on,created_developer,set_log,new_object_state,process_type,before_process_code,after_process_code,description)
values
  ('GET_FIX_NOTE', 'GET_FIX_NOTES', 'ROOT', 'A', NULL,'', sysdate, 'ASILBEK', 'Y','CREATED','GET',null,null,null);
--
insert into sm_r_process_events(process_code, event_code,order_by, state)
values(
'GET_FIX_NOTE',
'GET_FIX_NOTE',
1,
'A');
--


SELECT T.*,ROWID FROM SM_R_OBJECTS T;


SELECT T.* , ROWID FROM Mlt_Fix_Notes T;

