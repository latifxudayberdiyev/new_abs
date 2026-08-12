--------------------------------------------------------------------------------
-- CoreBank | Fizik shaxs mijoz kartochkasi
-- "Shaxsiy" va "Moliyaviy" bo'limlari uchun PL/SQL (Oracle) jadvallar strukturasi — v5
--
-- v5 da kiritilgan tuzatishlar (foydalanuvchi izohlari asosida):
--   1) Cheklov/indeks nomlash standarti joriy qilindi (jadval nomi + suffiks):
--        Primary Key  -> <TABLE>_PK
--        Foreign Key  -> <TABLE>_F1, _F2, _F3 ...   (jadvaldagi tartib bo'yicha)
--        Unique       -> <TABLE>_U1, _U2 ...
--        Index        -> <TABLE>_I1, _I2 ...
--        Check        -> <TABLE>_C1, _C2 ...
--   2) CL_PHYS_PERSONS jadvalidan DOC_SERIES_SRC va DOC_NUMBER_SRC ustunlari olib
--      tashlandi — bu ma'lumot CL_PHYS_DOCUMENTS jadvalida saqlanadi, dublikat shart emas.
--   3) Mijozga tegishli barcha tranzaksion jadvallar CL_PHYS_ prefiksi bilan
--      nomlandi (CL_PERSONS -> CL_PHYS_PERSONS va h.k.). Spravochnik (ma'lumotnoma)
--      jadvallari o'zining CL_R_ prefiksida qoladi — ular mijozga emas, umumiy
--      nomenklaturaga tegishli.
--   4) Barcha cheklovlar (PRIMARY KEY, FOREIGN KEY, UNIQUE, CHECK) endi
--      CREATE TABLE ichida emas, balki alohida ALTER TABLE ... ADD CONSTRAINT
--      operatorlari orqali qo'shiladi. CREATE TABLE faqat ustunlarni belgilaydi.
--   5) Har bir jadvalning ALTER TABLE (cheklovlar) va CREATE INDEX (indekslar)
--      operatorlari endi alohida QISM C/D bo'limlarida emas, balki o'sha
--      jadvalning CREATE TABLE bayonotidan darhol keyin joylashtirildi — har bir
--      jadval haqidagi barcha ma'lumot (ustunlar, izohlar, cheklovlar, indekslar)
--      bitta joyda, ketma-ket o'qiladi.
--
-- Manba: physical-person-banking-v15.html — Kartochka klienta oynasi
--------------------------------------------------------------------------------


--================================================================================
-- QISM A. SPRAVOCHNIK (MA'LUMOTNOMA) JADVALLARI — prefiks CL_R_
-- Har bir jadval blokida: CREATE TABLE -> COMMENT -> cheklovlar (ALTER TABLE) -> indekslar
--================================================================================

-- MUHIM: CL_R_COUNTRIES, CL_R_REGIONS, CL_R_DISTRICTS, CL_R_NATIONALITIES,
-- CL_R_DOCUMENT_TYPES jadvallari bazadan drop qilingan — ularga to'liq mos
-- keluvchi, allaqachon ma'lumot bilan to'ldirilgan CBR_COUNTRY_V, CBR_REGION_V,
-- CBR_DISTRICT_V, CBR_NATION_V, CBR_VERIFYING_DOCUMENT_TYPE(_V) spravochniklari
-- mavjud edi. CL_PHYS_ADDRESSES/CL_PHYS_PERSONS ustunlaridagi mos FK cheklovlari
-- ham shu bilan birga olib tashlandi (pastda izohlangan) — CBR_ ga qayta
-- yo'naltirish talab qilinmadi.

--------------------------------------------------------------------------------
-- A6) CL_R_BRANCHES — Bank filiallari spravochnigi
--------------------------------------------------------------------------------
CREATE TABLE CL_R_BRANCHES (
  BRANCH_CODE  VARCHAR2(10)  NOT NULL,
  BRANCH_NAME  VARCHAR2(300) NOT NULL
);
COMMENT ON TABLE CL_R_BRANCHES IS 'Bank filiallari spravochnigi. Formadagi Bank ma''lumotlari oynachasidagi "Filial" (F9 tugmali) maydoniga mos keladi.';
COMMENT ON COLUMN CL_R_BRANCHES.BRANCH_CODE IS 'Filial kodi (PK), masalan "00591"';
COMMENT ON COLUMN CL_R_BRANCHES.BRANCH_NAME IS 'Filial nomi';

-- CL_R_BRANCHES: cheklovlar (constraints)
ALTER TABLE CL_R_BRANCHES ADD CONSTRAINT CL_R_BRANCHES_PK PRIMARY KEY (BRANCH_CODE);

--------------------------------------------------------------------------------
-- A7) CL_R_SALES_POINTS — Savdo nuqtalari (tochka prodaj) spravochnigi
--------------------------------------------------------------------------------
CREATE TABLE CL_R_SALES_POINTS (
  SALES_POINT_CODE  VARCHAR2(10)  NOT NULL,
  SALES_POINT_NAME  VARCHAR2(300) NOT NULL,
  BRANCH_CODE       VARCHAR2(10)
);
COMMENT ON TABLE CL_R_SALES_POINTS IS 'Savdo nuqtalari (tochka prodaj) spravochnigi. Formadagi "Tochka prodaj" (F9 tugmali) maydoniga mos keladi.';
COMMENT ON COLUMN CL_R_SALES_POINTS.SALES_POINT_CODE IS 'Savdo nuqtasi kodi (PK)';
COMMENT ON COLUMN CL_R_SALES_POINTS.SALES_POINT_NAME IS 'Savdo nuqtasi nomi';
COMMENT ON COLUMN CL_R_SALES_POINTS.BRANCH_CODE      IS 'Savdo nuqtasi tegishli bo''lgan filial kodi, FK -> CL_R_BRANCHES (CL_R_SALES_POINTS_F1)';

-- CL_R_SALES_POINTS: cheklovlar (constraints)
ALTER TABLE CL_R_SALES_POINTS ADD CONSTRAINT CL_R_SALES_POINTS_PK PRIMARY KEY (SALES_POINT_CODE);
ALTER TABLE CL_R_SALES_POINTS ADD CONSTRAINT CL_R_SALES_POINTS_F1 FOREIGN KEY (BRANCH_CODE) REFERENCES CL_R_BRANCHES (BRANCH_CODE);

-- CL_R_SALES_POINTS: indekslar
CREATE INDEX CL_R_SALES_POINTS_I1 ON CL_R_SALES_POINTS (BRANCH_CODE);

--------------------------------------------------------------------------------
-- A8) CL_R_ORG_FORMS — Tashkilot shakli spravochnigi
--------------------------------------------------------------------------------
CREATE TABLE CL_R_ORG_FORMS (
  ORG_FORM_CD    VARCHAR2(10)  NOT NULL,
  ORG_FORM_NAME  VARCHAR2(150) NOT NULL
);
COMMENT ON TABLE CL_R_ORG_FORMS IS 'Tashkilot huquqiy shakllari spravochnigi (Bank, Davlat korxonasi, MChJ, AJ). Moliyaviy bo''limdagi "Ish joylari" blokidagi "Tashkilot shakli" tanlov ro''yxatiga mos keladi.';
COMMENT ON COLUMN CL_R_ORG_FORMS.ORG_FORM_CD   IS 'Tashkilot shakli kodi (PK)';
COMMENT ON COLUMN CL_R_ORG_FORMS.ORG_FORM_NAME IS 'Tashkilot shakli nomi (masalan "MChJ")';

