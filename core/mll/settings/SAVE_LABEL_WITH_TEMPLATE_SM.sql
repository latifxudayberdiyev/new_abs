/*
delete from sm_r_process_events where process_code='SAVE_LABEL_WITH_TEMPLATE' and event_code='SAVE_LABEL_WITH_TEMPLATE';
delete from sm_r_process_events where event_code='SAVE_LABEL_WITH_TEMPLATE';
delete from sm_r_event_procedures where event_code='SAVE_LABEL_WITH_TEMPLATE';
delete from sm_r_events where event_code='SAVE_LABEL_WITH_TEMPLATE';
delete from sm_r_processes where process_code = 'SAVE_LABEL_WITH_TEMPLATE';
*/

insert into Sm_R_Events
  (Event_Code, State)
values
  ('SAVE_LABEL_WITH_TEMPLATE', 'A');
--
insert into Sm_r_Procedures
  (Procedure_Code, Procedure_Name, State)
values
  ('SAVE_LABEL_WITH_TEMPLATE', 'Mll_Sm_Api.Save_Label_With_Template', 'A');
--
insert into Sm_r_Event_Procedures
  (Event_Code, Procedure_Code, Order_By, State)
values
  ('SAVE_LABEL_WITH_TEMPLATE', 'SAVE_LABEL_WITH_TEMPLATE', 1, 'A');
--
insert into Sm_r_Processes
  (process_code,object_code,parent_object_code,state,relation_key,parent_relation_key,
created_on,created_developer,set_log,new_object_state,process_type,before_process_code,after_process_code,description)
values
  ('SAVE_LABEL_WITH_TEMPLATE', 'MLT_LABEL', 'ROOT', 'A', '','', sysdate, 'ASILBEK', 'Y','CREATED','GET',null,null,null);
--
insert into sm_r_process_events(process_code, event_code,order_by, state)
values(
'SAVE_LABEL_WITH_TEMPLATE',
'SAVE_LABEL_WITH_TEMPLATE',
1,
'A');

 
SELECT T.*,ROWID FROM SM_R_OBJECTS T;
