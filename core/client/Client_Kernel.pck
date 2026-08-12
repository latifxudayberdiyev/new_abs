create or replace package Client_Kernel is

  -- Author  : B.URALOV
  -- Created : 23.04.2026 10:47:49
  -- Purpose : 
  Procedure Open_Physical_Client
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Get_Invidual_Client
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Get_Proprietor_Client
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Get_Entities_Client
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Client_Kernel;
/
create or replace package body Client_Kernel is
  Procedure Open_Physical_Client
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Method_Code varchar2(50) := 'OPEN_PHYSICAL_CLIENT';
    v_Client_Code varchar2(8);
    --v_Client_Id   number(10);
    v_Esbo_Req Hash_t := Hash_t();
    v_Esbo_Res Hash_t := Hash_t();
  begin
    o_Code := Sm_Const.c_Success_Code;
    --
    v_Esbo_Req.Put('method_code', v_Method_Code);
    v_Esbo_Req.Put('inn', Io_Hash.Get_Optional_Varchar2('inn'));
    v_Esbo_Req.Put('pnfl', Io_Hash.Get_Optional_Varchar2('pinfl'));
    v_Esbo_Req.Put('firstName', Io_Hash.Get_Optional_Varchar2('first_name'));
    v_Esbo_Req.Put('lastName', Io_Hash.Get_Optional_Varchar2('last_name'));
    v_Esbo_Req.Put('middleName', Io_Hash.Get_Optional_Varchar2('middle_name'));
    v_Esbo_Req.Put('birthDate', Io_Hash.Get_Optional_Varchar2('birth_date'));
    v_Esbo_Req.Put('birthPlace', Io_Hash.Get_Optional_Varchar2('birth_place'));
    v_Esbo_Req.Put('birthCountry', Io_Hash.Get_Optional_Varchar2('birth_country'));
    v_Esbo_Req.Put('gender', Io_Hash.Get_Optional_Varchar2('gender'));
    v_Esbo_Req.Put('citizenship', Io_Hash.Get_Optional_Varchar2('citizenship'));
    v_Esbo_Req.Put('docType', Io_Hash.Get_Optional_Varchar2('doc_type'));
    v_Esbo_Req.Put('series', Io_Hash.Get_Optional_Varchar2('series'));
    v_Esbo_Req.Put('number', Io_Hash.Get_Optional_Varchar2('number'));
    v_Esbo_Req.Put('docIssueDate', Io_Hash.Get_Optional_Varchar2('doc_issue_date'));
    v_Esbo_Req.Put('docExpireDate', Io_Hash.Get_Optional_Varchar2('doc_expire_date'));
    v_Esbo_Req.Put('docIssuePlace', Io_Hash.Get_Optional_Varchar2('doc_issue_place'));
    v_Esbo_Req.Put('residenceCountry', Io_Hash.Get_Optional_Varchar2('residence_country'));
    v_Esbo_Req.Put('codeFilial',
                   Nvl(Io_Hash.Get_Optional_Varchar2('filial_code'), Core_Const.c_Filial));
    v_Esbo_Req.Put('residenceRegion', Io_Hash.Get_Optional_Varchar2('residence_region'));
    v_Esbo_Req.Put('residenceDistrict', Io_Hash.Get_Optional_Varchar2('residence_district'));
    v_Esbo_Req.Put('residenceAddress', Io_Hash.Get_Optional_Varchar2('residence_address'));
    v_Esbo_Req.Put('phone', Io_Hash.Get_Optional_Varchar2('phone'));
    v_Esbo_Req.Put('mobilePhone', Io_Hash.Get_Optional_Varchar2('mobile_phone'));
    v_Esbo_Req.Put('email', Io_Hash.Get_Optional_Varchar2('email'));
    v_Esbo_Req.Put('maritalStatus', Io_Hash.Get_Optional_Varchar2('marital_status'));
    v_Esbo_Req.Put('bxmCode', Io_Hash.Get_Optional_Varchar2('cbu_code'));
    v_Esbo_Req.Put('villageCode', Io_Hash.Get_Optional_Varchar2('village_code'));
    v_Esbo_Req.Put('workArea', Io_Hash.Get_Optional_Varchar2('work_area'));
    v_Esbo_Req.Put('workRegion', Io_Hash.Get_Optional_Varchar2('work_region'));
    v_Esbo_Req.Put('workVillage', Io_Hash.Get_Optional_Varchar2('work_village'));
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    v_Esbo_Res    := Io_Hash.Get_Optional_Hash_t('esbo_response');
    v_Client_Code := v_Esbo_Res.Get_Optional_Varchar2('clientCode');
    --v_Client_Id   := v_Esbo_Res.Get_Optional_Number('clientId');
    --
    Io_Hash.Put('client_code', v_Client_Code);
    Client_Kernel.Get_Invidual_Client(Io_Hash   => Io_Hash,
                                      o_Code    => o_Code,
                                      o_Msg     => o_Msg,
                                      o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
  end;
  ----
  --
  ----
  Procedure Get_Invidual_Client
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Method_Code varchar2(50) := 'GET_PHYSICAL_INFO';
    v_Esbo_Req    Hash_t := Hash_t();
    v_Esbo_Res    Hash_t := Hash_t();
    v_Client_Row  Client_Individuals%rowtype;
  begin
    o_Code := Sm_Const.c_Success_Code;
    --
    v_Esbo_Req.Put('method_code', v_Method_Code);
    v_Esbo_Req.Put('client_code', Io_Hash.Get_Optional_Varchar2('client_code'));
    v_Esbo_Req.Put('inn', Io_Hash.Get_Optional_Varchar2('inn'));
    v_Esbo_Req.Put('pinfl', Io_Hash.Get_Optional_Varchar2('pinfl'));
    v_Esbo_Req.Put('doc_serial', Io_Hash.Get_Optional_Varchar2('doc_serial'));
    v_Esbo_Req.Put('doc_number', Io_Hash.Get_Optional_Varchar2('doc_number'));
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    v_Esbo_Res                   := Io_Hash.Get_Optional_Hash_t('esbo_response');
    v_Client_Row.Client_Code     := v_Esbo_Res.Get_Optional_Varchar2('client_code');
    v_Client_Row.Client_Id       := v_Esbo_Res.Get_Optional_Number('client_id');
    v_Client_Row.Client_Uid      := v_Esbo_Res.Get_Optional_Number('client_uid');
    v_Client_Row.Status          := v_Esbo_Res.Get_Optional_Varchar2('status');
    v_Client_Row.Surname         := v_Esbo_Res.Get_Optional_Varchar2('surname');
    v_Client_Row.First_Name      := v_Esbo_Res.Get_Optional_Varchar2('first_name');
    v_Client_Row.Patronymic      := v_Esbo_Res.Get_Optional_Varchar2('patronymic');
    v_Client_Row.Name            := v_Esbo_Res.Get_Optional_Varchar2('name');
    v_Client_Row.Birthday        := v_Esbo_Res.Get_Optional_Date('birthday');
    v_Client_Row.Pinfl           := v_Esbo_Res.Get_Optional_Varchar2('pinfl');
    v_Client_Row.Inn             := v_Esbo_Res.Get_Optional_Varchar2('inn');
    v_Client_Row.Passport_Serial := v_Esbo_Res.Get_Optional_Varchar2('passport_serial');
    v_Client_Row.Passport_Number := v_Esbo_Res.Get_Optional_Varchar2('passport_number');
    v_Client_Row.Mobile_Phone    := v_Esbo_Res.Get_Optional_Varchar2('mobile_phone');
    v_Client_Row.Operator_Code   := v_Esbo_Res.Get_Optional_Number('operator_code');
    v_Client_Row.Date_Open       := v_Esbo_Res.Get_Optional_Date('date_open');
    --
    Client_Dml.Set_Physical_Client(i_Row => v_Client_Row);
    --
    Client_Dml.Set_Client_Detail(i_Client_Code => v_Client_Row.Client_Code,
                                 i_Detail      => v_Esbo_Res.Json_Clob);
  end;
  ----
  --
  ----
  Procedure Get_Proprietor_Client
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Method_Code varchar2(50) := 'GET_PROPRIETOR_INFO';
    v_Esbo_Req    Hash_t := Hash_t();
    v_Esbo_Res    Hash_t := Hash_t();
    v_Client_Row  Client_Proprietors%rowtype;
  begin
    o_Code := Sm_Const.c_Success_Code;
    --
    v_Esbo_Req.Put('method_code', v_Method_Code);
    v_Esbo_Req.Put('client_code', Io_Hash.Get_Optional_Varchar2('client_code'));
    v_Esbo_Req.Put('inn', Io_Hash.Get_Optional_Varchar2('inn'));
    v_Esbo_Req.Put('pinfl', Io_Hash.Get_Optional_Varchar2('pinfl'));
    v_Esbo_Req.Put('doc_serial', Io_Hash.Get_Optional_Varchar2('doc_serial'));
    v_Esbo_Req.Put('doc_number', Io_Hash.Get_Optional_Varchar2('doc_number'));
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    v_Esbo_Res                       := Io_Hash.Get_Optional_Hash_t('esbo_response');
    v_Client_Row.Client_Code         := v_Esbo_Res.Get_Optional_Varchar2('client_code');
    v_Client_Row.Client_Id           := v_Esbo_Res.Get_Optional_Number('client_id');
    v_Client_Row.Client_Uid          := v_Esbo_Res.Get_Optional_Number('client_uid');
    v_Client_Row.Status              := v_Esbo_Res.Get_Optional_Varchar2('status');
    v_Client_Row.Segment_Code        := v_Esbo_Res.Get_Optional_Varchar2('segment_code');
    v_Client_Row.Surname             := v_Esbo_Res.Get_Optional_Varchar2('surname');
    v_Client_Row.First_Name          := v_Esbo_Res.Get_Optional_Varchar2('first_name');
    v_Client_Row.Patronymic          := v_Esbo_Res.Get_Optional_Varchar2('patronymic');
    v_Client_Row.Fio                 := v_Esbo_Res.Get_Optional_Varchar2('fio');
    v_Client_Row.Birthday            := v_Esbo_Res.Get_Optional_Date('birthday');
    v_Client_Row.Pinfl               := v_Esbo_Res.Get_Optional_Varchar2('pinfl');
    v_Client_Row.Inn                 := v_Esbo_Res.Get_Optional_Varchar2('inn');
    v_Client_Row.Passport_Serial     := v_Esbo_Res.Get_Optional_Varchar2('passport_serial');
    v_Client_Row.Passport_Number     := v_Esbo_Res.Get_Optional_Varchar2('passport_number');
    v_Client_Row.Mobile_Phone        := v_Esbo_Res.Get_Optional_Varchar2('mobile_phone');
    v_Client_Row.Business_Name       := v_Esbo_Res.Get_Optional_Varchar2('business_name');
    v_Client_Row.Registration_Date   := v_Esbo_Res.Get_Optional_Date('registration_date');
    v_Client_Row.Registration_Number := v_Esbo_Res.Get_Optional_Varchar2('registration_number');
    v_Client_Row.Director_Name       := v_Esbo_Res.Get_Optional_Varchar2('director_name');
    v_Client_Row.Director_Passport   := v_Esbo_Res.Get_Optional_Varchar2('director_passport');
    v_Client_Row.Accountant_Name     := v_Esbo_Res.Get_Optional_Varchar2('accountant_name');
    v_Client_Row.Accountant_Passport := v_Esbo_Res.Get_Optional_Varchar2('accountant_passport');
    v_Client_Row.Operator_Code       := v_Esbo_Res.Get_Optional_Number('operator_code');
    v_Client_Row.Date_Open           := v_Esbo_Res.Get_Optional_Date('date_open');
    --
    Client_Dml.Set_Proprietor_Client(i_Row => v_Client_Row);
    --
    Client_Dml.Set_Client_Detail(i_Client_Code => v_Client_Row.Client_Code,
                                 i_Detail      => v_Esbo_Res.Json_Clob);
  end;

  ----
  --
  ----
  Procedure Get_Entities_Client
  (
    Io_Hash   in out nocopy Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Method_Code varchar2(50) := 'GET_ENTITIES_INFO';
    v_Esbo_Req    Hash_t := Hash_t();
    v_Esbo_Res    Hash_t := Hash_t();
    v_Client_Row  Client_Entities%rowtype;
  begin
    o_Code := Sm_Const.c_Success_Code;
    --
    v_Esbo_Req.Put('method_code', v_Method_Code);
    v_Esbo_Req.Put('client_code', Io_Hash.Get_Optional_Varchar2('client_code'));
    v_Esbo_Req.Put('inn', Io_Hash.Get_Optional_Varchar2('inn'));
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
    if o_Code != Sm_Const.c_Success_Code then
      return;
    end if;
    v_Esbo_Res                           := Io_Hash.Get_Optional_Hash_t('esbo_response');
    v_Client_Row.Client_Code             := v_Esbo_Res.Get_Optional_Varchar2('client_code');
    v_Client_Row.Client_Id               := v_Esbo_Res.Get_Optional_Number('client_id');
    v_Client_Row.Client_Uid              := v_Esbo_Res.Get_Optional_Number('client_uid');
    v_Client_Row.Status                  := v_Esbo_Res.Get_Optional_Varchar2('status');
    v_Client_Row.Segment_Code            := v_Esbo_Res.Get_Optional_Varchar2('segment_code');
    v_Client_Row.Bic                     := v_Esbo_Res.Get_Optional_Varchar2('bic');
    v_Client_Row.Is_Identification_Bdmab := v_Esbo_Res.Get_Optional_Varchar2('identification_bdmab');
    v_Client_Row.Client_Type             := v_Esbo_Res.Get_Optional_Varchar2('typeof');
    v_Client_Row.Residency_Code          := v_Esbo_Res.Get_Optional_Varchar2('resident_code');
    v_Client_Row.Organization_Name       := v_Esbo_Res.Get_Optional_Varchar2('organization_name');
    v_Client_Row.Registration_Date       := v_Esbo_Res.Get_Optional_Date('registration_date');
    v_Client_Row.Registration_Number     := v_Esbo_Res.Get_Optional_Varchar2('registration_number');
    v_Client_Row.Inn                     := v_Esbo_Res.Get_Optional_Varchar2('inn');
    v_Client_Row.Director_Name           := v_Esbo_Res.Get_Optional_Varchar2('director_name');
    v_Client_Row.Director_Passport       := v_Esbo_Res.Get_Optional_Varchar2('director_passport');
    v_Client_Row.Accountant_Name         := v_Esbo_Res.Get_Optional_Varchar2('accountant_name');
    v_Client_Row.Accountant_Passport     := v_Esbo_Res.Get_Optional_Varchar2('accountant_passport');
    v_Client_Row.Phone                   := v_Esbo_Res.Get_Optional_Varchar2('phone');
    v_Client_Row.Mobile_Phone            := v_Esbo_Res.Get_Optional_Varchar2('mobile_phone');
    v_Client_Row.Operator_Code           := v_Esbo_Res.Get_Optional_Number('operator_code');
    v_Client_Row.Date_Open               := v_Esbo_Res.Get_Optional_Date('date_open');
    --
    Client_Dml.Set_Entities_Client(i_Row => v_Client_Row);
    --
    Client_Dml.Set_Client_Detail(i_Client_Code => v_Client_Row.Client_Code,
                                 i_Detail      => v_Esbo_Res.Json_Clob);
  end;
end Client_Kernel;
/
