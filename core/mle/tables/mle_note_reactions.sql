
create table mlt_note_reactions (
  reaction_id  number(12)   not null,
  note_id      number(12)   not null, 
  user_id      number(12)   not null,  
  reaction     varchar2(1)  not null,  
  created_on   date         not null
) ;

alter table mlt_note_reactions
  add constraint mlt_note_reactions_pk primary key (reaction_id)
  using index tablespace CORE_INDEX;


alter table mlt_note_reactions
  add constraint mlt_note_reactions_u1 unique (note_id, user_id)
  using index tablespace CORE_INDEX;

alter table mlt_note_reactions
  add constraint mlt_note_reactions_c1
  check (reaction in ('L', 'D'));

alter table mlt_note_reactions
  add constraint mlt_note_reactions_fk1
  foreign key (note_id) references mlt_fix_notes (note_id);
  
---------------------------------------------------------------------------------------------------

comment on table  mlt_note_reactions           is 'Foydalanuvchilarning admin notesiga bergan bahosi';
comment on column mlt_note_reactions.reaction_id is 'Unikal identifikator';
comment on column mlt_note_reactions.note_id   is 'Qaysi notega berilgan baho';
comment on column mlt_note_reactions.user_id   is 'Kim baholadi';
comment on column mlt_note_reactions.reaction  is 'Baho: L=like, D=dislike';
comment on column mlt_note_reactions.created_on is 'Baholagan vaqt';
