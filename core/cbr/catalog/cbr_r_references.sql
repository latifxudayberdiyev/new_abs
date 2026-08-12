----------------------------------------------------------------------------------------------------
--  CBR_R_REFERENCES: 19 ta rasmiy Markaziy Bank spravochnigi haqida umumiy katalog.
--  Har bir qatorda: Ref_Id (ESB/Cbr_r_Procedures bilan bir xil), jadval/view nomi,
--  qisqacha nomi, izoh va holati. JSP katalog sahifasi shu jadvaldan ro'yxatni
--  dinamik chiqarish uchun foydalanishi mumkin.
----------------------------------------------------------------------------------------------------

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

-- UAPP (JSP webapp) uchun grant + sinonim
begin
  execute immediate 'grant select on Cbr_r_References_v to UAPP';
  execute immediate 'create or replace synonym UAPP.Cbr_r_References_v for CORE.Cbr_r_References_v';
exception
  when others then dbms_output.put_line('SKIP UAPP (Cbr_r_References_v): ' || sqlerrm);
end;
/

commit;
exit;
