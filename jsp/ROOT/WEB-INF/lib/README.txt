file-service (fayl yuklash/yuklab olish) uchun kerak bo'lgan barcha bog'liq
kutubxonalar (13 ta jar). file-service-client.jar - tuzatilgan (patched)
nusxa: file/folder/privacyType kontraktiga mos, docx/xlsx MIME muammosiz.

O'RNATISH (yangi kompyuterdagi Tomcat uchun)
=============================================
1. Shu papkadagi BARCHA jar'larni $CATALINA_HOME\lib\ ga qo'ying
   (masalan E:\tomcat9_ABS\tomcat9_ABS\lib\ - bu papka Tomcat'ning
   umumiy/shared classloader'i, WEB-INF\lib EMAS).
2. WEB-INF\fileservice.properties faylini yarating (yoki nusxa oling):
     url=http://<file-service-host>:9090
     user=<login>
     password=<parol>
3. Tomcat'ni qayta ishga tushiring.

Kod tomonidan foydalanish uchun JSP fayllari kerak bo'ladi:
  print_setting_upload.jsp   - faylni file-service'ga yuklaydi
  print_setting_download.jsp - file-service'dan yuklab oladi (generateLink +
                                MinIO presigned URL, Host-header trukki bilan -
                                sabab: file-service 127.0.0.1:9000 qaytaradi,
                                tashqaridan yetib bo'lmaydi)
Ular E:\project\mpt\jsp\ibs\mpt\ da.

DIQQAT
======
- privacyType har doim PRIVATE bo'lishi kerak - PUBLIC faylda generateLink
  (demak yuklab olish) ishlamaydi (server "havola kerak emas" deb rad etadi).
- folder nomi faqat [a-zA-Z0-9_-] bo'lishi kerak, "/" TAQIQLANGAN.
