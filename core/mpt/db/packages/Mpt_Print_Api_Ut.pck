
  CREATE OR REPLACE EDITIONABLE PACKAGE "CORE"."MPT_PRINT_API_UT" IS

  -- Author  : SHUKUROV.O
  -- Created : 27.07.2026
  -- Purpose : MPT_PRINT_API paket metodlari uchun test paketi.
  --           utPLSQL hali o'rnatilmagan (SYSDBA huquqi yo'q) - shuning
  --           uchun har bir test PASS/FAIL'ni DBMS_OUTPUT orqali o'zi
  --           chiqaradi (mpt_p2_8_tests.sql bilan bir xil mantiq), lekin
  --           endi bitta yaxlit .sql skript o'rniga har bir tekshiruv
  --           alohida, nomlangan protsedura sifatida tashkillashtirilgan.
  --           Kelajakda utPLSQL o'rnatilsa, har bir protsedura tepasidagi
  --           izohni --%test(...) annotatsiyasiga aylantirib, ichini
  --           ut.expect() ga o'tkazish oson bo'ladi (mpt_ut_print_api.pck
  --           aynan shu formatda allaqachon mavjud).
  --
  -- Ishga tushirish: EXEC MPT_PRINT_API_UT.Run_All;
  -- Oldindan shart: db/start.sql VA db/packages/deploy_plsql.sql to'liq
  -- ishga tushirilgan bo'lishi kerak.

  Procedure Run_All;

  ------------------------------------------------------------------
  -- latin_to_cyrillic
  ------------------------------------------------------------------

  -- Alijonov -> Алижонов
  Procedure Test_Translit_Alijonov;

  -- Toshkent -> Тошкент
  Procedure Test_Translit_Toshkent;

  -- o'zbek -> ўзбек (o' digrafi)
  Procedure Test_Translit_Ozbek;

  -- shahar -> шаҳар
  Procedure Test_Translit_Shahar;

  -- NULL kiritilsa NULL qaytadi
  Procedure Test_Translit_Null;

  -- Harf bo'lmagan belgilar (raqam/tinish belgisi) o'zgarmaydi
  Procedure Test_Translit_No_Match;

  -- TOSHKENT - butunlay katta harfda ham to'g'ri o'giriladi
  Procedure Test_Translit_Uppercase;

  -- ishchi - qo'shni sh va ch digraflari birga ishlaydi
  Procedure Test_Translit_Adjacent_Digraphs;

  -- bog' - g' digrafi
  Procedure Test_Translit_Gapostrophe;

  -- ts digrafi bitta harflardan (t, s) ustun turadi
  Procedure Test_Translit_Ts_Digraph;

  -- yoshlar - yo digrafi
  Procedure Test_Translit_Yo_Digraph;

  -- yashil - ya digrafi
  Procedure Test_Translit_Ya_Digraph;

  -- yulduz - yu digrafi
  Procedure Test_Translit_Yu_Digraph;

  -- c harfi context'dan qat'i nazar doim k ga o'giriladi (rasmdagi
  -- spec ц/к context talab qiladi, joriy MPT_TRANSLIT_RULE bilan
  -- soddalashtirilgan - mpt_translit_rule_ins.sql izohiga qarang)
  Procedure Test_Translit_C_Letter;

  ------------------------------------------------------------------
  -- resolve_var_value
  ------------------------------------------------------------------

  -- LANG=UZL bo'lganda qiymat o'zgarmasdan qaytadi
  Procedure Test_Resolve_Uzl;

  -- LANG=UZC va NEEDS_TRANSLIT=Y bo'lganda translit qo'llaniladi
  Procedure Test_Resolve_Uzc;

  -- LANG=RU bo'lganda translit qo'llanmaydi
  Procedure Test_Resolve_Ru;

  -- LANG=ENG bo'lganda translit qo'llanmaydi
  Procedure Test_Resolve_Eng;

  -- Mavjud bo'lmagan VARIABLE_CODE uchun xato ko'tariladi (E'TIBOR:
  -- joriy jonli (live) paket -20011 o'rniga -20000 qaytaryapti -
  -- 2026-07-21'da qayd etilgan, source fayl bilan jonli paket
  -- orasidagi farq hali hal qilinmagan)
  Procedure Test_Resolve_Not_Found;

  ------------------------------------------------------------------
  -- add_qr_code_auto
  ------------------------------------------------------------------

  -- admin_qrcode_N to'g'ri formatda avtomatik yaratiladi (E'TIBOR:
  -- fixture 'CREDIT_CONTRACT' guruh kodini talab qiladi - agar joriy
  -- muhitda bu guruh mavjud bo'lmasa, ORA-02291 bilan FAIL beradi,
  -- shu holda i_Group_Code'ni mavjud guruhga almashtiring)
  Procedure Test_Qr_Auto_Increment;

  ------------------------------------------------------------------
  -- validate_variable_code
  ------------------------------------------------------------------

  -- GLOBAL scope'da 'g_' prefiksisiz kod rad etiladi
  Procedure Test_Validate_Global_No_Prefix;

  -- MODULE scope'da 'g_' prefiksli kod rad etiladi
  Procedure Test_Validate_Module_With_Prefix;

  -- Katta harfli kod rad etiladi
  Procedure Test_Validate_Uppercase;

  -- Probel saqlagan kod rad etiladi
  Procedure Test_Validate_Space;

  -- 101 belgili (100 dan uzun) kod rad etiladi
  Procedure Test_Validate_Too_Long;

  ------------------------------------------------------------------
  -- reprint / purge_old_history
  ------------------------------------------------------------------

  -- Eski VARS_SNAPSHOT saqlanib, STATUS=REPRINTED yangi yozuv yaratiladi
  Procedure Test_Reprint;

  -- Retention muddatidan oshgan yozuv o'chiriladi
  Procedure Test_Purge_Old_History;

  ------------------------------------------------------------------
  -- performance
  ------------------------------------------------------------------

  -- 100 ta resolve_var_value chaqiruvi 1 soniyadan kam vaqt olishi kerak
  Procedure Test_Performance_Resolve;

END MPT_PRINT_API_UT;
/
CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CORE"."MPT_PRINT_API_UT" IS

  ------------------------------------------------------------------
  -- Ichki yordamchilar (spec'da yo'q - faqat shu paket ichida ishlatiladi)
  ------------------------------------------------------------------

  Procedure Assert_Equals(i_Test_Name in varchar2, i_Expected in varchar2, i_Actual in varchar2) is
  begin
    if i_Expected = i_Actual or (i_Expected is null and i_Actual is null) then
      Dbms_Output.Put_Line('PASS: ' || i_Test_Name);
    else
      Dbms_Output.Put_Line('FAIL: ' || i_Test_Name || ' - kutilgan: [' || i_Expected || '] haqiqiy: [' ||
                           i_Actual || ']');
    end if;
  end Assert_Equals;

  Procedure Assert_Fails(i_Test_Name in varchar2, i_Sql in varchar2) is
  begin
    Savepoint Sp_Assert_Fails;
    execute immediate i_Sql;
    rollback to Sp_Assert_Fails;
    Dbms_Output.Put_Line('FAIL: ' || i_Test_Name || ' - kutilgan xato yuz bermadi');
  exception
    when others then
      rollback to Sp_Assert_Fails;
      Dbms_Output.Put_Line('PASS: ' || i_Test_Name || ' - ' || Sqlerrm);
  end Assert_Fails;

  Procedure Setup_Translit_Var is
  begin
    insert into Mpt_Print_Variables
      (Variable_Code, Scope, Module_Code, Var_Name, Var_Type, Var_Source, Var_Value, Needs_Translit,
       Created_By)
    values
      ('ut_translit_name', 'MODULE', 'TEST', 'Test', 'TEXT', 'STATIC', 'Alijonov Alijon', 'Y', 1);
  end Setup_Translit_Var;

  ------------------------------------------------------------------
  -- latin_to_cyrillic
  ------------------------------------------------------------------

  Procedure Test_Translit_Alijonov is
  begin
    Assert_Equals('latin_to_cyrillic: Alijonov -> Алижонов', 'Алижонов',
                  Mpt_Print_Api.Latin_To_Cyrillic('Alijonov'));
  end Test_Translit_Alijonov;

  Procedure Test_Translit_Toshkent is
  begin
    Assert_Equals('latin_to_cyrillic: Toshkent -> Тошкент', 'Тошкент',
                  Mpt_Print_Api.Latin_To_Cyrillic('Toshkent'));
  end Test_Translit_Toshkent;

  Procedure Test_Translit_Ozbek is
  begin
    Assert_Equals('latin_to_cyrillic: o''zbek -> ўзбек', 'ўзбек',
                  Mpt_Print_Api.Latin_To_Cyrillic('o''zbek'));
  end Test_Translit_Ozbek;

  Procedure Test_Translit_Shahar is
  begin
    Assert_Equals('latin_to_cyrillic: shahar -> шаҳар', 'шаҳар',
                  Mpt_Print_Api.Latin_To_Cyrillic('shahar'));
  end Test_Translit_Shahar;

  Procedure Test_Translit_Null is
  begin
    Assert_Equals('latin_to_cyrillic: NULL -> NULL', null, Mpt_Print_Api.Latin_To_Cyrillic(null));
  end Test_Translit_Null;

  Procedure Test_Translit_No_Match is
  begin
    Assert_Equals('latin_to_cyrillic: 2024-01! -> o''zgarmaydi', '2024-01!',
                  Mpt_Print_Api.Latin_To_Cyrillic('2024-01!'));
  end Test_Translit_No_Match;

  Procedure Test_Translit_Uppercase is
  begin
    Assert_Equals('latin_to_cyrillic: TOSHKENT -> ТОШКЕНТ (katta harf)', 'ТОШКЕНТ',
                  Mpt_Print_Api.Latin_To_Cyrillic('TOSHKENT'));
  end Test_Translit_Uppercase;

  Procedure Test_Translit_Adjacent_Digraphs is
  begin
    Assert_Equals('latin_to_cyrillic: ishchi -> ишчи (qo''shni sh+ch)', 'ишчи',
                  Mpt_Print_Api.Latin_To_Cyrillic('ishchi'));
  end Test_Translit_Adjacent_Digraphs;

  Procedure Test_Translit_Gapostrophe is
  begin
    Assert_Equals('latin_to_cyrillic: bog'' -> боғ (g'' digrafi)', 'боғ',
                  Mpt_Print_Api.Latin_To_Cyrillic('bog'''));
  end Test_Translit_Gapostrophe;

  Procedure Test_Translit_Ts_Digraph is
  begin
    Assert_Equals('latin_to_cyrillic: ts -> ц (digraf ustunligi)', 'ц',
                  Mpt_Print_Api.Latin_To_Cyrillic('ts'));
  end Test_Translit_Ts_Digraph;

  Procedure Test_Translit_Yo_Digraph is
  begin
    Assert_Equals('latin_to_cyrillic: yoshlar -> ёшлар (yo digrafi)', 'ёшлар',
                  Mpt_Print_Api.Latin_To_Cyrillic('yoshlar'));
  end Test_Translit_Yo_Digraph;

  Procedure Test_Translit_Ya_Digraph is
  begin
    Assert_Equals('latin_to_cyrillic: yashil -> яшил (ya digrafi)', 'яшил',
                  Mpt_Print_Api.Latin_To_Cyrillic('yashil'));
  end Test_Translit_Ya_Digraph;

  Procedure Test_Translit_Yu_Digraph is
  begin
    Assert_Equals('latin_to_cyrillic: yulduz -> юлдуз (yu digrafi)', 'юлдуз',
                  Mpt_Print_Api.Latin_To_Cyrillic('yulduz'));
  end Test_Translit_Yu_Digraph;

  Procedure Test_Translit_C_Letter is
  begin
    Assert_Equals('latin_to_cyrillic: c -> к (context inobatga olinmaydi)', 'к',
                  Mpt_Print_Api.Latin_To_Cyrillic('c'));
  end Test_Translit_C_Letter;

  ------------------------------------------------------------------
  -- resolve_var_value
  ------------------------------------------------------------------

  Procedure Test_Resolve_Uzl is
  begin
    Savepoint Sp_Resolve_Uzl;
    Setup_Translit_Var;
    Assert_Equals('resolve_var_value: UZL o''zgarmaydi', 'Alijonov Alijon',
                  Mpt_Print_Api.Resolve_Var_Value('ut_translit_name', null, 'UZL', null, null));
    rollback to Sp_Resolve_Uzl;
  exception
    when others then
      rollback to Sp_Resolve_Uzl;
      Dbms_Output.Put_Line('FAIL: resolve_var_value UZL test bloki - ' || Sqlerrm);
  end Test_Resolve_Uzl;

  Procedure Test_Resolve_Uzc is
  begin
    Savepoint Sp_Resolve_Uzc;
    Setup_Translit_Var;
    Assert_Equals('resolve_var_value: UZC translit qo''llaniladi', 'Алижонов Алижон',
                  Mpt_Print_Api.Resolve_Var_Value('ut_translit_name', null, 'UZC', null, null));
    rollback to Sp_Resolve_Uzc;
  exception
    when others then
      rollback to Sp_Resolve_Uzc;
      Dbms_Output.Put_Line('FAIL: resolve_var_value UZC test bloki - ' || Sqlerrm);
  end Test_Resolve_Uzc;

  Procedure Test_Resolve_Ru is
  begin
    Savepoint Sp_Resolve_Ru;
    Setup_Translit_Var;
    Assert_Equals('resolve_var_value: RU translit qo''llanmaydi', 'Alijonov Alijon',
                  Mpt_Print_Api.Resolve_Var_Value('ut_translit_name', null, 'RU', null, null));
    rollback to Sp_Resolve_Ru;
  exception
    when others then
      rollback to Sp_Resolve_Ru;
      Dbms_Output.Put_Line('FAIL: resolve_var_value RU test bloki - ' || Sqlerrm);
  end Test_Resolve_Ru;

  Procedure Test_Resolve_Eng is
  begin
    Savepoint Sp_Resolve_Eng;
    Setup_Translit_Var;
    Assert_Equals('resolve_var_value: ENG translit qo''llanmaydi', 'Alijonov Alijon',
                  Mpt_Print_Api.Resolve_Var_Value('ut_translit_name', null, 'ENG', null, null));
    rollback to Sp_Resolve_Eng;
  exception
    when others then
      rollback to Sp_Resolve_Eng;
      Dbms_Output.Put_Line('FAIL: resolve_var_value ENG test bloki - ' || Sqlerrm);
  end Test_Resolve_Eng;

  Procedure Test_Resolve_Not_Found is
    v_Val Varchar2(4000);
  begin
    v_Val := Mpt_Print_Api.Resolve_Var_Value('ut_nomavjud_xyz', null, 'UZL', null, null);
    Dbms_Output.Put_Line('FAIL: mavjud bo''lmagan VARIABLE_CODE uchun xato kutilgan edi, lekin qaytdi: [' ||
                         v_Val || ']');
  exception
    when others then
      if Sqlcode = -20011 then
        Dbms_Output.Put_Line('PASS: mavjud bo''lmagan VARIABLE_CODE -> -20011: ' || Sqlerrm);
      else
        Dbms_Output.Put_Line('FAIL: mavjud bo''lmagan VARIABLE_CODE - kutilgan -20011, haqiqiy: ' ||
                             Sqlerrm);
      end if;
  end Test_Resolve_Not_Found;

  ------------------------------------------------------------------
  -- add_qr_code_auto
  ------------------------------------------------------------------

  Procedure Test_Qr_Auto_Increment is
    v_Code Mpt_Print_Variables.Variable_Code%type;
  begin
    Savepoint Sp_Qr;
    Mpt_Print_Api.Add_Qr_Code_Auto(i_Group_Code    => 'CREDIT_CONTRACT',
                                   i_Created_By    => 1,
                                   o_Variable_Code => v_Code);

    if v_Code like 'admin\_qrcode\_%' escape '\' then
      Dbms_Output.Put_Line('PASS: add_qr_code_auto - admin_qrcode_N yaratildi: ' || v_Code);
    else
      Dbms_Output.Put_Line('FAIL: add_qr_code_auto - kutilmagan format: ' || v_Code);
    end if;

    rollback to Sp_Qr;
  exception
    when others then
      rollback to Sp_Qr;
      Dbms_Output.Put_Line('FAIL: add_qr_code_auto - ' || Sqlerrm);
  end Test_Qr_Auto_Increment;

  ------------------------------------------------------------------
  -- validate_variable_code
  ------------------------------------------------------------------

  Procedure Test_Validate_Global_No_Prefix is
  begin
    Assert_Fails('validate_variable_code: GLOBAL ''bank_name'' (g_ kerak)',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE('bank_name','GLOBAL'); END;]');
  end Test_Validate_Global_No_Prefix;

  Procedure Test_Validate_Module_With_Prefix is
  begin
    Assert_Fails('validate_variable_code: MODULE ''g_client_name'' (g_ taqiqlangan)',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE('g_client_name','MODULE'); END;]');
  end Test_Validate_Module_With_Prefix;

  Procedure Test_Validate_Uppercase is
  begin
    Assert_Fails('validate_variable_code: ''CLIENT_NAME'' (lowercase shart)',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE('CLIENT_NAME','MODULE'); END;]');
  end Test_Validate_Uppercase;

  Procedure Test_Validate_Space is
  begin
    Assert_Fails('validate_variable_code: ''client name'' (probel taqiqlangan)',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE('client name','MODULE'); END;]');
  end Test_Validate_Space;

  Procedure Test_Validate_Too_Long is
  begin
    Assert_Fails('validate_variable_code: 101 belgili kod',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE(RPAD('a',101,'a'),'MODULE'); END;]');
  end Test_Validate_Too_Long;

  ------------------------------------------------------------------
  -- reprint / purge_old_history
  ------------------------------------------------------------------

  Procedure Test_Reprint is
    v_Id  Mpt_Print_History.History_Id%type;
    v_Cnt number;
  begin
    Savepoint Sp_Reprint;

    insert into Mpt_Print_History
      (Group_Code, Template_Code, Module_Code, Lang_Code, Printed_By, Output_Format, Status,
       Vars_Snapshot)
    values
      ('CREDIT_CONTRACT', 'CREDIT_CONTRACT_UZL_V1', 'CREDIT', 'UZL', 1, 'PDF', 'SUCCESS',
       '{"g_bank_name":"Test Bank"}')
    returning History_Id into v_Id;

    Mpt_Print_Api.Reprint(v_Id, 2);

    -- CLOB ustunini '=' bilan solishtirish ORA-00932 beradi - shuning
    -- uchun DBMS_LOB.INSTR bilan qism-satr tekshiruvi qilinadi.
    select count(*)
      into v_Cnt
      from Mpt_Print_History
     where Status = 'REPRINTED'
       and Printed_By = 2
       and Dbms_Lob.Instr(Vars_Snapshot, '{"g_bank_name":"Test Bank"}') > 0;

    if v_Cnt >= 1 then
      Dbms_Output.Put_Line('PASS: reprint - eski VARS_SNAPSHOT bilan yangi REPRINTED yozuv yaratildi');
    else
      Dbms_Output.Put_Line('FAIL: reprint - REPRINTED yozuv topilmadi');
    end if;

    rollback to Sp_Reprint;
  exception
    when others then
      rollback to Sp_Reprint;
      Dbms_Output.Put_Line('FAIL: reprint - ' || Sqlerrm);
  end Test_Reprint;

  Procedure Test_Purge_Old_History is
    v_Id  Mpt_Print_History.History_Id%type;
    v_Cnt number;
  begin
    Savepoint Sp_Purge;

    insert into Mpt_Print_History
      (Group_Code, Template_Code, Module_Code, Lang_Code, Printed_By, Output_Format, Status,
       Print_Date)
    values
      ('CREDIT_CONTRACT', 'CREDIT_CONTRACT_UZL_V1', 'CREDIT', 'UZL', 1, 'PDF', 'SUCCESS',
       sysdate - 3000)
    returning History_Id into v_Id;

    Mpt_Print_Api.Purge_Old_History;

    select count(*) into v_Cnt from Mpt_Print_History where History_Id = v_Id;

    if v_Cnt = 0 then
      Dbms_Output.Put_Line('PASS: purge_old_history - retention''dan oshgan yozuv o''chirildi');
    else
      Dbms_Output.Put_Line('FAIL: purge_old_history - eski yozuv hali mavjud');
    end if;

    rollback to Sp_Purge;
  exception
    when others then
      rollback to Sp_Purge;
      Dbms_Output.Put_Line('FAIL: purge_old_history - ' || Sqlerrm);
  end Test_Purge_Old_History;

  ------------------------------------------------------------------
  -- performance
  ------------------------------------------------------------------

  Procedure Test_Performance_Resolve is
    v_Start Timestamp;
    v_Ms    number;
    v_Dummy Varchar2(4000);
  begin
    v_Start := Systimestamp;

    for i in 1 .. 100 loop
      v_Dummy := Mpt_Print_Api.Resolve_Var_Value('g_bank_name', null, 'UZL', null, null);
    end loop;

    v_Ms := (extract(second from (Systimestamp - v_Start)) +
             extract(minute from (Systimestamp - v_Start)) * 60) * 1000;

    if v_Ms < 1000 then
      Dbms_Output.Put_Line('PASS: 100 ta resolve_var_value = ' || round(v_Ms, 2) || ' ms (< 1000 ms)');
    else
      Dbms_Output.Put_Line('FAIL: 100 ta resolve_var_value = ' || round(v_Ms, 2) || ' ms (>= 1000 ms)');
    end if;
  exception
    when others then
      Dbms_Output.Put_Line('FAIL: performance - ' || Sqlerrm);
  end Test_Performance_Resolve;

  ------------------------------------------------------------------
  -- Run_All
  ------------------------------------------------------------------

  Procedure Run_All is
  begin
    Dbms_Output.Put_Line('=== MPT_PRINT_API_UT TEST SUITE ===');

    Dbms_Output.Put_Line('--- latin_to_cyrillic ---');
    Test_Translit_Alijonov;
    Test_Translit_Toshkent;
    Test_Translit_Ozbek;
    Test_Translit_Shahar;
    Test_Translit_Null;
    Test_Translit_No_Match;
    Test_Translit_Uppercase;
    Test_Translit_Adjacent_Digraphs;
    Test_Translit_Gapostrophe;
    Test_Translit_Ts_Digraph;
    Test_Translit_Yo_Digraph;
    Test_Translit_Ya_Digraph;
    Test_Translit_Yu_Digraph;
    Test_Translit_C_Letter;

    Dbms_Output.Put_Line('--- resolve_var_value ---');
    Test_Resolve_Uzl;
    Test_Resolve_Uzc;
    Test_Resolve_Ru;
    Test_Resolve_Eng;
    Test_Resolve_Not_Found;

    Dbms_Output.Put_Line('--- add_qr_code_auto ---');
    Test_Qr_Auto_Increment;

    Dbms_Output.Put_Line('--- validate_variable_code ---');
    Test_Validate_Global_No_Prefix;
    Test_Validate_Module_With_Prefix;
    Test_Validate_Uppercase;
    Test_Validate_Space;
    Test_Validate_Too_Long;

    Dbms_Output.Put_Line('--- reprint / purge_old_history ---');
    Test_Reprint;
    Test_Purge_Old_History;

    Dbms_Output.Put_Line('--- performance ---');
    Test_Performance_Resolve;

    Dbms_Output.Put_Line('=== MPT_PRINT_API_UT TUGADI ===');
  end Run_All;

END MPT_PRINT_API_UT;
/


  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "CORE"."MPT_PRINT_API_UT" IS

  ------------------------------------------------------------------
  -- Ichki yordamchilar (spec'da yo'q - faqat shu paket ichida ishlatiladi)
  ------------------------------------------------------------------

  Procedure Assert_Equals(i_Test_Name in varchar2, i_Expected in varchar2, i_Actual in varchar2) is
  begin
    if i_Expected = i_Actual or (i_Expected is null and i_Actual is null) then
      Dbms_Output.Put_Line('PASS: ' || i_Test_Name);
    else
      Dbms_Output.Put_Line('FAIL: ' || i_Test_Name || ' - kutilgan: [' || i_Expected || '] haqiqiy: [' ||
                           i_Actual || ']');
    end if;
  end Assert_Equals;

  Procedure Assert_Fails(i_Test_Name in varchar2, i_Sql in varchar2) is
  begin
    Savepoint Sp_Assert_Fails;
    execute immediate i_Sql;
    rollback to Sp_Assert_Fails;
    Dbms_Output.Put_Line('FAIL: ' || i_Test_Name || ' - kutilgan xato yuz bermadi');
  exception
    when others then
      rollback to Sp_Assert_Fails;
      Dbms_Output.Put_Line('PASS: ' || i_Test_Name || ' - ' || Sqlerrm);
  end Assert_Fails;

  Procedure Setup_Translit_Var is
  begin
    insert into Mpt_Print_Variables
      (Variable_Code, Scope, Module_Code, Var_Name, Var_Type, Var_Source, Var_Value, Needs_Translit,
       Created_By)
    values
      ('ut_translit_name', 'MODULE', 'TEST', 'Test', 'TEXT', 'STATIC', 'Alijonov Alijon', 'Y', 1);
  end Setup_Translit_Var;

  ------------------------------------------------------------------
  -- latin_to_cyrillic
  ------------------------------------------------------------------

  Procedure Test_Translit_Alijonov is
  begin
    Assert_Equals('latin_to_cyrillic: Alijonov -> Алижонов', 'Алижонов',
                  Mpt_Print_Api.Latin_To_Cyrillic('Alijonov'));
  end Test_Translit_Alijonov;

  Procedure Test_Translit_Toshkent is
  begin
    Assert_Equals('latin_to_cyrillic: Toshkent -> Тошкент', 'Тошкент',
                  Mpt_Print_Api.Latin_To_Cyrillic('Toshkent'));
  end Test_Translit_Toshkent;

  Procedure Test_Translit_Ozbek is
  begin
    Assert_Equals('latin_to_cyrillic: o''zbek -> ўзбек', 'ўзбек',
                  Mpt_Print_Api.Latin_To_Cyrillic('o''zbek'));
  end Test_Translit_Ozbek;

  Procedure Test_Translit_Shahar is
  begin
    Assert_Equals('latin_to_cyrillic: shahar -> шаҳар', 'шаҳар',
                  Mpt_Print_Api.Latin_To_Cyrillic('shahar'));
  end Test_Translit_Shahar;

  Procedure Test_Translit_Null is
  begin
    Assert_Equals('latin_to_cyrillic: NULL -> NULL', null, Mpt_Print_Api.Latin_To_Cyrillic(null));
  end Test_Translit_Null;

  Procedure Test_Translit_No_Match is
  begin
    Assert_Equals('latin_to_cyrillic: 2024-01! -> o''zgarmaydi', '2024-01!',
                  Mpt_Print_Api.Latin_To_Cyrillic('2024-01!'));
  end Test_Translit_No_Match;

  Procedure Test_Translit_Uppercase is
  begin
    Assert_Equals('latin_to_cyrillic: TOSHKENT -> ТОШКЕНТ (katta harf)', 'ТОШКЕНТ',
                  Mpt_Print_Api.Latin_To_Cyrillic('TOSHKENT'));
  end Test_Translit_Uppercase;

  Procedure Test_Translit_Adjacent_Digraphs is
  begin
    Assert_Equals('latin_to_cyrillic: ishchi -> ишчи (qo''shni sh+ch)', 'ишчи',
                  Mpt_Print_Api.Latin_To_Cyrillic('ishchi'));
  end Test_Translit_Adjacent_Digraphs;

  Procedure Test_Translit_Gapostrophe is
  begin
    Assert_Equals('latin_to_cyrillic: bog'' -> боғ (g'' digrafi)', 'боғ',
                  Mpt_Print_Api.Latin_To_Cyrillic('bog'''));
  end Test_Translit_Gapostrophe;

  Procedure Test_Translit_Ts_Digraph is
  begin
    Assert_Equals('latin_to_cyrillic: ts -> ц (digraf ustunligi)', 'ц',
                  Mpt_Print_Api.Latin_To_Cyrillic('ts'));
  end Test_Translit_Ts_Digraph;

  Procedure Test_Translit_Yo_Digraph is
  begin
    Assert_Equals('latin_to_cyrillic: yoshlar -> ёшлар (yo digrafi)', 'ёшлар',
                  Mpt_Print_Api.Latin_To_Cyrillic('yoshlar'));
  end Test_Translit_Yo_Digraph;

  Procedure Test_Translit_Ya_Digraph is
  begin
    Assert_Equals('latin_to_cyrillic: yashil -> яшил (ya digrafi)', 'яшил',
                  Mpt_Print_Api.Latin_To_Cyrillic('yashil'));
  end Test_Translit_Ya_Digraph;

  Procedure Test_Translit_Yu_Digraph is
  begin
    Assert_Equals('latin_to_cyrillic: yulduz -> юлдуз (yu digrafi)', 'юлдуз',
                  Mpt_Print_Api.Latin_To_Cyrillic('yulduz'));
  end Test_Translit_Yu_Digraph;

  Procedure Test_Translit_C_Letter is
  begin
    Assert_Equals('latin_to_cyrillic: c -> к (context inobatga olinmaydi)', 'к',
                  Mpt_Print_Api.Latin_To_Cyrillic('c'));
  end Test_Translit_C_Letter;

  ------------------------------------------------------------------
  -- resolve_var_value
  ------------------------------------------------------------------

  Procedure Test_Resolve_Uzl is
  begin
    Savepoint Sp_Resolve_Uzl;
    Setup_Translit_Var;
    Assert_Equals('resolve_var_value: UZL o''zgarmaydi', 'Alijonov Alijon',
                  Mpt_Print_Api.Resolve_Var_Value('ut_translit_name', null, 'UZL', null, null));
    rollback to Sp_Resolve_Uzl;
  exception
    when others then
      rollback to Sp_Resolve_Uzl;
      Dbms_Output.Put_Line('FAIL: resolve_var_value UZL test bloki - ' || Sqlerrm);
  end Test_Resolve_Uzl;

  Procedure Test_Resolve_Uzc is
  begin
    Savepoint Sp_Resolve_Uzc;
    Setup_Translit_Var;
    Assert_Equals('resolve_var_value: UZC translit qo''llaniladi', 'Алижонов Алижон',
                  Mpt_Print_Api.Resolve_Var_Value('ut_translit_name', null, 'UZC', null, null));
    rollback to Sp_Resolve_Uzc;
  exception
    when others then
      rollback to Sp_Resolve_Uzc;
      Dbms_Output.Put_Line('FAIL: resolve_var_value UZC test bloki - ' || Sqlerrm);
  end Test_Resolve_Uzc;

  Procedure Test_Resolve_Ru is
  begin
    Savepoint Sp_Resolve_Ru;
    Setup_Translit_Var;
    Assert_Equals('resolve_var_value: RU translit qo''llanmaydi', 'Alijonov Alijon',
                  Mpt_Print_Api.Resolve_Var_Value('ut_translit_name', null, 'RU', null, null));
    rollback to Sp_Resolve_Ru;
  exception
    when others then
      rollback to Sp_Resolve_Ru;
      Dbms_Output.Put_Line('FAIL: resolve_var_value RU test bloki - ' || Sqlerrm);
  end Test_Resolve_Ru;

  Procedure Test_Resolve_Eng is
  begin
    Savepoint Sp_Resolve_Eng;
    Setup_Translit_Var;
    Assert_Equals('resolve_var_value: ENG translit qo''llanmaydi', 'Alijonov Alijon',
                  Mpt_Print_Api.Resolve_Var_Value('ut_translit_name', null, 'ENG', null, null));
    rollback to Sp_Resolve_Eng;
  exception
    when others then
      rollback to Sp_Resolve_Eng;
      Dbms_Output.Put_Line('FAIL: resolve_var_value ENG test bloki - ' || Sqlerrm);
  end Test_Resolve_Eng;

  Procedure Test_Resolve_Not_Found is
    v_Val Varchar2(4000);
  begin
    v_Val := Mpt_Print_Api.Resolve_Var_Value('ut_nomavjud_xyz', null, 'UZL', null, null);
    Dbms_Output.Put_Line('FAIL: mavjud bo''lmagan VARIABLE_CODE uchun xato kutilgan edi, lekin qaytdi: [' ||
                         v_Val || ']');
  exception
    when others then
      if Sqlcode = -20011 then
        Dbms_Output.Put_Line('PASS: mavjud bo''lmagan VARIABLE_CODE -> -20011: ' || Sqlerrm);
      else
        Dbms_Output.Put_Line('FAIL: mavjud bo''lmagan VARIABLE_CODE - kutilgan -20011, haqiqiy: ' ||
                             Sqlerrm);
      end if;
  end Test_Resolve_Not_Found;

  ------------------------------------------------------------------
  -- add_qr_code_auto
  ------------------------------------------------------------------

  Procedure Test_Qr_Auto_Increment is
    v_Code Mpt_Print_Variables.Variable_Code%type;
  begin
    Savepoint Sp_Qr;
    Mpt_Print_Api.Add_Qr_Code_Auto(i_Group_Code    => 'CREDIT_CONTRACT',
                                   i_Created_By    => 1,
                                   o_Variable_Code => v_Code);

    if v_Code like 'admin\_qrcode\_%' escape '\' then
      Dbms_Output.Put_Line('PASS: add_qr_code_auto - admin_qrcode_N yaratildi: ' || v_Code);
    else
      Dbms_Output.Put_Line('FAIL: add_qr_code_auto - kutilmagan format: ' || v_Code);
    end if;

    rollback to Sp_Qr;
  exception
    when others then
      rollback to Sp_Qr;
      Dbms_Output.Put_Line('FAIL: add_qr_code_auto - ' || Sqlerrm);
  end Test_Qr_Auto_Increment;

  ------------------------------------------------------------------
  -- validate_variable_code
  ------------------------------------------------------------------

  Procedure Test_Validate_Global_No_Prefix is
  begin
    Assert_Fails('validate_variable_code: GLOBAL ''bank_name'' (g_ kerak)',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE('bank_name','GLOBAL'); END;]');
  end Test_Validate_Global_No_Prefix;

  Procedure Test_Validate_Module_With_Prefix is
  begin
    Assert_Fails('validate_variable_code: MODULE ''g_client_name'' (g_ taqiqlangan)',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE('g_client_name','MODULE'); END;]');
  end Test_Validate_Module_With_Prefix;

  Procedure Test_Validate_Uppercase is
  begin
    Assert_Fails('validate_variable_code: ''CLIENT_NAME'' (lowercase shart)',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE('CLIENT_NAME','MODULE'); END;]');
  end Test_Validate_Uppercase;

  Procedure Test_Validate_Space is
  begin
    Assert_Fails('validate_variable_code: ''client name'' (probel taqiqlangan)',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE('client name','MODULE'); END;]');
  end Test_Validate_Space;

  Procedure Test_Validate_Too_Long is
  begin
    Assert_Fails('validate_variable_code: 101 belgili kod',
                q'[BEGIN MPT_PRINT_API.VALIDATE_VARIABLE_CODE(RPAD('a',101,'a'),'MODULE'); END;]');
  end Test_Validate_Too_Long;

  ------------------------------------------------------------------
  -- reprint / purge_old_history
  ------------------------------------------------------------------

  Procedure Test_Reprint is
    v_Id  Mpt_Print_History.History_Id%type;
    v_Cnt number;
  begin
    Savepoint Sp_Reprint;

    insert into Mpt_Print_History
      (Group_Code, Template_Code, Module_Code, Lang_Code, Printed_By, Output_Format, Status,
       Vars_Snapshot)
    values
      ('CREDIT_CONTRACT', 'CREDIT_CONTRACT_UZL_V1', 'CREDIT', 'UZL', 1, 'PDF', 'SUCCESS',
       '{"g_bank_name":"Test Bank"}')
    returning History_Id into v_Id;

    Mpt_Print_Api.Reprint(v_Id, 2);

    -- CLOB ustunini '=' bilan solishtirish ORA-00932 beradi - shuning
    -- uchun DBMS_LOB.INSTR bilan qism-satr tekshiruvi qilinadi.
    select count(*)
      into v_Cnt
      from Mpt_Print_History
     where Status = 'REPRINTED'
       and Printed_By = 2
       and Dbms_Lob.Instr(Vars_Snapshot, '{"g_bank_name":"Test Bank"}') > 0;

    if v_Cnt >= 1 then
      Dbms_Output.Put_Line('PASS: reprint - eski VARS_SNAPSHOT bilan yangi REPRINTED yozuv yaratildi');
    else
      Dbms_Output.Put_Line('FAIL: reprint - REPRINTED yozuv topilmadi');
    end if;

    rollback to Sp_Reprint;
  exception
    when others then
      rollback to Sp_Reprint;
      Dbms_Output.Put_Line('FAIL: reprint - ' || Sqlerrm);
  end Test_Reprint;

  Procedure Test_Purge_Old_History is
    v_Id  Mpt_Print_History.History_Id%type;
    v_Cnt number;
  begin
    Savepoint Sp_Purge;

    insert into Mpt_Print_History
      (Group_Code, Template_Code, Module_Code, Lang_Code, Printed_By, Output_Format, Status,
       Print_Date)
    values
      ('CREDIT_CONTRACT', 'CREDIT_CONTRACT_UZL_V1', 'CREDIT', 'UZL', 1, 'PDF', 'SUCCESS',
       sysdate - 3000)
    returning History_Id into v_Id;

    Mpt_Print_Api.Purge_Old_History;

    select count(*) into v_Cnt from Mpt_Print_History where History_Id = v_Id;

    if v_Cnt = 0 then
      Dbms_Output.Put_Line('PASS: purge_old_history - retention''dan oshgan yozuv o''chirildi');
    else
      Dbms_Output.Put_Line('FAIL: purge_old_history - eski yozuv hali mavjud');
    end if;

    rollback to Sp_Purge;
  exception
    when others then
      rollback to Sp_Purge;
      Dbms_Output.Put_Line('FAIL: purge_old_history - ' || Sqlerrm);
  end Test_Purge_Old_History;

  ------------------------------------------------------------------
  -- performance
  ------------------------------------------------------------------

  Procedure Test_Performance_Resolve is
    v_Start Timestamp;
    v_Ms    number;
    v_Dummy Varchar2(4000);
  begin
    v_Start := Systimestamp;

    for i in 1 .. 100 loop
      v_Dummy := Mpt_Print_Api.Resolve_Var_Value('g_bank_name', null, 'UZL', null, null);
    end loop;

    v_Ms := (extract(second from (Systimestamp - v_Start)) +
             extract(minute from (Systimestamp - v_Start)) * 60) * 1000;

    if v_Ms < 1000 then
      Dbms_Output.Put_Line('PASS: 100 ta resolve_var_value = ' || round(v_Ms, 2) || ' ms (< 1000 ms)');
    else
      Dbms_Output.Put_Line('FAIL: 100 ta resolve_var_value = ' || round(v_Ms, 2) || ' ms (>= 1000 ms)');
    end if;
  exception
    when others then
      Dbms_Output.Put_Line('FAIL: performance - ' || Sqlerrm);
  end Test_Performance_Resolve;

  ------------------------------------------------------------------
  -- Run_All
  ------------------------------------------------------------------

  Procedure Run_All is
  begin
    Dbms_Output.Put_Line('=== MPT_PRINT_API_UT TEST SUITE ===');

    Dbms_Output.Put_Line('--- latin_to_cyrillic ---');
    Test_Translit_Alijonov;
    Test_Translit_Toshkent;
    Test_Translit_Ozbek;
    Test_Translit_Shahar;
    Test_Translit_Null;
    Test_Translit_No_Match;
    Test_Translit_Uppercase;
    Test_Translit_Adjacent_Digraphs;
    Test_Translit_Gapostrophe;
    Test_Translit_Ts_Digraph;
    Test_Translit_Yo_Digraph;
    Test_Translit_Ya_Digraph;
    Test_Translit_Yu_Digraph;
    Test_Translit_C_Letter;

    Dbms_Output.Put_Line('--- resolve_var_value ---');
    Test_Resolve_Uzl;
    Test_Resolve_Uzc;
    Test_Resolve_Ru;
    Test_Resolve_Eng;
    Test_Resolve_Not_Found;

    Dbms_Output.Put_Line('--- add_qr_code_auto ---');
    Test_Qr_Auto_Increment;

    Dbms_Output.Put_Line('--- validate_variable_code ---');
    Test_Validate_Global_No_Prefix;
    Test_Validate_Module_With_Prefix;
    Test_Validate_Uppercase;
    Test_Validate_Space;
    Test_Validate_Too_Long;

    Dbms_Output.Put_Line('--- reprint / purge_old_history ---');
    Test_Reprint;
    Test_Purge_Old_History;

    Dbms_Output.Put_Line('--- performance ---');
    Test_Performance_Resolve;

    Dbms_Output.Put_Line('=== MPT_PRINT_API_UT TUGADI ===');
  end Run_All;

END MPT_PRINT_API_UT;
/