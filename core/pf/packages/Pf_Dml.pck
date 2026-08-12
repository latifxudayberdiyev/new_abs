create or replace PACKAGE        "PF_DML" is

  Procedure Add_Category(i_Id		Number,
			 i_Code 	Varchar2,
			 i_Ml_Name_Code Varchar2,
			 i_State	Varchar2);

  Procedure Update_Category_State(i_Code  Varchar2,
				  i_State Varchar2);

  Procedure Delete_Category(i_Id	   Number,
			    o_Rows_Deleted Out Number);

  Procedure Add_Parameter(i_Id		   Number,
			  i_Attribute_Id   Number,
			  i_Code	   Varchar2,
			  i_Ml_Name_Code   Varchar2,
			  i_Value_Type	   Varchar2,
			  i_Input_Type	   Varchar2,
			  i_Change_Policy  Varchar2,
			  i_Value_Function Varchar2,
			  i_Reference_Id   Number,
			  i_Is_Required    Number,
			  i_Default_Value  Varchar2,
			  i_Sort_Order	   Number);

  Procedure Update_Parameter(i_Id	      Number,
			     i_Attribute_Id   Number,
			     i_Value_Type     Varchar2,
			     i_Input_Type     Varchar2,
			     i_Change_Policy  Varchar2,
			     i_Value_Function Varchar2,
			     i_Reference_Id   Number,
			     i_Is_Required    Number,
			     i_Default_Value  Varchar2,
			     i_Sort_Order     Number);

  Procedure Delete_Parameter(i_Id	    Number,
			     o_Rows_Deleted Out Number);

  Procedure Add_Attribute(i_Id		 Number,
			  i_Code	 Varchar2,
			  i_Ml_Name_Code Varchar2,
			  i_Source_Type  Varchar2,
			  i_Sort_Order	 Number);

  Procedure Delete_Attribute(i_Id	    Number,
			     o_Rows_Deleted Out Number);

  Procedure Sync_Attribute_Categories(i_Attribute_Id Number,
				      i_Category_Ids Core.Array_Number);

  Procedure Log_Attribute_History(i_Id	   Number,
				  i_Action Varchar2);

  -- Audit ustunlar (Created_By/Modified_By) Core.User_Env.Get_User_Id'dan olinadi -
  -- chaqiruvchidan i_User_Id parametri sifatida qabul qilinmaydi (PF konvensiyasi).
  Procedure Add_Product(i_Id		   Number,
			i_Category_Id	   Number,
			i_Code		   Varchar2,
			i_Name		   Varchar2,
			i_Delivery_Type_Id Number);

  Procedure Update_Product(i_Id 	      Number,
			   i_Category_Id      Number,
			   i_Name	      Varchar2,
			   i_Delivery_Type_Id Number);

  Procedure Delete_Product(i_Id 	  Number,
			   o_Rows_Deleted Out Number);

  Procedure Log_Product_History(i_Id	 Number,
				i_Action Varchar2);

  Procedure Add_Product_Version(i_Id		     Number,
				i_Product_Id	     Number,
				i_Version_No	     Number,
				i_State 	     Varchar2,
				i_Start_Date	     Date,
				i_End_Date	     Date,
				i_Continue_On_Expiry Number);

  Procedure Update_Product_Version(i_Id 		Number,
				   i_Start_Date 	Date,
				   i_End_Date		Date,
				   i_Continue_On_Expiry Number);

  Procedure Log_Product_Version_History(i_Id	 Number,
					i_Action Varchar2);

  -- Mahsulot versiyasining har bir parametr bo'yicha qiymatini saqlaydi (upsert:
  -- (Version_Id, Parameter_Id) UK1 bo'yicha mavjud bo'lsa update, bo'lmasa insert).
  Procedure Save_Product_Parameter_Value(i_Version_Id	Number,
					  i_Parameter_Id Number,
					  i_Value	 Varchar2);

  Procedure Add_Version_Rule(i_Id	     Number,
			      i_Category_Id  Number,
			      i_Product_Id   Number,
			      i_Parameter_Id Number,
			      i_Rule_Type    Varchar2,
			      i_Condition    Clob,
			      i_Target	     Clob,
			      i_Ml_Error_Code Varchar2,
			      i_Sort_Order   Number);

  Procedure Update_Version_Rule(i_Id		 Number,
				 i_Category_Id	 Number,
				 i_Product_Id	 Number,
				 i_Parameter_Id Number,
				 i_Rule_Type	 Varchar2,
				 i_Condition	 Clob,
				 i_Target	 Clob,
				 i_Ml_Error_Code Varchar2,
				 i_Sort_Order	 Number);

  Procedure Delete_Version_Rule(i_Id		 Number,
				 o_Rows_Deleted Out Number);

