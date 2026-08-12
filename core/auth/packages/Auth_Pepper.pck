create or replace package Auth_Pepper is
  -- Author      : CROBS
  -- Created     : 01.07.2026
  -- Назначение  : DEPLOY-ONLY константа приложения (app-pepper) для
  --               Auth_Util.Make_Local_Hash / Verify_Local_Hash.
  --
  --   ЭТОТ ФАЙЛ НЕ ДОЛЖЕН ПОПАДАТЬ В GIT С РЕАЛЬНЫМ ЗНАЧЕНИЕМ (см. .gitignore).
  --   DBA/релиз-инженер ОБЯЗАН заменить c_Pepper на случайное значение перед
  --   первым продовым деплоем, например:
  --     select Rawtohex(Dbms_Crypto.Randombytes(32)) from dual;
  --   и держать значение вне репозитория (сейф, vault, отдельный секрет-канал).
  --
  --   Смена значения делает НЕДЕЙСТВИТЕЛЬНЫМИ все существующие LOCAL-хэши
  --   (Core_User_Keys.Password) - после ротации всем LOCAL-пользователям
  --   нужен сброс пароля (Auth_Pwd_Kernel.Admin_Reset_Password / Reset_With_Token).
  c_Pepper constant varchar2(128) := 'CHANGE_ME_BEFORE_DEPLOY__REPLACE_WITH_RANDOM_SECRET';
end Auth_Pepper;
/
