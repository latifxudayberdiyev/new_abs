----------------------------------------------------------------------------------------------------
--  JOB_USER (user_id=-200) - Auth_Session.Open_Job_Actor tomonidan
--  ishlatiladigan yagona sun'iy foydalanuvchi. Rejalashtirilgan (DBMS_
--  SCHEDULER) job'lar audit-ustunli (Modified_By kabi) jadvallarga
--  yozganda ishlatiladi - haqiqiy xodim EMAS, JSP orqali kirib bo'lmaydi,
--  sidebar/menyu kerak emas (jobda UI yo'q) - shuning uchun DEBUG_USER'dan
--  farqli, faqat CORE_USERS qatori va SM_OBJECTS backfill yetarli.
--
--  cb_code/local_code faqat NOT NULL ustunni to'ldirish uchun - job'lar
--  odatda filial-scoped emas, hech qachon UAPP kontekstiga cb_code sifatida
--  ustidan yozilmaydi (Open_Job_Actor buni o'rnatmaydi, faqat user_id'ni).
--
--  Ishga tushirish: CORE schema egasi sifatida (bir marta, idempotent).
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  c_User_Id constant number := -200;
  v_Cnt     number;
begin
  -- 1) CORE_USERS qatori
  select count(*) into v_Cnt from Core.Core_Users where User_Id = c_User_Id;
  if v_Cnt = 0 then
    insert into Core.Core_Users
      (User_Id, Cb_Code, Local_Code, User_Type_Id, Name, Language, Theme_Id,
       Is_Access_Denied, Access_Level_Set, Group_Set, Debug, State,
       Activate_Date, Deactivate_Date, Created_By, Created_On, Modified_By, Modified_On)
    values
      (c_User_Id, '00440', '01000', 0, 'JOB SYSTEM USER', 'ru', 0,
       'Y', 0, Hextoraw('00'), 'Y', 'A',
       Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
       0, sysdate, 0, sysdate);
    Dbms_Output.Put_Line('OK: Core_Users(-200) yaratildi.');
  else
    Dbms_Output.Put_Line('Core_Users(-200) allaqachon mavjud - o''tkazib yuborildi.');
  end if;

  -- 2) SM_OBJECTS backfill (super_user/system_user/debug_user'dagi kabi) -
  --    agar biror SM jarayon bu user_id'ga murojaat qilsa, "obyekt topilmadi"
  --    xatosi bermasligi uchun
  select count(*) into v_Cnt from Sm_Objects where object_code = 'USER' and relation_id = c_User_Id;
  if v_Cnt = 0 then
    insert into Sm_Objects (object_id, parent_object_id, object_code, state,
      relation_id, parent_relation_id, created_on, created_by, modify_on, modify_by)
    values (Sm_Objects_Sq.nextval, null, 'USER', 'A',
      c_User_Id, null, sysdate, 0, sysdate, 0);
    Dbms_Output.Put_Line('OK: Sm_Objects(-200) yaratildi.');
  else
    Dbms_Output.Put_Line('Sm_Objects(-200) allaqachon mavjud - o''tkazib yuborildi.');
  end if;

  commit;
  Dbms_Output.Put_Line('=== Tayyor: JOB_USER (-200) sozlandi. ===');
exception
  when others then
    rollback;
    Dbms_Output.Put_Line('XATO: ' || sqlerrm);
    raise;
end;
/