-- CL_R_ORG_FORMS: cheklovlar (constraints)
ALTER TABLE CL_R_ORG_FORMS ADD CONSTRAINT CL_R_ORG_FORMS_PK PRIMARY KEY (ORG_FORM_CD);

--------------------------------------------------------------------------------
-- A9) CL_R_INCOME_SOURCES — Qo'shimcha daromad manbalari spravochnigi
--------------------------------------------------------------------------------
CREATE TABLE CL_R_INCOME_SOURCES (
  INCOME_SOURCE_CD    VARCHAR2(10)  NOT NULL,
  INCOME_SOURCE_NAME  VARCHAR2(150) NOT NULL
);
COMMENT ON TABLE CL_R_INCOME_SOURCES IS 'Qo''shimcha daromad manbalari spravochnigi (Ijara, Freelance, Dividend, Boshqa). Moliyaviy bo''limdagi "Qo''shimcha daromad manbalari" blokidagi "Manba" tanlov ro''yxatiga mos keladi.';
COMMENT ON COLUMN CL_R_INCOME_SOURCES.INCOME_SOURCE_CD   IS 'Daromad manbai kodi (PK)';
COMMENT ON COLUMN CL_R_INCOME_SOURCES.INCOME_SOURCE_NAME IS 'Daromad manbai nomi (masalan "Ijara daromadi")';

-- CL_R_INCOME_SOURCES: cheklovlar (constraints)
ALTER TABLE CL_R_INCOME_SOURCES ADD CONSTRAINT CL_R_INCOME_SOURCES_PK PRIMARY KEY (INCOME_SOURCE_CD);

--------------------------------------------------------------------------------
-- A10) CL_R_SEGMENTS — Mijoz segmentlari spravochnigi
--------------------------------------------------------------------------------
CREATE TABLE CL_R_SEGMENTS (
  SEGMENT_CODE  VARCHAR2(10)  NOT NULL,
  SEGMENT_NAME  VARCHAR2(150) NOT NULL
);
COMMENT ON TABLE CL_R_SEGMENTS IS 'Mijoz segmentlari spravochnigi (masalan "Retail (Chakana biznes)"). Kartochka klienta yon panelidagi "Segmenti" maydoniga mos keladi.';
COMMENT ON COLUMN CL_R_SEGMENTS.SEGMENT_CODE IS 'Segment kodi (PK)';
COMMENT ON COLUMN CL_R_SEGMENTS.SEGMENT_NAME IS 'Segment nomi';

-- CL_R_SEGMENTS: cheklovlar (constraints)
ALTER TABLE CL_R_SEGMENTS ADD CONSTRAINT CL_R_SEGMENTS_PK PRIMARY KEY (SEGMENT_CODE);

--------------------------------------------------------------------------------
-- A11) CL_R_SUB_SEGMENTS — Mijoz quyi segmentlari spravochnigi (segmentga bog'liq)
--------------------------------------------------------------------------------
CREATE TABLE CL_R_SUB_SEGMENTS (
  SUB_SEGMENT_CD    VARCHAR2(10)  NOT NULL,
  SUB_SEGMENT_NAME  VARCHAR2(150) NOT NULL,
  SEGMENT_CODE      VARCHAR2(10)  NOT NULL
);
COMMENT ON TABLE CL_R_SUB_SEGMENTS IS 'Mijoz quyi segmentlari spravochnigi (masalan "Mass", "Mass affluent"). "Mijoz asosiy ma''lumotlari" oynachasidagi "Quyi segmenti" tanlov ro''yxatiga mos keladi.';
COMMENT ON COLUMN CL_R_SUB_SEGMENTS.SUB_SEGMENT_CD   IS 'Quyi segment kodi (PK)';
COMMENT ON COLUMN CL_R_SUB_SEGMENTS.SUB_SEGMENT_NAME IS 'Quyi segment nomi';
COMMENT ON COLUMN CL_R_SUB_SEGMENTS.SEGMENT_CODE     IS 'Tegishli segment kodi, FK -> CL_R_SEGMENTS (CL_R_SUB_SEGMENTS_F1)';

-- CL_R_SUB_SEGMENTS: cheklovlar (constraints)
ALTER TABLE CL_R_SUB_SEGMENTS ADD CONSTRAINT CL_R_SUB_SEGMENTS_PK PRIMARY KEY (SUB_SEGMENT_CD);
ALTER TABLE CL_R_SUB_SEGMENTS ADD CONSTRAINT CL_R_SUB_SEGMENTS_F1 FOREIGN KEY (SEGMENT_CODE) REFERENCES CL_R_SEGMENTS (SEGMENT_CODE);

-- CL_R_SUB_SEGMENTS: indekslar
CREATE INDEX CL_R_SUB_SEGMENTS_I1 ON CL_R_SUB_SEGMENTS (SEGMENT_CODE);

--------------------------------------------------------------------------------
-- A12) CL_R_SENIORITY_RANGES — Ish staji oraliqlari spravochnigi
--------------------------------------------------------------------------------
CREATE TABLE CL_R_SENIORITY_RANGES (
  SENIORITY_CD    VARCHAR2(2)   NOT NULL,
  SENIORITY_NAME  VARCHAR2(50)  NOT NULL
);
COMMENT ON TABLE CL_R_SENIORITY_RANGES IS 'Ish staji oraliqlari spravochnigi. Moliyaviy bo''limdagi "Ish joylari" blokidagi "Ish staji" tanlov ro''yxatiga mos keladi.';
COMMENT ON COLUMN CL_R_SENIORITY_RANGES.SENIORITY_CD   IS 'Ish staji oralig''i kodi (PK)';
COMMENT ON COLUMN CL_R_SENIORITY_RANGES.SENIORITY_NAME IS 'Ish staji oralig''i nomi (masalan "1-5 yil")';

-- CL_R_SENIORITY_RANGES: cheklovlar (constraints)
ALTER TABLE CL_R_SENIORITY_RANGES ADD CONSTRAINT CL_R_SENIORITY_RANGES_PK PRIMARY KEY (SENIORITY_CD);

--================================================================================
-- QISM B. MIJOZGA TEGISHLI TRANZAKSION JADVALLAR — prefiks CL_PHYS_
-- Har bir jadval blokida: CREATE TABLE -> COMMENT -> cheklovlar (ALTER TABLE) -> indekslar
--================================================================================

