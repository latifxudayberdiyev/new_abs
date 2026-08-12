create or replace package Core_Util is
  -- Author  : ABDUQODIR
  -- Created : 07.04.2026 11:44:02
  -- Изменён : 19.05.2026 - Load_User_Key*
  -- Purpose :
  ----------------------------------------------------------------------------------------------------
  Function Load_User
  (
    i_User_Id number,
    o_Row     out Core_Users%rowtype
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  -- Загрузить ключ по identity_id.
  Function Load_User_Key
  (
    i_Identity_Id number,
    o_Row         out Core_User_Keys%rowtype
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  -- Загрузить ключ по (user_id, provider_type).
  Function Load_User_Key_For_Provider
  (
    i_User_Id       number,
    i_Provider_Type varchar2,
    o_Row           out Core_User_Keys%rowtype
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  -- Загрузить ключ по (provider_type, provider_key) - уникален по U1.
  Function Load_User_Key_By_Key
  (
    i_Provider_Type varchar2,
    i_Provider_Key  varchar2,
    o_Row           out Core_User_Keys%rowtype
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
end Core_Util;
/
create or replace package body Core_Util is
  ----------------------------------------------------------------------------------------------------
  Function Load_User
  (
    i_User_Id number,
    o_Row     out Core_Users%rowtype
  ) return boolean is
  begin
    select *
      into o_Row
      from Core_Users t
     where t.User_Id = i_User_Id;
    --
    return true;
  exception
    when No_Data_Found then
      o_Row.User_Id := i_User_Id;
      --
      return false;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Load_User_Key
  (
    i_Identity_Id number,
    o_Row         out Core_User_Keys%rowtype
  ) return boolean is
  begin
    select *
      into o_Row
      from Core_User_Keys t
     where t.Identity_Id = i_Identity_Id;
    return true;
  exception
    when No_Data_Found then
      o_Row.Identity_Id := i_Identity_Id;
      return false;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Load_User_Key_For_Provider
  (
    i_User_Id       number,
    i_Provider_Type varchar2,
    o_Row           out Core_User_Keys%rowtype
  ) return boolean is
  begin
    select *
      into o_Row
      from Core_User_Keys t
     where t.User_Id = i_User_Id
       and t.Provider_Type = i_Provider_Type;
    return true;
  exception
    when No_Data_Found then
      return false;
    when Too_Many_Rows then
      -- если у пользователя несколько ключей одного провайдера, берём активный самый свежий
      select *
        into o_Row
        from (select t.*
                from Core_User_Keys t
               where t.User_Id = i_User_Id
                 and t.Provider_Type = i_Provider_Type
               order by case when t.State = 'A' then 0 else 1 end,
                        t.Modified_On desc)
       where rownum = 1;
      return true;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Load_User_Key_By_Key
  (
    i_Provider_Type varchar2,
    i_Provider_Key  varchar2,
    o_Row           out Core_User_Keys%rowtype
  ) return boolean is
  begin
    select *
      into o_Row
      from Core_User_Keys t
     where t.Provider_Type = i_Provider_Type
       and Lower(t.Provider_Key) = Lower(i_Provider_Key);
    return true;
  exception
    when No_Data_Found then
      return false;
  end;
  ----------------------------------------------------------------------------------------------------
end Core_Util;
/
