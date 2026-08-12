----------------------------------------------------------------------------------------------------
-- CORE_PROCESS_ACCESS_LOG - Core_Api.Execute_Process_Clob / Get_Model_Clob process-code
-- authorization guard uchun VAQTINCHALIK kuzatuv (observability) jadvali.
--
-- Kontekst: Execute_Process_Clob / Get_Model_Clob chaqiruvchidan kelgan process_code'ni
-- avval hech qanday ruxsat tekshiruvisiz Sm_Kernel.Set_Method'ga yuborardi. Log-then-enforce
-- ko'chirish: LOG bosqichida (Core_Const.c_Process_Guard_Mode = 'LOG', joriy holat) har
-- chaqiruvda ADM_REL_USER_BUTTONS bo'yicha "agar ENFORCE yoqilgan bo'lganida nima bo'lardi"
-- natijasi shu jadvalga yoziladi, hech narsa bloklanmaydi. Core_Api.Check_Process_Access
-- (core/package/Core_Api.pck) endi Core_Const.c_Process_Guard_Mode'ni HAQIQATAN o'qiydi va
-- ENFORCE_DOOR/ENFORCE rejimlarida would_block='Y' bo'lgan chaqiruvlarni haqiqatan bloklaydi
-- (enforce_action='BLOCK', Raise_Application_Error(-20003)) - DEBUG foydalanuvchilar uchun
-- WARN_BYPASS bilan istisno bilan (Core_Const.pck'dagi rejim-zinapoyasi izohiga qarang).
--
-- AUTH_AUDIT_LOG'dan ATAYLAB alohida: AUTH_AUDIT_LOG'ning event_type domeni
-- autentifikatsiyaga xos (NONCE_FAIL/LOGIN_FAIL/LOGIN_OK/...) - boshqa subsystem/semantika,
-- shu jadvalga qo'shish ikki tushunchani aralashtirib yuboradi.
--
-- Bu doimiy audit ledger EMAS - log-then-enforce ko'chirish tugagach (ENFORCE barqaror
-- ishlagach) kichraytirilishi yoki olib tashlanishi mumkin bo'lgan vaqtinchalik jadval.
--
-- Qarang (see also): access/packages/purge_core_process_access_log.sql - bu jadvalning
-- cheksiz o'sishining oldini olish uchun 30 kunlik retention bilan davriy tozalash skripti
-- (rejalashtirish operatsion/DBA vazifasi - bu skript o'zi hech qanday job yaratmaydi).
----------------------------------------------------------------------------------------------------
-- Create table
create table CORE_PROCESS_ACCESS_LOG
(
  log_id         NUMBER(12)    not null,
  event_on       DATE          not null,
  user_id        NUMBER(10),
  process_code   VARCHAR2(100),
  door           VARCHAR2(20)  not null,
  outcome        VARCHAR2(20)  not null,
  would_block    VARCHAR2(1)   not null,
  session_id     VARCHAR2(64),
  process_id     NUMBER(10),
  enforce_action VARCHAR2(20)  default 'ALLOW' not null
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes
create index CORE_PROCESS_ACCESS_LOG_I1 on CORE_PROCESS_ACCESS_LOG (EVENT_ON)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create index CORE_PROCESS_ACCESS_LOG_I2 on CORE_PROCESS_ACCESS_LOG (PROCESS_CODE)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate primary key constraint
alter table CORE_PROCESS_ACCESS_LOG
  add constraint CORE_PROCESS_ACCESS_LOG_PK primary key (LOG_ID)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate check constraints
alter table CORE_PROCESS_ACCESS_LOG
  add constraint CORE_PROCESS_ACCESS_LOG_C1
  check (door in ('EXECUTE_PROCESS', 'GET_MODEL'));
alter table CORE_PROCESS_ACCESS_LOG
  add constraint CORE_PROCESS_ACCESS_LOG_C2
  check (outcome in ('MAPPED_AUTHORIZED', 'MAPPED_DENIED', 'UNMAPPED', 'WRONG_DOOR_TYPE',
                      'NO_USER_CTX', 'GUARD_ERROR', 'FOREIGN_PROCESS_ID'));
alter table CORE_PROCESS_ACCESS_LOG
  add constraint CORE_PROCESS_ACCESS_LOG_C3
  check (would_block in ('Y', 'N'));
alter table CORE_PROCESS_ACCESS_LOG
  add constraint CORE_PROCESS_ACCESS_LOG_C4
  check (enforce_action in ('ALLOW', 'BLOCK', 'WARN_BYPASS'));

COMMENT ON TABLE  CORE_PROCESS_ACCESS_LOG                IS 'Core_Api process-code guard uchun vaqtinchalik LOG-bosqich kuzatuv jadvali (log-then-enforce)';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.log_id          IS 'Yagona identifikator (CORE_PROCESS_ACCESS_LOG_SQ)';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.event_on        IS 'Tekshiruv vaqti';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.user_id         IS 'Core.User_Env.Get_User_Id (mavjud bo''lsa)';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.process_code    IS 'Sm_Kernel.Set_Method''ga yuborilishidan oldingi effektiv process_code';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.door            IS 'EXECUTE_PROCESS (Execute_Process_Clob) / GET_MODEL (Get_Model_Clob)';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.outcome         IS 'MAPPED_AUTHORIZED / MAPPED_DENIED / UNMAPPED (CORE_R_MENU_BUTTONS''da mos qator yo''q) / WRONG_DOOR_TYPE (GET_MODEL eshigiga process_type != GET bo''lgan process_code kelgan - cross-door escalation, SM_R_PROCESSES''da to''g''ridan-to''g''ri topilgan, lekin GET emas) / NO_USER_CTX (process_code mapped, lekin foydalanuvchi konteksti yo''q - grant tekshiruviga yetib bormasdan alohida ajratiladi) / GUARD_ERROR (guard''ning o''zining qaror-berish so''rovlari xato berdi - fail-closed: bloklanadi, jimgina ruxsat berilmaydi) / FOREIGN_PROCESS_ID (so''rovda faqat process_id bor - Sm_Kernel.Set_Method process_id-based rerun yo''li - va SM_PROCESSES.process_id topilmadi YOKI topilgan qatorning created_by''i joriy foydalanuvchi bilan mos kelmadi, ya''ni boshqa foydalanuvchining jarayonini davom ettirishga urinish)';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.would_block     IS 'Y/N - ENFORCE rejimi bloklagan bo''lardimi. Fail-closed whitelist: N FAQAT MAPPED_AUTHORIZED va UNMAPPED uchun (ikkalasi ham policy-approved "hech qachon bloklamaydi"), QOLGAN BARCHA outcome (shu jumladan MAPPED_DENIED, WRONG_DOOR_TYPE, NO_USER_CTX, GUARD_ERROR, FOREIGN_PROCESS_ID va kelajakda qo''shiladigan har qanday yangi outcome) uchun Y - yangi outcome sukut bo''yicha bloklash-nomzodi hisoblanadi. DIQQAT (semantik o''zgarish): LOG-bosqichning boshlang''ich versiyasida WRONG_DOOR_TYPE would_block=''N'' edi (hech qachon bloklanmaydi); ENFORCE ko''chirish ishi doirasida WRONG_DOOR_TYPE endi would_block=''Y'' deb hisoblanadi (cross-door escalation haqiqatan bloklanishi kerak bo''lgan holat) - eski qatorlar (ushbu o''zgarishdan oldin yozilgan) tarixiy qiymat sifatida ''N'' qolaveradi, faqat yangi qatorlar ''Y'' oladi.';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.session_id       IS 'Forenzik korrelyatsiya uchun DB sessiya identifikatori (Sys_Context(''USERENV'',''SESSIONID'')) - DIQQAT: bu UAPP token-hash asosidagi sessiya (Auth_Sessions.session_id_hash/Auth_Audit_Log.session_id_hash konvensiyasi) BILAN BIR XIL EMAS, chunki Core_Api/User_Env kontekstida token-hash hozircha ochiq emas (User_Env.pck/Auth_Session.pck''ni o''zgartirmasdan). Faqat DB-sessiya darajasidagi qo''shimcha iz sifatida qo''shilgan, NULL bo''lishi mumkin.';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.process_id       IS 'Sm_Kernel.Set_Method''ga qayta-ishga-tushirish (rerun) uchun berilgan process_id (agar hash''da bo''lsa) - Sm_Kernel.pck''ning process_id-based rerun yo''li bilan bir xil kalit nomi (SM_PROCESSES.process_id, NUMBER(10) - manba ustun bilan bir xil tur). NULL - odatiy (yangi) chaqiruv uchun.';
COMMENT ON COLUMN CORE_PROCESS_ACCESS_LOG.enforce_action   IS 'Guard ushbu chaqiruv uchun aslida nima qildi: ALLOW - odatdagidek bajarildi (LOG rejimi yoki ENFORCE rejimida would_block=N); BLOCK - guard Raise_Application_Error(-20003) bilan chaqiruvni to''xtatdi; WARN_BYPASS - would_block=Y edi, lekin DEBUG foydalanuvchi (Core_Users.Debug=''Y'') bo''lgani uchun baribir bajarilishga ruxsat berildi (Dbms_Output orqali ogohlantirish bilan birga).';
