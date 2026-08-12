
  CREATE TABLE "MPT_PRINT_SETTINGS"
   (	"SETTING_ID" NUMBER(19,0) NOT NULL ENABLE,
	"IS_ACTIVE" VARCHAR2(1) DEFAULT 'Y' NOT NULL ENABLE,
	"OPER_DAY" DATE DEFAULT SYSDATE NOT NULL ENABLE,
	"MODIFIED_BY" NUMBER(30,0),
	"MODIFIED_ON" DATE,
	"SETTING_NAME" VARCHAR2(200),
	"MODULE_CODE" VARCHAR2(20),
	"TEMPLATE_CODE" VARCHAR2(50),
	"FILE_TYPE" VARCHAR2(10),
	"FILE_FORMAT" VARCHAR2(10),
	"ACTIVATION_DATE" DATE,
	"DESCRIPTION" VARCHAR2(1000),
	"DEACTIVATION_DATE" DATE,
	"OPEN_AS_PDF" VARCHAR2(1) DEFAULT 'N' NOT NULL ENABLE,
	 CONSTRAINT "MPT_PRINT_SETTINGS_C1" PRIMARY KEY ("SETTING_ID")
  USING INDEX  ENABLE,
	 CONSTRAINT "MPT_PRINT_SETTINGS_CH3" CHECK (IS_ACTIVE IN ('Y', 'N')) ENABLE,
	 CONSTRAINT "MPT_PRINT_SETTINGS_CH1" CHECK (File_Type in ('WORD', 'EXCEL')) ENABLE,
	 CONSTRAINT "MPT_PRINT_SETTINGS_CH2" CHECK ((File_Type = 'WORD' and upper(File_Format) in ('DOC', 'DOCX', 'PDF')) or
         (File_Type = 'EXCEL' and upper(File_Format) in ('XLSX', 'PDF'))) ENABLE,
	 CONSTRAINT "MPT_PRINT_SETTINGS_CH4" CHECK (Open_As_Pdf in ('Y', 'N')) ENABLE
   ) ;

comment on column Mpt_Print_Settings.Open_As_Pdf is 'Y - fayl PDF formatida ochiladi, N - original formatda';
comment on column Mpt_Print_Settings.Modified_By is 'RU: Пользователь, изменивший запись последним. UZC: Ёзувни сўнгги ўзгартирган фойдаланувчи. UZ: Yozuvni so`nggi o`zgartirgan foydalanuvchi. EN: User who last updated the record.';
comment on column Mpt_Print_Settings.Modified_On is 'RU: Дата последнего изменения записи. UZC: Ёзувнинг сўнгги ўзгартирилган санаси. UZ: Yozuvning so`nggi o`zgartirilgan sanasi. EN: Date the record was last updated.';

