--------------------------------------------------------------------------------
-- ACC moduli ("Тип счёта" / Fabrika produktov) seed ma'lumotlari va sequence'lar.
-- Manba jadvallar: D:\_Projects\new_abs\core\acc\docs\account_type_tables.sql
-- View'lar endi alohida fayllarda: views/ACC_*.sql (har biri o'z nomi bilan).
-- Paketlar: packages/ACC_DML.pck, packages/ACC_KERNEL.pck, packages/ACC_SM_API.pck
--
-- MUHIM: bu skriptni ishga tushirishdan oldin sqlplus klient muhitida
-- NLS_LANG=AMERICAN_AMERICA.AL32UTF8 o'rnating (masalan: export NLS_LANG=...
-- yoki Windows'da set NLS_LANG=...), aks holda kirill harflari (masalan
-- "Баланс", "Внебаланс", modul nomlari) bazaga buzilgan holda yoziladi
-- (UTF-8 baytlari boshqa kodировka sifatida noto'g'ri o'qib, qayta
-- kodировka qilinadi - natijada satr uzunligi ikki-uch baravar oshadi va
-- keyinchalik CHECK cheklovlari yoki VARCHAR2 uzunligi xatolarga olib keladi).
--------------------------------------------------------------------------------
SET DEFINE OFF
WHENEVER SQLERROR CONTINUE

--================================================================================
-- 1) Ma'lumotnoma (spravochnik) seed ma'lumotlari
--================================================================================
INSERT INTO ACC_R_MODULES (MODULE_CODE, MODULE_NAME) VALUES ('LN',   'Кредит (LN)');
INSERT INTO ACC_R_MODULES (MODULE_CODE, MODULE_NAME) VALUES ('DEP',  'Депозит (DEP)');
INSERT INTO ACC_R_MODULES (MODULE_CODE, MODULE_NAME) VALUES ('SV',   'Сберкнижка (SV)');
INSERT INTO ACC_R_MODULES (MODULE_CODE, MODULE_NAME) VALUES ('CARD', 'Карта (CARD)');
INSERT INTO ACC_R_MODULES (MODULE_CODE, MODULE_NAME) VALUES ('GUAR', 'Гарантия (GUAR)');
INSERT INTO ACC_R_MODULES (MODULE_CODE, MODULE_NAME) VALUES ('MT',   'Денежный перевод (MT)');
INSERT INTO ACC_R_MODULES (MODULE_CODE, MODULE_NAME) VALUES ('UTIL', 'Коммунальные платежи (UTIL)');
INSERT INTO ACC_R_MODULES (MODULE_CODE, MODULE_NAME) VALUES ('FX',   'Обмен валют (FX)');

INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('1','10101','19999','Капитал банка','Уставный капитал, резервы, нераспределённая прибыль.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('2','20101','20999','Наличность и драгоценные металлы','Касса, обменные пункты, драгметаллы.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('2','21000','21999','Средства в других банках','Корсчета НОСТРО, МБК размещённые.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('2','20400','20499','Депозитные счета клиентов','Вклады до востребования и срочные вклады физ./юр. лиц.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('3','30000','39999','Ценные бумаги','Портфель ценных бумаг для торговли и инвестиций.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('4','10100','19899','Ссудные счета (кредиты)','Основной долг по кредитам всех видов и клиентских сегментов.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('4','19900','19999','Просроченная задолженность','Просроченный основной долг и проценты по кредитам.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('5','50000','59999','Обязательства перед клиентами','Расчётные и текущие счета клиентов.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('6','60000','65999','Основные средства и НМА','Здания, оборудование, нематериальные активы банка.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('7','70000','79999','Прочие активы','Дебиторская задолженность, расчёты с поставщиками.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('8','80000','89999','Доходы','Процентные и непроцентные доходы банка.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('8','90000','96999','Расходы','Процентные и непроцентные расходы, резервы.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('9','97000','98999','Внебалансовые обязательства','Гарантии, аккредитивы, обязательства по кредитным линиям.');
INSERT INTO ACC_R_CLASS_CATALOG (CLASS_CODE, RANGE_FROM, RANGE_TO, CATALOG_NAME, CATALOG_DESC) VALUES ('9','99000','99999','Внебалансовый учёт (прочее)','Документы, залоги, бланки строгой отчётности, транзитные внебаланс.');

-- Sinf <-> Modul bog'lanishlari (CATALOG_ID larni CATALOG_NAME bo'yicha topamiz)
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'CARD' FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Наличность и драгоценные металлы';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'DEP'  FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Наличность и драгоценные металлы';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'FX'   FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Средства в других банках';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'DEP'  FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Депозитные счета клиентов';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'SV'   FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Депозитные счета клиентов';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'LN'   FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Ссудные счета (кредиты)';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'GUAR' FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Ссудные счета (кредиты)';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'LN'   FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Просроченная задолженность';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'CARD' FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Обязательства перед клиентами';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'MT'   FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Обязательства перед клиентами';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'UTIL' FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Прочие активы';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'LN'   FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Доходы';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'DEP'  FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Доходы';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'CARD' FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Доходы';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'LN'   FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Расходы';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'DEP'  FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Расходы';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'GUAR' FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Внебалансовые обязательства';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'LN'   FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Внебалансовый учёт (прочее)';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'DEP'  FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Внебалансовый учёт (прочее)';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'CARD' FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Внебалансовый учёт (прочее)';
INSERT INTO ACC_R_CLASS_CATALOG_MODULES (CATALOG_ID, MODULE_CODE) SELECT CATALOG_ID,'GUAR' FROM ACC_R_CLASS_CATALOG WHERE CATALOG_NAME='Внебалансовый учёт (прочее)';

COMMIT;
