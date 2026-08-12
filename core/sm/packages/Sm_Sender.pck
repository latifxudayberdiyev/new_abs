create or replace package Sm_Sender is

  -- Author  : B.URALOV
  -- Created : 14.05.2025 11:46:10
  -- Purpose : tashqi tizimga chiqish uchun umumiy xolatlarni saqlaydi
  ----
  -- iabs shinasiga request berish
  ----
  Procedure Send_Iabs
  (
    Io_Hash         in Core.Hash_t,
    i_Method_Id     in number,
    o_Response_Hash out Core.Hash_t,
    o_Code          out number,
    o_Msg           out varchar2,
    o_Ora_Msg       out varchar2
  );
  ----
  -- iabs shinasiga request berish
  ----
  Procedure Send_Iabs_Esb
  (
    Io_Hash         in Core.Hash_t,
    i_Method_Id     in number,
    o_Response_Hash out Core.Hash_t,
    o_Code          out number,
    o_Msg           out varchar2,
    o_Ora_Msg       out varchar2
  );
end Sm_Sender;
/
create or replace package body Sm_Sender is
  ----
  -- iabs shinasiga request berish
  ----
  Procedure Send_Iabs
  (
    Io_Hash         in Core.Hash_t,
    i_Method_Id     in number,
    o_Response_Hash out Core.Hash_t,
    o_Code          out number,
    o_Msg           out varchar2,
    o_Ora_Msg       out varchar2
  ) is
    v_Iabs_Params Core.Hash_t := Core.Hash_t();
    v_Params      varchar2(3000);
    v_Request_Id  varchar2(50);
    v_Result      clob;
  begin
    v_Iabs_Params := Io_Hash.Get_Hash_t('iabs_params');
    v_Params      := v_Iabs_Params.Json;
    /*Crobs_V3.Iabs_Api.Send_Request(p_Method_Code   => i_Method_Id,
                                   p_Params        => v_Params,
                                   o_Response_Code => o_Code,
                                   o_Response_Msg  => o_Msg,
                                   o_Response      => v_Result,
                                   o_Request_Id    => v_Request_Id);*/
    if o_Code != Sm_Const.c_Success_Code then
      o_Ora_Msg := 'SHINA:' || o_Msg;
      return;
    else
      Core.Json_Parser.Parse_Json(v_Result, o_Response_Hash);
    end if;
  end;
  ----
  -- iabs shinasiga request berish
  ----
  Procedure Send_Iabs_Esb
  (
    Io_Hash         in Core.Hash_t,
    i_Method_Id     in number,
    o_Response_Hash out Core.Hash_t,
    o_Code          out number,
    o_Msg           out varchar2,
    o_Ora_Msg       out varchar2
  ) is
    v_Iabs_Params Core.Hash_t := Core.Hash_t();
    v_Params      varchar2(3000);
    v_Request_Id  varchar2(50);
    v_Result      clob;
  begin
    v_Iabs_Params := Io_Hash.Get_Hash_t('iabs_params');
    v_Params      := v_Iabs_Params.Json;
    /*Crobs_V3.Iabs_Api.Send_Request_New_Shina(p_Method_Code   => i_Method_Id,
                                             p_Params        => v_Params,
                                             o_Response_Code => o_Code,
                                             o_Response_Msg  => o_Msg,
                                             o_Response      => v_Result,
                                             o_Request_Id    => v_Request_Id);*/
    if o_Code != Sm_Const.c_Success_Code then
      o_Ora_Msg := 'SHINA:' || o_Msg;
      return;
    else
      Core.Json_Parser.Parse_Json(v_Result, o_Response_Hash);
      o_Response_Hash := o_Response_Hash.Get_Optional_Hash_t('data');
    end if;
  end;
end Sm_Sender;
/
