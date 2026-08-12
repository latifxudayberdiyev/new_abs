-- Create table
create table CLIENT_INDIVIDUALS
(
  client_id                     NUMBER(12),
  client_uid                    NUMBER(12),
  client_code                   VARCHAR2(8) not null,
  status                        VARCHAR2(1),
  surname                       VARCHAR2(30),
  first_name                    VARCHAR2(30),
  patronymic                    VARCHAR2(30),
  name                          VARCHAR2(80),
  birthday                      DATE,
  pinfl                         VARCHAR2(14),
  inn                           VARCHAR2(9),
  passport_serial               VARCHAR2(20),
  passport_number               VARCHAR2(20),
  mobile_phone                  VARCHAR2(20),
  operator_code                 NUMBER(9),
  date_open                     DATE,
  modify_on                     DATE,
  modify_by                     NUMBER(9)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
create index CLIENT_INDIVIDUAL_I1 on CLIENT_INDIVIDUALS (PINFL)
  tablespace CORE_DATA
  pctfree 10
  initrans 2
  maxtrans 255;
create index CLIENT_INDIVIDUAL_I2 on CLIENT_INDIVIDUALS (PASSPORT_NUMBER, PASSPORT_SERIAL)
  tablespace CORE_DATA
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index CLIENT_INDIVIDUAL_U1 on CLIENT_INDIVIDUALS (CLIENT_ID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
create unique index CLIENT_INDIVIDUAL_U2 on CLIENT_INDIVIDUALS (CLIENT_UID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints 
alter table CLIENT_INDIVIDUALS
  add constraint CLIENT_INDIVIDUAL_PK primary key (CLIENT_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255;
