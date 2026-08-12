----------------------------------------------------------------------------------------------------
--  DEBUG_USER (user_id=-100) - Auth_Session.Open_Debug_Session tomonidan
--  ishlatiladigan yagona sun'iy foydalanuvchi. Haqiqiy xodim EMAS, hech
--  qachon LOCAL login/parol bilan ta'minlanmaydi (JSP orqali kirib
--  bo'lmaydi) - faqat sqlplus'dan to'g'ridan-to'g'ri CORE ulanishi orqali
--  Open_Debug_Session chaqirilganda UAPP kontekstiga o'rnatiladi.
--
--  cb_code/local_code pastda faqat NOT NULL ustunni to'ldirish uchun -
--  haqiqiy debug-sessiyada bular Open_Debug_Session(i_Cb_Code yoki
--  i_Local_Code, i_Reason) parametrlari orqali Abs_Branches'dan olinib,
--  sessiya kontekstida ustidan yoziladi (bu jadval qatoriga tegilmaydi).
--
--  Ishga tushirish: CORE schema egasi sifatida (bir marta, idempotent).
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  c_User_Id constant number := -100;
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
      (c_User_Id, '00440', '01000', 0, 'DEBUG SESSION USER', 'ru', 0,
       'N', 0, Hextoraw('00'), 'Y', 'A',
       Trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'),
       0, sysdate, 0, sysdate);
    Dbms_Output.Put_Line('OK: Core_Users(-100) yaratildi.');
  else
    Dbms_Output.Put_Line('Core_Users(-100) allaqachon mavjud - o''tkazib yuborildi.');
  end if;

  -- 2) Barcha mavjud menyularga to'liq ruxsat (sidebar to'liq ko'rinishi uchun)
  --    DISTINCT: Core_R_Menus'ning PK'si (module_code, menu_id) - ya'ni
  --    menu_id o'zi yagona emas, boshqa modulda takrorlanishi mumkin.
  --    ADM_REL_USER_MENUS esa faqat (user_id, menu_id) bo'yicha yagona -
  --    takroriy menu_id ikkinchi marta kiritilsa ORA-00001 berardi.
  --    2026-08-04: CORE_REL_USER_MENUS (eski nom) rename_old_user_rel_tables.sql bilan
  --    _BAK_20260729'ga o'tkazilgan - haqiqiy grant-yozish endi ADM_REL_USER_MENUS orqali
  --    (Core_Sidebar.pck ham shundan o'qiydi).
  insert into Core.ADM_REL_USER_MENUS
    (user_id, menu_id, date_activate, date_deactivate, state, created_by, created_on, modify_by, modify_on)
  select c_User_Id, m.menu_id, trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'), 'A', 0, sysdate, 0, sysdate
    from (select distinct menu_id from Core.Core_R_Menus where state = 'A') m
   where not exists (select 1 from Core.ADM_REL_USER_MENUS x
                      where x.user_id = c_User_Id and x.menu_id = m.menu_id);
  Dbms_Output.Put_Line('OK: ADM_REL_USER_MENUS(-100) - barcha faol menyular biriktirildi.');

  -- 3) SM_OBJECTS backfill (super_user/system_user'dagi kabi) - EDIT_USER
  --    kabi SM jarayonlar bu user_id uchun ham ishlashi uchun
  select count(*) into v_Cnt from Sm_Objects where object_code = 'USER' and relation_id = c_User_Id;
  if v_Cnt = 0 then
    insert into Sm_Objects (object_id, parent_object_id, object_code, state,
      relation_id, parent_relation_id, created_on, created_by, modify_on, modify_by)
    values (Sm_Objects_Sq.nextval, null, 'USER', 'A',
      c_User_Id, null, sysdate, 0, sysdate, 0);
    Dbms_Output.Put_Line('OK: Sm_Objects(-100) yaratildi.');
  else
    Dbms_Output.Put_Line('Sm_Objects(-100) allaqachon mavjud - o''tkazib yuborildi.');
  end if;

  commit;
  Dbms_Output.Put_Line('=== Tayyor: DEBUG_USER (-100) sozlandi. ===');
exception
  when others then
    rollback;
    Dbms_Output.Put_Line('XATO: ' || sqlerrm);
    raise;
end;
/
