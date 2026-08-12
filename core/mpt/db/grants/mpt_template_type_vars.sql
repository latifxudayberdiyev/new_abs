-- Ilova (JSP) CORE emas, UAPP user orqali ulanadi. Har bir yangi CORE obyekti
-- uchun GRANT + SYNONYM kerak, aks holda ORA-00942.
--
-- MPT_TEMPLATE_TYPE_VARS - shablon turiga o'zgaruvchi biriktirish jadvali.
-- UAPP unga to'g'ridan-to'g'ri emas, Mpt_Admin_Api orqali yozadi, lekin
-- SM edit-model va grid uchun SELECT ham kerak.
--
-- MPT_TEMPLATE_TYPE_VARS_V - checkbox grid: barcha faol o'zgaruvchilar +
-- IS_MAPPED flag (joriy shablon turi uchun, session orqali).
--
-- DIQQAT: 'UAPP' - manba muhitdagi app-user nomi. Target muhitda boshqacha
-- bo'lishi mumkin - shu holatda quyidagi nomni almashtiring.

GRANT SELECT, INSERT, UPDATE, DELETE ON MPT_TEMPLATE_TYPE_VARS TO UAPP;
GRANT SELECT ON MPT_TEMPLATE_TYPE_VARS_S1 TO UAPP;
GRANT SELECT ON MPT_TEMPLATE_TYPE_VARS_V TO UAPP;

CREATE OR REPLACE SYNONYM UAPP.MPT_TEMPLATE_TYPE_VARS FOR CORE.MPT_TEMPLATE_TYPE_VARS;
CREATE OR REPLACE SYNONYM UAPP.MPT_TEMPLATE_TYPE_VARS_V FOR CORE.MPT_TEMPLATE_TYPE_VARS_V;
