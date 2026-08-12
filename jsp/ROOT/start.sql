/* OSM operation start script. CHANGE_ME qiymatlarini almashtiring. */
set serveroutput on size unlimited
set verify off

define p_operation_code = 'CHANGE_ME'
define p_module_code    = 'CHANGE_ME'
define p_input_json     = '{"REQUEST_ID":"TEST-001"}'

declare
  l_operation_code varchar2(50) := upper(trim('&&p_operation_code'));
  l_module_code    varchar2(50) := upper(trim('&&p_module_code'));
  l_input_json     clob := q'[&&p_input_json]';
  l_operation_id   number;
  l_count          pls_integer;
  l_request_id     number;
  l_status         varchar2(30);
  l_error_code     varchar2(100);
  l_error_message  varchar2(2000);
begin
  select count(*) into l_count
    from user_objects
   where object_name in ('OSM_OPERATION_CONST','OSM_OPERATION_CACHE',
         'OSM_OPERATION_PROTOCOL','OSM_ACTION_VALIDATOR',
         'OSM_ACTION_DISPATCHER','OSM_OPERATION')
     and object_type in ('PACKAGE','PACKAGE BODY')
     and status <> 'VALID';

  if l_count > 0 then
    raise_application_error(-20001,
      'OSM execution package INVALID. USER_ERRORS tekshirilsin.');
  end if;

  begin
    select operation_id into l_operation_id
      from (select operation_id
              from osm_r_operations
             where operation_code = l_operation_code
               and module_code = l_module_code
               and state = 'A'
               and effective_from <= sysdate
               and (effective_to is null or effective_to > sysdate)
             order by version_no desc)
     where rownum = 1;
  exception
    when no_data_found then
      raise_application_error(-20002,
        'Aktiv operation topilmadi: '||l_module_code||'.'||l_operation_code);
  end;

  select count(*) into l_count
    from osm_r_operation_actions oa
    join osm_r_actions a on a.action_id = oa.action_id
    left join osm_r_executor_functions e
      on e.executor_function_id = a.executor_function_id and e.state = 'A'
   where oa.operation_id = l_operation_id
     and oa.state = 'A'
     and a.state = 'A'
     and a.action_code is not null
     and e.executor_function_id is not null;

  if l_count = 0 then
    raise_application_error(-20003,
      'Operation uchun executor biriktirilgan aktiv action mavjud emas.');
  end if;

  dbms_output.put_line('START: '||l_module_code||'.'||l_operation_code);

  osm_operation.run(
    i_operation_code => l_operation_code,
    i_module_code    => l_module_code,
    i_params         => l_input_json,
    o_request_id     => l_request_id,
    o_status         => l_status,
    o_error_code     => l_error_code,
    o_error_message  => l_error_message
  );

  dbms_output.put_line('REQUEST_ID    = '||nvl(to_char(l_request_id),'NULL'));
  dbms_output.put_line('STATUS        = '||nvl(l_status,'NULL'));
  dbms_output.put_line('ERROR_CODE    = '||nvl(l_error_code,'NULL'));
  dbms_output.put_line('ERROR_MESSAGE = '||nvl(l_error_message,'NULL'));
end;
/

undefine p_operation_code
undefine p_module_code
undefine p_input_json
