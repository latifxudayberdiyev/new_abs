prompt Importing table mlt_templates...
set feedback off
set define off

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (24, 'ERROR', 'Generic error', 0, '$', 'Произошла ошибка', 'Хатолик юз берди', 'Xatolik yuz berdi', 'An error occurred', 'Qatelik júz berdi', 'Хато рух дод', null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (25, 'ALREADY_EXISTS', 'Object already exists', 1, '$', '$1 уже существует', '$1 аллақачон мавжуд', '$1 allaqachon mavjud', '$1 already exists', '$1 allaqashan bar', '$1 аллакай вуҷуд дорад', null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (27, 'TEMPLATE_NOT_FOUND', 'Template not found message', 1, '$', 'Шаблон $1 не найден', 'Шаблон $1 топилмади', 'Shablon $1 topilmadi', 'Template $1 not found', 'Shablon $1 tabılmadı', 'Шаблон $1 ёфт нашуд', null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (28, 'INVALID_FORMAT_COUNT', 'Format string count mismatch', 2, '$', 'Ошибка в языке $1. Должно быть $2 параметра', 'Тил $1 да хатолик. $2 та параметр бўлиши керак', 'Lang $1 da format noto‘‘g‘ri. $2 ta bo‘lishi kerak', 'Format error in lang $1. Expected $2 parameters', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (23, 'MESSAGE_CODE_REQUIRED', 'Message code majburiy', 0, '$', 'Код сообщения обязателен', 'Хабар коди мажбурий', 'Message code majburiy', 'Message code is required', null, 'Рамзи паём ҳатмист', null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (53, 'LABEL_CREATED', 'Label yaratildi', 1, '$', 'Метка $1 успешно создана', '$1 label muvaffaqiyatli yaratildi', '$1 label muvaffaqiyatli yaratildi', '$1 label created successfully', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (54, 'LABEL_UPDATED', 'Label yangilandi', 1, '$', 'Метка $1 успешно обновлена', '$1 label muvaffaqiyatli yangilandi', '$1 label muvaffaqiyatli yangilandi', '$1 label updated successfully', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (55, 'SAVE_BUTTON', 'save button', 1, '$', 'Кнопка $1 сохранена', '$1 tugmasi saqlandi', '$1 tugmasi saqlandi', '$1 button saved', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (56, 'UPDATE_BUTTON', 'save button', 1, '$', 'Кнопка $1 yangilandi', '$1 tugmasi yangilandi', '$1 tugmasi yangilandi', '$1 button yangilandi', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (51, 'DESCRIPTION_REQUIRED', 'description required description', 0, '$', 'Описание обязательно', 'Description majburiy', 'Description majburiy', 'Description is required', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (52, 'NOT_FOUND', 'object not found description', 1, '$', 'Объект $1 не найден', '$1 topilmadi', '$ topilmadi', '$1 not found', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (60, 'MODULE_CODE_REQUIREDT', 'Module code talab qilinadi', 0, '$', 'templateD $1 CREATED rus', 'template $1 CREATED krill', 'template $1 CREATED uzbek', null, null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (61, 'MESSAGE_CODE_REQUIRED_TEST3', 'Message kernel', 0, '$', 'Message code talab etiladi', 'Message code required', 'Код сообщения обязателен', null, null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (62, 'LABEL_UPDATED2', 'Label yangilandi', 1, '$', 'Метка $ успешно обновлена', '$ label muvaffaqiyatli yangilandi', '$ label muvaffaqiyatli yangilandi', '$ label updated successfully', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (50, 'MODULE_CODE_REQUIRED', 'module code required description', 0, '$', 'Код модуля обязателен', 'Modul kodi majburiy', 'Modul kodi majburiy', 'Module code is required', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (66, 'TABLE1', 'test uchun', 0, '$', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test', 'test');

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (44, 'TEMPLATE_UPDATED', 'template update description', 1, '$', 'Шаблон $1 успешно обновлен', 'Шаблон $1 муваффақиятли янгиланди', 'Shablon $1 muvaffaqiyatli yangilandi', 'Template $1 was updated successfully', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (38, 'TEMPLATE_CREATED', 'template CREATED description', 1, '$', 'Шаблон $1 успешно создан', 'Шаблон $1 муваффақиятли яратилди', 'Shablon $1 muvaffaqiyatli yaratildi', 'Template $1 was created successfully', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (39, 'INVALID_LANG_INDEX', 'Lang index majburiy', 0, '$', 'Неверный индекс языка', 'Нотўғри тил индекси', 'Noto‘g‘ri til indeksi', 'Invalid language index', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (46, 'TEMPLATE_ALREADY_EXISTS', 'template desc description', 1, '$', 'template mavjud ru', 'template mavjud krill', 'template mavjud uzb', 'template mavjud eng', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (40, 'LANG_INDEX_REQUIRED', 'Lang index majburiy', 0, '$', 'Требуется индекс языка', 'Тил индекси мажбурий', 'Til indeksi majburiy', 'Language index is required', null, null, null, null, null, null);

insert into mlt_templates (TEMPLATE_ID, MESSAGE_CODE, DESCRIPTION, PARAM_COUNT, FORMAT_STRING, MESSAGE_MASK_LANG1, MESSAGE_MASK_LANG2, MESSAGE_MASK_LANG3, MESSAGE_MASK_LANG4, MESSAGE_MASK_LANG5, MESSAGE_MASK_LANG6, MESSAGE_MASK_LANG7, MESSAGE_MASK_LANG8, MESSAGE_MASK_LANG9, MESSAGE_MASK_LANG10)
values (42, 'SUCCESS', 'hammasi ok', 0, '$', 'Успешно', 'Муваффақиятли бажарилди', 'Muvaffaqiyatli', 'Success', null, null, null, null, null, null);

prompt Done.
