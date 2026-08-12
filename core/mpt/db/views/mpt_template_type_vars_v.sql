
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_TEMPLATE_TYPE_VARS_V" ("TEMPLATE_CODE", "VARIABLE_CODE", "VAR_NAME", "PLACEHOLDER", "MODULE_CODE", "MODULE_NAME", "VAR_TYPE", "TYPE_NAME", "VAR_SOURCE", "DESCRIPTION", "EXAMPLE_VALUE", "IS_MAPPED") AS
  select tt.Template_Code,
       v.Variable_Code,
       v.Var_Name,
       -- eventual placeholder - biriktirilmagan bo'lsa ham ko'rsatiladi
       '[' || v.Variable_Code || ']' as Placeholder,
       v.Module_Code,
       -- Module_Code null = barcha modullar uchun (global)
       Nvl(m.Module_Name, Mpt_Module_Name('MPT_VAR_MODULE_ALL')) as Module_Name,
       v.Var_Type,
       t.Type_Name,
       v.Var_Source,
       v.Description,
       v.Example_Value,
       -- checkbox "checked" shu ustunga bog'lanadi: 0 = unchecked, 1 = checked
       -- (cms.tld t:column checked semantikasi)
       case when tv.Mapping_Id is not null then 1 else 0 end as Is_Mapped
  -- Har bir shablon turi x har bir faol o'zgaruvchi kesishmasi. Ekran
  -- t:table where="template_code = '<kod>'" bilan bitta turni tanlaydi -
  -- sessiya konteksti (User_Session) ISHLATILMAYDI: t:table'ning har bir
  -- so'rovi pool'dan boshqa DB ulanishini olishi mumkin, u holda avval
  -- o'rnatilgan sessiya qiymati ko'rinmay qoladi va IS_MAPPED noto'g'ri
  -- 0 bo'lib chiqadi.
  from Mpt_Template_Types tt
 cross join Mpt_Print_Variables v
  left join Mpt_Variable_Types t
    on t.Type_Code = v.Var_Type
  left join Mpt_Modules_V m
    on m.Module_Code = v.Module_Code
  left join Mpt_Template_Type_Vars tv
    on tv.Template_Code = tt.Template_Code
   and tv.Variable_Code = v.Variable_Code
 where v.Is_Active = 'Y'
;
