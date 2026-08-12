CREATE OR REPLACE VIEW MLT_ERROR_V AS
SELECT m.template_id,
       m.message_code,
       m.description,
       m.param_count,
       m.format_string,
       m.message_mask_lang1,
       m.message_mask_lang2,
       m.message_mask_lang3,
       m.message_mask_lang4,
       m.message_mask_lang5,
       m.message_mask_lang6,
       m.message_mask_lang7,
       m.message_mask_lang8,
       m.message_mask_lang9,
       m.message_mask_lang10,
       e.module_code,
       e.error_code,
       e.description as error_desc,
       e.error_id
  FROM mlt_templates m join mlt_error_codes e
  on m.message_code=e.message_code;
