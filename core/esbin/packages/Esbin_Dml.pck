create or replace package Esbin_Dml is

  -- Author  : B.URALOV
  -- Purpose : ESBIN uchun DML operatsiyalari

  Procedure Insert_Request(i_Row Esbin_Requests%rowtype);

  Procedure Update_Request_State
  (
    i_Id           number,
    i_State        varchar2,
    i_Sm_Process_Id number := null,
    i_Started_On   date := null,
    i_Finished_On  date := null
  );

  ----
  -- ESBIN'ning o'z audit-logi - avtonom tranzaksiyada, asosiy amaliyot
  -- rollback bo'lsa ham saqlanib qoladi.
  ----
  Procedure Insert_Request_Detail
  (
    i_Request_Id number,
    i_Request    clob,
    i_Response   clob
  );

  Procedure Set_Partner_Token
  (
    i_User_Id           number,
    i_Login             varchar2,
    i_Access_Token_Hash varchar2,
    i_Refresh_Token     varchar2,
    i_Expires_On        date
  );

  ----
  -- Joriy tokenni darhol yaroqsiz qiladi (Revoked_On/Revoke_Reason) - avtonom.
  -- i_Reason misol uchun 'LOGOUT' yoki 'ADMIN_REVOKE'. Bu FAQAT shu tokenni
  -- bloklaydi - keyingi muvaffaqiyatli login (Set_Partner_Token) uni avtomatik
  -- tozalaydi. Partnerni doimiy suspend qilish uchun ESBIN_R_PARTNER_USERS.STATE='P'.
  ----
  Procedure Revoke_Partner_Token(i_User_Id number, i_Reason varchar2 := null);

  Procedure Log_Partner_History(i_Partner_Code varchar2, i_Action varchar2);
  Procedure Add_Partner(i_Partner_Code varchar2, i_Name varchar2);
  Procedure Update_Partner_State(i_Partner_Code varchar2, i_State varchar2);

  Procedure Log_Method_History(i_Method_Code varchar2, i_Action varchar2);
  Procedure Add_Method(i_Row Esbin_R_Methods%rowtype);
  Procedure Update_Method(i_Row Esbin_R_Methods%rowtype);

  Procedure Log_User_Method_History
  (
    i_User_Id     number,
    i_Method_Code varchar2,
    i_State       varchar2,
    i_Action      varchar2
  );

  ----
  -- User uchun butun method-dostup to'plamini almashtiradi (delete + qayta
  -- insert) - PF_R_ATTRIBUTE_CATEGORIES uchun ishlatilgan Sync_* naqshiga o'xshash.
  ----
  Procedure Sync_User_Methods
  (
    i_User_Id      number,
    i_Method_Codes Core.Array_Varchar2
  );

  Procedure Attach_User_Methods
  (
    i_User_Id      number,
    i_Method_Codes Core.Array_Varchar2
  );