--------------------------------------------------------------------------------
-- B1) CL_PHYS_PERSONS — "Mijoz asosiy ma'lumotlari" oynasi + "Tashqi manbaa" bloki
--------------------------------------------------------------------------------
CREATE TABLE CL_PHYS_PERSONS (
  CLIENT_ID           NUMBER(19)        GENERATED BY DEFAULT AS IDENTITY,
  CLIENT_CODE         VARCHAR2(20)      NOT NULL,
  EXTERNAL_SOURCE     VARCHAR2(50),
  PINFL               VARCHAR2(14),
  LAST_NAME           VARCHAR2(100)     NOT NULL,
  FIRST_NAME          VARCHAR2(100)     NOT NULL,
  PATRONYMIC          VARCHAR2(100),
  LAST_NAME_CYR       VARCHAR2(100),
  FIRST_NAME_CYR      VARCHAR2(100),
  PATRONYMIC_CYR      VARCHAR2(100),
  PHYSICAL_STATUS_CD  VARCHAR2(2)       DEFAULT '1' NOT NULL,
  DEATH_DATE          DATE,
  BIRTH_DATE          DATE              NOT NULL,
  BIRTH_PLACE         VARCHAR2(200),
  BIRTH_PLACE_ID      VARCHAR2(20),
  BIRTH_COUNTRY_CODE  VARCHAR2(5),
  CITIZENSHIP         VARCHAR2(100),
  NATIONALITY_CODE    VARCHAR2(5),
  GENDER_CD           CHAR(1),
  RESIDENT_FLAG       CHAR(1),
  SECRET_WORD_ENC     VARCHAR2(200),
  SEGMENT_CODE        VARCHAR2(10),
  SUB_SEGMENT_CD      VARCHAR2(10),
  CLIENT_STATUS_CD    VARCHAR2(20)      DEFAULT 'POTENTIAL' NOT NULL,
  CREATED_AT          DATE              DEFAULT SYSDATE NOT NULL,
  CREATED_BY          VARCHAR2(50)      DEFAULT USER NOT NULL,
  UPDATED_AT          DATE,
  UPDATED_BY          VARCHAR2(50)
);

COMMENT ON TABLE CL_PHYS_PERSONS IS
  'Fizik shaxs mijozning asosiy (shaxsiy) ma''lumotlari. "Kartochka klienta" oynasidagi
   "Shaxsiy" bo''limining "Mijoz asosiy ma''lumotlari" oynachasi va yuqoridagi
   "Tashqi manbaa" (DPM) bloki asosida. Har bir fizik shaxs uchun bitta yozuv.';

COMMENT ON COLUMN CL_PHYS_PERSONS.CLIENT_ID          IS 'Mijozning ichki unikal identifikatori (PK), tizim tomonidan avtomatik generatsiya qilinadi';
COMMENT ON COLUMN CL_PHYS_PERSONS.CLIENT_CODE        IS 'Mijoz kodi (bank tizimidagi ko''rinadigan kod, masalan "700241")';
COMMENT ON COLUMN CL_PHYS_PERSONS.EXTERNAL_SOURCE    IS 'Ma''lumot olingan tashqi manba nomi ("Manba" maydoni, masalan DPM — Davlat personifikatsiya markazi)';
COMMENT ON COLUMN CL_PHYS_PERSONS.PINFL              IS 'JShShIR / ПИНФЛ — jismoniy shaxsning shaxsiy identifikatsiya raqami (14 ta raqam)';
COMMENT ON COLUMN CL_PHYS_PERSONS.LAST_NAME          IS 'Familiya (lotin yozuvida)';
COMMENT ON COLUMN CL_PHYS_PERSONS.FIRST_NAME         IS 'Ism (lotin yozuvida)';
COMMENT ON COLUMN CL_PHYS_PERSONS.PATRONYMIC         IS 'Otasining ismi (lotin yozuvida)';
COMMENT ON COLUMN CL_PHYS_PERSONS.LAST_NAME_CYR      IS 'Familiya (kirill yozuvida, lotin asosida avtomatik hosil qilinadi)';
COMMENT ON COLUMN CL_PHYS_PERSONS.FIRST_NAME_CYR     IS 'Ism (kirill yozuvida, lotin asosida avtomatik hosil qilinadi)';
COMMENT ON COLUMN CL_PHYS_PERSONS.PATRONYMIC_CYR     IS 'Otasining ismi (kirill yozuvida, lotin asosida avtomatik hosil qilinadi)';
COMMENT ON COLUMN CL_PHYS_PERSONS.PHYSICAL_STATUS_CD IS 'Jismoniy holati: 1 — Tirik, 2 — Vafot etgan';
COMMENT ON COLUMN CL_PHYS_PERSONS.DEATH_DATE         IS 'Vafot etgan sanasi (faqat PHYSICAL_STATUS_CD = 2 bo''lganda to''ldiriladi)';
COMMENT ON COLUMN CL_PHYS_PERSONS.BIRTH_DATE         IS 'Tug''ilgan sanasi';
COMMENT ON COLUMN CL_PHYS_PERSONS.BIRTH_PLACE        IS 'Tug''ilgan joyi (formada erkin matn sifatida kiritiladi, spravochnikka bog''lanmagan)';
COMMENT ON COLUMN CL_PHYS_PERSONS.BIRTH_PLACE_ID     IS 'Tug''ilgan joyi bo''yicha qo''shimcha ma''lumotnoma kodi (formadagi "Ma''lumotnoma kodi" maydoni)';
COMMENT ON COLUMN CL_PHYS_PERSONS.BIRTH_COUNTRY_CODE IS 'Tug''ilgan davlati, FK -> CL_R_COUNTRIES.COUNTRY_CODE (CL_PHYS_PERSONS_F1). Izoh: CL_R_COUNTRIES bo''sh spravochnik, to''liq ma''lumot uchun CBR_COUNTRY_V dan foydalanish mumkin.';
COMMENT ON COLUMN CL_PHYS_PERSONS.CITIZENSHIP        IS 'Fuqaroligi (formada erkin matn sifatida kiritiladi, spravochnikka bog''lanmagan)';
COMMENT ON COLUMN CL_PHYS_PERSONS.NATIONALITY_CODE   IS 'Millati, FK -> CL_R_NATIONALITIES.NATIONALITY_CODE (CL_PHYS_PERSONS_F2). Izoh: CL_R_NATIONALITIES bo''sh spravochnik, to''liq ma''lumot uchun CBR_NATION_V dan foydalanish mumkin.';
COMMENT ON COLUMN CL_PHYS_PERSONS.GENDER_CD          IS 'Jinsi: M — erkak, F — ayol';
COMMENT ON COLUMN CL_PHYS_PERSONS.RESIDENT_FLAG      IS 'Rezidentlik belgisi: Y — rezident, N — norezident';
COMMENT ON COLUMN CL_PHYS_PERSONS.SECRET_WORD_ENC    IS 'Maxfiy so''z (shifrlangan holda saqlanadi, mijozni og''zaki identifikatsiyalash uchun)';
COMMENT ON COLUMN CL_PHYS_PERSONS.SEGMENT_CODE       IS 'Mijoz segmenti, FK -> CL_R_SEGMENTS.SEGMENT_CODE (CL_PHYS_PERSONS_F3, avtomatik aniqlanadi, faqat o''qish uchun)';
COMMENT ON COLUMN CL_PHYS_PERSONS.SUB_SEGMENT_CD     IS 'Mijoz quyi segmenti, FK -> CL_R_SUB_SEGMENTS.SUB_SEGMENT_CD (CL_PHYS_PERSONS_F4)';
COMMENT ON COLUMN CL_PHYS_PERSONS.CLIENT_STATUS_CD   IS 'Mijoz maqomi: BANK_CLIENT — bank klienti, POTENTIAL — potensial mijoz';
COMMENT ON COLUMN CL_PHYS_PERSONS.CREATED_AT         IS 'Yozuv yaratilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_PERSONS.CREATED_BY         IS 'Yozuvni yaratgan foydalanuvchi (operator) login';
COMMENT ON COLUMN CL_PHYS_PERSONS.UPDATED_AT         IS 'Yozuv oxirgi marta o''zgartirilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_PERSONS.UPDATED_BY         IS 'Yozuvni oxirgi marta o''zgartirgan foydalanuvchi (operator) login';

