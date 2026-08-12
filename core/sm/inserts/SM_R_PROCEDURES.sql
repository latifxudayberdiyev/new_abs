insert into Sm_R_Procedures (procedure_code, procedure_name, state)
values ('SAVE_USER', 'Core_Kernel.Save_User', 'A');

insert into Sm_R_Procedures (procedure_code, procedure_name, state)
values ('MODEL_USER', 'Core_Kernel.Model_User', 'A');

insert into Sm_R_Procedures (procedure_code, procedure_name, state)
values ('RESET_PWD', 'Auth_Pwd_Kernel.Admin_Reset_Password', 'A');

commit;
