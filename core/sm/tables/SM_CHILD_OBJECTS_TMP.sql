-- Create table
create global temporary table SM_CHILD_OBJECTS_TMP
(
  object_id          NUMBER(12),
  object_code        VARCHAR2(100),
  step               NUMBER(2),
  parent_object_id   NUMBER(12),
  parent_object_code VARCHAR2(100)
)
on commit preserve rows;
