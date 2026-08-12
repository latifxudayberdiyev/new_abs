SET SERVEROUTPUT ON

-- Faqat test ma'lumotlari: PF_PARAMETER ekranini sinash uchun bir nechta
-- EDITABLE atribut. Attribute CRUD keyinchalik hamkasb tomonidan PF_*
-- paketlarida yoziladi - shu sabab bu yerda faqat jadvalga to'g'ridan-to'g'ri
-- test qatorlari qo'shiladi, hech qanday Pf_Kernel/Pf_Dml protsedurasi yo'q.

DECLARE
  v_Id      number;
  v_Ml_Code number;
  v_Ml_Msg  varchar2(4000);
  v_Cnt     number;

  PROCEDURE Add_Test_Attribute(i_Code varchar2, i_Name varchar2, i_Sort number) IS
    v_Ml_Name_Code varchar2(100) := 'PF_ATTRIBUTE_' || i_Code;
  BEGIN
    SELECT Pf_Attribute_Sq.nextval INTO v_Id FROM dual;

    Mll_Dev_Api.Save_Label_With_Template_Dev
    (
      i_Message_Code        => v_Ml_Name_Code,
      i_Description         => 'PF_ATTRIBUTE nomi (test)',
      i_Param_Count         => 0,
      i_Format_String       => Mlt_Const.c_Default_Format_String,
      i_Message_Mask_Lang1  => i_Name,
      i_Message_Mask_Lang2  => i_Name,
      i_Message_Mask_Lang3  => i_Name,
      i_Message_Mask_Lang4  => i_Name,
      i_Message_Mask_Lang5  => null,
      i_Message_Mask_Lang6  => null,
      i_Message_Mask_Lang7  => null,
      i_Message_Mask_Lang8  => null,
      i_Message_Mask_Lang9  => null,
      i_Message_Mask_Lang10 => null,
      i_Module_Code         => 'PF',
      i_Field_Hint          => null,
      o_Code                => v_Ml_Code,
      o_Msg                 => v_Ml_Msg
    );

    IF v_Ml_Code IS NULL THEN
      Dbms_Output.Put_Line(i_Code || ' - ML xato: ' || v_Ml_Msg);
      RETURN;
    END IF;

    INSERT INTO Pf_Attribute (Id, Code, Ml_Name_Code, Source_Type, Module_Code, Sort_Order)
    VALUES (v_Id, i_Code, v_Ml_Name_Code, 'EDITABLE', null, i_Sort);

    Dbms_Output.Put_Line(i_Code || ' - OK, id=' || v_Id);
  END;
BEGIN
  SELECT count(*) INTO v_Cnt FROM Pf_Attribute WHERE Code = 'GENERAL';
  IF v_Cnt = 0 THEN
    Add_Test_Attribute('GENERAL', 'Umumiy', 10);
  END IF;

  SELECT count(*) INTO v_Cnt FROM Pf_Attribute WHERE Code = 'CONTROL';
  IF v_Cnt = 0 THEN
    Add_Test_Attribute('CONTROL', 'Nazorat', 20);
  END IF;

  SELECT count(*) INTO v_Cnt FROM Pf_Attribute WHERE Code = 'OTHER';
  IF v_Cnt = 0 THEN
    Add_Test_Attribute('OTHER', 'Boshqa', 30);
  END IF;

  COMMIT;
END;
/

PROMPT === verify ===
SELECT id, code, ml_name_code, source_type, sort_order FROM Pf_Attribute ORDER BY sort_order;
