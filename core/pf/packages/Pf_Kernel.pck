create or replace PACKAGE        "PF_KERNEL" is

  Procedure Model_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2);

  Procedure Save_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			  o_Code    Out Number,
			  o_Msg     Out Varchar2,
			  o_Ora_Msg Out Varchar2);

  Procedure Delete_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2);

  Procedure Model_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2);

  Procedure Save_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2);

  Procedure Delete_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			     o_Code    Out Number,
			     o_Msg     Out Varchar2,
			     o_Ora_Msg Out Varchar2);

  Procedure Model_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2);

  Procedure Save_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2);

  Procedure Delete_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			     o_Code    Out Number,
			     o_Msg     Out Varchar2,
			     o_Ora_Msg Out Varchar2);

  Procedure Model_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			  o_Code    Out Number,
			  o_Msg     Out Varchar2,
			  o_Ora_Msg Out Varchar2);

  Procedure Save_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			 o_Code    Out Number,
			 o_Msg	   Out Varchar2,
			 o_Ora_Msg Out Varchar2);

  Procedure Delete_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2);

  Procedure Save_Product_Parameter_Values(Io_Hash   In Out Nocopy Core.Hash_t,
					   o_Code    Out Number,
					   o_Msg     Out Varchar2,
					   o_Ora_Msg Out Varchar2);

  Procedure Preview_Product_Parameters(Io_Hash   In Out Nocopy Core.Hash_t,
				       o_Code    Out Number,
				       o_Msg     Out Varchar2,
				       o_Ora_Msg Out Varchar2);

  Procedure Model_Version_Rule(Io_Hash   In Out Nocopy Core.Hash_t,
			       o_Code    Out Number,
			       o_Msg     Out Varchar2,
			       o_Ora_Msg Out Varchar2);

  Procedure Save_Version_Rule(Io_Hash   In Out Nocopy Core.Hash_t,
			      o_Code    Out Number,
			      o_Msg     Out Varchar2,
			      o_Ora_Msg Out Varchar2);

  Procedure Delete_Version_Rule(Io_Hash   In Out Nocopy Core.Hash_t,
				o_Code    Out Number,
				o_Msg     Out Varchar2,
				o_Ora_Msg Out Varchar2);

end Pf_Kernel;

