create or replace package Esbo_Kernel is

  -- Author  : B.URALOV
  -- Created : 02.04.2026 10:43:27
  -- Purpose : 
  ----
  --
  ----
  Function Get_Token(i_Service_Code in varchar2) return varchar2;
  ----
  --
  ----
  Procedure Send_Request
  (
    i_Service_Code in varchar2,
    i_Method_Code  in varchar2,
    i_Params       in Hash_t,
    o_Code         out number,
    o_Msg          out varchar2,
    o_Ora_Msg      out varchar2,
    o_Request_Id   out number,
    o_Response     out Hash_t
  );
  ----
  --
  ----
  Procedure Universal_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Psb_Service_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----
  --
  ----
  Procedure Fb_Service_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Esbo_Kernel;
/
create or replace package body Esbo_Kernel is
  Function Send_Http_Clob
  (
    i_Request varchar2,
    i_Timeout number,
    i_Url     varchar2,
    i_Token   varchar2 default null
  ) return clob is
    v_Req Utl_Http.Req;
  
    v_Res          Utl_Http.Resp;
    v_Url          varchar2(100) := i_Url;
    v_Buffer       varchar2(32767);
    v_Content      varchar2(32767);
    v_Content_Clob clob := i_Request;
    v_Response     clob;
    v_Req_Length   binary_integer;
    v_Offset       pls_integer := 1;
    v_Amount       pls_integer := 4000;
    v_Error_Resp   varchar2(1000);
  begin
    Utl_Http.Set_Body_Charset('UTF-8');
    Utl_Http.Set_Transfer_Timeout(i_Timeout);
    Dbms_Lob.Createtemporary(v_Response, false);
  
    v_Req := Utl_Http.Begin_Request(v_Url, 'POST', ' HTTP/1.1');
    Utl_Http.Set_Header(v_Req, 'user-agent', 'plsql/14.0');
    Utl_Http.Set_Header(v_Req, 'content-type', 'application/json');
    Utl_Http.Set_Header(v_Req, 'Authorization', 'Bearer ' || i_Token);
    v_Req_Length := Dbms_Lob.Getlength(v_Content_Clob);
  
    if v_Req_Length <= 30000 then
      v_Content := i_Request;
    
      Utl_Http.Set_Header(v_Req, 'Content-Length', Lengthb(v_Content));
      Utl_Http.Write_Raw(r => v_Req, Data => Utl_Raw.Cast_To_Raw(v_Content));
    
      Utl_Http.Write_Text(v_Req, v_Content);
    
    elsif v_Req_Length > 30000 then
    
      Utl_Http.Set_Header(v_Req, 'Transfer-Encoding', 'chunked');
    
      while (v_Offset < v_Req_Length)
      loop
        Dbms_Lob.Read(v_Content_Clob, v_Amount, v_Offset, v_Buffer);
        Utl_Http.Write_Text(v_Req, v_Buffer);
        v_Offset := v_Offset + v_Amount;
      end loop;
    
    end if;
  
    v_Res := Utl_Http.Get_Response(v_Req);
  
    begin
      loop
        Utl_Http.Read_Text(v_Res, v_Buffer, 32766);
        Dbms_Lob.Writeappend(v_Response, Length(v_Buffer), v_Buffer);
      end loop;
    
      Utl_Http.End_Response(v_Res);
    
    exception
      when Utl_Http.End_Of_Body then
        Utl_Http.End_Response(v_Res);
    end;
    return v_Response;
    Dbms_Lob.Freetemporary(v_Response);
  exception
    when Utl_Http.Request_Failed then
      Esbo_Util.Return_Response(i_Error_Code => 417,
                                i_Ora_Msg    => sqlerrm,
                                o_Response   => v_Error_Resp);
    
      return v_Error_Resp;
    when others then
      Esbo_Util.Return_Response(i_Error_Code => -999,
                                i_Error_Msg  => sqlerrm || ', ' || v_Response,
                                i_Ora_Msg    => sqlerrm || Dbms_Utility.Format_Error_Backtrace,
                                o_Response   => v_Error_Resp);
      return v_Error_Resp;
  end;
  ----
  --
  ----
  Function Get_Token(i_Service_Code in varchar2) return varchar2 is
    v_Refresh_Time  Esbo_Service_Settings.Param_Value%type;
    v_Param_Row     Esbo_Service_Settings%rowtype;
    v_Request       Hash_t := Hash_t();
    v_Response_Hash Hash_t := Hash_t();
    v_Response      clob;
  begin
    v_Refresh_Time := Esbo_Util.Get_Param_Value(i_Service_Code => i_Service_Code,
                                                i_Param_Code   => Esbo_Const.c_Pc_Refresh_Time);
    v_Param_Row    := Esbo_Util.Get_Service_Token(i_Service_Code => i_Service_Code);
  
    if ((sysdate - v_Param_Row.Created_On) * 24 * 60 < v_Refresh_Time) and
       v_Param_Row.Param_Value is not null then
      return v_Param_Row.Param_Value;
    else
      v_Request.Put('username',
                    Esbo_Util.Get_Param_Value(i_Service_Code => i_Service_Code,
                                              i_Param_Code   => Esbo_Const.c_Pc_Login));
      v_Request.Put('password',
                    Esbo_Util.Get_Param_Value(i_Service_Code => i_Service_Code,
                                              i_Param_Code   => Esbo_Const.c_Pc_Password));
      if i_Service_Code = Esbo_Const.c_Service_Fb then
        v_Request.Put('url',
                      Esbo_Util.Get_Param_Value(i_Service_Code => i_Service_Code,
                                                i_Param_Code   => Esbo_Const.c_Pc_Esb_Url) ||
                      '/getToken');
      end if;
    
      -- Dbms_Output.Put_Line(v_Request.Json);
      v_Response := Send_Http_Clob(i_Request => v_Request.Json,
                                   i_Timeout => 5,
                                   i_Url     => Esbo_Util.Get_Param_Value(i_Service_Code => i_Service_Code,
                                                                          i_Param_Code   => Esbo_Const.c_Pc_Get_Token_Url));
      Json_Parser.Parse_Json(v_Response, v_Response_Hash);
      v_Param_Row.Param_Value := Nvl(v_Response_Hash.Get_Optional_Varchar2('token'),
                                     v_Response_Hash.Get_Optional_Varchar2('access_token'));
    
      if v_Param_Row.Param_Value is not null then
        Esbo_Dml.Set_Service_Token(i_Service_Code, v_Param_Row.Param_Value);
      
        return v_Param_Row.Param_Value;
      else
        return null;
      end if;
    end if;
  end;
  ----
  --
  ----
  Procedure Send_Request
  (
    i_Service_Code in varchar2,
    i_Method_Code  in varchar2,
    i_Params       in Hash_t,
    o_Code         out number,
    o_Msg          out varchar2,
    o_Ora_Msg      out varchar2,
    o_Request_Id   out number,
    o_Response     out Hash_t
  ) is
    v_Method        Esbo_r_Methods%rowtype;
    v_Row           Esbo_Requests%rowtype;
    v_Params_Hash   Hash_t := i_Params;
    v_Error_Hash    Hash_t := Hash_t();
    v_Request_Hash  Hash_t := Hash_t();
    v_Response_Hash Hash_t := Hash_t();
    v_Token         varchar2(4000) := Get_Token(i_Service_Code);
    v_Url           varchar2(500);
  begin
    o_Code     := Core_Const.c_Success_Code;
    o_Response := Hash_t();
    -- check service 
    if Esbo_Util.Get_Service_State(i_Service_Code => i_Service_Code) != Core_Const.c_State_Active then
      o_Code    := 301;
      o_Msg     := 'Service active xolatda emas';
      o_Ora_Msg := 'Service active xolatda emas';
      return;
    end if;
    --
    begin
      v_Method := Esbo_Util.Get_Method(i_Service_Code => i_Service_Code,
                                       i_Method_Code  => i_Method_Code);
    exception
      when others then
        o_Code    := 302;
        o_Msg     := 'Mehtod topilmadi service_code:' || i_Service_Code || ' method_code:' ||
                     i_Method_Code;
        o_Ora_Msg := 'Mehtod topilmadi service_code:' || i_Service_Code || ' method_code:' ||
                     i_Method_Code;
        return;
    end;
  
    if v_Method.State <> 'A' then
      o_Code    := 302;
      o_Msg     := 'Mehtod active emas service_code:' || i_Service_Code || ' method_code:' ||
                   i_Method_Code;
      o_Ora_Msg := 'Mehtod active emas service_code:' || i_Service_Code || ' method_code:' ||
                   i_Method_Code;
      return;
    end if;
  
    v_Url := Esbo_Util.Get_Path_Params(i_Service_Code => i_Service_Code,
                                       i_Method_Url   => v_Method.Url,
                                       i_Params       => v_Params_Hash);
    --
    v_Row.Request_Id := Esbo_Util.Uuid;
    v_Request_Hash.Put('token', v_Token);
    v_Request_Hash.Put('timeout', v_Method.Timeout);
    v_Request_Hash.Put('url', v_Url);
    v_Request_Hash.Put('lang', 'ru');
    v_Request_Hash.Put('request_type', v_Method.Request_Type);
    v_Request_Hash.Put('request_id', v_Row.Request_Id);
  
    if i_Service_Code = Esbo_Const.c_Service_Psb then
      v_Request_Hash.Put('method_code', i_Method_Code);
      v_Request_Hash.Put('request', v_Params_Hash);
    else
      v_Request_Hash.Put('params', v_Params_Hash);
    end if;
    --
    --
    v_Row.Id          := Esbo_Requests_Sq.Nextval;
    o_Request_Id      := v_Row.Id;
    v_Row.Method_Code := v_Method.Method_Code;
    v_Row.Request     := v_Request_Hash.Json_Clob;
    v_Row.Created_On  := sysdate;
    --
    --   Dbms_Output.Put_Line(v_Row.Request);
    if v_Method.Add_Log = 'Y' then
      Esbo_Dml.Insert_Log(v_Row);
    end if;
    --
    v_Row.Response := Send_Http_Clob(i_Request => v_Row.Request,
                                     i_Timeout => v_Method.Timeout,
                                     i_Url     => Esbo_Util.Get_Param_Value(i_Service_Code => i_Service_Code,
                                                                            i_Param_Code   => Esbo_Const.c_Pc_Dbo_Url),
                                     i_Token   => v_Token);
  
    begin
      Json_Parser.Parse_Json(v_Row.Response, v_Response_Hash);
    exception
      when others then
        o_Code := -999;
        o_Msg  := v_Row.Response;
        return;
    end;
  
    if v_Response_Hash.Has('success') then
      if v_Response_Hash.Get_Optional_Varchar2('success') = 'true' then
        v_Row.Response_Code := 0;
        o_Msg               := '';
        if v_Response_Hash.Has('data') then
          o_Response := v_Response_Hash.Get_Optional_Hash_t('data');
        elsif v_Response_Hash.Has('responseBody') then
          o_Response := v_Response_Hash.Get_Optional_Hash_t('responseBody');
        end if;
      else
        begin
          v_Error_Hash        := v_Response_Hash.Get_Optional_Hash_t('error');
          v_Row.Response_Code := Nvl(v_Error_Hash.Get_Optional_Varchar2('code'), 404);
          o_Msg               := Nvl(v_Error_Hash.Get_Optional_Varchar2('msg'), v_Row.Response);
        exception
          when others then
            v_Row.Response_Code := 417;
            o_Msg               := v_Row.Response;
        end;
      end if;
    else
      v_Row.Response_Code := 417;
      o_Msg               := v_Row.Response;
    end if;
    o_Code := v_Row.Response_Code;
  
    v_Row.Modify_On := sysdate;
    if v_Method.Add_Log = 'Y' then
      Esbo_Dml.Update_Log(v_Row);
    end if;
  end;
  ----
  --
  ----
  Procedure Universal_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Request       Hash_t := Hash_t();
    v_Service_Code  Esbo_r_Services.Code %type;
    v_Method_Code   Esbo_r_Methods.Method_Code %type;
    v_Request_Id    Esbo_Requests.Id %type;
    v_Response_Hash Hash_t := Hash_t();
  begin
    o_Code := Core_Const.c_Success_Code;
    if not Io_Hash.Has('esbo_request') then
      return;
    end if;
    v_Request := Io_Hash.Get_Optional_Hash_t('esbo_request');
    --
    if not v_Request.Has('service_code') then
      return;
    end if;
    v_Service_Code := v_Request.Get_Optional_Varchar2('service_code');
    v_Method_Code  := v_Request.Get_Optional_Varchar2('method_code');
    Send_Request(i_Service_Code => v_Service_Code,
                 i_Method_Code  => v_Method_Code,
                 i_Params       => v_Request,
                 o_Code         => o_Code,
                 o_Msg          => o_Msg,
                 o_Ora_Msg      => o_Ora_Msg,
                 o_Request_Id   => v_Request_Id,
                 o_Response     => v_Response_Hash);
    --
    if o_Code = Core_Const.c_Success_Code then
      Io_Hash.Put('esbo_response', v_Response_Hash);
    end if;
  end;
  ----
  --
  ----
  Procedure Psb_Service_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Request       Hash_t := Hash_t();
    v_Service_Code  Esbo_r_Services.Code %type;
    v_Method_Code   Esbo_r_Methods.Method_Code %type;
    v_Request_Id    Esbo_Requests.Id %type;
    v_Response_Hash Hash_t := Hash_t();
  begin
    o_Code := Core_Const.c_Success_Code;
    if not Io_Hash.Has('esbo_request') then
      return;
    end if;
    v_Request := Io_Hash.Get_Optional_Hash_t('esbo_request');
    --
    v_Service_Code := Esbo_Const.c_Service_Psb;
    v_Method_Code  := v_Request.Get_Optional_Varchar2('method_code');
    Send_Request(i_Service_Code => v_Service_Code,
                 i_Method_Code  => v_Method_Code,
                 i_Params       => v_Request,
                 o_Code         => o_Code,
                 o_Msg          => o_Msg,
                 o_Ora_Msg      => o_Ora_Msg,
                 o_Request_Id   => v_Request_Id,
                 o_Response     => v_Response_Hash);
    --
    if o_Code = Core_Const.c_Success_Code then
      Io_Hash.Put('esbo_response', v_Response_Hash);
    end if;
  end;
  ----
  --
  ----
  Procedure Fb_Service_Api
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Request       Hash_t := Hash_t();
    v_Service_Code  Esbo_r_Services.Code %type;
    v_Method_Code   Esbo_r_Methods.Method_Code %type;
    v_Request_Id    Esbo_Requests.Id %type;
    v_Response_Hash Hash_t := Hash_t();
  begin
    o_Code := Core_Const.c_Success_Code;
    if not Io_Hash.Has('esbo_request') then
      return;
    end if;
    v_Request := Io_Hash.Get_Optional_Hash_t('esbo_request');
    --
    v_Service_Code := Esbo_Const.c_Service_Fb;
    v_Method_Code  := v_Request.Get_Optional_Varchar2('method_code');
    v_Request.Remove('method_code');
    Send_Request(i_Service_Code => v_Service_Code,
                 i_Method_Code  => v_Method_Code,
                 i_Params       => v_Request,
                 o_Code         => o_Code,
                 o_Msg          => o_Msg,
                 o_Ora_Msg      => o_Ora_Msg,
                 o_Request_Id   => v_Request_Id,
                 o_Response     => v_Response_Hash);
    --
    if o_Code = Core_Const.c_Success_Code then
      Io_Hash.Put('esbo_response', v_Response_Hash);
    end if;
  end;
end Esbo_Kernel;
/
