----------------------------------------------------------------------------------------------------
-- fix_menu_buttons_process_link.sql
--
-- Jonli (live) muhitda allaqachon mavjud, ESKI shakldagi CORE_R_MENU_BUTTONS jadvaliga
-- SM_R_PROCESSES bilan bog'lanish ustunlarini (PROCESS_CODE, MODEL_PROCESS_CODE),
-- audit ustunlarini (CREATED_BY/ON, MODIFY_BY/ON), indekslarni, FK'larni va
-- CORE_R_MENU_BUTTONS_C1 check cheklovini qo'shadigan bir martalik, idempotent
-- migratsiya. Har bir qadam avval mavjudligini tekshiradi (User_Tab_Columns /
-- User_Constraints / User_Indexes) - skript necha marta qayta ishga tushirilsa ham
-- xavfsiz. YANGI deploy uchun bu emas, balki to'liq DDL bo'lgan
-- access/tables/CORE_R_MENU_BUTTONS.sql ishlatiladi.
--
-- DIQQAT - BU DDL / MIGRATSIYA: ishga tushirishdan OLDIN lead/reviewer tasdig'i SHART.
--
-- Run as CORE schema owner.
----------------------------------------------------------------------------------------------------
-- LIVE-DEPLOY TARTIBI (MAJBURIY KETMA-KETLIK) - jonli/populyatsiyalangan muhitda:
--
-- Core_Api.pck (paket tanasi) process-code guard uchun Core_Process_Access_Log va
-- Core_Process_Access_Log_Sq obyektlariga QATTIQ (hard) murojaat qiladi (Log_Process_Access
-- ichida INSERT/NEXTVAL). Agar Core_Api.pck bu obyektlar hali mavjud bo'lmasdan turib
-- rekompilyatsiya qilinsa - paket tanasi INVALID bo'lib qoladi va shu paytdan boshlab HAR
-- QANDAY Execute_Process_Clob / Get_Model_Clob chaqiruvi ORA-04063 bilan yiqiladi - bu
-- dispatcher'ning eng "issiq" kirish nuqtasi, ya'ni TO'LIQ TO'XTASH (total outage).
-- Shu sabab quyidagi tartib QAT'IY bajarilishi SHART (birma-bir, har birini kutib):
--
--   1) access/packages/fix_menu_buttons_process_link.sql   (shu fayl)
--   2) access/sequences/CORE_PROCESS_ACCESS_LOG_SQ.sql
--   3) access/tables/CORE_PROCESS_ACCESS_LOG.sql
--   4) access/views/menu_button_wiring_v.sql
--   5) core/package/Core_Api.pck                            (paketni ENG OXIRIDA kompilyatsiya qiling)
--   6) Tekshiruv - quyidagi so'rov CORE_API'ga tegishli birorta ham qator QAYTARMASLIGI SHART,
--      aks holda deploy tugallangan hisoblanmaydi:
--        select object_name, status from user_objects where status = 'INVALID';
--
-- ROLLBACK TARTIBI (teskari) - agar deploy bekor qilinishi kerak bo'lsa:
--   avval Core_Api.pck'ning OLDINGI (guard-dan OLDINGI) paket tanasini qayta kompilyatsiya
--   qiling, va FAQAT SHUNDAN KEYIN Core_Process_Access_Log / Core_Process_Access_Log_Sq /
--   menu_button_wiring_v'ni DROP qiling. Jadval/ketma-ketlikni joriy (guard bilan) Core_Api.pck
--   HALI LIVE bo'lgan holatda DROP qilish MUTLAQO TAQIQLANADI - bu paketni darhol INVALID
--   qilib, xuddi shu dispatcher to'xtashiga olib keladi.
----------------------------------------------------------------------------------------------------
--
-- ISHGA TUSHIRISHDAN OLDIN QO'LDA TEKSHIRISH (natijalarni saqlab qo'ying):
----------------------------------------------------------------------------------------------------
--   -- 1) SM_R_PROCESSES mavjudligi (FK talab qiladi):
--   select count(*) from user_tables where table_name = 'SM_R_PROCESSES';
--
--   -- 2) joriy ustunlar (qaysilari allaqachon qo'shilgan bo'lishi mumkin):
--   select column_name, data_type, data_length, nullable
--     from user_tab_columns
--    where table_name = 'CORE_R_MENU_BUTTONS'
--    order by column_id;
--
--   -- 3) STATE ustunidagi joriy qiymatlar (C1 cheklovi 'A'/'P' dan boshqasini
--   --    qabul qilmaydi - bad qatorlar bo'lsa C1 qo'shilmaydi, skript pastda ogohlantiradi):
--   select state, count(*) from CORE_R_MENU_BUTTONS group by state;
--
--   -- 4) agar PROCESS_CODE / MODEL_PROCESS_CODE ustunlari allaqachon mavjud bo'lib,
--   --    ularda qiymat bo'lsa - FK muvaffaqiyatsiz bo'lmasligi uchun SM_R_PROCESSES'da
--   --    yo'q qiymatlarni oldindan aniqlash:
--   select distinct process_code from CORE_R_MENU_BUTTONS
--    where process_code is not null
--    minus
--   select process_code from SM_R_PROCESSES;
--
--   select distinct model_process_code from CORE_R_MENU_BUTTONS
--    where model_process_code is not null
--    minus
--   select process_code from SM_R_PROCESSES;
----------------------------------------------------------------------------------------------------
-- TRANZAKSIYA CHEGARASI HAQIDA MUHIM ESLATMA: Step 1-2-3 oddiy DML/qatorlarni to'ldirish
-- (COMMIT ATAYLAB yo'q - shu sababli ular hali qo'lda ROLLBACK qilinishi mumkin bo'lgan
-- bitta tranzaksiya ichida). LEKIN Step 4'dan boshlab har bir qadam DDL (ALTER TABLE / CREATE
-- INDEX) - Oracle DDL o'zidan OLDIN va KEYIN AVTOMATIK COMMIT qiladi. Demak Step 4 ishga
-- tushishi bilanoq Step 1-3'dagi barcha o'zgarishlar ALLAQACHON commit qilingan bo'ladi -
-- bu nuqtadan keyin oddiy ROLLBACK bilan orqaga qaytarib bo'lmaydi. Step 1-3 - bekor qilish
-- uchun OXIRGI imkoniyat (shunchaki keyingi qadamlarni ishga tushirmaslik orqali); Step 4'dan
-- keyin faqat pastdagi ROLLBACK bo'limidagi qo'lda kompensatsion DDL orqali orqaga qaytarish
-- mumkin - haqiqiy tranzaksion rollback nuqtasi YO'Q.
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Step 1: PROCESS_CODE / MODEL_PROCESS_CODE ustunlarini NULL-ga ruxsat berilgan holda qo'shish
----------------------------------------------------------------------------------------------------
declare
  v_Cnt number;
  procedure Add_Column(i_Column_Name varchar2, i_Ddl varchar2) is
  begin
    select count(*)
      into v_Cnt
      from user_tab_columns
     where table_name = 'CORE_R_MENU_BUTTONS'
       and column_name = i_Column_Name;
    if v_Cnt = 0 then
      execute immediate i_Ddl;
      Dbms_Output.Put_Line(i_Column_Name || ' ustuni qo''shildi.');
    else
      Dbms_Output.Put_Line(i_Column_Name || ' ustuni allaqachon mavjud, o''tkazib yuborildi.');
    end if;
  end Add_Column;
