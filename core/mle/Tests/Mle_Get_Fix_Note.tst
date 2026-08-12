PL/SQL Developer Test script 3.0
24
declare
    v_Hash    Core.Hash_t;
    v_Data    Core.Hash_t;
    v_Code    number;
    v_Msg     varchar2(4000);
    v_Ora_Msg varchar2(4000);
begin
    v_Hash := Core.Hash_t();
   -- v_Hash.Put('error_id', 1001);   -- mavjud Note_Id qo'ying
    Mle_Kernel.Get_Fix_Note(
        Io_Hash   => v_Hash,
        o_Code    => v_Code,
        o_Msg     => v_Msg,
        o_Ora_Msg => v_Ora_Msg
    );
    dbms_output.put_line('--- Test 1: bitta note (detail) ---');
    dbms_output.put_line('code    : ' || v_Code);
    dbms_output.put_line('msg     : ' || v_Msg);
    dbms_output.put_line('ora_msg : ' || v_Ora_Msg);
    if v_Code = 0 then
        v_Data := v_Hash.Get_Hash_t('data');
        dbms_output.put_line(v_Data.Json());
    end if;
end;
0
0
