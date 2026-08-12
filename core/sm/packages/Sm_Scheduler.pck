create or replace package Sm_Scheduler is

  -- Author  : B.URALOV
  -- Created : 16.07.2026 11:08:51
  -- Purpose : 
  Procedure Reexecute_Processes;
end Sm_Scheduler;
/
create or replace package body Sm_Scheduler is
  Procedure Reexecute_Processes is
    v_Hash    Hash_t := Hash_t();
    v_Code    number := Sm_Const.c_Success_Code;
    v_Msg     varchar2(4000);
    v_Ora_Msg varchar2(4000);
    v_Handle  varchar2(500);
  begin
    for r in (select *
                from Sm_Processes t
               where t.State_Id in (Sm_Const.c_Event_State_Hold_Complate))
    loop
      v_Hash.Put('process_id', r.Process_Id);
      if not Sm_Kernel.Lock_Process('LOCK_PROCESS_' || r.Process_Id, false, v_Handle, v_Msg) then
        v_Code := -2;
        return;
      end if;
      --
      begin
        Sm_Kernel.Set_Method(Io_Hash   => v_Hash,
                             o_Code    => v_Code,
                             o_Msg     => v_Msg,
                             o_Ora_Msg => v_Ora_Msg);
        Sm_Kernel.Unlock_Process(i_Handle => v_Handle);
      exception
        when others then
          Sm_Kernel.Unlock_Process(i_Handle => v_Handle);          v_Code := -1;
          declare
            v_Ml_Code number;
          begin
            Mle_Core_Api.Get_Error_Message(i_Module_Code => 'SM', i_Message_Code => 'SM_SYSTEM_ERROR', i_Params => null, o_Code => v_Ml_Code, o_Msg => v_Msg);
          end;
          v_Msg := v_Msg || ':' || sqlerrm;
      end;
      if v_Code = Sm_Const.c_Success_Code then
        commit;
      else
        rollback;
      end if;
    end loop;
  end;
end Sm_Scheduler;
/
