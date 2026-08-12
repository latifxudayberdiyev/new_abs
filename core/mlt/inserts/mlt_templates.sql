delete from mlt_templates where template_id = 1;
--
insert into mlt_templates(template_id,message_code, description, param_count, format_string, message_mask_lang1, message_mask_lang2, message_mask_lang3, message_mask_lang4, message_mask_lang5, message_mask_lang6, message_mask_lang7, message_mask_lang8, message_mask_lang9, message_mask_lang10)
values (1, 'USER_NOT_FOUND_BY_USER_ID', 'Berilgan USER_ID oraqali user topilmadi', 1, '$', 'Ползователь не найден по указанному $1', 'Берилган $1 буйича фойдаланувчи топилмади', 'Berilgan $1 bo`yicha foydalanuvchi topilmadi', 'User not found for the given user $1', '','','','','','');
