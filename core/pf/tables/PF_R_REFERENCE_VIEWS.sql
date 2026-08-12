CREATE TABLE PF_R_REFERENCE_VIEWS
(
  ID           NUMBER        NOT NULL,
  CODE         VARCHAR2(50)  NOT NULL,
  ML_NAME_CODE VARCHAR2(100) NOT NULL,
  VIEW_NAME    VARCHAR2(100) NOT NULL,
  MODULE_CODE  VARCHAR2(10)  NOT NULL,
  SORT_ORDER   NUMBER        DEFAULT 0 NOT NULL,
  CONSTRAINT PF_R_REFERENCE_VIEW_PK PRIMARY KEY (ID) USING INDEX TABLESPACE CORE_INDEX,
  CONSTRAINT PF_R_REFERENCE_VIEW_UK1 UNIQUE (CODE) USING INDEX TABLESPACE CORE_INDEX,
  CONSTRAINT PF_R_REFERENCE_VIEW_UK2 UNIQUE (VIEW_NAME) USING INDEX TABLESPACE CORE_INDEX
) TABLESPACE CORE_DATA;

COMMENT ON TABLE PF_R_REFERENCE_VIEWS IS 'INPUT_TYPE=REFERENCE parametrlar uchun ruxsat etilgan spravochnik view''lar reyestri (whitelist). Faqat shu yerda ro''yxatdan o''tgan view''lar parametrga bog''lanishi mumkin - ixtiyoriy view nomi qabul qilinmaydi';
COMMENT ON COLUMN PF_R_REFERENCE_VIEWS.ID IS 'Ichki identifikator - PF_R_PARAMETERS.REFERENCE_ID shu yerga FK qiladi';
COMMENT ON COLUMN PF_R_REFERENCE_VIEWS.CODE IS 'Barqaror kod';
COMMENT ON COLUMN PF_R_REFERENCE_VIEWS.ML_NAME_CODE IS 'Ko''rsatiladigan nomning ML kodi';
COMMENT ON COLUMN PF_R_REFERENCE_VIEWS.VIEW_NAME IS 'Haqiqiy DB view nomi (masalan PF_R_CATEGORIES_V). Bu view CODE va NAME ustunlariga ega bo''lishi shart - faqat admin ro''yxatga oladi, foydalanuvchidan qabul qilinmaydi';
COMMENT ON COLUMN PF_R_REFERENCE_VIEWS.MODULE_CODE IS 'Bu view qaysi moduldan kelganini bildiradi (masalan PF, yoki boshqa modul kodi) - PF_R_ATTRIBUTES.MODULE_CODE bilan bir xil ma''noda';
COMMENT ON COLUMN PF_R_REFERENCE_VIEWS.SORT_ORDER IS 'Ko''rsatish tartibi';
