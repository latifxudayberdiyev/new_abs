/*delete from sm_r_process_events where process_code='SAVE_TEMPLATE' and event_code='SAVE_TEMPLATE';
delete from sm_r_process_events where event_code='SAVE_TEMPLATE';
delete from sm_r_event_procedures where event_code='SAVE_TEMPLATE';
delete from sm_r_events where event_code='SAVE_TEMPLATE';
delete from sm_r_processes where process_code = 'SAVE_TEMPLATE';
*/

select * from sm_objects;
select t.*, rowid  from sm_r_objects t;
select rowid, t.* from  sm_r_tranzitions t 

insert into Sm_R_Events
  (Event_Code, State)
values
  ('SAVE_TEMPLATE', 'A');  
--
insert into Sm_r_Procedures
  (Procedure_Code, Procedure_Name, State)
values
  ('SAVE_TEMPLATE', 'Mlt_Sm_Api.SAVE_TEMPLATE', 'A');
--
insert into Sm_r_Event_Procedures
  (Event_Code, Procedure_Code, Order_By, State)
values
  ('SAVE_TEMPLATE', 'SAVE_TEMPLATE', 1, 'A');

--
insert into Sm_r_Processes
  (process_code,object_code,parent_object_code,state,relation_key,parent_relation_key,
created_on,created_developer,set_log,new_object_state,process_type,before_process_code,after_process_code,description)
values
  ('SAVE_TEMPLATE', 'MLT_ERROR', 'ROOT', 'A', 'template_id','', sysdate, 'ASILBEK', 'Y','CREATED','GET',null,null,null);

--- update sm_r_processes set new_object_state='ENTERED' where process_code='MODEL_TRANCHE_WITH_CONTRACT';  
----update sm_r_processes set parent_object_code='CREDIT_LINE' where process_code='MODEL_TRANCHE_WITH_CONTRACT';
insert into sm_r_process_events(process_code, event_code,order_by, state)
values(
'SAVE_TEMPLATE',
'SAVE_TEMPLATE',
1,
'A');


