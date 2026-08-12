create or replace package Esbin_Util is

  -- Author  : B.URALOV
  -- Purpose : ESBIN uchun select/qidiruv funksiyalari

  Procedure Select_Partner
  (
    i_Partner_Code varchar2,
    i_Is_Raise     boolean := true,
    o_Partner      out Esbin_R_Partners%rowtype
  );

  Function Exists_Active_Partner(i_Partner_Code varchar2) return boolean;

  Procedure Select_Method
  (
    i_Method_Code varchar2,
    i_Is_Raise    boolean := true,
    o_Method      out Esbin_R_Methods%rowtype
  );

  Function Has_Partner_User
  (
    i_Partner_Code varchar2,
    i_User_Id      number
  ) return boolean;

  ----
  -- ESBIN_R_USER_METHOD_REL orqali - dostup CORE button/menu tizimiga
  -- bog'lanmaydi, ESBIN o'zi alohida boshqaradi.
  ----
  Function Has_User_Method_Rel
  (
    i_User_Id     number,
    i_Method_Code varchar2
  ) return boolean;

  ----
  -- access_token orqali user_id va partner_code'ni topadi. Topilmasa (yoki
  -- topilgan user'ning IP allowlist'i i_Client_Ip'ga mos kelmasa) o_User_Id
  -- NULL qaytadi - ikkala holat chaqiruvchiga bir xil ko'rinadi (axborot oqib
  -- ketmasligi uchun).
  ----
  Procedure Get_Token_User
  (
    i_Access_Token in varchar2,
    i_Client_Ip    in varchar2,
    o_User_Id      out number,
    o_Partner_Code out varchar2
  );

  ----
  -- i_Allowlist (vergul bilan ajratilgan IPv4/CIDR ro'yxati) ichida i_Ip mos
  -- keluvchi yozuv bormi. i_Ip yoki i_Allowlist NULL bo'lsa - false (fail closed).
  ----
  Function Ip_Allowed(i_Ip varchar2, i_Allowlist varchar2) return boolean;

  ----
  -- MOCK - vaqtincha qoldiq: login/parolni haqiqiy tekshirish AUTH moduli
  -- tomonidan beriladi (hali tayyor emas). Imzo va xatti-harakat
  -- psbesb/Esb_User.Check_User bilan bir xil - AUTH moduli tayyor bo'lgach,
  -- shu procedure tanasi (faqat tanasi, imzosi emas) haqiqiy tekshiruv bilan
  -- almashtiriladi. Hozircha faqat CORE_USERS.NAME bo'yicha topadi, parolni
  -- TEKSHIRMAYDI.
  ----
  Procedure Check_User
  (
    i_User_Name in varchar2,
    i_Password  in varchar2,
    o_User_Id   out number,
    o_Code      out varchar2,
    o_Msg       out varchar2
  );

  Function Has_Request_By_Ext_Id
  (
    i_Partner_Code   varchar2,
    i_Ext_Request_Id varchar2
  ) return boolean;

  Procedure Select_Request
  (
    i_Id       number,
    i_Is_Raise boolean := true,
    o_Request  out Esbin_Requests%rowtype
  );

  Procedure Select_Request_By_Ext_Id
  (
    i_Partner_Code   varchar2,
    i_Ext_Request_Id varchar2,
    i_Is_Raise       boolean := true,
    o_Request        out Esbin_Requests%rowtype
  );

end Esbin_Util;
/
create or replace package body Esbin_Util is

  Procedure Select_Partner
  (
    i_Partner_Code varchar2,
    i_Is_Raise     boolean := true,
    o_Partner      out Esbin_R_Partners%rowtype
  ) is
  begin
    select *
      into o_Partner
      from Esbin_R_Partners
     where Partner_Code = i_Partner_Code;
  exception
    when no_data_found then
      if i_Is_Raise then
        raise;
      end if;
  end Select_Partner;

  Function Exists_Active_Partner(i_Partner_Code varchar2) return boolean is
    v_Partner Esbin_R_Partners%rowtype;
  begin
    Select_Partner(i_Partner_Code => i_Partner_Code, i_Is_Raise => false, o_Partner => v_Partner);
    return v_Partner.Partner_Code is not null and v_Partner.State = 'A';
  end Exists_Active_Partner;

  Procedure Select_Method
  (
    i_Method_Code varchar2,
    i_Is_Raise    boolean := true,
    o_Method      out Esbin_R_Methods%rowtype
  ) is
  begin
    select *
      into o_Method
      from Esbin_R_Methods
     where Method_Code = i_Method_Code;
  exception
    when no_data_found then
      if i_Is_Raise then
        raise;
      end if;
  end Select_Method;

  Function Has_Partner_User
  (
    i_Partner_Code varchar2,
    i_User_Id      number
  ) return boolean is
    v_Count pls_integer := 0;
  begin
    select 1
      into v_Count
      from Esbin_R_Partner_Users
     where Partner_Code = i_Partner_Code
       and User_Id = i_User_Id
       and State = 'A'
       and rownum = 1;
    return true;
  exception
    when no_data_found then
      return false;
  end Has_Partner_User;

  Function Has_User_Method_Rel
  (
    i_User_Id     number,
    i_Method_Code varchar2
  ) return boolean is
    v_Count pls_integer := 0;
  begin
    select 1
      into v_Count
      from Esbin_R_User_Method_Rel
     where User_Id = i_User_Id
       and Method_Code = i_Method_Code
       and State = 'A'
       and rownum = 1;
    return true;
  exception
    when no_data_found then
      return false;
  end Has_User_Method_Rel;

  ----
  -- PRIVATE: dotted-quad IPv4'ni 0..2^32-1 oralig'idagi songa aylantiradi.
  -- Har qanday IPv4 bo'lmagan (yoki oktet > 255) qiymatda NULL qaytaradi -
  -- fail closed. IPv6 ataylab qo'llab-quvvatlanmaydi.
  ----
  Function Ip_To_Num(i_Ip varchar2) return number is
    v_A number;
    v_B number;
    v_C number;
    v_D number;
  begin
    if i_Ip is null or not Regexp_Like(i_Ip, '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$') then
      return null;
    end if;
    v_A := To_Number(Regexp_Substr(i_Ip, '[^.]+', 1, 1));
    v_B := To_Number(Regexp_Substr(i_Ip, '[^.]+', 1, 2));
    v_C := To_Number(Regexp_Substr(i_Ip, '[^.]+', 1, 3));
    v_D := To_Number(Regexp_Substr(i_Ip, '[^.]+', 1, 4));
    if v_A > 255 or v_B > 255 or v_C > 255 or v_D > 255 then
      return null;
    end if;
    return v_A * 16777216 + v_B * 65536 + v_C * 256 + v_D;
  exception
    when others then
      return null;
  end Ip_To_Num;

  ----
  -- PRIVATE: i_Entry - bitta allowlist yozuvi ("a.b.c.d" yoki "a.b.c.d/prefix").
  -- NEEDS VERIFICATION: quyidagi BITAND chaqiruvlari 32-bitli qiymatlar
  -- (0..4294967295) bilan bu Oracle 19c instansiyasida amalda tekshirilmagan -
  -- BITAND'ning hujjatlashtirilgan NUMBER oralig'i buni qoplashi kerak, lekin
  -- production'ga tayanishdan oldin haqiqiy so'rov bilan tasdiqlang.
  ----
  Function Ip_Matches_Entry(i_Ip varchar2, i_Entry varchar2) return boolean is
    v_Entry_Ip  varchar2(50);
    v_Prefix    pls_integer;
    v_Ip_Num    number;
    v_Entry_Num number;
    v_Mask      number;
  begin
    v_Entry_Ip := Trim(Regexp_Substr(i_Entry, '^[^/]+'));
    v_Prefix   := To_Number(Regexp_Substr(i_Entry, '/(\d{1,2})$', 1, 1, null, 1));

    v_Ip_Num    := Ip_To_Num(i_Ip);
    v_Entry_Num := Ip_To_Num(v_Entry_Ip);
    if v_Ip_Num is null or v_Entry_Num is null then
      return false;
    end if;

    if v_Prefix is null then
      return v_Ip_Num = v_Entry_Num;
    end if;
    if v_Prefix > 32 or v_Prefix = 0 then
      -- /0 butun IPv4 fazoni qamrab oladi (mask=0 - HAR QANDAY IP mos keladi),
      -- allowlist gate'ini butunlay o'chirib qo'yadi - shu bois ataylab rad
      -- etiladi (fail closed), > 32 kabi noto'g'ri CIDR prefiks sifatida.
      return false;
    end if;

    v_Mask := Bitand(4294967295, Power(2, 32) - Power(2, 32 - v_Prefix));
    return Bitand(v_Ip_Num, v_Mask) = Bitand(v_Entry_Num, v_Mask);
  exception
    when others then
      return false;
  end Ip_Matches_Entry;

  Function Ip_Allowed(i_Ip varchar2, i_Allowlist varchar2) return boolean is
  begin
    if i_Ip is null or i_Allowlist is null then
      return false;
    end if;
    for r in (select Trim(Regexp_Substr(i_Allowlist, '[^,]+', 1, level)) as Entry
                from dual
              connect by Regexp_Substr(i_Allowlist, '[^,]+', 1, level) is not null) loop
      if Ip_Matches_Entry(i_Ip, r.Entry) then
        return true;
      end if;
    end loop;
    return false;
  end Ip_Allowed;

  Procedure Get_Token_User
  (
    i_Access_Token in varchar2,
    i_Client_Ip    in varchar2,
    o_User_Id      out number,
    o_Partner_Code out varchar2
  ) is
    v_Login        Esbin_Partner_Tokens.Login%type;
    v_Ip_Allowlist Esbin_R_Partner_Users.Ip_Allowlist%type;
  begin
    select t.User_Id, pu.Partner_Code, t.Login, pu.Ip_Allowlist
      into o_User_Id, o_Partner_Code, v_Login, v_Ip_Allowlist
      from Esbin_Partner_Tokens t
      join Esbin_R_Partner_Users pu on pu.User_Id = t.User_Id and pu.State = 'A'
      join Esbin_R_Partners p on p.Partner_Code = pu.Partner_Code and p.State = 'A'
     where t.Access_Token_Hash = Auth_Util.Hash_Sha256(i_Access_Token)
       and t.Revoked_On is null
       and t.Expires_On > sysdate;

    if not Ip_Allowed(i_Client_Ip, v_Ip_Allowlist) then
      Auth_Audit.Log(i_Event_Type  => 'ESBIN_TOKEN_IP_MISMATCH',
                     i_Success     => 'N',
                     i_Username    => v_Login,
                     i_User_Id     => o_User_Id,
                     i_Provider    => 'ESBIN',
                     i_Reason_Code => 'IP_NOT_ALLOWED',
                     i_Client_Ip   => i_Client_Ip);
      -- Mos kelmagan IP - chaqiruvchiga yaroqsiz token bilan bir xil ko'rinishi
      -- kerak (axborot oqib ketmasligi uchun).
      o_User_Id      := null;
      o_Partner_Code := null;
    end if;
  exception
    when no_data_found then
      o_User_Id      := null;
      o_Partner_Code := null;
  end Get_Token_User;

  ----
  -- MOCK - psbesb/Esb_User.Check_User bilan bir xil imzo/xatti-harakat
  -- (o_Code muvaffaqiyatda NULL qoladi, xato bo'lsa '100' + o_Msg). Hozircha
  -- i_Password TEKSHIRILMAYDI - faqat CORE_USERS.NAME bo'yicha topadi va
  -- STATE faolligini ko'radi. AUTH moduli tayyor bo'lgach, real tekshiruv
  -- bilan almashtiriladi (imzo o'zgarmaydi).
  ----
  Procedure Check_User
  (
    i_User_Name in varchar2,
    i_Password  in varchar2,
    o_User_Id   out number,
    o_Code      out varchar2,
    o_Msg       out varchar2
  ) is
    v_User Core_Users%rowtype;
  begin
    begin
      select *
        into v_User
        from Core_Users
       where Upper(Trim(Name)) = Upper(Trim(i_User_Name))
         and rownum = 1;
    exception
      when no_data_found then
        o_Code := '100';
        o_Msg  := 'Foydalanuvchi topilmadi: ' || i_User_Name;
        return;
    end;

    if v_User.State != 'A' then
      o_Code := '100';
      o_Msg  := 'Foydalanuvchi faol emas: ' || i_User_Name;
      return;
    end if;

    o_User_Id := v_User.User_Id;
  end Check_User;

  Function Has_Request_By_Ext_Id
  (
    i_Partner_Code   varchar2,
    i_Ext_Request_Id varchar2
  ) return boolean is
    v_Count pls_integer := 0;
  begin
    select 1
      into v_Count
      from Esbin_Requests
     where Partner_Code = i_Partner_Code
       and Ext_Request_Id = i_Ext_Request_Id
       and rownum = 1;
    return true;
  exception
    when no_data_found then
      return false;
  end Has_Request_By_Ext_Id;

  Procedure Select_Request
  (
    i_Id       number,
    i_Is_Raise boolean := true,
    o_Request  out Esbin_Requests%rowtype
  ) is
  begin
    select *
      into o_Request
      from Esbin_Requests
     where Id = i_Id;
  exception
    when no_data_found then
      if i_Is_Raise then
        raise;
      end if;
  end Select_Request;

  Procedure Select_Request_By_Ext_Id
  (
    i_Partner_Code   varchar2,
    i_Ext_Request_Id varchar2,
    i_Is_Raise       boolean := true,
    o_Request        out Esbin_Requests%rowtype
  ) is
  begin
    select *
      into o_Request
      from Esbin_Requests
     where Partner_Code = i_Partner_Code
       and Ext_Request_Id = i_Ext_Request_Id;
  exception
    when no_data_found then
      if i_Is_Raise then
        raise;
      end if;
  end Select_Request_By_Ext_Id;

end Esbin_Util;
/
