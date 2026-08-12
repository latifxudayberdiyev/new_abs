-- Ilova (JSP) CORE emas, alohida DB user (masalan UAPP) orqali ulanadi.
-- Har bir yangi CORE obyekti uchun shu userga alohida GRANT + SYNONYM kerak,
-- aks holda ORA-00942 "table or view does not exist" xatosi chiqadi
-- (obyekt CORE ostida mavjud va VALID bo'lsa ham).
--
-- MPT_PRINT_SETTING_FILES ga print_setting.jsp "Сохранить" bosilganda
-- to'g'ridan-to'g'ri emas, Mpt_Admin_Api.Save_Print_Setting_File orqali
-- yoziladi - lekin UAPP shu jadvalni tahrirlash (edit rejimida avvalgi
-- fayl nomini o'qish) uchun SELECT ga ham muhtoj.
--
-- DIQQAT: 'UAPP' - manba muhitdagi app-user nomi. Target muhitda boshqacha
-- bo'lishi mumkin - shu holatda quyidagi nomni almashtiring.

GRANT SELECT, INSERT, UPDATE, DELETE ON MPT_PRINT_SETTING_FILES TO UAPP;
GRANT SELECT ON MPT_PRINT_SETTING_FILES_S1 TO UAPP;

CREATE SYNONYM UAPP.MPT_PRINT_SETTING_FILES FOR CORE.MPT_PRINT_SETTING_FILES;
