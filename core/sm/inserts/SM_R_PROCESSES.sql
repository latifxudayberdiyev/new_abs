insert into Sm_R_Processes (process_code, object_code, parent_object_code, state, relation_key, parent_relation_key, created_on, created_developer, set_log, new_object_state, process_type, description)
values ('CREATE_USER', 'USER', 'ROOT', 'A', 'user_id', null, sysdate, 'ABDUQODIR', 'Y', 'A', 'POST', 'Yangi foydalanuvchi yaratish');

insert into Sm_R_Processes (process_code, object_code, parent_object_code, state, relation_key, parent_relation_key, created_on, created_developer, set_log, new_object_state, process_type, description)
values ('EDIT_USER', 'USER', 'ROOT', 'A', 'user_id', null, sysdate, 'ABDUQODIR', 'Y', 'A', 'POST', 'Foydalanuvchini tahrirlash');

insert into Sm_R_Processes (process_code, object_code, parent_object_code, state, relation_key, parent_relation_key, created_on, created_developer, set_log, new_object_state, process_type, description)
values ('MODEL_USER', 'USER', 'ROOT', 'A', 'user_id', null, sysdate, 'ABDUQODIR', 'N', null, 'GET', 'Foydalanuvchi modelini o''qish (edit uchun)');

insert into Sm_R_Processes (process_code, object_code, parent_object_code, state, relation_key, parent_relation_key, created_on, created_developer, set_log, new_object_state, process_type, description)
values ('RESET_USER_PASSWORD', 'USER', 'ROOT', 'A', 'user_id', null, sysdate, 'ABDUQODIR', 'Y', 'A', 'POST', 'Admin tomonidan foydalanuvchi parolini reset qilish');

commit;
