insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('01', 'Платежное поручение           ', to_date('05-03-1997', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('02', 'Платежное требованиe          ', to_date('05-03-1997', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('03', 'Кассовые документы            ', to_date('17-08-2009', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('04', 'Лимитированные чеки           ', to_date('05-03-1997', 'dd-mm-yyyy'), to_date('25-06-2001', 'dd-mm-yyyy'), 'Z', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('05', 'Заявление на аккредитив       ', to_date('05-03-1997', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('06', 'Мемориальный ордер            ', to_date('05-03-1997', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('08', 'Исправительный мемориальный ор', to_date('05-03-1997', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('09', 'Электронная кредитная карточка', to_date('05-03-1997', 'dd-mm-yyyy'), to_date('25-06-2001', 'dd-mm-yyyy'), 'Z', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('11', 'Инкассовое поручение          ', to_date('05-03-1997', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('12', 'Платежное требование поручение', to_date('05-03-1997', 'dd-mm-yyyy'), to_date('25-06-2001', 'dd-mm-yyyy'), 'Z', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('14', 'Расчетные чеки коммерческих ба', to_date('05-03-1997', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('21', 'Пл.поруч.через сист.дист.обсл.', to_date('29-08-2019', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));

insert into cbr_document (CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE, MODIFY_ON)
values ('22', 'Электрон. платежное требование', to_date('21-10-2021', 'dd-mm-yyyy'), null, 'A', to_date('04-08-2026 10:41:38', 'dd-mm-yyyy hh24:mi:ss'));


commit;
exit;
