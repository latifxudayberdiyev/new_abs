create or replace view r_state_v as
select 'A' as code, 'Активен' as name from dual
union all
select 'P' as code, 'Пассивен' as name from dual;
