create or replace package Pf_Util is

-- Author  : B.URALOV
-- Purpose : Fabrika produktov moduli uchun select/qidiruv funksiyalari.

Procedure Select_Category
(
  i_Id	     number,
  i_Is_Raise boolean := true,
  o_Category out Pf_R_Categories%rowtype
);

Procedure Select_Category_By_Code
(
  i_Code     varchar2,
  i_Is_Raise boolean := true,
  o_Category out Pf_R_Categories%rowtype
);

Function Exists_Category_Code(i_Code varchar2) return boolean;

Function Exists_Category(i_Id number) return boolean;

Procedure Select_Parameter
(
  i_Id	      number,
  i_Is_Raise  boolean := true,
  o_Parameter out Pf_R_Parameters%rowtype
);

Procedure Select_Parameter_By_Code
(
  i_Attribute_Id number,
  i_Code	 varchar2,
  i_Is_Raise	 boolean := true,
  o_Parameter	 out Pf_R_Parameters%rowtype
);

Function Exists_Parameter_Code(i_Attribute_Id number, i_Code varchar2) return boolean;

Function Exists_Reference_View(i_Id number) return boolean;

Function Exists_Attribute(i_Id number) return boolean;

Procedure Select_Attribute
(
  i_Id	      number,
  i_Is_Raise  boolean := true,
  o_Attribute out Pf_R_Attributes%rowtype
);

Procedure Select_Attribute_By_Code
(
  i_Code      varchar2,
  i_Is_Raise  boolean := true,
  o_Attribute out Pf_R_Attributes%rowtype
);

Function Exists_Attribute_Code(i_Code varchar2) return boolean;

Function Count_Attribute_Parameters(i_Attribute_Id number) return number;

Function Get_Attribute_Category_Ids(i_Attribute_Id number) return Core.Array_Number;

Function Exists_Product_Delivery_Type(i_Id number) return boolean;

Procedure Select_Product
(
  i_Id	     number,
  i_Is_Raise boolean := true,
  o_Product  out Pf_Products%rowtype
);

Procedure Select_Product_By_Code
(
  i_Code     varchar2,
  i_Is_Raise boolean := true,
  o_Product  out Pf_Products%rowtype
);

Function Exists_Product_Code(i_Code varchar2) return boolean;

Procedure Select_Latest_Product_Version
(
  i_Product_Id number,
  i_Is_Raise   boolean := true,
  o_Version    out Pf_Product_Versions%rowtype
);

Procedure Select_Version_Rule
(
  i_Id	     number,
  i_Is_Raise boolean := true,
  o_Rule     out Pf_Version_Rules%rowtype
);

