create or replace package Mle_Core_Api is

  -- Author  : AALIJONOV
  -- Created : 16.06.2026 10:16:01
  -- Purpose : 
  ------------------------------------------------------------------------------------------------------------- 
  Procedure Get_Error_Message(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Lang_Index   number := Mlt_Cache.Lang_Index,
                              --
                              i_Params        Array_Varchar2 := null,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              --
                              o_Code out number,
                              o_Msg  out varchar2);

  ------------------------------------------------------------------------------------------------------------- 
  Procedure Get_Error_Message(i_Module_Code   varchar2,
                              i_Message_Code  varchar2,
                              i_Lang_Index    number := Mlt_Cache.Lang_Index,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              -- 
                              i_Param1  varchar2,
                              i_Param2  varchar2 := null,
                              i_Param3  varchar2 := null,
                              i_Param4  varchar2 := null,
                              i_Param5  varchar2 := null,
                              i_Param6  varchar2 := null,
                              i_Param7  varchar2 := null,
                              i_Param8  varchar2 := null,
                              i_Param9  varchar2 := null,
                              i_Param10 varchar2 := null,
                              --
                              o_Code out number,
                              o_Msg  out varchar2);

  -------------------------------------------------------------------------------------------------------------
  Procedure Raise_Error(i_Module_Code   varchar2,
                        i_Message_Code  varchar2,
                        i_Lang_Index    number := Mlt_Cache.Lang_Index,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Params        Array_Varchar2 := null);
  -------------------------------------------------------------------------------------------------------------   

end Mle_Core_Api;
/
create or replace package body Mle_Core_Api is
  -------------------------------------------------------------------------------------------------------------  
  Procedure Get_Error_Message(i_Module_Code  varchar2,
                              i_Message_Code varchar2,
                              i_Lang_Index   number := Mlt_Cache.Lang_Index,
                              --
                              i_Params        Array_Varchar2 := null,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              --
                              o_Code out number,
                              o_Msg  out varchar2) is
  begin
    Mle_Kernel.Get_Error_Message(i_Module_Code   => i_Module_Code,
                                 i_Message_Code  => i_Message_Code,
                                 i_Lang_Index    => i_Lang_Index,
                                 i_Params        => i_Params,
                                 i_Format_String => i_Format_String,
                                 o_Code          => o_Code,
                                 o_Msg           => o_Msg);
  end Get_Error_Message;
  -------------------------------------------------------------------------------------------------------------
  Procedure Get_Error_Message(i_Module_Code   varchar2,
                              i_Message_Code  varchar2,
                              i_Lang_Index    number := Mlt_Cache.Lang_Index,
                              i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                              --
                              i_Param1  varchar2,
                              i_Param2  varchar2 := null,
                              i_Param3  varchar2 := null,
                              i_Param4  varchar2 := null,
                              i_Param5  varchar2 := null,
                              i_Param6  varchar2 := null,
                              i_Param7  varchar2 := null,
                              i_Param8  varchar2 := null,
                              i_Param9  varchar2 := null,
                              i_Param10 varchar2 := null,
                              --
                              o_Code out number,
                              o_Msg  out varchar2) is
  begin
    Mle_Kernel.Get_Error_Message(i_Module_Code   => i_Module_Code,
                                 i_Message_Code  => i_Message_Code,
                                 i_Lang_Index    => i_Lang_Index,
                                 i_Format_String => i_Format_String,
                                 i_Param1        => i_Param1,
                                 i_Param2        => i_Param2,
                                 i_Param3        => i_Param3,
                                 i_Param4        => i_Param4,
                                 i_Param5        => i_Param5,
                                 i_Param6        => i_Param6,
                                 i_Param7        => i_Param7,
                                 i_Param8        => i_Param8,
                                 i_Param9        => i_Param9,
                                 i_Param10       => i_Param10,
                                 o_Code          => o_Code,
                                 o_Msg           => o_Msg);
  end Get_Error_Message;
  -------------------------------------------------------------------------------------------------------------
  Procedure Raise_Error(i_Module_Code   varchar2,
                        i_Message_Code  varchar2,
                        i_Lang_Index    number := Mlt_Cache.Lang_Index,
                        i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                        i_Params        Array_Varchar2 := null) is
  begin
    Mle_Kernel.Raise_Error(i_Module_Code   => i_Module_Code,
                           i_Message_Code  => i_Message_Code,
                           i_Lang_Index    => i_Lang_Index,
                           i_Format_String => i_Format_String,
                           i_Params        => i_Params);
  end;
  -------------------------------------------------------------------------------------------------------------   
end Mle_Core_Api;
/
