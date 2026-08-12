-- Create table
create table CLIENT_ENTITIES
(
  client_id               NUMBER(12),
  client_uid              NUMBER(12),
  client_code             VARCHAR2(8) not null,
  status                  VARCHAR2(1),
  segment_code            VARCHAR2(50),
  bic                     VARCHAR2(11),
  is_identification_bdmab VARCHAR2(1),
  client_type             VARCHAR2(2),
  residency_type          VARCHAR2(1),
  organization_name       VARCHAR2(255),
  registration_number     VARCHAR2(50),
  registration_date       DATE,
  inn                     VARCHAR2(20),
  director_name           VARCHAR2(80),
  director_passport       VARCHAR2(30),
  accountant_name         VARCHAR2(80),
  accountant_passport     VARCHAR2(30),
  phone                   VARCHAR2(50),
  mobile_phone            VARCHAR2(50),
  modify_on               DATE,
  modify_by               NUMBER(9),
  operator_code           NUMBER(9),
  date_open               DATE
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate indexes 
create index CLIENT_ENTITIES_I1 on CLIENT_ENTITIES (INN)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create index CLIENT_ENTITIE_I3 on CLIENT_ENTITIES (ORGANIZATION_NAME)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index CLIENT_ENTITIE_U1 on CLIENT_ENTITIES (CLIENT_ID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index CLIENT_ENTITIE_U2 on CLIENT_ENTITIES (CLIENT_UID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints 
alter table CLIENT_ENTITIES
  add constraint CLIENT_ENTITIES_PK primary key (CLIENT_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
