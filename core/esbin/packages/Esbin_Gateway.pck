create or replace package Esbin_Gateway is

  -- Author  : Generated per security-review requirement: thin grant surface for UAPP
  -- Purpose : Bearer-token oqimi uchun UAPP'ga grant qilinadigan YAGONA ESBIN
  --           kirish nuqtasi. Esbin_Kernel'ning o'zi UAPP'ga grant qilinmaydi -
  --           u Save_User_Methods/Attach_User_Methods'ni ham tashiydi, ular
  --           o'z ichida hech qanday avtorizatsiya tekshirmaydi va Esbin_Kernel
  --           to'g'ridan-to'g'ri grant qilinsa, istalgan UAPP-tarafi JSP ixtiyoriy
  --           ESBIN method-dostupini biriktirib qo'yishi mumkin bo'lardi. Shu
  --           bois faqat quyidagi uchta - tashqi partner uchun zarur va ichida
  --           o'z-o'zini avtorizatsiya qiladigan (token/parol tekshiruvi) -
  --           metod shu paket orqali ochiladi.

  Procedure Login(Io_Hash in out nocopy Core.Hash_t, o_Code out number, o_Msg out varchar2, o_Ora_Msg out varchar2);

  Procedure Logout(Io_Hash in out nocopy Core.Hash_t, o_Code out number, o_Msg out varchar2, o_Ora_Msg out varchar2);

  Procedure Execute_Request
  (
    i_Access_Token   in varchar2,
    i_Client_Ip      in varchar2,
    i_Method_Code    in varchar2,
    i_Request        in clob,
    i_Ext_Request_Id in varchar2,
    o_Response       out clob,
    o_Code           out number,
    o_Msg            out varchar2,
    o_Ora_Msg        out varchar2
  );

end Esbin_Gateway;
/
create or replace package body Esbin_Gateway is

  Procedure Login(Io_Hash in out nocopy Core.Hash_t, o_Code out number, o_Msg out varchar2, o_Ora_Msg out varchar2) is
  begin
    Esbin_Kernel.Login(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end Login;

  Procedure Logout(Io_Hash in out nocopy Core.Hash_t, o_Code out number, o_Msg out varchar2, o_Ora_Msg out varchar2) is
  begin
    Esbin_Kernel.Logout(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  end Logout;

  Procedure Execute_Request
  (
    i_Access_Token   in varchar2,
    i_Client_Ip      in varchar2,
    i_Method_Code    in varchar2,
    i_Request        in clob,
    i_Ext_Request_Id in varchar2,
    o_Response       out clob,
    o_Code           out number,
    o_Msg            out varchar2,
    o_Ora_Msg        out varchar2
  ) is
    v_User_Id      number;
    v_Partner_Code varchar2(50);
  begin
    Esbin_Util.Get_Token_User(i_Access_Token => i_Access_Token,
                              i_Client_Ip    => i_Client_Ip,
                              o_User_Id      => v_User_Id,
                              o_Partner_Code => v_Partner_Code);

    if v_User_Id is null then
      o_Code    := 401;
      o_Msg     := 'Token yaroqsiz yoki muddati o''tgan';
      o_Ora_Msg := o_Msg;
      return;
    end if;

    Esbin_Kernel.Execute_Request(i_User_Id        => v_User_Id,
                                 i_Method_Code    => i_Method_Code,
                                 i_Request        => i_Request,
                                 i_Ext_Request_Id => i_Ext_Request_Id,
                                 i_Ip_Address     => i_Client_Ip,
                                 o_Response       => o_Response,
                                 o_Code           => o_Code,
                                 o_Msg            => o_Msg,
                                 o_Ora_Msg        => o_Ora_Msg);
  end Execute_Request;

end Esbin_Gateway;
/
