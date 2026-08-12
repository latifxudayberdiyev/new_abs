insert into Sm_R_Process_Events (process_code, event_code, order_by, state, execution_mode)
values ('CREATE_USER', 'SAVE_USER_EVT', 1, 'A', 'S');

insert into Sm_R_Process_Events (process_code, event_code, order_by, state, execution_mode)
values ('EDIT_USER', 'SAVE_USER_EVT', 1, 'A', 'S');

insert into Sm_R_Process_Events (process_code, event_code, order_by, state, execution_mode)
values ('MODEL_USER', 'MODEL_USER_EVT', 1, 'A', 'S');

insert into Sm_R_Process_Events (process_code, event_code, order_by, state, execution_mode)
values ('RESET_USER_PASSWORD', 'RESET_PWD_EVT', 1, 'A', 'S');

commit;
