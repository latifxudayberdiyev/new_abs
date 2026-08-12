create or replace package Pf_Api_Products is

  -- Author  : B.URALOV
  -- Purpose : "Fabrika produktov" mahsulotlarini ESBIN orqali tashqi tizimlarga
  --           faqat o'qish uchun taqdim etuvchi API (TZ: Get_Products_By_
  --           category_code_and_product_code - getProductByCategory / getProductByCode).
  --           Mavjud Pf_Kernel/Pf_Dml/Pf_Util'ga TEGMAYDI - faqat ulardan va PF
  --           view'laridan o'qiydi (alohida, mustaqil package).

  Procedure Get_Products_By_Category
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

  Procedure Get_Product_By_Code
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  );

end Pf_Api_Products;
/
create or replace package body Pf_Api_Products is

  c_Special_Type_Branch    constant varchar2(20) := 'BRANCH';
  c_Special_Type_Operation constant varchar2(20) := 'OPERATION';

  ----
  -- {ru,uz,en} ko'p tilli obyekt (MLL label kodi asosida, lang_index: 1=ru,
  -- 3=uz-lot, 4=en - MLT_LANGUAGES_V bo'yicha).
  ----
  Function Build_Ml_Object(i_Ml_Code varchar2) return Core.Hash_t is
    v_Obj Core.Hash_t := Core.Hash_t();
  begin
    if i_Ml_Code is not null then
      v_Obj.Put('ru', Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => i_Ml_Code, i_Lang_Index => 1));
      v_Obj.Put('uz', Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => i_Ml_Code, i_Lang_Index => 3));
      v_Obj.Put('en', Mll_Core_Api.Get_Label(i_Module_Code => 'PF', i_Message_Code => i_Ml_Code, i_Lang_Index => 4));
    end if;
    return v_Obj;
  end Build_Ml_Object;

  ----
  -- SPECIAL_TYPE='BRANCH' atributi asosida branch_scope obyekti
  -- (PF_PRODUCT_SPECIAL_ATTRS.SCOPE_MODE + PF_PRODUCT_SPECIAL_ATTR_ITEMS,
  -- Pf_Kernel.Model_Product_Special_Attr bilan bir xil manba).
  ----
  Function Build_Branch_Scope(i_Version_Id number) return Core.Hash_t is
    v_Result       Core.Hash_t := Core.Hash_t();
    v_Attribute_Id number;
    v_Scope_Mode   varchar2(20) := 'ALL';
    v_Branches     Core.Array_Varchar2 := Core.Array_Varchar2();
  begin
    begin
      select Id into v_Attribute_Id from Pf_R_Attributes where Special_Type = c_Special_Type_Branch and Rownum = 1;
    exception
      when No_Data_Found then
        v_Attribute_Id := null;
    end;

    if v_Attribute_Id is not null then
      begin
        select Scope_Mode
          into v_Scope_Mode
          from Pf_Product_Special_Attrs
         where Version_Id = i_Version_Id
           and Attribute_Id = v_Attribute_Id;
      exception
        when No_Data_Found then
          v_Scope_Mode := 'ALL';
      end;

      for r in (select Item_Code
                  from Pf_Product_Special_Attr_Items
                 where Version_Id = i_Version_Id
                   and Attribute_Id = v_Attribute_Id)
      loop
        v_Branches.Extend;
        v_Branches(v_Branches.Count) := r.Item_Code;
      end loop;
    end if;

    v_Result.Put('mode', Lower(v_Scope_Mode));
    v_Result.Put('branches', v_Branches);
    return v_Result;
  end Build_Branch_Scope;

  ----
  -- SPECIAL_TYPE='OPERATION' atributi asosida operations[] ro'yxati.
  ----
  Function Build_Operations(i_Version_Id number) return Core.Array_Varchar2 is
    v_Result       Core.Array_Varchar2 := Core.Array_Varchar2();
    v_Attribute_Id number;
  begin
    begin
      select Id into v_Attribute_Id from Pf_R_Attributes where Special_Type = c_Special_Type_Operation and Rownum = 1;
    exception
      when No_Data_Found then
        v_Attribute_Id := null;
    end;

    if v_Attribute_Id is not null then
      for r in (select Item_Code
                  from Pf_Product_Special_Attr_Items
                 where Version_Id = i_Version_Id
                   and Attribute_Id = v_Attribute_Id)
      loop
        v_Result.Extend;
        v_Result(v_Result.Count) := r.Item_Code;
      end loop;
    end if;
    return v_Result;
  end Build_Operations;

  ----
  -- SPECIAL bo'lmagan atributlarning parametr qiymatlari - dinamik, productda
  -- haqiqatda mavjud bo'lgan atribut/parametrlarga qarab (accounts/percent_rates/
  -- schedule kabi TZ'da so'ralgan, lekin PF'da hali alohida strukturaga ega
  -- bo'lmagan bo'limlar shu umumiy ro'yxat ichida keladi).
  ----
  Function Build_Parameters(i_Product_Id number, i_Version_No number) return Core.Arraylist is
    v_Result Core.Arraylist := Core.Arraylist();
    v_Item   Core.Hash_t;
  begin
    for r in (select av.Code Attribute_Key, av.Name Attribute_Name, pr.Name Param_Name,
                     Lower(pr.Value_Type) Value_Type, v.Value
                from Pf_Product_Parameter_Values_V v
                join Pf_R_Parameters_V pr on pr.Id = v.Parameter_Id
                join Pf_R_Attributes a on a.Id = pr.Attribute_Id
                join Pf_R_Attributes_V av on av.Id = a.Id
               where v.Product_Id = i_Product_Id
                 and v.Version_No = i_Version_No
                 and a.Special_Type is null
               order by a.Sort_Order, pr.Sort_Order)
    loop
      v_Item := Core.Hash_t();
      v_Item.Put('attribute_key', r.Attribute_Key);
      v_Item.Put('attribute_name', r.Attribute_Name);
      v_Item.Put('param_name', r.Param_Name);
      v_Item.Put('value_type', r.Value_Type);
      v_Item.Put('value', r.Value);
      v_Result.Push(v_Item);
    end loop;
    return v_Result;
  end Build_Parameters;

  ----
  -- SM_OBJECTS_H asosida hayot davri tarixi - haqiqiy audit ma'lumoti
  -- (CREATED/EDITED, TZ kutgan to'liq biznes-status tranzitsiya tarixi emas,
  -- chunki PF hozircha alohida biznes-status jurnaliga ega emas).
  ----
  Function Build_Lifecycle_History(i_Product_Id number) return Core.Arraylist is
    v_Result     Core.Arraylist := Core.Arraylist();
    v_Item       Core.Hash_t;
    v_Prev_State varchar2(20);
  begin
    for r in (select State, Modify_On, Action_Note
                from Sm_Objects_H
               where Object_Code = 'PF_PRODUCT'
                 and Relation_Id = i_Product_Id
               order by Modify_On)
    loop
      v_Item := Core.Hash_t();
      v_Item.Put('date', to_char(r.Modify_On, 'YYYY-MM-DD"T"HH24:MI:SS'));
      if v_Prev_State is not null then
        v_Item.Put('from_status', v_Prev_State);
      end if;
      v_Item.Put('to_status', r.State);
      v_Item.Put('comment', Nvl(r.Action_Note, ''));
      v_Result.Push(v_Item);
      v_Prev_State := r.State;
    end loop;
    return v_Result;
  end Build_Lifecycle_History;

  ----
  -- v_Envelope'ga {success:false,error:{code,message}} yozadi. o_Code SM
  -- darajasida 0 (muvaffaqiyatli chaqiruv) qoladi - bu biznes-darajadagi xato,
  -- ESBIN/SM darajasidagi nosozlik emas (http 200 + xato JSON'ga o'xshash
  -- mantiq).
  --
  -- MUHIM: Core_Api.Get_Model_Clob Io_Hash'ning FAQAT 'data' kalitini olib,
  -- shuni javob sifatida qaytaradi (Io_Hash'ning boshqa hech qanday kaliti
  -- javobga chiqmaydi) - shu sabab {success,data,error} konvertining o'zi
  -- Io_Hash.Put('data', <shu konvert>) shaklida BITTA marta, protsedura oxirida
  -- yoziladi - to'g'ridan-to'g'ri Io_Hash'ga emas.
  ----
  Procedure Set_Error(Io_Envelope in out nocopy Core.Hash_t, i_Error_Code varchar2, i_Message varchar2) is
    v_Error Core.Hash_t := Core.Hash_t();
  begin
    Io_Envelope.Put('success', 'false');
    v_Error.Put('code', i_Error_Code);
    v_Error.Put('message', i_Message);
    Io_Envelope.Put('error', v_Error);
  end Set_Error;

  Procedure Get_Products_By_Category
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Category_Code    varchar2(50);
    v_Category         Pf_R_Categories%rowtype;
    v_Category_Name    varchar2(4000);
    v_Status           varchar2(20);
    v_Delivery_Type    varchar2(20);
    v_Delivery_Type_Id number;
    v_Page             number;
    v_Limit            number;
    v_Total            number;
    v_Envelope         Core.Hash_t := Core.Hash_t();
    v_Data             Core.Hash_t := Core.Hash_t();
    v_Items            Core.Arraylist := Core.Arraylist();
    v_Item             Core.Hash_t;
  begin
    o_Code := 0;
    v_Envelope.Put('success', 'true');

    v_Category_Code := Io_Hash.Get_Optional_Varchar2('category_code');
    if v_Category_Code is null then
      Set_Error(v_Envelope, 'VALIDATION_ERROR', 'category_code majburiy parametr.');
      Io_Hash.Put('data', v_Envelope);
      return;
    end if;

    begin
      Pf_Util.Select_Category_By_Code(i_Code => Upper(v_Category_Code), i_Is_Raise => true, o_Category => v_Category);
    exception
      when others then
        Set_Error(v_Envelope, 'CATEGORY_NOT_FOUND', 'Ko''rsatilgan category_code bo''yicha kategoriya topilmadi.');
        Io_Hash.Put('data', v_Envelope);
        return;
    end;
    select Name into v_Category_Name from Pf_R_Categories_V where Id = v_Category.Id;

    v_Status        := Upper(Io_Hash.Get_Optional_Varchar2('status'));
    v_Delivery_Type := Upper(Io_Hash.Get_Optional_Varchar2('delivery_type'));
    if v_Delivery_Type is not null then
      begin
        select Id into v_Delivery_Type_Id from Pf_R_Product_Delivery_Types where Code = v_Delivery_Type;
      exception
        when No_Data_Found then
          Set_Error(v_Envelope, 'VALIDATION_ERROR', 'Noto''g''ri delivery_type qiymati.');
          Io_Hash.Put('data', v_Envelope);
          return;
      end;
    end if;

    v_Page  := Nvl(Io_Hash.Get_Optional_Number('page_number'), 1);
    v_Limit := Least(Nvl(Io_Hash.Get_Optional_Number('page_size'), 20), 100);
    if v_Page < 1 then
      v_Page := 1;
    end if;
    if v_Limit < 1 then
      v_Limit := 20;
    end if;

    select count(*)
      into v_Total
      from Pf_Products_V p
     where p.Category_Id = v_Category.Id
       and p.Current_State = Nvl(v_Status, 'ACTIVE')
       and p.Delivery_Type_Id = Nvl(v_Delivery_Type_Id, p.Delivery_Type_Id);

    for r in (select p.Id, p.Code, p.Current_State, p.Current_Version_No, p.Start_Date, p.End_Date, p.Created_At,
                     dt.Code Delivery_Type_Code, s.Name State_Name, pt.Ml_Name_Code
                from Pf_Products_V p
                join Pf_Products pt on pt.Id = p.Id
                join Pf_R_Product_Delivery_Types dt on dt.Id = p.Delivery_Type_Id
                left join Pf_R_Product_States_V s on s.Code = p.Current_State
               where p.Category_Id = v_Category.Id
                 and p.Current_State = Nvl(v_Status, 'ACTIVE')
                 and p.Delivery_Type_Id = Nvl(v_Delivery_Type_Id, p.Delivery_Type_Id)
               order by p.Code
              offset (v_Page - 1) * v_Limit rows fetch next v_Limit rows only)
    loop
      v_Item := Core.Hash_t();
      v_Item.Put('product_code', r.Code);
      v_Item.Put('category_code', v_Category.Code);
      v_Item.Put('category_name', v_Category_Name);
      v_Item.Put('name', Build_Ml_Object(r.Ml_Name_Code));
      v_Item.Put('status', r.Current_State);
      v_Item.Put('status_name', Nvl(r.State_Name, r.Current_State));
      v_Item.Put('version', r.Current_Version_No);
      v_Item.Put('delivery_types', Core.Array_Varchar2(r.Delivery_Type_Code));
      if r.Start_Date is not null then
        v_Item.Put('date_start', to_char(r.Start_Date, 'YYYY-MM-DD'));
      end if;
      if r.End_Date is not null then
        v_Item.Put('date_end', to_char(r.End_Date, 'YYYY-MM-DD'));
      end if;
      -- active_contracts: PF hali shartnoma (contract) tizimiga bog'lanmagan -
      -- shu sabab hozircha doim 0.
      v_Item.Put('active_contracts', 0);
      v_Item.Put('created_at', to_char(r.Created_At, 'YYYY-MM-DD'));
      v_Items.Push(v_Item);
    end loop;

    v_Data.Put('total', v_Total);
    v_Data.Put('page', v_Page);
    v_Data.Put('limit', v_Limit);
    v_Data.Put('items', v_Items);
    v_Envelope.Put('data', v_Data);
    Io_Hash.Put('data', v_Envelope);
  exception
    when others then
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Get_Products_By_Category;

  Procedure Get_Product_By_Code
  (
    Io_Hash   in out nocopy Core.Hash_t,
    o_Code    out number,
    o_Msg     out varchar2,
    o_Ora_Msg out varchar2
  ) is
    v_Product_Code varchar2(50);
    v_I_Version    number;
    v_Product      Pf_Products%rowtype;
    v_Version_No   number;
    v_Version      Pf_Product_Versions%rowtype;
    v_Category     Pf_R_Categories%rowtype;
    v_Category_Name varchar2(4000);
    v_Delivery_Code varchar2(20);
    v_State_Name   varchar2(4000);
    v_Envelope     Core.Hash_t := Core.Hash_t();
    v_Data         Core.Hash_t := Core.Hash_t();
    v_Schedule     Core.Hash_t := Core.Hash_t();
  begin
    o_Code := 0;
    v_Envelope.Put('success', 'true');

    v_Product_Code := Io_Hash.Get_Optional_Varchar2('product_code');
    if v_Product_Code is null then
      Set_Error(v_Envelope, 'VALIDATION_ERROR', 'product_code majburiy parametr.');
      Io_Hash.Put('data', v_Envelope);
      return;
    end if;

    begin
      Pf_Util.Select_Product_By_Code(i_Code => v_Product_Code, i_Is_Raise => true, o_Product => v_Product);
    exception
      when others then
        Set_Error(v_Envelope, 'PRODUCT_NOT_FOUND', 'Ko''rsatilgan product_code bo''yicha mahsulot topilmadi.');
        Io_Hash.Put('data', v_Envelope);
        return;
    end;

    v_I_Version := Io_Hash.Get_Optional_Number('version');
    if v_I_Version is not null then
      begin
        select *
          into v_Version
          from Pf_Product_Versions
         where Product_Id = v_Product.Id
           and Version_No = v_I_Version;
      exception
        when No_Data_Found then
          Set_Error(v_Envelope, 'PRODUCT_NOT_FOUND', 'Ko''rsatilgan product_code (yoki version) bo''yicha mahsulot topilmadi.');
          Io_Hash.Put('data', v_Envelope);
          return;
      end;
    else
      Pf_Util.Select_Latest_Product_Version(i_Product_Id => v_Product.Id, i_Is_Raise => true, o_Version => v_Version);
    end if;
    v_Version_No := v_Version.Version_No;

    Pf_Util.Select_Category(i_Id => v_Product.Category_Id, i_Is_Raise => true, o_Category => v_Category);
    select Name into v_Category_Name from Pf_R_Categories_V where Id = v_Category.Id;

    select Code into v_Delivery_Code from Pf_R_Product_Delivery_Types where Id = v_Product.Delivery_Type_Id;

    begin
      select Name into v_State_Name from Pf_R_Product_States_V where Code = v_Version.State;
    exception
      when No_Data_Found then
        v_State_Name := v_Version.State;
    end;

    v_Data.Put('product_code', v_Product.Code);
    v_Data.Put('category_id', v_Category.Code);
    v_Data.Put('category_name', v_Category_Name);
    v_Data.Put('name', Build_Ml_Object(v_Product.Ml_Name_Code));
    v_Data.Put('description', Build_Ml_Object(v_Product.Ml_Description_Code));
    if v_Product.Owner_Id is not null then
      declare
        v_Owner_Name varchar2(200);
      begin
        select Name into v_Owner_Name from Core_Users where User_Id = v_Product.Owner_Id;
        v_Data.Put('owner', v_Owner_Name);
      exception
        when No_Data_Found then
          null;
      end;
    end if;
    v_Data.Put('delivery_types', Core.Array_Varchar2(v_Delivery_Code));
    v_Data.Put('status', v_Version.State);
    v_Data.Put('status_name', v_State_Name);
    v_Data.Put('version', v_Version_No);
    if v_Version.Start_Date is not null then
      v_Data.Put('date_start', to_char(v_Version.Start_Date, 'YYYY-MM-DD'));
    end if;
    if v_Version.End_Date is not null then
      v_Data.Put('date_end', to_char(v_Version.End_Date, 'YYYY-MM-DD'));
    end if;
    v_Data.Put('keep_linked', case when Nvl(v_Version.Continue_On_Expiry, 0) = 1 then 'true' else 'false' end);
    -- active_contracts: PF hali shartnoma (contract) tizimiga bog'lanmagan -
    -- shu sabab hozircha doim 0.
    v_Data.Put('active_contracts', 0);
    v_Data.Put('branch_scope', Build_Branch_Scope(v_Version.Id));

    -- accounts/percent_rates/schedule - PF'da hali alohida SPECIAL_TYPE/struktura
    -- yo'q (faqat BRANCH va OPERATION mavjud), shu sabab hozircha bo'sh qaytadi.
    v_Data.Put('accounts', Core.Arraylist());
    v_Data.Put('percent_rates', Core.Arraylist());
    v_Schedule.Put('main_schedule', 'false');
    v_Schedule.Put('percent_schedule', 'false');
    v_Schedule.Put('grace_period', 'false');
    v_Schedule.Put('grace_months', 0);
    v_Data.Put('schedule', v_Schedule);

    v_Data.Put('operations', Build_Operations(v_Version.Id));
    v_Data.Put('parameters', Build_Parameters(v_Product.Id, v_Version_No));

    declare
      v_Lifecycle Core.Hash_t := Core.Hash_t();
    begin
      v_Lifecycle.Put('history', Build_Lifecycle_History(v_Product.Id));
      v_Data.Put('lifecycle', v_Lifecycle);
    end;

    v_Envelope.Put('data', v_Data);
    Io_Hash.Put('data', v_Envelope);
  exception
    when others then
      o_Code    := -1;
      o_Msg     := Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  end Get_Product_By_Code;

end Pf_Api_Products;
/
