----------------------------------------------------------------------------------------------------
-- fix_process_access_log_enforce_columns.sql
--
-- CORE_PROCESS_ACCESS_LOG jadvalini LOG-bosqichdan ENFORCE (haqiqiy bloklash) bosqichiga
-- o'tishni qo'llab-quvvatlash uchun kerakli ustun/cheklovlar bilan kengaytiradigan bir
-- martalik, idempotent migratsiya:
--   1) ENFORCE_ACTION VARCHAR2(20) DEFAULT 'ALLOW' NOT NULL ustunini qo'shadi. 19c'da DEFAULT
--      qiymat bilan NOT NULL ustun qo'shish METADATA-ONLY operatsiya (jismoniy UPDATE talab
--      qilinmaydi) - jadvalda allaqachon qator bo'lsa ham xavfsiz va tez.
--   2) CORE_PROCESS_ACCESS_LOG_C2 (outcome domeni) ni 'NO_USER_CTX', 'GUARD_ERROR' va
--      'FOREIGN_PROCESS_ID' (F2 - process_id-based rerun'da chet foydalanuvchi jarayoni)
--      qiymatlari bilan kengaytiradi (DROP + CREATE, faqat hali kengaytirilmagan bo'lsa).
--   3) CORE_PROCESS_ACCESS_LOG_C4 (enforce_action domeni: ALLOW/BLOCK/WARN_BYPASS) qo'shadi.
--   4) PROCESS_ID ustunini VARCHAR2(100)'dan NUMBER(10)'ga o'tkazadi (F7 - Core_Api.pck
--      i_Process_Id number sifatida (Get_Optional_Number) yuboradi, ustun turi mos kelishi
--      shart). Ustunda allaqachon (bo'sh bo'lmagan) ma'lumot bo'lsa - MODIFY XAVFLI (mumkin
--      bo'lgan raqam-bo'lmagan qiymatlar/ORA-01439), shu sabab avval bo'shligi tekshiriladi -
--      bo'sh bo'lmasa, aniq xato bilan to'xtaydi (qo'lda tekshirish/konvertatsiya talab
--      qilinadi), avtomatik "aql bilan taxmin qilib" konvertatsiya qilinmaydi.
--
-- Har bir qadam avval mavjud holatni tekshiradi (USER_TAB_COLUMNS / USER_CONSTRAINTS,
-- C2 uchun esa SEARCH_CONDITION_VC ichidagi domenning o'zi) - skript necha marta qayta
-- ishga tushirilsa ham xavfsiz. Jadvalda allaqachon LOG-bosqich trafigi (qatorlar) bor deb
-- FARAZ QILINADI (fresh-deploy emas) - shu sabab ENFORCE_ACTION DEFAULT bilan qo'shiladi,
-- mavjud qatorlar avtomatik 'ALLOW' oladi (LOG-bosqichda hech narsa bloklanmagani bilan mos).
--
-- YANGI deploy uchun bu emas, balki to'liq DDL bo'lgan access/tables/CORE_PROCESS_ACCESS_LOG.sql
-- ishlatiladi (shu fayl bilan bir xil final shaklga yangilangan) - ushbu migratsiya fresh deploy
-- vaqtida hech qanday amaliy o'zgarish kiritmaydi (barcha qadamlar "allaqachon mavjud" holatda
-- o'tkazib yuboriladi), faqat allaqachon jonli/populyatsiyalangan (bu jadval oldingi, tor
-- shaklda allaqachon mavjud) muhitlar uchun kerak.
--
-- DIQQAT - BU DDL / MIGRATSIYA: ishga tushirishdan OLDIN lead/reviewer tasdig'i SHART.
--
-- Run as CORE schema owner.
----------------------------------------------------------------------------------------------------
-- ROLLBACK (agar migratsiyani bekor qilish kerak bo'lsa - qo'lda, teskari tartibda bajaring):
--
-- DIQQAT (live-deploy tartibi): agar joriy (ENFORCE_ACTION/kengaytirilgan outcome domenidan
-- foydalanadigan) Core_Api.pck ushbu migratsiyadan KEYIN allaqachon deploy qilingan bo'lsa -
-- avval Core_Api.pck'ning OLDINGI (shu ustun/domendan foydalanmaydigan) paket tanasini qayta
-- kompilyatsiya qiling, FAQAT SHUNDAN KEYIN quyidagini bajaring - aks holda joriy paket
-- darhol INVALID bo'lib, Execute_Process_Clob/Get_Model_Clob dispatcher to'xtaydi.
--
--   alter table CORE_PROCESS_ACCESS_LOG drop constraint CORE_PROCESS_ACCESS_LOG_C4;
--   alter table CORE_PROCESS_ACCESS_LOG drop constraint CORE_PROCESS_ACCESS_LOG_C2;
--   alter table CORE_PROCESS_ACCESS_LOG add constraint CORE_PROCESS_ACCESS_LOG_C2
--     check (outcome in ('MAPPED_AUTHORIZED', 'MAPPED_DENIED', 'UNMAPPED', 'WRONG_DOOR_TYPE'));
--   alter table CORE_PROCESS_ACCESS_LOG drop column ENFORCE_ACTION;
--   -- PROCESS_ID'ni orqaga (NUMBER(10) -> VARCHAR2(100)) qaytarish - faqat Step 4 ishga
--   -- tushirilgan bo'lsa kerak (ustun bo'sh bo'lgandagina Step 4 haqiqatan MODIFY qiladi):
--   alter table CORE_PROCESS_ACCESS_LOG modify (process_id VARCHAR2(100));
--   commit;
--
-- DIQQAT: yuqoridagi ROLLBACK ENFORCE_ACTION ustunidagi barcha ma'lumotni QAYTARIB
-- BO'LMAYDIGAN tarzda yo'qotadi - shu sabab ATAYLAB avtomatik emas, qo'lda bajariladi.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Step 1: ENFORCE_ACTION ustunini DEFAULT 'ALLOW' NOT NULL bilan qo'shish
----------------------------------------------------------------------------------------------------
declare
  v_Cnt number;
