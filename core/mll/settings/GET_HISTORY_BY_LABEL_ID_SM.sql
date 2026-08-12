/*
delete from sm_r_process_events where process_code='GET_HISTORY_BY_LABEL_ID' and event_code='GET_HISTORY_BY_LABEL_ID';
delete from sm_r_process_events where event_code='GET_HISTORY_BY_LABEL_ID';
delete from sm_r_event_procedures where event_code='GET_HISTORY_BY_LABEL_ID';
delete from sm_r_events where event_code='GET_HISTORY_BY_LABEL_ID';
delete from sm_r_processes where process_code = 'GET_HISTORY_BY_LABEL_ID';
delete from Sm_r_Procedures where Procedure_Code='GET_HISTORY_BY_LABEL_ID';
*/

insert into Sm_R_Events
  (Event_Code, State)
values
  ('GET_HISTORY_BY_LABEL_ID', 'A');

--
insert into Sm_r_Procedures
  (Procedure_Code, Procedure_Name, State)
values
  ('GET_HISTORY_BY_LABEL_ID', 'Mll_Sm_Api.GET_HISTORY_BY_LABEL_ID', 'A');

--
insert into Sm_r_Event_Procedures
  (Event_Code, Procedure_Code, Order_By, State)
values
  ('GET_HISTORY_BY_LABEL_ID', 'GET_HISTORY_BY_LABEL_ID', 1, 'A');

--
insert into Sm_r_Processes
  (process_code,object_code,parent_object_code,state,relation_key,parent_relation_key,
created_on,created_developer,set_log,new_object_state,process_type,before_process_code,after_process_code,description)
values
  ('GET_HISTORY_BY_LABEL_ID', 'LABEL_LOGS', 'ROOT', 'A', NULL,'', sysdate, 'ASILBEK', 'Y','CREATED','GET',null,null,null);

insert into sm_r_process_events(process_code, event_code,order_by, state)
values(
'GET_HISTORY_BY_LABEL_ID',
'GET_HISTORY_BY_LABEL_ID',
1,
'A');


select t.*,rowid from sm_r_objects t;
