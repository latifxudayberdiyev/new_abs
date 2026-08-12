insert into cbr_rez_cl (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('1', 'Резидент            ', to_date('05-03-1997', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_rez_cl (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('2', 'Не резидент         ', to_date('22-10-2010', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));


commit;
exit;
