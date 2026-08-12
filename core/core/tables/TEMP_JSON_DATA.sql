-- Create table
create global temporary table TEMP_JSON_DATA
(
  key_name  VARCHAR2(4000),
  key_value VARCHAR2(4000)
)
on commit preserve rows;
