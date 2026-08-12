create or replace package Auth_Const is
  -- Author      : CROBS
  -- Created     : 18.05.2026
  -- Изменён     : 19.05.2026 - коды событий ключей, пароля и stage-токена
  -- Назначение  : Константы подсистемы аутентификации (независимо от провайдера).
  ----------------------------------------------------------------------------------------------------
  -- Провайдеры аутентификации (CORE.CORE_USER_KEYS.PROVIDER_TYPE)
  c_Provider_Ad    constant varchar2(20) := 'AD';
  c_Provider_Local constant varchar2(20) := 'LOCAL';
  ----------------------------------------------------------------------------------------------------
  -- Состояния записей (A/P/S как везде в CORE)
  c_State_Active  constant varchar2(1) := 'A';
  c_State_Passive constant varchar2(1) := 'P';
  ----------------------------------------------------------------------------------------------------
  -- Состояния сессии
  c_Sess_Active  constant varchar2(1) := 'A';
  c_Sess_Closed  constant varchar2(1) := 'C';
  c_Sess_Expired constant varchar2(1) := 'E';
  ----------------------------------------------------------------------------------------------------
  -- Типы событий аудита
  c_Ev_Nonce_Fail   constant varchar2(30) := 'NONCE_FAIL';
  c_Ev_Locked       constant varchar2(30) := 'LOCKED';
  c_Ev_Login_Fail   constant varchar2(30) := 'LOGIN_FAIL';
  c_Ev_Login_Ok     constant varchar2(30) := 'LOGIN_OK';
  c_Ev_Logout       constant varchar2(30) := 'LOGOUT';
  c_Ev_Session_Fail constant varchar2(30) := 'SESSION_FAIL';
  c_Ev_Stage_Fail   constant varchar2(30) := 'STAGE_FAIL';
  -- Управление ключами (CORE_USER_KEYS) и паролями (LOCAL)
  c_Ev_Key_Created   constant varchar2(30) := 'KEY_CREATED';
  c_Ev_Key_Changed   constant varchar2(30) := 'KEY_CHANGED';
  c_Ev_Key_Deleted   constant varchar2(30) := 'KEY_DELETED';
  c_Ev_Pwd_Changed   constant varchar2(30) := 'PASSWORD_CHANGED';
  c_Ev_Pwd_Admin_Set constant varchar2(30) := 'PASSWORD_ADMIN_RESET';
  c_Ev_Pwd_Req_Reset constant varchar2(30) := 'PASSWORD_RESET_REQUESTED';
  c_Ev_Pwd_Use_Reset constant varchar2(30) := 'PASSWORD_RESET_USED';
  ----------------------------------------------------------------------------------------------------
  -- Детальные коды причин (только для аудита - клиенту не возвращаются)
  c_Rsn_Nonce_Missing    constant varchar2(40) := 'NONCE_MISSING';
  c_Rsn_Nonce_Invalid    constant varchar2(40) := 'NONCE_INVALID';
  c_Rsn_Nonce_Expired    constant varchar2(40) := 'NONCE_EXPIRED';
  c_Rsn_Nonce_Used       constant varchar2(40) := 'NONCE_ALREADY_USED';
  c_Rsn_Locked           constant varchar2(40) := 'ACCOUNT_LOCKED';
  c_Rsn_Bad_Credentials  constant varchar2(40) := 'BAD_CREDENTIALS';
  c_Rsn_Not_Provisioned  constant varchar2(40) := 'USER_NOT_PROVISIONED';
  c_Rsn_Key_Passive      constant varchar2(40) := 'USER_KEY_PASSIVE';
  c_Rsn_User_Not_Active  constant varchar2(40) := 'USER_NOT_ACTIVE';
  c_Rsn_Access_Denied    constant varchar2(40) := 'ACCESS_DENIED';
  c_Rsn_No_Active_Role   constant varchar2(40) := 'NO_ACTIVE_ROLE';
  c_Rsn_Session_Invalid  constant varchar2(40) := 'SESSION_INVALID';
  c_Rsn_Session_Expired  constant varchar2(40) := 'SESSION_EXPIRED';
  c_Rsn_Stage_Invalid    constant varchar2(40) := 'STAGE_TOKEN_INVALID';
  c_Rsn_Ok               constant varchar2(40) := 'OK';
  -- Пароль / сброс
  c_Rsn_Wrong_Old_Pwd    constant varchar2(40) := 'WRONG_OLD_PASSWORD';
  c_Rsn_Not_Local        constant varchar2(40) := 'NOT_LOCAL_PROVIDER';
  c_Rsn_Identity_Missing constant varchar2(40) := 'IDENTITY_MISSING'; -- Admin_Reset_Password: identity_id yoki (provider_type+provider_key) berilmagan
  c_Rsn_Api_User         constant varchar2(40) := 'API_USER_BROWSER_BLOCKED';
  c_Rsn_Reset_Invalid    constant varchar2(40) := 'RESET_TOKEN_INVALID';
  c_Rsn_Reset_Expired    constant varchar2(40) := 'RESET_TOKEN_EXPIRED';
  c_Rsn_Reset_Used       constant varchar2(40) := 'RESET_TOKEN_USED';
  c_Rsn_Weak_Password    constant varchar2(40) := 'WEAK_PASSWORD';
  c_Rsn_Pwd_Must_Change  constant varchar2(40) := 'PASSWORD_MUST_BE_CHANGED';
  c_Rsn_Ip_Changed       constant varchar2(40) := 'IP_CHANGED'; -- Auth_Session.Validate: audit-log uchun, sessiyani rad etmaydi
  ----------------------------------------------------------------------------------------------------
  -- Общие сообщения для клиента (без раскрытия информации / без перечисления пользователей)
  c_Msg_Auth_Failed    constant varchar2(200) := 'Login yoki parol noto''g''ri';
  c_Msg_No_Access      constant varchar2(200) := 'Tizimga ruxsat yo''q';
  c_Msg_Locked         constant varchar2(200) := 'Akkaunt vaqtincha bloklangan, keyinroq urinib ko''ring';
  c_Msg_Session        constant varchar2(200) := 'Sessiya yaroqsiz yoki muddati tugagan';
  c_Msg_Sys_Error      constant varchar2(200) := 'Tizim xatosi';
  c_Msg_Pwd_Changed    constant varchar2(200) := 'Parol o''zgartirildi';
  c_Msg_Reset_Sent     constant varchar2(200) := 'Agar foydalanuvchi mavjud bo''lsa, tiklash ko''rsatmasi yuborildi';
  c_Msg_Reset_Invalid  constant varchar2(200) := 'Tiklash havolasi yaroqsiz yoki muddati tugagan';
  c_Msg_Weak_Password  constant varchar2(200) := 'Parol talablariga javob bermaydi';
  c_Msg_Pwd_Must_Chg   constant varchar2(200) := 'Parolni o''zgartirish kerak';
  c_Msg_Not_Local      constant varchar2(200) := 'Bu operatsiya faqat lokal foydalanuvchilar uchun';
  ----------------------------------------------------------------------------------------------------
  -- Тайм-ауты (секунды / минуты)
  c_Stage_Ttl_Sec    constant pls_integer := 120;     -- время жизни stage-токена (на bind в AD)
  c_Nonce_Ttl_Sec    constant pls_integer := 60;      -- время жизни nonce
  c_Sess_Idle_Min    constant pls_integer := 20;      -- тайм-аут бездействия
  c_Sess_Abs_Min     constant pls_integer := 600;     -- абсолютный тайм-аут (10 ч)
  c_Token_Bytes      constant pls_integer := 32;      -- размер случайного токена
  c_Reset_Ttl_Min    constant pls_integer := 30;      -- время жизни токена сброса пароля
  c_Pwd_Min_Length   constant pls_integer := 8;       -- минимальная длина пароля
  ----------------------------------------------------------------------------------------------------
  -- Политика блокировки (срабатывает до bind в AD - защищает реальную учётную запись AD)
  c_Lock_Threshold   constant pls_integer := 5;       -- неудач до первой блокировки
  c_Lock_Streak_Min  constant pls_integer := 15;      -- окно сброса серии (нет неудач N мин)
  ----------------------------------------------------------------------------------------------------
  -- Параметры PBKDF2 для провайдера LOCAL
  c_Pbkdf2_Iterations constant pls_integer := 120000;
  c_Pbkdf2_Salt_Bytes constant pls_integer := 16;
  ----------------------------------------------------------------------------------------------------
end Auth_Const;
/
