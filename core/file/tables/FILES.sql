CREATE TABLE FILES
(
  FILE_ID     NUMBER(10)     NOT NULL,
  FILE_TOKEN  VARCHAR2(100),
  DOC_TYPE    NUMBER(5)      NOT NULL,
  FILE_NAME   VARCHAR2(100)  NOT NULL,
  BEGIN_DATE  DATE           NOT NULL,
  END_DATE    DATE           NOT NULL,
  STATE       NUMBER(1)      NOT NULL,
  CREATED_BY  NUMBER         NOT NULL,
  CREATED_ON  DATE           DEFAULT SYSDATE NOT NULL,
  MODIFIED_BY NUMBER         NOT NULL,
  MODIFIED_ON DATE           DEFAULT SYSDATE NOT NULL,
  FILE_URL    VARCHAR2(200),
  DESCRIPTION VARCHAR2(1000),
  CONSTRAINT FILES_PK PRIMARY KEY (FILE_ID) USING INDEX TABLESPACE CORE_INDEX,
  CONSTRAINT FILES_C1 CHECK (STATE IN (0, 1, 3, 4, 8, 9))
) TABLESPACE CORE_DATA;

COMMENT ON TABLE FILES IS 'Fayllar - boshqa modullar obyektlariga (masalan PF_PRODUCTS) SM_OBJECTS ota-bola bog''lanishi orqali biriktiriladi. Fayl fizik jihatdan fayl serverida saqlanadi';
COMMENT ON COLUMN FILES.FILE_ID IS 'Faylning ichki identifikatori';
COMMENT ON COLUMN FILES.FILE_TOKEN IS 'Fayl serveridan yuklab olish/havola uchun ishlatiladigan token';
COMMENT ON COLUMN FILES.DOC_TYPE IS 'Hujjat turi';
COMMENT ON COLUMN FILES.FILE_NAME IS 'Fayl nomi';
COMMENT ON COLUMN FILES.BEGIN_DATE IS 'Amal qilish boshlanish sanasi';
COMMENT ON COLUMN FILES.END_DATE IS 'Amal qilish tugash sanasi';
COMMENT ON COLUMN FILES.STATE IS '0-kiritilgan, 1-tasdiqlashga yuborilgan, 3-tasdiqlangan, 4-rad etilgan, 8-o''chirilgan, 9-arxivlangan';
COMMENT ON COLUMN FILES.CREATED_BY IS 'Yaratgan foydalanuvchi (User_Env.Get_User_Id)';
COMMENT ON COLUMN FILES.CREATED_ON IS 'Yaratilgan vaqt';
COMMENT ON COLUMN FILES.MODIFIED_BY IS 'Oxirgi o''zgartirgan foydalanuvchi (User_Env.Get_User_Id)';
COMMENT ON COLUMN FILES.MODIFIED_ON IS 'Oxirgi o''zgartirilgan vaqt';
COMMENT ON COLUMN FILES.FILE_URL IS 'Fayl serveridagi nisbiy manzil. To''liq URL uchun host qismi chaqiruvchi tomonidan (tashqaridan) qo''shiladi';
COMMENT ON COLUMN FILES.DESCRIPTION IS 'Izoh';
