# Core_Api process-code guard — ENFORCE rejimiga o'tish runbooki

**2026-08-04 holati: 172.20.6.157:1521/new_abs'da `c_Process_Guard_Mode` allaqachon `ENFORCE`
(doimiy, "vaqtincha flip" emas)** - quyidagi qadamlar endi asosan boshqa (yangi) muhitni birinchi
marta ENFORCE'ga o'tkazish uchun qo'llanma sifatida saqlanadi. Avtomatlashtirilgan tasdiqlash uchun
`31_test_core_api_process_guard_enforce.sql`'ni ishga tushiring (fixture: `auth/create_test_user.sql`,
ixtiyoriy `auth/create_debug_user.sql` - lekin bu fayl `Core_Rel_User_Menus`'ga yozadi, u
`rename_old_user_rel_tables.sql` bilan `_BAK_20260729`'ga o'tkazilgan - ishga tushirishdan oldin
`ADM_REL_USER_MENUS`'ga moslab tuzating).

`Core_Const.c_Process_Guard_Mode` COMPILE-TIME konstanta (qarang: `core/package/Core_Const.pck`)
— ataylab yozma sozlamalar-jadvali emas, deploy-huquqi nazorat nuqtasi sifatida. Shu sabab
rejimni test-skriptdan avtomatlashtirib bo'lmaydi; bu qo'lda, bir martalik tekshiruv uchun ANIQ
qadamlar.

**DIQQAT**: bu QO'LDA operatsiya — jonli/populyatsiyalangan sxemada bajarishdan oldin
lead/reviewer tasdig'i SHART (`Core_Const.pck` qayta kompilyatsiya qilinadi — bu paketga
tayanadigan BARCHA kod uchun ta'sir qiladi, garchi bu o'zgarish faqat bitta konstanta qiymatini
almashtirsa ham).

## 0) MAJBURIY UCHINCHI GATE

ENFORCE_DOOR/ENFORCE'ga o'tishdan OLDIN mavjud `Core_Users.Debug='Y'` qatorlar audit qilingan
bo'lishi SHART (avvalgi `Save_User` versiyasi mijoz yuborgan `'debug'` kalitini qabul qilgan
edi — tuzatilgan, lekin mavjud ma'lumotlarda iz qolgan bo'lishi mumkin). Faqat `-100`
(DEBUG_USER) kutiladi; boshqa qator chiqsa — ENFORCE'ga O'TMANG, avval tekshiring/investigatsiya
qiling.

`CORE_USERS` jadvalida "login" ustuni YO'Q — login `CORE_USER_KEYS.PROVIDER_KEY`
(`PROVIDER_TYPE='LOCAL'`)'dan olinadi:

```sql
select u.user_id, k.provider_key as login, u.state
  from Core_Users u
  left join Core_User_Keys k
    on k.user_id = u.user_id and k.provider_type = 'LOCAL'
 where Nvl(u.Debug,'N') = 'Y';
-- kutilgan: FAQAT -100 (DEBUG_USER). Boshqa qator bo'lsa - ENFORCE'ga O'TMANG.
```

## 1) Joriy qiymatni yodda tuting

`core/package/Core_Const.pck` faylidagi qatorni yodda tuting (keyin qaytarish uchun):

```
c_Process_Guard_Mode constant varchar2(15) := c_Guard_Mode_Log;
```

## 2) Vaqtincha almashtiring va qayta kompilyatsiya qiling

```
c_Process_Guard_Mode constant varchar2(15) := c_Guard_Mode_Enforce_Door;  -- yoki c_Guard_Mode_Enforce
```

```bash
sqlplus core/*** @core/package/Core_Const.pck
sqlplus core/*** @core/package/Core_Api.pck
```

(`Core_Api.pck` `Core_Const.c_Process_Guard_Mode`'ni faqat qiymat sifatida o'qiydi, o'zi
o'zgarmagan — lekin dependency invalidation uchun ham baribir avval `Core_Const`, keyin
`Core_Api` qayta kompilyatsiya qilinadi.)

## 3) BLOKLANISHI kerak bo'lgan chaqiruvni tekshiring

Debug bo'lmagan foydalanuvchi (`test_user`, `user_id=900002`), `WRONG_DOOR_TYPE` holati —
ENFORCE_DOOR VA ENFORCE ikkalasida ham bloklanishi kerak:

```sql
declare
  v_Token varchar2(200); v_Ttl number; v_Result clob;
begin
  Core.Auth_Session.Create_Session(
    i_User_Id => 900002, i_Provider => 'LOCAL', i_Cb_Code => '00440', i_Local_Code => '01000',
    i_Lang => 'UZ', i_Client_Ip => '127.0.0.1', i_User_Agent => 'manual-verify',
    o_Token => v_Token, o_Ttl_Sec => v_Ttl);
  begin
    v_Result := Core.Core_Api.Get_Model_Clob('{"process_code":"CREATE_USER","user_id":900002}');
    Dbms_Output.Put_Line('KUTILMAGAN: ORA-20003 chiqmadi!');
  exception
    when others then
      if sqlcode = -20003 then
        Dbms_Output.Put_Line('OK: ORA-20003 chiqdi (' || sqlerrm || ') - bloklandi.');
      else
        Dbms_Output.Put_Line('KUTILMAGAN XATO: ' || sqlerrm);
      end if;
  end;
  Core.Auth_Session.Close(v_Token, 'MANUAL_VERIFY');
  Core.Auth_Session.Clear_Context;
end;
/
```

