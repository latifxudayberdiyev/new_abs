-- Create table
create table ESBO_R_SERVICES
(
  code  VARCHAR2(50) not null,
  name  VARCHAR2(200),
  state VARCHAR2(1) default 'A'
)
tablespace CORE_DATA
  pctfree 10
  initrans 1
  maxtrans 255;
-- Create/Recreate primary, unique and foreign key constraints 
alter table ESBO_R_SERVICES
  add constraint ESBO_R_SERVICES_PK primary key (CODE)
  using index
  tablespace CORE_DATA
  pctfree 10
  initrans 2
  maxtrans 255;