begin
  select count(*)
    into v_Cnt
    from user_tab_columns
   where table_name = 'CORE_PROCESS_ACCESS_LOG'
     and column_name = 'ENFORCE_ACTION';
  if v_Cnt = 0 then
    execute immediate 'alter table CORE_PROCESS_ACCESS_LOG add ' ||
                      '(ENFORCE_ACTION VARCHAR2(20) DEFAULT ''ALLOW'' NOT NULL)';
    Dbms_Output.Put_Line('ENFORCE_ACTION ustuni qo''shildi (DEFAULT ''ALLOW'' NOT NULL, metadata-only).');
  else
    Dbms_Output.Put_Line('ENFORCE_ACTION ustuni allaqachon mavjud, o''tkazib yuborildi.');
  end if;
end;
/

----------------------------------------------------------------------------------------------------
-- Step 2: CORE_PROCESS_ACCESS_LOG_C2 (outcome domeni) - 'NO_USER_CTX', 'GUARD_ERROR' va
-- 'FOREIGN_PROCESS_ID' (F2) qiymatlari bilan kengaytirish. Joriy domen SEARCH_CONDITION_VC
-- ichida 'FOREIGN_PROCESS_ID' borligiga qarab tekshiriladi (eng so'nggi/eng keng domen
-- belgisi) - agar allaqachon shu darajada kengaytirilgan bo'lsa, DROP+CREATE qilinmaydi
-- (haqiqiy idempotentlik, shunchaki nomga qarab emas; bu shuningdek eski - faqat
-- NO_USER_CTX/GUARD_ERROR bilan kengaytirilgan, lekin FOREIGN_PROCESS_ID'siz - holatni ham
-- to'g'ri qayta kengaytiradi).
----------------------------------------------------------------------------------------------------
declare
  v_Cnt          number;
  v_Search       user_constraints.search_condition_vc%type;
  v_Already_New  boolean := false;
