----------------------------------------------------------------------------------------------------
--  MODEL_USER: to'liq SM engine oqimi orqali (Core_Api.Get_Model_Clob -> Sm_Kernel.Set_Method ->
--  SM_R_PROCESSES metadata -> Core_Kernel.Model_User) forma-o'qish JSON'ni tekshiradi.
--  Asosiy fokus: hr_user_id (va boshqa nullable maydonlar) NULL bo'lganda ham JSON buzilmasligi
--  kerak (bug: Hash_t.Put(key, NULL number) "hr_user_id":, kabi yaroqsiz JSON chiqarardi -
--  butun payload JSON.parse'ni buzardi). Massiv-asosidagi kalitlar (identity_id/provider_type/
--  provider_key/is_required/key_state) ham tekshiriladi.
--  Fixture yaratilmaydi - allaqachon mavjud, haqiqiy test-user (user_id=142, hr_user_id/pinfl/
--  date_birth NULL) ustida ishlaydi, hech narsa yozmaydi/o'chirmaydi.
--  Ishga tushirish: sqlplus core/*** @core/Tests/20_test_core_kernel_model_user.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;
set define off;

declare
  v_Pass   number := 0;
  v_Fail   number := 0;
  c_Uid    constant number := 142;
  v_Result clob;
  v_Hash   Core.Hash_t;
  v_Form   Core.Hash_t;
  v_Token  varchar2(200);
  v_Ttl    number;
  --------------------------------------------------
  Procedure Assert
  (
    i_Name varchar2,
    i_Cond boolean
  ) is
  begin
    if i_Cond then
      v_Pass := v_Pass + 1;
      Dbms_Output.Put_Line('  PASS  ' || i_Name);
    else
      v_Fail := v_Fail + 1;
      Dbms_Output.Put_Line('  FAIL  ' || i_Name);
    end if;
  end;
begin
  Dbms_Output.Put_Line('=== MODEL_USER: to''liq SM dispatch orqali forma-o''qish (user_id=' || c_Uid || ') ===');

  --==== UAPP kontekst (Sm_Kernel/Core.User_Env shundan Created_By/user_id o'qiydi) ====
  Core.Auth_Session.Create_Session(
    i_User_Id    => c_Uid,
    i_Provider   => 'LOCAL',
    i_Cb_Code    => '00440',
    i_Local_Code => '01000',
    i_Lang       => 'UZ',
    i_Client_Ip  => '127.0.0.1',
    i_User_Agent => 'sqlplus-test',
    o_Token      => v_Token,
    o_Ttl_Sec    => v_Ttl
  );

  --==== chaqiruv: to'liq SM dispatch orqali ==========================
  v_Result := Core.Core_Api.Get_Model_Clob('{"process_code":"MODEL_USER","user_id":' || c_Uid || '}');

  -- Json_Parser.Parse_Json'ning o'zi muvaffaqiyatli o'tishi - "hr_user_id":, kabi
  -- yaroqsiz JSON bo'lmaganining birinchi va eng muhim isboti.
  v_Hash := Json_Parser.Parse_Json(v_Result);
  Assert('Get_Model_Clob natijasi valid JSON (hr_user_id NULL malformed emas)', v_Hash is not null);

  v_Form := v_Hash.Get_Hash_t('fm');
  Assert('fm mavjud', v_Form is not null);
  Assert('full_name to''g''ri', v_Form.Get_Varchar2('full_name') = 'API GATEWAY FINAL TEST');
  Assert('hr_user_id fm''da yo''q yoki bo''sh (NULL guard)',
         not v_Form.Has('hr_user_id') or v_Form.Get_Varchar2('hr_user_id') is null);
  Assert('identity_id massivi to''g''ri', v_Form.Get_Array_Varchar2('identity_id')(1) = '62');
  Assert('provider_type massivi to''g''ri', v_Form.Get_Array_Varchar2('provider_type')(1) = 'LOCAL');
  Assert('provider_key massivi to''g''ri', v_Form.Get_Array_Varchar2('provider_key')(1) = 'apigwfinal');
  Assert('is_required massivi to''g''ri', v_Form.Get_Array_Varchar2('is_required')(1) = 'N');
  Assert('key_state massivi to''g''ri', v_Form.Get_Array_Varchar2('key_state')(1) = 'A');

  Core.Auth_Session.Clear_Context;
  Dbms_Output.Put_Line('--- Test MODEL_USER: PASS=' || v_Pass || ' FAIL=' || v_Fail);
exception
  when others then
    Core.Auth_Session.Clear_Context;
    raise;
end;
/
set define on;
