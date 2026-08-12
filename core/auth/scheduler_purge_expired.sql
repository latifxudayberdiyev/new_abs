----------------------------------------------------------------------------------------------------
--  Daily cleanup job: expired nonce / stage-token / session / password-reset
--  rows (Auth_Nonce, Auth_Session, Auth_Pwd_Kernel each keep their own
--  Purge_Expired - this job is just the schedule, no new business logic).
--
--  Requires CREATE JOB (granted to CORE - see grants.sql).
--  Run as CORE: sqlplus core/*** @core/auth/scheduler_purge_expired.sql
----------------------------------------------------------------------------------------------------
begin
  begin
    Dbms_Scheduler.Drop_Job(job_name => 'AUTH_PURGE_EXPIRED', force => true);
  exception
    when others then
      if sqlcode != -27475 then -- ORA-27475: job does not exist - ignore
        raise;
      end if;
  end;

  Dbms_Scheduler.Create_Job(job_name        => 'AUTH_PURGE_EXPIRED',
                            job_type        => 'PLSQL_BLOCK',
                            job_action      => 'begin
                                                   Core.Auth_Nonce.Purge_Expired;
                                                   Core.Auth_Session.Purge_Expired;
                                                   Core.Auth_Pwd_Kernel.Purge_Expired;
                                                 end;',
                            start_date      => systimestamp,
                            repeat_interval => 'FREQ=DAILY; BYHOUR=3; BYMINUTE=0; BYSECOND=0',
                            enabled         => true,
                            comments        => 'Daily cleanup of expired AUTH nonce/stage/session/reset-token rows.');
end;
/
