-- Create table
create table CLIENT_individualS
(
  client_id                     NUMBER(12),
  client_uid                    NUMBER(12),
  client_code                   VARCHAR2(8) not null,
  status                        VARCHAR2(1),
  surname                       VARCHAR2(30),
  first_name                    VARCHAR2(30),
  patronymic                    VARCHAR2(30),
  name                          VARCHAR2(80),
  gender                        VARCHAR2(1),
  birthday                      DATE,
  birth_country                 VARCHAR2(3),
  birth_place                   VARCHAR2(60),
  country_birth                 VARCHAR2(3),
  pinfl                         VARCHAR2(14),
  inn                           VARCHAR2(9),
  passport_type                 VARCHAR2(1),
  passport_serial               VARCHAR2(20),
  passport_number               VARCHAR2(20),
  passport_registration_date    DATE,
  passport_registration_place   VARCHAR2(200),
  passport_expired_date         DATE,
  resident_code                 VARCHAR2(1),
  country_code                  VARCHAR2(3),
  region_code                   VARCHAR2(3),
  district_code                 VARCHAR2(3),
  village_code                  VARCHAR2(10),
  city                          VARCHAR2(256),
  address                       VARCHAR2(160),
  temporary_address             VARCHAR2(160),
  postal_code                   VARCHAR2(8),
  domicile_kadastor             VARCHAR2(500),
  phone                         VARCHAR2(20),
  mobile_phone                  VARCHAR2(20),
  email                         VARCHAR2(256),
  family_status                 NUMBER(1),
  work_capacity                 VARCHAR2(4),
  work_place                    VARCHAR2(128),
  pensionary_certification      VARCHAR2(10),
  pensionary_registration_date  DATE,
  pensionary_registration_place VARCHAR2(60),
  death_date                    DATE,
  operator_code                 NUMBER(9),
  date_open                     DATE,
  modify_on                     DATE,
  modify_by                     NUMBER(9)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Add comments to the table 
comment on table CLIENT_individualS
  is 'Jismoniy shaxs mijozlari bo‘yicha asosiy master jadval. Ushbu jadvalda mijozning identifikatsion, shaxsiy, pasport, rezidentlik, manzil, aloqa, ijtimoiy holat, pensiya va audit ma’lumotlari saqlanadi. Bankning boshqa modullari ushbu jadvaldagi CLIENT_ID yoki CLIENT_UID orqali bog‘lanadi.';
-- Add comments to the columns 
comment on column CLIENT_individualS.client_id
  is 'Jadval ichidagi asosiy ichki identifikator';
comment on column CLIENT_individualS.client_uid
  is 'Mijozning yagona global unique identifikatori';
comment on column CLIENT_individualS.client_code
  is 'Bank tizimidagi qisqa mijoz kodi';
comment on column CLIENT_individualS.status
  is 'Mijozning joriy holati (aktiv, bloklangan va hokazo)';
comment on column CLIENT_individualS.surname
  is 'Mijozning familiyasi';
comment on column CLIENT_individualS.first_name
  is 'Mijozning ismi';
comment on column CLIENT_individualS.patronymic
  is 'Mijozning otasining ismi';
comment on column CLIENT_individualS.name
  is 'Mijozning to‘liq F.I.Sh';
comment on column CLIENT_individualS.gender
  is 'Mijozning jinsi';
comment on column CLIENT_individualS.birthday
  is 'Mijozning tug‘ilgan sanasi';
comment on column CLIENT_individualS.birth_place
  is 'Mijozning tug‘ilgan joyi';
comment on column CLIENT_individualS.country_birth
  is 'Mijoz tug‘ilgan davlat kodi';
comment on column CLIENT_individualS.pinfl
  is 'JShShIR (PINFL) identifikatori';
comment on column CLIENT_individualS.inn
  is 'STIR (INN) raqami';
comment on column CLIENT_individualS.passport_type
  is 'Shaxsni tasdiqlovchi hujjat turi';
comment on column CLIENT_individualS.passport_serial
  is 'Pasport seriyasi';
comment on column CLIENT_individualS.passport_number
  is 'Pasport raqami';
comment on column CLIENT_individualS.passport_registration_date
  is 'Pasport berilgan sana';
comment on column CLIENT_individualS.passport_registration_place
  is 'Pasportni bergan organ yoki joy';
comment on column CLIENT_individualS.resident_code
  is 'Rezident yoki norezident belgisi';
comment on column CLIENT_individualS.country_code
  is 'Fuqarolik davlati kodi';
comment on column CLIENT_individualS.district_code
  is 'Tuman kodi';
comment on column CLIENT_individualS.village_code
  is 'Mahalla yoki qishloq kodi';
comment on column CLIENT_individualS.city
  is 'Shahar nomi';
comment on column CLIENT_individualS.address
  is 'Doimiy yashash manzili';
comment on column CLIENT_individualS.temporary_address
  is 'Vaqtinchalik yashash manzili';
comment on column CLIENT_individualS.domicile_kadastor
  is 'Yashash joyi bo‘yicha kadastr ma’lumoti';
comment on column CLIENT_individualS.phone
  is 'Uy telefoni raqami';
comment on column CLIENT_individualS.mobile_phone
  is 'Mobil telefon raqami';
comment on column CLIENT_individualS.email
  is 'Elektron pochta manzili';
comment on column CLIENT_individualS.family_status
  is 'Oilaviy holati';
comment on column CLIENT_individualS.work_capacity
  is 'Mehnatga layoqatlilik holati';
comment on column CLIENT_individualS.work_place
  is 'Ish joyi';
comment on column CLIENT_individualS.pensionary_certification
  is 'Pensiya guvohnomasi raqami';
comment on column CLIENT_individualS.pensionary_registration_date
  is 'Pensiya ro‘yxatidan o‘tgan sana';
comment on column CLIENT_individualS.pensionary_registration_place
  is 'Pensiya ro‘yxatidan o‘tgan joy';
comment on column CLIENT_individualS.death_date
  is 'Mijoz vafot etgan sana';
comment on column CLIENT_individualS.operator_code
  is 'Mijozni kiritgan yoki biriktirilgan operator kodi';
comment on column CLIENT_individualS.date_open
  is 'Mijoz tizimda ochilgan sana';
comment on column CLIENT_individualS.modify_on
  is 'Oxirgi o‘zgartirish sanasi';
comment on column CLIENT_individualS.modify_by
  is 'Oxirgi o‘zgartirishni amalga oshirgan foydalanuvchi';
comment on column CLIENT_individualS.passport_expired_date
  is 'Pasport muddati tugash sanasi';
-- Create/Recreate indexes 
create index CLIENT_individual_I1 on CLIENT_individualS (PINFL)
  tablespace CORE_DATA
  pctfree 10
  initrans 2
  maxtrans 255;
create index CLIENT_individual_I2 on CLIENT_individualS (PASSPORT_NUMBER, PASSPORT_SERIAL)
  tablespace CORE_DATA
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index CLIENT_individual_U1 on CLIENT_individualS (CLIENT_ID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index CLIENT_individual_U2 on CLIENT_individualS (CLIENT_UID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints 
alter table CLIENT_individualS
  add constraint CLIENT_individual_PK primary key (CLIENT_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
