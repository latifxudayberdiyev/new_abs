SET LINESIZE 200
SET PAGESIZE 100

-- CODE ni butun jadval bo'yicha emas, bitta ATTRIBUTE_ID ichida unikal qilish
-- (2026-07-24, foydalanuvchi tasdig'i bilan). Eski cheklov qat'iyroq bo'lgani
-- uchun mavjud qatorlarda konflikt bo'lishi mumkin emas - to'g'ridan-to'g'ri
-- almashtirish xavfsiz.

ALTER TABLE PF_PARAMETER DROP CONSTRAINT PF_PARAMETER_UK1;
ALTER TABLE PF_PARAMETER ADD CONSTRAINT PF_PARAMETER_UK1 UNIQUE (ATTRIBUTE_ID, CODE) USING INDEX TABLESPACE CORE_INDEX;

PROMPT === verify ===
SELECT constraint_name, constraint_type, status FROM user_constraints WHERE table_name = 'PF_PARAMETER' AND constraint_name = 'PF_PARAMETER_UK1';
SELECT index_name, uniqueness FROM user_indexes WHERE table_name = 'PF_PARAMETER' AND index_name = 'PF_PARAMETER_UK1';
