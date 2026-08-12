PL/SQL Developer Test script 3.0
23
declare
  i_Clob clob;
  a      varchar2(1000) := '{
  "method": "mfi.api",
  "params": [
    {
      "process_code": "GET_ACTION_ROLE_RELATION",
      "object_code": "TRANCHE"
    }
  ]
}
';
begin
  Dbms_Lob.Createtemporary(i_Clob, true);
  Dbms_Lob.Writeappend(i_Clob, Length(a), a);

  Crobs_V3.Core_Session.Set_User_Session(1);
  Sm_Kernel.Set_Method(i_Clob    => i_Clob,
                       o_Clob    => :o_Clob,
                       o_Code    => :o_Code,
                       o_Msg     => :o_Msg,
                       o_Ora_Msg => :o_Ora_Msg);
end;
4
o_Clob
1
<CLOB>
112
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