/
create or replace PACKAGE BODY	    "PF_KERNEL" is

  Procedure Model_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2) Is
    v_Category Pf_R_Categories%Rowtype;
    v_Data     Core.Hash_t := Core.Hash_t();
  Begin
    o_Code := 0;

    Pf_Util.Select_Category(i_Id       => Io_Hash.Get_Optional_Number('category_id'),
			    o_Category => v_Category);

    v_Data.Put('category_id', v_Category.Id);
    v_Data.Put('code', v_Category.Code);
    v_Data.Put('name',
	       Mll_Core_Api.Get_Label(i_Module_Code  => Pf_Const.c_Module_Code,
				      i_Message_Code => v_Category.Ml_Name_Code));
    v_Data.Put('state', v_Category.State);

    Io_Hash.Put('data', v_Data);
  Exception
    When No_Data_Found Then
      o_Code	:= -20040;
      o_Msg	:= 'Kategoriya topilmadi.';
      o_Ora_Msg := o_Msg;
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Model_Category;

  Procedure Save_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			  o_Code    Out Number,
			  o_Msg     Out Varchar2,
			  o_Ora_Msg Out Varchar2) Is
    v_Code	   Pf_R_Categories.Code%Type;
    v_Name	   Varchar2(200);
    v_Ml_Name_Code Pf_R_Categories.Ml_Name_Code%Type;
    v_Sm_Cache	   Core.Hash_t;
    v_Rel_Id	   Number;
    v_Category	   Pf_R_Categories%Rowtype;
    v_Ml_Code	   Number;
    v_Ml_Msg	   Varchar2(4000);
  Begin
    o_Code := 0;
    v_Code := Io_Hash.Get_Varchar2('code');
    v_Name := Io_Hash.Get_Varchar2('name');

    If Pf_Util.Exists_Category_Code(v_Code) Then
      Pf_Util.Select_Category_By_Code(i_Code	 => v_Code,
				      o_Category => v_Category);
      v_Ml_Name_Code := v_Category.Ml_Name_Code;

      Pf_Dml.Update_Category_State(i_Code  => v_Code,
				   i_State => Nvl(Io_Hash.Get_Optional_Varchar2('state'),
						  'A'));
    Else
      v_Ml_Name_Code := 'PF_CATEGORY_' || v_Code;
      v_Sm_Cache     := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Rel_Id	     := v_Sm_Cache.Get_Optional_Number('category_id');

      Pf_Dml.Add_Category(i_Id		 => v_Rel_Id,
			  i_Code	 => v_Code,
			  i_Ml_Name_Code => v_Ml_Name_Code,
			  i_State	 => Nvl(Io_Hash.Get_Optional_Varchar2('state'),
						'A'));
    End If;

    -- MLE/MLL/MLT qo'llanmasiga ko'ra: Mlt_Templates/Mll_Label_Codes'ga
    -- to'g'ridan-to'g'ri INSERT/UPDATE yozilmaydi - faqat *_Dev_Api orqali
    -- (sequence sinxronizatsiyasi shu yerda to'g'ri boshqariladi). Bitta
    -- chaqiruv yaratish va yangilashning ikkalasini ham qamrab oladi.
    Mll_Dev_Api.Save_Label_With_Template_Dev(i_Message_Code	   => v_Ml_Name_Code,
					     i_Description	    => 'PF_CATEGORY nomi',
					     i_Param_Count	    => 0,
					     i_Format_String	    => Mlt_Const.c_Default_Format_String,
					     i_Message_Mask_Lang1   => v_Name,
					     i_Message_Mask_Lang2   => v_Name,
					     i_Message_Mask_Lang3   => v_Name,
					     i_Message_Mask_Lang4   => v_Name,
					     i_Message_Mask_Lang5   => Null,
					     i_Message_Mask_Lang6   => Null,
					     i_Message_Mask_Lang7   => Null,
					     i_Message_Mask_Lang8   => Null,
					     i_Message_Mask_Lang9   => Null,
					     i_Message_Mask_Lang10  => Null,
					     i_Module_Code	    => Pf_Const.c_Module_Code,
					     i_Field_Hint	    => Null,
					     o_Code		    => v_Ml_Code,
					     o_Msg		    => v_Ml_Msg);

    -- Mll_Dev_Api.Save_Label_With_Template_Dev o_Code'i "0=success" emas -
    -- muvaffaqiyatda ham doim ijobiy axborot-kodi (masalan TEMPLATE_CREATED)
    -- qaytaradi. Haqiqiy xato faqat o_Code NULL bo'lganda yuz beradi.
    If v_Ml_Code Is Null Then
      o_Code	:= -1;
      o_Msg	:= v_Ml_Msg;
      o_Ora_Msg := v_Ml_Msg;
    End If;
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Save_Category;

  Procedure Delete_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2) Is
    v_Rows Number;
  Begin
    o_Code := 0;

    Pf_Dml.Delete_Category(i_Id 	  => Io_Hash.Get_Optional_Number('category_id'),
			   o_Rows_Deleted => v_Rows);

    If v_Rows = 0 Then
      o_Code := -20041;
      o_Msg  := 'Kategoriya topilmadi.';
    End If;
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Delete_Category;

  Procedure Model_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2) Is
    v_Parameter Pf_R_Parameters%Rowtype;
    v_Data	Core.Hash_t := Core.Hash_t();
  Begin
    o_Code := 0;

    Pf_Util.Select_Parameter(i_Id	 => Io_Hash.Get_Optional_Number('parameter_id'),
			     o_Parameter => v_Parameter);

    v_Data.Put('parameter_id', v_Parameter.Id);
    v_Data.Put('code', v_Parameter.Code);
    v_Data.Put('name',
	       Mll_Core_Api.Get_Label(i_Module_Code  => Pf_Const.c_Module_Code,
				      i_Message_Code => v_Parameter.Ml_Name_Code));
    v_Data.Put('attribute_id', v_Parameter.Attribute_Id);
    v_Data.Put('value_type', v_Parameter.Value_Type);
    v_Data.Put('input_type', v_Parameter.Input_Type);
    v_Data.Put('change_policy', v_Parameter.Change_Policy);
    v_Data.Put('value_function', v_Parameter.Value_Function);
    If v_Parameter.Reference_Id Is Not Null Then
      v_Data.Put('reference_id', v_Parameter.Reference_Id);
    End If;
    v_Data.Put('is_required', v_Parameter.Is_Required);
    v_Data.Put('default_value', v_Parameter.Default_Value);
    v_Data.Put('sort_order', v_Parameter.Sort_Order);

    Io_Hash.Put('data', v_Data);
  Exception
    When No_Data_Found Then
      o_Code	:= -20042;
      o_Msg	:= 'Parametr topilmadi.';
      o_Ora_Msg := o_Msg;
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Model_Parameter;

  Procedure Save_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2) Is
    v_Code	     Pf_R_Parameters.Code%Type;
    v_Name	     Varchar2(200);
    v_Ml_Name_Code   Pf_R_Parameters.Ml_Name_Code%Type;
    v_Attribute_Id   Pf_R_Parameters.Attribute_Id%Type;
    v_Value_Type     Pf_R_Parameters.Value_Type%Type;
    v_Input_Type     Pf_R_Parameters.Input_Type%Type;
    v_Change_Policy  Pf_R_Parameters.Change_Policy%Type;
    v_Value_Function Pf_R_Parameters.Value_Function%Type;
    v_Reference_Id   Pf_R_Parameters.Reference_Id%Type;
    v_Is_Required    Pf_R_Parameters.Is_Required%Type;
    v_Default_Value  Pf_R_Parameters.Default_Value%Type;
    v_Sort_Order     Pf_R_Parameters.Sort_Order%Type;
    v_Sm_Cache	     Core.Hash_t;
    v_New_Id	     Number;
    v_Existing_Id    Number;
    v_Parameter      Pf_R_Parameters%Rowtype;
    v_Ml_Code	     Number;
    v_Ml_Msg	     Varchar2(4000);
    v_Is_Create      Boolean;
    v_Dummy_Num      Number;
    v_Dummy_Date     Date;
  Begin
    o_Code	     := 0;
    v_Code	     := Io_Hash.Get_Varchar2('code');
    v_Name	     := Io_Hash.Get_Varchar2('name');
    v_Attribute_Id   := Io_Hash.Get_Optional_Number('attribute_id');
    v_Value_Type     := Io_Hash.Get_Varchar2('value_type');
    v_Input_Type     := Nvl(Io_Hash.Get_Optional_Varchar2('input_type'),
			    'MANUAL');
    v_Change_Policy  := Nvl(Io_Hash.Get_Optional_Varchar2('change_policy'),
			    'VERSIONED');
    v_Value_Function := Io_Hash.Get_Optional_Varchar2('value_function');
    v_Reference_Id   := Io_Hash.Get_Optional_Number('reference_id');
    v_Is_Required := Case
		       When Io_Hash.Get_Optional_Varchar2('is_required') = '1' Then
			1
		       Else
			0
		     End;
    v_Default_Value  := Io_Hash.Get_Optional_Varchar2('default_value');
    v_Sort_Order     := Nvl(Io_Hash.Get_Optional_Number('sort_order'), 0);
    v_Is_Create      := Io_Hash.Get_Optional_Varchar2('process_code') =
			'CREATE_PF_PARAMETER';

    If v_Attribute_Id Is Null Or
       Not Pf_Util.Exists_Attribute(v_Attribute_Id) Then
      o_Code	:= -20043;
      o_Msg	:= 'Ko''rsatilgan atribut topilmadi.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If v_Input_Type = 'FUNCTION' And v_Value_Function Is Null Then
      o_Code	:= -20044;
      o_Msg	:= 'INPUT_TYPE=FUNCTION uchun funksiya nomini kiriting.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If v_Input_Type = 'REFERENCE' Then
      If v_Reference_Id Is Null Then
	o_Code	  := -20054;
	o_Msg	  := 'INPUT_TYPE=REFERENCE uchun spravochnikni tanlang.';
	o_Ora_Msg := o_Msg;
	Return;
      End If;
      If Not Pf_Util.Exists_Reference_View(v_Reference_Id) Then
	o_Code	  := -20055;
	o_Msg	  := 'Ko''rsatilgan spravochnik topilmadi.';
	o_Ora_Msg := o_Msg;
	Return;
      End If;
    Else
      v_Reference_Id := Null;
    End If;

    -- DEFAULT_VALUE ni VALUE_TYPE ga mosligini tekshirish
    If v_Default_Value Is Not Null Then
      If v_Value_Type = 'NUMBER' Then
	Begin
	  v_Dummy_Num := To_Number(v_Default_Value);
	Exception
	  When Others Then
	    o_Code    := -20046;
	    o_Msg     := 'Standart qiymat NUMBER turiga mos emas.';
	    o_Ora_Msg := o_Msg;
	    Return;
	End;
      Elsif v_Value_Type = 'DATE' Then
	Begin
	  v_Dummy_Date := To_Date(v_Default_Value, 'DD.MM.YYYY');
	Exception
	  When Others Then
	    o_Code    := -20047;
	    o_Msg     := 'Standart qiymat DATE turiga mos emas (KK.OO.YYYY formatida kiriting).';
	    o_Ora_Msg := o_Msg;
	    Return;
	End;
      Elsif v_Value_Type = 'BOOLEAN' And v_Default_Value Not In ('0', '1') Then
	o_Code	  := -20048;
	o_Msg	  := 'Standart qiymat BOOLEAN turiga mos emas (0 yoki 1 bo''lishi kerak).';
	o_Ora_Msg := o_Msg;
	Return;
      End If;
    End If;

    If v_Is_Create Then
      If Pf_Util.Exists_Parameter_Code(i_Attribute_Id => v_Attribute_Id,
				       i_Code	      => v_Code) Then
	o_Code	  := -20049;
	o_Msg	  := 'Bu kod ushbu atributda allaqachon mavjud. Boshqa kod tanlang.';
	o_Ora_Msg := o_Msg;
	Return;
      End If;

      v_Sm_Cache     := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_New_Id	     := v_Sm_Cache.Get_Optional_Number('parameter_id');
      v_Ml_Name_Code := 'PF_PARAMETER_' || v_New_Id;

      Pf_Dml.Add_Parameter(i_Id 	    => v_New_Id,
			   i_Attribute_Id   => v_Attribute_Id,
			   i_Code	    => v_Code,
			   i_Ml_Name_Code   => v_Ml_Name_Code,
			   i_Value_Type     => v_Value_Type,
			   i_Input_Type     => v_Input_Type,
			   i_Change_Policy  => v_Change_Policy,
			   i_Value_Function => v_Value_Function,
			   i_Reference_Id   => v_Reference_Id,
			   i_Is_Required    => v_Is_Required,
			   i_Default_Value  => v_Default_Value,
			   i_Sort_Order     => v_Sort_Order);
    Else
      v_Existing_Id := Io_Hash.Get_Optional_Number('parameter_id');
      Pf_Util.Select_Parameter(i_Id	   => v_Existing_Id,
			       o_Parameter => v_Parameter);
      v_Ml_Name_Code := v_Parameter.Ml_Name_Code;

      If v_Attribute_Id != v_Parameter.Attribute_Id And
	 Pf_Util.Exists_Parameter_Code(i_Attribute_Id => v_Attribute_Id,
				       i_Code	      => v_Code) Then
	o_Code	  := -20049;
	o_Msg	  := 'Bu kod ushbu atributda allaqachon mavjud. Boshqa kod tanlang.';
	o_Ora_Msg := o_Msg;
	Return;
      End If;

      Pf_Dml.Update_Parameter(i_Id	       => v_Existing_Id,
			      i_Attribute_Id   => v_Attribute_Id,
			      i_Value_Type     => v_Value_Type,
			      i_Input_Type     => v_Input_Type,
			      i_Change_Policy  => v_Change_Policy,
			      i_Value_Function => v_Value_Function,
			      i_Reference_Id   => v_Reference_Id,
			      i_Is_Required    => v_Is_Required,
			      i_Default_Value  => v_Default_Value,
			      i_Sort_Order     => v_Sort_Order);
    End If;

    -- MLE/MLL/MLT qo'llanmasiga ko'ra: Mlt_Templates/Mll_Label_Codes'ga
    -- to'g'ridan-to'g'ri INSERT/UPDATE yozilmaydi - faqat *_Dev_Api orqali.
    Mll_Dev_Api.Save_Label_With_Template_Dev(i_Message_Code	   => v_Ml_Name_Code,
					     i_Description	    => 'PF_PARAMETER nomi',
					     i_Param_Count	    => 0,
					     i_Format_String	    => Mlt_Const.c_Default_Format_String,
					     i_Message_Mask_Lang1   => v_Name,
					     i_Message_Mask_Lang2   => v_Name,
					     i_Message_Mask_Lang3   => v_Name,
					     i_Message_Mask_Lang4   => v_Name,
					     i_Message_Mask_Lang5   => Null,
					     i_Message_Mask_Lang6   => Null,
					     i_Message_Mask_Lang7   => Null,
					     i_Message_Mask_Lang8   => Null,
					     i_Message_Mask_Lang9   => Null,
					     i_Message_Mask_Lang10  => Null,
					     i_Module_Code	    => Pf_Const.c_Module_Code,
					     i_Field_Hint	    => Null,
					     o_Code		    => v_Ml_Code,
					     o_Msg		    => v_Ml_Msg);

    -- Mll_Dev_Api'ning o_Code'i "0=success" emas - haqiqiy xato faqat o_Code
    -- NULL bo'lganda yuz beradi.
    If v_Ml_Code Is Null Then
      o_Code	:= -1;
      o_Msg	:= v_Ml_Msg;
      o_Ora_Msg := v_Ml_Msg;
    End If;
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Save_Parameter;

  Procedure Delete_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			     o_Code    Out Number,
			     o_Msg     Out Varchar2,
			     o_Ora_Msg Out Varchar2) Is
    v_Rows Number;
  Begin
    o_Code := 0;

    Pf_Dml.Delete_Parameter(i_Id	   => Io_Hash.Get_Optional_Number('parameter_id'),
			    o_Rows_Deleted => v_Rows);

    If v_Rows = 0 Then
      o_Code := -20045;
      o_Msg  := 'Parametr topilmadi.';
    End If;
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Delete_Parameter;

  Procedure Model_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2) Is
    v_Attribute Pf_R_Attributes%Rowtype;
    v_Data	Core.Hash_t := Core.Hash_t();
  Begin
    o_Code := 0;

    Pf_Util.Select_Attribute(i_Id	 => Io_Hash.Get_Optional_Number('attribute_id'),
			     o_Attribute => v_Attribute);

    v_Data.Put('attribute_id', v_Attribute.Id);
    v_Data.Put('code', v_Attribute.Code);
    v_Data.Put('name',
	       Mll_Core_Api.Get_Label(i_Module_Code  => Pf_Const.c_Module_Code,
				      i_Message_Code => v_Attribute.Ml_Name_Code));
    v_Data.Put('source_type', v_Attribute.Source_Type);
    v_Data.Put('module_code', v_Attribute.Module_Code);
    v_Data.Put('is_module',
	       Case When v_Attribute.Module_Code Is Not Null Then 1 Else 0 End);
    v_Data.Put('category_ids',
	       Pf_Util.Get_Attribute_Category_Ids(v_Attribute.Id));

    Io_Hash.Put('data', v_Data);
  Exception
    When No_Data_Found Then
      o_Code	:= -20046;
      o_Msg	:= 'Atribut topilmadi.';
      o_Ora_Msg := o_Msg;
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Model_Attribute;

  Procedure Save_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2) Is
    v_Code	   Pf_R_Attributes.Code%Type;
    v_Name	   Varchar2(200);
    v_Ml_Name_Code Pf_R_Attributes.Ml_Name_Code%Type;
    v_Category_Ids Core.Array_Number;
    v_Sm_Cache	   Core.Hash_t;
    v_Rel_Id	   Number;
    v_Attribute    Pf_R_Attributes%Rowtype;
    v_Ml_Code	   Number;
    v_Ml_Msg	   Varchar2(4000);
  Begin
    o_Code	   := 0;
    v_Code	   := Io_Hash.Get_Optional_Varchar2('code');
    v_Name	   := Io_Hash.Get_Varchar2('name');
    v_Category_Ids := Io_Hash.Get_Optional_Array_Number('category_ids');

    If v_Code Is Not Null And Pf_Util.Exists_Attribute_Code(v_Code) Then
      Pf_Util.Select_Attribute_By_Code(i_Code	   => v_Code,
				       o_Attribute => v_Attribute);
      v_Ml_Name_Code := v_Attribute.Ml_Name_Code;
      v_Rel_Id	     := v_Attribute.Id;

      If v_Attribute.Module_Code Is Not Null Then
	-- Modul tomonidan yaratilgan atribut: faqat kategoriya bog'lanishlari o'zgaradi, nomi emas.
	Null;
      Else
	Mll_Dev_Api.Save_Label_With_Template_Dev(i_Message_Code        => v_Ml_Name_Code,
						 i_Description		=> 'PF_ATTRIBUTE nomi',
						 i_Param_Count		=> 0,
						 i_Format_String	=> Mlt_Const.c_Default_Format_String,
						 i_Message_Mask_Lang1	=> v_Name,
						 i_Message_Mask_Lang2	=> v_Name,
						 i_Message_Mask_Lang3	=> v_Name,
						 i_Message_Mask_Lang4	=> v_Name,
						 i_Message_Mask_Lang5	=> Null,
						 i_Message_Mask_Lang6	=> Null,
						 i_Message_Mask_Lang7	=> Null,
						 i_Message_Mask_Lang8	=> Null,
						 i_Message_Mask_Lang9	=> Null,
						 i_Message_Mask_Lang10	=> Null,
						 i_Module_Code		=> Pf_Const.c_Module_Code,
						 i_Field_Hint		=> Null,
						 o_Code 		=> v_Ml_Code,
						 o_Msg			=> v_Ml_Msg);

	If v_Ml_Code Is Null Then
	  o_Code    := -1;
	  o_Msg     := v_Ml_Msg;
	  o_Ora_Msg := v_Ml_Msg;
	  Return;
	End If;
      End If;

      Pf_Dml.Log_Attribute_History(i_Id => v_Rel_Id, i_Action => 'U');
    Else
      v_Sm_Cache     := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Rel_Id	     := v_Sm_Cache.Get_Optional_Number('attribute_id');
      v_Code	     := 'ATTR_' || v_Rel_Id;
      v_Ml_Name_Code := 'PF_ATTRIBUTE_' || v_Code;

      Pf_Dml.Add_Attribute(i_Id 	  => v_Rel_Id,
			   i_Code	  => v_Code,
			   i_Ml_Name_Code => v_Ml_Name_Code,
			   i_Source_Type  => 'EDITABLE',
			   i_Sort_Order   => 100);

      Mll_Dev_Api.Save_Label_With_Template_Dev(i_Message_Code	     => v_Ml_Name_Code,
					       i_Description	      => 'PF_ATTRIBUTE nomi',
					       i_Param_Count	      => 0,
					       i_Format_String	      => Mlt_Const.c_Default_Format_String,
					       i_Message_Mask_Lang1   => v_Name,
					       i_Message_Mask_Lang2   => v_Name,
					       i_Message_Mask_Lang3   => v_Name,
					       i_Message_Mask_Lang4   => v_Name,
					       i_Message_Mask_Lang5   => Null,
					       i_Message_Mask_Lang6   => Null,
					       i_Message_Mask_Lang7   => Null,
					       i_Message_Mask_Lang8   => Null,
					       i_Message_Mask_Lang9   => Null,
					       i_Message_Mask_Lang10  => Null,
					       i_Module_Code	      => Pf_Const.c_Module_Code,
					       i_Field_Hint	      => Null,
					       o_Code		      => v_Ml_Code,
					       o_Msg		      => v_Ml_Msg);

      If v_Ml_Code Is Null Then
	o_Code	  := -1;
	o_Msg	  := v_Ml_Msg;
	o_Ora_Msg := v_Ml_Msg;
	Return;
      End If;
    End If;

    Pf_Dml.Sync_Attribute_Categories(i_Attribute_Id => v_Rel_Id,
				     i_Category_Ids => v_Category_Ids);
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Save_Attribute;

  Procedure Delete_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			     o_Code    Out Number,
			     o_Msg     Out Varchar2,
			     o_Ora_Msg Out Varchar2) Is
    v_Id	  Number;
    v_Attribute   Pf_R_Attributes%Rowtype;
    v_Param_Count Number;
    v_Rows	  Number;
  Begin
    o_Code := 0;
    v_Id   := Io_Hash.Get_Optional_Number('attribute_id');

    Pf_Util.Select_Attribute(i_Id => v_Id, o_Attribute => v_Attribute);

    If v_Attribute.Module_Code Is Not Null Then
      o_Code := -20047;
      o_Msg  := 'Modul tomonidan yaratilgan atributni o''chirib bo''lmaydi.';
      Return;
    End If;

    v_Param_Count := Pf_Util.Count_Attribute_Parameters(v_Id);
    If v_Param_Count > 0 Then
      o_Code := -20048;
      o_Msg  := 'Bu atributda ' || v_Param_Count ||
		' ta parametr bog''langan. Avval ularni o''chiring.';
      Return;
    End If;

    Pf_Dml.Delete_Attribute(i_Id => v_Id, o_Rows_Deleted => v_Rows);

    If v_Rows = 0 Then
      o_Code := -20046;
      o_Msg  := 'Atribut topilmadi.';
    End If;
  Exception
    When No_Data_Found Then
      o_Code := -20046;
      o_Msg  := 'Atribut topilmadi.';
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Delete_Attribute;

  Procedure Model_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			  o_Code    Out Number,
			  o_Msg     Out Varchar2,
			  o_Ora_Msg Out Varchar2) Is
    v_Product Pf_Products%Rowtype;
    v_Version Pf_Product_Versions%Rowtype;
    v_Data    Core.Hash_t := Core.Hash_t();
  Begin
    o_Code := 0;

    Pf_Util.Select_Product(i_Id      => Io_Hash.Get_Optional_Number('product_id'),
			   o_Product => v_Product);
    Pf_Util.Select_Latest_Product_Version(i_Product_Id => v_Product.Id,
					  i_Is_Raise   => False,
					  o_Version    => v_Version);

    v_Data.Put('product_id', v_Product.Id);
    v_Data.Put('code', v_Product.Code);
    v_Data.Put('name', v_Product.Name);
    v_Data.Put('category_id', v_Product.Category_Id);
    v_Data.Put('delivery_type_id', v_Product.Delivery_Type_Id);
    v_Data.Put('state', v_Version.State);
    If v_Version.Start_Date Is Not Null Then
      v_Data.Put('start_date', To_Char(v_Version.Start_Date, 'DD.MM.YYYY'));
    End If;
    If v_Version.End_Date Is Not Null Then
      v_Data.Put('end_date', To_Char(v_Version.End_Date, 'DD.MM.YYYY'));
    End If;
    v_Data.Put('continue_on_expiry', v_Version.Continue_On_Expiry);

    Io_Hash.Put('data', v_Data);
  Exception
    When No_Data_Found Then
      o_Code	:= -20052;
      o_Msg	:= 'Mahsulot topilmadi.';
      o_Ora_Msg := o_Msg;
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Model_Product;

  Procedure Save_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			 o_Code    Out Number,
			 o_Msg	   Out Varchar2,
			 o_Ora_Msg Out Varchar2) Is
    v_Category_Id	 Number;
    v_Name		 Varchar2(255);
    v_Delivery_Type_Id	 Number;
    v_Start_Date	 Date;
    v_End_Date		 Date;
    v_Continue_On_Expiry Number;
    v_Code		 Varchar2(50);
    v_Sm_Cache		 Core.Hash_t;
    v_Rel_Id		 Number;
    v_Version_Id	 Number;
    v_Product		 Pf_Products%Rowtype;
    v_Version		 Pf_Product_Versions%Rowtype;
  Begin
    o_Code		 := 0;
    v_Code		 := Io_Hash.Get_Optional_Varchar2('code');
    v_Category_Id	 := Io_Hash.Get_Number('category_id');
    v_Name		 := Io_Hash.Get_Varchar2('name');
    v_Delivery_Type_Id	 := Io_Hash.Get_Number('delivery_type_id');
    v_Start_Date	 := Io_Hash.Get_Optional_Date('start_date',
						      'DD.MM.YYYY');
    v_End_Date		 := Io_Hash.Get_Optional_Date('end_date',
						      'DD.MM.YYYY');
    v_Continue_On_Expiry := Case
			      When Io_Hash.Get_Optional_Varchar2('continue_on_expiry') = '1' Then
			       1
			      Else
			       0
			    End;

    If Not Pf_Util.Exists_Category(v_Category_Id) Then
      o_Code	:= -20050;
      o_Msg	:= 'Ko''rsatilgan kategoriya topilmadi.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If Not Pf_Util.Exists_Product_Delivery_Type(v_Delivery_Type_Id) Then
      o_Code	:= -20051;
      o_Msg	:= 'Ko''rsatilgan mahsulot turi topilmadi.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If v_Code Is Not Null And Pf_Util.Exists_Product_Code(v_Code) Then
      Pf_Util.Select_Product_By_Code(i_Code    => v_Code,
				     o_Product => v_Product);

      Pf_Dml.Update_Product(i_Id	       => v_Product.Id,
			    i_Category_Id      => v_Category_Id,
			    i_Name	       => v_Name,
			    i_Delivery_Type_Id => v_Delivery_Type_Id);

      Pf_Util.Select_Latest_Product_Version(i_Product_Id => v_Product.Id,
					    i_Is_Raise	 => False,
					    o_Version	 => v_Version);
      If v_Version.Id Is Not Null Then
	Pf_Dml.Update_Product_Version(i_Id		   => v_Version.Id,
				      i_Start_Date	   => v_Start_Date,
				      i_End_Date	   => v_End_Date,
				      i_Continue_On_Expiry => v_Continue_On_Expiry);
      End If;
    Else
      v_Sm_Cache := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Rel_Id	 := v_Sm_Cache.Get_Optional_Number('product_id');
      v_Code	 := 'PRD_' || v_Rel_Id;

      Pf_Dml.Add_Product(i_Id		    => v_Rel_Id,
			 i_Category_Id	    => v_Category_Id,
			 i_Code 	    => v_Code,
			 i_Name 	    => v_Name,
			 i_Delivery_Type_Id => v_Delivery_Type_Id);

      Select Pf_Product_Version_Sq.Nextval Into v_Version_Id From Dual;

      Pf_Dml.Add_Product_Version(i_Id		      => v_Version_Id,
				 i_Product_Id	      => v_Rel_Id,
				 i_Version_No	      => 1,
				 i_State	      => 'DRAFT',
				 i_Start_Date	      => v_Start_Date,
				 i_End_Date	      => v_End_Date,
				 i_Continue_On_Expiry => v_Continue_On_Expiry);
    End If;
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Save_Product;

  Procedure Delete_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2) Is
    v_Rows Number;
  Begin
    o_Code := 0;

    Pf_Dml.Delete_Product(i_Id		 => Io_Hash.Get_Optional_Number('product_id'),
			  o_Rows_Deleted => v_Rows);

    If v_Rows = 0 Then
      o_Code := -20053;
      o_Msg  := 'Mahsulot topilmadi.';
    End If;
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Delete_Product;

  -- Mahsulotning tanlangan atributi doirasidagi barcha parametrlar qiymatini
  -- (Io_Hash'dan 'param_<parameter_id>' kalitlari orqali) so'nggi versiyaga saqlaydi.
  -- Majburiy (Is_Required=1) parametr bo'sh qoldirilsa xato qaytaradi.
  Procedure Save_Product_Parameter_Values(Io_Hash   In Out Nocopy Core.Hash_t,
					   o_Code    Out Number,
					   o_Msg     Out Varchar2,
					   o_Ora_Msg Out Varchar2) Is
    v_Product_Id   Number;
    v_Attribute_Id Number;
    v_Category_Id  Number;
    v_Version	   Pf_Product_Versions%Rowtype;
    v_Value	   Varchar2(4000);
    v_Values	   Core.Hash_t := Core.Hash_t();
    v_Error_Msg    Varchar2(4000);
    Type t_Id_Tab Is Table Of Number;
    Type t_Val_Tab Is Table Of Varchar2(4000);
    v_Ids  t_Id_Tab := t_Id_Tab();
    v_Vals t_Val_Tab := t_Val_Tab();
  Begin
    o_Code	   := 0;
    v_Product_Id   := Io_Hash.Get_Number('product_id');
    v_Attribute_Id := Io_Hash.Get_Number('attribute_id');

    Pf_Util.Select_Latest_Product_Version(i_Product_Id => v_Product_Id,
					  i_Is_Raise   => True,
					  o_Version    => v_Version);

    Select Category_Id Into v_Category_Id From Pf_Products Where Id = v_Product_Id;

    -- Boshqa atributlarda avval saqlangan qiymatlar - qoidalarni to'liq
    -- kontekst bilan tekshirish uchun (parametrlararo shartlar).
    For pv In (Select Parameter_Id, Value
		 From Pf_Product_Parameter_Values
		Where Version_Id = v_Version.Id) Loop
      v_Values.Put(To_Char(pv.Parameter_Id), pv.Value);
    End Loop;

    -- Qo'lda kiritiladigan (MANUAL) parametrlar: majburiylikni tekshirish va
    -- kontekstga qo'shish (FUNCTION qiymatlarini hisoblashdan oldin kerak).
    For rec In (Select Id, Is_Required
		  From Pf_R_Parameters
		 Where Attribute_Id = v_Attribute_Id
		   And Input_Type != 'FUNCTION'
		 Order By Sort_Order) Loop
      v_Value := Io_Hash.Get_Optional_Varchar2('param_' || rec.Id);

      If rec.Is_Required = 1 And (v_Value Is Null Or v_Value = '') Then
	o_Code	  := -20054;
	o_Msg	  := 'Majburiy parametrlar to''ldirilishi shart.';
	o_Ora_Msg := o_Msg;
	Return;
      End If;

      v_Values.Put(To_Char(rec.Id), v_Value);
      v_Ids.Extend;
      v_Ids(v_Ids.Last) := rec.Id;
      v_Vals.Extend;
      v_Vals(v_Vals.Last) := v_Value;
    End Loop;

    -- FUNCTION turidagi parametrlar: qiymat qo'lda kiritilmaydi, qoidalar
    -- jadvalidan (Pf_Version_Rules) hisoblab olinadi.
    For rec In (Select Id
		  From Pf_R_Parameters
		 Where Attribute_Id = v_Attribute_Id
		   And Input_Type = 'FUNCTION'
		 Order By Sort_Order) Loop
      v_Value := Pf_Util.Get_Rule_Derived_Value(i_Category_Id	 => v_Category_Id,
						i_Product_Id	 => v_Product_Id,
						i_Parameter_Id => rec.Id,
						i_Values	 => v_Values);
      v_Values.Put(To_Char(rec.Id), v_Value);
      v_Ids.Extend;
      v_Ids(v_Ids.Last) := rec.Id;
      v_Vals.Extend;
      v_Vals(v_Vals.Last) := v_Value;
    End Loop;

    -- Parametrlararo biznes qoidalar (REQUIRED_IF/FORBIDDEN_IF/VALUE_CHECK_IF)
    -- to'liq kontekst (v_Values) bo'yicha tekshiriladi - saqlashdan oldin.
    If Not Pf_Util.Evaluate_Version_Rules(i_Category_Id => v_Category_Id,
					  i_Product_Id	=> v_Product_Id,
					  i_Values	=> v_Values,
					  o_Error_Msg	=> v_Error_Msg) Then
      o_Code	:= -20061;
      o_Msg	:= v_Error_Msg;
      o_Ora_Msg := v_Error_Msg;
      Return;
    End If;

    For i In 1 .. v_Ids.Count Loop
      Pf_Dml.Save_Product_Parameter_Value(i_Version_Id	 => v_Version.Id,
					   i_Parameter_Id => v_Ids(i),
					   i_Value	  => v_Vals(i));
    End Loop;
  Exception
    When No_Data_Found Then
      o_Code	:= -20052;
      o_Msg	:= 'Mahsulot topilmadi.';
      o_Ora_Msg := o_Msg;
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Save_Product_Parameter_Values;

  -- Formada hali saqlanmagan (joriy) qiymatlar asosida FUNCTION turidagi
  -- parametrlarni hisoblab qaytaradi - hech narsani bazaga yozmaydi.
  Procedure Preview_Product_Parameters(Io_Hash   In Out Nocopy Core.Hash_t,
				       o_Code    Out Number,
				       o_Msg     Out Varchar2,
				       o_Ora_Msg Out Varchar2) Is
    v_Product_Id   Number;
    v_Attribute_Id Number;
    v_Category_Id  Number;
    v_Version	   Pf_Product_Versions%Rowtype;
    v_Value	   Varchar2(4000);
    v_Values	   Core.Hash_t := Core.Hash_t();
    v_Data	   Core.Hash_t := Core.Hash_t();
  Begin
    o_Code	   := 0;
    v_Product_Id   := Io_Hash.Get_Number('product_id');
    v_Attribute_Id := Io_Hash.Get_Number('attribute_id');

    Select Category_Id Into v_Category_Id From Pf_Products Where Id = v_Product_Id;

    Pf_Util.Select_Latest_Product_Version(i_Product_Id => v_Product_Id,
					  i_Is_Raise   => False,
					  o_Version    => v_Version);

    If v_Version.Id Is Not Null Then
      For pv In (Select Parameter_Id, Value
		   From Pf_Product_Parameter_Values
		  Where Version_Id = v_Version.Id) Loop
	v_Values.Put(To_Char(pv.Parameter_Id), pv.Value);
      End Loop;
    End If;

    -- joriy (hali saqlanmagan) MANUAL qiymatlarni formadan ustiga qo'yish
    For rec In (Select Id
		  From Pf_R_Parameters
		 Where Attribute_Id = v_Attribute_Id
		   And Input_Type != 'FUNCTION') Loop
      v_Value := Io_Hash.Get_Optional_Varchar2('param_' || rec.Id);
      If v_Value Is Not Null Then
	v_Values.Put(To_Char(rec.Id), v_Value);
      End If;
    End Loop;

    -- shu tab ichidagi FUNCTION parametrlarni hisoblash (saqlamasdan)
    For rec In (Select Id
		  From Pf_R_Parameters
		 Where Attribute_Id = v_Attribute_Id
		   And Input_Type = 'FUNCTION') Loop
      v_Value := Pf_Util.Get_Rule_Derived_Value(i_Category_Id	 => v_Category_Id,
						i_Product_Id	 => v_Product_Id,
						i_Parameter_Id => rec.Id,
						i_Values	 => v_Values);
      v_Data.Put('param_' || rec.Id, v_Value);
    End Loop;

    Io_Hash.Put('data', v_Data);
  Exception
    When No_Data_Found Then
      o_Code	:= -20052;
      o_Msg	:= 'Mahsulot topilmadi.';
      o_Ora_Msg := o_Msg;
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Preview_Product_Parameters;

  Procedure Model_Version_Rule(Io_Hash	 In Out Nocopy Core.Hash_t,
			       o_Code	 Out Number,
			       o_Msg	 Out Varchar2,
			       o_Ora_Msg Out Varchar2) Is
    v_Rule Pf_Version_Rules%Rowtype;
    v_Data Core.Hash_t := Core.Hash_t();
  Begin
    o_Code := 0;

    Pf_Util.Select_Version_Rule(i_Id => Io_Hash.Get_Optional_Number('version_rule_id'),
				 o_Rule => v_Rule);

    v_Data.Put('version_rule_id', v_Rule.Id);
    v_Data.Put('parameter_id', v_Rule.Parameter_Id);
    If v_Rule.Category_Id Is Not Null Then
      v_Data.Put('category_id', v_Rule.Category_Id);
    End If;
    If v_Rule.Product_Id Is Not Null Then
      v_Data.Put('product_id', v_Rule.Product_Id);
    End If;
    v_Data.Put('rule_type', v_Rule.Rule_Type);
    v_Data.Put('condition', v_Rule.Condition);
    v_Data.Put('target', v_Rule.Target);
    v_Data.Put('sort_order', v_Rule.Sort_Order);
    v_Data.Put('error_message',
	       Mll_Core_Api.Get_Label(i_Module_Code  => Pf_Const.c_Module_Code,
				      i_Message_Code => v_Rule.Ml_Error_Code));

    Io_Hash.Put('data', v_Data);
  Exception
    When No_Data_Found Then
      o_Code	:= -20060;
      o_Msg	:= 'Qoida topilmadi.';
      o_Ora_Msg := o_Msg;
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Model_Version_Rule;

  Procedure Save_Version_Rule(Io_Hash	In Out Nocopy Core.Hash_t,
			      o_Code	Out Number,
			      o_Msg	Out Varchar2,
			      o_Ora_Msg Out Varchar2) Is
    v_Category_Id	Number;
    v_Product_Id	Number;
    v_Parameter_Id	Number;
    v_Rule_Type		Pf_Version_Rules.Rule_Type%Type;
    v_Condition		Clob;
    v_Target		Clob;
    v_Error_Message	Varchar2(500);
    v_Sort_Order	Number;
    v_Sm_Cache		Core.Hash_t;
    v_Rel_Id		Number;
    v_Ml_Name_Code	Varchar2(100);
    v_Ml_Code		Number;
    v_Ml_Msg		Varchar2(4000);
    v_Is_Create		Boolean;
  Begin
    o_Code	   := 0;
    v_Category_Id  := Io_Hash.Get_Optional_Number('category_id');
    v_Product_Id   := Io_Hash.Get_Optional_Number('product_id');
    v_Parameter_Id := Io_Hash.Get_Number('parameter_id');
    v_Rule_Type    := Io_Hash.Get_Varchar2('rule_type');
    v_Condition    := Io_Hash.Get_Varchar2('condition');
    v_Target	   := Io_Hash.Get_Varchar2('target');
    v_Error_Message := Io_Hash.Get_Varchar2('error_message');
    v_Sort_Order   := Nvl(Io_Hash.Get_Optional_Number('sort_order'), 0);
    v_Is_Create    := Io_Hash.Get_Optional_Varchar2('process_code') =
		       'CREATE_PF_VERSION_RULE';

    If v_Category_Id Is Null And v_Product_Id Is Null Then
      o_Code	:= -20061;
      o_Msg	:= 'Kategoriya yoki mahsulotni tanlang.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If Not v_Condition Is Json Then
      o_Code	:= -20062;
      o_Msg	:= 'Shartlar (condition) noto''g''ri formatda.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If Not v_Target Is Json Then
      o_Code	:= -20063;
      o_Msg	:= 'Natija (target) noto''g''ri formatda.';
      o_Ora_Msg := o_Msg;
      Return;
    End If;

    If v_Is_Create Then
      v_Sm_Cache     := Io_Hash.Get_Optional_Hash_t('sm_cache');
      v_Rel_Id	     := v_Sm_Cache.Get_Optional_Number('version_rule_id');
      v_Ml_Name_Code := 'PF_VERSION_RULE_' || v_Rel_Id;

      Pf_Dml.Add_Version_Rule(i_Id		=> v_Rel_Id,
			      i_Category_Id	=> v_Category_Id,
			      i_Product_Id	=> v_Product_Id,
			      i_Parameter_Id	=> v_Parameter_Id,
			      i_Rule_Type	=> v_Rule_Type,
			      i_Condition	=> v_Condition,
			      i_Target		=> v_Target,
			      i_Ml_Error_Code	=> v_Ml_Name_Code,
			      i_Sort_Order	=> v_Sort_Order);
    Else
      v_Rel_Id	     := Io_Hash.Get_Optional_Number('version_rule_id');
      v_Ml_Name_Code := 'PF_VERSION_RULE_' || v_Rel_Id;

      Pf_Dml.Update_Version_Rule(i_Id	       => v_Rel_Id,
				 i_Category_Id	=> v_Category_Id,
				 i_Product_Id	=> v_Product_Id,
				 i_Parameter_Id => v_Parameter_Id,
				 i_Rule_Type	=> v_Rule_Type,
				 i_Condition	=> v_Condition,
				 i_Target	=> v_Target,
				 i_Ml_Error_Code => v_Ml_Name_Code,
				 i_Sort_Order	=> v_Sort_Order);
    End If;

    Mll_Dev_Api.Save_Label_With_Template_Dev(i_Message_Code	   => v_Ml_Name_Code,
					     i_Description	    => 'PF_VERSION_RULE xato xabari',
					     i_Param_Count	    => 0,
					     i_Format_String	    => Mlt_Const.c_Default_Format_String,
					     i_Message_Mask_Lang1   => v_Error_Message,
					     i_Message_Mask_Lang2   => v_Error_Message,
					     i_Message_Mask_Lang3   => v_Error_Message,
					     i_Message_Mask_Lang4   => v_Error_Message,
					     i_Message_Mask_Lang5   => Null,
					     i_Message_Mask_Lang6   => Null,
					     i_Message_Mask_Lang7   => Null,
					     i_Message_Mask_Lang8   => Null,
					     i_Message_Mask_Lang9   => Null,
					     i_Message_Mask_Lang10  => Null,
					     i_Module_Code	    => Pf_Const.c_Module_Code,
					     i_Field_Hint	    => Null,
					     o_Code		    => v_Ml_Code,
					     o_Msg		    => v_Ml_Msg);

    If v_Ml_Code Is Null Then
      o_Code	:= -1;
      o_Msg	:= v_Ml_Msg;
      o_Ora_Msg := v_Ml_Msg;
    End If;
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Save_Version_Rule;

  Procedure Delete_Version_Rule(Io_Hash   In Out Nocopy Core.Hash_t,
				o_Code	  Out Number,
				o_Msg	  Out Varchar2,
				o_Ora_Msg Out Varchar2) Is
    v_Rows Number;
  Begin
    o_Code := 0;

    Pf_Dml.Delete_Version_Rule(i_Id	     => Io_Hash.Get_Optional_Number('version_rule_id'),
			       o_Rows_Deleted => v_Rows);

    If v_Rows = 0 Then
      o_Code := -20064;
      o_Msg  := 'Qoida topilmadi.';
    End If;
  Exception
    When Others Then
      o_Code	:= -1;
      o_Msg	:= Sqlerrm;
      o_Ora_Msg := Sqlerrm || ' ' || Dbms_Utility.Format_Error_Backtrace;
  End Delete_Version_Rule;

end Pf_Kernel;



/
