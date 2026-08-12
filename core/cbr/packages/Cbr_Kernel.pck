create or replace package Cbr_Kernel is

  -- Author  : YASHNAR
  -- Created : 10.04.2026 10:05:42
  -- Purpose :

  Procedure Set_Ref_52(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_16(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_17(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_18(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_38(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_41(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_47(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_29(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_93(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_13(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  -- 19 talikning yangi 14 tasi
  -----------------------------------------------
  Procedure Set_Ref_6(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_7(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_8(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_12(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_14(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_26(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_27(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_54(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_57(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_63(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_72(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_74(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_92(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Set_Ref_125(i_Arr in Core.Array_Varchar2);
  -----------------------------------------------
  Procedure Get_Reference_Cb
  (
    i_Reference_Id in number,
    o_Code         out number,
    o_Msg          out varchar2,
    i_Page_Size    in number default 10
  );

end Cbr_Kernel;
/
create or replace package body Cbr_Kernel is

  ------------------------------------------------
  Function Get_Ref_Procedure_Name(i_Ref_Id in number) return varchar2 is
    result varchar2(200);
  begin
    select t.Procedure_Name
      into result
      from Cbr_r_Procedures t
     where t.Ref_Id = i_Ref_Id;
    return result;
  end;
  -----------------------------------------------
  Procedure Set_Ref_16(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Region%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Order_By   := i_Arr(3);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State      := i_Arr(6);
    Cbr_Dml.Set_Ref_16(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_17(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Currency%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Char_Code  := i_Arr(2);
    v_Row.Name       := i_Arr(3);
    v_Row.Scale      := i_Arr(4);
    v_Row.Scale_Name := i_Arr(5);
    v_Row.Hard       := i_Arr(6);
    v_Row.Allow      := i_Arr(7);
    v_Row.Date_Activ := to_date(i_Arr(8), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State      := i_Arr(10);
    Cbr_Dml.Set_Ref_17(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_52(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_District%rowtype;
  begin
    v_Row.Code        := i_Arr(1);
    v_Row.Name        := i_Arr(2);
    v_Row.Region_Code := i_Arr(3);
    v_Row.Date_Activ  := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.Date_Deact  := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State       := i_Arr(6);
    Cbr_Dml.Set_Ref_52(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_18(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Country%rowtype;
  begin
    v_Row.Code          := i_Arr(1);
    v_Row.Char_Code     := i_Arr(2);
    v_Row.Char_Ext_Code := i_Arr(3);
    v_Row.Name          := i_Arr(4);
    v_Row.Currency_Code := i_Arr(5);
    v_Row.In_Sng        := i_Arr(6);
    v_Row.Date_Activ    := to_date(i_Arr(7), 'dd.mm.rr');
    v_Row.Date_Deact    := to_date(i_Arr(8), 'dd.mm.rr');
    v_Row.State         := i_Arr(9);
    Cbr_Dml.Set_Ref_18(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_38(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Credit_Source%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Group_Code := i_Arr(3);
    v_Row.Date_Activ := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State      := i_Arr(6);
    Cbr_Dml.Set_Ref_38(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_41(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Foreign_Organization%rowtype;
  begin
    v_Row.Code               := i_Arr(1);
    v_Row.Credit_Source_Code := i_Arr(2);
    v_Row.Name               := i_Arr(3);
    v_Row.Label              := i_Arr(7);
    v_Row.Date_Activ         := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.Date_Deact         := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.State              := i_Arr(6);
    Cbr_Dml.Set_Ref_41(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_47(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank_Corr%rowtype;
  begin
    v_Row.Code         := i_Arr(1);
    v_Row.Swift_Code   := i_Arr(2);
    v_Row.Name         := i_Arr(3);
    v_Row.Country_Code := i_Arr(4);
    v_Row.Date_Activ   := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.Date_Deact   := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State        := i_Arr(7);
    Cbr_Dml.Set_Ref_47(i_Row => v_Row);
  end;
  ----------------------------------------------
  Procedure Set_Ref_29(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Budget_Accounts%rowtype;
  begin
    v_Row.Code         := i_Arr(1);
    v_Row.Account_Code := i_Arr(2);
    v_Row.Inn          := i_Arr(3);
    v_Row.Name         := i_Arr(4);
    v_Row.Date_Activ   := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.Date_Deact   := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State        := i_Arr(7);
    Cbr_Dml.Set_Ref_29(i_Row => v_Row);
  end;
  ---------------------------------------------
  Procedure Set_Ref_93(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Business_Form%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name_Rus   := i_Arr(2);
    v_Row.Name_Uzb   := i_Arr(3);
    v_Row.Group_Code := i_Arr(4);
    v_Row.Date_Activ := to_date(i_Arr(5), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.State      := i_Arr(7);
    Cbr_Dml.Set_Ref_93(i_Row => v_Row);
  end;
  --------------------------------------------
  Procedure Set_Ref_13(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Oked%rowtype;
  begin
    v_Row.Sction_Gr       := i_Arr(1);
    v_Row.Section_Sy      := i_Arr(2);
    v_Row.Sg_Name_Ru      := i_Arr(3);
    v_Row.Sg_Name_Uz      := i_Arr(4);
    v_Row.Section_Code    := i_Arr(5);
    v_Row.Section_Name_Ru := i_Arr(6);
    v_Row.Section_Name_Uz := i_Arr(7);
    v_Row.Group_Code      := i_Arr(8);
    v_Row.Group_Name_Ru   := i_Arr(9);
    v_Row.Group_Name_Uz   := i_Arr(10);
    v_Row.Class_Code      := i_Arr(11);
    v_Row.Class_Name_Ru   := i_Arr(12);
    v_Row.Class_Name_Uz   := i_Arr(13);
    v_Row.Code            := i_Arr(14);
    v_Row.Name_Ru         := i_Arr(15);
    v_Row.Name_Uz         := i_Arr(16);
    v_Row.Date_Activ      := to_date(i_Arr(17), 'dd.mm.rr');
    v_Row.Date_Deact      := to_date(i_Arr(18), 'dd.mm.rr');
    v_Row.State           := i_Arr(19);
    Cbr_Dml.Set_Ref_13(i_Row => v_Row);
  end;
  --------------------------------------------------------------------------------------------------
  -- 19 talikning yangi 14 tasi
  -- E'TIBOR: i_Arr tartibi IBS@TEST manba jadval tuzilishidan taxmin qilingan (mavjud namunalardagi
  -- "oxirida Date_Activ, Date_Deact, State" konventsiyasiga asosan). ESB haqiqiy javobi bilan
  -- solishtirib tasdiqlash kerak.
  --------------------------------------------------------------------------------------------------
  Procedure Set_Ref_6(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Subject_Type%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State      := i_Arr(5);
    v_Row.Name_Uz    := i_Arr(6);
    Cbr_Dml.Set_Ref_6(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_7(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Subject_Sexual_Identity%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State      := i_Arr(5);
    Cbr_Dml.Set_Ref_7(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_8(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Verifying_Document_Type%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State      := i_Arr(5);
    Cbr_Dml.Set_Ref_8(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_12(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank%rowtype;
  begin
    v_Row.Code              := i_Arr(1);
    v_Row.Bank_Type_Code    := i_Arr(2);
    v_Row.Region_Code       := i_Arr(3);
    v_Row.Header_Code       := i_Arr(4);
    v_Row.Union_Code        := i_Arr(5);
    v_Row.Tcr_Code          := i_Arr(6);
    v_Row.Rkc_Code          := i_Arr(7);
    v_Row.Name              := i_Arr(8);
    v_Row.Adress            := i_Arr(9);
    v_Row.Status_Code       := i_Arr(10);
    v_Row.Account_Type      := i_Arr(11);
    v_Row.Date_Open         := to_date(i_Arr(12), 'dd.mm.rr');
    v_Row.Date_Close        := to_date(i_Arr(13), 'dd.mm.rr');
    v_Row.Active            := i_Arr(14);
    v_Row.Email             := i_Arr(15);
    v_Row.Server_Alias      := i_Arr(16);
    v_Row.Connect_Type      := i_Arr(17);
    v_Row.Allow_Currency    := i_Arr(18);
    v_Row.Date_Activ        := to_date(i_Arr(19), 'dd.mm.rr');
    v_Row.Date_Deact        := to_date(i_Arr(20), 'dd.mm.rr');
    v_Row.District_Code     := i_Arr(21);
    v_Row.Num_Change_Office := i_Arr(22);
    v_Row.State             := i_Arr(23);
    Cbr_Dml.Set_Ref_12(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_14(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Bank_Type%rowtype;
  begin
    v_Row.Code         := i_Arr(1);
    v_Row.Name         := i_Arr(2);
    v_Row.Short_Name   := i_Arr(3);
    v_Row.Country_Code := i_Arr(4);
    v_Row.Account_Type := i_Arr(5);
    v_Row.Date_Open    := to_date(i_Arr(6), 'dd.mm.rr');
    v_Row.Date_Close   := to_date(i_Arr(7), 'dd.mm.rr');
    v_Row.Date_Activ   := to_date(i_Arr(8), 'dd.mm.rr');
    v_Row.Date_Deact   := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State        := i_Arr(10);
    Cbr_Dml.Set_Ref_14(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_26(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Document%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State      := i_Arr(5);
    Cbr_Dml.Set_Ref_26(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_27(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Rez_Cl%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State      := i_Arr(5);
    Cbr_Dml.Set_Ref_27(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_54(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Tax_Organization%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State      := i_Arr(5);
    Cbr_Dml.Set_Ref_54(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_57(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Form_Property%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.Active     := i_Arr(5);
    v_Row.State      := i_Arr(6);
    Cbr_Dml.Set_Ref_57(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_63(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Organization_Legal_Form%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Name       := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State      := i_Arr(5);
    Cbr_Dml.Set_Ref_63(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_72(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Nation%rowtype;
  begin
    v_Row.Code        := i_Arr(1);
    v_Row.Nation_Name := i_Arr(2);
    v_Row.Date_Activ  := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact  := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State       := i_Arr(5);
    Cbr_Dml.Set_Ref_72(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_74(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Obraz%rowtype;
  begin
    v_Row.Code       := i_Arr(1);
    v_Row.Obraz_Name := i_Arr(2);
    v_Row.Date_Activ := to_date(i_Arr(3), 'dd.mm.rr');
    v_Row.Date_Deact := to_date(i_Arr(4), 'dd.mm.rr');
    v_Row.State      := i_Arr(5);
    Cbr_Dml.Set_Ref_74(i_Row => v_Row);
  end;
  -----------------------------------------------
  Procedure Set_Ref_92(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Coato%rowtype;
  begin
    v_Row.Code              := i_Arr(1);
    v_Row.District_Code     := i_Arr(2);
    v_Row.District_Tax_Code := i_Arr(3);
    v_Row.Region_Code       := i_Arr(4);
    v_Row.Rus_Name          := i_Arr(5);
    v_Row.Uzb_Cyr_Name      := i_Arr(6);
    v_Row.Uzb_Lat_Name      := i_Arr(7);
    v_Row.Date_Activ        := to_date(i_Arr(8), 'dd.mm.rr');
    v_Row.Date_Deact        := to_date(i_Arr(9), 'dd.mm.rr');
    v_Row.State             := i_Arr(10);
    Cbr_Dml.Set_Ref_92(i_Row => v_Row);
  end;
  -----------------------------------------------
  -- Mahalla: manbada Date_Activ/Date_Deact/State tushunchasi yo'q, o'rniga Date_Open/Date_Close/Active
  Procedure Set_Ref_125(i_Arr in Core.Array_Varchar2) is
    v_Row cbr_Mahalla%rowtype;
  begin
    v_Row.Code_Uz_Cad := i_Arr(1);
    v_Row.Code_1c     := i_Arr(2);
    v_Row.Inn         := i_Arr(3);
    v_Row.Region_Id   := i_Arr(4);
    v_Row.Soato_Id    := i_Arr(5);
    v_Row.Distr       := i_Arr(6);
    v_Row.Name_Uz     := i_Arr(7);
    v_Row.Name_Ru     := i_Arr(8);
    v_Row.Name_En     := i_Arr(9);
    v_Row.Date_Open   := to_date(i_Arr(10), 'dd.mm.rr');
    v_Row.Date_Close  := to_date(i_Arr(11), 'dd.mm.rr');
    v_Row.Active      := i_Arr(12);
    Cbr_Dml.Set_Ref_125(i_Row => v_Row);
  end;
  -------------------------------------------
  Procedure Call_Reference
  (
    i_Arr    in Core.Array_Varchar2,
    i_Ref_Id in number
  ) is
    v_Procedure_Name varchar2(200);
    v_Sql_Stm        varchar2(3000);
  begin
    v_Procedure_Name := Get_Ref_Procedure_Name(i_Ref_Id);
    v_Sql_Stm        := 'begin ' || v_Procedure_Name || '(:1); end;';
    execute immediate v_Sql_Stm
      using in i_Arr;
  end;
  -------------------------------------------
  Procedure Get_Reference_Cb
  (
    i_Reference_Id in number,
    o_Code         out number,
    o_Msg          out varchar2,
    i_Page_Size    in number default 10
  ) is
    Io_Hash         Core.Hash_t := Core.Hash_t();
    v_Req           Core.Hash_t := Core.Hash_t();
    v_Response_Hash Core.Hash_t := Core.Hash_t();
    v_Page_Number   number := 1;
    v_Page_Size     number := nvl(i_Page_Size, 10);
    v_Data_List     Core.Arraylist := Core.Arraylist();
    v_Detail_Arr    Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Ora_Msg       varchar2(4000);
  begin
    o_Code := Core_Const.c_Success_Code;
    o_Msg  := null;

    loop
      Io_Hash := Core.Hash_t();
      v_Req   := Core.Hash_t();

      v_Req.Put('service_code', 'FB_ESB');
      v_Req.Put('method_code', '1');
      v_Req.Put('referenceId', to_char(i_Reference_Id));
      v_Req.Put('pageSize', to_char(v_Page_Size));
      v_Req.Put('page', to_char(v_Page_Number));

      Io_Hash.Put('esbo_request', v_Req);

      Esbo_Kernel.Universal_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => v_Ora_Msg);

      if o_Code != Core_Const.c_Success_Code then
        o_Msg := o_Msg || ' ' || v_Ora_Msg;
        return;
      end if;

      v_Response_Hash := Io_Hash.Get_Optional_Hash_t('esbo_response');
      v_Data_List     := v_Response_Hash.Get_Optional_Arraylist('data');

      if v_Data_List is null or v_Data_List.Count = 0 then
        exit;
      end if;

      for i in 1 .. v_Data_List.Count
      loop
        v_Detail_Arr := v_Data_List.Get_r_Array_Varchar2(i);
        Call_Reference(v_Detail_Arr, i_Reference_Id);
      end loop;

      if v_Data_List.Count < v_Page_Size then
        exit;
      end if;

      v_Page_Number := v_Page_Number + 1;
    end loop;

  exception
    when others then
      o_Code := -999;
      o_Msg  := 'System error ' || sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  --
end Cbr_Kernel;
/
