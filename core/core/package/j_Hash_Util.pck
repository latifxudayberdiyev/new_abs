-- j_Hash_Util o'chirildi: hech qanday PL/SQL funksiyada ham, Java tarafda ham
-- (setOutParameterEncrypted/addJhashEncryptionValue olib tashlandi, cms_tag)
-- chaqirilmagan, to'liq o'lik kod edi. Ustiga, holati (Param_Names/
-- Param_Entity_Names) paket-global (pooled connection'da sessiya darajasida)
-- saqlanardi - agar kimdir buni qayta ishlatsa, bitta so'rovning shifrlash
-- ro'yxati keyingi so'rovga sizib qolishi mumkin edi (pool orqali).
--
-- Tarix uchun eski tarkib git logda saqlanadi. Qayta kerak bo'lsa, o'sha
-- versiyadan tiklab, avval bitta real funksiyaga ulab sinab ko'rish kerak.
drop package j_Hash_Util;
