create or replace package Core_Kernel is
  -- Author  : ABDUQODIR
  -- Created : 07.04.2026 11:24:20
  -- Изменён : 19.05.2026 - Save_User управляет массивом ключей в CORE_USER_KEYS,
  --                       sync-режим: отсутствующий в массиве ключ -> state='P'.
  -- Purpose :
  ----------------------------------------------------------------------------------------------------
  Procedure Save_User
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
  Procedure Model_User
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
  ----------------------------------------------------------------------------------------------------
end Core_Kernel;
/
create or replace package body Core_Kernel is
  -- Collect_Form_Keys validatsiya xatolari - har biri alohida kod, bitta -20001'ni ulashmasin
  c_Err_Invalid_Provider_Type constant number := -20001;
  c_Err_Invalid_Key_State     constant number := -20002;
  c_Err_Invalid_Is_Required   constant number := -20003;
  ----------------------------------------------------------------------------------------------------
  -- Обработка массива ключей пользователя (CORE_USER_KEYS) в sync-режиме.
  --
  -- Hash_t.keys = Arraylist of Hash_t. Каждый элемент:
  --   identity_id              (опц.) - PK для UPDATE; если null - ищется
  --                                     по (user_id, provider_type, provider_key)
  --   provider_type            (обяз. для INSERT)  AD / LOCAL / GOOGLE / STX_KEY ...
  --   provider_key             (обяз. для INSERT)  логин/идентификатор в провайдере
  --   password                 (опц., LOCAL) - сырой пароль, hash'ируется на сервере
  --   password_must_be_changed (опц.) Y/N
  --   is_required              (опц.) Y/N
  --   state                    (опц.) A/P/S
  --   description              (опц.)
  --
  -- Правила:
  --   * Hash_t.keys = NULL          -> ключи не трогаем (поле не прислано)
  --   * Hash_t.keys = []  (пустой)  -> все активные ключи -> P
  --   * Hash_t.keys = [...]         -> sync:
  --       - элемент найден  -> UPDATE (diff внутри Core_Dml.Update_User_Key)
  --       - элемент новый   -> INSERT
  --       - существующий ключ отсутствует в массиве -> state='P' (AUTO_PASSIVE)
  --
  -- Физически ключи не удаляются (passive = soft delete, история сохраняется).
  -- Все изменения пишутся в _H и AUTH_AUDIT_LOG
  -- (KEY_CREATED / KEY_CHANGED / PASSWORD_ADMIN_RESET).
  ----------------------------------------------------------------------------------------------------
  Procedure Handle_Keys
  (
    Io_Hash      in out nocopy Core.Hash_t,
    i_User_Id    number,
    i_Client_Ip  varchar2,
    i_User_Agent varchar2
  ) is
    type t_Seen is table of boolean index by binary_integer;
    v_Seen t_Seen;
    v_Keys Core.Arraylist;
    v_Idx  binary_integer;
  begin
    v_Keys := Io_Hash.Get_Optional_Arraylist('keys');
    --
    if v_Keys is null then
      return; -- поле keys не прислано -> ключи не трогаем
    end if;
    -- 1) собираем существующие ключи пользователя (изначально - не отмечены)
    for r in (select Identity_Id
                from Core_User_Keys
               where User_Id = i_User_Id)
    loop
      v_Seen(r.Identity_Id) := false;
    end loop;
  
    -- 2) обработка входящего массива
    for i in 1 .. v_Keys.Count
    loop
      declare
        v_Kh       Core.Hash_t := Treat(v_Keys.Get_r_Hash_t(i) as Core.Hash_t);
        v_Kid      number := v_Kh.Get_Optional_Number('identity_id');
        v_Provider varchar2(20) := v_Kh.Get_Optional_Varchar2('provider_type');
        v_Pkey     varchar2(512) := v_Kh.Get_Optional_Varchar2('provider_key');
        v_Raw_Pwd  varchar2(1000) := v_Kh.Get_Optional_Varchar2('password');
        v_Must_Chg varchar2(1) := Nvl(v_Kh.Get_Optional_Varchar2('password_must_be_changed'), 'N');
        v_Required varchar2(1) := Nvl(v_Kh.Get_Optional_Varchar2('is_required'), 'N');
        v_Kstate   varchar2(1) := Nvl(v_Kh.Get_Optional_Varchar2('state'), 'A');
        v_Kdesc    varchar2(200) := v_Kh.Get_Optional_Varchar2('description');
        v_Old      Core_User_Keys%rowtype;
        v_New      Core_User_Keys%rowtype;
        v_Found    boolean := false;
        v_Old_Pkey varchar2(512);
      begin
        -- поиск: сначала по identity_id, иначе по (provider_type, provider_key)
        if v_Kid is not null then
          v_Found := Core_Util.Load_User_Key(v_Kid, v_Old);
          if v_Found and v_Old.User_Id != i_User_Id then
            v_Found := false; -- чужой ключ
          end if;
        end if;
        if not v_Found and v_Provider is not null and v_Pkey is not null then
          v_Found := Core_Util.Load_User_Key_By_Key(v_Provider, v_Pkey, v_Old);
          if v_Found and v_Old.User_Id != i_User_Id then
            v_Found := false; -- (provider+key) занят другим юзером
          end if;
        end if;
        --
        if not v_Found then
          -- INSERT (требуются provider_type + provider_key)
          if v_Provider is null or v_Pkey is null then
            goto Next_Key;
          end if;
          --
          v_New.User_Id                  := i_User_Id;
          v_New.Provider_Type            := v_Provider;
          v_New.Provider_Key             := v_Pkey;
          v_New.Is_Required              := v_Required;
          v_New.State                    := v_Kstate;
          v_New.Description              := v_Kdesc;
          v_New.Password_Must_Be_Changed := v_Must_Chg;
          if v_Provider = Auth_Const.c_Provider_Local and v_Raw_Pwd is not null then
            v_New.Password := Auth_Util.Make_Local_Hash(v_Raw_Pwd);
          end if;
          Core_Dml.Insert_User_Key(v_New); -- внутри присваивает Identity_Id из sequence
          v_Seen(v_New.Identity_Id) := true;
          Auth_Audit.Log(Auth_Const.c_Ev_Key_Created,
                         'Y',
                         v_Pkey,
                         i_User_Id,
                         v_Provider,
                         Auth_Const.c_Rsn_Ok,
                         i_Client_Ip,
                         i_User_Agent);
        else
          -- UPDATE
          v_New      := v_Old;
          v_Old_Pkey := v_Old.Provider_Key;
          --
          if v_Provider is not null and v_Old.Provider_Type != v_Provider then
            v_New.Provider_Type := v_Provider;
          end if;
          if v_Pkey is not null and Lower(v_Old.Provider_Key) != Lower(v_Pkey) then
            v_New.Provider_Key := v_Pkey;
          end if;
          if Nvl(v_Old.Is_Required, 'N') != v_Required then
            v_New.Is_Required := v_Required;
          end if;
          if Nvl(v_Old.State, 'A') != v_Kstate then
            v_New.State := v_Kstate;
          end if;
          if Nvl(v_Old.Description, '~') != Nvl(v_Kdesc, '~') then
            v_New.Description := v_Kdesc;
          end if;
          if Nvl(v_Old.Password_Must_Be_Changed, 'N') != v_Must_Chg then
            v_New.Password_Must_Be_Changed := v_Must_Chg;
          end if;
          if v_New.Provider_Type = Auth_Const.c_Provider_Local and v_Raw_Pwd is not null then
            v_New.Password                 := Auth_Util.Make_Local_Hash(v_Raw_Pwd);
            v_New.Password_Must_Be_Changed := 'Y';
            v_New.Password_Expiry_Date     := null;
          end if;
          --
          Core_Dml.Update_User_Key(v_New); -- внутри проверяет реальные изменения и пишет _H
          --
          v_Seen(v_Old.Identity_Id) := true;
          --
          if v_Pkey is not null and Lower(v_Old_Pkey) != Lower(v_Pkey) then
            Auth_Audit.Log(Auth_Const.c_Ev_Key_Changed,
                           'Y',
                           v_New.Provider_Key,
                           i_User_Id,
                           v_New.Provider_Type,
                           'OLD=' || v_Old_Pkey,
                           i_Client_Ip,
                           i_User_Agent);
          end if;
          --
          if v_New.Provider_Type = Auth_Const.c_Provider_Local and v_Raw_Pwd is not null then
            Auth_Audit.Log(Auth_Const.c_Ev_Pwd_Admin_Set,
                           'Y',
                           v_New.Provider_Key,
                           i_User_Id,
                           v_New.Provider_Type,
                           Auth_Const.c_Rsn_Ok,
                           i_Client_Ip,
                           i_User_Agent);
          end if;
        end if;
        --
        <<next_Key>>
        null;
      end;
    end loop;
    -- 3) SYNC: ключи, которых нет в массиве -> переводим в state='P'
    v_Idx := v_Seen.First;
    --
    while v_Idx is not null
    loop
      if not v_Seen(v_Idx) then
        declare
          v_Old Core_User_Keys%rowtype;
          v_New Core_User_Keys%rowtype;
        begin
          -- обязательный фактор (is_required='Y') нельзя авто-пассивировать:
          -- иначе случайный недосыл ключа в массиве заблокировал бы вход
          if Core_Util.Load_User_Key(v_Idx, v_Old) and v_Old.State != Auth_Const.c_State_Passive and
             Nvl(v_Old.Is_Required, 'N') != 'Y' then
            v_New       := v_Old;
            v_New.State := Auth_Const.c_State_Passive;
            Core_Dml.Update_User_Key(v_New);
            Auth_Audit.Log(Auth_Const.c_Ev_Key_Changed,
                           'Y',
                           v_Old.Provider_Key,
                           i_User_Id,
                           v_Old.Provider_Type,
                           'AUTO_PASSIVE',
                           i_Client_Ip,
                           i_User_Agent);
          end if;
        end;
      end if;
      v_Idx := v_Seen.Next(v_Idx);
    end loop;
  end;
  ----------------------------------------------------------------------------------------------------
  -- user.jsp insdel-qatoridan kelgan parallel massivlarni (identity_id[],
  -- provider_type[], provider_key[], password[], is_required[], key_state[])
  -- Handle_Keys kutgan 'keys' arraylist shakliga o'giradi. Haqiqiy JSON API
  -- chaqiruvi (Io_Hash'da 'keys' allaqachon bor bo'lsa) tegilmaydi.
  -- provider_type/state qiymatlari FORMADAN kelgani uchun bu yerda serverda
  -- whitelist qilinadi - hech qachon UI'ga ishonilmaydi.
  Procedure Collect_Form_Keys(Io_Hash in out nocopy Core.Hash_t) is
    v_Ids    Core.Array_Varchar2 := Io_Hash.Get_Optional_Array_Varchar2('identity_id');
    v_Types  Core.Array_Varchar2 := Io_Hash.Get_Optional_Array_Varchar2('provider_type');
    v_Pkeys  Core.Array_Varchar2 := Io_Hash.Get_Optional_Array_Varchar2('provider_key');
    v_Pwds   Core.Array_Varchar2 := Io_Hash.Get_Optional_Array_Varchar2('password');
    v_Reqs   Core.Array_Varchar2 := Io_Hash.Get_Optional_Array_Varchar2('is_required');
    v_States Core.Array_Varchar2 := Io_Hash.Get_Optional_Array_Varchar2('key_state');
    v_List   Core.Arraylist := Core.Arraylist();
    v_Kh     Core.Hash_t;
    --
    Function El(a Core.Array_Varchar2, i pls_integer) return varchar2 is
    begin
      if a is null or a.Count < i then
        return null;
      end if;
      return a(i);
    end;
  begin
    if Io_Hash.Has('keys') then
      return; -- haqiqiy JSON API chaqiruvi - 'keys' allaqachon to'g'ri shaklda
    end if;
    if v_Pkeys is null or v_Pkeys.Count = 0 then
      return; -- forma kalit yubormadi (masalan bo'sh shablon qator saqlanmadi)
    end if;
    --
    for i in 1 .. v_Pkeys.Count loop
      if El(v_Pkeys, i) is not null then
        if El(v_Types, i) not in (Auth_Const.c_Provider_Local, Auth_Const.c_Provider_Ad) then
          Raise_Application_Error(c_Err_Invalid_Provider_Type, 'INVALID PROVIDER_TYPE');
        end if;
        if Nvl(El(v_States, i), 'A') not in ('A', 'P') then
          Raise_Application_Error(c_Err_Invalid_Key_State, 'INVALID KEY STATE');
        end if;
        if Nvl(El(v_Reqs, i), 'N') not in ('Y', 'N') then
          Raise_Application_Error(c_Err_Invalid_Is_Required, 'INVALID IS_REQUIRED');
        end if;
        --
        v_Kh := Core.Hash_t();
        if El(v_Ids, i) is not null then
          v_Kh.Put('identity_id', to_number(El(v_Ids, i)));
        end if;
        v_Kh.Put('provider_type', El(v_Types, i));
        v_Kh.Put('provider_key', El(v_Pkeys, i));
        if El(v_Pwds, i) is not null then
          v_Kh.Put('password', El(v_Pwds, i));
        end if;
        v_Kh.Put('is_required', Nvl(El(v_Reqs, i), 'N'));
        v_Kh.Put('state', Nvl(El(v_States, i), 'A'));
        v_List.Push(v_Kh);
      end if;
    end loop;
    if v_List.Count > 0 then
      Io_Hash.Put('keys', v_List);
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Save_User
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Cache     Core.Hash_t := Io_Hash.Get_Optional_Hash_t('sm_cache');
    v_Row       Core_Users%rowtype;
    v_Old_Row   Core_Users%rowtype;
    v_Is_Create boolean;
    v_Ip        varchar2(45) := Io_Hash.Get_Optional_Varchar2('client_ip');
    v_Ua        varchar2(400) := Io_Hash.Get_Optional_Varchar2('user_agent');
  begin
    savepoint Sp_Save_User;
    o_Code      := Core.Core_Const.c_Success_Code;
    v_Is_Create := (v_Cache.Get_Optional_Varchar2('is_create') = 'Y');
    --
    v_Row.User_Id          := Io_Hash.Get_Number('user_id');
    v_Row.Cb_Code          := Lpad(Io_Hash.Get_Varchar2('cb_code'), 5, '0');
    v_Row.Local_Code       := Lpad(Io_Hash.Get_Varchar2('local_code'), 5, '0');
    v_Row.User_Type_Id     := Nvl(Io_Hash.Get_Optional_Number('user_type_id'), 0);
    v_Row.Name             := Io_Hash.Get_Varchar2('full_name');
    v_Row.Pinfl            := Io_Hash.Get_Varchar2('pinfl');
    v_Row.Date_Birth       := Io_Hash.Get_Optional_Date('date_birth', 'dd.mm.yyyy');
    v_Row.Hr_User_Id       := Io_Hash.Get_Optional_Number('hr_user_id');
    v_Row.Phone_Number     := Io_Hash.Get_Optional_Varchar2('phone_number');
    v_Row.Email            := Io_Hash.Get_Optional_Varchar2('email');
    v_Row.Language         := Nvl(Io_Hash.Get_Optional_Varchar2('language'), 'ru');
    v_Row.Theme_Id         := Nvl(Io_Hash.Get_Optional_Number('theme_id'), 0);
    v_Row.Is_Access_Denied := Nvl(Io_Hash.Get_Varchar2('is_access_denied'), 'Y');
    v_Row.State            := Io_Hash.Get_Varchar2('state');
    v_Row.Activate_Date    := Io_Hash.Get_Date('activate_date', 'dd.mm.yyyy');
    v_Row.Deactivate_Date  := Nvl(Io_Hash.Get_Optional_Date('deactivate_date', 'dd.mm.yyyy'),
                                  to_date('31.12.9999', 'dd.mm.yyyy'));
    v_Row.Virtual_Fields   := Io_Hash.Get_Optional_Varchar2('virtual_fields');
    --
    if v_Is_Create then
      v_Row.User_Id := v_Cache.Get_Number('user_id');
      v_Row.Access_Level_Set := 0;
      v_Row.Group_Set        := Hextoraw('00');
      v_Row.Debug := 'N';
      --
      Core_Dml.Insert_User(Io_Row => v_Row);
    else
      if not Core_Util.Load_User(i_User_Id => v_Row.User_Id, o_Row => v_Old_Row) then
        o_Code := Core.Core_Const.c_Err_Not_Found;
        o_Msg  := 'USER NOT FOUND USER ID:' || v_Row.User_Id;
        return;
      end if;
      --
      v_Row.Access_Level_Set := v_Old_Row.Access_Level_Set;
      v_Row.Group_Set        := v_Old_Row.Group_Set;
      v_Row.Created_By       := v_Old_Row.Created_By;
      v_Row.Created_On       := v_Old_Row.Created_On;
      -- DIQQAT: DEBUG - Core_Api.Is_Debug_User orqali process-guard'ni (Core_Api.pck)
      -- chetlab o'tish huquqini beruvchi avtorizatsiya-bypass bayrog'i - FAQAT DBA
      -- tomonidan to'g'ridan-to'g'ri SQL orqali qo'yiladi, jonli JSP saqlash formasida
      -- bunday maydon UMUMAN YO'Q. Shu sabab bu qiymat Io_Hash'dan HECH QACHON
      -- o'qilmaydi (client so'roviga ishonilmaydi) - eski qiymat har doim so'zsiz
      -- saqlanadi.
      v_Row.Debug := v_Old_Row.Debug;
      --
      Core_Dml.Update_User(Io_Row => v_Row);
    end if;
    -- SYNC массива ключей (CORE_USER_KEYS): любые провайдеры (AD/LOCAL/...)
    Collect_Form_Keys(Io_Hash);
    Handle_Keys(Io_Hash, v_Row.User_Id, v_Ip, v_Ua);
  exception
    when others then
      -- атомарность: откатываем только изменения этого Save_User
      rollback to Sp_Save_User;
      o_Code    := Core.Core_Const.c_Err_Unhandled;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
  -- Foydalanuvchi modelini o'qish (edit forma uchun, Property_Model konvensiyasiga mos).
  ----------------------------------------------------------------------------------------------------
  Procedure Model_User
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Form       Core.Hash_t := Core.Hash_t();
    v_Data       Core.Hash_t := Core.Hash_t();
    v_Row        Core_Users%rowtype;
    v_Ident_Ids  Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Prov_Types Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Prov_Keys  Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Requireds  Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Key_States Core.Array_Varchar2 := Core.Array_Varchar2();
  begin
    o_Code        := Core.Core_Const.c_Success_Code;
    v_Row.User_Id := Io_Hash.Get_Number('user_id');
    --
    if not Core_Util.Load_User(i_User_Id => v_Row.User_Id, o_Row => v_Row) then
      o_Code := Core.Core_Const.c_Err_Not_Found;
      o_Msg  := 'USER NOT FOUND USER ID:' || v_Row.User_Id;
      return;
    end if;
    --
    -- fillForm() insdel qatoriga mos - parallel massivlar (bitta obyekt-massiv EMAS).
    -- LOCAL har doim birinchi qatorda chiqishi uchun tartiblab olinadi.
    select to_char(t.Identity_Id), t.Provider_Type, t.Provider_Key,
           Nvl(t.Is_Required, 'N'), Nvl(t.State, 'A')
      bulk collect into v_Ident_Ids, v_Prov_Types, v_Prov_Keys, v_Requireds, v_Key_States
      from Core_User_Keys t
     where t.User_Id = v_Row.User_Id
     order by case when t.Provider_Type = Auth_Const.c_Provider_Local then 0 else 1 end,
              t.Identity_Id;
    --
    v_Form.Put('user_id', v_Row.User_Id);
    v_Form.Put('cb_code', v_Row.Cb_Code);
    v_Form.Put('local_code', v_Row.Local_Code);
    v_Form.Put('user_type_id', v_Row.User_Type_Id);
    v_Form.Put('full_name', v_Row.Name);
    v_Form.Put('pinfl', v_Row.Pinfl);
    v_Form.Put('date_birth', to_char(v_Row.Date_Birth, 'dd.mm.yyyy'));
    if v_Row.Hr_User_Id is not null then
      v_Form.Put('hr_user_id', v_Row.Hr_User_Id);
    end if;
    v_Form.Put('phone_number', v_Row.Phone_Number);
    v_Form.Put('email', v_Row.Email);
    v_Form.Put('is_access_denied', v_Row.Is_Access_Denied);
    v_Form.Put('state', v_Row.State);
    v_Form.Put('activate_date', to_char(v_Row.Activate_Date, 'dd.mm.yyyy'));
    v_Form.Put('deactivate_date', to_char(v_Row.Deactivate_Date, 'dd.mm.yyyy'));
    --
    -- Bo'sh massiv fillForm()ni buzadi (v.length!=0 tekshiruvidan o'tolmay
    -- object-shoxobchaga tushib qoladi) - shuning uchun kalit yo'q bo'lsa
    -- bu 5 ta kalitni umuman yubormaymiz (forma o'z bo'sh shablon qatorida qoladi).
    if v_Prov_Keys.Count > 0 then
      v_Form.Put('identity_id', v_Ident_Ids);
      v_Form.Put('provider_type', v_Prov_Types);
      v_Form.Put('provider_key', v_Prov_Keys);
      v_Form.Put('is_required', v_Requireds);
      v_Form.Put('key_state', v_Key_States);
    end if;
    --
    v_Data.Put('fm', v_Form);
    Io_Hash.Put('data', v_Data);
  exception
    when others then
      o_Code    := Core.Core_Const.c_Err_Unhandled;
      o_Msg     := sqlerrm;
      o_Ora_Msg := sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end;
  ----------------------------------------------------------------------------------------------------
end Core_Kernel;
/