Natija: `ORA-20003` chiqishi va `CORE_PROCESS_ACCESS_LOG`'da shu `log_id` uchun
`enforce_action='BLOCK'` bo'lishi SHART.

## 4) DEBUG bypass'ni tekshiring

Xuddi 3-qadamdagi bilan bir xil chaqiruv, lekin DEBUG_USER (-100) nomidan —
`Auth_Session.Open_Debug_Session` ishlatilishi kerak (DEBUG_USER LOCAL login bilan kira
olmaydi, sqlplus'dan to'g'ridan-to'g'ri). DEBUG_USER allaqachon `Debug='Y'` bilan yaratiladi
(`auth/create_debug_user.sql`), shu sabab qo'shimcha DBA qadami odatda kerak EMAS.

Agar buning o'rniga boshqa, allaqachon faol test-foydalanuvchi (masalan `test_user`,
`user_id=900002`) ustida tekshirmoqchi bo'lsangiz — DIQQAT: `Core_Kernel.Save_User` endi
`'debug'` kalitini mijozdan QABUL QILMAYDI (xavfsizlik tuzatishi); Debug bayrog'ini faqat DBA
to'g'ridan-to'g'ri SQL orqali, qo'lda o'rnatishi mumkin:

```sql
-- Debug-bypass foydalanuvchisini QO'LDA yoqish (faqat DBA, Save_User orqali EMAS):
update Core_Users set Debug = 'Y' where user_id = 900002; -- test_user
commit;
-- ... tekshiruvdan keyin MAJBURIY qaytarish:
update Core_Users set Debug = 'N' where user_id = 900002;
commit;

declare
  v_Result clob;
begin
  Core.Auth_Session.Open_Debug_Session(i_Branch_Code => '01000', i_Reason => 'ENFORCE guard manual verify');
  begin
    v_Result := Core.Core_Api.Get_Model_Clob('{"process_code":"CREATE_USER","user_id":-100}');
    Dbms_Output.Put_Line('OK: ORA-20003 chiqmadi - DEBUG bypass ishladi (WARN_BYPASS).');
  exception
    when others then
      if sqlcode = -20003 then
        Dbms_Output.Put_Line('KUTILMAGAN: ORA-20003 chiqdi - DEBUG bypass ishlamadi!');
      else
        Dbms_Output.Put_Line('Boshqa xato (ahamiyatsiz bo''lishi mumkin): ' || sqlerrm);
      end if;
  end;
  Core.Auth_Session.Clear_Context;
end;
/
```

Natija: `ORA-20003` chiqMASLIGI va `CORE_PROCESS_ACCESS_LOG`'da shu `log_id` uchun
`enforce_action='WARN_BYPASS'` bo'lishi, sqlplus konsolida `"CORE_API GUARD WARNING: ..."`
DBMS_OUTPUT qatori ko'rinishi SHART.

## 5) Log'larni tekshiring

Yuqoridagi ikkala tekshiruv (3 va 4) kutilgandek o'tgach — `CORE_PROCESS_ACCESS_LOG`'da o'sha
ikkala `log_id`ni tekshirib chiqing (`outcome`/`would_block`/`enforce_action` ustunlari), so'ng
bu test uchun yaratilgan qatorlarni tozalang (agar kerak bo'lsa).

## 6) Agar bu FAQAT VAQTINCHALIK tekshiruv bo'lsa - Core_Const.pck'ni ASLIGA QAYTARING

Bu qadam FAQAT 1-bandda yodda tutgan qiymatingiz `LOG` bo'lsa kerak (ya'ni siz LOG'dan ENFORCE'ga
birinchi marta, faqat shu tekshiruv uchun vaqtincha o'tgan bo'lsangiz). Agar ENFORCE allaqachon
doimiy deploy holati bo'lsa (172.20.6.157:1521/new_abs'da 2026-08-04'dan shunday) - bu qadamni
BAJARMANG, aks holda haqiqiy production himoyasini o'chirib qo'yasiz.

```
c_Process_Guard_Mode constant varchar2(15) := c_Guard_Mode_Log;
```

```bash
sqlplus core/*** @core/package/Core_Const.pck
sqlplus core/*** @core/package/Core_Api.pck
```

Tekshiruv — quyidagi so'rov HECH QANDAY qator qaytarmasligi SHART:

```sql
select object_name, status from user_objects where status = 'INVALID';
```

Va `30_test_core_api_process_guard_log_mode.sql`ni ishga tushirib, barcha PASS ekanini tasdiqlang
(rejim yana LOG'ga qaytganini isbotlash uchun - `31_test_...`ENDI ENFORCE-ga xos bashoratlarni
tekshiradi, LOG rejimida u OGOHLANTIRISH bilan FAIL beradi, bu KUTILGAN, tuzatilishi shart bo'lgan
xato emas).
