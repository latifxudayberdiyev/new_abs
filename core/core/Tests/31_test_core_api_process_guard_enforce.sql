----------------------------------------------------------------------------------------------------
--  Core_Api process-code guard - ENFORCE-rejimi testi.
--
--  MUHIM CHEKLOV (nega bu test faqat joriy, kompilyatsiya qilingan rejimni tekshiradi):
--  Core_Const.c_Process_Guard_Mode COMPILE-TIME konstanta (Core_Const.pck'ga qarang - bu ATAYLAB,
--  yozma sozlamalar-jadvali emas, deploy-huquqi nazorat nuqtasi sifatida). Shu sabab bu test
--  skriptidan turib rejimni almashtirib sinab ko'rish MUMKIN EMAS - buning uchun paketni qayta
--  kompilyatsiya qilish kerak bo'lardi (ENFORCE_MODE_MANUAL_RUNBOOK.md'ga qarang). Xuddi shu
--  sababdan Check_Process_Access/Is_Debug_User PRIVATE (paket tanasida) - tashqaridan to'g'ridan-
--  to'g'ri chaqirib bo'lmaydi, faqat Get_Model_Clob orqali bilvosita ishga tushiriladi.
--
--  LOG-rejimi bilan javobgarlik chegarasi: 30_test_core_api_process_guard_log_mode.sql LOG
--  rejimini (hech narsa hech qachon bloklanmasligini) tekshiradi. Bu fayl ENDI faqat ENFORCE
--  rejimiga xos xatti-harakatni tekshiradi:
--   1) WRONG_DOOR_TYPE va MAPPED_DENIED (would_block='Y' beruvchi ikkala outcome) haqiqatan
--      BLOKLANISHI (ORA-20003, enforce_action='BLOCK') SHART - debug bo'lmagan foydalanuvchi bilan.
--   2) Xuddi shu MAPPED_DENIED holati DEBUG_USER (-100, Core_Users.Debug='Y') nomidan chaqirilsa
--      BLOKLANMASLIGI (enforce_action='WARN_BYPASS', ORA-20003 YO'Q) SHART - bu ENFORCE rejimida
--      ENDI HAQIQATAN sinab bo'ladi (LOG rejimida v_Mode_Blocks doim false, WARN_BYPASS'ga
--      hech qachon yetib bo'lmas edi - shu sabab avvalgi versiyada faqat BILVOSITA/read-only
--      precondition tekshiruvi bor edi). DEBUG_USER LOCAL login bilan kira olmaydi - shu sabab
--      Auth_Session.Create_Session emas, Auth_Session.Open_Debug_Session ishlatiladi (u
--      user_id'ni sukut bo'yicha -100'ga o'rnatadi, parametr sifatida qabul qilinmaydi).
--   3) Is_Debug_User uchun BILVOSITA (indirect) READ-ONLY precondition tekshiruvi ham saqlanadi
--      (2-band DEBUG_USER qatori mavjud bo'lmasa o'tkazib yuborilganda ham ishlaydigan, arzon
--      fallback - fixture holatini tasdiqlaydi, funksiyaning o'zini emas).
--
--  Fixture'lar (live-DB bog'liqligi, test 30'dagi kabi qabul qilingan naqsh):
--   - test_user (user_id=900002, auth/create_test_user.sql) - FAQAT Dashboard menyusiga (menu_id=2)
--     ruxsatli, ADM_REL_USER_BUTTONS'da HECH QANDAY button-granti YO'Q. Shu sabab bu foydalanuvchi
--     nomidan CHAQIRILGAN har qanday mapped process_code MAPPED_DENIED beradi (grant yo'qligi
--     sababli) - "simulated MAPPED_DENIED" fixture sifatida ishlatiladi (haqiqiy fixture-jadval
--     yozuvi yaratilmaydi, mavjud, atayin cheklangan test-foydalanuvchi qayta ishlatiladi).
--   - MODEL_USER process_code - GET_MODEL eshigida mapped bo'lishi uchun bu test o'ZI sentinel
--     CORE_R_MENU_BUTTONS qatorini yaratadi (menu_id/button_id=999999903, test 10/20'dagi kabi
--     naqsh) - real katalog holatiga (production'da mapped bo'lishi mumkin, lekin test bazasida
--     kafolatlanmagan) tayanilmaydi.
--   - CREATE_USER process_code - test 30'dagi kabi (SM_R_PROCESSES seed: process_type='POST') -
--     GET_MODEL eshigiga yuborilganda WRONG_DOOR_TYPE beradi.
--   - DEBUG_USER (user_id=-100, auth/create_debug_user.sql) - Debug='Y', State='A',
--     Is_Access_Denied='N' deb faraz qilinadi (create_debug_user.sql shu qiymatlar bilan yaratadi).
--     2-band (WARN_BYPASS behavioral test) FAQAT bu qator CORE_USERS'da haqiqatan mavjud bo'lsa
--     ishga tushadi - aks holda aniq SKIP xabari bilan o'tkazib yuboriladi (FAIL emas, chunki
--     fixture yaratish alohida, ixtiyoriy setup qadami - auth/create_debug_user.sql).
--
--  Faqat Get_Model_Clob (GET_MODEL eshigi, o'qish) ishlatiladi, Execute_Process_Clob EMAS - yozish
--  (OPERATION/POST processlarni) chaqirish real yon-ta'sir xavfini keltirib chiqarardi.
--
--  Tozalash: test 30'dagi bilan bir xil naqsh - testdan OLDINGI max(log_id) chegara sifatida
--  olinadi, faqat shu chegaradan katta va shu testga tegishli process_code'lar bo'yicha qatorlar
--  o'chiriladi. Bu test HECH QANDAY grant/CORE_R_MENU_BUTTONS/CORE_CONST o'zgartirmaydi - schema
--  ishga tushishdan oldingi holatda qoladi (log-jadval qatorlaridan tashqari, ular ham teardown'da
--  tozalanadi).
--
--  Ishga tushirish: sqlplus core/*** @core/Tests/31_test_core_api_process_guard_enforce.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited;
set define off;

declare
  v_Pass     number := 0;
  v_Fail     number := 0;
  c_Uid                 constant number := 900002; -- test_user, auth/create_test_user.sql
  c_Wrong_Door_Process  constant varchar2(100) := 'CREATE_USER';  -- SM_R_PROCESSES seed: process_type='POST'
  c_Mapped_Denied_Process constant varchar2(100) := 'MODEL_USER'; -- mapped, lekin test_user'da granti yo'q
  c_Debug_Uid           constant number := -100; -- DEBUG_USER, auth/create_debug_user.sql
  v_Result   clob;
  v_Token    varchar2(200);
  v_Ttl      number;
  v_Log_Id_Baseline number;
  v_Cnt      number;
  v_Outcome  varchar2(20);
  v_Would_Block varchar2(1);
  v_Enforce_Action varchar2(20);
  v_Ora_20003_Seen boolean;
  v_Debug_User_Exists boolean;
  -- @@_assert.sql SHART RAVISHDA barcha o'zgaruvchi/konstanta e'lonlaridan KEYIN, begin'dan
  -- OLDIN turishi kerak - PL/SQL declare bo'limida bir marta protsedura/funksiya e'lon
  -- qilingach, undan keyin YANA o'zgaruvchi e'lon qilib bo'lmaydi (PLS-00103).
  @@_assert.sql
begin
  Dbms_Output.Put_Line('=== Core_Api process guard: ENFORCE-rejimi tekshiruvi (joriy rejim, user_id=' || c_Uid || ') ===');

  -- Bu test faqat 'ENFORCE' rejimida ma'noga ega bashoratlarni tasdiqlaydi (WRONG_DOOR_TYPE va
  -- MAPPED_DENIED haqiqatan bloklanadi) - agar kimdir bu faylni LOG yoki ENFORCE_DOOR bilan
  -- kompilyatsiya qilingan paket ustida ishga tushirsa, quyidagi tekshiruv buni ANIQ ko'rsatadi
  -- (aks holda pastdagi assertlar FAIL bo'ladi, lekin sabab noaniq bo'lib qolishi mumkin edi).
  -- ENFORCE_DOOR uchun eslatma: u FAQAT WRONG_DOOR_TYPE/GUARD_ERROR'ni bloklaydi, MAPPED_DENIED'ni
  -- EMAS - shu sabab ENFORCE_DOOR bilan bu test qisman FAIL beradi (2-band), bu KUTILGAN, LOG bilan
  -- bo'lgani kabi xato emas.
  if Core.Core_Const.c_Process_Guard_Mode != Core.Core_Const.c_Guard_Mode_Enforce then
    Dbms_Output.Put_Line('  OGOHLANTIRISH: Core_Const.c_Process_Guard_Mode = ''' ||
                          Core.Core_Const.c_Process_Guard_Mode ||
                          ''' (ENFORCE emas) - bu test faqat ENFORCE rejimi uchun mo''ljallangan, natijalar mos kelmasligi mumkin.');
  end if;

  select Nvl(max(log_id), 0) into v_Log_Id_Baseline from Core_Process_Access_Log;

  -- MAPPED_DENIED-shaped stsenariysi CORE_R_MENU_BUTTONS'da MODEL_USER uchun haqiqatan
  -- mapped qator borligiga bog'liq - bu boshqa muhitda (masalan production) rost bo'lishi
  -- mumkin, lekin test bazasida bunga tayanib bo'lmaydi (test 10/20'dagi kabi sentinel
  -- qator o'zi yaratiladi, real katalog holatiga tayanilmaydi). Sentinel menu_id/button_id -
  -- boshqa hech qanday testda ishlatilmaydigan, aniq ajratilgan qiymatlar.
  delete from Core_R_Menu_Buttons where menu_id = 999999903 and button_id = 999999903;
  insert into Core_R_Menu_Buttons
    (module_code, menu_id, button_id, action_code, name_mll_code, order_by, state,
     model_process_code, created_by, created_on, modify_by, modify_on)
  values
    ('TEST', 999999903, 999999903, 'GUARD_TEST_MODEL_DENIED', 'GUARD_TEST_MODEL_DENIED', 1, 'A',
     c_Mapped_Denied_Process, -1, sysdate, -1, sysdate);

  --==== UAPP kontekst: test_user (grantsiz) =============================
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

  ----------------------------------------------------------------------------------------------------
  -- 1) WRONG_DOOR_TYPE: ENFORCE rejimida would_block='Y' bo'lgani uchun haqiqatan BLOKLANISHI
  --    (ORA-20003) va enforce_action='BLOCK' bo'lishi SHART.
  ----------------------------------------------------------------------------------------------------
  v_Ora_20003_Seen := false;
  begin
    v_Result := Core.Core_Api.Get_Model_Clob('{"process_code":"' || c_Wrong_Door_Process || '","user_id":' || c_Uid || '}');
  exception
    when others then
      if sqlcode = -20003 then
        v_Ora_20003_Seen := true;
      end if;
      null; -- Sm_Kernel tomonidan chiqarilishi mumkin bo'lgan boshqa xatolar (ORA-20000 va h.k.)
            -- bu test uchun ahamiyatsiz - faqat ORA-20003 (guard blok) va guard-log qatori tekshiriladi.
  end;
  Assert(v_Pass, v_Fail, 'WRONG_DOOR_TYPE: ORA-20003 (guard block) chiqdi (ENFORCE bloklashi shart)',
         v_Ora_20003_Seen);

  begin
    select outcome, would_block, enforce_action
      into v_Outcome, v_Would_Block, v_Enforce_Action
      from Core_Process_Access_Log
     where log_id > v_Log_Id_Baseline
       and door = 'GET_MODEL'
       and process_code = c_Wrong_Door_Process
       and rownum = 1;
    Assert(v_Pass, v_Fail, 'WRONG_DOOR_TYPE: log qatori yozilgan', true);
    Assert(v_Pass, v_Fail, 'WRONG_DOOR_TYPE: outcome = WRONG_DOOR_TYPE', v_Outcome = 'WRONG_DOOR_TYPE');
    Assert(v_Pass, v_Fail, 'WRONG_DOOR_TYPE: would_block = Y', v_Would_Block = 'Y');
    Assert(v_Pass, v_Fail, 'WRONG_DOOR_TYPE: enforce_action = BLOCK', v_Enforce_Action = 'BLOCK');
  exception
    when No_Data_Found then
      Assert(v_Pass, v_Fail, 'WRONG_DOOR_TYPE: log qatori yozilgan', false);
  end;

  ----------------------------------------------------------------------------------------------------
  -- 2) MAPPED_DENIED (simulated): test_user'da MODEL_USER uchun grant yo'q - ENFORCE rejimida
  --    would_block='Y' bo'lgani uchun haqiqatan BLOKLANISHI (ORA-20003) SHART.
  ----------------------------------------------------------------------------------------------------
  v_Ora_20003_Seen := false;
  begin
    v_Result := Core.Core_Api.Get_Model_Clob('{"process_code":"' || c_Mapped_Denied_Process || '","user_id":' || c_Uid || '}');
  exception
    when others then
      if sqlcode = -20003 then
        v_Ora_20003_Seen := true;
      end if;
      null; -- Sm_Kernel/model-qatlamidagi boshqa xatolar bu test uchun ahamiyatsiz.
  end;
  Assert(v_Pass, v_Fail, 'MAPPED_DENIED: ORA-20003 (guard block) chiqdi (ENFORCE bloklashi shart)',
         v_Ora_20003_Seen);

  begin
    select outcome, would_block, enforce_action
      into v_Outcome, v_Would_Block, v_Enforce_Action
      from Core_Process_Access_Log
     where log_id > v_Log_Id_Baseline
       and door = 'GET_MODEL'
       and process_code = c_Mapped_Denied_Process
       and user_id = c_Uid
       and rownum = 1;
    Assert(v_Pass, v_Fail, 'MAPPED_DENIED: log qatori yozilgan', true);
    Assert(v_Pass, v_Fail, 'MAPPED_DENIED: outcome = MAPPED_DENIED (test_user''da grant yo''q deb faraz qilinadi)',
           v_Outcome = 'MAPPED_DENIED');
    Assert(v_Pass, v_Fail, 'MAPPED_DENIED: would_block = Y', v_Would_Block = 'Y');
    Assert(v_Pass, v_Fail, 'MAPPED_DENIED: enforce_action = BLOCK', v_Enforce_Action = 'BLOCK');
  exception
    when No_Data_Found then
      Assert(v_Pass, v_Fail, 'MAPPED_DENIED: log qatori yozilgan', false);
  end;

  if v_Token is not null then
    Core.Auth_Session.Close(v_Token, 'TEST_TEARDOWN');
    v_Token := null;
  end if;
  Core.Auth_Session.Clear_Context;

  ----------------------------------------------------------------------------------------------------
  -- 3) WARN_BYPASS - BEHAVIORAL: xuddi shu MAPPED_DENIED holati, lekin DEBUG_USER (-100) nomidan.
  --    ENDI (ENFORCE rejimida) haqiqatan sinab bo'ladi - LOG rejimida v_Mode_Blocks doim false
  --    bo'lgani uchun WARN_BYPASS shoxobchasiga hech qachon yetib bo'lmas edi. DEBUG_USER LOCAL
  --    login bilan kira olmaydi - Auth_Session.Open_Debug_Session ishlatiladi (user_id'ni sukut
  --    bo'yicha -100'ga o'rnatadi, Auth_Session.pck'dagi c_Debug_User_Id konstantasi - parametr
  --    sifatida qabul qilinmaydi, shu sabab JSON payload'da "user_id" yo'q: baribir e'tiborga
  --    olinmas edi, Core.User_Env.Get_User_Id doim kontekstdan o'qiydi). FAQAT DEBUG_USER qatori
  --    CORE_USERS'da haqiqatan mavjud bo'lsa ishga tushadi - Is_Debug_User fail-closed (qator
  --    topilmasa FALSE), shu sabab fixture yo'qligida bu blok jimgina emas, ANIQ SKIP xabari
  --    bilan o'tkazib yuboriladi.
  ----------------------------------------------------------------------------------------------------
  begin
    select count(*) into v_Cnt from Core_Users where user_id = c_Debug_Uid;
    v_Debug_User_Exists := (v_Cnt = 1);
  exception
    when others then
      v_Debug_User_Exists := false;
  end;

  if not v_Debug_User_Exists then
    Dbms_Output.Put_Line('  SKIP  WARN_BYPASS behavioral test - DEBUG_USER(-100) CORE_USERS''da yo''q ' ||
                          '(auth/create_debug_user.sql ishga tushirilmagan, bu muhitga xos setup, FAIL emas).');
  else
    Core.Auth_Session.Open_Debug_Session(i_Branch_Code => '01000', i_Reason => 'test 31 ENFORCE verify');

    v_Ora_20003_Seen := false;
    begin
      v_Result := Core.Core_Api.Get_Model_Clob('{"process_code":"' || c_Mapped_Denied_Process || '"}');
    exception
      when others then
        if sqlcode = -20003 then
          v_Ora_20003_Seen := true;
        end if;
        null; -- Sm_Kernel/model-qatlamidagi boshqa xatolar bu test uchun ahamiyatsiz.
    end;
    Assert(v_Pass, v_Fail, 'WARN_BYPASS: ORA-20003 chiqmadi (DEBUG_USER bloklanmasligi shart)',
           not v_Ora_20003_Seen);

    begin
      select outcome, would_block, enforce_action
        into v_Outcome, v_Would_Block, v_Enforce_Action
        from Core_Process_Access_Log
       where log_id > v_Log_Id_Baseline
         and door = 'GET_MODEL'
         and process_code = c_Mapped_Denied_Process
         and user_id = c_Debug_Uid
         and rownum = 1;
      Assert(v_Pass, v_Fail, 'WARN_BYPASS: log qatori yozilgan', true);
      Assert(v_Pass, v_Fail, 'WARN_BYPASS: outcome = MAPPED_DENIED (DEBUG_USER'' da ham grant yo''q)',
             v_Outcome = 'MAPPED_DENIED');
      Assert(v_Pass, v_Fail, 'WARN_BYPASS: would_block = Y (bloklanishi kerak EDI)', v_Would_Block = 'Y');
      Assert(v_Pass, v_Fail, 'WARN_BYPASS: enforce_action = WARN_BYPASS (lekin DEBUG tufayli o''tkazildi)',
             v_Enforce_Action = 'WARN_BYPASS');
    exception
      when No_Data_Found then
        Assert(v_Pass, v_Fail, 'WARN_BYPASS: log qatori yozilgan', false);
    end;

    Core.Auth_Session.Clear_Context;
  end if;

  ----------------------------------------------------------------------------------------------------
  -- 4) Is_Debug_User - BILVOSITA (indirect) arzon READ-ONLY fallback tekshiruvi (funksiya private,
  --    to'g'ridan-to'g'ri chaqirib bo'lmaydi). 3-band DEBUG_USER mavjud bo'lganda uni BEHAVIORAL
  --    ravishda allaqachon sinab ko'radi - bu band shunchaki fixture ma'lumot-holatini alohida
  --    hujjatlaydi/tasdiqlaydi. DEBUG_USER umuman mavjud bo'lmasa (v_Debug_User_Exists=false,
  --    3-band hisoblagan) - bu band ham xuddi 3-band kabi SKIP qiladi, FAIL emas (aks holda
  --    bitta yo'q fixture ikkita alohida FAIL sifatida ko'rinib, chalkashtirib yuborardi).
  ----------------------------------------------------------------------------------------------------
  if not v_Debug_User_Exists then
    Dbms_Output.Put_Line('  SKIP  Is_Debug_User precondition - DEBUG_USER(-100) CORE_USERS''da yo''q (3-band bilan bir xil sabab).');
  else
    begin
      select count(*)
        into v_Cnt
        from Core_Users u
       where u.User_Id          = c_Debug_Uid
         and u.State            = Core.Core_Const.c_State_Active
         and u.Is_Access_Denied = 'N'
         and u.Debug            = 'Y'
         and Trunc(sysdate) between u.Activate_Date and u.Deactivate_Date;
      Assert(v_Pass, v_Fail, 'Is_Debug_User precondition: DEBUG_USER(-100) faol/Debug=Y (Is_Debug_User TRUE qaytarishi uchun zarur holat)',
             v_Cnt = 1);
    exception
      when others then
        Assert(v_Pass, v_Fail, 'Is_Debug_User precondition: DEBUG_USER(-100) faol/Debug=Y (Is_Debug_User TRUE qaytarishi uchun zarur holat)', false);
    end;
  end if;

  --==== teardown ======================================================
  if v_Token is not null then
    Core.Auth_Session.Close(v_Token, 'TEST_TEARDOWN');
  end if;
  Core.Auth_Session.Clear_Context;
  delete from Core_Process_Access_Log
   where log_id > v_Log_Id_Baseline
     and user_id in (c_Uid, c_Debug_Uid)
     and process_code in (c_Wrong_Door_Process, c_Mapped_Denied_Process);
  delete from Core_R_Menu_Buttons where menu_id = 999999903 and button_id = 999999903;
  commit;

  Dbms_Output.Put_Line('--- Test CORE_API_PROCESS_GUARD_ENFORCE: PASS=' || v_Pass || ' FAIL=' || v_Fail);
exception
  when others then
    if v_Token is not null then
      Core.Auth_Session.Close(v_Token, 'TEST_TEARDOWN');
    end if;
    Core.Auth_Session.Clear_Context;
    delete from Core_Process_Access_Log
     where log_id > v_Log_Id_Baseline
       and user_id in (c_Uid, c_Debug_Uid)
       and process_code in (c_Wrong_Door_Process, c_Mapped_Denied_Process);
    delete from Core_R_Menu_Buttons where menu_id = 999999903 and button_id = 999999903;
    commit;
    raise;
end;
/
set define on;

----------------------------------------------------------------------------------------------------
-- QO'LDA TEKSHIRISH BO'LIMI - ENFORCE_DOOR/ENFORCE rejimiga o'tishning to'liq, bosqichma-bosqich
-- runbooki bu yerdan ko'chirildi: core/Tests/ENFORCE_MODE_MANUAL_RUNBOOK.md (2026-08-04: joriy
-- deploy holati - runbook endi "vaqtincha flip, keyin LOG'ga qaytaring" emas, ENFORCE doimiy
-- kompilyatsiya qilingan holat - runbook'ning boshiga qarang).
----------------------------------------------------------------------------------------------------
