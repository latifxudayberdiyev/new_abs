-- Create table
create table ACCOUNTS
(
  account_code    VARCHAR2(30) not null,
  account_id      NUMBER(12) not null,
  client_code     VARCHAR2(8) not null,
  client_uid      NUMBER(12) not null,
  name            VARCHAR2(300) not null,
  status          VARCHAR2(1) not null,
  code_coa        VARCHAR2(5) not null,
  currency_code   VARCHAR2(3) not null,
  local_code      VARCHAR2(5) not null,
  cbu_code        NUMBER(5) not null,
  date_open       DATE not null,
  lead_last_date  DATE,
  condition       VARCHAR2(1) not null,
  saldo_in        NUMBER(20) not null,
  saldo_out       NUMBER(20) not null,
  saldo_unlead    NUMBER(20) not null,
  turnover_debit  NUMBER(20) not null,
  turnover_credit NUMBER(20) not null,
  sign_registr    VARCHAR2(1) not null,
  gruppa_code     VARCHAR2(5),
  modify_on       DATE,
  modify_by       NUMBER(10),
  created_on      DATE,
  created_by      NUMBER(10)
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Add comments to the table 
comment on table ACCOUNTS
  is 'Mijozlarning bank hisobvaraqlari ma''lumotlarini saqlovchi jadval. Hisob raqami, balans, aylanmalar va holat ma''lumotlarini o''z ichiga oladi.';
-- Add comments to the columns 
comment on column ACCOUNTS.account_code
  is 'Hisobvaraqning kodi.';
comment on column ACCOUNTS.account_id
  is 'Hisobvaraqning yagona identifikatori.';
comment on column ACCOUNTS.client_code
  is 'Mijozga biriktirilgan noyob kod.';
comment on column ACCOUNTS.client_uid
  is 'Mijozning yagona raqamli identifikatori.';
comment on column ACCOUNTS.name
  is 'Hisobvaraq nomi.';
comment on column ACCOUNTS.status
  is 'Hisobvaraqning darajasi M-Основной, O-Вторичный.';
comment on column ACCOUNTS.code_coa
  is 'Buxgalteriya hisobvaraqlari rejasidagi kod.';
comment on column ACCOUNTS.currency_code
  is 'Valyuta kodi (masalan: 000, 840).';
comment on column ACCOUNTS.local_code
  is 'Filial yoki ichki lokal kod.';
comment on column ACCOUNTS.cbu_code
  is 'Markaziy bankdan berilgan bxm kodi.';
comment on column ACCOUNTS.date_open
  is 'Hisobvaraq ochilgan sana.';
comment on column ACCOUNTS.lead_last_date
  is 'Oxirgi buxgalteriya yangilanish sanasi.';
comment on column ACCOUNTS.condition
  is 'Hisobvaraqning joriy holati.';
comment on column ACCOUNTS.saldo_in
  is 'Boshlang''ich qoldiq summasi.';
comment on column ACCOUNTS.saldo_out
  is 'Yakuniy qoldiq summasi.';
comment on column ACCOUNTS.saldo_unlead
  is 'Buxgalteriyaga tushmagan qoldiq summasi.';
comment on column ACCOUNTS.turnover_debit
  is 'Debet bo''yicha jami aylanma summa.';
comment on column ACCOUNTS.turnover_credit
  is 'Kredit bo''yicha jami aylanma summa.';
comment on column ACCOUNTS.sign_registr
  is 'Ro''yxatdan o''tganlik belgisi A-Зарегистрирован, I-Не требует регистрации, O-Единое Окно.';
-- Create/Recreate indexes 
create index ACCOUNTS_I1 on ACCOUNTS (CLIENT_UID)
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
-- Create/Recreate primary, unique and foreign key constraints 
alter table ACCOUNTS
  add constraint ACCOUNTS_PK primary key (ACCOUNT_CODE)
  using index
  tablespace CORE_INDEX
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    next 1M
    minextents 1
    maxextents unlimited
  );