-- CL_PHYS_PERSONS: cheklovlar (constraints)
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_PK PRIMARY KEY (CLIENT_ID);
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_U1 UNIQUE (CLIENT_CODE);
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_U2 UNIQUE (PINFL);
-- CL_PHYS_PERSONS_F1 (BIRTH_COUNTRY_CODE -> CL_R_COUNTRIES) va CL_PHYS_PERSONS_F2
-- (NATIONALITY_CODE -> CL_R_NATIONALITIES) olib tashlandi — CL_R_COUNTRIES va
-- CL_R_NATIONALITIES drop qilingan (o'rniga CBR_COUNTRY_V / CBR_NATION_V bor,
-- lekin FK qayta ulanmadi).
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_F3 FOREIGN KEY (SEGMENT_CODE)       REFERENCES CL_R_SEGMENTS (SEGMENT_CODE);
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_F4 FOREIGN KEY (SUB_SEGMENT_CD)     REFERENCES CL_R_SUB_SEGMENTS (SUB_SEGMENT_CD);
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_C1 CHECK (PHYSICAL_STATUS_CD IN ('1','2'));
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_C2 CHECK (GENDER_CD IN ('M','F'));
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_C3 CHECK (RESIDENT_FLAG IN ('Y','N'));
ALTER TABLE CL_PHYS_PERSONS ADD CONSTRAINT CL_PHYS_PERSONS_C4 CHECK (CLIENT_STATUS_CD IN ('BANK_CLIENT','POTENTIAL'));

-- CL_PHYS_PERSONS: indekslar
CREATE INDEX CL_PHYS_PERSONS_I1 ON CL_PHYS_PERSONS (BIRTH_COUNTRY_CODE);
CREATE INDEX CL_PHYS_PERSONS_I2 ON CL_PHYS_PERSONS (NATIONALITY_CODE);
CREATE INDEX CL_PHYS_PERSONS_I3 ON CL_PHYS_PERSONS (SEGMENT_CODE);
CREATE INDEX CL_PHYS_PERSONS_I4 ON CL_PHYS_PERSONS (SUB_SEGMENT_CD);

--------------------------------------------------------------------------------
-- B2) CL_PHYS_DOCUMENTS — "ShTH ma'lumotlari" oynasi (+ "Hujjatlar tarixi" jadvali)
--    Eslatma: shaxsni identifikatsiyalash uchun ShTH seriya/raqami faqat shu
--    jadvalda saqlanadi (CL_PHYS_PERSONS da dublikat ustunlar yo'q).
--------------------------------------------------------------------------------
CREATE TABLE CL_PHYS_DOCUMENTS (
  DOCUMENT_ID   NUMBER(19)    GENERATED BY DEFAULT AS IDENTITY,
  CLIENT_ID     NUMBER(19)    NOT NULL,
  DOC_TYPE_CD   VARCHAR2(10)  NOT NULL,
  DOC_SERIES    VARCHAR2(4)   NOT NULL,
  DOC_NUMBER    VARCHAR2(10)  NOT NULL,
  ISSUE_DATE    DATE,
  EXPIRY_DATE   DATE,
  ISSUED_BY     VARCHAR2(300),
  IS_CURRENT    CHAR(1)       DEFAULT 'Y' NOT NULL,
  SAVED_AT      DATE          DEFAULT SYSDATE NOT NULL,
  CREATED_AT    DATE          DEFAULT SYSDATE NOT NULL,
  CREATED_BY    VARCHAR2(50)  DEFAULT USER NOT NULL
);

COMMENT ON TABLE CL_PHYS_DOCUMENTS IS
  'Mijozning shaxsni tasdiqlovchi hujjat(lar)i. "Shaxsiy" bo''limining "ShTH ma''lumotlari"
   oynachasi hamda undagi "Hujjatlar tarixi" jadvaliga mos keladi. Bitta mijozga bir nechta
   (tarixiy) hujjat yozuvi bo''lishi mumkin, IS_CURRENT = ''Y'' joriy hujjatni bildiradi.
   ShTH seriya/raqami markazlashgan holda faqat shu jadvalda saqlanadi.';

COMMENT ON COLUMN CL_PHYS_DOCUMENTS.DOCUMENT_ID  IS 'Hujjat yozuvining unikal identifikatori (PK)';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.CLIENT_ID    IS 'Mijozga FK -> CL_PHYS_PERSONS.CLIENT_ID (CL_PHYS_DOCUMENTS_F1)';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.DOC_TYPE_CD  IS 'ShTH turi, FK -> CBR_VERIFYING_DOCUMENT_TYPE.CODE (CL_PHYS_DOCUMENTS_F2). Izoh: CL_R_DOCUMENT_TYPES bo''sh spravochnik edi, drop qilingan — o''rniga to''liq to''ldirilgan CBR_VERIFYING_DOCUMENT_TYPE(_V) ishlatiladi.';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.DOC_SERIES   IS 'ShTH seriyasi (masalan "KA")';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.DOC_NUMBER   IS 'ShTH raqami (masalan "4261913")';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.ISSUE_DATE   IS 'ShTH berilgan sana';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.EXPIRY_DATE  IS 'ShTH amal qilish muddati';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.ISSUED_BY    IS 'ShTH kim tomonidan berilgani (bergan organ nomi, erkin matn)';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.IS_CURRENT   IS 'Joriy (amaldagi) hujjat belgisi: Y — joriy, N — tarixiy (eskirgan)';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.SAVED_AT     IS 'Hujjat ma''lumoti bazaga saqlangan sana ("Hujjatlar tarixi" jadvalidagi ustun)';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.CREATED_AT   IS 'Yozuv yaratilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_DOCUMENTS.CREATED_BY   IS 'Yozuvni yaratgan foydalanuvchi (operator) login';

-- CL_PHYS_DOCUMENTS: cheklovlar (constraints)
ALTER TABLE CL_PHYS_DOCUMENTS ADD CONSTRAINT CL_PHYS_DOCUMENTS_PK PRIMARY KEY (DOCUMENT_ID);
ALTER TABLE CL_PHYS_DOCUMENTS ADD CONSTRAINT CL_PHYS_DOCUMENTS_F1 FOREIGN KEY (CLIENT_ID)   REFERENCES CL_PHYS_PERSONS (CLIENT_ID) ON DELETE CASCADE;
ALTER TABLE CL_PHYS_DOCUMENTS ADD CONSTRAINT CL_PHYS_DOCUMENTS_F2 FOREIGN KEY (DOC_TYPE_CD) REFERENCES CBR_VERIFYING_DOCUMENT_TYPE (CODE);
ALTER TABLE CL_PHYS_DOCUMENTS ADD CONSTRAINT CL_PHYS_DOCUMENTS_U1 UNIQUE (DOC_SERIES, DOC_NUMBER);
ALTER TABLE CL_PHYS_DOCUMENTS ADD CONSTRAINT CL_PHYS_DOCUMENTS_C1 CHECK (IS_CURRENT IN ('Y','N'));

-- CL_PHYS_DOCUMENTS: indekslar
CREATE INDEX CL_PHYS_DOCUMENTS_I1 ON CL_PHYS_DOCUMENTS (CLIENT_ID);
CREATE INDEX CL_PHYS_DOCUMENTS_I2 ON CL_PHYS_DOCUMENTS (DOC_TYPE_CD);

--------------------------------------------------------------------------------
-- B3) CL_PHYS_ADDRESSES — "Manzil ma'lumotlari" oynasi
--    (Ro'yxatdan o'tgan manzil — doimiy/vaqtincha, va Haqiqatda yashash manzili)
--------------------------------------------------------------------------------
CREATE TABLE CL_PHYS_ADDRESSES (
  ADDRESS_ID      NUMBER(19)    GENERATED BY DEFAULT AS IDENTITY,
  CLIENT_ID       NUMBER(19)    NOT NULL,
  ADDRESS_TYPE_CD VARCHAR2(20)  NOT NULL,
  COUNTRY_CODE    VARCHAR2(5),
  REGION_CODE     VARCHAR2(10),
  DISTRICT_CODE   VARCHAR2(10),
  MAHALLA_NAME    VARCHAR2(150),
  STREET_NAME     VARCHAR2(200),
  HOUSE_NO        VARCHAR2(20),
  FULL_ADDRESS    VARCHAR2(500),
  CREATED_AT      DATE          DEFAULT SYSDATE NOT NULL,
  CREATED_BY      VARCHAR2(50)  DEFAULT USER NOT NULL,
  UPDATED_AT      DATE,
  UPDATED_BY      VARCHAR2(50)
);

