----------------------------------------------------------------------------------------------------
--  Har bir Markaziy Bank spravochnigi uchun QO'LDA yangilash (manual refresh) va DAVRIY
--  (job orqali) avtomatik yangilanish imkoniyati.
--  Interval kodlari: 15MIN, 1HOUR, 6HOUR, 1DAY, 10DAY, 1MONTH, 1YEAR, yoki NULL (o'chirilgan).
----------------------------------------------------------------------------------------------------
set define off;
set serveroutput on size unlimited;

prompt =====================================================================
prompt 1) Cbr_r_References jadvaliga jadval (schedule) ustunlarini qo'shish
prompt =====================================================================
alter table Cbr_r_References add (
  Refresh_Interval    varchar2(10),
  Next_Refresh_On     date,
  Last_Refresh_On     date,
  Last_Refresh_Status varchar2(1),
  Last_Refresh_Msg    varchar2(500)
);

prompt =====================================================================
prompt 2) Cbr_r_References_v'ni qayta yaratish (yangi ustunlarni ko'rsatish uchun)
prompt =====================================================================
create or replace view Cbr_r_References_v as
select * from Cbr_r_References order by Order_By;

begin
  execute immediate 'grant select on Cbr_r_References_v to UAPP';
  execute immediate 'create or replace synonym UAPP.Cbr_r_References_v for CORE.Cbr_r_References_v';
exception
  when others then dbms_output.put_line('SKIP UAPP (Cbr_r_References_v): ' || sqlerrm);
end;
/

prompt =====================================================================
prompt 3) Cbr_Schedule_Kernel paketi: qo'lda va davriy yangilash mexanizmi
prompt =====================================================================
create or replace package Cbr_Schedule_Kernel is
  -- Ruxsat etilgan interval kodlari: 15MIN, 1HOUR, 6HOUR, 1DAY, 10DAY, 1MONTH, 1YEAR.
  -- i_Interval = null -> avtomatik yangilanish o'chiriladi.
  Procedure Set_Schedule(i_Ref_Id in number, i_Interval in varchar2);

  -- Bitta spravochnikni darhol (qo'lda) yangilaydi, ESB orqali.
  Procedure Manual_Refresh
  (
    i_Ref_Id in number,
    o_Code   out number,
    o_Msg    out varchar2
  );

  -- Job tomonidan chaqiriladi: muddati kelgan barcha spravochniklarni yangilaydi.
  Procedure Run_Due_Refreshes;

  Function Compute_Next_Run(i_Interval in varchar2, i_From in date default sysdate) return date;
end Cbr_Schedule_Kernel;
/
create or replace package body Cbr_Schedule_Kernel is

  Function Compute_Next_Run(i_Interval in varchar2, i_From in date default sysdate) return date is
  begin
    if i_Interval is null then
      return null;
    end if;
    case i_Interval
      when '15MIN'  then return i_From + (15/1440);
      when '1HOUR'  then return i_From + (1/24);
      when '6HOUR'  then return i_From + (6/24);
      when '1DAY'   then return i_From + 1;
      when '10DAY'  then return i_From + 10;
      when '1MONTH' then return add_months(i_From, 1);
      when '1YEAR'  then return add_months(i_From, 12);
      else raise_application_error(-20001, 'Notanish interval: ' || i_Interval);
    end case;
  end;

  Procedure Set_Schedule(i_Ref_Id in number, i_Interval in varchar2) is
  begin
    if i_Interval is not null and i_Interval not in ('15MIN','1HOUR','6HOUR','1DAY','10DAY','1MONTH','1YEAR') then
      raise_application_error(-20002, 'Notanish interval kodi: ' || i_Interval);
    end if;
    update Cbr_r_References
       set Refresh_Interval = i_Interval,
           Next_Refresh_On  = Compute_Next_Run(i_Interval, sysdate)
     where Ref_Id = i_Ref_Id;
    if sql%rowcount = 0 then
      raise_application_error(-20003, 'Ref_Id topilmadi: ' || i_Ref_Id);
    end if;
    commit;
  end;

  Procedure Manual_Refresh
  (
    i_Ref_Id in number,
    o_Code   out number,
    o_Msg    out varchar2
  ) is
    v_Interval varchar2(10);
  begin
    Cbr_Kernel.Get_Reference_Cb(i_Reference_Id => i_Ref_Id, o_Code => o_Code, o_Msg => o_Msg);

    select Refresh_Interval into v_Interval from Cbr_r_References where Ref_Id = i_Ref_Id;

    update Cbr_r_References
       set Last_Refresh_On     = sysdate,
           Last_Refresh_Status = case when o_Code = Core_Const.c_Success_Code then 'S' else 'E' end,
           Last_Refresh_Msg    = o_Msg,
           Next_Refresh_On     = Compute_Next_Run(v_Interval, sysdate)
     where Ref_Id = i_Ref_Id;
    commit;
  exception
    when others then
      o_Code := -999;
      o_Msg  := 'System error: ' || sqlerrm;
      update Cbr_r_References
         set Last_Refresh_On     = sysdate,
             Last_Refresh_Status = 'E',
             Last_Refresh_Msg    = o_Msg
       where Ref_Id = i_Ref_Id;
      commit;
  end;

  Procedure Run_Due_Refreshes is
    v_Code number;
    v_Msg  varchar2(4000);
  begin
    for r in (
      select Ref_Id from Cbr_r_References
       where Refresh_Interval is not null
         and Next_Refresh_On <= sysdate
    ) loop
      begin
        Manual_Refresh(i_Ref_Id => r.Ref_Id, o_Code => v_Code, o_Msg => v_Msg);
      exception
        when others then null; -- bitta spravochnikdagi xato qolganlarini to'xtatmasin
      end;
    end loop;
  end;

end Cbr_Schedule_Kernel;
/

prompt =====================================================================
prompt 4) DBMS_SCHEDULER job: har 15 daqiqada muddati kelganlarni tekshiradi
prompt =====================================================================
begin
  begin
    dbms_scheduler.drop_job('CBR_REFRESH_JOB', force => true);
  exception
    when others then null;
  end;

  dbms_scheduler.create_job(
    job_name        => 'CBR_REFRESH_JOB',
    job_type        => 'STORED_PROCEDURE',
    job_action      => 'Cbr_Schedule_Kernel.Run_Due_Refreshes',
    start_date      => sysdate,
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=15',
    enabled         => true,
    comments        => 'CBR spravochniklarini muddati kelganda ESB orqali avtomatik yangilaydi (15 daqiqada bir tekshiradi)'
  );
end;
/

prompt =====================================================================
prompt Tekshirish
prompt =====================================================================
select object_name, status from user_objects where object_name = 'CBR_SCHEDULE_KERNEL';
select job_name, enabled, state, repeat_interval from user_scheduler_jobs where job_name = 'CBR_REFRESH_JOB';

exit;
