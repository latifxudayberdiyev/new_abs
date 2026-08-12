----------------------------------------------------------------------------------------------------
--  Tizimda "r_%_v" nomli view'lar uchun CODE, NAME, DATE_ACTIV, DATE_DEACT, STATE
--  standart ustunlari bor deb hisoblaydigan umumiy mexanizm bor ekan.
--  Bu 5 ta view'da asl nomlari boshqacha bo'lgani uchun qo'shimcha alias qo'shamiz
--  (asl ustunlar ham qoladi - JSP'dagi t:field'lar buzilmaydi).
----------------------------------------------------------------------------------------------------
create or replace view r_nation_v as
select r.*, Nation_Name as Name from r_nation r;

create or replace view r_obraz_v as
select r.*, Obraz_Name as Name from r_obraz r;

create or replace view r_coato_v as
select r.*, Uzb_Lat_Name as Name from r_coato r;

create or replace view r_business_form_v as
select r.*, Name_Rus as Name from r_business_form r;

create or replace view r_mahalla_v as
select r.*,
       Code_Uz_Cad as Code,
       Name_Uz     as Name,
       Date_Open   as Date_Activ,
       Date_Close  as Date_Deact,
       Active      as State
  from r_mahalla r;
