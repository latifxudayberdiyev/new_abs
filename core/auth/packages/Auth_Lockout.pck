create or replace package Auth_Lockout is
  -- Author      : CROBS
  -- Created     : 18.05.2026
  -- Назначение  : Блокировка от перебора по имени пользователя. Проверяется ДО bind в AD,
  --               чтобы трафик атакующего не доходил до AD и не блокировал реальную учётную
  --               запись AD.
  ----------------------------------------------------------------------------------------------------
  -- Заблокировано ли имя пользователя сейчас? Время разблокировки в o_Locked_Until.
  Function Is_Locked
  (
    i_Username     in varchar2,
    o_Locked_Until out date
  ) return boolean;
  ----------------------------------------------------------------------------------------------------
  -- Зарегистрировать одну неудачную попытку (прогрессивная блокировка).
  -- Автономно - сохраняется даже при откате вызывающей транзакции.
  Procedure Register_Failure(i_Username varchar2);
  ----------------------------------------------------------------------------------------------------
  -- Сбросить серию после успешного входа.
  Procedure Reset(i_Username varchar2);
  ----------------------------------------------------------------------------------------------------
end Auth_Lockout;
/
create or replace package body Auth_Lockout is
  ----------------------------------------------------------------------------------------------------
  Function Is_Locked
  (
    i_Username     in varchar2,
    o_Locked_Until out date
  ) return boolean is
    v_Username varchar2(100) := Auth_Util.Norm_Username(i_Username);
  begin
    o_Locked_Until := null;
    --
    select Locked_Until
      into o_Locked_Until
      from Auth_Lockouts
     where Username = v_Username;
    return(o_Locked_Until is not null and o_Locked_Until > sysdate);
  exception
    when No_Data_Found then
      return false;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Register_Failure(i_Username varchar2) is
    pragma autonomous_transaction;
    v_Username varchar2(100) := Auth_Util.Norm_Username(i_Username);
    v_Fail     number;
    v_Level    number;
    v_First    date;
    v_Last     date;
  begin
    begin
      select Fail_Count, Lock_Level, First_Fail_On, Last_Fail_On
        into v_Fail, v_Level, v_First, v_Last
        from Auth_Lockouts
       where Username = v_Username
         for update;
    exception
      when No_Data_Found then
        insert into Auth_Lockouts
          (Username,
           Fail_Count,
           Lock_Level,
           First_Fail_On,
           Last_Fail_On,
           Locked_Until,
           Modified_On)
        values
          (v_Username, 1, 0, sysdate, sysdate, null, sysdate);
        commit;
        return;
    end;
    -- сброс серии, если тишина дольше настроенного окна
    if v_Last < sysdate - Auth_Const.c_Lock_Streak_Min / 1440 then
      v_Fail  := 0;
      v_Level := 0;
      v_First := sysdate;
    end if;
    --
    v_Fail := v_Fail + 1;
    --
    if v_Fail >= Auth_Const.c_Lock_Threshold then
      v_Level := v_Level + 1;
      --
      update Auth_Lockouts
         set Fail_Count    = 0,
             Lock_Level    = v_Level,
             First_Fail_On = v_First,
             Last_Fail_On  = sysdate,
             Locked_Until  = sysdate + Auth_Util.Lock_Minutes(v_Level) / 1440,
             Modified_On   = sysdate
       where Username = v_Username;
    else
      update Auth_Lockouts
         set Fail_Count    = v_Fail,
             First_Fail_On = v_First,
             Last_Fail_On  = sysdate,
             Modified_On   = sysdate
       where Username = v_Username;
    end if;
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Reset(i_Username varchar2) is
    pragma autonomous_transaction;
    v_Username varchar2(100) := Auth_Util.Norm_Username(i_Username);
  begin
    update Auth_Lockouts
       set Fail_Count   = 0,
           Lock_Level   = 0,
           Locked_Until = null,
           Modified_On  = sysdate
     where Username = v_Username;
    --
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Lockout;
/
