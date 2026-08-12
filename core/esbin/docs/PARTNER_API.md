# ESBIN Partner API — integration guide

Tashqi tizim (partner) uchun Bearer-token asosidagi API. Bu hujjatni tashqi
tizim dasturchilariga bering — ular shu bo'yicha o'z klientlarini yozishadi.
Bizning tomonda faqat CORE_R_PARTNER... jadvallarida ro'yxatdan o'tkazilgan
`login`/`password` va ruxsat berilgan `method_code`larga ega texnik user
ishlaydi — partnerning o'z end-user'lari bizga umuman ko'rinmaydi va
qiziqtirmaydi.

## Talablar (bizning tomondan)

- **Faqat HTTPS.** Oddiy HTTP orqali so'rov qabul qilinmaydi.
- **Statik chiquvchi IP(lar).** Login va har bir so'rovda tekshiriladi
  (IP-allowlist). Ro'yxatdan o'tishdan oldin bizga sizning server(lar)ingiz
  chiquvchi IP manzilini(larini) bering (CIDR ham mumkin, masalan
  `10.20.30.5` yoki `10.20.31.0/24`).
- **login + parol** — bizning tomondan sizga oldindan beriladi (bitta
  texnik user, sizning barcha so'rovlaringiz shu userdan bajariladi).
- Har bir chaqirishingiz uchun ruxsat berilgan `method_code`lar ro'yxati
  oldindan kelishiladi — ro'yxatda yo'q methodni chaqirsangiz `403` qaytadi.

## 1. Login

```
POST /api/esbin/v1/login
Content-Type: application/json

{
  "login": "<sizga berilgan login>",
  "password": "<sizga berilgan parol>"
}
```

**Muvaffaqiyatli javob — 200:**
```json
{
  "access_token": "9f3a...64-hex-belgidan-iborat-token",
  "token_type": "Bearer",
  "expires_in": 28800,
  "partner_code": "SIZNING_PARTNER_KODINGIZ"
}
```

`expires_in` — token amal qilish muddati, sekundda (standart 8 soat,
biz tomondan sozlanishi mumkin). Muddati tugagach yoki token bekor
qilingach, qayta shu endpoint orqali login qilib, yangi token oling.

**Xato — 401:**
```json
{"code": 1, "msg": "..."}
```
Sabab (noto'g'ri parol, bloklangan, IP ro'yxatda yo'q va h.k.) ATAYLAB
oshkor qilinmaydi — hammasi bir xil xabar.

## 2. Metodni chaqirish (asosiy ish)

```
POST /api/esbin/v1/execute
Authorization: Bearer <access_token>
X-Esbin-Method-Code: <sizga berilgan method_code>
X-Esbin-Ext-Request-Id: <sizning tomoningizdagi noyob so'rov ID'i>
Content-Type: application/json

{ ... sizning method uchun kerakli JSON tanasi ... }
```

- **`X-Esbin-Ext-Request-Id`** — har bir yangi amaliyot uchun noyob bo'lishi
  SHART. Idempotent methodlar uchun bir xil ID bilan qayta yuborilgan
  so'rov bajarilmaydi (`409` qaytadi) — tarmoq uzilib qayta yuborishda
  ikki marta bajarilishning oldini oladi.
- Request tanasi (JSON) qanday shaklda bo'lishi — bu **method-specific**,
  har bir `method_code` uchun alohida kelishiladi. Biz uning ichki
  formatiga aralashmaymiz, faqat kerakli `process_code`ga uzatamiz.

**Muvaffaqiyatli javob — 200:** method natijasi, o'zgarishsiz (qanday
JSON qaytgan bo'lsa, aynan shu).

**Xato javoblari:**

| HTTP | `code` | Ma'no |
|---|---|---|
| 401 | 401 | Token yaroqsiz/muddati tugagan/bekor qilingan/IP mos emas — qayta login qiling |
| 403 | 403 | Bu methodga (yoki bu partnerga) dostup yo'q |
| 404 | 404 | `method_code` topilmadi yoki faol emas |
| 409 | 409 | Shu `X-Esbin-Ext-Request-Id` bilan so'rov allaqachon mavjud |
| 500 | -1 / -999 | Bizning tomondagi tizim xatosi — sabab tafsiloti qaytarilmaydi, biz bilan bog'laning |

Barcha xato javoblari bir xil shaklda: `{"code": <yuqoridagi>, "msg": "..."}`.

## 3. Asinxron methodlar — natijani so'rash

Ba'zi methodlar darhol emas, navbatga qo'yilgan holda ishlaydi (bu holat
oldindan kelishiladi). Bunday method chaqirilganda javob darhol:
```json
{"esbin_request_id": 12345, "state": "QUEUED"}
```
Natijani keyin shu maxsus method bilan so'rang:
```
POST /api/esbin/v1/execute
Authorization: Bearer <access_token>
X-Esbin-Method-Code: GET_REQUEST_RESULT
X-Esbin-Ext-Request-Id: <yangi noyob ID>

{"esbin_request_id": 12345}
```
yoki `{"ext_request_id": "<sizning original ID'ingiz>"}` orqali ham so'rash
mumkin. Javobda `"state"` — `QUEUED`/`RUNNING`/`SUCCESS`/`ERROR`, va
tugagan bo'lsa `"response"` maydoni bilan natija keladi.

## 4. Logout

```
POST /api/esbin/v1/logout
Authorization: Bearer <access_token>
```
Har doim `204 No Content` qaytadi. Tokenni shubhali holatda (masalan,
sizib chiqqan deb gumon qilsangiz) darhol shu orqali yoping — yangi
login o'zi ham eski tokenni avtomatik bekor qiladi.

## Eslatmalar

- Token faqat BITTA marta ko'rsatiladi (login javobida) — uni saqlang,
  loglarga yozmang.
- Bir vaqtning o'zida bitta texnik user uchun bitta token aktiv bo'ladi
  — qayta login qilsangiz, avvalgi token darhol ishlamay qoladi. Parallel
  so'rovlar yuborsangiz ham, BITTA tokenni ulashib ishlating (har safar
  qayta login qilmang).
- Token/parolni URL query-parametrda YUBORMANG — faqat header/body orqali.