begin
  select count(*)
    into v_Cnt
    from user_constraints
   where table_name      = 'CORE_PROCESS_ACCESS_LOG'
     and constraint_name = 'CORE_PROCESS_ACCESS_LOG_C2';
  --
  if v_Cnt > 0 then
    select search_condition_vc
      into v_Search
      from user_constraints
     where table_name      = 'CORE_PROCESS_ACCESS_LOG'
       and constraint_name = 'CORE_PROCESS_ACCESS_LOG_C2';
    if Instr(Nvl(v_Search, ' '), 'FOREIGN_PROCESS_ID') > 0 then
      v_Already_New := true;
    end if;
  end if;
  --
  if v_Already_New then
    Dbms_Output.Put_Line('CORE_PROCESS_ACCESS_LOG_C2 allaqachon kengaytirilgan domenda (NO_USER_CTX/GUARD_ERROR/FOREIGN_PROCESS_ID bor), o''tkazib yuborildi.');
  else
    if v_Cnt > 0 then
      execute immediate 'alter table CORE_PROCESS_ACCESS_LOG drop constraint CORE_PROCESS_ACCESS_LOG_C2';
      Dbms_Output.Put_Line('Eski (tor) CORE_PROCESS_ACCESS_LOG_C2 cheklovi olib tashlandi.');
    end if;
    execute immediate 'alter table CORE_PROCESS_ACCESS_LOG add constraint CORE_PROCESS_ACCESS_LOG_C2 ' ||
                      'check (outcome in (''MAPPED_AUTHORIZED'', ''MAPPED_DENIED'', ''UNMAPPED'', ' ||
                      '''WRONG_DOOR_TYPE'', ''NO_USER_CTX'', ''GUARD_ERROR'', ''FOREIGN_PROCESS_ID''))';
    Dbms_Output.Put_Line('CORE_PROCESS_ACCESS_LOG_C2 cheklovi (kengaytirilgan domen: +NO_USER_CTX +GUARD_ERROR +FOREIGN_PROCESS_ID) qo''shildi.');
  end if;
end;
/

----------------------------------------------------------------------------------------------------
-- Step 3: CORE_PROCESS_ACCESS_LOG_C4 (enforce_action domeni) qo'shish
----------------------------------------------------------------------------------------------------
declare
  v_Cnt number;
begin
  select count(*)
    into v_Cnt
    from user_constraints
   where table_name      = 'CORE_PROCESS_ACCESS_LOG'
     and constraint_name = 'CORE_PROCESS_ACCESS_LOG_C4';
  if v_Cnt = 0 then
    execute immediate 'alter table CORE_PROCESS_ACCESS_LOG add constraint CORE_PROCESS_ACCESS_LOG_C4 ' ||
                      'check (enforce_action in (''ALLOW'', ''BLOCK'', ''WARN_BYPASS''))';
    Dbms_Output.Put_Line('CORE_PROCESS_ACCESS_LOG_C4 cheklovi qo''shildi.');
  else
    Dbms_Output.Put_Line('CORE_PROCESS_ACCESS_LOG_C4 cheklovi allaqachon mavjud, o''tkazib yuborildi.');
  end if;
end;
/

----------------------------------------------------------------------------------------------------
-- Step 4: PROCESS_ID ustunini VARCHAR2(100)'dan NUMBER(10)'ga o'tkazish (F7 - Core_Api.pck
-- Get_Optional_Number('process_id') orqali number sifatida o'qiydi va Write_Access_Log'ga
-- i_Process_Id number parametr sifatida uzatadi - ustun turi mos kelmasa implicit
-- conversion'ga tayaniladi, bu xavfli/nomaqbul). Idempotent: ustun turi allaqachon NUMBER
-- bo'lsa o'tkazib yuboriladi. VARCHAR2 bo'lsa - MODIFY dan OLDIN ustunda (bo'sh bo'lmagan)
-- ma'lumot yo'qligi tekshiriladi: bunday ma'lumot bo'lsa, avtomatik "aql bilan taxmin qilib"
-- konvertatsiya qilinMAYDI (raqam bo'lmagan qiymatlar ORA-01722/01439 bilan buzilishi yoki
-- jimgina noto'g'ri natija berishi mumkin) - buning o'rniga aniq xabar bilan RAISE qilinadi,
-- qo'lda tekshirish/konvertatsiya talab qilinadi.
----------------------------------------------------------------------------------------------------
declare
  v_Data_Type     user_tab_columns.data_type%type;
  v_Non_Null_Cnt  number;
begin
  begin
    select data_type
      into v_Data_Type
      from user_tab_columns
     where table_name  = 'CORE_PROCESS_ACCESS_LOG'
       and column_name = 'PROCESS_ID';
  exception
    when No_Data_Found then
      -- Legacy/chetga chiqqan jadval varianti PROCESS_ID ustunini UMUMAN o'z ichiga olmasligi
      -- mumkin (select yuqorida ORA-01403 beradi) - bunday holda convert-in-place mantiqiga
      -- zarurat yo'q, ustunni to'g'ridan-to'g'ri yangi (NUMBER(10)) sifatida qo'shamiz (fayldagi
      -- boshqa qadamlar bilan bir xil existence-check-before-DDL naqshi; No_Data_Found'ning o'zi
      -- ustun mavjud emasligini isbotlaydi, qo'shimcha tekshiruv shart emas).
      execute immediate 'alter table CORE_PROCESS_ACCESS_LOG add (process_id NUMBER(10))';
      Dbms_Output.Put_Line('PROCESS_ID ustuni topilmadi - yangi NUMBER(10) ustun sifatida qo''shildi.');
      v_Data_Type := null;
  end;
  --
  if v_Data_Type is null then
    null; -- yuqoridagi No_Data_Found shoxobchasida allaqachon hal qilindi (ustun qo'shildi).
  elsif v_Data_Type = 'NUMBER' then
    Dbms_Output.Put_Line('PROCESS_ID ustuni allaqachon NUMBER, o''tkazib yuborildi.');
  else
    select count(*)
      into v_Non_Null_Cnt
      from CORE_PROCESS_ACCESS_LOG
     where process_id is not null;
    --
    if v_Non_Null_Cnt > 0 then
      Raise_Application_Error(-20050,
        'PROCESS_ID ustunida ' || v_Non_Null_Cnt || ' ta bo''sh bo''lmagan qator bor - ' ||
        'avtomatik VARCHAR2->NUMBER(10) MODIFY XAVFLI (raqam bo''lmagan qiymatlar bo''lishi ' ||
        'mumkin). Qo''lda tekshiring/konvertatsiya qiling (masalan mavjud qiymatlarni ' ||
        'To_Number bilan yangi ustunga ko''chirib, so''ng eskisini almashtirib), so''ng shu ' ||
        'qadamni qayta ishga tushiring.');
    else
      execute immediate 'alter table CORE_PROCESS_ACCESS_LOG modify (process_id NUMBER(10))';
      Dbms_Output.Put_Line('PROCESS_ID ustuni NUMBER(10)''ga o''tkazildi (ustun bo''sh edi, xavfsiz).');
    end if;
  end if;
end;
/

----------------------------------------------------------------------------------------------------
-- Verification
----------------------------------------------------------------------------------------------------
column column_name format a20
column constraint_name format a30
column constraint_type format a5
select column_name, data_type, data_length, nullable, data_default
  from user_tab_cols
 where table_name = 'CORE_PROCESS_ACCESS_LOG'
 order by column_id;

select constraint_name, constraint_type, status
  from user_constraints
 where table_name = 'CORE_PROCESS_ACCESS_LOG'
 order by constraint_type, constraint_name;

-- Agar yuqoridagi natijalar kutilganidek bo'lsa (ENFORCE_ACTION mavjud/NOT NULL/DEFAULT 'ALLOW',
-- C2 kengaytirilgan domenda, C4 mavjud va ENABLED), commit qiling. Aks holda investigatsiya qiling.
-- commit;
