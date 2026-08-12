----------------------------------------------------------------------------------------------------
--  CBR (Markaziy Bank) spravochniklar subsystemasini YANGI (CBR_% obyektlaridan bo'sh) bazaga
--  o'rnatish. "Bo'sh" - faqat CBR_% obyektlari yo'q degani; Core/SM/Access freymvorki (Core.Hash_t,
--  Core_Api.Execute_Process_Clob, Sm_Kernel, SM_R_*, CORE_R_MODULES/MENUS/MENU_BUTTONS,
--  ADM_REL_USER_MENUS/BUTTONS, mlt_templates, mll_label_codes) bazada ALLAQACHON o'rnatilgan
--  bo'lishi shart - bu skript ularni yaratmaydi, faqat ulardan foydalanadi.
--  Oracle 19c, schema CORE. 24 ta jadval (19 ta rasmiy CBR spravochnigi + kompilyatsiya
--  uchun kerak bo'lgan 5 tasi) + ESB orqali avtomatik sinxronlash mexanizmi (Cbr_Dml/Cbr_Kernel)
--  + JSP katalog uchun view'lar/grantlar/menyu.
--
--  E'TIBOR: bu skript OBYEKTLARNI TO'G'RIDAN-TO'G'RI CBR_% nomlar bilan yaratadi (R_%/Ref_%
--  oraliq bosqichisiz). Agar baza avval R_%/Ref_% strukturasida bo'lgan bo'lsa (masalan,
--  172.25.43.35 TEST'dan eksport qilingan eski holat), buning o'rniga
--  core/cbr/rename/install_full_cbr_migration.sql skriptini ishlating.
--
--  Ishga tushirish tartibi: ushbu faylning o'zi barcha bosqichlarni ketma-ket bajaradi.
--  MUHIM: bu fayl UTF-8'da saqlangan (STATE_NAME uchun kirill matni bor) - sqlplus orqali
--  ishga tushirishda albatta NLS_LANG=AMERICAN_AMERICA.AL32UTF8 bilan chaqiring
--  (CL8MSWIN1251 emas!), aks holda kirill matni buzilib saqlanadi (mojibake).
----------------------------------------------------------------------------------------------------
set define off;
set serveroutput on size unlimited;

prompt =====================================================================
prompt 1) Jadvallar (CBR_R_PROCEDURES + 24 ta cbr_* spravochnik jadvali)
prompt =====================================================================

CREATE TABLE Cbr_r_Procedures
(  Ref_Id         NUMBER(6,0) NOT NULL,
   Procedure_Name VARCHAR2(200) NOT NULL,
   CONSTRAINT Cbr_r_Procedures_PK PRIMARY KEY (Ref_Id)
);

