-- Ilova (JSP) CORE emas, alohida DB user (masalan UAPP) orqali ulanadi.
-- Har bir yangi CORE obyekti uchun shu userga alohida GRANT + SYNONYM kerak,
-- aks holda ORA-00942 "table or view does not exist" xatosi chiqadi
-- (obyekt CORE ostida mavjud va VALID bo'lsa ham).
--
-- MPT_LANGUAGES_V ni print_setting.jsp o'qiydi - "Faylni tanlang <til>"
-- polyalari shu view'dan dinamik chiziladi.
--
-- DIQQAT: 'UAPP' - manba muhitdagi app-user nomi. Target muhitda boshqacha
-- bo'lishi mumkin - shu holatda quyidagi nomni almashtiring.

GRANT SELECT ON MPT_LANGUAGES_V TO UAPP;

CREATE SYNONYM UAPP.MPT_LANGUAGES_V FOR CORE.MPT_LANGUAGES_V;
