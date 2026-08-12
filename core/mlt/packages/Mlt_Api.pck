create or replace package Mlt_Api is
  -- Author  : YASHNAR
  -- Created : 26.12.2025 16:50:10
  -- Purpose : 
   ----------------------------------------------------------------------------------------------------
  Procedure Execute_Process_Clob(i_Json clob);
  ----------------------------------------------------------------------------------------------------
  Function Get_Model_Clob(i_Json clob) return clob;
  ----------------------------------------------------------------------------------------------------  
end Mlt_Api;
/
create or replace package body Mlt_Api is
   Procedure Execute_Process_Clob(i_Json clob) is
    v_Hash     Core.Hash_t;
    v_Response clob;
    v_Code     number;
    v_Msg      varchar2(3000);
    v_Ora_Msg  varchar2(3000);
  begin
    v_Hash := Json_Parser.Parse_Json(i_Json);
    --
    if v_Hash.Has('params') then
      Sm_Kernel.Set_Method(i_Json, v_Response, v_Code, v_Msg, v_Ora_Msg);
    else
      -- yassi JSON: hash-variant orqali to'g'ridan-to'g'ri
      Sm_Kernel.Set_Method(v_Hash, v_Code, v_Msg, v_Ora_Msg);
    end if;
    --
    if v_Code != Sm_Const.c_Success_Code then
      Raise_Application_Error(-20000, v_Msg);
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  -- model_process_code -> process_code: t:reference/edit() konvensiyasida
  -- process_code saqlash (POST) uchun, model_process_code esa modelni
  -- o'qish (GET) uchun ishlatiladi (bir xil so'rovda ikkalasi ham keladi,
  -- ammo Sm_Kernel faqat process_code'ni o'qiydi - shuning uchun bu yerda
  -- model_process_code mavjud bo'lsa process_code'ga ko'chiriladi).
  ----------------------------------------------------------------------------------------------------
  Function Get_Model_Clob(i_Json clob) return clob is
    v_Hash       Core.Hash_t := Core.Hash_t();
    v_Params     Core.Arraylist;
    v_Param_Hash Core.Hash_t;
    v_Data       Core.Hash_t := Core.Hash_t();
    v_Code       number;
    v_Msg        varchar2(3000);
    v_Ora_Msg    varchar2(3000);
  begin
    v_Hash   := Json_Parser.Parse_Json(i_Json);
    v_Params := v_Hash.Get_Optional_Arraylist('params');
    --
    if v_Params is not null then
      for i in 1 .. v_Params.count loop
        v_Param_Hash := Treat(v_Params.Get_r_Hash_t(i) as Core.Hash_t);
        --
        if v_Param_Hash.Has('model_process_code') then
          v_Param_Hash.Put('process_code',
                           v_Param_Hash.Get_Varchar2('model_process_code'));
        end if;
        --
        v_Param_Hash.Put('data', v_Data);
        Sm_Kernel.Set_Method(v_Param_Hash, v_Code, v_Msg, v_Ora_Msg);
        --
        if v_Code != Sm_Const.c_Success_Code then
          Raise_Application_Error(-20000, v_Msg);
        end if;
        --
        v_Data := v_Param_Hash.Get_Optional_Hash_t('data');
      end loop;
    else
      if v_Hash.Has('model_process_code') then
        v_Hash.Put('process_code',
                   v_Hash.Get_Varchar2('model_process_code'));
      end if;
      --
      v_Hash.Put('data', v_Data);
      Sm_Kernel.Set_Method(v_Hash, v_Code, v_Msg, v_Ora_Msg);
      --
      if v_Code != Sm_Const.c_Success_Code then
        Raise_Application_Error(-20000, v_Msg);
      end if;
      --
      v_Data := v_Hash.Get_Optional_Hash_t('data');
    end if;
    --
    return v_Data.Json_Clob;
  end;
end Mlt_Api;
/
