create or replace type "J_OBJECT" force as object
(
  State char(1),
  not instantiable member Function To_String return varchar2,
  static Function escape(St varchar2) return varchar2
)
not instantiable not final;
/
create or replace type body "J_OBJECT" as
  static Function escape(St varchar2) return varchar2 is
  begin
    return replace(replace(replace(replace(St, '\', '\\'), '''', '\'''), Chr(10), '\n'),
                   Chr(13),
                   '\r');
  end;
  -- \r (Carriage Return) > moves the cursor to the beginning of the line without advancing to the next line
-- \n (Line Feed (newline)) > moves the cursor down to the next line without returning to the beginning of the line ? In a *nix environment \n moves to the beginning of the line.
-- \r\n (End Of Line) > a combination of \r and \n
-- chr(10) -> \n
-- chr(13) -> \r
end;
/
