CREATE OR REPLACE TYPE "J_NUMBER"                                          under j_Object
(
  value number,
  constructor Function j_Number
  (
    self  in out nocopy j_Number,
    value number
  ) return self as result,
  overriding member Function To_String return varchar2
)
;
/
CREATE OR REPLACE TYPE BODY "J_NUMBER" as

  constructor Function j_Number
  (
    self  in out nocopy j_Number,
    value number
  ) return self as result is
  begin
    Self.State := null;
    Self.Value := value;
    return;
  end;

  overriding member Function To_String return varchar2 is
  begin
    if value is null then
      return '''''';
    end if;
    return value;
  end;

end;
/
