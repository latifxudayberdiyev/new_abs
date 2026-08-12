----------------------------------------------------------------------------------------------------
--  Core_Api process-code guard (Log_Process_Access, Core_Const.c_Process_Guard_Mode = 'LOG'):
--  kuzatuv (observability) rejimida hech narsani BLOKLAMASLIGINI va har chaqiruvda
--  CORE_PROCESS_ACCESS_LOG'ga bitta qator yozilishini tekshiradi.
--  Tekshiriladigan holatlar:
--   1) Core.Core_Api.Get_Model_Clob('{"process_code":"MODEL_USER","user_id":142}') - test 20
--      (20_test_core_kernel_model_user.sql) bilan bir xil chaqiruv - avvalgidek muvaffaqiyatli
--      o'tishi kerak (guard xatti-harakatni o'zgartirmagani isboti) VA CORE_PROCESS_ACCESS_LOG'da
--      door='GET_MODEL', process_code='MODEL_USER' uchun yangi qator paydo bo'lishi kerak
--      (outcome/would_block qiymati aynan nima ekani ADM_REL_USER_BUTTONS'dagi live grant holatiga
--      bog'liq - shu sabab faqat "qator bor va outcome/would_block NULL emas" tekshiriladi).
--   2) Core.Core_Api.Execute_Process_Clob mutlaqo bog'lanmagan (unmapped) process_code bilan -
--      CORE_R_MENU_BUTTONS'da hech qachon bo'lmaydigan kod - CORE_PROCESS_ACCESS_LOG'da
--      outcome='UNMAPPED' va would_block='N' bilan yozilishi SHART (bu LOG-bosqichning asosiy
--      kafolati: bog'lanmagan process HECH QACHON would_block='Y' bo'lib belgilanmaydi).
--      Execute_Process_Clob'ning o'zi bu yerda Sm_Kernel orqali istisno chiqarishi mumkin (kutilgan
--      va shu test uchun ahamiyatsiz) - shu sabab begin/exception ichida chaqiriladi.
--   3) Core.Core_Api.Get_Model_Clob (GET_MODEL eshigi) haqiqiy POST/OPERATION turidagi process_code
--      bilan - CREATE_USER (sm/inserts/SM_R_PROCESSES.sql seed faylida process_type='POST') -
--      cross-door escalation holati: CORE_R_MENU_BUTTONS'da model_process_code sifatida bog'lanmagan
--      bo'lsa-da, kod SM_R_PROCESSES'da to'g'ridan-to'g'ri mavjud va process_type != 'GET' - shu sabab
--      CORE_PROCESS_ACCESS_LOG'da outcome='WRONG_DOOR_TYPE' bilan yozilishi SHART. DIQQAT (semantik
--      o'zgarish, shu session ishi doirasida): would_block ENDI 'Y' (avval 'N' edi - "hozircha faqat
--      kuzatuv" bosqichida WRONG_DOOR_TYPE hech qachon bloklanmasdi; endi Core_Api.Check_Process_Access
--      buni ENFORCE_DOOR/ENFORCE rejimlarida haqiqatan bloklanadigan holat deb belgilaydi - lekin
--      Core_Const.c_Process_Guard_Mode joriy holatda 'LOG' bo'lgani uchun HALI HECH NARSA bloklanmaydi,
--      faqat would_block ustuni endi to'g'ri bashorat qiladi). Get_Model_Clob'ning o'zi bu yerda
--      Sm_Kernel orqali istisno chiqarishi kutilgan va shu test uchun ahamiyatsiz (CREATE_USER
--      GET-model process emasligi sababli) - shu sabab begin/exception ichida chaqiriladi.
--   Yana: Core_Const.c_Process_Guard_Mode joriy compile qilingan holatda 'LOG' bo'lgani uchun -
--   yuqoridagi UCHALA holatning HAR BIRIDA enforce_action='ALLOW' bo'lishi SHART (LOG rejimida
--   hech narsa hech qachon BLOCK/WARN_BYPASS bo'lmaydi, would_block qiymatidan qat'i nazar).
--  Fixture: mavjud test-user (user_id=142, test 20'dagi bilan bir xil) qayta ishlatiladi -
--  bu xavfsiz, chunki Log_Process_Access ADM_REL_USER_BUTTONS'ni FAQAT SELECT qiladi (grant
--  yozmaydi/o'zgartirmaydi) va bu test biror aniq outcome qiymatiga tayanmaydi.
--  Tozalash: CORE_PROCESS_ACCESS_LOG'da bu test yozgan qatorlarni aniqlash uchun testdan OLDINGI
--  max(log_id) chegara sifatida olinadi va faqat shu chegaradan katta log_id'lar o'chiriladi -
--  shu bilan boshqa (real/parallel) trafik yozuvlariga tegilmaydi.
--  Live-DB bog'liqligi: MODEL_USER uchun test 20'dagi kabi user_id=142 uchun to'g'ri konfiguratsiya
--  (identity_id/full_name va h.k.) mavjud deb faraz qilinadi - agar yo'q bo'lsa Get_Model_Clob
--  chaqiruvi istisno chiqarib testni FAIL qiladi (bu allaqachon test 20'ning ham bog'liqligi).
--  Ishga tushirish: sqlplus core/*** @core/Tests/30_test_core_api_process_guard_log_mode.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;
set define off;

declare
  v_Pass     number := 0;
  v_Fail     number := 0;
  c_Uid      constant number := 142;
  c_Unmapped_Process constant varchar2(100) := 'ZZZ_GUARD_TEST_UNMAPPED_ZZZ';
  c_Wrong_Door_Process constant varchar2(100) := 'CREATE_USER'; -- SM_R_PROCESSES seed: process_type='POST'
  v_Result   clob;
  v_Token    varchar2(200);
  v_Ttl      number;
  v_Log_Id_Baseline number;
  v_Cnt      number;
  v_Outcome  varchar2(20);
  v_Would_Block varchar2(1);
  v_Enforce_Action varchar2(20);
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
  Dbms_Output.Put_Line('=== Core_Api process guard: LOG-rejimi hech narsani bloklamaydi (user_id=' || c_Uid || ') ===');

  select Nvl(max(log_id), 0) into v_Log_Id_Baseline from Core_Process_Access_Log;

  --==== UAPP kontekst ================================================
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

  --==== 1. Get_Model_Clob - avvalgidek muvaffaqiyatli o'tishi kerak =====
  v_Result := Core.Core_Api.Get_Model_Clob('{"process_code":"MODEL_USER","user_id":' || c_Uid || '}');
  Assert('Get_Model_Clob (MODEL_USER) hali ham muvaffaqiyatli natija qaytaradi', v_Result is not null);

  begin
    select outcome, would_block, enforce_action
      into v_Outcome, v_Would_Block, v_Enforce_Action
      from Core_Process_Access_Log
     where log_id > v_Log_Id_Baseline
       and door = 'GET_MODEL'
       and process_code = 'MODEL_USER'
       and rownum = 1;
    Assert('CORE_PROCESS_ACCESS_LOG: GET_MODEL/MODEL_USER uchun qator yozilgan', true);
    Assert('CORE_PROCESS_ACCESS_LOG: outcome to''ldirilgan (NULL emas)', v_Outcome is not null);
    Assert('CORE_PROCESS_ACCESS_LOG: would_block to''ldirilgan (Y yoki N)', v_Would_Block in ('Y', 'N'));
    Assert('CORE_PROCESS_ACCESS_LOG: enforce_action = ALLOW (LOG rejimida hech narsa bloklanmaydi)',
           v_Enforce_Action = 'ALLOW');
  exception
    when No_Data_Found then
      Assert('CORE_PROCESS_ACCESS_LOG: GET_MODEL/MODEL_USER uchun qator yozilgan', false);
  end;

  --==== 2. Execute_Process_Clob - mutlaqo bog'lanmagan process_code =====
  -- Sm_Kernel orqali istisno chiqarishi mumkin (kutilgan/ahamiyatsiz) - guard'ning o'zi
  -- Sm_Kernel'ga yetib borishdan OLDIN ishlaydi, shu sabab log yozuvi baribir yaratiladi.
  begin
    Core.Core_Api.Execute_Process_Clob('{"process_code":"' || c_Unmapped_Process || '","user_id":' || c_Uid || '}');
  exception
    when others then
      null; -- bu test uchun ahamiyatsiz - faqat guard yozgan log qatori tekshiriladi
  end;

  begin
    select outcome, would_block, enforce_action
      into v_Outcome, v_Would_Block, v_Enforce_Action
      from Core_Process_Access_Log
     where log_id > v_Log_Id_Baseline
       and door = 'EXECUTE_PROCESS'
       and process_code = c_Unmapped_Process
       and rownum = 1;
    Assert('CORE_PROCESS_ACCESS_LOG: EXECUTE_PROCESS/unmapped uchun qator yozilgan', true);
    Assert('CORE_PROCESS_ACCESS_LOG: outcome = UNMAPPED', v_Outcome = 'UNMAPPED');
    Assert('CORE_PROCESS_ACCESS_LOG: would_block = N (unmapped hech qachon would-block emas)',
           v_Would_Block = 'N');
    Assert('CORE_PROCESS_ACCESS_LOG: enforce_action = ALLOW (LOG rejimida hech narsa bloklanmaydi)',
           v_Enforce_Action = 'ALLOW');
  exception
    when No_Data_Found then
      Assert('CORE_PROCESS_ACCESS_LOG: EXECUTE_PROCESS/unmapped uchun qator yozilgan', false);
  end;

  --==== 3. Get_Model_Clob - haqiqiy POST/OPERATION process_code (cross-door escalation) =
  -- CREATE_USER GET-model process emas - Sm_Kernel orqali istisno chiqarishi kutilgan va
  -- shu test uchun ahamiyatsiz - guard'ning o'zi Sm_Kernel'ga yetib borishdan OLDIN ishlaydi.
  begin
    v_Result := Core.Core_Api.Get_Model_Clob('{"process_code":"' || c_Wrong_Door_Process || '","user_id":' || c_Uid || '}');
  exception
    when others then
      null; -- bu test uchun ahamiyatsiz - faqat guard yozgan log qatori tekshiriladi
  end;

  begin
    select outcome, would_block, enforce_action
      into v_Outcome, v_Would_Block, v_Enforce_Action
      from Core_Process_Access_Log
     where log_id > v_Log_Id_Baseline
       and door = 'GET_MODEL'
       and process_code = c_Wrong_Door_Process
       and rownum = 1;
    Assert('CORE_PROCESS_ACCESS_LOG: GET_MODEL/' || c_Wrong_Door_Process || ' uchun qator yozilgan', true);
    Assert('CORE_PROCESS_ACCESS_LOG: outcome = WRONG_DOOR_TYPE', v_Outcome = 'WRONG_DOOR_TYPE');
    -- SEMANTIK O'ZGARISH (ataylab, shu session ishi doirasida): avval would_block='N' edi
    -- (LOG-bosqichning boshlang'ich versiyasida WRONG_DOOR_TYPE hech qachon bloklanmasdi);
    -- endi Check_Process_Access buni ENFORCE_DOOR/ENFORCE rejimlarida haqiqatan bloklanadigan
    -- holat deb hisoblaydi, shu sabab would_block='Y'. Bu HALI blok qilmaydi (pastdagi
    -- enforce_action=ALLOW tekshiruviga qarang) - c_Process_Guard_Mode='LOG' bo'lgani uchun.
    Assert('CORE_PROCESS_ACCESS_LOG: would_block = Y (WRONG_DOOR_TYPE endi would-block hisoblanadi)',
           v_Would_Block = 'Y');
    Assert('CORE_PROCESS_ACCESS_LOG: enforce_action = ALLOW (LOG rejimida hech narsa bloklanmaydi)',
           v_Enforce_Action = 'ALLOW');
  exception
    when No_Data_Found then
      Assert('CORE_PROCESS_ACCESS_LOG: GET_MODEL/' || c_Wrong_Door_Process || ' uchun qator yozilgan', false);
  end;

  --==== teardown ======================================================
  -- Create_Session haqiqiy, faol sessiya qatori (bearer token) yaratadi - Clear_Context
  -- faqat joriy DB sessiyaning in-memory UAPP kontekstini tozalaydi, AUTH_SESSIONS'dagi
  -- tokenni BEKOR QILMAYDI. Shu sabab avval Auth_Session.Close bilan token haqiqatan
  -- yopiladi (State='CLOSED'), so'ng Clear_Context bilan kontekst tozalanadi.
  if v_Token is not null then
    Core.Auth_Session.Close(v_Token, 'TEST_TEARDOWN');
  end if;
  Core.Auth_Session.Clear_Context;
  delete from Core_Process_Access_Log
   where log_id > v_Log_Id_Baseline
     and user_id = c_Uid
     and process_code in ('MODEL_USER', c_Unmapped_Process, c_Wrong_Door_Process);
  commit;

  Dbms_Output.Put_Line('--- Test CORE_API_PROCESS_GUARD_LOG_MODE: PASS=' || v_Pass || ' FAIL=' || v_Fail);
exception
  when others then
    if v_Token is not null then
      Core.Auth_Session.Close(v_Token, 'TEST_TEARDOWN');
    end if;
    Core.Auth_Session.Clear_Context;
    delete from Core_Process_Access_Log
     where log_id > v_Log_Id_Baseline
       and user_id = c_Uid
       and process_code in ('MODEL_USER', c_Unmapped_Process, c_Wrong_Door_Process);
    commit;
    raise;
end;
/
set define on;