COMMENT ON TABLE CL_PHYS_ADDRESSES IS
  'Mijozning manzil ma''lumotlari. "Shaxsiy" bo''limining "Manzil ma''lumotlari" oynachasiga mos
   keladi: ro''yxatdan o''tgan manzil (doimiy va vaqtincha) hamda haqiqatda yashash manzili
   ADDRESS_TYPE_CD orqali bitta jadvalda ajratiladi (bitta mijozga har tur bo''yicha bitta yozuv).';

COMMENT ON COLUMN CL_PHYS_ADDRESSES.ADDRESS_ID      IS 'Manzil yozuvining unikal identifikatori (PK)';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.CLIENT_ID       IS 'Mijozga FK -> CL_PHYS_PERSONS.CLIENT_ID (CL_PHYS_ADDRESSES_F1)';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.ADDRESS_TYPE_CD IS 'Manzil turi: LEGAL_PERM — doimiy ro''yxatdan o''tgan, LEGAL_TEMP — vaqtincha ro''yxatdan o''tgan, ACTUAL — haqiqatda yashash manzili';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.COUNTRY_CODE    IS 'Davlat, FK -> CL_R_COUNTRIES.COUNTRY_CODE (CL_PHYS_ADDRESSES_F2). Izoh: CL_R_COUNTRIES bo''sh spravochnik, to''liq ma''lumot uchun CBR_COUNTRY_V dan foydalanish mumkin.';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.REGION_CODE     IS 'Viloyat/shahar, FK -> CL_R_REGIONS.REGION_CODE (CL_PHYS_ADDRESSES_F3). Izoh: CL_R_REGIONS bo''sh spravochnik, to''liq ma''lumot uchun CBR_REGION_V dan foydalanish mumkin.';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.DISTRICT_CODE   IS 'Tuman/shahar, FK -> CL_R_DISTRICTS.DISTRICT_CODE (CL_PHYS_ADDRESSES_F4). Izoh: CL_R_DISTRICTS bo''sh spravochnik, to''liq ma''lumot uchun CBR_DISTRICT_V dan foydalanish mumkin.';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.MAHALLA_NAME    IS 'Mahalla nomi (formada erkin matn sifatida kiritiladi)';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.STREET_NAME     IS 'Ko''cha nomi (formada erkin matn sifatida kiritiladi)';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.HOUSE_NO        IS 'Uy raqami';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.FULL_ADDRESS    IS 'Manzil (to''liq) — erkin matn ko''rinishidagi to''liq manzil';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.CREATED_AT      IS 'Yozuv yaratilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.CREATED_BY      IS 'Yozuvni yaratgan foydalanuvchi (operator) login';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.UPDATED_AT      IS 'Yozuv oxirgi marta o''zgartirilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_ADDRESSES.UPDATED_BY      IS 'Yozuvni oxirgi marta o''zgartirgan foydalanuvchi (operator) login';

-- CL_PHYS_ADDRESSES: cheklovlar (constraints)
ALTER TABLE CL_PHYS_ADDRESSES ADD CONSTRAINT CL_PHYS_ADDRESSES_PK PRIMARY KEY (ADDRESS_ID);
ALTER TABLE CL_PHYS_ADDRESSES ADD CONSTRAINT CL_PHYS_ADDRESSES_F1 FOREIGN KEY (CLIENT_ID)     REFERENCES CL_PHYS_PERSONS (CLIENT_ID) ON DELETE CASCADE;
-- CL_PHYS_ADDRESSES_F2/F3/F4 (COUNTRY_CODE/REGION_CODE/DISTRICT_CODE -> CL_R_COUNTRIES/
-- CL_R_REGIONS/CL_R_DISTRICTS) olib tashlandi — bu 3 ta spravochnik drop qilingan
-- (o'rniga CBR_COUNTRY_V/CBR_REGION_V/CBR_DISTRICT_V bor, lekin FK qayta ulanmadi).
ALTER TABLE CL_PHYS_ADDRESSES ADD CONSTRAINT CL_PHYS_ADDRESSES_U1 UNIQUE (CLIENT_ID, ADDRESS_TYPE_CD);
ALTER TABLE CL_PHYS_ADDRESSES ADD CONSTRAINT CL_PHYS_ADDRESSES_C1 CHECK (ADDRESS_TYPE_CD IN ('LEGAL_PERM','LEGAL_TEMP','ACTUAL'));

-- CL_PHYS_ADDRESSES: indekslar
CREATE INDEX CL_PHYS_ADDRESSES_I1 ON CL_PHYS_ADDRESSES (COUNTRY_CODE);
CREATE INDEX CL_PHYS_ADDRESSES_I2 ON CL_PHYS_ADDRESSES (REGION_CODE);
CREATE INDEX CL_PHYS_ADDRESSES_I3 ON CL_PHYS_ADDRESSES (DISTRICT_CODE);

--------------------------------------------------------------------------------
-- B4) CL_PHYS_CONTACTS — "Aloqa ma'lumotlari" oynasi (mijozga 1:1)
--------------------------------------------------------------------------------
CREATE TABLE CL_PHYS_CONTACTS (
  CONTACT_ID    NUMBER(19)    GENERATED BY DEFAULT AS IDENTITY,
  CLIENT_ID     NUMBER(19)    NOT NULL,
  MOBILE_PHONE  VARCHAR2(20),
  WORK_PHONE    VARCHAR2(20),
  HOME_PHONE    VARCHAR2(20),
  EMAIL         VARCHAR2(150),
  UPDATED_AT    DATE          DEFAULT SYSDATE NOT NULL,
  UPDATED_BY    VARCHAR2(50)  DEFAULT USER NOT NULL
);

