----------------------------------------------------------------------------------------------------
--  SM_OBJECTS'ga oldindan (raw SQL bilan, SM engine orqali emas) yaratilgan
--  seed foydalanuvchilar uchun backfill: super_user (user_id=-1) va
--  system_user (user_id=0).
--
--  Sabab: SM_OBJECTS - "bu instance SM engine orqali ro'yxatdan o'tganmi"
--  degan tekshiruv uchun ishlatiladi (Sm_Kernel.Set_Object). Yangi
--  foydalanuvchi CREATE_USER orqali yaratilganda bu qator avtomatik
--  qo'shiladi, lekin super_user/system_user'da bunday qator yo'q edi -
--  natijada EDIT_USER/RESET_USER_PASSWORD kabi POST-jarayonlar bu ikki
--  foydalanuvchi uchun "Указанный объект не найден" xatosi berardi.
--
--  Idempotent: agar qator allaqachon bo'lsa, qayta qo'shilmaydi
--  (SM_OBJECTS_I2 unique index: object_code+relation_id).
----------------------------------------------------------------------------------------------------
declare
  procedure backfill(i_user_id in number) is
    v_cnt number;
  begin
    select count(*) into v_cnt
      from Sm_Objects
     where object_code = 'USER'
       and relation_id = i_user_id;

    if v_cnt = 0 then
      insert into Sm_Objects (object_id, parent_object_id, object_code, state,
        relation_id, parent_relation_id, created_on, created_by, modify_on, modify_by)
      values (Sm_Objects_Sq.nextval, null, 'USER', 'A',
        i_user_id, null, sysdate, 0, sysdate, 0);
    end if;
  end;
begin
  backfill(-1); -- super_user
  backfill(0);  -- system_user
  commit;
end;
/
