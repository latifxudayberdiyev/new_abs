--------------------------------------------------------------------------------
-- "Хисоб рақамлар" (ACC_ACCOUNTS) menyusini "Тип счёта" guruhi (MENU_ID=7000)
-- tagiga sibling sifatida qo'shish. MUHIM: CORE_R_MENUS.MODULE_CODE va
-- MLL_LABEL_CODES.MODULE_CODE aynan bir xil ('ACC') bo'lishi shart, aks holda
-- "<code> ni MLL ga qushing!!!" xatosi chiqadi.
-- MUHIM: kompilyatsiyadan oldin NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating.
--------------------------------------------------------------------------------
SET DEFINE OFF
SET SERVEROUTPUT ON

DECLARE
  o_Code Number;
  o_Msg  Varchar2(4000);
BEGIN
  Mll_Dev_Api.Save_Label_With_Template_Dev(
    i_Message_Code       => 'ACC_MENU_ACCOUNTS',
    i_Description        => 'ACC moduli - Хисоб рақамлар ro''yxati menyu punkti',
    i_Param_Count        => 0,
    i_Message_Mask_Lang1 => 'Счета клиентов',
    i_Message_Mask_Lang2 => 'Мижоз ҳисоблари',
    i_Message_Mask_Lang3 => 'Hisob raqamlar',
    i_Message_Mask_Lang4 => 'Accounts',
    i_Module_Code        => 'ACC',
    o_Code               => o_Code,
    o_Msg                => o_Msg);
  Dbms_Output.Put_Line('label o_Code=' || o_Code || ' o_Msg=' || o_Msg);
END;
/

INSERT INTO CORE_R_MENUS (MENU_ID, PARENT_MENU_ID, MODULE_CODE, NAME_MLL_CODE, PAGE_URL, ORDER_BY, STATE)
VALUES (7002, 7000, 'ACC', 'ACC_MENU_ACCOUNTS', '/ibs/acc/accounts.jsp', 2, 'A');

INSERT INTO ADM_REL_USER_MENUS (USER_ID, MENU_ID, DATE_ACTIVATE, DATE_DEACTIVATE, STATE, CREATED_BY, CREATED_ON, MODIFY_BY, MODIFY_ON)
VALUES (-1, 7002, TRUNC(SYSDATE), TO_DATE('31-12-9999','DD-MM-YYYY'), 'A', -1, SYSDATE, -1, SYSDATE);

COMMIT;
