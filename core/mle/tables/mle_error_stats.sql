create table mlt_error_stat (
  stat_id      number(12)    not null,
  user_id      number(12),
  error_id     number(12)    not null,
  created_on   date          not null
);

alter table mlt_error_stat
  add constraint mlt_error_stat_pk primary key (stat_id)
  using index tablespace CORE_INDEX;

alter table mlt_error_stat
  add constraint mlt_error_stat_f1 foreign key (error_id)
  references mlt_error_codes (error_id);

---------------------------------------------------------------------------------------------------
  
comment on table  mlt_error_stat             is 'Foydalanuvchilar chiqargan xatoliklar statistikasi';
comment on column mlt_error_stat.stat_id     is 'Unikal identifikator';
comment on column mlt_error_stat.user_id     is 'Xatolikni chiqargan foydalanuvchi ID';
comment on column mlt_error_stat.error_id    is 'Mlt_Error_Codes jadvalidagi xatolik identifikatori';
comment on column mlt_error_stat.created_on  is 'Xatolik chiqgan vaqt';


