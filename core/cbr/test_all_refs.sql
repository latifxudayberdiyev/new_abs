----------------------------------------------------------------------------------------------------
--  Barcha 24 ta spravochnikni ESB orqali sinash (Ref_Kernel.Get_Reference_Cb).
--  Ishga tushirish: F8 (Execute as Script). Natija Output oynasida chiqadi.
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited
set feedback off pagesize 0 verify off echo off linesize 500

declare
  o_Code number;
  o_Msg  varchar2(4000);
  type t_ids is table of number;
  v_ids t_ids := t_ids(16,17,52,18,38,41,47,29,93,13,6,7,8,12,14,26,27,54,57,63,72,74,92,125);
begin
  for i in 1 .. v_ids.count loop
    begin
      o_Code := null;
      o_Msg  := null;
      Ref_Kernel.Get_Reference_Cb(v_ids(i), o_Code, o_Msg);
      Dbms_Output.Put_Line('REF_ID=' || v_ids(i) || ' CODE=' || o_Code || ' MSG=' || substr(o_Msg,1,200));
    exception
      when others then
        Dbms_Output.Put_Line('REF_ID=' || v_ids(i) || ' EXCEPTION: ' || sqlerrm);
    end;
  end loop;
  commit;
end;
/

prompt =====================================================================
prompt Har bir jadvaldagi qatorlar soni:
select 'r_Region: ' || count(*) from r_Region
union all select 'r_Currency: ' || count(*) from r_Currency
union all select 'r_District: ' || count(*) from r_District
union all select 'r_Country: ' || count(*) from r_Country
union all select 'r_Credit_Source: ' || count(*) from r_Credit_Source
union all select 'r_Foreign_Organization: ' || count(*) from r_Foreign_Organization
union all select 'r_Bank_Corr: ' || count(*) from r_Bank_Corr
union all select 'r_Budget_Accounts: ' || count(*) from r_Budget_Accounts
union all select 'r_Business_Form: ' || count(*) from r_Business_Form
union all select 'r_Oked: ' || count(*) from r_Oked
union all select 'r_Subject_Type: ' || count(*) from r_Subject_Type
union all select 'r_Subject_Sexual_Identity: ' || count(*) from r_Subject_Sexual_Identity
union all select 'r_Verifying_Document_Type: ' || count(*) from r_Verifying_Document_Type
union all select 'r_Bank: ' || count(*) from r_Bank
union all select 'r_Bank_Type: ' || count(*) from r_Bank_Type
union all select 'r_Document: ' || count(*) from r_Document
union all select 'r_Rez_Cl: ' || count(*) from r_Rez_Cl
union all select 'r_Tax_Organization: ' || count(*) from r_Tax_Organization
union all select 'r_Form_Property: ' || count(*) from r_Form_Property
union all select 'r_Organization_Legal_Form: ' || count(*) from r_Organization_Legal_Form
union all select 'r_Nation: ' || count(*) from r_Nation
union all select 'r_Obraz: ' || count(*) from r_Obraz
union all select 'r_Coato: ' || count(*) from r_Coato
union all select 'r_Mahalla: ' || count(*) from r_Mahalla;
