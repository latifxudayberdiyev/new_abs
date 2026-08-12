create or replace package Auth_Nonce is

  -- Author      : CROBS
  -- Created     : 18.05.2026
  -- Изменён     : 19.05.2026 - stage-токен (Issue_Stage / Consume_Stage)
  -- Назначение  : Одноразовый nonce входа (защита от replay / CSRF) + stage-токен
  --               между Begin_Login и Complete_Login. Оба одноразовые, короткий TTL,
  --               хранятся в виде ХЭША.
  ----------------------------------------------------------------------------------------------------
  -- Выдать nonce для формы логина. Делает commit.
  Procedure Issue
  (
    i_Client_Ip  in  varchar2,
    i_User_Agent in  varchar2,
    o_Nonce      out varchar2,
    o_Ttl_Sec    out number
  );
  ----------------------------------------------------------------------------------------------------
  -- Проверить и погасить nonce. Возвращает код причины (Auth_Const.c_Rsn_*).
  Function Consume(i_Nonce varchar2) return varchar2;
  ----------------------------------------------------------------------------------------------------
  -- Выдать stage-токен (после успешного Begin_Login). Привязан к username. Делает commit.
  Procedure Issue_Stage
  (
    i_Username   in  varchar2,
    i_Client_Ip  in  varchar2,
    o_Token      out varchar2,
    o_Ttl_Sec    out number
  );
  ----------------------------------------------------------------------------------------------------
  -- Проверить и погасить stage-токен. Должен совпасть username. Код причины.
  Function Consume_Stage
  (
    i_Token    varchar2,
    i_Username varchar2
  ) return varchar2;
  ----------------------------------------------------------------------------------------------------
  -- Обслуживание: удалить просроченные nonce и stage-токены (из планировщика).
  Procedure Purge_Expired;
  ----------------------------------------------------------------------------------------------------
end Auth_Nonce;
/
create or replace package body Auth_Nonce is
  ----------------------------------------------------------------------------------------------------
  Procedure Issue
  (
    i_Client_Ip  in  varchar2,
    i_User_Agent in  varchar2,
    o_Nonce      out varchar2,
    o_Ttl_Sec    out number
  ) is
    pragma autonomous_transaction;
  begin
    o_Nonce   := Auth_Util.Random_Token(24);
    o_Ttl_Sec := Auth_Const.c_Nonce_Ttl_Sec;
    insert into Auth_Login_Nonce
      (Nonce, Client_Ip, User_Agent, Issued_On, Expires_On, Used)
    values
      (o_Nonce,
       Substr(i_Client_Ip, 1, 45),
       Substr(i_User_Agent, 1, 400),
       sysdate,
       sysdate + Auth_Const.c_Nonce_Ttl_Sec / 86400,
       'N');
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Consume(i_Nonce varchar2) return varchar2 is
    pragma autonomous_transaction;
    v_Used       varchar2(1);
    v_Expires_On date;
  begin
    if i_Nonce is null then
      commit;
      return Auth_Const.c_Rsn_Nonce_Missing;
    end if;

    begin
      select Used, Expires_On
        into v_Used, v_Expires_On
        from Auth_Login_Nonce
       where Nonce = i_Nonce
         for update;
    exception
      when no_data_found then
        commit;
        return Auth_Const.c_Rsn_Nonce_Invalid;
    end;

    -- гасим безусловно (одноразовый)
    update Auth_Login_Nonce
       set Used = 'Y', Used_On = sysdate
     where Nonce = i_Nonce;
    commit;

    if v_Used = 'Y' then
      return Auth_Const.c_Rsn_Nonce_Used;
    elsif v_Expires_On < sysdate then
      return Auth_Const.c_Rsn_Nonce_Expired;
    end if;

    return Auth_Const.c_Rsn_Ok;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Issue_Stage
  (
    i_Username   in  varchar2,
    i_Client_Ip  in  varchar2,
    o_Token      out varchar2,
    o_Ttl_Sec    out number
  ) is
    pragma autonomous_transaction;
  begin
    o_Token   := Auth_Util.Random_Token(Auth_Const.c_Token_Bytes);
    o_Ttl_Sec := Auth_Const.c_Stage_Ttl_Sec;
    insert into Auth_Login_Stage
      (Stage_Hash, Username, Client_Ip, Issued_On, Expires_On, Used)
    values
      (Auth_Util.Hash_Sha256(o_Token),
       Substr(i_Username, 1, 512),
       Substr(i_Client_Ip, 1, 45),
       sysdate,
       sysdate + Auth_Const.c_Stage_Ttl_Sec / 86400,
       'N');
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
  Function Consume_Stage
  (
    i_Token    varchar2,
    i_Username varchar2
  ) return varchar2 is
    pragma autonomous_transaction;
    v_Hash     varchar2(64);
    v_Used     varchar2(1);
    v_Expires  date;
    v_Username varchar2(512);
  begin
    if i_Token is null then
      commit;
      return Auth_Const.c_Rsn_Stage_Invalid;
    end if;
    v_Hash := Auth_Util.Hash_Sha256(i_Token);

    begin
      select Used, Expires_On, Username
        into v_Used, v_Expires, v_Username
        from Auth_Login_Stage
       where Stage_Hash = v_Hash
         for update;
    exception
      when no_data_found then
        commit;
        return Auth_Const.c_Rsn_Stage_Invalid;
    end;

    -- гасим безусловно (одноразовый)
    update Auth_Login_Stage
       set Used = 'Y', Used_On = sysdate
     where Stage_Hash = v_Hash;
    commit;

    if v_Used = 'Y'
       or v_Expires < sysdate
       or v_Username != i_Username then
      return Auth_Const.c_Rsn_Stage_Invalid;
    end if;

    return Auth_Const.c_Rsn_Ok;
  end;
  ----------------------------------------------------------------------------------------------------
  Procedure Purge_Expired is
    pragma autonomous_transaction;
  begin
    delete from Auth_Login_Nonce where Expires_On < sysdate - 1;
    delete from Auth_Login_Stage where Expires_On < sysdate - 1;
    commit;
  end;
  ----------------------------------------------------------------------------------------------------
end Auth_Nonce;
/