COMMENT ON TABLE CL_PHYS_CONTACTS IS
  'Mijozning aloqa ma''lumotlari. "Shaxsiy" bo''limining "Aloqa ma''lumotlari" oynachasiga mos
   keladi. Har bir mijoz uchun bitta joriy yozuv (1:1); qo''shimcha (bir nechta) kontaktlar
   "Aloqalar" bo''limida alohida boshqariladi va bu jadvalga kirmaydi.';

COMMENT ON COLUMN CL_PHYS_CONTACTS.CONTACT_ID   IS 'Kontakt yozuvining unikal identifikatori (PK)';
COMMENT ON COLUMN CL_PHYS_CONTACTS.CLIENT_ID    IS 'Mijozga FK -> CL_PHYS_PERSONS.CLIENT_ID (CL_PHYS_CONTACTS_F1), 1:1 bog''lanish (CL_PHYS_CONTACTS_U1)';
COMMENT ON COLUMN CL_PHYS_CONTACTS.MOBILE_PHONE IS 'Mobil telefon raqami (format: +998 XX XXX XX XX)';
COMMENT ON COLUMN CL_PHYS_CONTACTS.WORK_PHONE   IS 'Ish telefon raqami';
COMMENT ON COLUMN CL_PHYS_CONTACTS.HOME_PHONE   IS 'Uy telefon raqami';
COMMENT ON COLUMN CL_PHYS_CONTACTS.EMAIL        IS 'Elektron pochta manzili';
COMMENT ON COLUMN CL_PHYS_CONTACTS.UPDATED_AT   IS 'Yozuv oxirgi marta o''zgartirilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_CONTACTS.UPDATED_BY   IS 'Yozuvni oxirgi marta o''zgartirgan foydalanuvchi (operator) login';

-- CL_PHYS_CONTACTS: cheklovlar (constraints)
ALTER TABLE CL_PHYS_CONTACTS ADD CONSTRAINT CL_PHYS_CONTACTS_PK PRIMARY KEY (CONTACT_ID);
ALTER TABLE CL_PHYS_CONTACTS ADD CONSTRAINT CL_PHYS_CONTACTS_F1 FOREIGN KEY (CLIENT_ID) REFERENCES CL_PHYS_PERSONS (CLIENT_ID) ON DELETE CASCADE;
ALTER TABLE CL_PHYS_CONTACTS ADD CONSTRAINT CL_PHYS_CONTACTS_U1 UNIQUE (CLIENT_ID);

-- Indekslar: qo'shimcha shart emas — CLIENT_ID ustuni CL_PHYS_CONTACTS_U1 (UNIQUE) orqali allaqachon indekslangan.

--------------------------------------------------------------------------------
-- B5) CL_PHYS_BANK_DETAILS — "Bank ma'lumotlari" oynasi (mijozga 1:1)
--------------------------------------------------------------------------------
CREATE TABLE CL_PHYS_BANK_DETAILS (
  BANK_DETAIL_ID    NUMBER(19)    GENERATED BY DEFAULT AS IDENTITY,
  CLIENT_ID         NUMBER(19)    NOT NULL,
  BRANCH_CODE       VARCHAR2(10)  NOT NULL,
  SALES_POINT_CODE  VARCHAR2(10),
  ATTRACT_EMP_CODE  VARCHAR2(10),
  ATTRACT_EMP_FIO   VARCHAR2(200),
  UPDATED_AT        DATE          DEFAULT SYSDATE NOT NULL,
  UPDATED_BY        VARCHAR2(50)  DEFAULT USER NOT NULL
);

COMMENT ON TABLE CL_PHYS_BANK_DETAILS IS
  'Mijozni bankka bog''lovchi ma''lumotlar. "Shaxsiy" bo''limining "Bank ma''lumotlari"
   oynachasiga mos keladi: xizmat ko''rsatuvchi filial, savdo nuqtasi va mijozni jalb qilgan
   xodim ma''lumotlari. Har bir mijoz uchun bitta joriy yozuv (1:1).';

COMMENT ON COLUMN CL_PHYS_BANK_DETAILS.BANK_DETAIL_ID   IS 'Bank rekvizitlari yozuvining unikal identifikatori (PK)';
COMMENT ON COLUMN CL_PHYS_BANK_DETAILS.CLIENT_ID        IS 'Mijozga FK -> CL_PHYS_PERSONS.CLIENT_ID (CL_PHYS_BANK_DETAILS_F1), 1:1 bog''lanish (CL_PHYS_BANK_DETAILS_U1)';
COMMENT ON COLUMN CL_PHYS_BANK_DETAILS.BRANCH_CODE      IS 'Filial, FK -> CL_R_BRANCHES.BRANCH_CODE (CL_PHYS_BANK_DETAILS_F2)';
COMMENT ON COLUMN CL_PHYS_BANK_DETAILS.SALES_POINT_CODE IS 'Savdo nuqtasi (tochka prodaj), FK -> CL_R_SALES_POINTS.SALES_POINT_CODE (CL_PHYS_BANK_DETAILS_F3)';
COMMENT ON COLUMN CL_PHYS_BANK_DETAILS.ATTRACT_EMP_CODE IS 'Mijozni jalb qilgan xodimning kodi';
COMMENT ON COLUMN CL_PHYS_BANK_DETAILS.ATTRACT_EMP_FIO  IS 'Mijozni jalb qilgan xodimning F.I.Sh.';
COMMENT ON COLUMN CL_PHYS_BANK_DETAILS.UPDATED_AT       IS 'Yozuv oxirgi marta o''zgartirilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_BANK_DETAILS.UPDATED_BY       IS 'Yozuvni oxirgi marta o''zgartirgan foydalanuvchi (operator) login';

-- CL_PHYS_BANK_DETAILS: cheklovlar (constraints)
ALTER TABLE CL_PHYS_BANK_DETAILS ADD CONSTRAINT CL_PHYS_BANK_DETAILS_PK PRIMARY KEY (BANK_DETAIL_ID);
ALTER TABLE CL_PHYS_BANK_DETAILS ADD CONSTRAINT CL_PHYS_BANK_DETAILS_F1 FOREIGN KEY (CLIENT_ID)        REFERENCES CL_PHYS_PERSONS (CLIENT_ID) ON DELETE CASCADE;
ALTER TABLE CL_PHYS_BANK_DETAILS ADD CONSTRAINT CL_PHYS_BANK_DETAILS_F2 FOREIGN KEY (BRANCH_CODE)      REFERENCES CL_R_BRANCHES (BRANCH_CODE);
ALTER TABLE CL_PHYS_BANK_DETAILS ADD CONSTRAINT CL_PHYS_BANK_DETAILS_F3 FOREIGN KEY (SALES_POINT_CODE) REFERENCES CL_R_SALES_POINTS (SALES_POINT_CODE);
ALTER TABLE CL_PHYS_BANK_DETAILS ADD CONSTRAINT CL_PHYS_BANK_DETAILS_U1 UNIQUE (CLIENT_ID);

