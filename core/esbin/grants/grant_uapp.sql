----------------------------------------------------------------------------------------------------
--  Veb-ilova (UAPP) uchun ESBIN grant/sinonim - FAQAT Esbin_Gateway.
--
--  MUHIM: Esbin_Kernel, Esbin_Dml, Esbin_Util, Esbin_Const, Esbin_Sm_Api UAPP'ga
--  GRANT QILINMAYDI - ular CORE-ichki/SM-dispatch-only bo'lib qoladi. Sabab:
--  Esbin_Kernel o'zi Save_User_Methods/Attach_User_Methods'ni ham tashiydi -
--  ular o'z ichida hech qanday avtorizatsiya tekshirmaydi (chaqiruvchi
--  Esbin_Sm_Api/Core_Api process-guard orqali kelgan deb ishonadi). Agar
--  Esbin_Kernel to'g'ridan-to'g'ri UAPP'ga grant qilinsa, istalgan UAPP-tarafi
--  JSP ixtiyoriy ESBIN method-dostupini biriktirib qo'yishi mumkin bo'lardi -
--  bu avtorizatsiyani chetlab o'tish (bypass). Esbin_Gateway shu xavfni
--  yo'q qiladi: faqat o'z-o'zini avtorizatsiya qiladigan (token/parol
--  tekshiruvi ichida) uchta metodni (Login/Logout/Execute_Request) ochadi.
--
--  Run as CORE schema owner.
----------------------------------------------------------------------------------------------------

grant execute on CORE.ESBIN_GATEWAY to UAPP;

create or replace synonym UAPP.ESBIN_GATEWAY for CORE.ESBIN_GATEWAY;

-- Discovered missing during live dev-deploy test: the Java gateway builds a
-- Core.Hash_t object directly (Esbin_Gateway.Login/Logout take one as an
-- in-out param) - unlike Core_Api.Get_Page_Init's plain-CLOB signature, this
-- requires UAPP to instantiate the TYPE itself, not just call a package that
-- uses it internally. Hash_t is a generic key/value carrier, not itself an
-- authorization boundary - the real access check stays inside Esbin_Gateway.
grant execute on CORE.HASH_T to UAPP;

create or replace synonym UAPP.HASH_T for CORE.HASH_T;

PROMPT === verify ===
SELECT grantee, privilege, table_name FROM all_tab_privs WHERE grantee = 'UAPP' AND table_name LIKE 'ESBIN%';
SELECT synonym_name, table_owner, table_name FROM all_synonyms WHERE owner = 'UAPP' AND synonym_name LIKE 'ESBIN%';
