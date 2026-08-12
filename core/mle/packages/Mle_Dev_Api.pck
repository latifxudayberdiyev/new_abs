create or replace package Mle_Dev_Api is

  -- Author  : AALIJONOV
  -- Created : 16.06.2026 9:27:54
  -- Purpose : 
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template_Error(i_Message_Code  varchar2,
                                i_Description   varchar2,
                                i_Param_Count   number,
                                i_Format_String varchar2,
                                --
                                i_Message_Mask_Lang1  varchar2,
                                i_Message_Mask_Lang2  varchar2,
                                i_Message_Mask_Lang3  varchar2,
                                i_Message_Mask_Lang4  varchar2,
                                i_Message_Mask_Lang5  varchar2,
                                i_Message_Mask_Lang6  varchar2,
                                i_Message_Mask_Lang7  varchar2,
                                i_Message_Mask_Lang8  varchar2,
                                i_Message_Mask_Lang9  varchar2,
                                i_Message_Mask_Lang10 varchar2,
                                --
                                i_Module_Code varchar2,
                                i_Error_Code  number,
                                o_Code        out number,
                                o_Msg         out varchar2);
  -------------------------------------------------------------------------------------------------------------
  Function Get_Next_Error_Code(i_Module_Code varchar2) return number;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Free_Error_Code(i_Module_Code varchar2) return number;
  -------------------------------------------------------------------------------------------------------------
  Procedure Connect_Error_Code(i_Module_Code  varchar2,
                               i_Message_Code varchar2,
                               i_Error_Code   number := null,
                               i_Description  varchar2 := null,
                               --
                               o_Code out number,
                               o_Msg  out varchar2);
  -------------------------------------------------------------------------------------------------------------  

end Mle_Dev_Api;
/
create or replace package body Mle_Dev_Api is
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Template_Error(i_Message_Code  varchar2,
                                i_Description   varchar2,
                                i_Param_Count   number,
                                i_Format_String varchar2,
                                --
                                i_Message_Mask_Lang1  varchar2,
                                i_Message_Mask_Lang2  varchar2,
                                i_Message_Mask_Lang3  varchar2,
                                i_Message_Mask_Lang4  varchar2,
                                i_Message_Mask_Lang5  varchar2,
                                i_Message_Mask_Lang6  varchar2,
                                i_Message_Mask_Lang7  varchar2,
                                i_Message_Mask_Lang8  varchar2,
                                i_Message_Mask_Lang9  varchar2,
                                i_Message_Mask_Lang10 varchar2,
                                --
                                i_Module_Code varchar2,
                                i_Error_Code  number,
                                o_Code        out number,
                                o_Msg         out varchar2) is
  begin
    Mle_Kernel.Save_Template_With_Error(i_Message_Code        => i_Message_Code,
                                        i_Description         => i_Description,
                                        i_Param_Count         => i_Param_Count,
                                        i_Format_String       => i_Format_String,
                                        i_Message_Mask_Lang1  => i_Message_Mask_Lang1,
                                        i_Message_Mask_Lang2  => i_Message_Mask_Lang2,
                                        i_Message_Mask_Lang3  => i_Message_Mask_Lang3,
                                        i_Message_Mask_Lang4  => i_Message_Mask_Lang4,
                                        i_Message_Mask_Lang5  => i_Message_Mask_Lang5,
                                        i_Message_Mask_Lang6  => i_Message_Mask_Lang6,
                                        i_Message_Mask_Lang7  => i_Message_Mask_Lang7,
                                        i_Message_Mask_Lang8  => i_Message_Mask_Lang8,
                                        i_Message_Mask_Lang9  => i_Message_Mask_Lang9,
                                        i_Message_Mask_Lang10 => i_Message_Mask_Lang10,
                                        i_Module_Code         => i_Module_Code,
                                        i_Error_Code          => i_Error_Code,
                                        o_Code                => o_Code,
                                        o_Msg                 => o_Msg);
  end Save_Template_Error;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Next_Error_Code(i_Module_Code varchar2) return number is
  begin
    return Mle_Util.Get_Next_Error_Code(i_Module_Code => i_Module_Code);
  end;
  -------------------------------------------------------------------------------------------------------------
  Function Get_Free_Error_Code(i_Module_Code varchar2) return number is
  begin
    return Mle_Util.Get_Free_Error_Code(i_Module_Code);
  end;
  -------------------------------------------------------------------------------------------------------------
  Procedure Connect_Error_Code(i_Module_Code  varchar2,
                               i_Message_Code varchar2,
                               i_Error_Code   number := null,
                               i_Description  varchar2 := null,
                               --
                               o_Code out number,
                               o_Msg  out varchar2) is
  begin
    Mle_Kernel.Connect_Error_Code(i_Module_Code  => i_Module_Code,
                                  i_Message_Code => i_Message_Code,
                                  i_Error_Code   => i_Error_Code,
                                  i_Description  => i_Description,
                                  o_Code         => o_Code,
                                  o_Msg          => o_Msg);
  end;
  -------------------------------------------------------------------------------------------------------------
end Mle_Dev_Api;
/
