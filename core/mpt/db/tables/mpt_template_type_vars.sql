
  CREATE TABLE "MPT_TEMPLATE_TYPE_VARS"
   (	"MAPPING_ID" NUMBER(19,0) NOT NULL ENABLE,
	"TEMPLATE_CODE" VARCHAR2(50) NOT NULL ENABLE,
	"VARIABLE_CODE" VARCHAR2(100) NOT NULL ENABLE,
	"PLACEHOLDER" VARCHAR2(100) NOT NULL ENABLE,
	"IS_ACTIVE" VARCHAR2(1) DEFAULT 'Y' NOT NULL ENABLE,
	"CREATED_BY" NUMBER(30,0) NOT NULL ENABLE,
	"CREATED_DATE" DATE DEFAULT SYSDATE NOT NULL ENABLE,
	"MODIFIED_BY" NUMBER(30,0),
	"MODIFIED_ON" DATE,
	"SM_RELATION_ID" NUMBER(10,0),
	 CONSTRAINT "MPT_TEMPLATE_TYPE_VARS_C1" PRIMARY KEY ("MAPPING_ID")
  USING INDEX  ENABLE,
	 CONSTRAINT "MPT_TEMPLATE_TYPE_VARS_C2" UNIQUE ("TEMPLATE_CODE", "VARIABLE_CODE")
  USING INDEX  ENABLE,
	 CONSTRAINT "MPT_TEMPLATE_TYPE_VARS_C3" UNIQUE ("TEMPLATE_CODE", "PLACEHOLDER")
  USING INDEX  ENABLE,
	 CONSTRAINT "MPT_TEMPLATE_TYPE_VARS_C4" UNIQUE ("SM_RELATION_ID")
  USING INDEX  ENABLE,
	 CONSTRAINT "MPT_TEMPLATE_TYPE_VARS_CH1" CHECK (IS_ACTIVE IN ('Y', 'N')) ENABLE
   ) ;

comment on table Mpt_Template_Type_Vars is 'Shablon turiga biriktirilgan chop o''zgaruvchilari (GROUP emas, TUR darajasida). Bir tur = bir necha o''zgaruvchi. PLACEHOLDER trigger orqali [variable_code] shaklida avtomatik.';
comment on column Mpt_Template_Type_Vars.Template_Code is 'MPT_TEMPLATE_TYPES ga FK - qaysi shablon turiga tegishli';
comment on column Mpt_Template_Type_Vars.Variable_Code is 'MPT_PRINT_VARIABLES ga FK - biriktirilgan o''zgaruvchi (GLOBAL yoki MODULE)';
comment on column Mpt_Template_Type_Vars.Placeholder is 'Fayl ichidagi ['']'' belgisi - [variable_code], trigger avtomatik to''ldiradi';
comment on column Mpt_Template_Type_Vars.Sm_Relation_Id is 'SM (Sm_Kernel) edit-model uchun relation id';
