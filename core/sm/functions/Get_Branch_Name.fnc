create or replace Function Get_Branch_Name(i_Branch_Id in number) return varchar2 is
  result varchar2(500);
begin
  select Core.Ml.Cur_Lang(t.Name)
    into result
    from Mfi_Branches t
   where t.Branch_Id = i_Branch_Id
     and Rownum = 1;
  return result;
end Get_Branch_Name;
/
