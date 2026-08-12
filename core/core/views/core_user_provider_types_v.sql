create or replace force view core_user_provider_types_v as
select 'LOCAL' code, 'Системный аутентификации' name
  from dual
union all
select 'AD' code, 'Active derectori' name
  from dual
union all
select 'STX_KEY' code, 'STX key bilan' name
  from dual
union all
select 'GOOGLE' code, 'google auth' name
  from dual;
