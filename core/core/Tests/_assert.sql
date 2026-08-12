----------------------------------------------------------------------------------------------------
--  Umumiy PASS/FAIL assert protsedurasi - test skriptlari o'rtasida takrorlanadigan
--  v_Pass/v_Fail/Assert bloki (~15 qator har birida) o'rniga.
--
--  Ishlatish (test skriptining declare bo'limida, SQL*Plus @@ orqali):
--    declare
--      v_Pass number := 0;
--      v_Fail number := 0;
--      @@_assert.sql
--    begin
--      ...
--      Assert(v_Pass, v_Fail, 'nom', shart);
--      ...
--      Dbms_Output.Put_Line('--- Test XXX: PASS=' || v_Pass || ' FAIL=' || v_Fail);
--    end;
--    /
--
--  ESLATMA: bu fayl mustaqil kompilyatsiya birligi EMAS - u boshqa PL/SQL blokning
--  DECLARE bo'limi ichiga @@ orqali qo'yiladigan protsedura tanasi. Mavjud 12 ta test
--  skripti hozircha o'zining mahalliy Assert nusxasini saqlab qolmoqda (ular ishlab
--  turibdi - ularni bu umumiy fayldan foydalanadigan qilib qayta yozish sqlplus orqali
--  qayta tekshirilmaguncha amalga oshirilmadi); YANGI test skriptlari shu faylni
--  ishlatsin.
----------------------------------------------------------------------------------------------------
Procedure Assert
(
  io_Pass in out nocopy number,
  io_Fail in out nocopy number,
  i_Name  varchar2,
  i_Cond  boolean
) is
begin
  if i_Cond then
    io_Pass := io_Pass + 1;
    Dbms_Output.Put_Line('  PASS  ' || i_Name);
  else
    io_Fail := io_Fail + 1;
    Dbms_Output.Put_Line('  FAIL  ' || i_Name);
  end if;
end;
