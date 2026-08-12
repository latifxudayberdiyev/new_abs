--drop table mll_label_codes;
--
create table mll_label_codes (
  label_id         number(12)  not null,
  module_code      varchar2(10) not null,
  message_code       varchar2(100)  not null,
  description      varchar2(1000 char) not null
) tablespace CORE_DATA;
--
alter table mll_label_codes
  add constraint mll_label_codes_pk primary key (label_id)
  using index
  tablespace CORE_INDEX;
--
alter table mll_label_codes
  add constraint mll_label_codes_u1 unique (module_code, message_code)
  using index
  tablespace CORE_INDEX;
--
alter table mll_label_codes
 add field_hint varchar2(1000);
--
alter table mll_label_codes add (
  modified_by number(12),
  modified_on date
);

comment on column mll_label_codes.modified_by is 'Ozgartirgan foydalanuvchi ID';
comment on column mll_label_codes.modified_on is 'Ozgartirilgan sana';

comment on column mll_label_codes.message_code
    is 'MLT templates uchun message code';

comment on column mll_label_codes.module_code
    is 'Module code qaysi module uchunligini aniqlash';

comment on column mll_label_codes.description
    is 'Labellar uchun description';

