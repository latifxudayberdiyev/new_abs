
create table mlt_fix_notes (
  note_id      number(12)        not null,
  user_id      number(12)        not null,  
  error_id     number(12),                  
  note_text    varchar2(4000 char) not null, 
  created_by   number(12)        not null, 
  created_on   date              not null,  
  is_sent      varchar2(1)       default 'N' not null 
);

alter table mlt_fix_notes
  add constraint mlt_fix_notes_pk primary key (note_id)
  using index tablespace CORE_INDEX;

alter table mlt_fix_notes
  add constraint mlt_fix_notes_c1
  check (is_sent in ('Y', 'N'));

alter table mlt_fix_notes
  add constraint mlt_fix_notes_f1 foreign key (error_id)
  references mlt_error_codes (error_id);
  
---------------------------------------------------------------------------------------------------

comment on table  mlt_fix_notes              is 'Admin tomonidan foydalanuvchilarga yoziladigan tuzatish eslatmalari';
comment on column mlt_fix_notes.note_id      is 'Unikal identifikator';
comment on column mlt_fix_notes.user_id      is 'Kimga yuborilayapti (foydalanuvchi ID)';
comment on column mlt_fix_notes.error_id     is 'Qaysi xato haqida note (ixtiyoriy)';
comment on column mlt_fix_notes.note_text    is 'Admin yozgan matn';
comment on column mlt_fix_notes.created_by   is 'Noteni yaratgan admin ID';
comment on column mlt_fix_notes.created_on   is 'Yaratilgan vaqt';
comment on column mlt_fix_notes.is_sent      is 'Websocket yubordi: Y=ha, N=yo''q';

