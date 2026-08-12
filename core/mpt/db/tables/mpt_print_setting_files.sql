
  CREATE TABLE "MPT_PRINT_SETTING_FILES"
   (	"SETTING_FILE_ID" NUMBER(19,0) NOT NULL ENABLE,
	"SETTING_ID" NUMBER(19,0) NOT NULL ENABLE,
	"LANG_CODE" VARCHAR2(5) NOT NULL ENABLE,
	"FILE_ID" VARCHAR2(36) NOT NULL ENABLE,
	"FILE_NAME" VARCHAR2(255),
	"CREATED_DATE" DATE DEFAULT SYSDATE NOT NULL ENABLE,
	"MODIFIED_BY" NUMBER(30,0),
	"OPER_DAY" DATE,
	 CONSTRAINT "MPT_PRINT_SETTING_FILES_C1" PRIMARY KEY ("SETTING_FILE_ID")
  USING INDEX  ENABLE,
	 CONSTRAINT "MPT_PRINT_SETTING_FILES_U1" UNIQUE ("SETTING_ID", "LANG_CODE")
  USING INDEX  ENABLE
   ) ;

comment on table Mpt_Print_Setting_Files is 'Har bir chop sozlamasi (MPT_PRINT_SETTINGS) uchun til bo`yicha yuklangan shablon fayli - file-service dagi FILE_ID ga havola';
comment on column Mpt_Print_Setting_Files.File_Id is 'file-service (uz.sqb.abs.fileclient) upload javobidagi FileUploadResponse.getId() - UUID';
comment on column Mpt_Print_Setting_Files.File_Name is 'Foydalanuvchi tanlagan asl fayl nomi - ko`rsatish uchun';
comment on column Mpt_Print_Setting_Files.Modified_By is 'RU: Пользователь, изменивший запись последним. UZC: Ёзувни сўнгги ўзгартирган фойдаланувчи. UZ: Yozuvni so`nggi o`zgartirgan foydalanuvchi. EN: User who last updated the record.';
comment on column Mpt_Print_Setting_Files.Oper_Day is 'RU: Дата последнего изменения записи. UZC: Ёзувнинг сўнгги ўзгартирилган санаси. UZ: Yozuvning so`nggi o`zgartirilgan sanasi. EN: Date the record was last updated.';

