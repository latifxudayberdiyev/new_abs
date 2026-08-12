CREATE OR REPLACE TYPE "J_STRING"                                          under j_Object
(
  value varchar2(4000),
  constructor Function j_String
  (
        self   in out nocopy j_String,
        value                varchar2
  ) return self as result,
  overriding member Function to_String return varchar2
);
/
CREATE OR REPLACE TYPE BODY "J_STRING" as

  constructor Function j_String
  (
        self   in out nocopy j_String,
        value                varchar2
  ) return self as result
  is
  begin
    self.state := null;
    self.value := value;
    return;
  end;

  overriding member Function to_String return varchar2
  is
  begin
    return '''' || j_Object.escape(value) || '''';
  end;

end;
/
