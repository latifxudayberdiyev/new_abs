
  CREATE TABLE "MPT_PRINT_SETTING_FILES_H"
   (	"LOG_ID" NUMBER NOT NULL ENABLE,
	"SETTING_FILE_ID" NUMBER NOT NULL ENABLE,
	"SETTING_ID" NUMBER NOT NULL ENABLE,
	"LANG_CODE" VARCHAR2(5) NOT NULL ENABLE,
	"FILE_ID" VARCHAR2(36) NOT NULL ENABLE,
	"FILE_NAME" VARCHAR2(255),
	"CREATED_DATE" DATE NOT NULL ENABLE,
	"MODIFIED_BY" NUMBER,
	"OPER_DAY" DATE,
	"ACTION" VARCHAR2(1) NOT NULL ENABLE,
	"ACTION_DATE" DATE NOT NULL ENABLE,
	 CONSTRAINT "MPT_PRINT_SETTING_FILES_H_CH1" CHECK (ACTION IN ('I','U','D')) ENABLE,
	 CONSTRAINT "MPT_PRINT_SETTING_FILES_H_PK" PRIMARY KEY ("LOG_ID")
  USING INDEX  ENABLE
   ) ;

comment on table Mpt_Print_Setting_Files_H is 'MPT_PRINT_SETTING_FILES uchun o`zgarishlar tarixi - har bir shablon+til uchun biriktirilgan barcha fayllar (eski va yangi) shu yerda saqlanadi';
comment on column Mpt_Print_Setting_Files_H.Action is 'I=yaratildi, U=ozgartirildi (fayl almashtirildi), D=ochirildi';