-- CL_PHYS_BANK_DETAILS: indekslar
CREATE INDEX CL_PHYS_BANK_DETAILS_I1 ON CL_PHYS_BANK_DETAILS (BRANCH_CODE);
CREATE INDEX CL_PHYS_BANK_DETAILS_I2 ON CL_PHYS_BANK_DETAILS (SALES_POINT_CODE);

--------------------------------------------------------------------------------
-- B6) CL_PHYS_FIN_SUMMARIES — "Moliyaviy" bo'limining KPI va "Daromad ma'lumotlari" bloki
--------------------------------------------------------------------------------
CREATE TABLE CL_PHYS_FIN_SUMMARIES (
  FIN_SUMMARY_ID        NUMBER(19)     GENERATED BY DEFAULT AS IDENTITY,
  CLIENT_ID             NUMBER(19)     NOT NULL,
  MONTHLY_SALARY_AMT    NUMBER(18,2)   DEFAULT 0 NOT NULL,
  SALARY_RECEIVE_METHOD VARCHAR2(20),
  ADDITIONAL_INCOME_AMT NUMBER(18,2)   DEFAULT 0 NOT NULL,
  TOTAL_INCOME_AMT      NUMBER(18,2)   GENERATED ALWAYS AS (MONTHLY_SALARY_AMT + ADDITIONAL_INCOME_AMT) VIRTUAL,
  DTI_PERCENT           NUMBER(5,2),
  CREDIT_SCORE          NUMBER(5),
  CALC_DATE             DATE           DEFAULT SYSDATE NOT NULL,
  IS_CURRENT            CHAR(1)        DEFAULT 'Y' NOT NULL
);

COMMENT ON TABLE CL_PHYS_FIN_SUMMARIES IS
  'Mijozning moliyaviy holati bo''yicha umumlashtirilgan ko''rsatkichlari. "Moliyaviy" bo''limi
   yuqorisidagi KPI kartochkalari (Oylik daromad, Qo''shimcha daromad, DTI, Kredit reytingi) va
   "Daromad ma''lumotlari" blokiga mos keladi. CALC_DATE bo''yicha tarixiylashtirilishi mumkin,
   IS_CURRENT = ''Y'' joriy hisoblangan ko''rsatkichni bildiradi.';

COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.FIN_SUMMARY_ID        IS 'Moliyaviy xulosa yozuvining unikal identifikatori (PK)';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.CLIENT_ID             IS 'Mijozga FK -> CL_PHYS_PERSONS.CLIENT_ID (CL_PHYS_FIN_SUMMARIES_F1)';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.MONTHLY_SALARY_AMT    IS 'Oylik maosh miqdori, so''mda ("Daromad ma''lumotlari" blokidagi "Oylik maosh")';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.SALARY_RECEIVE_METHOD IS 'Maoshni olish usuli: CARD — bank kartasi, CASH — naqd';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.ADDITIONAL_INCOME_AMT IS 'Qo''shimcha daromadlar yig''indisi, so''mda (CL_PHYS_EXTRA_INCOMES jadvali asosida hisoblanadi)';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.TOTAL_INCOME_AMT      IS 'Jami daromad, so''mda — hisoblanadigan (virtual) ustun: oylik maosh + qo''shimcha daromad';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.DTI_PERCENT           IS 'Kredit yuki koeffitsienti (Debt-to-Income), foizda';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.CREDIT_SCORE          IS 'Mijozning kredit reytingi (skoring balli)';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.CALC_DATE             IS 'Ko''rsatkichlar hisoblangan sana';
COMMENT ON COLUMN CL_PHYS_FIN_SUMMARIES.IS_CURRENT            IS 'Joriy hisob-kitob belgisi: Y — joriy, N — tarixiy';

-- CL_PHYS_FIN_SUMMARIES: cheklovlar (constraints)
ALTER TABLE CL_PHYS_FIN_SUMMARIES ADD CONSTRAINT CL_PHYS_FIN_SUMMARIES_PK PRIMARY KEY (FIN_SUMMARY_ID);
ALTER TABLE CL_PHYS_FIN_SUMMARIES ADD CONSTRAINT CL_PHYS_FIN_SUMMARIES_F1 FOREIGN KEY (CLIENT_ID) REFERENCES CL_PHYS_PERSONS (CLIENT_ID) ON DELETE CASCADE;
ALTER TABLE CL_PHYS_FIN_SUMMARIES ADD CONSTRAINT CL_PHYS_FIN_SUMMARIES_C1 CHECK (SALARY_RECEIVE_METHOD IN ('CARD','CASH'));
ALTER TABLE CL_PHYS_FIN_SUMMARIES ADD CONSTRAINT CL_PHYS_FIN_SUMMARIES_C2 CHECK (IS_CURRENT IN ('Y','N'));

-- CL_PHYS_FIN_SUMMARIES: indekslar
CREATE INDEX CL_PHYS_FIN_SUMMARIES_I1 ON CL_PHYS_FIN_SUMMARIES (CLIENT_ID);

--------------------------------------------------------------------------------
-- B7) CL_PHYS_WORKPLACES — "Moliyaviy" bo'limidagi "Ish joylari" bloki (1 mijoz -> N ish joyi)
--------------------------------------------------------------------------------
CREATE TABLE CL_PHYS_WORKPLACES (
  WORKPLACE_ID   NUMBER(19)    GENERATED BY DEFAULT AS IDENTITY,
  CLIENT_ID      NUMBER(19)    NOT NULL,
  ORG_NAME       VARCHAR2(300) NOT NULL,
  DEPARTMENT     VARCHAR2(150),
  POSITION_NAME  VARCHAR2(150),
  TIN            VARCHAR2(9),
  SENIORITY_CD   VARCHAR2(2),
  ORG_FORM_CD    VARCHAR2(10),
  IS_PRIMARY     CHAR(1)       DEFAULT 'Y' NOT NULL,
  CREATED_AT     DATE          DEFAULT SYSDATE NOT NULL,
  CREATED_BY     VARCHAR2(50)  DEFAULT USER NOT NULL
);

COMMENT ON TABLE CL_PHYS_WORKPLACES IS
  'Mijozning ish joylari. "Moliyaviy" bo''limining "Ish joylari" blokiga mos keladi — foydalanuvchi
   interfeysida "+ Ish joyi qo''shish" tugmasi orqali bir nechta ish joyi kiritilishi mumkinligi
   sababli bitta mijozga bir nechta yozuv (1:N) mo''ljallangan.';