begin
  Add_Column('PROCESS_CODE', 'alter table CORE_R_MENU_BUTTONS add (PROCESS_CODE VARCHAR2(100))');
  Add_Column('MODEL_PROCESS_CODE', 'alter table CORE_R_MENU_BUTTONS add (MODEL_PROCESS_CODE VARCHAR2(100))');
end;
/

----------------------------------------------------------------------------------------------------
-- Step 2: audit ustunlarini (CREATED_BY, CREATED_ON, MODIFY_BY, MODIFY_ON) avval
-- NULL-ga ruxsat berilgan holda qo'shish - to'g'ridan-to'g'ri NOT NULL qilib
-- qo'shib bo'lmaydi, chunki jadvalda allaqachon qator bor.
----------------------------------------------------------------------------------------------------
declare
  v_Cnt number;
  procedure Add_Column(i_Column_Name varchar2, i_Ddl varchar2) is
  begin
    select count(*)
      into v_Cnt
      from user_tab_columns
     where table_name = 'CORE_R_MENU_BUTTONS'
       and column_name = i_Column_Name;
    if v_Cnt = 0 then
      execute immediate i_Ddl;
      Dbms_Output.Put_Line(i_Column_Name || ' ustuni qo''shildi (NULL ga ruxsat berilgan holda).');
    else
      Dbms_Output.Put_Line(i_Column_Name || ' ustuni allaqachon mavjud, o''tkazib yuborildi.');
    end if;
  end Add_Column;
