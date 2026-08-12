create or replace view core_r_yes_no as
select 'Y' as code, 'Да' as name from dual
union all
select 'N' as code, 'Нет' as name from dual;
