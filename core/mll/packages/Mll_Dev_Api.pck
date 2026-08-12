create or replace package Mll_Dev_Api is

  -- Author  : AALIJONOV
  -- Created : 22.07.2026 13:36:59
  -- Purpose : 
  -------------------------------------------------------------------------------------------------------------  
  Procedure Save_Label_With_Template_Dev(i_Message_Code  varchar2,
                                         i_Description   varchar2,
                                         i_Param_Count   number,
                                         i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                                         --
                                         i_Message_Mask_Lang1  varchar2,
                                         i_Message_Mask_Lang2  varchar2:=null,
                                         i_Message_Mask_Lang3  varchar2:=null,
                                         i_Message_Mask_Lang4  varchar2:=null,
                                         i_Message_Mask_Lang5  varchar2:=null,
                                         i_Message_Mask_Lang6  varchar2:=null,
                                         i_Message_Mask_Lang7  varchar2:=null,
                                         i_Message_Mask_Lang8  varchar2:=null,
                                         i_Message_Mask_Lang9  varchar2:=null,
                                         i_Message_Mask_Lang10 varchar2:=null,
                                         --
                                         i_Module_Code varchar2,
                                         i_Field_Hint  varchar2 := null,
                                         o_Code        out number,
                                         o_Msg         out varchar2);
  -------------------------------------------------------------------------------------------------------------
end Mll_Dev_Api;
/
create or replace package body Mll_Dev_Api is
  -------------------------------------------------------------------------------------------------------------
  Procedure Save_Label_With_Template_Dev(i_Message_Code  varchar2,
                                         i_Description   varchar2,
                                         i_Param_Count   number,
                                         i_Format_String varchar2 := Mlt_Const.c_Default_Format_String,
                                         --
                                         i_Message_Mask_Lang1  varchar2,
                                         i_Message_Mask_Lang2  varchar2:=null,
                                         i_Message_Mask_Lang3  varchar2:=null,
                                         i_Message_Mask_Lang4  varchar2:=null,
                                         i_Message_Mask_Lang5  varchar2:=null,
                                         i_Message_Mask_Lang6  varchar2:=null,
                                         i_Message_Mask_Lang7  varchar2:=null,
                                         i_Message_Mask_Lang8  varchar2:=null,
                                         i_Message_Mask_Lang9  varchar2:=null,
                                         i_Message_Mask_Lang10 varchar2:=null,
                                         --
                                         i_Module_Code varchar2,
                                         i_Field_Hint  varchar2 := null,
                                         o_Code        out number,
                                         o_Msg         out varchar2) is
  begin
    mll_kernel.Save_Label_With_Template_DEV(i_Message_Code        => i_Message_Code,
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
                                            i_Field_Hint          => i_Field_Hint,
                                            o_Code                => o_Code,
                                            o_Msg                 => o_Msg);
  end;
  -------------------------------------------------------------------------------------------------------------
end Mll_Dev_Api;
/
