create or replace package Account_Util is

  -- Author  : B.URALOV
  -- Created : 10.04.2026 10:38:08
  -- Purpose : 
  Function Get_Account_Row(i_Account_Id in number) return Accounts%rowtype;
end Account_Util;
/
create or replace package body Account_Util is
  Function Get_Account_Row(i_Account_Id in number) return Accounts%rowtype is
    result Accounts%rowtype;
  begin
    select a.*
      into result
      from Accounts a
     where a.Account_Id = i_Account_Id;
  end;
end Account_Util;
/
