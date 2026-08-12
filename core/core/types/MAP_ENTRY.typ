CREATE OR REPLACE TYPE "MAP_ENTRY"                                          force as object
(
  key varchar2(100),
  val Object_t,

------------------------------------------------------------------------------------------------------
  constructor Function Map_Entry
  (
    self in out nocopy Map_Entry,
    key    varchar2,
    val    Object_t
  ) return self as result

)
/
CREATE OR REPLACE TYPE BODY "MAP_ENTRY" is

  ------------------------------------------------------------------------------------------------------
  constructor Function Map_Entry
  (
    self in out nocopy Map_Entry,
    key    varchar2,
    val    Object_t
  ) return self as result is
  begin
    Self.key := key;
    Self.val := val;
    return;
  end;

end;
/
