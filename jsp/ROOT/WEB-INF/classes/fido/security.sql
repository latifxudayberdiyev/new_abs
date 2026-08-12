create or replace function c(cText IN varchar2) return varchar2 is
cTemp varchar2(2000):=cText;
cPorc varchar2(2000);
nPorc NUMBER;
CSEZAM VARCHAR2(10):='123';
i number;
cSymb varchar2(1);
cSezSymb varchar2(1);
cVozvrat varchar2(2000);
begin
 --  while cSymb<>chr(10) loop
    while length(cTemp)>0 loop
    cPorc:=Substr(cTemp,1,Length(cSezam));
    nPorc:=Length(cPorc);
    cTemp:=SubStr(cTemp,nPorc+1);
    for i IN 1..nPorc  loop
      cSymb:=SubStr(cPorc,i,1);
      cSezSymb:=SubStr(cSezam,i,1);
      cVozvrat:=cVozvrat||Chr(MOD((2*Ascii(cSezSymb)-Ascii(cSymb)+256),256));
    end loop;
  end loop;
  return(cVozvrat);
end;
