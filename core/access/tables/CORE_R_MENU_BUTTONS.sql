----------------------------------------------------------------------------------------------------
-- CORE_R_MENU_BUTTONS - menyu tugmalari (button) reestri + har bir tugmani SM_R_PROCESSES
-- state-machine jarayoniga ulovchi YAGONA manba (single source of truth).
--
-- PROCESS_CODE va MODEL_PROCESS_CODE nega faqat ikkita ustun: CMS JSP protokolida
-- tugma uchun aynan ikkita "uya" bor -
--   model_process_code -> Core_Api.Get_Model_Clob chaqiradi (GET / forma ochilganda -
--                          mavjud obyekt namunasini o'qish),
--   process_code        -> Core_Api.Execute_Process_Clob chaqiradi (POST / forma
--                          yuborilganda - process'ni ishga tushirish).
-- Ikkalasi ham NULL bo'lishi QONUNIY holat - bu "faqat navigatsiya" tugmasi degani
-- (masalan sahifaga o'tish tugmasi), unga hech qanday process bog'lanmagan.
--
-- Bu ataylab CORE_R_API_READS'dagi anti-patterndan qochadi: tugmaga "biror narsa"
-- bog'lash uchun SM_R_OBJECTS'ga 'MENU' / 'BUTTON' / 'UI' kabi soxta obyekt qatorlari
-- HECH QACHON yaratilmaydi. Agar tugma haqiqatan process'ga bog'liq bo'lsa - u
-- SM_R_PROCESSES'dagi haqiqiy obyektga (masalan USER, ACCOUNT) ishora qiladi;
-- bog'liq bo'lmasa - ustunlar NULL qoladi.
--
-- MODEL_PROCESS_CODE FAQAT mavjud obyekt namunasini tahrirlash uchun o'qishga
-- mo'ljallangan (masalan MODEL_USER kabi) - ya'ni forma edit rejimida ochilganda.
-- Holatsiz page-init / list / dashboard o'qishlari (sidebar, grid, statistika va
-- hokazo) hamon CORE_R_API_READS orqali boradi - bu jadval ularni almashtirmaydi.
--
-- Bu yerda HECH QANDAY ruxsat (permission) ma'lumoti saqlanmaydi - kim qaysi
-- tugmani ko'rishi/bosishi mumkinligi har chaqiruvda ADM_REL_USER_BUTTONS'dan
-- hisoblanadi, shu jadvaldan emas.
----------------------------------------------------------------------------------------------------
-- Create table
create table CORE_R_MENU_BUTTONS
(
  module_code        VARCHAR2(100) not null,
  menu_id            NUMBER(10) not null,
  button_id          NUMBER(10) not null,
  action_code        VARCHAR2(200) not null,
  name_mll_code      VARCHAR2(100) not null,
  order_by           NUMBER(3) not null,
  state              VARCHAR2(1) default 'A' not null,
  button_type        VARCHAR2(10),
  process_code       VARCHAR2(100),
  model_process_code VARCHAR2(100),
  created_by         NUMBER(10) not null,
  created_on         DATE not null,
  modify_by          NUMBER(10) not null,
  modify_on          DATE not null
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes
create index CORE_R_MENU_BUTTONS_I1 on CORE_R_MENU_BUTTONS (MODULE_CODE, MENU_ID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create index CORE_R_MENU_BUTTONS_I2 on CORE_R_MENU_BUTTONS (PROCESS_CODE)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create index CORE_R_MENU_BUTTONS_I3 on CORE_R_MENU_BUTTONS (MODEL_PROCESS_CODE)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints
alter table CORE_R_MENU_BUTTONS
  add constraint CORE_R_MENU_BUTTONS_PK primary key (MENU_ID, BUTTON_ID)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
alter table CORE_R_MENU_BUTTONS
  add constraint CORE_R_MENU_BUTTONS_F1 foreign key (PROCESS_CODE)
  references SM_R_PROCESSES (PROCESS_CODE);
alter table CORE_R_MENU_BUTTONS
  add constraint CORE_R_MENU_BUTTONS_F2 foreign key (MODEL_PROCESS_CODE)
  references SM_R_PROCESSES (PROCESS_CODE);
-- Create/Recreate check constraints
alter table CORE_R_MENU_BUTTONS
  add constraint CORE_R_MENU_BUTTONS_C1
  check (state in ('A', 'P'));
