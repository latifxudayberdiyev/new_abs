create or replace package Mlt_Core_Api is

  -- Author  : AALIJONOV
  -- Created : 22.04.2026 16:47:29
  -- Purpose : 
  -------------------------------------------------------------------------------------------------------------
  Procedure Set_Lang_Index(i_Lang_Index number,
                           o_Msg        out varchar2,
                           o_Code       out number);
  -------------------------------------------------------------------------------------------------------------
  Procedure Clear_Lang_Index;
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Get_Message(i_Message_Code  varchar2,
                        i_Lang_Index    number := null,
                        i_Params        Array_Varchar2 := null,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        o_Msg           out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Message(i_Message_Code varchar2,
                        i_Lang_Index   number := Mlt_Cache.Lang_Index,
                        i_Param1       varchar2,
                        i_Param2       varchar2 := null,
                        i_Param3       varchar2 := null,
                        i_Param4       varchar2 := null,
                        i_Param5       varchar2 := null,
                        i_Param6       varchar2 := null,
                        i_Param7       varchar2 := null,
                        i_Param8       varchar2 := null,
                        i_Param9       varchar2 := null,
                        i_Param10      varchar2 := null,
                        o_Msg          out varchar2);
  -------------------------------------------------------------------------------------------------------------  
end Mlt_Core_Api;
/
create or replace package body Mlt_Core_Api is
  -------------------------------------------------------------------------------------------------------------
  Procedure Set_Lang_Index(i_Lang_Index number,
                           o_Msg        out varchar2,
                           o_Code       out number) is
  begin
    Mlt_Kernel.Set_Lang_Index(i_Lang_Index => i_Lang_Index,
                              o_Msg        => o_Msg,
                              o_Code       => o_Code);
  end Set_Lang_Index;
  -------------------------------------------------------------------------------------------------------------
  Procedure Clear_Lang_Index is
  begin
    Mlt_Kernel.Clear_Lang_Index;
  end Clear_Lang_Index;
  -------------------------------------------------------------------------------------------------------------  
  Procedure Get_Message(i_Message_Code  varchar2,
                        i_Lang_Index    number := null,
                        i_Params        Array_Varchar2 := null,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        o_Msg           out varchar2) is
  begin
    --
    Mlt_Kernel.Get_Message(i_Message_Code  => i_Message_Code,
                           i_Lang_Index    => i_Lang_Index,
                           i_Params        => i_Params,
                           i_Format_String => i_Format_String,
                           o_Msg           => o_Msg);
  end Get_Message;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Message(i_Message_Code varchar2,
                        i_Lang_Index   number := Mlt_Cache.Lang_Index,
                        i_Param1       varchar2,
                        i_Param2       varchar2 := null,
                        i_Param3       varchar2 := null,
                        i_Param4       varchar2 := null,
                        i_Param5       varchar2 := null,
                        i_Param6       varchar2 := null,
                        i_Param7       varchar2 := null,
                        i_Param8       varchar2 := null,
                        i_Param9       varchar2 := null,
                        i_Param10      varchar2 := null,
                        o_Msg          out varchar2) is
  begin
    Mlt_Kernel.Get_Message(i_Message_Code => i_Message_Code,
                           i_Lang_Index   => i_Lang_Index,
                           i_Param1       => i_Param1,
                           i_Param2       => i_Param2,
                           i_Param3       => i_Param3,
                           i_Param4       => i_Param4,
                           i_Param5       => i_Param5,
                           i_Param6       => i_Param6,
                           i_Param7       => i_Param7,
                           i_Param8       => i_Param8,
                           i_Param9       => i_Param9,
                           i_Param10      => i_Param10,
                           o_Msg          => o_Msg);
  end Get_Message;
  -------------------------------------------------------------------------------------------------------------     
end Mlt_Core_Api;
/
