PL/SQL Developer Test script 3.0
18
declare
  -- Non-scalar parameters require additional processing 
  Io_Hash Hash_t := Hash_t();
  v_Req   Hash_t := Hash_t();
begin
  -- Call the procedure
  v_Req.Put('service_code', 'PSB_ESB');
  v_Req.Put('method_code', 'GET_EMP_INFO');
  v_Req.Put('tab_num', '149188'); --"pageSize":"20","referenceId":"13","page":"1"
  --v_Req.Put('pageSize', '10');
  --v_Req.Put('page', '1');
  Io_Hash.Put('esbo_request', v_Req);
  Esbo_Kernel.Universal_Api(Io_Hash   => Io_Hash,
                            o_Code    => :o_Code,
                            o_Msg     => :o_Msg,
                            o_Ora_Msg => :o_Ora_Msg);
  Dbms_Output.Put_Line(Io_Hash.Get_Optional_Hash_t('esbo_response').Json);
end;
3
o_Code
1
0
5
o_Msg
0
5
o_Ora_Msg
0
5
0
