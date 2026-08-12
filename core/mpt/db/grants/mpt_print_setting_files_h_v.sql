-- Ilova (JSP) CORE emas, alohida DB user (masalan UAPP) orqali ulanadi.
-- Har bir yangi CORE obyekti uchun shu userga alohida GRANT + SYNONYM kerak,
-- aks holda ORA-00942 "table or view does not exist" xatosi chiqadi
-- (obyekt CORE ostida mavjud va VALID bo'lsa ham).
--
-- print_setting_file_history.jsp shu view orqali fayl almashtirish tarixini
-- (eski va yangi fayllar, har birini yuklab olish havolasi bilan) ko'rsatadi.
--
-- DIQQAT: 'UAPP' - manba muhitdagi app-user nomi. Target muhitda boshqacha
-- bo'lishi mumkin - shu holatda quyidagi nomni almashtiring.

GRANT SELECT ON MPT_PRINT_SETTING_FILES_H_V TO UAPP;

CREATE SYNONYM UAPP.MPT_PRINT_SETTING_FILES_H_V FOR CORE.MPT_PRINT_SETTING_FILES_H_V;
