----------------------------------------------------------------------------------------------------
-- Foydalanuvchining biror local_code'ga (filial) dostupi bor-yo'qligini tekshiradi.
--
-- Oddiy foydalanuvchi (Auth_Session.Create_Session orqali kirgan) va Set_System_Actor -
-- ADM_REL_USER_LOCALS jadvalidagi haqiqiy grant qatoriga qaraydi (state='A',
-- sysdate date_activate/date_deactivate oralig'ida).
--
-- Auth_Session.Open_Debug_Session / Open_Job_Actor esa grant jadvaliga umuman
-- tegmaydi - ular 'local_access_mode' kontekst atributi orqali maxsus rejimda
-- ishlaydi:
--   LOCAL - faqat kontekstdagi bitta local_code'ga dostup
--   CB    - kontekstdagi cb_code ostidagi barcha locallarga dostup (Abs_Branches orqali)
--   FULL  - istalgan local_code'ga dostup (cheklovsiz - hech narsa berilmagan debug/job)
--
-- Kontekst yo'q yoki i_Local_Code bo'sh bo'lsa - fail-closed, 'N'.
----------------------------------------------------------------------------------------------------
create or replace package Core_Locals is
  Function Has_Local_Access(i_Local_Code in varchar2) return varchar2;
  Procedure Assert_Local_Access(i_Local_Code in varchar2);
end Core_Locals;
/
create or replace package body Core_Locals is
  ----------------------------------------------------------------------------------------------------
  Function Has_Local_Access(i_Local_Code in varchar2) return varchar2 is
    v_Mode    varchar2(10) := Sys_Context('UAPP', 'local_access_mode');
    v_User_Id number := Core.User_Env.Get_User_Id;
    v_Result  varchar2(1);
  begin
    if i_Local_Code is null or v_User_Id is null then
      return 'N';
    end if;
    --
    if v_Mode = 'FULL' then
      return 'Y';
    elsif v_Mode = 'CB' then
      select Nvl(Max('Y'), 'N')
        into v_Result
        from Abs_Branches
       where Local_Code = i_Local_Code
         and Cb_Code = Sys_Context('UAPP', 'cb_code')
         and Condition = 'A';
      return v_Result;
    elsif v_Mode = 'LOCAL' then
      return case
               when i_Local_Code = Sys_Context('UAPP', 'local_code') then 'Y'
               else 'N'
             end;
    else
      select Nvl(Max('Y'), 'N')
        into v_Result
        from ADM_REL_USER_LOCALS
       where user_id = v_User_Id
         and local_code = i_Local_Code
         and state = 'A'
         and sysdate between date_activate and date_deactivate;
      return v_Result;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Assert_Local_Access(i_Local_Code in varchar2) is
  begin
    if Has_Local_Access(i_Local_Code) != 'Y' then
      Raise_Application_Error(-20060, 'Bu local_code uchun ruxsat yo''q: ' || i_Local_Code);
    end if;
  end;
end Core_Locals;
/
