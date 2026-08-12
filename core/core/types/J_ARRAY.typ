create or replace type "J_ARRAY" under j_Object
(
  value j_Tarray,
  constructor Function j_Array(self in out nocopy j_Array) return self as result,
  overriding member Function To_String return varchar2,
  member Procedure Push
  (
    self in out nocopy j_Array,
    o    j_Object
  ),
  member Procedure Push
  (
    self in out nocopy j_Array,
    o    varchar2
  ),
  member Procedure Push
  (
    self in out nocopy j_Array,
    o    number
  ),
  member Procedure Push
  (
    self   in out nocopy j_Array,
    o      date,
    Format varchar2 := null
  ),
  member Function count return pls_integer
)
/
CREATE OR REPLACE TYPE BODY "J_ARRAY" as

  constructor function j_array(self in out nocopy j_array) return self as result is
  begin
    self.state := null;
    self.value := j_tarray();
    return;
  end;

  overriding member function to_string return varchar2 is
    tmp varchar2(32767);
  begin
    tmp := '[';
    for i in 1 .. value.count
    loop
      tmp := tmp || value(i).to_string();
      if i <> value.last then
        tmp := tmp || ',';
      end if;
    end loop;
    return tmp || ']';
  end;

  member procedure push
  (
    self in out nocopy j_array,
    o    j_object
  ) is
  begin
    self.value.extend;
    self.value(self.value.count) := o;
  end;

  member procedure push
  (
    self in out nocopy j_array,
    o    varchar2
  ) is
  --sanitized_value varchar2(32767);
  begin
    --sanitized_value:= j_Hash_Util.Sanitize(i_value => o);
    self.push(j_string(o));
  end;

  member procedure push
  (
    self in out nocopy j_array,
    o    number
  ) is
  begin
    self.push(j_number(o));
  end;

  member procedure push
  (
    self   in out nocopy j_array,
    o      date,
    format varchar2 := null
  ) is
  begin
    self.push(to_char(o, nvl(format, 'dd.mm.yyyy')));
  end;

  member function count return pls_integer is
  begin
    return value.count;
  end count;

end;
/
