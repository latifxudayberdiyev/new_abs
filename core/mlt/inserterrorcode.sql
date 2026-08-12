prompt Importing table mlt_error_codes...
set feedback off
set define off

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 66, 'ERROR', 'created  error', null, null, 1);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 11, 'MESSAGE_CODE_REQUIRED', 'message code required uchun', null, null, 2);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 3, 'ALREADY_EXISTS', 'allaqachon mavjud error code', null, null, 3);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 4, 'MESSAGE_UPPER', 'message code katta harflarda bo''lishi kerak ', null, null, 4);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 5, 'TEMPLATE_NOT_FOUND', 'allaqachon mavjud error code', null, null, 5);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 6, 'INVALID_FORMAT_COUNT', 'Params soni textdagi belgiga soniga mos emas', null, null, 6);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 16, 'LABEL_CREATED', 'Label yaratildi', null, null, 7);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 17, 'LABEL_UPDATED', 'Label yangilandi', null, null, 8);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 13, 'MODULE_CODE_REQUIRED', 'module code required description', null, null, 9);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 14, 'DESCRIPTION_REQUIRED', 'description required description', null, null, 10);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 15, 'NOT_FOUND', 'object not found description', null, null, 11);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 7, 'MODULE_CODE_REQUIREDT', 'Module code talab qilinadi', null, null, 12);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 10, 'LABEL_UPDATED2', 'Label yangilandi', null, null, 13);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 8, 'TEMPLATE_UPDATED', 'template update description', null, null, 14);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 1, 'INVALID_LANG_INDEX', 'Lang index majburiy', null, null, 15);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 1004, 'TEMPLATE_ERROR', 'template ERROR description', null, null, 16);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 2, 'LANG_INDEX_REQUIRED', 'Lang index majburiy', null, null, 17);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 1005, 'TEMPLATE_CREATED', 'template CREATED description', null, null, 18);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 0, 'SUCCESS', 'hammasi ok', null, null, 19);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT', 9, 'TEMPLATE_ALREADY_EXISTS', 'template desc description', null, null, 20);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MLT1', 18, 'SUCCESS_TEST', 'description', null, null, 21);

insert into mlt_error_codes (MODULE_CODE, ERROR_CODE, MESSAGE_CODE, DESCRIPTION, MODIFIED_BY, MODIFIED_ON, ERROR_ID)
values ('MFI', 11122, 'TEST11', 'Module code talab qilinadi', null, null, 1000);

prompt Done.
