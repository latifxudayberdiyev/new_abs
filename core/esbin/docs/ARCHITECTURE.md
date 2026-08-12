# ESBIN external-auth extension - architecture & handoff

Bu hujjat ESBIN (inbound ESB, asl muallif B.URALOV) subsystemiga shu loyiha
davomida qo'shilgan **bearer-token autentifikatsiya qatlami**ni tasvirlaydi:
Login/Logout, token TTL, IP-allowlist, va HTTP gateway. Maqsad - ESBIN
dasturchilariga to'liq topshirish: bundan buyon bu kodni ular qo'llab-quvvatlaydi.

## 1. Nima uchun qurilgan

Tashqi tizim (partner) bizga o'z end-user'lariga alohida murojaat qilmasdan,
BITTA texnik user nomidan, ruxsat berilgan ichki process'larni chaqirishi
kerak edi. Talablar (loyiha egasi tomonidan berilgan):

- Partnerning ichki mijozlari bizga umuman ko'rinmaydi/qiziq emas - faqat
  process darajasida ishlaymiz.
- Login/parol FAQAT bizning tomonimizda tekshiriladi (tashqi tizimning o'z
  autentifikatsiyasiga bog'liq emasmiz).
- Sessiya/token davomiyligini BIZ belgilaymiz, keyin yopamiz.
- Ulanish o'g'irlab olinishi (token o'g'irlanishi) holatiga qarshi biror
  tekshiruv bo'lishi kerak.

ESBIN'da bu vazifaga juda mos infratuzilma (partner/texnik-user/method-grant
modeli, Core_Api orqali dispatch, o'z audit-logi) allaqachon mavjud edi -
faqat login/token-TTL/IP-himoya qismi yetishmayotgan edi. Shu qism qo'shildi.

## 2. Ma'lumotlar modeli (yangi/o'zgargan qismlar)

Mavjud ESBIN jadvallari (B.URALOV, o'zgarmagan): `ESBIN_R_PARTNERS`,
`ESBIN_R_PARTNER_USERS`, `ESBIN_R_METHODS`, `ESBIN_R_USER_METHOD_REL`,
`ESBIN_REQUESTS`, `ESBIN_REQUEST_DETAILS` (+ ularning `_H` tarix nusxalari).

Shu loyiha davomida qo'shilgan ustunlar:

| Jadval | Yangi ustun | Vazifasi |
|---|---|---|
| `ESBIN_PARTNER_TOKENS` | `ACCESS_TOKEN_HASH` (avvalgi `ACCESS_TOKEN` o'rniga) | Token SHA-256 xeshi - xom token DB'da HECH QACHON saqlanmaydi |
| `ESBIN_PARTNER_TOKENS` | `EXPIRES_ON` | Belgilangan (fixed, sliding EMAS) muddat |
| `ESBIN_PARTNER_TOKENS` | `REVOKED_ON`, `REVOKE_REASON` | Aniq bekor qilish belgisi |
| `ESBIN_R_PARTNERS` | `TOKEN_TTL_MIN` | Partner darajasida TTL override (standart - `Esbin_Const.c_Token_Ttl_Min` = 480 daqiqa / 8 soat, maksimal 1440) |
| `ESBIN_R_PARTNER_USERS` | `IP_ALLOWLIST` | Majburiy (NOT NULL), vergul bilan ajratilgan IPv4/CIDR ro'yxati |

`ESBIN_R_PARTNER_USERS` ustiga yana bitta cheklov qo'shildi: bitta texnik
user bir vaqtning o'zida faqat BITTA aktiv partnerga tegishli bo'lishi
mumkin (`ESBIN_R_PARTNER_USERS_U1`, funksional unique indeks
`CASE WHEN STATE='A' THEN USER_ID END` bo'yicha).

`ESBIN_PARTNER_TOKENS`ning PK'si `USER_ID` - ya'ni **bitta texnik user =
bitta aktiv token**. Qayta login qilinsa, eskisi avtomatik almashadi. Bu
ataylab shunday: "sessiya davomiyligini biz belgilaymiz" talabining eng
sodda ifodasi.

## 3. PL/SQL paketlar

```
Esbin_Const   - doimiylar (holat kodlari, lockout namespace, standart TTL)
Esbin_Util    - qidiruv/tekshiruv funksiyalari (Get_Token_User, Ip_Allowed, ...)
Esbin_Dml     - DML (Set_Partner_Token, Revoke_Partner_Token, tarix yozish, ...)
Esbin_Kernel  - biznes-mantiq: Login, Logout, Revoke_Token, Execute_Request,
                Run_Async_Queue (+ B.URALOVning asl Model/Save/Attach_User_Methods)
Esbin_Sm_Api  - SM_R_PROCESSES uchun yupqa wrapper (admin ekranlar uchun,
                Core_Api dispatch orqali chaqiriladi)
Esbin_Gateway - YANGI, YAGONA UAPP'ga grant qilinadigan paket
```

**Nega `Esbin_Gateway` alohida?** `Esbin_Kernel`ning o'zi UAPP'ga
GRANT QILINMAYDI. Sababi: u `Save_User_Methods`/`Attach_User_Methods`ni ham
tashiydi, ular o'z ichida hech qanday avtorizatsiya tekshirmaydi (chaqiruvchi
`Core_Api`ning process-guard'idan o'tgan deb ishonadi). Agar `Esbin_Kernel`
to'g'ridan-to'g'ri UAPP'ga grant qilinsa, istalgan UAPP-tarafi JSP ixtiyoriy
ESBIN method-dostupini biriktirib qo'yishi mumkin bo'lardi (avtorizatsiyani
chetlab o'tish). `Esbin_Gateway` faqat o'z-o'zini avtorizatsiya qiladigan
(token/parol tekshiruvi o'z ichida) uchta metodni ochadi: `Login`, `Logout`,
`Execute_Request`.

Grant/sinonim: `esbin/grants/grant_uapp.sql` - UAPP'ga faqat
`CORE.ESBIN_GATEWAY` va (kerakli) `CORE.HASH_T` turi grant qilingan.
`Esbin_Kernel`/`Dml`/`Util`/`Const`/`Sm_Api` UAPP'ga grant QILINMAGAN.

## 4. So'rov oqimlari

### 4.1 Login

```
Java (EsbinGatewayServlet.doLogin)
  -> EsbinDb.login(login, password, clientIp)
    -> anonim PL/SQL blok -> CORE.ESBIN_GATEWAY.LOGIN(h, c, m, o)
      -> Esbin_Kernel.Login, QAT'IY tartibda:
         1. login uzunligi tekshiruvi (AUTH_LOCKOUTS.USERNAME limiti uchun)
         2. bruteforce lockout tekshiruvi (Auth_Lockout, namespace 'ESBIN:')
         3. LOCAL identity (Core_User_Keys) - user_id, key holati
         4. CORE_USERS holati (aktiv, muddat ichida, bloklanmagan)
         5. aktiv partner-user a'zoligi (ESBIN_R_PARTNER_USERS + ESBIN_R_PARTNERS)
         6. IP allowlist tekshiruvi <<-- PAROLDAN OLDIN, ataylab
         7. Auth_Util.Verify_Local_Hash (parol) <<-- faqat shu yerda
         8. muvaffaqiyat: token generatsiya, Esbin_Dml.Set_Partner_Token
            (SHA-256 xesh saqlanadi, xom token faqat javobda bir marta)
```

IP tekshiruvi parol tekshiruvidan OLDIN turishi ataylab: parol tekshiruvi
(PBKDF2, ~120000 iteratsiya) qimmat amal - ruxsat etilmagan IP'dan kelgan
so'rov bu amalgacha yetib bormasligi kerak (aks holda DB CPU'ni "bombalash"
va nishonli lockout orqali haqiqiy hamkorni bloklab qo'yish mumkin edi -
bu birinchi implementatsiya davrida topilgan va tuzatilgan xato).

### 4.2 Execute

```
Java (EsbinGatewayServlet.doExecute)
  -> EsbinDb.execute(token, clientIp, methodCode, extRequestId, rawBodyJson)
    -> CORE.ESBIN_GATEWAY.EXECUTE_REQUEST(...)
      -> Esbin_Kernel.Execute_Request:
         0. Auth_Session.Clear_Context
            (pool'langan ulanishda oldingi so'rovdan qolgan HAR QANDAY UAPP
            konteksti tozalanadi - eng birinchi qadam, hech ish boshlanmasdan)
         1. Esbin_Util.Get_Token_User: token xeshini qidiradi, Revoked_On/
            Expires_On tekshiradi, TOPILSA IP allowlist'ni ham tekshiradi
            (mos kelmasa xuddi token topilmagandek javob - oshkor qilinmaydi)
         2. method mavjudligi/aktivligi, partner-user/method grant tekshiruvi
         3. idempotentlik (Ext_Request_Id) tekshiruvi -> 409 agar takror
         4. Auth_Session.Set_System_Actor(user_id) <<-- FAQAT shu yerda,
            Core_Api dispatch'dan darhol oldin
         5. Core_Api.Get_Model_Clob yoki Execute_Process_Clob (asl process)
         6. Auth_Session.Clear_System_Actor (muvaffaqiyat HAM, xato HAM)
         7. natija ESBIN_REQUESTS/ESBIN_REQUEST_DETAILS'ga yoziladi
```

Muhim: `user_id` so'rov JSON'iga ham qo'shiladi (`Build_Merged_Request`), LEKIN
bu `Core_Api.Check_Process_Access`ning haqiqiy avtorizatsiya manbai EMAS -
u faqat `Core.User_Env.Get_User_Id` (SYS_CONTEXT) orqali ishlaydi, shuning
uchun 4-qadamdagi `Set_System_Actor` chaqiruvi MAJBURIY (bu birinchi
implementatsiya davrida yo'q edi va topilib tuzatilgan - aks holda har bir
chaqiruv `ORA-20003`ga yiqilardi yoki NULL identitet bilan tekshiruvsiz
ishlardi).

Xato bo'lsa: partnerga HAR DOIM generic xabar (`Auth_Const.c_Msg_Sys_Error`
yoki maxsus JSON `{"error":"..."}`) qaytadi, xom `sqlerrm` hech qachon
tashqariga chiqmaydi. Asl xato `o_Ora_Msg`ga (faqat server-log,
`CmsLogUtil` orqali `cms_tag.log`ga) yoziladi.

### 4.3 Logout

Token topilsa - `Esbin_Dml.Revoke_Partner_Token` (darhol). Har doim
muvaffaqiyat qaytaradi (token mavjud/mavjud emasligi oshkor qilinmaydi).
IP allowlist logout'da ATAYLAB tekshirilmaydi - hamkor sizib chiqqan
tokenni istalgan tarmoqdan ham yopa olishi kerak.

## 5. Java gateway (D:\github\core\esbin\java\uz\crobs\esbin\)

```
EsbinGatewayServlet.java  - HttpServlet, /api/esbin/v1/{login,logout,execute}
EsbinDb.java              - JDBC ko'prik (anonim PL/SQL bloklar + CallableStatement)
```

**MUHIM - joylashuv o'zgardi.** Bu fayllar avval `D:\project\iabs\iabs\ibs\esbin\`
ichida, bizning umumiy Tomcat/webapp bilan BIR XIL joyda edi va shu tarzda
uchidan-uchigacha sinalgan edi (9-bo'limga qarang). Keyinroq qaror qilindi:
ESBIN bizning Tomcat'imiz ICHIDA ishlamaydi - shuning uchun `web.xml`dagi
servlet ro'yxati, kompilyatsiya qilingan class fayllar va uch filter
(`VerifyCsrfTokenFilter`/`SetCsrfTokenFilter`/`PageInitFilter`)dagi
`/api/esbin/v1` istisnolari OLIB TASHLANDI - bizning Tomcat'imiz endi bu
yo'l haqida umuman bilmaydi. Java manba fayllari (kod yo'qolib qolmasligi
uchun) shu joyga ko'chirildi - qayerda va qanday ishga tushirilishi (qaysi
server, qaysi web.xml, qanday DB ulanish) endi ESBIN jamoasining o'z qarori.

**DIQQAT - DB ulanish naqshi (o'sha eski, bizning Tomcat'imizdagi sinov
paytida topilgan)**: bu loyihada (bizning `iabs`da) JNDI connection pool
YO'Q edi. Barcha JSP'lar `uz.core.sql.CoreDBConnection.initWalletConnection(...)`
orqali (Oracle Wallet/SEPS) ulanadi, sessiya davomida BITTA marta ochib,
qayta ishlatiladi. `EsbinDb.conn()` xuddi shu mexanizmni ishlatgan edi, LEKIN
ESBIN gateway atayin stateless (HttpSession yo'q) - shuning uchun **har bir
/login va /execute chaqiruvida yangi wallet-ulanish ochilardi**. ESBIN o'z
serverida qayta ishga tushirilganda, DB ulanish naqshi (JNDI pool bormi,
qanday wallet/credential ishlatiladi) ularning o'z muhitiga qarab qayta
ko'rib chiqilishi kerak - bu yerdagi kod faqat namuna/boshlang'ich nuqta.

## 6. Xavfsizlik xususiyatlari (qisqa ro'yxat)

- Token: 256-bit tasodifiy (`Auth_Util.Random_Token`), DB'da faqat SHA-256
  xesh sifatida saqlanadi.
- Parol: mavjud `Auth_Util.Verify_Local_Hash` (PBKDF2+pepper) - yangi
  narsa ixtiro qilinmagan.
- Bruteforce lockout: mavjud `AUTH_LOCKOUTS`/`Auth_Lockout`, `'ESBIN:'`
  namespace bilan (brauzer-login hisoblagichi bilan aralashmaydi).
- IP-allowlist: login VA har bir token-lookup'da, parol tekshiruvidan OLDIN.
- Token TTL: belgilangan (fixed) muddat, partner darajasida sozlanadigan
  (max 24 soat), sliding EMAS.
- Revoke: token darajasida (`Revoke_Partner_Token`, keyingi login'da
  tozalanadi) VA partner-user darajasida (`STATE='P'` - bu DOIMIY, chin
  "o'chir" tugmasi - Login ham, Get_Token_User ham buni tekshiradi).
- DB user-context: har chaqiruv oldidan to'liq tozalanadi
  (`Auth_Session.Clear_Context`), dispatch oldidan `Set_System_Actor`,
  keyin yana tozalanadi - pool'langan ulanishda identitet/kontekst
  sizib qolmasligi uchun.
- Xato xabarlari: partnerga hech qachon xom `sqlerrm`/ORA-matn yubormaydi.
- Audit: `Auth_Audit_Log`ga `ESBIN_LOGIN_OK/FAIL/LOCKED`, `ESBIN_LOGOUT`,
  `ESBIN_TOKEN_IP_MISMATCH`, `ESBIN_ASYNC_ERROR` va h.k. yoziladi.

## 7. Bizning paketlarimizga bog'liqlik (dependency shartnomasi)

ESBIN o'z-o'zidan yopiq subsystem emas - login/parol/audit/kontekst uchun
BIZNING (`access`/`auth`/`core`) paketlarimizga tayanadi. Bu - haqiqiy kodni
(`grep`) tekshirib chiqarilgan, TO'LIQ ro'yxat (faqat izohlarda tilga
olingan, lekin chaqirilmagan narsalar - masalan `Auth_Api_Gateway.Execute`,
`Core_Api.Check_Process_Access`, `Core.User_Env.Get_User_Id` - bu ro'yxatda
YO'Q, ular faqat "shu bilan bir xil intizom" deb izohda solishtirish uchun
tilga olingan, ESBIN ularni to'g'ridan-to'g'ri chaqirmaydi).

| Bizning paket | Nima chaqiriladi | Qayerda (Esbin_Kernel.pck) |
|---|---|---|
| `Core_Api` | `Execute_Process_Clob`, `Get_Model_Clob` | Execute_Request, Run_Async_Queue - asosiy dispatch |
| `Auth_Session` | `Clear_Context`, `Set_System_Actor` | Execute_Request/Run_Async_Queue - har chaqiruv oldi/keyin |
| `Auth_Util` | `Norm_Username`, `Verify_Local_Hash`, `Random_Token`, `Hash_Sha256` | Login (parol/token) |
| `Auth_Lockout` | `Is_Locked`, `Register_Failure`, `Reset` | Login (bruteforce himoya, namespace `'ESBIN:'`) |
| `Auth_Audit` | `Log` | Login/Logout/Revoke_Token/Run_Async_Queue xatolari - audit yozuvi |
| `Auth_Const` | `c_Msg_Sys_Error`, `c_Msg_Auth_Failed`, `c_Provider_Local`, `c_State_Active`, `c_Rsn_*` doimiylari | Login (xabar/sabab kodlari) |
| `Core.Hash_t` (tur) | `Core.Hash_t()`, `.Put()`, `.Get_Optional_*()` | Login/Logout/Sm_Api/Gateway imzolari - UAPP'ga alohida grant qilingan (3-bo'limga qarang) |
| `Core_User_Keys`, `Core_Users` (jadval) | to'g'ridan-to'g'ri SELECT (LOCAL identity, holat) | Login |

**Amaliy natija**: agar kelajakda BIZ shu imzolarni (masalan
`Auth_Session.Set_System_Actor`ning parametrlarini, yoki `Auth_Const.c_Rsn_*`
doimiylarining nomini) o'zgartirsak - ESBIN buziladi, chunki u bizning
paketimizni to'g'ridan-to'g'ri chaqiradi (grant/sinonim orqali emas, CORE
ichida to'g'ridan-to'g'ri - ESBIN ham CORE schema'sida). Bu ro'yxat - shu
signal uchun "buzilishi mumkin" ro'yxati.

## 8. Bilinadigan ochiq masalalar (ESBIN jamoasi uchun TODO)

Bular hal qilinmagan, keyingi egasi hal qiladi deb qoldirilgan:

1. **Yuklama/DoS chidamliligi (ENG MUHIM, Fable bilan maslahatlashilgan,
   HALI QO'LLANILMAGAN).** `EsbinGatewayServlet` xuddi shu Tomcat/JVM'da,
   xodimlar ishlatadigan asosiy ilova bilan BIR XIL thread pool'ni
   baham ko'radi - alohida jarayon/konteyner yo'q. Har bir ESBIN so'rovi
   yangi Oracle Wallet ulanish ochadi (6-bo'limga qarang) - bu oddiy
   so'rovdan ancha qimmat (yuzlab ms - soniyalar). Bir nechta parallel
   "sekin"/zararli so'rov Tomcat'ning BUTUN thread pool'ini to'ldirib,
   ESBIN bilan bog'liq bo'lmagan asosiy ilovani ham osilib qoldirishi
   mumkin - murakkab hujum shart emas. IP-allowlist va lockout bu yerda
   yordam bermaydi (ular thread band bo'lgandan KEYIN tekshiriladi).

   Tavsiya (bugun uchun, bitta faylda, kichik o'zgarish):
   `EsbinGatewayServlet.doPost`ga chegaralangan semaphore qo'yish - limitdan
   oshgan so'rov darhol `503` bilan rad etiladi, thread band qilinmaydi:
   ```java
   private static final int MAX_CONCURRENT = 20; // haqiqiy trafikni kuzatib sozlash kerak
   private static final java.util.concurrent.Semaphore CONCURRENCY_GATE =
       new java.util.concurrent.Semaphore(MAX_CONCURRENT);

   protected void doPost(...) {
       if (!CONCURRENCY_GATE.tryAcquire()) {
           res.setHeader("Retry-After", "1");
           res.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE);
           return;
       }
       try { /* mavjud dispatch */ }
       finally { CONCURRENCY_GATE.release(); }
   }
   ```
   Keyingi qadam (keyinroq, kattaroq o'zgarish, alohida review bilan): ESBIN
   uchun haqiqiy connection pool (har safar yangi wallet ochish o'rniga) -
   bu ham yuklama, ham DoS holatida xarajatni tubdan kamaytiradi.

   Kod bilan hal qilib bo'lmaydigan qism: haqiqiy hajmli tarmoq hujumi
   (paket darajasida) - bu Tomcat oldida proxy/firewall/WAF bor-yo'qligiga
   bog'liq, infratuzilma savoli, servlet kodi bilan yechilmaydi.

   **Qo'shimcha tavsiya - favqulodda "kill-switch" (Fable bilan alohida
   maslahatlashilgan, HALI QO'LLANILMAGAN):** loyiha egasi tomonidan
   so'ralgan g'oya - hujum vaqtida tashqi-tizim trafigini bir joydan
   butunlay o'chirib qo'yish imkoniyati. Fable'ning xulosasi:
   - Bu g'oya faqat "so'rov darajasidagi" (L7, ko'p HTTP so'rov) toshqinga
     yordam beradi - haqiqiy hajmli tarmoq hujumiga (paket darajasida,
     Tomcat konnektor/OS darajasida) YORDAM BERMAYDI, chunki flag'ni
     tekshiradigan kod ham o'sha band bo'lib qolgan JVM ichida ishlaydi.
   - Amalga oshirilsa: `EsbinGatewayServlet` oldiga bitta Java `Filter`,
     **xotiradagi** (`volatile`/`AtomicBoolean` static maydon) flagni
     tekshiradi - `EsbinDb.conn()` (qimmat wallet-ulanish) ochilishidan
     OLDIN. DB'dan har-so'rov o'qish EMAS - bu himoya qilmoqchi bo'lgan
     resursning o'ziga yuklama qo'shib qo'yadi.
   - `Core_Api`ning o'ziga TEGMASLIK kerak - u ham xodimlar brauzeridan
     (PageInitFilter/Get_Page_Init), ham ESBIN'dan chaqiriladi, va ularni
     arzon ajratish yo'li hozircha yo'q. Kill-switch har bir gateway'ning
     (ESBIN, va agar kerak bo'lsa alohida - `Auth_Api_Gateway`) O'ZIDA
     bo'lishi kerak, umumiy joyda emas.
   - `Auth_Api_Gateway` uchun alohida eslatma: u PL/SQL paket, Java servlet
     emas - shuning uchun Java-tomonidagi flag unga tegmaydi (PL/SQL-tomonida
     alohida mexanizm kerak bo'lardi). Bunga vaqt sarflashdan oldin, uning
     umuman jonli tashqi chaqiruvchisi bor-yo'qligini tekshirish tavsiya
     etiladi (agar ishlatilmayotgan/legacy bo'lsa - bu spekulyativ ish).
   - Ustuvorlik: avval yuqoridagi semaphore, kill-switch shu bilan BIRGA
     (o'rniga emas) qo'shilishi mumkin - arzon, lekin semaphore'dan keyingi
     qadam, birinchi emas.

2. **HTTPS.** `web.xml`dagi `<security-constraint>` (CONFIDENTIAL) hozir
   izohga olingan - real muhitga chiqishdan oldin qayta yoqilishi VA o'sha
   Tomcat'da haqiqiy HTTPS connector/sertifikat bo'lishi SHART.

3. **X-Forwarded-For ishonchi.** `EsbinGatewayServlet.clientIp()` ataylab
   FAQAT `getRemoteAddr()`ni ishlatadi (proxy sarlavhasiga ishonmaydi),
   chunki Tomcat oldida ishonchli TLS-tugatuvchi proxy borligi
   tasdiqlanmagan. Agar kelajakda shunday proxy qo'shilsa, bu funksiya
   ataylab moslashtirilishi kerak (aks holda IP-allowlist butunlay
   chetlab o'tiladi).

4. **`Ip_Matches_Entry` (Esbin_Util.pck) BITAND xatti-harakati** 32-bitli
   qiymatlar bilan bu aniq Oracle 19c nusxasida amaliy tekshirilmagan -
   real `/24` va `/32` so'rov bilan tasdiqlash tavsiya etiladi.

5. Bu subsystem hali `D:\github\core\deploy_all.sql`ga ulanmagan - bu
   ataylab shunday qoldirilgan (kim va qachon ulashini ESBIN jamoasi
   hal qiladi).

6. **Texnik userlar brauzer-login'dan himoyalanmagan (bizning tomonda
   qisman tuzatildi, ESBIN tomonida hali yo'q).** Aniqlandi: hech narsa
   bir xil `Core_User_Keys` (LOCAL) login/parolining HAM ESBIN'ga, HAM
   oddiy brauzer login formasiga ishlatilishiga to'sqinlik qilmaydi -
   `TEST_PARTNER`/`-1` (`super_user`) sinovda aynan shu sabab ikkala
   tomondan ham ishladi. Bizning tomonda (`Auth_Kernel.Complete_Login`)
   endi `Core_Users.User_Type_Id = 1` (`Core_Const.c_User_Type_Api`)
   bo'lgan har qanday userni brauzer-login'dan rad etadi. **Tavsiya
   qilinadi**: `Esbin_Kernel.Login` ham TESKARI tomondan tekshirsin -
   `ESBIN_R_PARTNER_USERS`ga qo'shiladigan texnik user albatta shu
   `User_Type_Id=1` turida bo'lishi SHART qilinsin (masalan `Login`ning
   `Core_User_Keys`/`Core_Users` lookup bosqichida qo'shimcha shart
   sifatida) - shunda haqiqiy xodim tasodifan yoki ataylab
   `ESBIN_R_PARTNER_USERS`ga qo'shilib qo'yilsa ham, uning haqiqiy
   ish-parolidan ESBIN orqali foydalanib bo'lmaydi. Real (test
   bo'lmagan) ESBIN texnik userlarini yaratishda ham shu turni
   belgilash tavsiya etiladi.

## 9. Joriy holat (dev mashina) va keyingi qadam

**DB (PL/SQL) tomoni**: hammasi `D:\github\core` git tarixida (commitlar:
`git log --oneline --all -- esbin/`). Dev DB'da (`172.20.6.157:1521/new_abs`)
to'liq deploy qilingan va uchidan-uchigacha (login -> execute -> xato
holatlar -> idempotentlik -> logout -> audit-log) `curl` bilan tasdiqlangan -
test ma'lumoti: `TEST_PARTNER` / texnik user `-1` (`super_user`). Bu sinov
o'sha paytda ESBIN'ning Java gateway'i vaqtincha bizning `iabs` Tomcat'imizga
qo'yilgan holda o'tkazilgan edi.

**MUHIM - Java gateway endi bizning Tomcat'imizda EMAS.** Sinovdan keyin
qaror qilindi: ESBIN'ning HTTP qatlami bizning umumiy Tomcat/webapp bilan
bir jarayonda yashamasligi kerak (5-bo'limdagi sabab). Shunga ko'ra:
- `D:\project\iabs`dan servlet ro'yxati (`web.xml`), kompilyatsiya qilingan
  class fayllar, va uch filter (`VerifyCsrfTokenFilter`/`SetCsrfTokenFilter`/
  `PageInitFilter`)dagi `/api/esbin/v1` istisnolari OLIB TASHLANDI.
- Java manba fayllari `D:\github\core\esbin\java\uz\crobs\esbin\`ga
  ko'chirildi - **qayerda va qanday serverda ishga tushirilishi endi ESBIN
  jamoasining o'z tanlovi** (o'z Tomcat'i, boshqa servlet konteyner, yoki
  butunlay boshqa til/freymvork - bu kod faqat namuna/boshlang'ich nuqta,
  PL/SQL tomoni bilan qanday bog'lanish (JDBC ulanish turi, wallet/pool) ham
  ularning o'z muhitiga qarab qayta ko'rib chiqilishi kerak).

Boshqa muhitga (ularning o'z serveriga) chiqarish uchun: DB skriptlari
(`esbin/tables`, `esbin/packages`, `esbin/grants`) o'sha muhitning bazasida
ishga tushiriladi (server qayerda bo'lishidan qat'iy nazar, DB bir xil
qoladi); Java tomoni (`esbin/java/`) ESBIN jamoasi tanlagan serverga
moslashtirilib joylashtiriladi; `TEST_PARTNER` o'rniga haqiqiy hamkor
ma'lumoti yaratiladi. Tashqi hamkor uchun API-hujjat (server manzili
o'zgarsa ham HTTP-shartnoma bir xil qoladi): `esbin/docs/PARTNER_API.md`.
