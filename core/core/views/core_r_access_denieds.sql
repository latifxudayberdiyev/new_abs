create or replace view core_r_access_denieds as
select 'N' as code, 'Нет' as name from dual
union all
select 'Y' as code, 'Да' as name from dual;