COMMENT ON COLUMN CL_PHYS_WORKPLACES.WORKPLACE_ID  IS 'Ish joyi yozuvining unikal identifikatori (PK)';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.CLIENT_ID     IS 'Mijozga FK -> CL_PHYS_PERSONS.CLIENT_ID (CL_PHYS_WORKPLACES_F1)';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.ORG_NAME      IS 'Tashkilot nomi';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.DEPARTMENT    IS 'Bo''lim nomi';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.POSITION_NAME IS 'Lavozimi';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.TIN           IS 'STIR — tashkilotning soliq to''lovchi identifikatsion raqami (9 ta raqam)';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.SENIORITY_CD  IS 'Ish staji oralig''i, FK -> CL_R_SENIORITY_RANGES.SENIORITY_CD (CL_PHYS_WORKPLACES_F2)';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.ORG_FORM_CD   IS 'Tashkilot shakli, FK -> CL_R_ORG_FORMS.ORG_FORM_CD (CL_PHYS_WORKPLACES_F3)';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.IS_PRIMARY    IS 'Asosiy ish joyi belgisi: Y — asosiy, N — qo''shimcha';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.CREATED_AT    IS 'Yozuv yaratilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_WORKPLACES.CREATED_BY    IS 'Yozuvni yaratgan foydalanuvchi (operator) login';

-- CL_PHYS_WORKPLACES: cheklovlar (constraints)
ALTER TABLE CL_PHYS_WORKPLACES ADD CONSTRAINT CL_PHYS_WORKPLACES_PK PRIMARY KEY (WORKPLACE_ID);
ALTER TABLE CL_PHYS_WORKPLACES ADD CONSTRAINT CL_PHYS_WORKPLACES_F1 FOREIGN KEY (CLIENT_ID)    REFERENCES CL_PHYS_PERSONS (CLIENT_ID) ON DELETE CASCADE;
ALTER TABLE CL_PHYS_WORKPLACES ADD CONSTRAINT CL_PHYS_WORKPLACES_F2 FOREIGN KEY (SENIORITY_CD) REFERENCES CL_R_SENIORITY_RANGES (SENIORITY_CD);
ALTER TABLE CL_PHYS_WORKPLACES ADD CONSTRAINT CL_PHYS_WORKPLACES_F3 FOREIGN KEY (ORG_FORM_CD)  REFERENCES CL_R_ORG_FORMS (ORG_FORM_CD);
ALTER TABLE CL_PHYS_WORKPLACES ADD CONSTRAINT CL_PHYS_WORKPLACES_C1 CHECK (IS_PRIMARY IN ('Y','N'));

-- CL_PHYS_WORKPLACES: indekslar
CREATE INDEX CL_PHYS_WORKPLACES_I1 ON CL_PHYS_WORKPLACES (CLIENT_ID);
CREATE INDEX CL_PHYS_WORKPLACES_I2 ON CL_PHYS_WORKPLACES (ORG_FORM_CD);
CREATE INDEX CL_PHYS_WORKPLACES_I3 ON CL_PHYS_WORKPLACES (SENIORITY_CD);

--------------------------------------------------------------------------------
-- B8) CL_PHYS_EXTRA_INCOMES — "Moliyaviy" bo'limidagi "Qo'shimcha daromad manbalari" bloki
--------------------------------------------------------------------------------
CREATE TABLE CL_PHYS_EXTRA_INCOMES (
  EXTRA_INCOME_ID  NUMBER(19)     GENERATED BY DEFAULT AS IDENTITY,
  CLIENT_ID        NUMBER(19)     NOT NULL,
  INCOME_SOURCE_CD VARCHAR2(10)   NOT NULL,
  AVG_MONTHLY_AMT  NUMBER(18,2)   DEFAULT 0 NOT NULL,
  COMMENT_TXT      VARCHAR2(500),
  CREATED_AT       DATE           DEFAULT SYSDATE NOT NULL,
  CREATED_BY       VARCHAR2(50)   DEFAULT USER NOT NULL
);

COMMENT ON TABLE CL_PHYS_EXTRA_INCOMES IS
  'Mijozning asosiy maoshdan tashqari qo''shimcha daromad manbalari. "Moliyaviy" bo''limining
   "Qo''shimcha daromad manbalari" blokiga mos keladi — "+ Qo''shimcha daromad qo''shish" tugmasi
   orqali bir nechta manba kiritilishi mumkinligi sababli bitta mijozga bir nechta yozuv (1:N).';

COMMENT ON COLUMN CL_PHYS_EXTRA_INCOMES.EXTRA_INCOME_ID  IS 'Qo''shimcha daromad manbai yozuvining unikal identifikatori (PK)';
COMMENT ON COLUMN CL_PHYS_EXTRA_INCOMES.CLIENT_ID        IS 'Mijozga FK -> CL_PHYS_PERSONS.CLIENT_ID (CL_PHYS_EXTRA_INCOMES_F1)';
COMMENT ON COLUMN CL_PHYS_EXTRA_INCOMES.INCOME_SOURCE_CD IS 'Daromad manbai, FK -> CL_R_INCOME_SOURCES.INCOME_SOURCE_CD (CL_PHYS_EXTRA_INCOMES_F2)';
COMMENT ON COLUMN CL_PHYS_EXTRA_INCOMES.AVG_MONTHLY_AMT  IS 'O''rtacha oylik daromad miqdori, so''mda';
COMMENT ON COLUMN CL_PHYS_EXTRA_INCOMES.COMMENT_TXT      IS 'Daromad manbai bo''yicha izoh (erkin matn)';
COMMENT ON COLUMN CL_PHYS_EXTRA_INCOMES.CREATED_AT       IS 'Yozuv yaratilgan sana/vaqt';
COMMENT ON COLUMN CL_PHYS_EXTRA_INCOMES.CREATED_BY       IS 'Yozuvni yaratgan foydalanuvchi (operator) login';

-- CL_PHYS_EXTRA_INCOMES: cheklovlar (constraints)
ALTER TABLE CL_PHYS_EXTRA_INCOMES ADD CONSTRAINT CL_PHYS_EXTRA_INCOMES_PK PRIMARY KEY (EXTRA_INCOME_ID);
ALTER TABLE CL_PHYS_EXTRA_INCOMES ADD CONSTRAINT CL_PHYS_EXTRA_INCOMES_F1 FOREIGN KEY (CLIENT_ID)        REFERENCES CL_PHYS_PERSONS (CLIENT_ID) ON DELETE CASCADE;
ALTER TABLE CL_PHYS_EXTRA_INCOMES ADD CONSTRAINT CL_PHYS_EXTRA_INCOMES_F2 FOREIGN KEY (INCOME_SOURCE_CD) REFERENCES CL_R_INCOME_SOURCES (INCOME_SOURCE_CD);

-- CL_PHYS_EXTRA_INCOMES: indekslar
CREATE INDEX CL_PHYS_EXTRA_INCOMES_I1 ON CL_PHYS_EXTRA_INCOMES (CLIENT_ID);
CREATE INDEX CL_PHYS_EXTRA_INCOMES_I2 ON CL_PHYS_EXTRA_INCOMES (INCOME_SOURCE_CD);

--------------------------------------------------------------------------------
-- Izoh: CL_PHYS_PERSONS.CLIENT_ID ga bog'liq barcha CL_PHYS_ jadvallari
-- ON DELETE CASCADE bilan bog'langan — mijoz o'chirilganda unga tegishli barcha
-- shaxsiy va moliyaviy yozuvlar ham o'chadi. Spravochnik (CL_R_*) jadvallari
-- CASCADE bilan bog'lanmagan — ular normal holatda faqat ma'lumot to'ldirish
-- (referensial yaxlitlik) uchun ishlatiladi va mustaqil boshqariladi.
--------------------------------------------------------------------------------
