----------------------------------------------------------------------------------------------------
--  super_user (User_Id=-1, bazadan tekshirilgan haqiqiy qiymat) uchun barcha
--  faol menyu/tugmalarga to'liq dostup.
--  create_super_user.sql hech qanday menu/button granti bermaydi (faqat login
--  yozuvini yaratadi) - shu skript uni ADM_REL_USER_MENUS/ADM_REL_USER_BUTTONS
--  orqali to'ldiradi. Idempotent (avval o'ziniki bo'lgan qatorlarni o'chirib,
--  qayta yozadi).
--  Ishga tushirish: sqlplus core/*** @core/auth/grant_super_user_full_access.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;

declare
  c_User_Id constant number := -1;
  v_Menu_Cnt   number;
  v_Button_Cnt number;
begin
  delete from Adm_Rel_User_Buttons where user_id = c_User_Id;
  delete from Adm_Rel_User_Menus   where user_id = c_User_Id;

  insert into Adm_Rel_User_Menus
    (user_id, menu_id, date_activate, date_deactivate, state,
     created_by, created_on, modify_by, modify_on)
  select c_User_Id, m.menu_id, trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'), 'A',
         c_User_Id, sysdate, c_User_Id, sysdate
    from Core_R_Menus m
   where m.state = 'A';
  v_Menu_Cnt := sql%rowcount;

  insert into Adm_Rel_User_Buttons
    (user_id, button_id, menu_id, date_activate, date_deactivate, state,
     created_by, created_on, modify_by, modify_on)
  select c_User_Id, b.button_id, b.menu_id, trunc(sysdate) - 1, to_date('31.12.9999', 'dd.mm.yyyy'), 'A',
         c_User_Id, sysdate, c_User_Id, sysdate
    from Core_R_Menu_Buttons b
    join Core_R_Menus m on m.menu_id = b.menu_id
   where b.state = 'A'
     and m.state = 'A';
  v_Button_Cnt := sql%rowcount;

  commit;
  Dbms_Output.Put_Line('OK: super_user uchun ' || v_Menu_Cnt || ' ta menyu, ' || v_Button_Cnt || ' ta tugma granti berildi.');
exception
  when others then
    rollback;
    Dbms_Output.Put_Line('XATO: ' || sqlerrm);
    raise;
end;
/
