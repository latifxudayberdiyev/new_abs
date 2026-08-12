----------------------------------------------------------------------------------------------------
-- menu_button_wiring_v - CORE_R_MENU_BUTTONS <-> SM_R_PROCESSES orasidagi ulanishni
-- tekshiruvchi konsistentlik (consistency) view'i.
--
-- Bu qoidalar CHECK cheklovi bo'la olmaydi (ikkita jadval orasidagi bog'liqlik,
-- Oracle CHECK esa faqat bitta qatorning o'zini ko'radi), trigger esa noto'g'ri
-- vosita - SM_R_PROCESSES deploy-boshqariluvchi katalog jadvali va uning keyinchalik
-- o'zgarishi (masalan STATE='P' qilinishi yoki process_type o'zgartirilishi)
-- CORE_R_MENU_BUTTONS'dagi hech qanday DML'ni ishga tushirmaydi - trigger buni
-- hech qachon ushlab qololmaydi. Shu sabab bu tekshiruv alohida view sifatida
-- ishlab chiqilgan - har deploy'dan keyin va davriy monitoring orqali SELECT
-- qilinishi kerak.
--
-- TO'G'RI holatda bu view HAR DOIM BO'SH qaytishi kerak. Har bir qaytgan qator -
-- CATALOG (wiring) xatosi, runtime xatosi emas.
--
-- Tekshiriladigan holatlar (process_type qiymatlari Sm_Const.pck'dagi
-- c_Process_Type_Post='POST', c_Process_Type_Operation='OPERATION',
-- c_Process_Type_Get='GET' konstantalariga mos keladi - literal sifatida
-- yozilgan, chunki SQL view'dan PL/SQL paket konstantasiga to'g'ridan-to'g'ri
-- murojaat qilib bo'lmaydi; Sm_Kernel.pck ham shu uchta qiymat bo'yicha
-- branch qiladi):
--   WRONG_PROCESS_TYPE     - process_code GET turidagi processga ishora qiladi
--                            (process_code Core_Api.Execute_Process_Clob / POST-submit
--                            uchun, GET emas)
--   WRONG_MODEL_TYPE       - model_process_code GET bo'lmagan processga ishora qiladi
--                            (model_process_code faqat Core_Api.Get_Model_Clob / o'qish
--                            uchun)
--   PROCESS_INACTIVE       - process_code ko'rsatgan process STATE != 'A'
--   MODEL_PROCESS_INACTIVE - model_process_code ko'rsatgan process STATE != 'A'
--   MODEL_WITHOUT_PROCESS  - model_process_code bor, lekin process_code NULL
--                            (forma o'qish uchun ochiladi, lekin submit qiladigan
--                            joyi yo'q - shubhali holat)
----------------------------------------------------------------------------------------------------
create or replace view menu_button_wiring_v as
select b.module_code,
       b.menu_id,
       b.button_id,
       b.action_code,
       b.process_code,
       b.model_process_code,
       'WRONG_PROCESS_TYPE' as problem_code,
       'process_code (''' || b.process_code ||
       ''') GET turidagi processga ishora qiladi - process_code faqat POST/OPERATION (submit) uchun' as problem_description
  from CORE_R_MENU_BUTTONS b
  join SM_R_PROCESSES p1
    on p1.process_code = b.process_code
 where b.process_code is not null
   and p1.process_type = 'GET'
union all
select b.module_code,
       b.menu_id,
       b.button_id,
       b.action_code,
       b.process_code,
       b.model_process_code,
       'WRONG_MODEL_TYPE' as problem_code,
       'model_process_code (''' || b.model_process_code || ''') GET bo''lmagan (''' || p2.process_type ||
       ''') processga ishora qiladi - model_process_code faqat GET (o''qish) uchun' as problem_description
  from CORE_R_MENU_BUTTONS b
  join SM_R_PROCESSES p2
    on p2.process_code = b.model_process_code
 where b.model_process_code is not null
   and p2.process_type != 'GET'
union all
select b.module_code,
       b.menu_id,
       b.button_id,
       b.action_code,
       b.process_code,
       b.model_process_code,
       'PROCESS_INACTIVE' as problem_code,
       'process_code (''' || b.process_code || ''') ko''rsatgan process holati faol emas (STATE=''' ||
       Nvl(p1.state, 'NULL') || ''')' as problem_description
  from CORE_R_MENU_BUTTONS b
  join SM_R_PROCESSES p1
    on p1.process_code = b.process_code
 where b.process_code is not null
   and Nvl(p1.state, 'X') != 'A'
union all
select b.module_code,
       b.menu_id,
       b.button_id,
       b.action_code,
       b.process_code,
       b.model_process_code,
       'MODEL_PROCESS_INACTIVE' as problem_code,
       'model_process_code (''' || b.model_process_code ||
       ''') ko''rsatgan process holati faol emas (STATE=''' || Nvl(p2.state, 'NULL') || ''')' as problem_description
  from CORE_R_MENU_BUTTONS b
  join SM_R_PROCESSES p2
    on p2.process_code = b.model_process_code
 where b.model_process_code is not null
   and Nvl(p2.state, 'X') != 'A'
union all
select b.module_code,
       b.menu_id,
       b.button_id,
       b.action_code,
       b.process_code,
       b.model_process_code,
       'MODEL_WITHOUT_PROCESS' as problem_code,
       'model_process_code bor, lekin process_code NULL - forma o''qish uchun ochiladi, lekin submit qiladigan process yo''q' as problem_description
  from CORE_R_MENU_BUTTONS b
 where b.model_process_code is not null
   and b.process_code is null;
