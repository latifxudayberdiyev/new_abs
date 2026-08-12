-- Create table
create global temporary table SM_PARAM_PROTOCOLS
(
  param_key   VARCHAR2(100),
  param_value VARCHAR2(1000),
  err_code    NUMBER,
  err_msg     VARCHAR2(1000)
)
on commit preserve rows;
-- Create/Recreate indexes 
create index SM_PARAM_PROTOCOLS_I1 on SM_PARAM_PROTOCOLS (PARAM_KEY);
