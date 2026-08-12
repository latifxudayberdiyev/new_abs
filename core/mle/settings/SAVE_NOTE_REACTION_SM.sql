/*
delete from sm_r_process_events where process_code='SAVE_NOTE_REACTION' and event_code='SAVE_NOTE_REACTION';
delete from sm_r_process_events where event_code='SAVE_NOTE_REACTION';
delete from sm_r_event_procedures where event_code='SAVE_NOTE_REACTION';
delete from sm_r_events where event_code='SAVE_NOTE_REACTION';
delete from sm_r_processes where process_code = 'SAVE_NOTE_REACTION';
*/

insert into Sm_R_Events
  (Event_Code, State)
values
  ('SAVE_NOTE_REACTION', 'A');
--
insert into Sm_r_Procedures
  (Procedure_Code, Procedure_Name, State)
values
  ('SAVE_NOTE_REACTION', 'Mle_Sm_Api.SAVE_NOTE_REACTION', 'A');
--
insert into Sm_r_Event_Procedures
  (Event_Code, Procedure_Code, Order_By, State)
values
  ('SAVE_NOTE_REACTION', 'SAVE_NOTE_REACTION', 1, 'A');
--
insert into Sm_r_Processes
  (process_code,object_code,parent_object_code,state,relation_key,parent_relation_key,
created_on,created_developer,set_log,new_object_state,process_type,before_process_code,after_process_code,description)
values
  ('SAVE_NOTE_REACTION', 'REACTIONS', 'ROOT', 'A', NULL,'', sysdate, 'ASILBEK', 'Y','CREATED','GET',null,null,null);
--
insert into sm_r_process_events(process_code, event_code,order_by, state)
values(
'SAVE_NOTE_REACTION',
'SAVE_NOTE_REACTION',
1,
'A');
--


SELECT T.*,ROWID FROM SM_R_OBJECTS T;
