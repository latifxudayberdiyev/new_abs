create or replace package Core_Job_Kernel is
  -- Author  : ABDUQODIR
  -- Created : 14.04.2026 15:37:31
  -- Purpose : 
  ----------------------------------------------------------------------------------------------------
  Procedure Load_Core_Branches
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Load_Core_r_Org_Units
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
end Core_Job_Kernel;
/
create or replace package body Core_Job_Kernel is
  ----------------------------------------------------------------------------------------------------
  Procedure Load_Core_Branches
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Method_Code varchar2(50) := 'GET_REF_CORE_BRANCHES';
    v_Esbo_Req    Hash_t := Hash_t();
    v_Esbo_Res    Hash_t := Hash_t();
    v_Page_Number number(4) := 1;
    v_Page_Size   number(6) := 20;
    v_List        Arraylist := Arraylist();
    v_Row         Abs_Branches%rowtype;
  begin
    o_Code := Sm_Const.c_Success_Code;
    while 1 = 1
    loop
      v_Esbo_Req.Put('method_code', v_Method_Code);
      v_Esbo_Req.Put('page_number', v_Page_Number);
      v_Esbo_Req.Put('page_size', v_Page_Size);
      --
      Io_Hash.Put('esbo_request', v_Esbo_Req);
      --
      Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                  o_Code    => o_Code,
                                  o_Msg     => o_Msg,
                                  o_Ora_Msg => o_Ora_Msg);
      --
      if o_Code != Sm_Const.c_Success_Code then
        return;
      end if;
      --
      v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
      --
      v_List := v_Esbo_Res.Get_Optional_Arraylist('list');
      --
      for i in 1 .. v_List.Count
      loop
        begin
          v_Esbo_Res := Treat(v_List.Get_r_Hash_t(i) as Hash_t);
          --
          v_Row.Code            := v_Esbo_Res.Get_Optional_Varchar2('code');
          v_Row.Cb_Code         := v_Esbo_Res.Get_Optional_Varchar2('cb_code');
          v_Row.Code_Type       := v_Esbo_Res.Get_Optional_Number('code_type');
          v_Row.Code_Header     := v_Esbo_Res.Get_Optional_Varchar2('code_header');
          v_Row.Code_Bank       := v_Esbo_Res.Get_Optional_Varchar2('code_bank');
          v_Row.Local_Code      := v_Esbo_Res.Get_Optional_Varchar2('local_code');
          v_Row.Filial_Code     := v_Esbo_Res.Get_Optional_Varchar2('filial_code');
          v_Row.Branch_Id       := v_Esbo_Res.Get_Optional_Number('branch_id');
          v_Row.Name            := v_Esbo_Res.Get_Optional_Varchar2('name');
          v_Row.Filial_Number   := v_Esbo_Res.Get_Optional_Varchar2('filial_number');
          v_Row.Condition       := v_Esbo_Res.Get_Optional_Varchar2('condition');
          v_Row.Date_Activ      := v_Esbo_Res.Get_Optional_Date('date_activ', 'dd.mm.yyyy');
          v_Row.Date_Deact      := v_Esbo_Res.Get_Optional_Date('date_deact', 'dd.mm.yyyy');
          v_Row.Code_District   := v_Esbo_Res.Get_Optional_Varchar2('code_district');
          v_Row.Address         := v_Esbo_Res.Get_Optional_Varchar2('address');
          v_Row.City            := v_Esbo_Res.Get_Optional_Varchar2('city');
          v_Row.Has_Balance     := v_Esbo_Res.Get_Optional_Varchar2('has_balance');
          v_Row.Union_Code      := v_Esbo_Res.Get_Optional_Varchar2('union_code');
          v_Row.Date_Open       := v_Esbo_Res.Get_Optional_Date('date_open', 'dd.mm.yyyy');
          v_Row.Region_Code     := v_Esbo_Res.Get_Optional_Varchar2('region_code');
          v_Row.Branch_Uid      := v_Esbo_Res.Get_Optional_Number('branch_uid');
          v_Row.Activate_Date   := v_Esbo_Res.Get_Optional_Date('activate_date', 'dd.mm.yyyy');
          v_Row.Deactivate_Date := v_Esbo_Res.Get_Optional_Date('deactivate_date', 'dd.mm.yyyy');
          --
          Core_Dml.Sync_Branches(v_Row);
          --
          commit;
        exception
          when others then
            Dbms_Output.Put_Line(v_Row.Code || ' ' || sqlerrm || Chr(13) ||
                                 Dbms_Utility.Format_Error_Backtrace);
            --
            rollback;
        end;
      end loop;
      --
      if v_List.Count >= v_Page_Size then
        v_Page_Number := v_Page_Number + 1;
      else
        exit;
      end if;
    end loop;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Load_Core_r_Org_Units
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Method_Code varchar2(50) := 'GET_REF_CORE_R_ORG_UNITS';
    v_Esbo_Req    Hash_t := Hash_t();
    v_Esbo_Res    Hash_t := Hash_t();
    v_Page_Number number(4) := 1;
    v_Page_Size   number(6) := 20;
    v_List        Arraylist := Arraylist();
    v_Row         Abs_r_Org_Units%rowtype;
  begin
    o_Code := Sm_Const.c_Success_Code;
    --
    v_Esbo_Req.Put('method_code', v_Method_Code);
    v_Esbo_Req.Put('page_number', v_Page_Number);
    v_Esbo_Req.Put('page_size', v_Page_Size);
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
    --
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    --
    v_Esbo_Res := Io_Hash.Get_Optional_Hash_t('esbo_response');
    v_List     := v_Esbo_Res.Get_Optional_Arraylist('list');
    --
    for i in 1 .. v_List.Count
    loop
      begin
        v_Esbo_Res := Treat(v_List.Get_r_Hash_t(i) as Hash_t);
        --
        v_Row.Org_Unit_Id      := v_Esbo_Res.Get_Optional_Number('org_unit_id');
        v_Row.Org_Unit_Name    := v_Esbo_Res.Get_Optional_Varchar2('org_unit_name');
        v_Row.Label            := v_Esbo_Res.Get_Optional_Varchar2('label');
        v_Row.Org_Unit_Level   := v_Esbo_Res.Get_Optional_Number('org_unit_level');
        v_Row.Access_Level_Set := v_Esbo_Res.Get_Optional_Number('access_level_set');
        v_Row.State            := v_Esbo_Res.Get_Optional_Varchar2('state');
        v_Row.Activate_Date    := v_Esbo_Res.Get_Optional_Date('activate_date', 'dd.mm.yyyy');
        v_Row.Deactivate_Date  := v_Esbo_Res.Get_Optional_Date('deactivate_date', 'dd.mm.yyyy');
        v_Row.Description      := v_Esbo_Res.Get_Optional_Varchar2('description');
        v_Row.Type_Filial      := v_Esbo_Res.Get_Optional_Varchar2('type_filial');
        --
        Core_Dml.Sync_r_Org_Units(v_Row);
        --
        commit;
      exception
        when others then
          Dbms_Output.Put_Line(v_Row.Org_Unit_Id || ' ' || sqlerrm || Chr(13) ||
                               Dbms_Utility.Format_Error_Backtrace);
          --
          rollback;
      end;
    end loop;
  end;
  ----------------------------------------------------------------------------------------------------
end Core_Job_Kernel;
/
