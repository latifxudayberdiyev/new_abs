create or replace package Core_Const is

  -- Author  : B.URALOV
  -- Created : 15.04.2025 16:22:48
  -- Purpose : core ga tegishli va barcha modulelar uchun umumiy constlarni saqlaydi

  c_Filial       constant varchar2(5) := '00440';
  c_Filial_Local constant varchar2(5) := '01000';
  c_Header_Bank  constant varchar2(5) := '09003';
  c_Header_Local constant varchar2(5) := '00000';

  --  dates
  c_Deactivate_Date constant date := to_date('31.12.9999', 'dd.mm.yyyy');

  -- states
  c_State_Active  constant varchar2(1) := 'A';
  c_State_Passive constant varchar2(1) := 'P';
  c_State_Reject  constant varchar2(1) := 'R';
  c_Success_Code  constant number := 0;
  -- umumiy natija kodlari (core_kernel.pck va shu kabi paketlar uchun) - "topilmadi"/"kutilmagan
  -- xato" har birida alohida-alohida raqam sifatida qaytarilmasin, shu yerdan olinsin
  c_Err_Not_Found constant number := 1;
  c_Err_Unhandled constant number := -999;
  -- user types (Core_Users.User_Type_Id -> Core_R_User_Types.Code)
  -- API USER: sun'iy/texnik hisob (masalan ESBIN texnik useri) - inson emas.
  -- Auth_Kernel.Complete_Login bu turdagi userni brauzer-login'dan rad etadi
  -- (technik hisob login/paroli tasodifan yoki ataylab brauzer UI'ga kirish
  -- uchun ishlatilmasin - ADM_REL_USER_MENUS/BUTTONS granti bo'lmasa ham,
  -- Menu_Type='PUBLIC' menyular har qanday login qilgan userga ochiq).
  c_User_Type_Api constant number := 1;
  -- menus
  c_Core_Menus    constant number(1) := 0;
  c_Is_Menu_True  constant varchar2(1) := 'Y';
  c_Is_Menu_False constant varchar2(1) := 'Y';
  -- modules
  c_Adm_Module_Code constant varchar2(3) := 'ADM';
  c_Mfi_Module_Code constant varchar2(3) := 'MFI';
  -- Core_Api process-code guard: log-then-enforce ko'chirish rejimi - UCH BOSQICHLI "zinapoya"
  -- (staircase), har bosqich avvalgisidan qat'iyroq:
  --   LOG          - hech narsani bloklamaydi, faqat CORE_PROCESS_ACCESS_LOG'ga yozadi.
  --   ENFORCE_DOOR - faqat WRONG_DOOR_TYPE va GUARD_ERROR outcome'larini bloklaydi (eng past
  --                  xavfli/eng ishonchli qism - cross-door escalation va guard'ning o'z ichki
  --                  xatolari; ADM_REL_USER_BUTTONS grant-backfill holatidan mustaqil, chunki bu
  --                  ikkalasi ham grant mavjudligiga bog'liq emas).
  --   ENFORCE      - yuqoridagilarga qo'shimcha MAPPED_DENIED va NO_USER_CTX'ni ham bloklaydi -
  --                  to'liq enforcement, ADM_REL_USER_BUTTONS'da grantlar to'liq backfill
  --                  qilingandan KEYINGINA qo'yilishi kerak (aks holda haqiqiy, ruxsatli
  --                  foydalanuvchilar noto'g'ri bloklanadi).
  --
  -- Bu konstanta ATAYLAB compile-time literal - ATAYLAB sozlamalar-jadvali (settings table)
  -- qatori EMAS: rejimni almashtirish deploy huquqini (paketni qayta kompilyatsiya qilish
  -- huquqi) talab qiladi, bu maqsadli nazorat nuqtasi. Jadval-asosidagi kalit bo'lganida, u
  -- yozilishi mumkin bo'lgan qo'shimcha sirt (writable surface) bo'lib qolardi - shu sirt
  -- buzilsa (masalan SQL-injection yoki ADM_USERS orqali ruxsatsiz DML), guard tashqi hujum
  -- yuzasi ORQALI o'chirilishi mumkin bo'lardi; compile-time konstantada bunday yo'l yo'q.
  --
  -- LOG'dan tashqariga (ENFORCE_DOOR yoki ENFORCE'ga) o'tishning UCH shart-gate'i bor -
  -- Core_Api.pck'dagi Check_Process_Access sarlavha izohiga qarang (cross-reference, shu
  -- yerda takrorlanmaydi): (1) LOG-bosqichda CORE_PROCESS_ACCESS_LOG orqali yetarli tarixiy
  -- trafik tahlil qilingan bo'lishi, (2) ENFORCE uchun qo'shimcha - ADM_REL_USER_BUTTONS'da
  -- grantlar to'liq backfill qilingan bo'lishi, (3) mavjud Core_Users.Debug='Y' qatorlar
  -- AUDIT qilingan bo'lishi.
  --
  -- 2026-08-04: qo'lda tekshirildi - Debug='Y' bo'lgan yagona qator user_id=1 ("test user",
  -- registratsiyadan buyon test-account, ishlab chiqarish useri emas). SUPER_USER (-1) va
  -- boshqa hech bir haqiqiy userda Debug='Y' yo'q. Shu holatda ENFORCE'ga o'tish xavfsiz deb
  -- topildi (lead tasdig'i bilan) - DEBUG_USER (-100) sentinel hali yaratilmagan bo'lsa ham,
  -- yagona bypass qiluvchi qator aniq test-account, "tushuntirilmagan" emas.
  c_Guard_Mode_Log          constant varchar2(15) := 'LOG';
  c_Guard_Mode_Enforce_Door constant varchar2(15) := 'ENFORCE_DOOR';  -- faqat WRONG_DOOR_TYPE + GUARD_ERROR bloklaydi
  c_Guard_Mode_Enforce      constant varchar2(15) := 'ENFORCE';       -- + MAPPED_DENIED + NO_USER_CTX ham bloklaydi
  c_Process_Guard_Mode      constant varchar2(15) := c_Guard_Mode_Enforce;
  -- log actions (history _H tables): merged from former Adm_Const
  c_Log_Insert constant varchar2(1) := 'I';
  c_Log_Update constant varchar2(1) := 'U';
  c_Log_Delete constant varchar2(1) := 'D';
  --
  c_Sum_Format_tiyn constant varchar2(100) := 'FM999G999G999G999G999D00';
  Function Get_State_Active return varchar2;
  Function Get_Sum_Format_Tiyn return varchar2;
end Core_Const;
/
create or replace package body Core_Const is
  Function Get_State_Active return varchar2 is
  begin
    return c_State_Active;
  end;
  Function Get_Sum_Format_Tiyn return varchar2 is
  begin
    return c_Sum_Format_tiyn;
  end;
end Core_Const;
/
