
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_LANGUAGES_V" ("LANG_INDEX", "LANG_CODE", "LANG_NAME", "PRIORITY", "STATE", "IS_ACTIVE", "IS_REQUIRED", "FILE_FIELD_NAME") AS
  select l.Lang_Index,
         l.Lang_Code,
         l.Name                                 as Lang_Name,
         l.Priority,
         l.State,
         decode(l.State, 'A', 'Y', 'N')          as Is_Active,
         decode(l.Priority, 1, 'Y', 'N')         as Is_Required,
         'template_file_' || lower(l.Lang_Code)  as File_Field_Name
    from Mlt_Languages_V l
;

-- Mlt_Languages_V dagi barcha yozuvlar qaytariladi (filtrsiz) - MPT ekranlari
-- Is_Active bo'yicha o'zi tanlaydi. Chop shabloni fayllari har bir til uchun
-- alohida yuklanadi, shu sababli print_setting.jsp dagi "Faylni tanlang <til>"
-- polyalari shu view'dan dinamik chiziladi.
comment on table Mpt_Languages_V is 'MPT ekranlari uchun til reyestri (Mlt_Languages_V ustidan)';
comment on column Mpt_Languages_V.Is_Required is 'Y - shu tildagi fayl majburiy (Priority=1, yani asosiy til)';
comment on column Mpt_Languages_V.File_Field_Name is 'Formadagi file-input nomi: template_file_<lang_code kichik harfda>';
