CREATE OR REPLACE VIEW MLT_LABEL_V AS
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
       l.label_id,
       l.module_code,
       l.description as label_description,
       l.field_hint
  FROM mlt_templates m join mll_label_codes l
  on m.message_code=l.message_code;
  

