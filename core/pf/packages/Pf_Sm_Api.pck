create or replace PACKAGE        "PF_SM_API" Is

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

End Pf_Sm_Api;

/
create or replace PACKAGE BODY	    "PF_SM_API" Is

  Procedure Model_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Model_Category(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Model_Category;

  Procedure Save_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			  o_Code    Out Number,
			  o_Msg     Out Varchar2,
			  o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Save_Category(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Save_Category;

  Procedure Delete_Category(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Delete_Category(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Delete_Category;

  Procedure Model_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Model_Parameter(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Model_Parameter;

  Procedure Save_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Save_Parameter(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Save_Parameter;

  Procedure Delete_Parameter(Io_Hash   In Out Nocopy Core.Hash_t,
			     o_Code    Out Number,
			     o_Msg     Out Varchar2,
			     o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Delete_Parameter(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Delete_Parameter;

  Procedure Model_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			    o_Code    Out Number,
			    o_Msg     Out Varchar2,
			    o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Model_Attribute(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Model_Attribute;

  Procedure Save_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Save_Attribute(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Save_Attribute;

  Procedure Delete_Attribute(Io_Hash   In Out Nocopy Core.Hash_t,
			     o_Code    Out Number,
			     o_Msg     Out Varchar2,
			     o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Delete_Attribute(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Delete_Attribute;

  Procedure Model_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			  o_Code    Out Number,
			  o_Msg     Out Varchar2,
			  o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Model_Product(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Model_Product;

  Procedure Save_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			 o_Code    Out Number,
			 o_Msg	   Out Varchar2,
			 o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Save_Product(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Save_Product;

  Procedure Delete_Product(Io_Hash   In Out Nocopy Core.Hash_t,
			   o_Code    Out Number,
			   o_Msg     Out Varchar2,
			   o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Delete_Product(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Delete_Product;

  Procedure Save_Product_Parameter_Values(Io_Hash   In Out Nocopy Core.Hash_t,
					   o_Code    Out Number,
					   o_Msg     Out Varchar2,
					   o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Save_Product_Parameter_Values(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Save_Product_Parameter_Values;

  Procedure Preview_Product_Parameters(Io_Hash   In Out Nocopy Core.Hash_t,
				       o_Code    Out Number,
				       o_Msg     Out Varchar2,
				       o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Preview_Product_Parameters(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Preview_Product_Parameters;

  Procedure Model_Version_Rule(Io_Hash   In Out Nocopy Core.Hash_t,
			       o_Code    Out Number,
			       o_Msg     Out Varchar2,
			       o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Model_Version_Rule(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Model_Version_Rule;

  Procedure Save_Version_Rule(Io_Hash   In Out Nocopy Core.Hash_t,
			      o_Code    Out Number,
			      o_Msg     Out Varchar2,
			      o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Save_Version_Rule(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Save_Version_Rule;

  Procedure Delete_Version_Rule(Io_Hash   In Out Nocopy Core.Hash_t,
				o_Code    Out Number,
				o_Msg     Out Varchar2,
				o_Ora_Msg Out Varchar2) Is
  Begin
    Pf_Kernel.Delete_Version_Rule(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  End Delete_Version_Rule;

End Pf_Sm_Api;

/
