prompt Importing table Mlt_Languages...
set feedback off
set define off

insert into Mlt_Languages (LANG_INDEX, LANG_CODE, NAME, PRIORITY, STATE)
values (1, 'RUS', 'Russian', 1, 'A');

insert into Mlt_Languages (LANG_INDEX, LANG_CODE, NAME, PRIORITY, STATE)
values (2, 'UZC', 'Узбек кирилл', 2, 'A');

insert into Mlt_Languages (LANG_INDEX, LANG_CODE, NAME, PRIORITY, STATE)
values (3, 'UZL', 'O`zbek lotin', 3, 'A');

insert into Mlt_Languages (LANG_INDEX, LANG_CODE, NAME, PRIORITY, STATE)
values (4, 'ENG', 'English', 4, 'A');

insert into Mlt_Languages (LANG_INDEX, LANG_CODE, NAME, PRIORITY, STATE)
values (5, 'KAR', 'Qoraqalpoq', 5, 'A');

insert into Mlt_Languages (LANG_INDEX, LANG_CODE, NAME, PRIORITY, STATE)
values (6, 'TAJ', 'Тожик', 6, 'A');

prompt Done.
