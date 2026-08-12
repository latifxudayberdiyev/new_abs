CREATE TABLE PF_R_CATEGORIES
(
  ID           NUMBER        NOT NULL,
  CODE         VARCHAR2(50)  NOT NULL,
  ML_NAME_CODE VARCHAR2(100) NOT NULL,
  STATE        VARCHAR2(1)   DEFAULT 'A' NOT NULL,
  CONSTRAINT PF_CATEGORY_PK PRIMARY KEY (ID) USING INDEX TABLESPACE CORE_INDEX,
  CONSTRAINT PF_CATEGORY_UK1 UNIQUE (CODE) USING INDEX TABLESPACE CORE_INDEX,
  CONSTRAINT PF_CATEGORY_C1 CHECK (STATE IN ('A', 'P'))
) TABLESPACE CORE_DATA;

COMMENT ON TABLE PF_R_CATEGORIES IS 'Produkt kategoriyalari (CREDIT, DEPOSIT va h.k.)';
COMMENT ON COLUMN PF_R_CATEGORIES.ID IS 'Kategoriyaning ichki identifikatori';
COMMENT ON COLUMN PF_R_CATEGORIES.CODE IS 'Barqaror texnik kod. Integratsiyalarda ishlatiladi, o''zgarmaydi';
COMMENT ON COLUMN PF_R_CATEGORIES.ML_NAME_CODE IS 'Nomning ml xizmatidagi kodi. Ko''rsatishda joriy til bo''yicha tarjima ml dan olinadi';
COMMENT ON COLUMN PF_R_CATEGORIES.STATE IS 'A - yangi produktda tanlanadi; P - yashiriladi (passiv), mavjud produktlar ishlaydi (soft delete)';


