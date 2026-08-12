create or replace view core_r_provider_types as
select 'LOCAL' as code, 'Локальный' as name from dual
union all
select 'AD' as code, 'Active Directory' as name from dual;
