-- Ilova (JSP) CORE emas, alohida DB user (masalan UAPP) orqali ulanadi.
-- Har bir yangi CORE obyekti uchun shu userga alohida GRANT + SYNONYM kerak,
-- aks holda ORA-06550/PLS-00201 "identifier must be declared" xatosi chiqadi
-- (paket CORE ostida mavjud va VALID bo'lsa ham).
--
-- MPT_PRINT_API - PECHAT SISTEMA v4 (Get_All_Resolved_Vars va boshqalar) -
-- yozilgandan keyin hech qanday JSP tomonidan chaqirilmagan edi, shuning
-- uchun grant/sinonim ham qo'shilmagan qolgan.
--
-- DIQQAT: 'UAPP' - manba muhitdagi app-user nomi. Target muhitda boshqacha
-- bo'lishi mumkin - shu holatda quyidagi nomni almashtiring.

GRANT EXECUTE ON MPT_PRINT_API TO UAPP;

CREATE OR REPLACE SYNONYM UAPP.MPT_PRINT_API FOR CORE.MPT_PRINT_API;
