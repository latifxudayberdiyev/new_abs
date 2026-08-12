/* =========================================================
   USER_ACCESSES_TMP
   ========================================================= */

create global temporary table user_accesses_tmp (
    user_id       number not null,
    access_type   varchar2(30) not null,
    access_code   varchar2(150) not null,
    access_name   varchar2(300),
    allow_flag    varchar2(1) default 'Y' not null
) on commit preserve rows;

comment on table user_accesses_tmp is 'Joriy session uchun keshga yuklangan foydalanuvchi dostuplari';
comment on column user_accesses_tmp.user_id     is 'Joriy foydalanuvchi ID raqami';
comment on column user_accesses_tmp.access_type is 'Dostup turi: MODULE, MENU, FORM, BUTTON, ACTION';
comment on column user_accesses_tmp.access_code is 'Dostup kodi';
comment on column user_accesses_tmp.access_name is 'Dostup nomi';
comment on column user_accesses_tmp.allow_flag  is 'Ruxsat belgisi: Y - ruxsat bor, N - ruxsat yo''q';

create index user_accesses_tmp_i1 on user_accesses_tmp(access_type, access_code);
create index user_accesses_tmp_i2 on user_accesses_tmp(user_id, access_type);
