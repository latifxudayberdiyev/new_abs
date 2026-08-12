drop table mlt_languages;
--
create table mlt_languages (
  lang_index   number(2) not null,
  lang_code    varchar2(5) not null,
  name         varchar2(50 char) not null,
  priority     number(2) not null,
  state        varchar2(1) not null
) tablespace CORE_DATA;
--
alter table mlt_languages
  add constraint mlt_languages_pk primary key (lang_index)
  using index tablespace CORE_INDEX;
--
alter table mlt_languages
  add constraint mlt_languages_u1 unique (lang_code)
  using index tablespace CORE_INDEX;
--
alter table mlt_languages
  add constraint mlt_languages_u2 unique (priority)
  using index tablespace CORE_INDEX;
--
alter table mlt_languages
  add constraint mlt_languages_c1
  check (state in ('A','I'));
--
comment on table mlt_languages             is 'Справочник языков системы MLT и соответствие индексам (LANG1, LANG2, ...)';
comment on column mlt_languages.lang_index is 'Индекс языка (соответствует LANG1, LANG2 и т.д.)';
comment on column mlt_languages.lang_code  is 'Код языка (RUS, ENG, UZL, UZC, KAR и т.д.)';
comment on column mlt_languages.name       is 'Наименование языка';
comment on column mlt_languages.priority   is 'Приоритет отображения';
comment on column mlt_languages.state      is 'Статус (A - активный, I - неактивный)';