-- Kategoriya/mahsulotga tegishli PF_VERSION_RULES qoidalarini i_Values (kalit =
-- to_char(parameter_id), qiymat = parametr matn qiymati) asosida tekshiradi.
-- Barcha qoidalar bajarilsa true, aks holda false + o_Error_Msg birinchi
-- buzilgan qoidaning xabari bilan qaytadi (SORT_ORDER bo'yicha).
Function Evaluate_Version_Rules
(
  i_Category_Id number,
  i_Product_Id	number,
  i_Values	Core.Hash_t,
  o_Error_Msg	out varchar2
) return boolean;

-- input_type=FUNCTION parametr uchun: shu parametrni TARGET qilib ko'rsatgan
-- birinchi mos keluvchi VALUE_CHECK_IF qoidaning TARGET.value'sini qaytaradi,
-- mos qoida topilmasa NULL.
Function Get_Rule_Derived_Value
(
  i_Category_Id  number,
  i_Product_Id	 number,
  i_Parameter_Id number,
  i_Values	 Core.Hash_t
) return varchar2;

end Pf_Util;



/
create or replace package body Pf_Util is

Procedure Select_Category
(
  i_Id	     number,
  i_Is_Raise boolean := true,
  o_Category out Pf_R_Categories%rowtype
) is
begin
  select *
    into o_Category
    from Pf_R_Categories
   where Id = i_Id;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Category;

Procedure Select_Category_By_Code
(
  i_Code     varchar2,
  i_Is_Raise boolean := true,
  o_Category out Pf_R_Categories%rowtype
) is
begin
  select *
    into o_Category
    from Pf_R_Categories
   where Code = i_Code;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Category_By_Code;

Function Exists_Category_Code(i_Code varchar2) return boolean is
  v_Category Pf_R_Categories%rowtype;
begin
  Select_Category_By_Code(i_Code => i_Code, i_Is_Raise => false, o_Category => v_Category);
  return v_Category.Id is not null;
end Exists_Category_Code;

Function Exists_Category(i_Id number) return boolean is
  v_Dummy number;
begin
  select 1
    into v_Dummy
    from Pf_R_Categories
   where Id = i_Id;
  return true;
exception
  when no_data_found then
    return false;
end Exists_Category;

Procedure Select_Parameter
(
  i_Id	      number,
  i_Is_Raise  boolean := true,
  o_Parameter out Pf_R_Parameters%rowtype
) is
begin
  select *
    into o_Parameter
    from Pf_R_Parameters
   where Id = i_Id;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Parameter;

Procedure Select_Parameter_By_Code
(
  i_Attribute_Id number,
  i_Code	 varchar2,
  i_Is_Raise	 boolean := true,
  o_Parameter	 out Pf_R_Parameters%rowtype
) is
begin
  select *
    into o_Parameter
    from Pf_R_Parameters
   where Attribute_Id = i_Attribute_Id
     and Code = i_Code;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Parameter_By_Code;

Function Exists_Parameter_Code(i_Attribute_Id number, i_Code varchar2) return boolean is
  v_Parameter Pf_R_Parameters%rowtype;
begin
  Select_Parameter_By_Code(i_Attribute_Id => i_Attribute_Id, i_Code => i_Code, i_Is_Raise => false, o_Parameter => v_Parameter);
  return v_Parameter.Id is not null;
end Exists_Parameter_Code;

Function Exists_Reference_View(i_Id number) return boolean is
  v_Dummy number;
begin
  select 1
    into v_Dummy
    from Pf_R_Reference_Views
   where Id = i_Id;
  return true;
exception
  when no_data_found then
    return false;
end Exists_Reference_View;

Function Exists_Attribute(i_Id number) return boolean is
  v_Dummy number;
begin
  select 1
    into v_Dummy
    from Pf_R_Attributes
   where Id = i_Id;
  return true;
exception
  when no_data_found then
    return false;
end Exists_Attribute;

Procedure Select_Attribute
(
  i_Id	      number,
  i_Is_Raise  boolean := true,
  o_Attribute out Pf_R_Attributes%rowtype
) is
begin
  select *
    into o_Attribute
    from Pf_R_Attributes
   where Id = i_Id;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Attribute;

Procedure Select_Attribute_By_Code
(
  i_Code      varchar2,
  i_Is_Raise  boolean := true,
  o_Attribute out Pf_R_Attributes%rowtype
) is
begin
  select *
    into o_Attribute
    from Pf_R_Attributes
   where Code = i_Code;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Attribute_By_Code;

Function Exists_Attribute_Code(i_Code varchar2) return boolean is
  v_Attribute Pf_R_Attributes%rowtype;
begin
  Select_Attribute_By_Code(i_Code => i_Code, i_Is_Raise => false, o_Attribute => v_Attribute);
  return v_Attribute.Id is not null;
end Exists_Attribute_Code;

Function Count_Attribute_Parameters(i_Attribute_Id number) return number is
  v_Count number;
begin
  select count(*)
    into v_Count
    from Pf_R_Parameters
   where Attribute_Id = i_Attribute_Id;
  return v_Count;
end Count_Attribute_Parameters;

Function Get_Attribute_Category_Ids(i_Attribute_Id number) return Core.Array_Number is
  v_Ids Core.Array_Number;
begin
  select Category_Id
    bulk collect into v_Ids
    from Pf_R_Attribute_Categories
   where Attribute_Id = i_Attribute_Id;
  return v_Ids;
end Get_Attribute_Category_Ids;

Function Exists_Product_Delivery_Type(i_Id number) return boolean is
  v_Dummy number;
begin
  select 1
    into v_Dummy
    from Pf_R_Product_Delivery_Types
   where Id = i_Id;
  return true;
exception
  when no_data_found then
    return false;
end Exists_Product_Delivery_Type;

Procedure Select_Product
(
  i_Id	     number,
  i_Is_Raise boolean := true,
  o_Product  out Pf_Products%rowtype
) is
begin
  select *
    into o_Product
    from Pf_Products
   where Id = i_Id;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Product;

Procedure Select_Product_By_Code
(
  i_Code     varchar2,
  i_Is_Raise boolean := true,
  o_Product  out Pf_Products%rowtype
) is
begin
  select *
    into o_Product
    from Pf_Products
   where Code = i_Code;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Product_By_Code;

Function Exists_Product_Code(i_Code varchar2) return boolean is
  v_Product Pf_Products%rowtype;
begin
  Select_Product_By_Code(i_Code => i_Code, i_Is_Raise => false, o_Product => v_Product);
  return v_Product.Id is not null;
end Exists_Product_Code;

Procedure Select_Latest_Product_Version
(
  i_Product_Id number,
  i_Is_Raise   boolean := true,
  o_Version    out Pf_Product_Versions%rowtype
) is
begin
  select *
    into o_Version
    from Pf_Product_Versions
   where Product_Id = i_Product_Id
     and Version_No = (select max(v2.Version_No) from Pf_Product_Versions v2 where v2.Product_Id = i_Product_Id);
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Latest_Product_Version;

Procedure Select_Version_Rule
(
  i_Id	     number,
  i_Is_Raise boolean := true,
  o_Rule     out Pf_Version_Rules%rowtype
) is
begin
  select *
    into o_Rule
    from Pf_Version_Rules
   where Id = i_Id;
exception
  when no_data_found then
    if i_Is_Raise then
	raise;
    end if;
end Select_Version_Rule;

----
-- Bitta shart elementini ({"parameter_id":..,"op":..,"value":..,"value2":..})
-- joriy qiymatlar (i_Values) asosida tekshiradi.
----
Function Compare_Value
(
  i_Value      varchar2,
  i_Op	       varchar2,
  i_Cmp_Value  varchar2,
  i_Cmp_Value2 varchar2 := null
) return boolean is
  v_Num  number;
  v_Cmp1 number;
  v_Cmp2 number;
begin
  if i_Value is null then
    return false;
  end if;
  if i_Op = '=' then
    return i_Value = i_Cmp_Value;
  elsif i_Op = '!=' then
    return i_Value != i_Cmp_Value;
  elsif i_Op = 'IN' then
    return instr(',' || i_Cmp_Value || ',', ',' || i_Value || ',') > 0;
  elsif i_Op in ('>', '<', '>=', '<=', 'BETWEEN') then
    begin
      v_Num  := to_number(i_Value);
      v_Cmp1 := to_number(i_Cmp_Value);
    exception
      when others then
	return false;
    end;
    if i_Op = '>' then
      return v_Num > v_Cmp1;
    elsif i_Op = '<' then
      return v_Num < v_Cmp1;
    elsif i_Op = '>=' then
      return v_Num >= v_Cmp1;
    elsif i_Op = '<=' then
      return v_Num <= v_Cmp1;
    else
      begin
	v_Cmp2 := to_number(i_Cmp_Value2);
      exception
	when others then
	  return false;
      end;
      return v_Num between v_Cmp1 and v_Cmp2;
    end if;
  end if;
  return false;
end Compare_Value;

Function Match_Rule_Item
(
  i_Item_Json varchar2,
  i_Values    Core.Hash_t
) return boolean is
  v_Parameter_Id varchar2(50);
  v_Op		 varchar2(10);
  v_Cmp_Value	 varchar2(4000);
  v_Cmp_Value2	 varchar2(4000);
begin
  v_Parameter_Id := Json_Value(i_Item_Json, '$.parameter_id');
  v_Op		 := Json_Value(i_Item_Json, '$.op');
  v_Cmp_Value	 := Json_Value(i_Item_Json, '$.value');
  v_Cmp_Value2	 := Json_Value(i_Item_Json, '$.value2');
  return Compare_Value(i_Values.Get_Optional_Varchar2(v_Parameter_Id),
		       v_Op,
		       v_Cmp_Value,
		       v_Cmp_Value2);
end Match_Rule_Item;

----
-- TARGET uchun: parametr endi alohida PARAMETER_ID ustunida (JSON ichida emas) -
-- shu sabab qiymatni to'g'ridan-to'g'ri i_Parameter_Id orqali olamiz, op/value/
-- value2'ni esa TARGET JSON'idan.
----
Function Match_Target
(
  i_Parameter_Id number,
  i_Target_Json  Clob,
  i_Values	 Core.Hash_t
) return boolean is
  v_Op	       varchar2(10);
  v_Cmp_Value  varchar2(4000);
  v_Cmp_Value2 varchar2(4000);
begin
  v_Op		:= Json_Value(i_Target_Json, '$.op');
  v_Cmp_Value	:= Json_Value(i_Target_Json, '$.value');
  v_Cmp_Value2	:= Json_Value(i_Target_Json, '$.value2');
  return Compare_Value(i_Values.Get_Optional_Varchar2(to_char(i_Parameter_Id)),
		       v_Op,
		       v_Cmp_Value,
		       v_Cmp_Value2);
end Match_Target;

----
-- CONDITION massividagi barcha elementlar (AND) i_Values bilan mos keladimi
----
Function Match_All_Conditions
(
  i_Condition Clob,
  i_Values    Core.Hash_t
) return boolean is
begin
  for c in (select jt.Item_Json
	      from dual,
		   Json_Table(i_Condition, '$[*]' columns(Item_Json varchar2(4000) format json path '$')) jt) loop
    if not Match_Rule_Item(c.Item_Json, i_Values) then
      return false;
    end if;
  end loop;
  return true;
end Match_All_Conditions;

Function Evaluate_Version_Rules
(
  i_Category_Id number,
  i_Product_Id	number,
  i_Values	Core.Hash_t,
  o_Error_Msg	out varchar2
) return boolean is
  v_Ok	       boolean;
begin
  -- FUNCTION turidagi (hisoblanadigan) parametrga tegishli VALUE_CHECK_IF
  -- qatorlari - bu qaror jadvali (Get_Rule_Derived_Value uchun), haqiqiy
  -- validatsiya sharti emas - shu sabab bu yerda o'tkazib yuboriladi.
  for r in (select rul.Id, rul.Rule_Type, rul.Condition, rul.Target, rul.Parameter_Id, rul.Ml_Error_Code
	      from Pf_Version_Rules rul
	      join Pf_R_Parameters par on par.Id = rul.Parameter_Id
	     where (rul.Category_Id = i_Category_Id
		     or rul.Product_Id = i_Product_Id
		     or (rul.Category_Id is null and rul.Product_Id is null))
	       and not (rul.Rule_Type = 'VALUE_CHECK_IF' and par.Input_Type = 'FUNCTION')
	     order by rul.Sort_Order) loop
    if Match_All_Conditions(r.Condition, i_Values) then
      if r.Rule_Type = 'REQUIRED_IF' then
	v_Ok := i_Values.Get_Optional_Varchar2(to_char(r.Parameter_Id)) is not null;
      else
	-- FORBIDDEN_IF: target mos kelsa taqiqlangan -> qoida buzilgan
	-- VALUE_CHECK_IF: target mos kelmasa -> qoida buzilgan
	v_Ok := Match_Target(r.Parameter_Id, r.Target, i_Values);
	if r.Rule_Type = 'FORBIDDEN_IF' then
	  v_Ok := not v_Ok;
	end if;
      end if;
      if not v_Ok then
	-- Ml_Error_Code - PF_VERSION_RULES_V'da ham ishlatilgan Mll label kodi
	-- (raqamli Mle xato-kodi emas), shu sabab Mll_Core_Api.Get_Label bilan olinadi.
	o_Error_Msg := Mll_Core_Api.Get_Label(i_Module_Code  => Pf_Const.c_Module_Code,
					      i_Message_Code => r.Ml_Error_Code);
	return false;
      end if;
    end if;
  end loop;
  return true;
end Evaluate_Version_Rules;

Function Get_Rule_Derived_Value
(
  i_Category_Id  number,
  i_Product_Id	 number,
  i_Parameter_Id number,
  i_Values	 Core.Hash_t
) return varchar2 is
begin
  for r in (select Condition, Target
	      from Pf_Version_Rules
	     where (Category_Id = i_Category_Id
		     or Product_Id = i_Product_Id
		     or (Category_Id is null and Product_Id is null))
	       and Rule_Type = 'VALUE_CHECK_IF'
	       and Parameter_Id = i_Parameter_Id
	     order by Sort_Order) loop
    if Match_All_Conditions(r.Condition, i_Values) then
      return Json_Value(r.Target, '$.value');
    end if;
  end loop;
  return null;
end Get_Rule_Derived_Value;

end Pf_Util;



/