CREATE TABLE cbr_Region
(  Code       VARCHAR2(2) NOT NULL,
   Name       VARCHAR2(200),
   Order_By   NUMBER(2,0),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Region_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Currency
(  Code       VARCHAR2(3) NOT NULL,
   Char_Code  VARCHAR2(3),
   Name       VARCHAR2(35),
   Scale      NUMBER(1,0),
   Scale_Name VARCHAR2(20),
   Hard       VARCHAR2(1),
   Allow      VARCHAR2(1),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Currency_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_District
(  Code        VARCHAR2(3) NOT NULL,
   Name        VARCHAR2(60 CHAR),
   Region_Code VARCHAR2(2),
   Date_Activ  DATE,
   Date_Deact  DATE,
   State       VARCHAR2(1),
   Modify_On   DATE,
   CONSTRAINT cbr_District_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Country
(  Code          VARCHAR2(3) NOT NULL,
   Char_Code     VARCHAR2(3),
   Char_Ext_Code VARCHAR2(3),
   Name          VARCHAR2(150 CHAR),
   Currency_Code VARCHAR2(3),
   In_Sng        NUMBER(1,0),
   Date_Activ    DATE,
   Date_Deact    DATE,
   State         VARCHAR2(1),
   Modify_On     DATE,
   CONSTRAINT cbr_Country_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Business_Form
(  Code       VARCHAR2(3) NOT NULL,
   Name_Rus   VARCHAR2(150),
   Name_Uzb   VARCHAR2(150),
   Group_Code VARCHAR2(3),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Business_Form_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Credit_Source
(  Code       VARCHAR2(10) NOT NULL,
   Name       VARCHAR2(200),
   Group_Code VARCHAR2(10),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Credit_Source_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Foreign_Organization
(  Code               VARCHAR2(10) NOT NULL,
   Credit_Source_Code VARCHAR2(10),
   Name               VARCHAR2(250 CHAR),
   Label              VARCHAR2(200),
   Date_Activ         DATE,
   Date_Deact         DATE,
   State              VARCHAR2(1),
   Modify_On          DATE,
   CONSTRAINT cbr_Foreign_Organization_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Bank_Corr
(  Code         VARCHAR2(10) NOT NULL,
   Swift_Code   VARCHAR2(20),
   Name         VARCHAR2(200),
   Country_Code VARCHAR2(3),
   Date_Activ   DATE,
   Date_Deact   DATE,
   State        VARCHAR2(1),
   Modify_On    DATE,
   CONSTRAINT cbr_Bank_Corr_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Budget_Accounts
(  Code         VARCHAR2(20) NOT NULL,
   Account_Code VARCHAR2(30),
   Inn          VARCHAR2(9),
   Name         VARCHAR2(200),
   Date_Activ   DATE,
   Date_Deact   DATE,
   State        VARCHAR2(1),
   Modify_On    DATE,
   CONSTRAINT cbr_Budget_Accounts_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Oked
(  Sction_Gr       VARCHAR2(10),
   Section_Sy      VARCHAR2(10),
   Sg_Name_Ru      VARCHAR2(300 CHAR),
   Sg_Name_Uz      VARCHAR2(300 CHAR),
   Section_Code    VARCHAR2(10),
   Section_Name_Ru VARCHAR2(300 CHAR),
   Section_Name_Uz VARCHAR2(300 CHAR),
   Group_Code      VARCHAR2(10),
   Group_Name_Ru   VARCHAR2(300 CHAR),
   Group_Name_Uz   VARCHAR2(300 CHAR),
   Class_Code      VARCHAR2(10),
   Class_Name_Ru   VARCHAR2(300 CHAR),
   Class_Name_Uz   VARCHAR2(300 CHAR),
   Code            VARCHAR2(10) NOT NULL,
   Name_Ru         VARCHAR2(400 CHAR),
   Name_Uz         VARCHAR2(400 CHAR),
   Date_Activ      DATE,
   Date_Deact      DATE,
   State           VARCHAR2(1),
   Modify_On       DATE,
   CONSTRAINT cbr_Oked_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Subject_Type
(  Code       VARCHAR2(1) NOT NULL,
   Name       VARCHAR2(100 CHAR),
   Name_Uz    VARCHAR2(100 CHAR),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Subject_Type_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Subject_Sexual_Identity
(  Code       VARCHAR2(1) NOT NULL,
   Name       VARCHAR2(30 CHAR),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Subject_Sexual_Identity_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Verifying_Document_Type
(  Code       VARCHAR2(1) NOT NULL,
   Name       VARCHAR2(150 CHAR),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Verifying_Document_Type_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Bank
(  Code               VARCHAR2(5) NOT NULL,
   Bank_Type_Code     VARCHAR2(3),
   Region_Code        VARCHAR2(2),
   Header_Code        VARCHAR2(5),
   Union_Code         VARCHAR2(5),
   Tcr_Code           VARCHAR2(5),
   Rkc_Code           VARCHAR2(5),
   Name               VARCHAR2(200 CHAR),
   Adress             VARCHAR2(150 CHAR),
   Status_Code        VARCHAR2(2),
   Account_Type       VARCHAR2(1),
   Date_Open          DATE,
   Date_Close         DATE,
   Active             VARCHAR2(1),
   Email              VARCHAR2(18),
   Server_Alias       VARCHAR2(50),
   Connect_Type       VARCHAR2(1),
   Allow_Currency     VARCHAR2(1),
   District_Code      VARCHAR2(3),
   Num_Change_Office  NUMBER(2,0),
   Date_Activ         DATE,
   Date_Deact         DATE,
   State              VARCHAR2(1),
   Modify_On          DATE,
   CONSTRAINT cbr_Bank_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Bank_Type
(  Code         VARCHAR2(3) NOT NULL,
   Name         VARCHAR2(100 CHAR),
   Short_Name   VARCHAR2(50 CHAR),
   Country_Code VARCHAR2(3),
   Account_Type VARCHAR2(5),
   Date_Open    DATE,
   Date_Close   DATE,
   Date_Activ   DATE,
   Date_Deact   DATE,
   State        VARCHAR2(1),
   Modify_On    DATE,
   CONSTRAINT cbr_Bank_Type_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Document
(  Code       VARCHAR2(2) NOT NULL,
   Name       VARCHAR2(80 CHAR),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Document_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Rez_Cl
(  Code       VARCHAR2(1) NOT NULL,
   Name       VARCHAR2(50 CHAR),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Rez_Cl_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Tax_Organization
(  Code       VARCHAR2(4) NOT NULL,
   Name       VARCHAR2(80),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Tax_Organization_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Form_Property
(  Code       VARCHAR2(3) NOT NULL,
   Name       VARCHAR2(250 CHAR),
   Active     VARCHAR2(1),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Form_Property_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Organization_Legal_Form
(  Code       VARCHAR2(4) NOT NULL,
   Name       VARCHAR2(80),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Organization_Legal_Form_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Nation
(  Code        VARCHAR2(2) NOT NULL,
   Nation_Name VARCHAR2(40 CHAR),
   Date_Activ  DATE,
   Date_Deact  DATE,
   State       VARCHAR2(1),
   Modify_On   DATE,
   CONSTRAINT cbr_Nation_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Obraz
(  Code       VARCHAR2(1) NOT NULL,
   Obraz_Name VARCHAR2(60 CHAR),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT cbr_Obraz_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Coato
(  Code              VARCHAR2(5) NOT NULL,
   District_Code     VARCHAR2(3),
   District_Tax_Code VARCHAR2(4),
   Region_Code       VARCHAR2(2),
   Rus_Name          VARCHAR2(150 CHAR),
   Uzb_Cyr_Name      VARCHAR2(150 CHAR),
   Uzb_Lat_Name      VARCHAR2(150 CHAR),
   Date_Activ        DATE,
   Date_Deact        DATE,
   State             VARCHAR2(1),
   Modify_On         DATE,
   CONSTRAINT cbr_Coato_PK PRIMARY KEY (Code)
);

CREATE TABLE cbr_Mahalla
(  Code_Uz_Cad VARCHAR2(10) NOT NULL,
   Code_1c     VARCHAR2(8),
   Inn         VARCHAR2(9),
   Region_Id   VARCHAR2(4),
   Soato_Id    VARCHAR2(7),
   Distr       VARCHAR2(3),
   Name_Uz     VARCHAR2(50),
   Name_Ru     VARCHAR2(50),
   Name_En     VARCHAR2(50),
   Date_Open   DATE,
   Date_Close  DATE,
   Active      VARCHAR2(1),
   Modify_On   DATE,
   CONSTRAINT cbr_Mahalla_PK PRIMARY KEY (Code_Uz_Cad)
);

prompt =====================================================================
prompt 2) Cbr_r_Procedures: Ref_Id -> Cbr_Kernel.Set_Ref_XX xaritasi (24 ta)
prompt =====================================================================
insert into Cbr_r_Procedures values (16,  'Cbr_Kernel.Set_Ref_16');
insert into Cbr_r_Procedures values (17,  'Cbr_Kernel.Set_Ref_17');
insert into Cbr_r_Procedures values (52,  'Cbr_Kernel.Set_Ref_52');
insert into Cbr_r_Procedures values (18,  'Cbr_Kernel.Set_Ref_18');
insert into Cbr_r_Procedures values (38,  'Cbr_Kernel.Set_Ref_38');
insert into Cbr_r_Procedures values (41,  'Cbr_Kernel.Set_Ref_41');
insert into Cbr_r_Procedures values (47,  'Cbr_Kernel.Set_Ref_47');
insert into Cbr_r_Procedures values (29,  'Cbr_Kernel.Set_Ref_29');
insert into Cbr_r_Procedures values (93,  'Cbr_Kernel.Set_Ref_93');
insert into Cbr_r_Procedures values (13,  'Cbr_Kernel.Set_Ref_13');
insert into Cbr_r_Procedures values (6,   'Cbr_Kernel.Set_Ref_6');
insert into Cbr_r_Procedures values (7,   'Cbr_Kernel.Set_Ref_7');
insert into Cbr_r_Procedures values (8,   'Cbr_Kernel.Set_Ref_8');
insert into Cbr_r_Procedures values (12,  'Cbr_Kernel.Set_Ref_12');
insert into Cbr_r_Procedures values (14,  'Cbr_Kernel.Set_Ref_14');
insert into Cbr_r_Procedures values (26,  'Cbr_Kernel.Set_Ref_26');
insert into Cbr_r_Procedures values (27,  'Cbr_Kernel.Set_Ref_27');
insert into Cbr_r_Procedures values (54,  'Cbr_Kernel.Set_Ref_54');
insert into Cbr_r_Procedures values (57,  'Cbr_Kernel.Set_Ref_57');
insert into Cbr_r_Procedures values (63,  'Cbr_Kernel.Set_Ref_63');
insert into Cbr_r_Procedures values (72,  'Cbr_Kernel.Set_Ref_72');
insert into Cbr_r_Procedures values (74,  'Cbr_Kernel.Set_Ref_74');
insert into Cbr_r_Procedures values (92,  'Cbr_Kernel.Set_Ref_92');
insert into Cbr_r_Procedures values (125, 'Cbr_Kernel.Set_Ref_125');
commit;

prompt =====================================================================
prompt 2b) Cbr_r_References: 19 ta rasmiy spravochnik haqida umumiy katalog
prompt =====================================================================
CREATE TABLE Cbr_r_References
(  Ref_Id      NUMBER(6,0)   NOT NULL,
   Order_By    NUMBER(3,0)   NOT NULL,
   Table_Name  VARCHAR2(30 CHAR) NOT NULL,
   View_Name   VARCHAR2(30 CHAR) NOT NULL,
   Name        VARCHAR2(200 CHAR) NOT NULL,
   Description VARCHAR2(500 CHAR),
   State       VARCHAR2(1)   DEFAULT 'A' NOT NULL,
   Modify_On   DATE          DEFAULT sysdate NOT NULL,
   CONSTRAINT Cbr_r_References_PK PRIMARY KEY (Ref_Id)
);

insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(6,   1,  'CBR_SUBJECT_TYPE',            'CBR_SUBJECT_TYPE_V',            'Sub''ekt turi',                              'Jismoniy/yuridik shaxs sub''ekt turlari spravochnigi');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(7,   2,  'CBR_SUBJECT_SEXUAL_IDENTITY', 'CBR_SUBJECT_SEXUAL_IDENTITY_V', 'Jinsi',                                       'Sub''ekt jinsi spravochnigi');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(8,   3,  'CBR_VERIFYING_DOCUMENT_TYPE', 'CBR_VERIFYING_DOCUMENT_TYPE_V', 'Shaxsni tasdiqlovchi hujjat turi',           'Pasport, ID-karta va boshqa tasdiqlovchi hujjat turlari');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(12,  4,  'CBR_BANK',                    'CBR_BANK_V',                    'Banklar',                                     'O''zbekiston tijorat banklari va ularning filiallari');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(14,  5,  'CBR_BANK_TYPE',               'CBR_BANK_TYPE_V',               'Bank turlari',                                'Bank turlari klassifikatori');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(16,  6,  'CBR_REGION',                  'CBR_REGION_V',                  'Viloyatlar',                                  'O''zbekiston viloyatlari va Toshkent shahri');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(17,  7,  'CBR_CURRENCY',                'CBR_CURRENCY_V',                'Valyutalar',                                  'Valyuta kodlari klassifikatori (ISO 4217 asosida)');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(18,  8,  'CBR_COUNTRY',                 'CBR_COUNTRY_V',                 'Davlatlar',                                   'Davlatlar klassifikatori');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(26,  9,  'CBR_DOCUMENT',                'CBR_DOCUMENT_V',                'Hujjat turlari',                              'Bank operatsiyalarida ishlatiladigan hujjat turlari');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(27,  10, 'CBR_REZ_CL',                  'CBR_REZ_CL_V',                  'Rezidentlik toifasi',                        'Rezident/norezident toifalari klassifikatori');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(52,  11, 'CBR_DISTRICT',                'CBR_DISTRICT_V',                'Tumanlar',                                    'Tumanlar (rayonlar) klassifikatori');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(54,  12, 'CBR_TAX_ORGANIZATION',        'CBR_TAX_ORGANIZATION_V',        'Soliq organlari',                             'Soliq organlari (IFU) spravochnigi');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(57,  13, 'CBR_FORM_PROPERTY',           'CBR_FORM_PROPERTY_V',           'Mulkchilik shakli',                          'Mulkchilik shakllari klassifikatori');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(63,  14, 'CBR_ORGANIZATION_LEGAL_FORM', 'CBR_ORGANIZATION_LEGAL_FORM_V', 'Tashkiliy-huquqiy shakli',                    'Yuridik shaxslarning tashkiliy-huquqiy shakllari (OKOPF)');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(72,  15, 'CBR_NATION',                  'CBR_NATION_V',                  'Millati',                                     'Millat klassifikatori');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(74,  16, 'CBR_OBRAZ',                   'CBR_OBRAZ_V',                   'Ma''lumoti',                                 'Ta''lim darajasi klassifikatori');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(92,  17, 'CBR_COATO',                   'CBR_COATO_V',                   'SOATO',                                       'Hududiy-ma''muriy birliklar klassifikatori (SOATO)');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(93,  18, 'CBR_BUSINESS_FORM',           'CBR_BUSINESS_FORM_V',           'Xo''jalik yurituvchi sub''ekt shakli',       'Xo''jalik yurituvchi sub''ektlarning shakllari klassifikatori');
insert into Cbr_r_References (Ref_Id, Order_By, Table_Name, View_Name, Name, Description) values
(125, 19, 'CBR_MAHALLA',                 'CBR_MAHALLA_V',                 'Mahallalar',                                  'Mahallalar (fuqarolar yig''ini) klassifikatori');
commit;

create or replace view Cbr_r_References_v as
select * from Cbr_r_References order by Order_By;

prompt =====================================================================
prompt 3) cbr_*_v view'lar (JSP katalogi shulardan o'qiydi)
prompt =====================================================================
-- E'TIBOR: 19 ta rasmiy spravochnikning har birida STATE_NAME hisoblanadigan ustun bor
-- (STATE='A' -> 'Актив', qolgan barcha holatlar, jumladan NULL -> 'Пассив'). JSP katalogi
-- shu ustundan o'qiydi. 5 ta kompilyatsiya-uchun-kerak (19 talikka kirmaydigan) view'da
-- STATE_NAME yo'q.
create or replace view cbr_region_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_region t;
create or replace view cbr_currency_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_currency t;
create or replace view cbr_district_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_district t;
create or replace view cbr_country_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_country t;
create or replace view cbr_credit_source_v as select * from cbr_credit_source;
create or replace view cbr_foreign_organization_v as select * from cbr_foreign_organization;
create or replace view cbr_bank_corr_v as select * from cbr_bank_corr;
create or replace view cbr_budget_accounts_v as select * from cbr_budget_accounts;
create or replace view cbr_oked_v as select * from cbr_oked;
create or replace view cbr_subject_type_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_subject_type t;
create or replace view cbr_subject_sexual_identity_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_subject_sexual_identity t;
create or replace view cbr_verifying_document_type_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_verifying_document_type t;
create or replace view cbr_bank_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_bank t;
create or replace view cbr_bank_type_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_bank_type t;
create or replace view cbr_document_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_document t;
create or replace view cbr_rez_cl_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_rez_cl t;
create or replace view cbr_tax_organization_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_tax_organization t;
create or replace view cbr_form_property_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_form_property t;
create or replace view cbr_organization_legal_form_v as
select t.*, decode(t.state,'A','Актив','Пассив') as State_Name from cbr_organization_legal_form t;

create or replace view cbr_business_form_v as
select r.*, Name_Rus as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_business_form r;

create or replace view cbr_nation_v as
select r.*, Nation_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_nation r;

create or replace view cbr_obraz_v as
select r.*, Obraz_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_obraz r;

create or replace view cbr_coato_v as
select r.*, Uzb_Lat_Name as Name, decode(r.state,'A','Актив','Пассив') as State_Name from cbr_coato r;

create or replace view cbr_mahalla_v as
select r.*,
       Code_Uz_Cad as Code,
       Name_Uz     as Name,
       Date_Open   as Date_Activ,
       Date_Close  as Date_Deact,
       Active      as State,
       decode(r.Active,'A','Актив','Пассив') as State_Name
  from cbr_mahalla r;

prompt =====================================================================
prompt 4) Cbr_Dml paketi
prompt =====================================================================
create or replace package Cbr_Dml is
  Procedure Set_Ref_16(i_Row in cbr_Region%rowtype);
  Procedure Set_Ref_17(i_Row in cbr_Currency%rowtype);
  Procedure Set_Ref_52(i_Row in cbr_District%rowtype);
  Procedure Set_Ref_18(i_Row in cbr_Country%rowtype);
  Procedure Set_Ref_38(i_Row in cbr_Credit_Source%rowtype);
  Procedure Set_Ref_41(i_Row in cbr_Foreign_Organization%rowtype);
  Procedure Set_Ref_47(i_Row in cbr_Bank_Corr%rowtype);
  Procedure Set_Ref_29(i_Row in cbr_Budget_Accounts%rowtype);
  Procedure Set_Ref_93(i_Row in cbr_Business_Form%rowtype);
  Procedure Set_Ref_13(i_Row in cbr_Oked%rowtype);
  Procedure Set_Ref_6(i_Row in cbr_Subject_Type%rowtype);
  Procedure Set_Ref_7(i_Row in cbr_Subject_Sexual_Identity%rowtype);
  Procedure Set_Ref_8(i_Row in cbr_Verifying_Document_Type%rowtype);
  Procedure Set_Ref_12(i_Row in cbr_Bank%rowtype);
  Procedure Set_Ref_14(i_Row in cbr_Bank_Type%rowtype);
  Procedure Set_Ref_26(i_Row in cbr_Document%rowtype);
  Procedure Set_Ref_27(i_Row in cbr_Rez_Cl%rowtype);
  Procedure Set_Ref_54(i_Row in cbr_Tax_Organization%rowtype);
  Procedure Set_Ref_57(i_Row in cbr_Form_Property%rowtype);
  Procedure Set_Ref_63(i_Row in cbr_Organization_Legal_Form%rowtype);
  Procedure Set_Ref_72(i_Row in cbr_Nation%rowtype);
  Procedure Set_Ref_74(i_Row in cbr_Obraz%rowtype);
  Procedure Set_Ref_92(i_Row in cbr_Coato%rowtype);
  Procedure Set_Ref_125(i_Row in cbr_Mahalla%rowtype);
end Cbr_Dml;
/
create or replace package body Cbr_Dml is
  Procedure Set_Ref_16(i_Row in cbr_Region%rowtype) is
    v_Row cbr_Region%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Region t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Region values v_Row; end if;
  end;
  Procedure Set_Ref_17(i_Row in cbr_Currency%rowtype) is
    v_Row cbr_Currency%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Currency t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Currency values v_Row; end if;
  end;
  Procedure Set_Ref_52(i_Row in cbr_District%rowtype) is
    v_Row cbr_District%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_District t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_District values v_Row; end if;
  end;
  Procedure Set_Ref_18(i_Row in cbr_Country%rowtype) is
    v_Row cbr_Country%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Country t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Country values v_Row; end if;
  end;
  Procedure Set_Ref_41(i_Row in cbr_Foreign_Organization%rowtype) is
    v_Row cbr_Foreign_Organization%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Foreign_Organization t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Foreign_Organization values v_Row; end if;
  end;
  Procedure Set_Ref_38(i_Row in cbr_Credit_Source%rowtype) is
    v_Row cbr_Credit_Source%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Credit_Source t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Credit_Source values v_Row; end if;
  end;
  Procedure Set_Ref_47(i_Row in cbr_Bank_Corr%rowtype) is
    v_Row cbr_Bank_Corr%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank_Corr t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Bank_Corr values v_Row; end if;
  end;
  Procedure Set_Ref_29(i_Row in cbr_Budget_Accounts%rowtype) is
    v_Row cbr_Budget_Accounts%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Budget_Accounts t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Budget_Accounts values v_Row; end if;
  end;
  Procedure Set_Ref_93(i_Row in cbr_Business_Form%rowtype) is
    v_Row cbr_Business_Form%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Business_Form t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Business_Form values v_Row; end if;
  end;
  Procedure Set_Ref_13(i_Row in cbr_Oked%rowtype) is
    v_Row cbr_Oked%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Oked t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Oked values v_Row; end if;
  end;
  Procedure Set_Ref_6(i_Row in cbr_Subject_Type%rowtype) is
    v_Row cbr_Subject_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Subject_Type t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Subject_Type values v_Row; end if;
  end;
  Procedure Set_Ref_7(i_Row in cbr_Subject_Sexual_Identity%rowtype) is
    v_Row cbr_Subject_Sexual_Identity%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Subject_Sexual_Identity t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Subject_Sexual_Identity values v_Row; end if;
  end;
  Procedure Set_Ref_8(i_Row in cbr_Verifying_Document_Type%rowtype) is
    v_Row cbr_Verifying_Document_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Verifying_Document_Type t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Verifying_Document_Type values v_Row; end if;
  end;
  Procedure Set_Ref_12(i_Row in cbr_Bank%rowtype) is
    v_Row cbr_Bank%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Bank values v_Row; end if;
  end;
  Procedure Set_Ref_14(i_Row in cbr_Bank_Type%rowtype) is
    v_Row cbr_Bank_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank_Type t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Bank_Type values v_Row; end if;
  end;
  Procedure Set_Ref_26(i_Row in cbr_Document%rowtype) is
    v_Row cbr_Document%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Document t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Document values v_Row; end if;
  end;
  Procedure Set_Ref_27(i_Row in cbr_Rez_Cl%rowtype) is
    v_Row cbr_Rez_Cl%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Rez_Cl t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Rez_Cl values v_Row; end if;
  end;
  Procedure Set_Ref_54(i_Row in cbr_Tax_Organization%rowtype) is
    v_Row cbr_Tax_Organization%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Tax_Organization t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Tax_Organization values v_Row; end if;
  end;
  Procedure Set_Ref_57(i_Row in cbr_Form_Property%rowtype) is
    v_Row cbr_Form_Property%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Form_Property t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Form_Property values v_Row; end if;
  end;
  Procedure Set_Ref_63(i_Row in cbr_Organization_Legal_Form%rowtype) is
    v_Row cbr_Organization_Legal_Form%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Organization_Legal_Form t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Organization_Legal_Form values v_Row; end if;
  end;
  Procedure Set_Ref_72(i_Row in cbr_Nation%rowtype) is
    v_Row cbr_Nation%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Nation t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Nation values v_Row; end if;
  end;
  Procedure Set_Ref_74(i_Row in cbr_Obraz%rowtype) is
    v_Row cbr_Obraz%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Obraz t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Obraz values v_Row; end if;
  end;
  Procedure Set_Ref_92(i_Row in cbr_Coato%rowtype) is
    v_Row cbr_Coato%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Coato t set row = v_Row where t.Code = v_Row.Code;
    if sql%rowcount = 0 then insert into cbr_Coato values v_Row; end if;
  end;
  Procedure Set_Ref_125(i_Row in cbr_Mahalla%rowtype) is
    v_Row cbr_Mahalla%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Mahalla t set row = v_Row where t.Code_Uz_Cad = v_Row.Code_Uz_Cad;
    if sql%rowcount = 0 then insert into cbr_Mahalla values v_Row; end if;
  end;
end Cbr_Dml;
/

prompt =====================================================================
prompt 5) Cbr_Kernel paketi (ESB orqali sinxronlash: Esbo_Kernel.Universal_Api)
prompt =====================================================================
create or replace package Cbr_Kernel is
  Procedure Set_Ref_52(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_16(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_17(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_18(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_38(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_41(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_47(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_29(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_93(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_13(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_6(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_7(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_8(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_12(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_14(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_26(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_27(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_54(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_57(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_63(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_72(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_74(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_92(i_Arr in Core.Array_Varchar2);
  Procedure Set_Ref_125(i_Arr in Core.Array_Varchar2);
  Procedure Get_Reference_Cb
  (
    i_Reference_Id in number,
    o_Code         out number,
    o_Msg          out varchar2,
    i_Page_Size    in number default 10
  );
end Cbr_Kernel;
/
create or replace package body Cbr_Kernel is
  Function Get_Ref_Procedure_Name(i_Ref_Id in number) return varchar2 is
    result varchar2(200);
  begin
    select t.Procedure_Name into result from Cbr_r_Procedures t where t.Ref_Id = i_Ref_Id;
    return result;
  end;
  Procedure Set_Ref_16(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Region%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2); v_Row.Order_By := i_Arr(3);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_16(i_Row => v_Row);
  end;
  Procedure Set_Ref_17(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Currency%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Char_Code := i_Arr(2); v_Row.Name := i_Arr(3);
    v_Row.Scale := i_Arr(4); v_Row.Scale_Name := i_Arr(5); v_Row.Hard := i_Arr(6); v_Row.Allow := i_Arr(7);
    v_Row.Date_Activ := to_date(i_Arr(8), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State := i_Arr(10);
    Cbr_Dml.Set_Ref_17(i_Row => v_Row);
  end;
  Procedure Set_Ref_52(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_District%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2); v_Row.Region_Code := i_Arr(3);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_52(i_Row => v_Row);
  end;
  Procedure Set_Ref_18(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Country%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Char_Code := i_Arr(2); v_Row.Char_Ext_Code := i_Arr(3); v_Row.Name := i_Arr(4);
    v_Row.Currency_Code := i_Arr(5); v_Row.In_Sng := i_Arr(6);
    v_Row.Date_Activ := to_date(i_Arr(7), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(8), 'dd.mm.rr');
    v_Row.State := i_Arr(9);
    Cbr_Dml.Set_Ref_18(i_Row => v_Row);
  end;
  Procedure Set_Ref_38(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Credit_Source%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2); v_Row.Group_Code := i_Arr(3);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_38(i_Row => v_Row);
  end;
  Procedure Set_Ref_41(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Foreign_Organization%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Credit_Source_Code := i_Arr(2); v_Row.Name := i_Arr(3); v_Row.Label := i_Arr(7);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_41(i_Row => v_Row);
  end;
  Procedure Set_Ref_47(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank_Corr%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Swift_Code := i_Arr(2); v_Row.Name := i_Arr(3); v_Row.Country_Code := i_Arr(4);
    v_Row.Date_Activ := to_date(i_Arr(5), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State := i_Arr(7);
    Cbr_Dml.Set_Ref_47(i_Row => v_Row);
  end;
  Procedure Set_Ref_29(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Budget_Accounts%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Account_Code := i_Arr(2); v_Row.Inn := i_Arr(3); v_Row.Name := i_Arr(4);
    v_Row.Date_Activ := to_date(i_Arr(5), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State := i_Arr(7);
    Cbr_Dml.Set_Ref_29(i_Row => v_Row);
  end;
  Procedure Set_Ref_93(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Business_Form%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name_Rus := i_Arr(2); v_Row.Name_Uzb := i_Arr(3); v_Row.Group_Code := i_Arr(4);
    v_Row.Date_Activ := to_date(i_Arr(5), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State := i_Arr(7);
    Cbr_Dml.Set_Ref_93(i_Row => v_Row);
  end;
  Procedure Set_Ref_13(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Oked%rowtype;
  begin
    v_Row.Sction_Gr := i_Arr(1); v_Row.Section_Sy := i_Arr(2); v_Row.Sg_Name_Ru := i_Arr(3); v_Row.Sg_Name_Uz := i_Arr(4);
    v_Row.Section_Code := i_Arr(5); v_Row.Section_Name_Ru := i_Arr(6); v_Row.Section_Name_Uz := i_Arr(7);
    v_Row.Group_Code := i_Arr(8); v_Row.Group_Name_Ru := i_Arr(9); v_Row.Group_Name_Uz := i_Arr(10);
    v_Row.Class_Code := i_Arr(11); v_Row.Class_Name_Ru := i_Arr(12); v_Row.Class_Name_Uz := i_Arr(13);
    v_Row.Code := i_Arr(14); v_Row.Name_Ru := i_Arr(15); v_Row.Name_Uz := i_Arr(16);
    v_Row.Date_Activ := to_date(i_Arr(17), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(18), 'dd.mm.rr');
    v_Row.State := i_Arr(19);
    Cbr_Dml.Set_Ref_13(i_Row => v_Row);
  end;
  Procedure Set_Ref_6(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Subject_Type%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5); v_Row.Name_Uz := i_Arr(6);
    Cbr_Dml.Set_Ref_6(i_Row => v_Row);
  end;
  Procedure Set_Ref_7(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Subject_Sexual_Identity%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_7(i_Row => v_Row);
  end;
  Procedure Set_Ref_8(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Verifying_Document_Type%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_8(i_Row => v_Row);
  end;
  Procedure Set_Ref_12(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Bank_Type_Code := i_Arr(2); v_Row.Region_Code := i_Arr(3);
    v_Row.Header_Code := i_Arr(4); v_Row.Union_Code := i_Arr(5); v_Row.Tcr_Code := i_Arr(6); v_Row.Rkc_Code := i_Arr(7);
    v_Row.Name := i_Arr(8); v_Row.Adress := i_Arr(9); v_Row.Status_Code := i_Arr(10); v_Row.Account_Type := i_Arr(11);
    v_Row.Date_Open := to_date(i_Arr(12), 'dd.mm.rr'); v_Row.Date_Close := to_date(i_Arr(13), 'dd.mm.rr');
    v_Row.Active := i_Arr(14); v_Row.Email := i_Arr(15); v_Row.Server_Alias := i_Arr(16); v_Row.Connect_Type := i_Arr(17);
    v_Row.Allow_Currency := i_Arr(18);
    v_Row.Date_Activ := to_date(i_Arr(19), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(20), 'dd.mm.rr');
    v_Row.District_Code := i_Arr(21); v_Row.Num_Change_Office := i_Arr(22); v_Row.State := i_Arr(23);
    Cbr_Dml.Set_Ref_12(i_Row => v_Row);
  end;
  Procedure Set_Ref_14(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank_Type%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2); v_Row.Short_Name := i_Arr(3); v_Row.Country_Code := i_Arr(4);
    v_Row.Account_Type := i_Arr(5);
    v_Row.Date_Open := to_date(i_Arr(6), 'dd.mm.rr'); v_Row.Date_Close := to_date(i_Arr(7), 'dd.mm.rr');
    v_Row.Date_Activ := to_date(i_Arr(8), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State := i_Arr(10);
    Cbr_Dml.Set_Ref_14(i_Row => v_Row);
  end;
  Procedure Set_Ref_26(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Document%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_26(i_Row => v_Row);
  end;
  Procedure Set_Ref_27(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Rez_Cl%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_27(i_Row => v_Row);
  end;
  Procedure Set_Ref_54(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Tax_Organization%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_54(i_Row => v_Row);
  end;
  Procedure Set_Ref_57(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Form_Property%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.Active := i_Arr(5); v_Row.State := i_Arr(6);
    Cbr_Dml.Set_Ref_57(i_Row => v_Row);
  end;
  Procedure Set_Ref_63(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Organization_Legal_Form%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_63(i_Row => v_Row);
  end;
  Procedure Set_Ref_72(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Nation%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Nation_Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_72(i_Row => v_Row);
  end;
  Procedure Set_Ref_74(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Obraz%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.Obraz_Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State := i_Arr(5);
    Cbr_Dml.Set_Ref_74(i_Row => v_Row);
  end;
  Procedure Set_Ref_92(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Coato%rowtype;
  begin
    v_Row.Code := i_Arr(1); v_Row.District_Code := i_Arr(2); v_Row.District_Tax_Code := i_Arr(3);
    v_Row.Region_Code := i_Arr(4); v_Row.Rus_Name := i_Arr(5); v_Row.Uzb_Cyr_Name := i_Arr(6); v_Row.Uzb_Lat_Name := i_Arr(7);
    v_Row.Date_Activ := to_date(i_Arr(8), 'dd.mm.rr'); v_Row.Date_Deact := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State := i_Arr(10);
    Cbr_Dml.Set_Ref_92(i_Row => v_Row);
  end;
  Procedure Set_Ref_125(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Mahalla%rowtype;
  begin
    v_Row.Code_Uz_Cad := i_Arr(1); v_Row.Code_1c := i_Arr(2); v_Row.Inn := i_Arr(3); v_Row.Region_Id := i_Arr(4);
    v_Row.Soato_Id := i_Arr(5); v_Row.Distr := i_Arr(6); v_Row.Name_Uz := i_Arr(7); v_Row.Name_Ru := i_Arr(8);
    v_Row.Name_En := i_Arr(9);
    v_Row.Date_Open := to_date(i_Arr(10), 'dd.mm.rr'); v_Row.Date_Close := to_date(i_Arr(11), 'dd.mm.rr');
    v_Row.Active := i_Arr(12);
    Cbr_Dml.Set_Ref_125(i_Row => v_Row);
  end;
  Procedure Call_Reference(i_Arr in Core.Array_Varchar2, i_Ref_Id in number) is
    v_Procedure_Name varchar2(200);
    v_Sql_Stm        varchar2(3000);
  begin
    v_Procedure_Name := Get_Ref_Procedure_Name(i_Ref_Id);
    v_Sql_Stm := 'begin ' || v_Procedure_Name || '(:1); end;';
    execute immediate v_Sql_Stm using in i_Arr;
  end;
  Procedure Get_Reference_Cb
  (
    i_Reference_Id in number,
    o_Code         out number,
    o_Msg          out varchar2,
    i_Page_Size    in number default 10
  ) is
    Io_Hash         Core.Hash_t := Core.Hash_t();
    v_Req           Core.Hash_t := Core.Hash_t();
    v_Response_Hash Core.Hash_t := Core.Hash_t();
    v_Page_Number   number := 1;
    v_Page_Size     number := nvl(i_Page_Size, 10);
    v_Data_List     Core.Arraylist := Core.Arraylist();
    v_Detail_Arr    Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Ora_Msg       varchar2(4000);
  begin
    o_Code := Core_Const.c_Success_Code;
    o_Msg  := null;
    loop
      Io_Hash := Core.Hash_t();
      v_Req   := Core.Hash_t();
      v_Req.Put('service_code', 'FB_ESB');
      v_Req.Put('method_code', '1');
      v_Req.Put('referenceId', to_char(i_Reference_Id));
      v_Req.Put('pageSize', to_char(v_Page_Size));
      v_Req.Put('page', to_char(v_Page_Number));
      Io_Hash.Put('esbo_request', v_Req);
      Esbo_Kernel.Universal_Api(Io_Hash => Io_Hash, o_Code => o_Code, o_Msg => o_Msg, o_Ora_Msg => v_Ora_Msg);
      if o_Code != Core_Const.c_Success_Code then
        o_Msg := o_Msg || ' ' || v_Ora_Msg;
        return;
      end if;
      v_Response_Hash := Io_Hash.Get_Optional_Hash_t('esbo_response');
      v_Data_List     := v_Response_Hash.Get_Optional_Arraylist('data');
      if v_Data_List is null or v_Data_List.Count = 0 then exit; end if;
      for i in 1 .. v_Data_List.Count loop
        v_Detail_Arr := v_Data_List.Get_r_Array_Varchar2(i);
        Call_Reference(v_Detail_Arr, i_Reference_Id);
      end loop;
      if v_Data_List.Count < v_Page_Size then exit; end if;
      v_Page_Number := v_Page_Number + 1;
    end loop;
  exception
    when others then
      o_Code := -999;
      o_Msg  := 'System error ' || sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
end Cbr_Kernel;
/

prompt =====================================================================
prompt 6) UAPP uchun grant + sinonim (JSP shu schema orqali ulanadi)
prompt =====================================================================
declare
  procedure safe_grant_syn(p_view varchar2) is
  begin
    execute immediate 'grant select on ' || p_view || ' to UAPP';
    execute immediate 'create or replace synonym UAPP.' || p_view || ' for CORE.' || p_view;
  exception
    when others then dbms_output.put_line('SKIP UAPP (' || p_view || '): ' || sqlerrm);
  end;
begin
  safe_grant_syn('cbr_region_v');
  safe_grant_syn('cbr_currency_v');
  safe_grant_syn('cbr_district_v');
  safe_grant_syn('cbr_country_v');
  safe_grant_syn('cbr_credit_source_v');
  safe_grant_syn('cbr_foreign_organization_v');
  safe_grant_syn('cbr_bank_corr_v');
  safe_grant_syn('cbr_budget_accounts_v');
  safe_grant_syn('cbr_business_form_v');
  safe_grant_syn('cbr_oked_v');
  safe_grant_syn('cbr_subject_type_v');
  safe_grant_syn('cbr_subject_sexual_identity_v');
  safe_grant_syn('cbr_verifying_document_type_v');
  safe_grant_syn('cbr_bank_v');
  safe_grant_syn('cbr_bank_type_v');
  safe_grant_syn('cbr_document_v');
  safe_grant_syn('cbr_rez_cl_v');
  safe_grant_syn('cbr_tax_organization_v');
  safe_grant_syn('cbr_form_property_v');
  safe_grant_syn('cbr_organization_legal_form_v');
  safe_grant_syn('cbr_nation_v');
  safe_grant_syn('cbr_obraz_v');
  safe_grant_syn('cbr_coato_v');
  safe_grant_syn('cbr_mahalla_v');
  safe_grant_syn('cbr_r_references_v');
end;
/

prompt =====================================================================
prompt 7) Menyu: CORE_R_MODULES + mlt_templates/mll_label_codes + CORE_R_MENUS
prompt         + ADM_REL_USER_MENUS (barcha foydalanuvchilar uchun, user_id=-1)
prompt =====================================================================
insert into CORE_R_MODULES
  (module_code, module_id, parent_module_id, name_mll_code, short_name_mll_code, page_url, order_by, state)
values
  ('CBR', 5, 0, 'CBR_CB_MENU_GROUP', 'CBR_CB_MENU_GROUP', '/ibs/cbr/cbr_catalog.jsp', 5, 'A');

insert into mlt_templates (message_code, description, param_count, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
values ('CBR_CB_MENU_GROUP', 'CBR moduli menyu bo''limi sarlavhasi', 0, 'Справочник', 'Маълумотнома', 'Ma''lumotnoma', 'Reference');

insert into mlt_templates (message_code, description, param_count, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
values ('CBR_CB_MENU_CATALOG', 'Sidebar: Markaziy Bank spravochniklari', 0, 'Справочники ЦБ', 'Марказий банк маълумотномалари', 'Markaziy bank ma''lumotnomalari', 'Central Bank references');

insert into mll_label_codes (label_id, module_code, message_code, description)
values (mll_label_codes_seq.nextval, 'CBR', 'CBR_CB_MENU_GROUP', 'CBR moduli menyu bo''limi sarlavhasi');

insert into mll_label_codes (label_id, module_code, message_code, description)
values (mll_label_codes_seq.nextval, 'CBR', 'CBR_CB_MENU_CATALOG', 'Sidebar: Markaziy Bank spravochniklari');

insert into CORE_R_MENUS (module_code, menu_id, parent_menu_id, name_mll_code, page_url, order_by, state)
values ('CBR', 8000, '0', 'CBR_CB_MENU_GROUP', '#', 8, 'A');

insert into CORE_R_MENUS (module_code, menu_id, parent_menu_id, name_mll_code, page_url, order_by, state)
values ('CBR', 8001, '8000', 'CBR_CB_MENU_CATALOG', '/ibs/cbr/cbr_catalog.jsp', 1, 'A');

insert into ADM_REL_USER_MENUS (user_id, menu_id, date_act, date_deact, state, created_by, created_on, modify_by, modify_on)
values (-1, 8000, sysdate, to_date('31-12-9999','dd-mm-yyyy'), 'A', -1, sysdate, -1, sysdate);

insert into ADM_REL_USER_MENUS (user_id, menu_id, date_act, date_deact, state, created_by, created_on, modify_by, modify_on)
values (-1, 8001, sysdate, to_date('31-12-9999','dd-mm-yyyy'), 'A', -1, sysdate, -1, sysdate);

commit;

prompt =====================================================================
prompt 8) Qo'lda va davriy yangilash mexanizmi (Cbr_Schedule_Kernel + Job)
prompt =====================================================================
alter table Cbr_r_References add (
  Refresh_Interval    varchar2(10),
  Next_Refresh_On     date,
  Last_Refresh_On     date,
  Last_Refresh_Status varchar2(1),
  Last_Refresh_Msg    varchar2(500)
);

create or replace view Cbr_r_References_v as
select * from Cbr_r_References order by Order_By;

begin
  execute immediate 'grant select on Cbr_r_References_v to UAPP';
  execute immediate 'create or replace synonym UAPP.Cbr_r_References_v for CORE.Cbr_r_References_v';
exception
  when others then dbms_output.put_line('SKIP UAPP (Cbr_r_References_v): ' || sqlerrm);
end;
/

create or replace package Cbr_Schedule_Kernel is
  -- Ruxsat etilgan interval kodlari: 15MIN, 1HOUR, 6HOUR, 1DAY, 10DAY, 1MONTH, 1YEAR.
  -- i_Interval = null -> avtomatik yangilanish o'chiriladi.
  Procedure Set_Schedule(i_Ref_Id in number, i_Interval in varchar2);

  -- Bitta spravochnikni darhol (qo'lda) yangilaydi, ESB orqali.
  Procedure Manual_Refresh
  (
    i_Ref_Id in number,
    o_Code   out number,
    o_Msg    out varchar2
  );

  -- Job tomonidan chaqiriladi: muddati kelgan barcha spravochniklarni yangilaydi.
  Procedure Run_Due_Refreshes;

  Function Compute_Next_Run(i_Interval in varchar2, i_From in date default sysdate) return date;
end Cbr_Schedule_Kernel;
/
create or replace package body Cbr_Schedule_Kernel is

  Function Compute_Next_Run(i_Interval in varchar2, i_From in date default sysdate) return date is
  begin
    if i_Interval is null then
      return null;
    end if;
    case i_Interval
      when '15MIN'  then return i_From + (15/1440);
      when '1HOUR'  then return i_From + (1/24);
      when '6HOUR'  then return i_From + (6/24);
      when '1DAY'   then return i_From + 1;
      when '10DAY'  then return i_From + 10;
      when '1MONTH' then return add_months(i_From, 1);
      when '1YEAR'  then return add_months(i_From, 12);
      else raise_application_error(-20001, 'Notanish interval: ' || i_Interval);
    end case;
  end;

  Procedure Set_Schedule(i_Ref_Id in number, i_Interval in varchar2) is
  begin
    if i_Interval is not null and i_Interval not in ('15MIN','1HOUR','6HOUR','1DAY','10DAY','1MONTH','1YEAR') then
      raise_application_error(-20002, 'Notanish interval kodi: ' || i_Interval);
    end if;
    update Cbr_r_References
       set Refresh_Interval = i_Interval,
           Next_Refresh_On  = Compute_Next_Run(i_Interval, sysdate)
     where Ref_Id = i_Ref_Id;
    if sql%rowcount = 0 then
      raise_application_error(-20003, 'Ref_Id topilmadi: ' || i_Ref_Id);
    end if;
    commit;
  end;

  Procedure Manual_Refresh
  (
    i_Ref_Id in number,
    o_Code   out number,
    o_Msg    out varchar2
  ) is
    v_Interval varchar2(10);
  begin
    Cbr_Kernel.Get_Reference_Cb(i_Reference_Id => i_Ref_Id, o_Code => o_Code, o_Msg => o_Msg);

    select Refresh_Interval into v_Interval from Cbr_r_References where Ref_Id = i_Ref_Id;

    update Cbr_r_References
       set Last_Refresh_On     = sysdate,
           Last_Refresh_Status = case when o_Code = Core_Const.c_Success_Code then 'S' else 'E' end,
           Last_Refresh_Msg    = o_Msg,
           Next_Refresh_On     = Compute_Next_Run(v_Interval, sysdate)
     where Ref_Id = i_Ref_Id;
    commit;
  exception
    when others then
      o_Code := -999;
      o_Msg  := 'System error: ' || sqlerrm;
      update Cbr_r_References
         set Last_Refresh_On     = sysdate,
             Last_Refresh_Status = 'E',
             Last_Refresh_Msg    = o_Msg
       where Ref_Id = i_Ref_Id;
      commit;
  end;

  Procedure Run_Due_Refreshes is
    v_Code number;
    v_Msg  varchar2(4000);
  begin
    for r in (
      select Ref_Id from Cbr_r_References
       where Refresh_Interval is not null
         and Next_Refresh_On <= sysdate
    ) loop
      begin
        Manual_Refresh(i_Ref_Id => r.Ref_Id, o_Code => v_Code, o_Msg => v_Msg);
      exception
        when others then null; -- bitta spravochnikdagi xato qolganlarini to'xtatmasin
      end;
    end loop;
  end;

end Cbr_Schedule_Kernel;
/

begin
  begin
    dbms_scheduler.drop_job('CBR_REFRESH_JOB', force => true);
  exception
    when others then null;
  end;

  dbms_scheduler.create_job(
    job_name        => 'CBR_REFRESH_JOB',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'Cbr_Schedule_Kernel.Run_Due_Refreshes',
    start_date      => sysdate,
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=15',
    enabled         => true,
    comments        => 'CBR spravochniklarini muddati kelganda ESB orqali avtomatik yangilaydi (15 daqiqada bir tekshiradi)'
  );
end;
/

prompt =====================================================================
prompt 9) Cbr_Sm_Api: qo'lda yangilash/interval amallarini SM ro'yxatiga qo'shish
prompt    (bank tizimidagi har bir amal Core_Api.Execute_Process_Clob umumiy
prompt    dispetcheri orqali SM_R_* jadvallar bo'yicha topiladi)
prompt =====================================================================
create or replace package Cbr_Sm_Api is
  Procedure Manual_Refresh
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  Procedure Set_Schedule
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Cbr_Sm_Api;
/
create or replace package body Cbr_Sm_Api is

  Procedure Manual_Refresh
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    o_Ora_Msg := null;
    Cbr_Schedule_Kernel.Manual_Refresh(
      i_Ref_Id => Io_Hash.Get_Number('ref_id'),
      o_Code   => o_Code,
      o_Msg    => o_Msg
    );
  exception
    when others then
      o_Code    := -999;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;

  Procedure Set_Schedule
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
  begin
    o_Ora_Msg := null;
    Cbr_Schedule_Kernel.Set_Schedule(
      i_Ref_Id    => Io_Hash.Get_Number('ref_id'),
      i_Interval  => Io_Hash.Get_Optional_Varchar2('interval')
    );
    o_Code := Core_Const.c_Success_Code;
    o_Msg  := null;
  exception
    when others then
      o_Code    := -999;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;

end Cbr_Sm_Api;
/

declare
  procedure safe_ins(p_sql varchar2) is
  begin
    execute immediate p_sql;
  exception
    when others then
      if sqlcode != -1 then raise; end if; -- -1 = unique constraint (allaqachon bor)
  end;
begin
  safe_ins(q'[insert into SM_R_OBJECTS (object_code, parent_object_code, initial_state, sequence_getter, created_on, created_developer, state)
              values ('CBR_REFERENCE', 'ROOT', null, null, sysdate, 'CBR', 'A')]');

  safe_ins(q'[insert into SM_R_PROCESSES (process_code, object_code, parent_object_code, state, relation_key, created_on, created_developer, process_type, set_log, description)
              values ('CBR_MANUAL_REFRESH', 'CBR_REFERENCE', 'ROOT', 'A', 'ref_id', sysdate, 'CBR', 'OPERATION', 'Y', 'CBR spravochnikni qo''lda (darhol) yangilash')]');
  safe_ins(q'[insert into SM_R_PROCESSES (process_code, object_code, parent_object_code, state, relation_key, created_on, created_developer, process_type, set_log, description)
              values ('CBR_SET_SCHEDULE', 'CBR_REFERENCE', 'ROOT', 'A', 'ref_id', sysdate, 'CBR', 'OPERATION', 'Y', 'CBR spravochnik uchun avtomatik yangilanish intervalini belgilash')]');

  safe_ins(q'[insert into SM_R_EVENTS (event_code, state) values ('CBR_MANUAL_REFRESH_EVT', 'A')]');
  safe_ins(q'[insert into SM_R_EVENTS (event_code, state) values ('CBR_SET_SCHEDULE_EVT', 'A')]');
  safe_ins(q'[insert into SM_R_PROCESS_EVENTS (process_code, event_code, order_by, state, execution_mode)
              values ('CBR_MANUAL_REFRESH', 'CBR_MANUAL_REFRESH_EVT', 1, 'A', 'S')]');
  safe_ins(q'[insert into SM_R_PROCESS_EVENTS (process_code, event_code, order_by, state, execution_mode)
              values ('CBR_SET_SCHEDULE', 'CBR_SET_SCHEDULE_EVT', 1, 'A', 'S')]');

  safe_ins(q'[insert into SM_R_PROCEDURES (procedure_code, procedure_name, state) values ('CBR_MANUAL_REFRESH', 'Cbr_Sm_Api.Manual_Refresh', 'A')]');
  safe_ins(q'[insert into SM_R_PROCEDURES (procedure_code, procedure_name, state) values ('CBR_SET_SCHEDULE', 'Cbr_Sm_Api.Set_Schedule', 'A')]');
  safe_ins(q'[insert into SM_R_EVENT_PROCEDURES (event_code, procedure_code, order_by, state)
              values ('CBR_MANUAL_REFRESH_EVT', 'CBR_MANUAL_REFRESH', 1, 'A')]');
  safe_ins(q'[insert into SM_R_EVENT_PROCEDURES (event_code, procedure_code, order_by, state)
              values ('CBR_SET_SCHEDULE_EVT', 'CBR_SET_SCHEDULE', 1, 'A')]');

  safe_ins(q'[insert into mlt_templates (message_code, description, param_count, format_string, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
              values ('CBR_BTN_MANUAL_REFRESH', 'CBR: qo''lda yangilash tugmasi', 0, '$', 'Обновить сейчас', 'Ҳозир янгилаш', 'Hozir yangilash', 'Refresh now')]');
  safe_ins(q'[insert into mlt_templates (message_code, description, param_count, format_string, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4)
              values ('CBR_BTN_SET_SCHEDULE', 'CBR: interval saqlash tugmasi', 0, '$', 'Сохранить', 'Сақлаш', 'Saqlash', 'Save')]');
  safe_ins(q'[insert into mll_label_codes (label_id, module_code, message_code, description)
              values (mll_label_codes_seq.nextval, 'CBR', 'CBR_BTN_MANUAL_REFRESH', 'CBR: qo''lda yangilash tugmasi')]');
  safe_ins(q'[insert into mll_label_codes (label_id, module_code, message_code, description)
              values (mll_label_codes_seq.nextval, 'CBR', 'CBR_BTN_SET_SCHEDULE', 'CBR: interval saqlash tugmasi')]');

  safe_ins(q'[insert into CORE_R_MENU_BUTTONS (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state, button_type, process_code, created_by, created_on, modify_by, modify_on)
              values ('CBR', 8001, 10, 'CBR_MANUAL_REFRESH', 'CBR_BTN_MANUAL_REFRESH', 10, 'A', 'NAV', 'CBR_MANUAL_REFRESH', -1, sysdate, -1, sysdate)]');
  safe_ins(q'[insert into CORE_R_MENU_BUTTONS (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state, button_type, process_code, created_by, created_on, modify_by, modify_on)
              values ('CBR', 8001, 11, 'CBR_SET_SCHEDULE', 'CBR_BTN_SET_SCHEDULE', 11, 'A', 'NAV', 'CBR_SET_SCHEDULE', -1, sysdate, -1, sysdate)]');

  safe_ins(q'[insert into ADM_REL_USER_BUTTONS (user_id, button_id, menu_id, date_activate, date_deactivate, state, created_by, created_on, modify_by, modify_on)
              values (-1, 10, 8001, sysdate, to_date('31-12-9999','dd-mm-yyyy'), 'A', -1, sysdate, -1, sysdate)]');
  safe_ins(q'[insert into ADM_REL_USER_BUTTONS (user_id, button_id, menu_id, date_activate, date_deactivate, state, created_by, created_on, modify_by, modify_on)
              values (-1, 11, 8001, sysdate, to_date('31-12-9999','dd-mm-yyyy'), 'A', -1, sysdate, -1, sysdate)]');
end;
/
commit;

prompt =====================================================================
prompt Tekshirish: kompilyatsiya holati
prompt =====================================================================
select object_name || ' (' || object_type || '): ' || status
  from user_objects
 where object_name in ('CBR_DML','CBR_KERNEL','CBR_R_PROCEDURES','CBR_SCHEDULE_KERNEL','CBR_SM_API')
 order by object_name, object_type;

prompt Tayyor. Endi core/cbr/jsp/cbr_catalog.jsp faylini Tomcat'ga joylashtiring
prompt (\\172.20.6.157\tomcat9_ABS\webapps\ROOT\ibs\cbr\), Windows-1251 kodировkasida.
prompt Ma'lumotlarni yuklash uchun: core/cbr/data/loaded_0408/*.sql (avval widen_cbr_columns.sql
prompt ishga tushirilgan bo'lishi kerak, agar ustunlar hali kengaytirilmagan bo'lsa).

set define on;
