--drop table mlt_error_codes;
--
create table mlt_error_codes (
  module_code      varchar2(10) not null,
  error_code       number(5)  not null,
  message_code     varchar2(100) not null,
  description      varchar2(1000 char) not null
) tablespace CORE_DATA;
--
alter table mlt_error_codes
  add constraint mlt_error_codes_pk primary key (module_code, error_code)
  using index
  tablespace CORE_INDEX;
--
alter table mlt_error_codes
  add constraint mlt_error_codes_u1 unique (module_code, message_code)
  using index
  tablespace CORE_INDEX;
--

alter table mlt_error_codes add (
  modified_by  number(12),
  modified_on  date
);
--
alter table mlt_error_codes add (
  error_id number(12)
);
--
alter table mlt_error_codes modify (error_id number(12) not null);
--
alter table mlt_error_codes
  add constraint mlt_error_codes_u2 unique (error_id)
  using index tablespace CORE_INDEX;


comment on table mlt_error_codes                  is 'Справочник кодов ошибок с привязкой к модулям и шаблонам сообщений';
comment on column mlt_error_codes.module_code     is 'Код модуля системы';
comment on column mlt_error_codes.error_code      is 'Код ошибки';
comment on column mlt_error_codes.message_code    is 'Код сообщения';
comment on column mlt_error_codes.description     is 'Описание ошибки';
comment on column mlt_error_codes.modified_by is 'Ozgartirgan foydalanuvchi ID';
comment on column mlt_error_codes.modified_on is 'Ozgartirilgan sana';