end Esbin_Dml;
/
create or replace package body Esbin_Dml is

  ----
  -- ESBIN'ning o'z jurnali - asosiy (SM/business) tranzaksiyadan mustaqil,
  -- avtonom. Shu bilan bir vaqtda: (1) asosiy tranzaksiya keyinroq rollback
  -- bo'lsa ham log durable qoladi, (2) ESBIN_REQUEST_DETAILS'ning shu qatorga
  -- FK bilan yozishi paytida asosiy tranzaksiya bilan o'z-o'ziga qulflanish
  -- (ORA-00060 deadlock) yuzaga kelmaydi - chunki ota qator darhol commit
  -- bo'ladi, uzoq kutilmaydi.
  ----
  Procedure Insert_Request(i_Row Esbin_Requests%rowtype) is
    pragma autonomous_transaction;
  begin
    insert into Esbin_Requests
      (Id, Ext_Request_Id, Partner_Code, User_Id, Method_Code, Sm_Process_Id,
       State, Sync_Type, Created_On, Started_On, Finished_On, Duration_Ms, Ip_Address)
    values
      (i_Row.Id, i_Row.Ext_Request_Id, i_Row.Partner_Code, i_Row.User_Id, i_Row.Method_Code,
       i_Row.Sm_Process_Id, i_Row.State, i_Row.Sync_Type, i_Row.Created_On, i_Row.Started_On,
       i_Row.Finished_On, i_Row.Duration_Ms, i_Row.Ip_Address);
    commit;
  end Insert_Request;

  Procedure Update_Request_State
  (
    i_Id            number,
    i_State         varchar2,
    i_Sm_Process_Id number := null,
    i_Started_On    date := null,
    i_Finished_On   date := null
  ) is
    pragma autonomous_transaction;
  begin
    update Esbin_Requests
       set State         = i_State,
           Sm_Process_Id = Nvl(i_Sm_Process_Id, Sm_Process_Id),
           Started_On    = Nvl(i_Started_On, Started_On),
           Finished_On   = i_Finished_On,
           Duration_Ms   = case
                             when i_Finished_On is not null and Nvl(i_Started_On, Started_On) is not null then
                              (i_Finished_On - Nvl(i_Started_On, Started_On)) * 24 * 60 * 60 * 1000
                           end
     where Id = i_Id;
    commit;
  end Update_Request_State;

  Procedure Insert_Request_Detail
  (
    i_Request_Id number,
    i_Request    clob,
    i_Response   clob
  ) is
    pragma autonomous_transaction;
  begin
    merge into Esbin_Request_Details t
    using (select i_Request_Id as Request_Id from dual) s
    on (t.Request_Id = s.Request_Id)
    when matched then
      update set Response = i_Response
    when not matched then
      insert (Request_Id, Request, Response, Created_On)
      values (i_Request_Id, i_Request, i_Response, sysdate);
    commit;
  end Insert_Request_Detail;

  Procedure Set_Partner_Token
  (
    i_User_Id           number,
    i_Login             varchar2,
    i_Access_Token_Hash varchar2,
    i_Refresh_Token     varchar2,
    i_Expires_On        date
  ) is
    pragma autonomous_transaction;
  begin
    merge into Esbin_Partner_Tokens t
    using (select i_User_Id as User_Id from dual) s
    on (t.User_Id = s.User_Id)
    when matched then
      update
         set Login             = i_Login,
             Access_Token_Hash = i_Access_Token_Hash,
             Refresh_Token     = i_Refresh_Token,
             Expires_On        = i_Expires_On,
             -- Muvaffaqiyatli login har doim oldingi revoke holatini tozalaydi -
             -- bitta tokenni revoke qilish faqat KEYINGI muvaffaqiyatli login'gacha
             -- bloklaydi, partnerni doimiy suspend qilmaydi. Doimiy suspend uchun
             -- ESBIN_R_PARTNER_USERS.STATE='P' ishlatiladi (Login ham, Get_Token_User
             -- ham buni allaqachon tekshiradi).
             Revoked_On        = null,
             Revoke_Reason     = null,
             Modify_On         = sysdate
    when not matched then
      insert
        (User_Id, Login, Access_Token_Hash, Refresh_Token, Expires_On, Created_On, Modify_On)
      values
        (i_User_Id, i_Login, i_Access_Token_Hash, i_Refresh_Token, i_Expires_On, sysdate, sysdate);
    commit;
  exception
    when Dup_Val_On_Index then
      -- Ikkita bir vaqtdagi birinchi-marta-login PK bo'yicha to'qnashadi (ikkalasi
      -- ham "not matched" deb hisoblab insert qilishga urinadi). Bunday holda
      -- insert emas, oddiy UPDATE bilan davom etamiz - qator allaqachon boshqa
      -- sessiya tomonidan yaratilgan.
      rollback;
      begin
        update Esbin_Partner_Tokens
           set Login             = i_Login,
               Access_Token_Hash = i_Access_Token_Hash,
               Refresh_Token     = i_Refresh_Token,
               Expires_On        = i_Expires_On,
               Revoked_On        = null,
               Revoke_Reason     = null,
               Modify_On         = sysdate
         where User_Id = i_User_Id;
        commit;
      exception
        when others then
          -- Retry-UPDATE ham xato bersa ham avtonom tranzaksiya commit/rollback
          -- qilinmasdan chiqib bo'lmaydi - asl xatoni maskalamasdan ko'taramiz.
          rollback;
          raise;
      end;
    when others then
      -- Avtonom tranzaksiya commit/rollback qilinmasdan chiqib bo'lmaydi
      -- (aks holda ORA-06519 chaqiruvchiga asl xatoni maskalab qo'yadi) -
      -- Login'ning o'z handleriga ASL sqlerrm yetib borishi uchun rollback
      -- qilib, xatoni o'zgarishsiz qayta ko'taramiz.
      rollback;
      raise;
  end Set_Partner_Token;

  Procedure Revoke_Partner_Token(i_User_Id number, i_Reason varchar2 := null) is
    pragma autonomous_transaction;
  begin
    update Esbin_Partner_Tokens
       set Revoked_On    = sysdate,
           Revoke_Reason = Substr(i_Reason, 1, 40),
           Modify_On     = sysdate
     where User_Id = i_User_Id
       and Revoked_On is null;
    commit;
  end Revoke_Partner_Token;

  Procedure Log_Partner_History(i_Partner_Code varchar2, i_Action varchar2) is
  begin
    insert into Esbin_R_Partners_H
      (Log_Id, Partner_Code, Name, State, Token_Ttl_Min, Action, Action_Date)
      select Esbin_Request_Sq.Nextval, Partner_Code, Name, State, Token_Ttl_Min, i_Action, sysdate
        from Esbin_R_Partners
       where Partner_Code = i_Partner_Code;
  end Log_Partner_History;

  Procedure Add_Partner(i_Partner_Code varchar2, i_Name varchar2) is
  begin
    insert into Esbin_R_Partners (Partner_Code, Name, State)
    values (i_Partner_Code, i_Name, 'A');
    Log_Partner_History(i_Partner_Code, 'I');
  end Add_Partner;

  Procedure Update_Partner_State(i_Partner_Code varchar2, i_State varchar2) is
  begin
    update Esbin_R_Partners set State = i_State where Partner_Code = i_Partner_Code;
    Log_Partner_History(i_Partner_Code, 'U');
  end Update_Partner_State;

  Procedure Log_Method_History(i_Method_Code varchar2, i_Action varchar2) is
  begin
    insert into Esbin_R_Methods_H
      (Log_Id, Method_Code, Name, Process_Code, Request_Type, Synchronize_Type,
       Result_Function, Is_Idempotent, Add_Log, State, Action, Action_Date)
      select Esbin_Request_Sq.Nextval, Method_Code, Name, Process_Code, Request_Type,
             Synchronize_Type, Result_Function, Is_Idempotent, Add_Log, State, i_Action, sysdate
        from Esbin_R_Methods
       where Method_Code = i_Method_Code;
  end Log_Method_History;

  Procedure Add_Method(i_Row Esbin_R_Methods%rowtype) is
  begin
    insert into Esbin_R_Methods
      (Method_Code, Name, Process_Code, Request_Type, Synchronize_Type,
       Result_Function, Is_Idempotent, Add_Log, State)
    values
      (i_Row.Method_Code, i_Row.Name, i_Row.Process_Code, i_Row.Request_Type, i_Row.Synchronize_Type,
       i_Row.Result_Function, i_Row.Is_Idempotent, i_Row.Add_Log, i_Row.State);
    Log_Method_History(i_Row.Method_Code, 'I');
  end Add_Method;

  Procedure Update_Method(i_Row Esbin_R_Methods%rowtype) is
  begin
    update Esbin_R_Methods
       set Name             = i_Row.Name,
           Process_Code     = i_Row.Process_Code,
           Request_Type     = i_Row.Request_Type,
           Synchronize_Type = i_Row.Synchronize_Type,
           Result_Function  = i_Row.Result_Function,
           Is_Idempotent    = i_Row.Is_Idempotent,
           Add_Log          = i_Row.Add_Log,
           State            = i_Row.State
     where Method_Code = i_Row.Method_Code;
    Log_Method_History(i_Row.Method_Code, 'U');
  end Update_Method;

  Procedure Log_User_Method_History
  (
    i_User_Id     number,
    i_Method_Code varchar2,
    i_State       varchar2,
    i_Action      varchar2
  ) is
  begin
    insert into Esbin_R_User_Method_Rel_H
      (Log_Id, User_Id, Method_Code, State, Action, Action_Date)
    values
      (Esbin_Request_Sq.Nextval, i_User_Id, i_Method_Code, i_State, i_Action, sysdate);
  end Log_User_Method_History;

  ----
  -- User uchun butun method-dostup to'plamini almashtiradi (delete + qayta
  -- insert). O'chirilgan/qo'shilgan methodlar uchun tarixga 'D'/'I' yoziladi -
  -- o'zgarmagan (oldin ham, hozir ham grant qilingan) methodlar uchun yozilmaydi.
  ----
  Procedure Sync_User_Methods
  (
    i_User_Id      number,
    i_Method_Codes Core.Array_Varchar2
  ) is
    v_Cnt number;

    function In_New(i_Code varchar2) return boolean is
    begin
      if i_Method_Codes is not null then
        for i in 1 .. i_Method_Codes.Count loop
          if i_Method_Codes(i) = i_Code then
            return true;
          end if;
        end loop;
      end if;
      return false;
    end In_New;
  begin
    for r in (select Method_Code from Esbin_R_User_Method_Rel where User_Id = i_User_Id) loop
      if not In_New(r.Method_Code) then
        Log_User_Method_History(i_User_Id, r.Method_Code, 'P', 'D');
      end if;
    end loop;

    if i_Method_Codes is not null then
      for i in 1 .. i_Method_Codes.Count loop
        select count(*) into v_Cnt
          from Esbin_R_User_Method_Rel
         where User_Id = i_User_Id
           and Method_Code = i_Method_Codes(i);
        if v_Cnt = 0 then
          Log_User_Method_History(i_User_Id, i_Method_Codes(i), 'A', 'I');
        end if;
      end loop;
    end if;

    delete from Esbin_R_User_Method_Rel where User_Id = i_User_Id;
    if i_Method_Codes is not null then
      for i in 1 .. i_Method_Codes.Count loop
        insert into Esbin_R_User_Method_Rel (User_Id, Method_Code, State)
        values (i_User_Id, i_Method_Codes(i), 'A');
      end loop;
    end if;
  end Sync_User_Methods;

  ----
  -- Mavjud grantlarni o'chirmasdan, faqat qo'shimcha method_code'larni
  -- biriktiradi (allaqachon bor bo'lsa - qayta faollashtiradi).
  ----
  Procedure Attach_User_Methods
  (
    i_User_Id      number,
    i_Method_Codes Core.Array_Varchar2
  ) is
    v_Cnt number;
  begin
    if i_Method_Codes is not null then
      for i in 1 .. i_Method_Codes.Count loop
        select count(*) into v_Cnt
          from Esbin_R_User_Method_Rel
         where User_Id = i_User_Id
           and Method_Code = i_Method_Codes(i)
           and State = 'A';
        if v_Cnt = 0 then
          Log_User_Method_History(i_User_Id, i_Method_Codes(i), 'A', 'I');
        end if;
        merge into Esbin_R_User_Method_Rel t
        using (select i_User_Id as User_Id, i_Method_Codes(i) as Method_Code from dual) s
        on (t.User_Id = s.User_Id and t.Method_Code = s.Method_Code)
        when matched then
          update set State = 'A'
        when not matched then
          insert (User_Id, Method_Code, State)
          values (s.User_Id, s.Method_Code, 'A');
      end loop;
    end if;
  end Attach_User_Methods;

end Esbin_Dml;
/
