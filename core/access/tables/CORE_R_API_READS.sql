----------------------------------------------------------------------------------------------------
-- "Bitta eshik" - JSP tomonidan so'raladigan, GET turidagi (holatsiz) o'qishlar reestri.
-- SM_R_PROCESSES'dan ATAYLAB ALOHIDA: u obyekt-hayot-sikli (object_code/state) talab
-- qiladi, sidebar/dashboard kabi holatsiz o'qishlar uchun bu yolg'on obyekt yaratishga
-- majbur qilardi. Bu jadval FAQAT kod -> protsedura xaritasi - hech qanday ruxsat
-- ma'lumoti saqlamaydi (kim nimani ko'rishi mumkinligi ADM_REL_USER_MENUS /
-- ADM_REL_USER_BUTTONS'dan hisoblanadi, har chaqiruvda, shu jadvaldan emas).
--
-- procedure_name faqat controlled-deploy orqali yoziladi (UAPP yoki boshqa
-- ilova-qatlamidan DML YO'Q) - Core_Api.Get_Page_Init shu ustunni ishonchli deb
-- EXECUTE IMMEDIATE'ga uzatadi, shuning uchun bu yozish yo'li muhofaza qilinishi SHART.
----------------------------------------------------------------------------------------------------
create table CORE_R_API_READS
(
  read_code        VARCHAR2(100) not null,
  procedure_name   VARCHAR2(100) not null,
  menu_id          NUMBER(10),
  requires_context VARCHAR2(1) default 'Y' not null,
  description      VARCHAR2(400),
  state            VARCHAR2(1) default 'A' not null,
  created_by       NUMBER(10) not null,
  created_on       DATE not null,
  modify_by        NUMBER(10) not null,
  modify_on        DATE not null
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints
alter table CORE_R_API_READS
  add constraint CORE_R_API_READS_PK primary key (READ_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate check constraints
alter table CORE_R_API_READS
  add constraint CORE_R_API_READS_C1
  check (state in ('A', 'P'));
alter table CORE_R_API_READS
  add constraint CORE_R_API_READS_C2
  check (requires_context in ('Y', 'N'));
-- menu_id ATAYLAB soft-link (FK yo'q) - CORE_R_MENU_BUTTONS ham xuddi shunday
-- (PK MENU_ID,BUTTON_ID - MODULE_CODE'siz) bare menu_id'ni yetarli deb hisoblaydi,
-- shu konvensiyaga ergashildi.
--
-- requires_context: bu read_code chaqirilganda haqiqiy foydalanuvchi konteksti
-- (Core.User_Env.Get_User_Id) SHART ekanini bildiradi. DIQQAT: Core_Api.pck'ning
-- joriy Get_Page_Init tanasida bu ustun HOZIRCHA o'lik tekshiruv - funksiya
-- boshida (v_User_Id is null bo'lsa) allaqachon qaytadi, shu sabab pastdagi
-- requires_context sharti hech qachon 'true' bo'lolmaydi. Kelajakda haqiqatan
-- anonim (kontekstsiz) o'qish kerak bo'lsa, avval o'sha erta-return shartli
-- qilinishi kerak.
