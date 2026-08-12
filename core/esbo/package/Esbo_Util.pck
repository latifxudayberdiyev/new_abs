create or replace package Esbo_Util is

  -- Author  : B.URALOV
  -- Created : 02.04.2026 10:59:12
  -- Purpose : 
  Procedure Return_Response
  (
    i_Data       Json_Object_t default null,
    i_Error_Code number,
    i_Error_Msg  varchar2 default null,
    i_Ora_Msg    varchar2 default null,
    i_Variables  Json_Object_t default null,
    o_Response   out clob
  );
  ----
  --
  ----
  Function Get_Service_State(i_Service_Code in varchar2) return varchar2;
  ----
  -- Getting generate UUID
  ----
  Function Uuid return varchar2;
  ----
  --
  ----
  Function Get_Method
  (
    i_Service_Code in varchar2,
    i_Method_Code  in varchar2
  ) return Esbo_r_Methods%rowtype;
  ----
  --
  ----
  Function Get_Param_Value
  (
    i_Service_Code in varchar2,
    i_Param_Code   in varchar2
  ) return varchar2;
  ----
  --
  ----
  Function Get_Service_Token(i_Service_Code in varchar2) return Esbo_Service_Settings%rowtype;
  ----
  --
  ----
  Function Get_Path_Params
  (
    i_Service_Code in varchar2,
    i_Method_Url   in varchar2,
    i_Params       in Hash_t
  ) return varchar2;
end Esbo_Util;
/
create or replace package body Esbo_Util is
  Procedure Return_Response
  (
    i_Data       Json_Object_t default null,
    i_Error_Code number,
    i_Error_Msg  varchar2 default null,
    i_Ora_Msg    varchar2 default null,
    i_Variables  Json_Object_t default null,
    o_Response   out clob
  ) is
    v_Success   boolean := (i_Error_Code = 0);
    v_Response  Json_Object_t := Json_Object_t();
    v_Error     Json_Object_t := Json_Object_t();
    v_Data      Json_Object_t := Coalesce(i_Data, Json_Object_t());
    v_Error_r   Esbo_r_Errors%rowtype;
    v_Lang      varchar2(10);
    v_Error_Msg varchar2(1000);
    v_Keys      Json_Key_List := Json_Key_List();
  begin
    if not v_Success then
      begin
        select e.*
          into v_Error_r
          from Esbo_r_Errors e
         where e.Code = i_Error_Code;
      
        case v_Lang
          when 'uz' then
            v_Error_Msg := v_Error_r.Uz;
          when 'en' then
            v_Error_Msg := v_Error_r.En;
          else
            v_Error_Msg := v_Error_r.Ru;
        end case;
      
      exception
        when No_Data_Found then
          case v_Lang
            when 'uz' then
              v_Error_Msg := 'Kutilmagan xatolik.';
            when 'en' then
              v_Error_Msg := 'Unknown error.';
            else
              v_Error_Msg := 'Неизвестная ошибка.';
          end case;
      end;
    
      -- Parametrlarni joylashtirish
      if i_Variables is not null then
        v_Keys := i_Variables.Get_Keys;
        for i in 1 .. v_Keys.Count
        loop
          declare
            v_Key   varchar2(100) := v_Keys(i);
            v_Value varchar2(4000) := i_Variables.Get_String(v_Keys(i));
          begin
            v_Error_Msg := replace(v_Error_Msg, ':' || v_Key, v_Value);
          end;
        end loop;
      end if;
    
      -- Faqat -999 bo'lsa tashqi xabarni ustun qo'yish
      if i_Error_Code = -999 and i_Error_Msg is not null then
        v_Error_Msg := i_Error_Msg;
      end if;
    
      v_Error.Put('code', i_Error_Code);
      v_Error.Put('message', i_Error_Code || ' ' || v_Error_Msg);
      v_Error.Put('ora_message', i_Ora_Msg);
    end if;
  
    v_Response.Put('success', v_Success);
    v_Response.Put('data', v_Data);
    v_Response.Put('error', v_Error);
  
    o_Response := v_Response.To_Clob;
  end;
  ----
  --
  ----
  Function Get_Service_State(i_Service_Code in varchar2) return varchar2 is
    v_State Esbo_r_Services.State%type;
  begin
    select t.State
      into v_State
      from Esbo_r_Services t
     where t.Code = i_Service_Code;
    return v_State;
  exception
    when others then
      return 'N';
  end;
  ----
  -- Getting generate UUID
  ----
  Function Uuid return varchar2 is
  begin
    return Lower(Sys_Guid());
  end;
  ----
  --
  ----
  Function Get_Method
  (
    i_Service_Code in varchar2,
    i_Method_Code  in varchar2
  ) return Esbo_r_Methods%rowtype is
    v_Row Esbo_r_Methods%rowtype;
  begin
    select t.*
      into v_Row
      from Esbo_r_Methods t
     where t.Service_Code = i_Service_Code
       and t.Method_Code = i_Method_Code;
    return v_Row;
  end;
  ----
  --
  ----
  Function Get_Param_Value
  (
    i_Service_Code in varchar2,
    i_Param_Code   in varchar2
  ) return varchar2 is
    result Esbo_Service_Settings.Param_Value %type;
  begin
    select t.Param_Value
      into result
      from Esbo_Service_Settings t
     where t.Service_Code = i_Service_Code
       and t.Param_Code = i_Param_Code;
    return result;
  exception
    when others then
      return '';
  end;
  ----
  --
  ----
  Function Get_Service_Token(i_Service_Code in varchar2) return Esbo_Service_Settings%rowtype is
    result Esbo_Service_Settings%rowtype;
  begin
    select t.*
      into result
      from Esbo_Service_Settings t
     where t.Service_Code = i_Service_Code
       and t.Param_Code = Esbo_Const.c_Pc_Token;
    return result;
  exception
    when others then
      return result;
  end;
  ----
  --
  ----
  Function Get_Path_Params
  (
    i_Service_Code in varchar2,
    i_Method_Url   in varchar2,
    i_Params       in Hash_t
  ) return varchar2 is
    v_Pattern  varchar2(1000);
    v_Key      varchar2(1000);
    v_Value    varchar2(4000);
    v_Pos      pls_integer := 1;
    v_Esb_Host varchar2(300);
    v_Url      varchar2(500);
  begin
    v_Esb_Host := Esbo_Util.Get_Param_Value(i_Service_Code => i_Service_Code,
                                            i_Param_Code   => Esbo_Const.c_Pc_Esb_Url);
    if Instr(i_Method_Url, '}') > 0 then
      v_Url := i_Method_Url;
      loop
        v_Pos := Instr(i_Method_Url, '{', v_Pos);
        exit when v_Pos = 0;
      
        v_Pattern := Substr(i_Method_Url, v_Pos, Instr(i_Method_Url, '}', v_Pos) - v_Pos + 1);
        v_Key     := Substr(v_Pattern, 2, Length(v_Pattern) - 2);
      
        if i_Params.Has(v_Key) then
          v_Value := i_Params.Get_Optional_Varchar2(v_Key);
        else
          v_Value := '';
        end if;
      
        v_Url := replace(v_Url, v_Pattern, v_Value);
        v_Pos := v_Pos + 1;
      end loop;
    end if;
    return v_Esb_Host || Nvl(v_Url, i_Method_Url);
  end;
  ----
  --
  ---- 
  
end Esbo_Util;
/