begin
  Add_Column('CREATED_BY', 'alter table CORE_R_MENU_BUTTONS add (CREATED_BY NUMBER(10))');
  Add_Column('CREATED_ON', 'alter table CORE_R_MENU_BUTTONS add (CREATED_ON DATE)');
  Add_Column('MODIFY_BY', 'alter table CORE_R_MENU_BUTTONS add (MODIFY_BY NUMBER(10))');
  Add_Column('MODIFY_ON', 'alter table CORE_R_MENU_BUTTONS add (MODIFY_ON DATE)');
end;
/

----------------------------------------------------------------------------------------------------
-- Step 3: mavjud qatorlarni sentinel qiymat bilan to'ldirish (CREATED_BY/MODIFY_BY = -1 -
-- "migratsiya orqali", CREATED_ON/MODIFY_ON = sysdate) - Step 4'da NOT NULL qo'yish uchun shart.
-- DIQQAT: sentinel sifatida 0 EMAS, -1 ishlatiladi - Auth_Session.Set_System_Actor(i_User_Id
-- default 0) kodda 0'ni "SYSTEM USER" (haqiqiy tizim-actor yozuvi) sifatida hujjatlashtiradi;
-- agar bu backfill ham 0'ni ishlatsa, migratsiya orqali to'ldirilgan eski qatorlar haqiqiy
-- system-actor yozuvidan farqlanmaydigan bo'lib qoladi. -1 hech qachon Set_System_Actor orqali
-- ishlatilmaydi, shu bilan "bu qator migratsiya orqali backfill qilingan, haqiqiy actor emas"
-- degani aniq ajratiladi.
-- COMMIT bu yerda YO'Q - transaction nazorati skript oxirida, qo'lda (lekin pastdagi Step 4
-- izohiga qarang - Step 4'dan boshlab bu haqiqiy emas, DDL avtomatik commit qiladi).
----------------------------------------------------------------------------------------------------
declare
  v_Rows number;
begin
  update CORE_R_MENU_BUTTONS
     set created_by = -1,
         created_on = sysdate,
         modify_by  = -1,
         modify_on  = sysdate
   where created_by is null
      or created_on is null
      or modify_by is null
      or modify_on is null;
  v_Rows := sql%rowcount;
  Dbms_Output.Put_Line(v_Rows || ' ta qatorda audit ustunlari sentinel (created_by/modify_by=-1, sysdate) qiymat bilan to''ldirildi.');
end;
/

----------------------------------------------------------------------------------------------------
-- Step 4: audit ustunlarini NOT NULL qilib belgilash (faqat hali NULL-ga ruxsat berilgan bo'lsa)
----------------------------------------------------------------------------------------------------
declare
  v_Nullable user_tab_columns.nullable%type;
  procedure Set_Not_Null(i_Column_Name varchar2) is
  begin
    select nullable
      into v_Nullable
      from user_tab_columns
     where table_name = 'CORE_R_MENU_BUTTONS'
       and column_name = i_Column_Name;
    if v_Nullable = 'Y' then
      execute immediate 'alter table CORE_R_MENU_BUTTONS modify (' || i_Column_Name || ' not null)';
      Dbms_Output.Put_Line(i_Column_Name || ' NOT NULL qilib belgilandi.');
    else
      Dbms_Output.Put_Line(i_Column_Name || ' allaqachon NOT NULL, o''tkazib yuborildi.');
    end if;
  end Set_Not_Null;
begin
  Set_Not_Null('CREATED_BY');
  Set_Not_Null('CREATED_ON');
  Set_Not_Null('MODIFY_BY');
  Set_Not_Null('MODIFY_ON');
end;
/

----------------------------------------------------------------------------------------------------
-- Step 5: CORE_R_MENU_BUTTONS_I2 (PROCESS_CODE) va CORE_R_MENU_BUTTONS_I3 (MODEL_PROCESS_CODE)
-- indekslarini yaratish - I1 bilan bir xil tablespace/pctfree/initrans/maxtrans.
----------------------------------------------------------------------------------------------------
declare
  v_Cnt number;
  procedure Create_Index(i_Index_Name varchar2, i_Ddl varchar2) is
  begin
    select count(*)
      into v_Cnt
      from user_indexes
     where index_name = i_Index_Name;
    if v_Cnt = 0 then
      execute immediate i_Ddl;
      Dbms_Output.Put_Line(i_Index_Name || ' indeksi yaratildi.');
    else
      Dbms_Output.Put_Line(i_Index_Name || ' indeksi allaqachon mavjud, o''tkazib yuborildi.');
    end if;
  end Create_Index;
begin
  Create_Index('CORE_R_MENU_BUTTONS_I2',
               'create index CORE_R_MENU_BUTTONS_I2 on CORE_R_MENU_BUTTONS (PROCESS_CODE) ' ||
               'tablespace CORE_INDEX pctfree 10 initrans 2 maxtrans 255');
  Create_Index('CORE_R_MENU_BUTTONS_I3',
               'create index CORE_R_MENU_BUTTONS_I3 on CORE_R_MENU_BUTTONS (MODEL_PROCESS_CODE) ' ||
               'tablespace CORE_INDEX pctfree 10 initrans 2 maxtrans 255');
end;
/

----------------------------------------------------------------------------------------------------
-- Step 6: CORE_R_MENU_BUTTONS_FK1 (PROCESS_CODE) va CORE_R_MENU_BUTTONS_FK2 (MODEL_PROCESS_CODE)
-- cheklovlarini SM_R_PROCESSES (PROCESS_CODE) ga qo'shish.
----------------------------------------------------------------------------------------------------
declare
  v_Cnt number;
  procedure Add_Fk(i_Constraint_Name varchar2, i_Ddl varchar2) is
  begin
    select count(*)
      into v_Cnt
      from user_constraints
     where constraint_name = i_Constraint_Name;
    if v_Cnt = 0 then
      execute immediate i_Ddl;
      Dbms_Output.Put_Line(i_Constraint_Name || ' cheklovi qo''shildi.');
    else
      Dbms_Output.Put_Line(i_Constraint_Name || ' cheklovi allaqachon mavjud, o''tkazib yuborildi.');
    end if;
  end Add_Fk;
begin
  Add_Fk('CORE_R_MENU_BUTTONS_FK1',
         'alter table CORE_R_MENU_BUTTONS add constraint CORE_R_MENU_BUTTONS_FK1 ' ||
         'foreign key (PROCESS_CODE) references SM_R_PROCESSES (PROCESS_CODE)');
  Add_Fk('CORE_R_MENU_BUTTONS_FK2',
         'alter table CORE_R_MENU_BUTTONS add constraint CORE_R_MENU_BUTTONS_FK2 ' ||
         'foreign key (MODEL_PROCESS_CODE) references SM_R_PROCESSES (PROCESS_CODE)');
end;
/

----------------------------------------------------------------------------------------------------
-- Step 7: CORE_R_MENU_BUTTONS_C1 check (state in ('A','P')) - FAQAT mavjud qatorlarning
-- hech biri buni buzmasa qo'shiladi. Aks holda qo'shilmaydi va Dbms_Output orqali
-- ogohlantirish chiqadi (qatorlarni tozalab, skriptni qayta ishga tushirish kerak).
----------------------------------------------------------------------------------------------------
declare
  v_Cnt     number;
  v_Bad_Cnt number;
begin
  select count(*)
    into v_Cnt
    from user_constraints
   where constraint_name = 'CORE_R_MENU_BUTTONS_C1';
  if v_Cnt > 0 then
    Dbms_Output.Put_Line('CORE_R_MENU_BUTTONS_C1 cheklovi allaqachon mavjud, o''tkazib yuborildi.');
  else
    select count(*)
      into v_Bad_Cnt
      from CORE_R_MENU_BUTTONS
     where state not in ('A', 'P');
    if v_Bad_Cnt = 0 then
      execute immediate 'alter table CORE_R_MENU_BUTTONS add constraint CORE_R_MENU_BUTTONS_C1 ' ||
                        'check (state in (''A'', ''P''))';
      Dbms_Output.Put_Line('CORE_R_MENU_BUTTONS_C1 cheklovi qo''shildi.');
    else
      Dbms_Output.Put_Line('OGOHLANTIRISH: ' || v_Bad_Cnt ||
                           ' ta qatorda STATE ''A''/''P'' dan boshqa qiymat bor - ' ||
                           'CORE_R_MENU_BUTTONS_C1 cheklovi QO''SHILMADI. Avval shu qatorlarni ' ||
                           'tozalang (yoki STATE ni tuzating), so''ng skriptni qayta ishga tushiring.');
    end if;
  end if;
end;
/

----------------------------------------------------------------------------------------------------
-- ROLLBACK (agar migratsiyani bekor qilish kerak bo'lsa - quyidagini qo'lda, teskari
-- tartibda bajaring; audit ustunlarini DROP qilish orqali sentinel (created_by=-1,
-- Step 3'ga qarang) ma'lumot QAYTARIB BO'LMAYDIGAN tarzda yo'qoladi, shuning uchun
-- bu qadam ATAYLAB avtomatik emas):
--
-- DIQQAT (live-deploy tartibi): agar CORE_PROCESS_ACCESS_LOG / Core_Api.pck (guard)
-- ushbu migratsiyadan KEYIN allaqachon deploy qilingan bo'lsa - pastdagi ROLLBACK'ni
-- boshlashdan OLDIN yuqoridagi "LIVE-DEPLOY TARTIBI" bo'limidagi teskari tartibga
-- (rollback ordering) qarang: avval Core_Api.pck'ning OLDINGI (guard-dan oldingi)
-- paket tanasi qayta kompilyatsiya qilinadi, FAQAT SHUNDAN KEYIN CORE_PROCESS_ACCESS_LOG
-- jadvali/ketma-ketligi/view'i DROP qilinadi - aks holda joriy (guard bilan) Core_Api.pck
-- darhol INVALID bo'lib, Execute_Process_Clob/Get_Model_Clob orqali butun dispatcher
-- to'xtaydi.
----------------------------------------------------------------------------------------------------
-- alter table CORE_R_MENU_BUTTONS drop constraint CORE_R_MENU_BUTTONS_C1;
-- alter table CORE_R_MENU_BUTTONS drop constraint CORE_R_MENU_BUTTONS_FK2;
-- alter table CORE_R_MENU_BUTTONS drop constraint CORE_R_MENU_BUTTONS_FK1;
-- drop index CORE_R_MENU_BUTTONS_I3;
-- drop index CORE_R_MENU_BUTTONS_I2;
-- alter table CORE_R_MENU_BUTTONS drop column MODIFY_ON;
-- alter table CORE_R_MENU_BUTTONS drop column MODIFY_BY;
-- alter table CORE_R_MENU_BUTTONS drop column CREATED_ON;
-- alter table CORE_R_MENU_BUTTONS drop column CREATED_BY;
-- alter table CORE_R_MENU_BUTTONS drop column MODEL_PROCESS_CODE;
-- alter table CORE_R_MENU_BUTTONS drop column PROCESS_CODE;
-- commit;
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Verification
----------------------------------------------------------------------------------------------------
column column_name format a20
column constraint_name format a30
column constraint_type format a5
select column_name, data_type, data_length, nullable
  from user_tab_cols
 where table_name = 'CORE_R_MENU_BUTTONS'
 order by column_id;

select constraint_name, constraint_type, status
  from user_constraints
 where table_name = 'CORE_R_MENU_BUTTONS'
 order by constraint_type, constraint_name;

-- Agar yuqoridagi ikkala natija kutilganidek bo'lsa (PROCESS_CODE/MODEL_PROCESS_CODE,
-- audit ustunlari NOT NULL, FK1/FK2/C1 mavjud va ENABLED), commit qiling.
-- Aks holda investigatsiya qiling.
-- commit;
