create or replace package Core_Dml is
  -- Author  : ABDUQODIR
  -- Created : 07.04.2026 11:44:02
  -- Изменён : 19.05.2026 - DML для CORE_USER_KEYS
  -- Purpose :
  ----------------------------------------------------------------------------------------------------
  Procedure Insert_User(Io_Row in out Core_Users%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Update_User(Io_Row in out Core_Users%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Delete_User(Io_Row in out Core_Users%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Sync_Branches(Io_Row in out Abs_Branches%rowtype);
  ----------------------------------------------------------------------------------------------------
  Procedure Sync_r_Org_Units(Io_Row in out Abs_r_Org_Units%rowtype);
  ----------------------------------------------------------------------------------------------------
  -- CORE_USER_KEYS
  Procedure Insert_User_Key(Io_Row in out Core_User_Keys%rowtype);
  Procedure Update_User_Key(Io_Row in out Core_User_Keys%rowtype);
  Procedure Delete_User_Key(Io_Row in out Core_User_Keys%rowtype);
  ----------------------------------------------------------------------------------------------------
end Core_Dml;
/
create or replace package body Core_Dml is
  ----------------------------------------------------------------------------------------------------
  Function Is_Value_Changed
  (
    i_Old_Value in varchar2,
    i_New_Value in varchar2
  ) return boolean is
  begin
    if i_Old_Value is null and i_New_Value is null then
      return false;
    elsif i_Old_Value is null or i_New_Value is null then
      return true;
    elsif i_Old_Value != i_New_Value then
      return true;
    else
      return false;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Is_Value_Changed
  (
    i_Old_Value in date,
    i_New_Value in date
  ) return boolean is
  begin
    if i_Old_Value is null and i_New_Value is null then
      return false;
    elsif i_Old_Value is null or i_New_Value is null then
      return true;
    elsif i_Old_Value != i_New_Value then
      return true;
    else
      return false;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Is_Value_Changed
  (
    i_Old_Value in number,
    i_New_Value in number
  ) return boolean is
  begin
    if i_Old_Value is null and i_New_Value is null then
      return false;
    elsif i_Old_Value is null or i_New_Value is null then
      return true;
    elsif i_Old_Value != i_New_Value then
      return true;
    else
      return false;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Log_User
  (
    i_Row    Core_Users%rowtype,
    i_Action in varchar2
  ) is
    v_Row Core_Users_h%rowtype;
  begin
    v_Row.User_Id          := i_Row.User_Id;
    v_Row.Cb_Code          := i_Row.Cb_Code;
    v_Row.Local_Code       := i_Row.Local_Code;
    v_Row.User_Type_Id     := i_Row.User_Type_Id;
    v_Row.Name             := i_Row.Name;
    v_Row.Pinfl            := i_Row.Pinfl;
    v_Row.Date_Birth       := i_Row.Date_Birth;
    v_Row.Hr_User_Id       := i_Row.Hr_User_Id;
    v_Row.Phone_Number     := i_Row.Phone_Number;
    v_Row.Email            := i_Row.Email;
    v_Row.Language         := i_Row.Language;
    v_Row.Theme_Id         := i_Row.Theme_Id;
    v_Row.Is_Access_Denied := i_Row.Is_Access_Denied;
    v_Row.Access_Level_Set := i_Row.Access_Level_Set;
    v_Row.Group_Set        := i_Row.Group_Set;
    v_Row.Debug            := i_Row.Debug;
    v_Row.State            := i_Row.State;
    v_Row.Activate_Date    := i_Row.Activate_Date;
    v_Row.Deactivate_Date  := i_Row.Deactivate_Date;
    v_Row.Virtual_Fields   := i_Row.Virtual_Fields;
    v_Row.Created_On       := i_Row.Created_On;
    v_Row.Created_By       := i_Row.Created_By;
    v_Row.Modified_On      := i_Row.Modified_On;
    v_Row.Modified_By      := i_Row.Modified_By;
    v_Row.Action           := i_Action;
    v_Row.Action_Date      := Trunc(sysdate);
    --
    insert into Core_Users_h
    values v_Row;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Insert_User(Io_Row in out Core_Users%rowtype) is
  begin
    Io_Row.Created_On  := sysdate;
    Io_Row.Created_By  := Core.User_Env.Get_User_Id;
    Io_Row.Modified_On := sysdate;
    Io_Row.Modified_By := Core.User_Env.Get_User_Id;
    --
    insert into Core_Users
    values Io_Row;
    Log_User(Io_Row, Core_Const.c_Log_Insert);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Update_User(Io_Row in out Core_Users%rowtype) is
    v_Old_Row Core_Users%rowtype;
  begin
    if Core_Util.Load_User(i_User_Id => Io_Row.User_Id, o_Row => v_Old_Row) then
      if Is_Value_Changed(v_Old_Row.Cb_Code, Io_Row.Cb_Code) or
         Is_Value_Changed(v_Old_Row.Local_Code, Io_Row.Local_Code) or
         Is_Value_Changed(v_Old_Row.User_Type_Id, Io_Row.User_Type_Id) or
         Is_Value_Changed(v_Old_Row.Name, Io_Row.Name) or
         Is_Value_Changed(v_Old_Row.Pinfl, Io_Row.Pinfl) or
         Is_Value_Changed(v_Old_Row.Date_Birth, Io_Row.Date_Birth) or
         Is_Value_Changed(v_Old_Row.Hr_User_Id, Io_Row.Hr_User_Id) or
         Is_Value_Changed(v_Old_Row.Phone_Number, Io_Row.Phone_Number) or
         Is_Value_Changed(v_Old_Row.Email, Io_Row.Email) or
         Is_Value_Changed(v_Old_Row.Language, Io_Row.Language) or
         Is_Value_Changed(v_Old_Row.Theme_Id, Io_Row.Theme_Id) or
         Is_Value_Changed(v_Old_Row.Debug, Io_Row.Debug) or
         Is_Value_Changed(v_Old_Row.Is_Access_Denied, Io_Row.Is_Access_Denied) or
         Is_Value_Changed(v_Old_Row.State, Io_Row.State) or
         Is_Value_Changed(v_Old_Row.Activate_Date, Io_Row.Activate_Date) or
         Is_Value_Changed(v_Old_Row.Deactivate_Date, Io_Row.Deactivate_Date) or
         Is_Value_Changed(v_Old_Row.Virtual_Fields, Io_Row.Virtual_Fields) then
        --
        Io_Row.Modified_On := sysdate;
        Io_Row.Modified_By := Core.User_Env.Get_User_Id;
        --
        update Core_Users t
           set t.Cb_Code         = Io_Row.Cb_Code,
               t.Local_Code      = Io_Row.Local_Code,
               t.User_Type_Id    = Io_Row.User_Type_Id,
               t.Name            = Io_Row.Name,
               t.Pinfl           = Io_Row.Pinfl,
               t.Date_Birth      = Io_Row.Date_Birth,
               t.Hr_User_Id      = Io_Row.Hr_User_Id,
               t.Phone_Number    = Io_Row.Phone_Number,
               t.Email           = Io_Row.Email,
               t.Language        = Io_Row.Language,
               t.Theme_Id        = Io_Row.Theme_Id,
               t.Debug           = Io_Row.Debug,
               t.Is_Access_Denied = Io_Row.Is_Access_Denied,
               t.State           = Io_Row.State,
               t.Activate_Date   = Io_Row.Activate_Date,
               t.Deactivate_Date = Io_Row.Deactivate_Date,
               t.Virtual_Fields  = Io_Row.Virtual_Fields,
               t.Modified_On     = Io_Row.Modified_On,
               t.Modified_By     = Io_Row.Modified_By
         where t.User_Id = Io_Row.User_Id;
        Log_User(Io_Row, Core_Const.c_Log_Update);
      end if;
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Delete_User(Io_Row in out Core_Users%rowtype) is
  begin
    Io_Row.Modified_By := Core.User_Env.Get_User_Id;
    Io_Row.Modified_On := sysdate;
    --
    delete from Core_Users t
     where t.User_Id = Io_Row.User_Id;
    Log_User(Io_Row, Core_Const.c_Log_Delete);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Sync_Branches(Io_Row in out Abs_Branches%rowtype) is
  begin
    Io_Row.Last_Sync := sysdate;
    --
    merge into Abs_Branches t
    using dual
    on (t.Code = Io_Row.Code)
    when matched then
      update
         set t.Cb_Code         = Io_Row.Cb_Code,
             t.Code_Type       = Io_Row.Code_Type,
             t.Code_Header     = Io_Row.Code_Header,
             t.Code_Bank       = Io_Row.Code_Bank,
             t.Local_Code      = Io_Row.Local_Code,
             t.Filial_Code     = Io_Row.Filial_Code,
             t.Branch_Id       = Io_Row.Branch_Id,
             t.Name            = Io_Row.Name,
             t.Filial_Number   = Io_Row.Filial_Number,
             t.Condition       = Io_Row.Condition,
             t.Date_Activ      = Io_Row.Date_Activ,
             t.Date_Deact      = Io_Row.Date_Deact,
             t.Code_District   = Io_Row.Code_District,
             t.Address         = Io_Row.Address,
             t.City            = Io_Row.City,
             t.Has_Balance     = Io_Row.Has_Balance,
             t.Union_Code      = Io_Row.Union_Code,
             t.Date_Open       = Io_Row.Date_Open,
             t.Region_Code     = Io_Row.Region_Code,
             t.Branch_Uid      = Io_Row.Branch_Uid,
             t.Activate_Date   = Io_Row.Activate_Date,
             t.Deactivate_Date = Io_Row.Deactivate_Date,
             t.Last_Sync       = Io_Row.Last_Sync
    when not matched then
      insert values Io_Row;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Sync_r_Org_Units(Io_Row in out Abs_r_Org_Units%rowtype) is
  begin
    Io_Row.Last_Sync := sysdate;
    --
    merge into Abs_r_Org_Units t
    using dual
    on (t.Org_Unit_Id = Io_Row.Org_Unit_Id)
    when matched then
      update
         set t.Org_Unit_Name    = Io_Row.Org_Unit_Name,
             t.Label            = Io_Row.Label,
             t.Org_Unit_Level   = Io_Row.Org_Unit_Level,
             t.Access_Level_Set = Io_Row.Access_Level_Set,
             t.State            = Io_Row.State,
             t.Activate_Date    = Io_Row.Activate_Date,
             t.Deactivate_Date  = Io_Row.Deactivate_Date,
             t.Description      = Io_Row.Description,
             t.Type_Filial      = Io_Row.Type_Filial,
             t.Last_Sync        = Io_Row.Last_Sync
    when not matched then
      insert values Io_Row;
  end;
  ----------------------------------------------------------------------------------------------------
  -- ===================================================================
  -- CORE_USER_KEYS
  -- ===================================================================
  Procedure Log_User_Key
  (
    i_Row    Core_User_Keys%rowtype,
    i_Action in varchar2
  ) is
    v_Row Core_User_Keys_h%rowtype;
  begin
    v_Row.Identity_Id              := i_Row.Identity_Id;
    v_Row.User_Id                  := i_Row.User_Id;
    v_Row.Provider_Type            := i_Row.Provider_Type;
    v_Row.Provider_Key             := i_Row.Provider_Key;
    v_Row.Is_Required              := i_Row.Is_Required;
    v_Row.Password                 := i_Row.Password;
    v_Row.Password_Must_Be_Changed := i_Row.Password_Must_Be_Changed;
    v_Row.Password_Expiry_Date     := i_Row.Password_Expiry_Date;
    v_Row.State                    := i_Row.State;
    v_Row.Modified_By              := i_Row.Modified_By;
    v_Row.Modified_On              := i_Row.Modified_On;
    v_Row.Description              := i_Row.Description;
    v_Row.Action                   := i_Action;
    v_Row.Action_Date              := Trunc(sysdate);
    --
    insert into Core_User_Keys_h
    values v_Row;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Insert_User_Key(Io_Row in out Core_User_Keys%rowtype) is
  begin
    if Io_Row.Identity_Id is null then
      Io_Row.Identity_Id := Core_User_Keys_Sq.Nextval;
    end if;
    Io_Row.Modified_On              := sysdate;
    Io_Row.Modified_By              := Core.User_Env.Get_User_Id;
    Io_Row.Is_Required              := Nvl(Io_Row.Is_Required, 'N');
    Io_Row.Password_Must_Be_Changed := Nvl(Io_Row.Password_Must_Be_Changed, 'N');
    Io_Row.State                    := Nvl(Io_Row.State, 'A');
    -- normalize key: U1(provider_type, provider_key) and login are
    -- case-insensitive (AD/LOCAL). Duplicates Fido/fido excluded.
    Io_Row.Provider_Key             := Lower(Io_Row.Provider_Key);
    --
    insert into Core_User_Keys
    values Io_Row;
    Log_User_Key(Io_Row, Core_Const.c_Log_Insert);
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Update_User_Key(Io_Row in out Core_User_Keys%rowtype) is
    v_Old Core_User_Keys%rowtype;
  begin
    if not Core_Util.Load_User_Key(Io_Row.Identity_Id, v_Old) then
      return;
    end if;
    -- normalize key (see Insert_User_Key)
    Io_Row.Provider_Key := Lower(Io_Row.Provider_Key);
    if Is_Value_Changed(v_Old.User_Id, Io_Row.User_Id) or
       Is_Value_Changed(v_Old.Provider_Type, Io_Row.Provider_Type) or
       Is_Value_Changed(v_Old.Provider_Key, Io_Row.Provider_Key) or
       Is_Value_Changed(v_Old.Is_Required, Io_Row.Is_Required) or
       Is_Value_Changed(v_Old.Password, Io_Row.Password) or
       Is_Value_Changed(v_Old.Password_Must_Be_Changed, Io_Row.Password_Must_Be_Changed) or
       Is_Value_Changed(v_Old.Password_Expiry_Date, Io_Row.Password_Expiry_Date) or
       Is_Value_Changed(v_Old.State, Io_Row.State) or
       Is_Value_Changed(v_Old.Description, Io_Row.Description) then
      Io_Row.Modified_On := sysdate;
      Io_Row.Modified_By := Core.User_Env.Get_User_Id;
      update Core_User_Keys t
         set t.User_Id                  = Io_Row.User_Id,
             t.Provider_Type            = Io_Row.Provider_Type,
             t.Provider_Key             = Io_Row.Provider_Key,
             t.Is_Required              = Io_Row.Is_Required,
             t.Password                 = Io_Row.Password,
             t.Password_Must_Be_Changed = Io_Row.Password_Must_Be_Changed,
             t.Password_Expiry_Date     = Io_Row.Password_Expiry_Date,
             t.State                    = Io_Row.State,
             t.Description              = Io_Row.Description,
             t.Modified_On              = Io_Row.Modified_On,
             t.Modified_By              = Io_Row.Modified_By
       where t.Identity_Id = Io_Row.Identity_Id;
      Log_User_Key(Io_Row, Core_Const.c_Log_Update);
    end if;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Delete_User_Key(Io_Row in out Core_User_Keys%rowtype) is
  begin
    Io_Row.Modified_On := sysdate;
    Io_Row.Modified_By := Core.User_Env.Get_User_Id;
    delete from Core_User_Keys t
     where t.Identity_Id = Io_Row.Identity_Id;
    Log_User_Key(Io_Row, Core_Const.c_Log_Delete);
  end;
  ----------------------------------------------------------------------------------------------------
end Core_Dml;
/
