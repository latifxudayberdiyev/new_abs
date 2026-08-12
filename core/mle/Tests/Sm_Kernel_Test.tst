PL/SQL Developer Test script 3.0
30
declare
  v_clob clob := '{"module_code":"MFI","error_code":11123,"message_masks":["templateD $1 YANGILANDI rus","template $1 YANGILANDI krill","template $1 YANGILANDI uzbek",
  "template $1 UPDATED en","template $1 YANGILANDI uzbek","template $1 YANGILANDI uzbek","template $1 YANGILANDI uzbek","template $1 YANGILANDI uzbek",
  "template $1 YANGILANDI uzbek","template $1 YANGILANDI uzbek"],"process_code":"SAVE_ERROR_WITH_TEMPLATE",
  "x-csrf-token":"","message_code":"TEST12","format_string":"$","description":"TEST UPDATE 999","template_id":1,"request":"save","param_count":1}';
  v_hash hash_t := hash_t;
  v_Token varchar2(64);
  v_Ttl   number;
begin
  -- Call the procedure
  Json_Parser.Parse_Json(v_Clob, v_Hash, true);
  
  dbms_output.put_line(v_Hash.Get_Optional_Varchar2('message_code'));
  --
  Auth_Session.Create_Session(i_User_Id    => -1,
                              i_Provider   => 'LOCAL',
                              i_Cb_Code    => '00440',
                              i_Local_Code => '00000',
                              i_Lang       => 1,
                              i_Client_Ip  => '127.0.0.1',
                              i_User_Agent => 'EMSE',
                              o_Token      => v_Token,
                              o_Ttl_Sec    => v_Ttl);
  --
  Sm_Kernel.Set_Method(Io_Hash   => v_hash,
                       o_Code    => :o_Code,
                       o_Msg     => :o_Msg,
                       o_Ora_Msg => :o_Ora_Msg);
                                            
end;
3
o_Code
1
3
5
o_Msg
1
TEST12 уже существует
5
o_Ora_Msg
1
TEST12 уже существует
5
8
Io_Object_t.o_code
v_Object_t.o_Msg
Io_Object_t.Procedure_Name 
Io_Object_t.o_Code
Io_Object_t.o_Msg
Io_Object_t.o_Ora_Msg
Io_Object_t.message_code
Io_Object_t.message_code
