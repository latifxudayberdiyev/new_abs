-- Create table
create table CLIENT_PROPRIETORS
(
  client_id           NUMBER(12),
  client_uid          NUMBER(12),
  client_code         VARCHAR2(8) not null,
  status              VARCHAR2(1),
  segment_code        VARCHAR2(12),
  surname             VARCHAR2(30),
  first_name          VARCHAR2(30),
  patronymic          VARCHAR2(30),
  name                VARCHAR2(80),
  birthday            DATE,
  passport_serial     VARCHAR2(20),
  passport_number     VARCHAR2(20),
  pinfl               VARCHAR2(20),
  inn                 VARCHAR2(20),
  mobile_phone        VARCHAR2(20),
  business_name       VARCHAR2(255),
  registration_date   DATE,
  registration_number VARCHAR2(50),
  director_name       VARCHAR2(80),
  director_passport   VARCHAR2(30),
  accountant_name     VARCHAR2(80),
  accountant_passport VARCHAR2(30),
  modify_on           DATE,
  modify_by           NUMBER(9),
  operator_code       NUMBER(9),
  date_open           DATE
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes 
create index CLIENT_PROPRIETOR_I1 on CLIENT_PROPRIETORS (PINFL)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create index CLIENT_PROPRIETOR_I2 on CLIENT_PROPRIETORS (PASSPORT_NUMBER, PASSPORT_SERIAL)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create index CLIENT_PROPRIETOR_I3 on CLIENT_PROPRIETORS (BUSINESS_NAME)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index CLIENT_PROPRIETOR_U1 on CLIENT_PROPRIETORS (CLIENT_ID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index CLIENT_PROPRIETOR_U2 on CLIENT_PROPRIETORS (CLIENT_UID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints 
alter table CLIENT_PROPRIETORS
  add constraint CLIENT_PROPRIETOR_PK primary key (CLIENT_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
