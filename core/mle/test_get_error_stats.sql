set serveroutput on;

-------------------------------------------------------------------------------------------------------------
-- USER_ID only test
-------------------------------------------------------------------------------------------------------------
declare
  v_Hash   Core.Hash_t := Core.Hash_t();
  v_Data   Core.Hash_t := Core.Hash_t();
  v_Result Array_Varchar2;
  v_Code   number;
  v_Msg    varchar2(4000);
begin
  v_Data.Put('user_id', 1);
  v_Hash.Put('data', v_Data);

  Mle_Sm_Api.Get_Error_Stats(Io_Hash  => v_Hash,
                             o_Result => v_Result,
                             o_Code   => v_Code,
                             o_Msg    => v_Msg);

  Dbms_Output.Put_Line('code = ' || v_Code);
  Dbms_Output.Put_Line('msg  = ' || v_Msg);
  Dbms_Output.Put_Line('period_start | period_label | error_id | module_code | error_code | message_code | description | error_count');

  for i in 1 .. v_Result.Count
  loop
    Dbms_Output.Put_Line(v_Result(i));
  end loop;
end;
/

-------------------------------------------------------------------------------------------------------------
-- DAILY test
-------------------------------------------------------------------------------------------------------------
declare
  v_Hash   Core.Hash_t := Core.Hash_t();
  v_Data   Core.Hash_t := Core.Hash_t();
  v_Result Array_Varchar2;
  v_Code   number;
  v_Msg    varchar2(4000);
begin
  v_Data.Put('from_date', '01.07.2026');
  v_Data.Put('to_date', '31.07.2026');
  v_Data.Put('period_type', 'DAILY');
  -- v_Data.Put('user_id', 1);
  -- v_Data.Put('error_id', 1);
  v_Hash.Put('data', v_Data);

  Mle_Sm_Api.Get_Error_Stats(Io_Hash  => v_Hash,
                             o_Result => v_Result,
                             o_Code   => v_Code,
                             o_Msg    => v_Msg);

  Dbms_Output.Put_Line('code = ' || v_Code);
  Dbms_Output.Put_Line('msg  = ' || v_Msg);
  Dbms_Output.Put_Line('period_start | period_label | error_id | module_code | error_code | message_code | description | error_count');

  for i in 1 .. v_Result.Count
  loop
    Dbms_Output.Put_Line(v_Result(i));
  end loop;
end;
/

-------------------------------------------------------------------------------------------------------------
-- WEEKLY test
-------------------------------------------------------------------------------------------------------------
declare
  v_Hash   Core.Hash_t := Core.Hash_t();
  v_Data   Core.Hash_t := Core.Hash_t();
  v_Result Array_Varchar2;
  v_Code   number;
  v_Msg    varchar2(4000);
begin
  v_Data.Put('from_date', '01.07.2026');
  v_Data.Put('to_date', '31.07.2026');
  v_Data.Put('period_type', 'WEEKLY');
  v_Hash.Put('data', v_Data);

  Mle_Sm_Api.Get_Error_Stats(Io_Hash  => v_Hash,
                             o_Result => v_Result,
                             o_Code   => v_Code,
                             o_Msg    => v_Msg);

  Dbms_Output.Put_Line('code = ' || v_Code);
  Dbms_Output.Put_Line('msg  = ' || v_Msg);
  Dbms_Output.Put_Line('period_start | period_label | error_id | module_code | error_code | message_code | description | error_count');

  for i in 1 .. v_Result.Count
  loop
    Dbms_Output.Put_Line(v_Result(i));
  end loop;
end;
/

-------------------------------------------------------------------------------------------------------------
-- MONTHLY test
-------------------------------------------------------------------------------------------------------------
declare
  v_Hash   Core.Hash_t := Core.Hash_t();
  v_Data   Core.Hash_t := Core.Hash_t();
  v_Result Array_Varchar2;
  v_Code   number;
  v_Msg    varchar2(4000);
begin
  v_Data.Put('from_date', '01.01.2026');
  v_Data.Put('to_date', '31.12.2026');
  v_Data.Put('period_type', 'MONTHLY');
  v_Hash.Put('data', v_Data);

  Mle_Sm_Api.Get_Error_Stats(Io_Hash  => v_Hash,
                             o_Result => v_Result,
                             o_Code   => v_Code,
                             o_Msg    => v_Msg);

  Dbms_Output.Put_Line('code = ' || v_Code);
  Dbms_Output.Put_Line('msg  = ' || v_Msg);
  Dbms_Output.Put_Line('period_start | period_label | error_id | module_code | error_code | message_code | description | error_count');

  for i in 1 .. v_Result.Count
  loop
    Dbms_Output.Put_Line(v_Result(i));
  end loop;
end;
/
