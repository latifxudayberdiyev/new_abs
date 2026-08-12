-- default languages data
delete from mlt_languages;
--
insert into mlt_languages (lang_index, lang_code, name, priority, state) 
  values (1, 'RUS', 'Russian',         1, 'A');
insert into mlt_languages (lang_index, lang_code, name, priority, state) 
  values (2, 'UZC', 'Узбек кирилл',    2, 'A');
insert into mlt_languages (lang_index, lang_code, name, priority, state) 
  values (3, 'UZL', 'O`zbek lotin',    3, 'A');
insert into mlt_languages (lang_index, lang_code, name, priority, state) 
  values (4, 'ENG', 'English',         4, 'A');
insert into mlt_languages (lang_index, lang_code, name, priority, state) 
  values (5, 'KAR', 'Qoraqalpoq',      5, 'A');
insert into mlt_languages (lang_index, lang_code, name, priority, state) 
  values (6, 'TAJ', 'Тожик',           6, 'A');
--
commit;
