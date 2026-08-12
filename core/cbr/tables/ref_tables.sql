----------------------------------------------------------------------------------------------------
--  Ref_Kernel / Ref_Dml paketlari ishlatadigan spravochnik jadvallari.
--  Oddiy (tarixsiz) konventsiya: CODE + maydonlar + DATE_ACTIV + DATE_DEACT + STATE + MODIFY_ON.
--  Manba: IBS@TEST tuzilishidan moslashtirilgan (REF_UID/DATE_APPLY/DATE_CANCEL/VERSION_ID/LABEL olib tashlangan).
----------------------------------------------------------------------------------------------------

-- Ref_Id -> Set_Ref protsedura nomi (Call_Reference shundan foydalanadi)
-- E'TIBOR: haqiqiy (RDP/NEW_IABS) muhitda bu jadval oldindan mavjud, faqat REF_ID va
-- PROCEDURE_NAME ustunlari bilan - shu tuzilishga moslashtirilgan.
CREATE TABLE Ref_r_Procedures
(  Ref_Id         NUMBER(6,0) NOT NULL,
   Procedure_Name VARCHAR2(200) NOT NULL,
   CONSTRAINT Ref_r_Procedures_PK PRIMARY KEY (Ref_Id)
);

----------------------------------------------------------------------------------------------------
-- Mavjud 5 ta (allaqachon Ref_Kernel/Ref_Dml'da bor, 19 talikka ham kiradi)
----------------------------------------------------------------------------------------------------

CREATE TABLE r_Region
(  Code       VARCHAR2(2) NOT NULL,
   Name       VARCHAR2(30),
   Order_By   NUMBER(2,0),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Region_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Currency
(  Code       VARCHAR2(3) NOT NULL,
   Char_Code  VARCHAR2(3),
   Name       VARCHAR2(35),
   Scale      NUMBER(1,0),
   Scale_Name VARCHAR2(20),
   Hard       VARCHAR2(1),
   Allow      VARCHAR2(1),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Currency_PK PRIMARY KEY (Code)
);

CREATE TABLE r_District
(  Code        VARCHAR2(3) NOT NULL,
   Name        VARCHAR2(30),
   Region_Code VARCHAR2(2),
   Date_Activ  DATE,
   Date_Deact  DATE,
   State       VARCHAR2(1),
   Modify_On   DATE,
   CONSTRAINT r_District_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Country
(  Code          VARCHAR2(3) NOT NULL,
   Char_Code     VARCHAR2(3),
   Char_Ext_Code VARCHAR2(3),
   Name          VARCHAR2(60),
   Currency_Code VARCHAR2(3),
   In_Sng        NUMBER(1,0),
   Date_Activ    DATE,
   Date_Deact    DATE,
   State         VARCHAR2(1),
   Modify_On     DATE,
   CONSTRAINT r_Country_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Business_Form
(  Code       VARCHAR2(3) NOT NULL,
   Name_Rus   VARCHAR2(150),
   Name_Uzb   VARCHAR2(150),
   Group_Code VARCHAR2(3),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Business_Form_PK PRIMARY KEY (Code)
);

----------------------------------------------------------------------------------------------------
-- 19 talikka kirmaydigan, lekin paketda mavjud bo'lgani uchun kompilyatsiya uchun kerak (5 ta)
----------------------------------------------------------------------------------------------------

CREATE TABLE r_Credit_Source
(  Code       VARCHAR2(10) NOT NULL,
   Name       VARCHAR2(200),
   Group_Code VARCHAR2(10),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Credit_Source_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Foreign_Organization
(  Code               VARCHAR2(10) NOT NULL,
   Credit_Source_Code VARCHAR2(10),
   Name               VARCHAR2(200),
   Label              VARCHAR2(200),
   Date_Activ         DATE,
   Date_Deact         DATE,
   State              VARCHAR2(1),
   Modify_On          DATE,
   CONSTRAINT r_Foreign_Organization_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Bank_Corr
(  Code         VARCHAR2(10) NOT NULL,
   Swift_Code   VARCHAR2(20),
   Name         VARCHAR2(200),
   Country_Code VARCHAR2(3),
   Date_Activ   DATE,
   Date_Deact   DATE,
   State        VARCHAR2(1),
   Modify_On    DATE,
   CONSTRAINT r_Bank_Corr_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Budget_Accounts
(  Code         VARCHAR2(20) NOT NULL,
   Account_Code VARCHAR2(30),
   Inn          VARCHAR2(9),
   Name         VARCHAR2(200),
   Date_Activ   DATE,
   Date_Deact   DATE,
   State        VARCHAR2(1),
   Modify_On    DATE,
   CONSTRAINT r_Budget_Accounts_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Oked
(  Sction_Gr       VARCHAR2(10),
   Section_Sy      VARCHAR2(10),
   Sg_Name_Ru      VARCHAR2(200),
   Sg_Name_Uz      VARCHAR2(200),
   Section_Code    VARCHAR2(10),
   Section_Name_Ru VARCHAR2(200),
   Section_Name_Uz VARCHAR2(200),
   Group_Code      VARCHAR2(10),
   Group_Name_Ru   VARCHAR2(200),
   Group_Name_Uz   VARCHAR2(200),
   Class_Code      VARCHAR2(10),
   Class_Name_Ru   VARCHAR2(200),
   Class_Name_Uz   VARCHAR2(200),
   Code            VARCHAR2(10) NOT NULL,
   Name_Ru         VARCHAR2(300),
   Name_Uz         VARCHAR2(300),
   Date_Activ      DATE,
   Date_Deact      DATE,
   State           VARCHAR2(1),
   Modify_On       DATE,
   CONSTRAINT r_Oked_PK PRIMARY KEY (Code)
);

----------------------------------------------------------------------------------------------------
-- 19 talikning qolgan 14 tasi (yangi)
----------------------------------------------------------------------------------------------------

CREATE TABLE r_Subject_Type
(  Code       VARCHAR2(1) NOT NULL,
   Name       VARCHAR2(40),
   Name_Uz    VARCHAR2(40),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Subject_Type_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Subject_Sexual_Identity
(  Code       VARCHAR2(1) NOT NULL,
   Name       VARCHAR2(10),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Subject_Sexual_Identity_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Verifying_Document_Type
(  Code       VARCHAR2(1) NOT NULL,
   Name       VARCHAR2(50),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Verifying_Document_Type_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Bank
(  Code               VARCHAR2(5) NOT NULL,
   Bank_Type_Code     VARCHAR2(3),
   Region_Code        VARCHAR2(2),
   Header_Code        VARCHAR2(5),
   Union_Code         VARCHAR2(5),
   Tcr_Code           VARCHAR2(5),
   Rkc_Code           VARCHAR2(5),
   Name               VARCHAR2(80),
   Adress             VARCHAR2(60),
   Status_Code        VARCHAR2(2),
   Account_Type       VARCHAR2(1),
   Date_Open          DATE,
   Date_Close         DATE,
   Active             VARCHAR2(1),
   Email              VARCHAR2(18),
   Server_Alias       VARCHAR2(50),
   Connect_Type       VARCHAR2(1),
   Allow_Currency     VARCHAR2(1),
   District_Code      VARCHAR2(3),
   Num_Change_Office  NUMBER(2,0),
   Date_Activ         DATE,
   Date_Deact         DATE,
   State              VARCHAR2(1),
   Modify_On          DATE,
   CONSTRAINT r_Bank_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Bank_Type
(  Code         VARCHAR2(3) NOT NULL,
   Name         VARCHAR2(40),
   Short_Name   VARCHAR2(10),
   Country_Code VARCHAR2(3),
   Account_Type VARCHAR2(5),
   Date_Open    DATE,
   Date_Close   DATE,
   Date_Activ   DATE,
   Date_Deact   DATE,
   State        VARCHAR2(1),
   Modify_On    DATE,
   CONSTRAINT r_Bank_Type_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Document
(  Code       VARCHAR2(2) NOT NULL,
   Name       VARCHAR2(30),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Document_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Rez_Cl
(  Code       VARCHAR2(1) NOT NULL,
   Name       VARCHAR2(20),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Rez_Cl_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Tax_Organization
(  Code       VARCHAR2(4) NOT NULL,
   Name       VARCHAR2(80),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Tax_Organization_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Form_Property
(  Code       VARCHAR2(3) NOT NULL,
   Name       VARCHAR2(100),
   Active     VARCHAR2(1),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Form_Property_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Organization_Legal_Form
(  Code       VARCHAR2(4) NOT NULL,
   Name       VARCHAR2(80),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Organization_Legal_Form_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Nation
(  Code        VARCHAR2(2) NOT NULL,
   Nation_Name VARCHAR2(15),
   Date_Activ  DATE,
   Date_Deact  DATE,
   State       VARCHAR2(1),
   Modify_On   DATE,
   CONSTRAINT r_Nation_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Obraz
(  Code       VARCHAR2(1) NOT NULL,
   Obraz_Name VARCHAR2(20),
   Date_Activ DATE,
   Date_Deact DATE,
   State      VARCHAR2(1),
   Modify_On  DATE,
   CONSTRAINT r_Obraz_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Coato
(  Code              VARCHAR2(5) NOT NULL,
   District_Code     VARCHAR2(3),
   District_Tax_Code VARCHAR2(4),
   Region_Code       VARCHAR2(2),
   Rus_Name          VARCHAR2(60),
   Uzb_Cyr_Name      VARCHAR2(60),
   Uzb_Lat_Name      VARCHAR2(60),
   Date_Activ        DATE,
   Date_Deact        DATE,
   State             VARCHAR2(1),
   Modify_On         DATE,
   CONSTRAINT r_Coato_PK PRIMARY KEY (Code)
);

CREATE TABLE r_Mahalla
(  Code_Uz_Cad VARCHAR2(10) NOT NULL,
   Code_1c     VARCHAR2(8),
   Inn         VARCHAR2(9),
   Region_Id   VARCHAR2(4),
   Soato_Id    VARCHAR2(7),
   Distr       VARCHAR2(3),
   Name_Uz     VARCHAR2(50),
   Name_Ru     VARCHAR2(50),
   Name_En     VARCHAR2(50),
   Date_Open   DATE,
   Date_Close  DATE,
   Active      VARCHAR2(1),
   Modify_On   DATE,
   CONSTRAINT r_Mahalla_PK PRIMARY KEY (Code_Uz_Cad)
);

----------------------------------------------------------------------------------------------------
-- Ref_r_Procedures: Ref_Id -> Set_Ref_XX xaritasi (24 ta: mavjud 10 + yangi 14)
----------------------------------------------------------------------------------------------------
insert into Ref_r_Procedures values (16,  'Ref_Kernel.Set_Ref_16');
insert into Ref_r_Procedures values (17,  'Ref_Kernel.Set_Ref_17');
insert into Ref_r_Procedures values (52,  'Ref_Kernel.Set_Ref_52');
insert into Ref_r_Procedures values (18,  'Ref_Kernel.Set_Ref_18');
insert into Ref_r_Procedures values (38,  'Ref_Kernel.Set_Ref_38');
insert into Ref_r_Procedures values (41,  'Ref_Kernel.Set_Ref_41');
insert into Ref_r_Procedures values (47,  'Ref_Kernel.Set_Ref_47');
insert into Ref_r_Procedures values (29,  'Ref_Kernel.Set_Ref_29');
insert into Ref_r_Procedures values (93,  'Ref_Kernel.Set_Ref_93');
insert into Ref_r_Procedures values (13,  'Ref_Kernel.Set_Ref_13');
insert into Ref_r_Procedures values (6,   'Ref_Kernel.Set_Ref_6');
insert into Ref_r_Procedures values (7,   'Ref_Kernel.Set_Ref_7');
insert into Ref_r_Procedures values (8,   'Ref_Kernel.Set_Ref_8');
insert into Ref_r_Procedures values (12,  'Ref_Kernel.Set_Ref_12');
insert into Ref_r_Procedures values (14,  'Ref_Kernel.Set_Ref_14');
insert into Ref_r_Procedures values (26,  'Ref_Kernel.Set_Ref_26');
insert into Ref_r_Procedures values (27,  'Ref_Kernel.Set_Ref_27');
insert into Ref_r_Procedures values (54,  'Ref_Kernel.Set_Ref_54');
insert into Ref_r_Procedures values (57,  'Ref_Kernel.Set_Ref_57');
insert into Ref_r_Procedures values (63,  'Ref_Kernel.Set_Ref_63');
insert into Ref_r_Procedures values (72,  'Ref_Kernel.Set_Ref_72');
insert into Ref_r_Procedures values (74,  'Ref_Kernel.Set_Ref_74');
insert into Ref_r_Procedures values (92,  'Ref_Kernel.Set_Ref_92');
insert into Ref_r_Procedures values (125, 'Ref_Kernel.Set_Ref_125');
commit;
