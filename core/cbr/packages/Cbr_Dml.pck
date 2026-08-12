create or replace package Cbr_Dml is

  -- Author  : YASHNAR
  -- Created : 10.04.2026 10:49:40
  -- Purpose :

  Procedure Set_Ref_16(i_Row in cbr_Region%rowtype);
  --
  Procedure Set_Ref_17(i_Row in cbr_Currency%rowtype);
  --
  Procedure Set_Ref_52(i_Row in cbr_District%rowtype);
  --
  Procedure Set_Ref_18(i_Row in cbr_Country%rowtype);
  --
  Procedure Set_Ref_38(i_Row in cbr_Credit_Source%rowtype);
  --
  Procedure Set_Ref_41(i_Row in cbr_Foreign_Organization%rowtype);
  --
  Procedure Set_Ref_47(i_Row in cbr_Bank_Corr%rowtype);
  --
  Procedure Set_Ref_29(i_Row in cbr_Budget_Accounts%rowtype);
  --
  Procedure Set_Ref_93(i_Row in cbr_Business_Form%rowtype);
  --
  Procedure Set_Ref_13(i_Row in cbr_Oked%rowtype);
  --
  Procedure Set_Ref_6(i_Row in cbr_Subject_Type%rowtype);
  --
  Procedure Set_Ref_7(i_Row in cbr_Subject_Sexual_Identity%rowtype);
  --
  Procedure Set_Ref_8(i_Row in cbr_Verifying_Document_Type%rowtype);
  --
  Procedure Set_Ref_12(i_Row in cbr_Bank%rowtype);
  --
  Procedure Set_Ref_14(i_Row in cbr_Bank_Type%rowtype);
  --
  Procedure Set_Ref_26(i_Row in cbr_Document%rowtype);
  --
  Procedure Set_Ref_27(i_Row in cbr_Rez_Cl%rowtype);
  --
  Procedure Set_Ref_54(i_Row in cbr_Tax_Organization%rowtype);
  --
  Procedure Set_Ref_57(i_Row in cbr_Form_Property%rowtype);
  --
  Procedure Set_Ref_63(i_Row in cbr_Organization_Legal_Form%rowtype);
  --
  Procedure Set_Ref_72(i_Row in cbr_Nation%rowtype);
  --
  Procedure Set_Ref_74(i_Row in cbr_Obraz%rowtype);
  --
  Procedure Set_Ref_92(i_Row in cbr_Coato%rowtype);
  --
  Procedure Set_Ref_125(i_Row in cbr_Mahalla%rowtype);

end Cbr_Dml;
/
create or replace package body Cbr_Dml is
  --
  Procedure Set_Ref_16(i_Row in cbr_Region%rowtype) is
    v_Row cbr_Region%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Region t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Region
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_17(i_Row in cbr_Currency%rowtype) is
    v_Row cbr_Currency%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Currency t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Currency
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_52(i_Row in cbr_District%rowtype) is
    v_Row cbr_District%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_District t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_District
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_18(i_Row in cbr_Country%rowtype) is
    v_Row cbr_Country%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Country t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Country
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_41(i_Row in cbr_Foreign_Organization%rowtype) is
    v_Row cbr_Foreign_Organization%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Foreign_Organization t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Foreign_Organization
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_38(i_Row in cbr_Credit_Source%rowtype) is
    v_Row cbr_Credit_Source%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Credit_Source t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Credit_Source
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_47(i_Row in cbr_Bank_Corr%rowtype) is
    v_Row cbr_Bank_Corr%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank_Corr t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Bank_Corr
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_29(i_Row in cbr_Budget_Accounts%rowtype) is
    v_Row cbr_Budget_Accounts%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Budget_Accounts t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Budget_Accounts
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_93(i_Row in cbr_Business_Form%rowtype) is
    v_Row cbr_Business_Form%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Business_Form t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Business_Form
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_13(i_Row in cbr_Oked%rowtype) is
    v_Row cbr_Oked%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Oked t
       set row = v_Row
     where t.Code = v_Row.Code;
    --
    if sql%rowcount = 0 then
      insert into cbr_Oked
      values v_Row;
    end if;
  end;
  --------------------------------------------------------------------------------------------------
  -- 19 talikning yangi 14 tasi
  --------------------------------------------------------------------------------------------------
  Procedure Set_Ref_6(i_Row in cbr_Subject_Type%rowtype) is
    v_Row cbr_Subject_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Subject_Type t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Subject_Type
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_7(i_Row in cbr_Subject_Sexual_Identity%rowtype) is
    v_Row cbr_Subject_Sexual_Identity%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Subject_Sexual_Identity t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Subject_Sexual_Identity
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_8(i_Row in cbr_Verifying_Document_Type%rowtype) is
    v_Row cbr_Verifying_Document_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Verifying_Document_Type t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Verifying_Document_Type
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_12(i_Row in cbr_Bank%rowtype) is
    v_Row cbr_Bank%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Bank
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_14(i_Row in cbr_Bank_Type%rowtype) is
    v_Row cbr_Bank_Type%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Bank_Type t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Bank_Type
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_26(i_Row in cbr_Document%rowtype) is
    v_Row cbr_Document%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Document t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Document
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_27(i_Row in cbr_Rez_Cl%rowtype) is
    v_Row cbr_Rez_Cl%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Rez_Cl t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Rez_Cl
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_54(i_Row in cbr_Tax_Organization%rowtype) is
    v_Row cbr_Tax_Organization%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Tax_Organization t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Tax_Organization
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_57(i_Row in cbr_Form_Property%rowtype) is
    v_Row cbr_Form_Property%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Form_Property t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Form_Property
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_63(i_Row in cbr_Organization_Legal_Form%rowtype) is
    v_Row cbr_Organization_Legal_Form%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Organization_Legal_Form t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Organization_Legal_Form
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_72(i_Row in cbr_Nation%rowtype) is
    v_Row cbr_Nation%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Nation t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Nation
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_74(i_Row in cbr_Obraz%rowtype) is
    v_Row cbr_Obraz%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Obraz t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Obraz
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_92(i_Row in cbr_Coato%rowtype) is
    v_Row cbr_Coato%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Coato t
       set row = v_Row
     where t.Code = v_Row.Code;
    if sql%rowcount = 0 then
      insert into cbr_Coato
      values v_Row;
    end if;
  end;
  --
  Procedure Set_Ref_125(i_Row in cbr_Mahalla%rowtype) is
    v_Row cbr_Mahalla%rowtype := i_Row;
  begin
    v_Row.Modify_On := sysdate;
    update cbr_Mahalla t
       set row = v_Row
     where t.Code_Uz_Cad = v_Row.Code_Uz_Cad;
    if sql%rowcount = 0 then
      insert into cbr_Mahalla
      values v_Row;
    end if;
  end;

end Cbr_Dml;
/