end Pf_Dml;



/
create or replace PACKAGE BODY	    "PF_DML" is

  Procedure Add_Category(i_Id		Number,
			 i_Code 	Varchar2,
			 i_Ml_Name_Code Varchar2,
			 i_State	Varchar2) is
  Begin
    Insert Into Pf_R_Categories
      (Id, Code, Ml_Name_Code, State)
    Values
      (i_Id, i_Code, i_Ml_Name_Code, i_State);

    Insert Into Pf_R_Categories_H
      (Log_Id, Id, Code, Ml_Name_Code, State, Action, Action_Date)
    Values
      (Pf_Category_H_Sq.Nextval, i_Id, i_Code, i_Ml_Name_Code, i_State, 'I',
       Sysdate);
  End Add_Category;

  Procedure Update_Category_State(i_Code  Varchar2,
				  i_State Varchar2) is
  Begin
    Update Pf_R_Categories Set State = i_State Where Code = i_Code;

    Insert Into Pf_R_Categories_H
      (Log_Id, Id, Code, Ml_Name_Code, State, Action, Action_Date)
      Select Pf_Category_H_Sq.Nextval,
	     Id,
	     Code,
	     Ml_Name_Code,
	     State,
	     'U',
	     Sysdate
	From Pf_R_Categories
       Where Code = i_Code;
  End Update_Category_State;

  Procedure Delete_Category(i_Id	   Number,
			    o_Rows_Deleted Out Number) is
  Begin
    Insert Into Pf_R_Categories_H
      (Log_Id, Id, Code, Ml_Name_Code, State, Action, Action_Date)
      Select Pf_Category_H_Sq.Nextval,
	     Id,
	     Code,
	     Ml_Name_Code,
	     State,
	     'D',
	     Sysdate
	From Pf_R_Categories
       Where Id = i_Id;

    Delete From Pf_R_Categories Where Id = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  End Delete_Category;

  Procedure Add_Parameter(i_Id		   Number,
			  i_Attribute_Id   Number,
			  i_Code	   Varchar2,
			  i_Ml_Name_Code   Varchar2,
			  i_Value_Type	   Varchar2,
			  i_Input_Type	   Varchar2,
			  i_Change_Policy  Varchar2,
			  i_Value_Function Varchar2,
			  i_Reference_Id   Number,
			  i_Is_Required    Number,
			  i_Default_Value  Varchar2,
			  i_Sort_Order	   Number) is
  Begin
    Insert Into Pf_R_Parameters
      (Id, Attribute_Id, Code, Ml_Name_Code, Value_Type, Input_Type,
       Change_Policy, Value_Function, Reference_Id, Is_Required, Default_Value, Sort_Order)
    Values
      (i_Id, i_Attribute_Id, i_Code, i_Ml_Name_Code, i_Value_Type,
       i_Input_Type, i_Change_Policy, i_Value_Function, i_Reference_Id, i_Is_Required,
       i_Default_Value, i_Sort_Order);

    Insert Into Pf_R_Parameters_H
      (Log_Id, Id, Attribute_Id, Code, Ml_Name_Code, Value_Type, Input_Type,
       Change_Policy, Value_Function, Reference_Id, Is_Required, Default_Value, Sort_Order,
       Action, Action_Date)
    Values
      (Pf_Parameter_H_Sq.Nextval, i_Id, i_Attribute_Id, i_Code,
       i_Ml_Name_Code, i_Value_Type, i_Input_Type, i_Change_Policy,
       i_Value_Function, i_Reference_Id, i_Is_Required, i_Default_Value, i_Sort_Order, 'I',
       Sysdate);
  End Add_Parameter;

  Procedure Update_Parameter(i_Id	      Number,
			     i_Attribute_Id   Number,
			     i_Value_Type     Varchar2,
			     i_Input_Type     Varchar2,
			     i_Change_Policy  Varchar2,
			     i_Value_Function Varchar2,
			     i_Reference_Id   Number,
			     i_Is_Required    Number,
			     i_Default_Value  Varchar2,
			     i_Sort_Order     Number) is
  Begin
    Update Pf_R_Parameters
       Set Attribute_Id   = i_Attribute_Id,
	   Value_Type	  = i_Value_Type,
	   Input_Type	  = i_Input_Type,
	   Change_Policy  = i_Change_Policy,
	   Value_Function = i_Value_Function,
	   Reference_Id   = i_Reference_Id,
	   Is_Required	  = i_Is_Required,
	   Default_Value  = i_Default_Value,
	   Sort_Order	  = i_Sort_Order
     Where Id = i_Id;

    Insert Into Pf_R_Parameters_H
      (Log_Id, Id, Attribute_Id, Code, Ml_Name_Code, Value_Type, Input_Type,
       Change_Policy, Value_Function, Reference_Id, Is_Required, Default_Value, Sort_Order,
       Action, Action_Date)
      Select Pf_Parameter_H_Sq.Nextval,
	     Id,
	     Attribute_Id,
	     Code,
	     Ml_Name_Code,
	     Value_Type,
	     Input_Type,
	     Change_Policy,
	     Value_Function,
	     Reference_Id,
	     Is_Required,
	     Default_Value,
	     Sort_Order,
	     'U',
	     Sysdate
	From Pf_R_Parameters
       Where Id = i_Id;
  End Update_Parameter;

  Procedure Delete_Parameter(i_Id	    Number,
			     o_Rows_Deleted Out Number) is
  Begin
    Insert Into Pf_R_Parameters_H
      (Log_Id, Id, Attribute_Id, Code, Ml_Name_Code, Value_Type, Input_Type,
       Change_Policy, Value_Function, Reference_Id, Is_Required, Default_Value, Sort_Order,
       Action, Action_Date)
      Select Pf_Parameter_H_Sq.Nextval,
	     Id,
	     Attribute_Id,
	     Code,
	     Ml_Name_Code,
	     Value_Type,
	     Input_Type,
	     Change_Policy,
	     Value_Function,
	     Reference_Id,
	     Is_Required,
	     Default_Value,
	     Sort_Order,
	     'D',
	     Sysdate
	From Pf_R_Parameters
       Where Id = i_Id;

    Delete From Pf_R_Parameters Where Id = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  End Delete_Parameter;

  Procedure Add_Attribute(i_Id		 Number,
			  i_Code	 Varchar2,
			  i_Ml_Name_Code Varchar2,
			  i_Source_Type  Varchar2,
			  i_Sort_Order	 Number) is
  Begin
    Insert Into Pf_R_Attributes
      (Id, Code, Ml_Name_Code, Source_Type, Module_Code, Sort_Order)
    Values
      (i_Id, i_Code, i_Ml_Name_Code, i_Source_Type, Null, i_Sort_Order);

    Log_Attribute_History(i_Id => i_Id, i_Action => 'I');
  End Add_Attribute;

  Procedure Delete_Attribute(i_Id	    Number,
			     o_Rows_Deleted Out Number) is
  Begin
    Log_Attribute_History(i_Id => i_Id, i_Action => 'D');

    Delete From Pf_R_Attribute_Categories Where Attribute_Id = i_Id;
    Delete From Pf_R_Attributes Where Id = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  End Delete_Attribute;

  Procedure Sync_Attribute_Categories(i_Attribute_Id Number,
				      i_Category_Ids Core.Array_Number) is
  Begin
    Delete From Pf_R_Attribute_Categories
     Where Attribute_Id = i_Attribute_Id;
    If i_Category_Ids Is Not Null Then
      For i In 1 .. i_Category_Ids.Count
      Loop
	Insert Into Pf_R_Attribute_Categories
	  (Attribute_Id, Category_Id)
	Values
	  (i_Attribute_Id, i_Category_Ids(i));
      End Loop;
    End If;
  End Sync_Attribute_Categories;

  Procedure Log_Attribute_History(i_Id	   Number,
				  i_Action Varchar2) is
  Begin
    Insert Into Pf_R_Attributes_H
      (Log_Id, Id, Code, Ml_Name_Code, Source_Type, Module_Code, Sort_Order,
       Action, Action_Date)
      Select Pf_Attribute_H_Sq.Nextval,
	     Id,
	     Code,
	     Ml_Name_Code,
	     Source_Type,
	     Module_Code,
	     Sort_Order,
	     i_Action,
	     Sysdate
	From Pf_R_Attributes
       Where Id = i_Id;
  End Log_Attribute_History;

  Procedure Add_Product(i_Id		   Number,
			i_Category_Id	   Number,
			i_Code		   Varchar2,
			i_Name		   Varchar2,
			i_Delivery_Type_Id Number) is
  Begin
    Insert Into Pf_Products
      (Id, Category_Id, Code, Name, Delivery_Type_Id, Created_By,
       Created_On, Modified_By, Modified_On)
    Values
      (i_Id, i_Category_Id, i_Code, i_Name, i_Delivery_Type_Id, Core.User_Env.Get_User_Id,
       Sysdate, Core.User_Env.Get_User_Id, Sysdate);

    Log_Product_History(i_Id => i_Id, i_Action => 'I');
  End Add_Product;

  Procedure Update_Product(i_Id 	      Number,
			   i_Category_Id      Number,
			   i_Name	      Varchar2,
			   i_Delivery_Type_Id Number) is
  Begin
    Update Pf_Products
       Set Category_Id	    = i_Category_Id,
	   Name 	     = i_Name,
	   Delivery_Type_Id  = i_Delivery_Type_Id,
	   Modified_By	     = Core.User_Env.Get_User_Id,
	   Modified_On	     = Sysdate
     Where Id = i_Id;

    Log_Product_History(i_Id => i_Id, i_Action => 'U');
  End Update_Product;

  Procedure Delete_Product(i_Id 	  Number,
			   o_Rows_Deleted Out Number) is
  Begin
    Log_Product_History(i_Id => i_Id, i_Action => 'D');

    For r In (Select Id From Pf_Product_Versions Where Product_Id = i_Id)
    Loop
      Log_Product_Version_History(i_Id => r.Id, i_Action => 'D');
    End Loop;

    Delete From Pf_Product_Versions Where Product_Id = i_Id;
    Delete From Pf_Products Where Id = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  End Delete_Product;

  Procedure Log_Product_History(i_Id	 Number,
				i_Action Varchar2) is
  Begin
    Insert Into Pf_Products_H
      (Log_Id, Id, Category_Id, Code, Name, Delivery_Type_Id, Created_By,
       Created_On, Modified_By, Modified_On, Action, Action_Date)
      Select Pf_Product_H_Sq.Nextval,
	     Id,
	     Category_Id,
	     Code,
	     Name,
	     Delivery_Type_Id,
	     Created_By,
	     Created_On,
	     Modified_By,
	     Modified_On,
	     i_Action,
	     Sysdate
	From Pf_Products
       Where Id = i_Id;
  End Log_Product_History;

  Procedure Add_Product_Version(i_Id		     Number,
				i_Product_Id	     Number,
				i_Version_No	     Number,
				i_State 	     Varchar2,
				i_Start_Date	     Date,
				i_End_Date	     Date,
				i_Continue_On_Expiry Number) is
  Begin
    Insert Into Pf_Product_Versions
      (Id, Product_Id, Version_No, State, Start_Date, End_Date,
       Continue_On_Expiry, Created_By, Created_On, Modified_By, Modified_On)
    Values
      (i_Id, i_Product_Id, i_Version_No, i_State, i_Start_Date, i_End_Date,
       i_Continue_On_Expiry, Core.User_Env.Get_User_Id, Sysdate, Core.User_Env.Get_User_Id, Sysdate);

    Log_Product_Version_History(i_Id => i_Id, i_Action => 'I');
  End Add_Product_Version;

  Procedure Update_Product_Version(i_Id 		Number,
				   i_Start_Date 	Date,
				   i_End_Date		Date,
				   i_Continue_On_Expiry Number) is
  Begin
    Update Pf_Product_Versions
       Set Start_Date	      = i_Start_Date,
	   End_Date	      = i_End_Date,
	   Continue_On_Expiry = i_Continue_On_Expiry,
	   Modified_By	      = Core.User_Env.Get_User_Id,
	   Modified_On	      = Sysdate
     Where Id = i_Id;

    Log_Product_Version_History(i_Id => i_Id, i_Action => 'U');
  End Update_Product_Version;

  Procedure Log_Product_Version_History(i_Id	 Number,
					i_Action Varchar2) is
  Begin
    Insert Into Pf_Product_Versions_H
      (Log_Id, Id, Product_Id, Version_No, State, Valid_From, Valid_To,
       Start_Date, End_Date, Continue_On_Expiry, Created_By, Created_On,
       Modified_By, Modified_On, Action, Action_Date)
      Select Pf_Product_Version_H_Sq.Nextval,
	     Id,
	     Product_Id,
	     Version_No,
	     State,
	     Valid_From,
	     Valid_To,
	     Start_Date,
	     End_Date,
	     Continue_On_Expiry,
	     Created_By,
	     Created_On,
	     Modified_By,
	     Modified_On,
	     i_Action,
	     Sysdate
	From Pf_Product_Versions
       Where Id = i_Id;
  End Log_Product_Version_History;

  Procedure Save_Product_Parameter_Value(i_Version_Id	Number,
					  i_Parameter_Id Number,
					  i_Value	 Varchar2) is
    v_Id Pf_Product_Parameter_Values.Id%Type;
  Begin
    Begin
      Select Id
	Into v_Id
	From Pf_Product_Parameter_Values
       Where Version_Id   = i_Version_Id
	 And Parameter_Id = i_Parameter_Id;

      Update Pf_Product_Parameter_Values
	 Set Value	 = i_Value,
	     Modified_By = Core.User_Env.Get_User_Id,
	     Modified_On = Sysdate
       Where Id = v_Id;
    Exception
      When No_Data_Found Then
	Insert Into Pf_Product_Parameter_Values
	  (Id, Version_Id, Parameter_Id, Value, Created_By, Created_On,
	   Modified_By, Modified_On)
	Values
	  (Pf_Product_Parameter_Value_Sq.Nextval, i_Version_Id, i_Parameter_Id, i_Value,
	   Core.User_Env.Get_User_Id, Sysdate, Core.User_Env.Get_User_Id, Sysdate);
    End;
  End Save_Product_Parameter_Value;

  Procedure Log_Version_Rule_History(i_Id Number, i_Action Varchar2) Is
  Begin
    Insert Into Pf_Version_Rules_H
      (Log_Id, Id, Category_Id, Product_Id, Parameter_Id, Rule_Type, Condition, Target,
       Ml_Error_Code, Sort_Order, Created_By, Created_On, Modified_By,
       Modified_On, Action, Action_Date)
    Select Pf_Version_Rule_H_Sq.Nextval,
	   Id, Category_Id, Product_Id, Parameter_Id, Rule_Type, Condition, Target,
	   Ml_Error_Code, Sort_Order, Created_By, Created_On, Modified_By,
	   Modified_On, i_Action, Sysdate
      From Pf_Version_Rules
     Where Id = i_Id;
  End Log_Version_Rule_History;

  Procedure Add_Version_Rule(i_Id		Number,
			      i_Category_Id	Number,
			      i_Product_Id	Number,
			      i_Parameter_Id	Number,
			      i_Rule_Type	Varchar2,
			      i_Condition	Clob,
			      i_Target		Clob,
			      i_Ml_Error_Code	Varchar2,
			      i_Sort_Order	Number) Is
  Begin
    Insert Into Pf_Version_Rules
      (Id, Category_Id, Product_Id, Parameter_Id, Rule_Type, Condition, Target,
       Ml_Error_Code, Sort_Order, Created_By, Created_On, Modified_By,
       Modified_On)
    Values
      (i_Id, i_Category_Id, i_Product_Id, i_Parameter_Id, i_Rule_Type, i_Condition, i_Target,
       i_Ml_Error_Code, i_Sort_Order, Core.User_Env.Get_User_Id, Sysdate,
       Core.User_Env.Get_User_Id, Sysdate);

    Log_Version_Rule_History(i_Id => i_Id, i_Action => 'I');
  End Add_Version_Rule;

  Procedure Update_Version_Rule(i_Id		  Number,
				 i_Category_Id	  Number,
				 i_Product_Id	  Number,
				 i_Parameter_Id	  Number,
				 i_Rule_Type	  Varchar2,
				 i_Condition	  Clob,
				 i_Target	  Clob,
				 i_Ml_Error_Code  Varchar2,
				 i_Sort_Order	  Number) Is
  Begin
    Update Pf_Version_Rules
       Set Category_Id	 = i_Category_Id,
	   Product_Id	 = i_Product_Id,
	   Parameter_Id	 = i_Parameter_Id,
	   Rule_Type	 = i_Rule_Type,
	   Condition	 = i_Condition,
	   Target	 = i_Target,
	   Ml_Error_Code = i_Ml_Error_Code,
	   Sort_Order	 = i_Sort_Order,
	   Modified_By	 = Core.User_Env.Get_User_Id,
	   Modified_On	 = Sysdate
     Where Id = i_Id;

    Log_Version_Rule_History(i_Id => i_Id, i_Action => 'U');
  End Update_Version_Rule;

  Procedure Delete_Version_Rule(i_Id Number, o_Rows_Deleted Out Number) Is
  Begin
    Log_Version_Rule_History(i_Id => i_Id, i_Action => 'D');

    Delete From Pf_Version_Rules Where Id = i_Id;
    o_Rows_Deleted := Sql%Rowcount;
  End Delete_Version_Rule;

end Pf_Dml;



/
