create or replace package Core_Dashboard is
  ----------------------------------------------------------------------------------------------------
  -- Read-only KPI queries for the main.jsp dashboard home view. No DML, no user input,
  -- no bind variables needed (all predicates are literals). Definer rights (package default).
  ----------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------
  -- Core_Api.Get_Page_Init ('dashboard_home') orqali chaqiriladigan yagona kirish
  -- nuqtasi - yuqoridagi 4 ta hisoblagichni va 7-kunlik grafik ma'lumotlarini
  -- bitta Io_Hash'ga yig'ib beradi (avval 6 ta alohida chaqiruv edi).
  Procedure Get_Home
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );
end Core_Dashboard;
/
create or replace package body Core_Dashboard is
  ----------------------------------------------------------------------------------------------------
  Procedure Get_Home
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Logins_7d Core.Arraylist := Core.Arraylist();
    v_Events    Core.Arraylist := Core.Arraylist();
    v_Row       Core.Hash_t;
    v_Users     number;
    v_Sessions  number;
    v_Logins    number;
  begin
    select (select count(*) from Core.Core_Users where state = 'A'),
           (select count(*)
              from Core.Auth_Sessions
             where state = 'A'
               and idle_expires_on > sysdate),
           (select count(*)
              from Core.Auth_Audit_Log
             where event_type = 'LOGIN_OK'
               and event_on >= trunc(sysdate))
      into v_Users, v_Sessions, v_Logins
      from dual;
    Io_Hash.Put('users', v_Users);
    -- "Rollar" (roles) konsepti olib tashlangan (remove_roles_concept.sql), lekin
    -- dashboard.jsp hali ham data.get("roles") o'qiydi - kalitni butunlay olib
    -- tashlash JSP'ni buzadi, shuning uchun 0 literal sifatida saqlanadi.
    Io_Hash.Put('roles', 0);
    Io_Hash.Put('sessions', v_Sessions);
    Io_Hash.Put('logins_today', v_Logins);
    --
    for r in (select Trunc(event_on) d,
                     sum(case when event_type = 'LOGIN_OK' then 1 else 0 end) ok_cnt,
                     sum(case when event_type = 'LOGIN_FAIL' then 1 else 0 end) fail_cnt
                from Core.Auth_Audit_Log
               where event_on >= Trunc(sysdate) - 6
               group by Trunc(event_on)
               order by d)
    loop
      v_Row := Core.Hash_t();
      v_Row.Put('d', To_Char(r.d, 'dd.mm'));
      v_Row.Put('ok', r.ok_cnt);
      v_Row.Put('fail', r.fail_cnt);
      v_Logins_7d.Push(v_Row);
    end loop;
    Io_Hash.Put('logins_7d', v_Logins_7d);
    --
    for r in (select event_type, count(*) cnt
                from Core.Auth_Audit_Log
               where event_on >= Trunc(sysdate) - 6
               group by event_type
               order by cnt desc)
    loop
      v_Row := Core.Hash_t();
      v_Row.Put('t', r.event_type);
      v_Row.Put('c', r.cnt);
      v_Events.Push(v_Row);
    end loop;
    Io_Hash.Put('events', v_Events);
    --
    o_Code := Core_Const.c_Success_Code;
    o_Msg  := 'OK';
  exception
    when others then
      o_Code    := -1;
      o_Msg     := 'Dashboard ma''lumotlarini olishda xatolik';
      o_Ora_Msg := Sqlerrm;
  end;
  ----------------------------------------------------------------------------------------------------
end Core_Dashboard;
/
