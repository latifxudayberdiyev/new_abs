----------------------------------------------------------------------------------------------------
--  RDP (NEW_IABS)dan olingan ref_mahalla insertlarini cbr_mahalla ga yuklash.
--  Qadamlar:
--   1) Vaqtinchalik jadval (stg_ref_mahalla) - manba REF_MAHALLA tuzilishiga mos.
--   2) ins_mahalla.sql (yoki shunga o'xshash) faylidagi "insert into ref_mahalla"ni
--      "insert into stg_ref_mahalla" ga almashtirib, shu jadvalga yuklanadi.
--      MUHIM: fayl Windows-1251 kodировkada, shuning uchun uni ishga tushirishdan oldin:
--        set NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251
--   3) cbr_mahalla ga faqat har CODE_UZ_CAD bo'yicha ENG OXIRGI versiya (Date_Cancel/
--      Modified_On bo'yicha) o'tkaziladi - manba tarixiy (versiyalangan) jadval bo'lgani uchun.
--   4) Vaqtinchalik jadval tozalanadi.
----------------------------------------------------------------------------------------------------

-- 1) Vaqtinchalik jadval
create table stg_ref_mahalla
(  CODE_UZ_CAD VARCHAR2(10),
   CODE_1C VARCHAR2(8),
   INN VARCHAR2(9),
   REGION_ID VARCHAR2(4),
   SOATO_ID VARCHAR2(7),
   DISTR VARCHAR2(3),
   NAME_UZ VARCHAR2(50),
   NAME_RU VARCHAR2(50),
   NAME_EN VARCHAR2(50),
   DATE_OPEN DATE,
   DATE_CLOSE DATE,
   ACTIVE VARCHAR2(1),
   REF_UID NUMBER,
   DATE_APPLY DATE,
   DATE_CANCEL DATE,
   VERSION_ID NUMBER,
   MODIFIED_ON DATE,
   LABEL VARCHAR2(4000)
);

-- 2) Bu yerga (yoki alohida skript sifatida) manba insert fayli ishga tushiriladi:
--    @stg_load_mahalla.sql   (ins_mahalla.sql dan "ref_mahalla" -> "stg_ref_mahalla" almashtirilgan nusxa)

-- 3) cbr_mahalla ga eng oxirgi versiyalarni o'tkazish
insert into cbr_mahalla (Code_Uz_Cad, Code_1c, Inn, Region_Id, Soato_Id, Distr, Name_Uz, Name_Ru, Name_En, Date_Open, Date_Close, Active, Modify_On)
select Code_Uz_Cad, Code_1c, Inn, Region_Id, Soato_Id, Distr, Name_Uz, Name_Ru, Name_En, Date_Open, Date_Close, Active, Modified_On
  from (
    select trim(Code_Uz_Cad) Code_Uz_Cad, trim(Code_1c) Code_1c, trim(Inn) Inn, trim(Region_Id) Region_Id,
           trim(Soato_Id) Soato_Id, trim(Distr) Distr, trim(Name_Uz) Name_Uz, trim(Name_Ru) Name_Ru, trim(Name_En) Name_En,
           Date_Open, Date_Close, Active, Modified_On,
           row_number() over (partition by trim(Code_Uz_Cad) order by Date_Cancel desc, Modified_On desc) rn
      from stg_ref_mahalla
  )
 where rn = 1;
commit;

select 'cbr_mahalla: ' || count(*) from cbr_mahalla;

-- 4) Tozalash
drop table stg_ref_mahalla purge;
