-- Create table
create table SM_ACTION_ROUTES
(
  object_code   VARCHAR2(100) not null,
  curr_state_id NUMBER(3) not null,
  action_id     NUMBER(3) not null,
  new_state_id  NUMBER(3) not null,
  order_num     NUMBER(3) not null
) 
tablespace CORE_DATA;
-- Add comments to the table 
comment on table SM_ACTION_ROUTES
  is '���������� ���������';
-- Add comments to the columns 
comment on column SM_ACTION_ROUTES.object_code
  is '��� �������';
comment on column SM_ACTION_ROUTES.curr_state_id
  is '������� ���������';
comment on column SM_ACTION_ROUTES.action_id
  is '��������';
comment on column SM_ACTION_ROUTES.new_state_id
  is '����� ���������';
comment on column SM_ACTION_ROUTES.order_num
  is '���������� �����';
-- Create/Recreate primary, unique and foreign key constraints 
alter table SM_ACTION_ROUTES
  add constraint SM_ACTION_ROUTES_PK primary key (OBJECT_CODE, CURR_STATE_ID, ACTION_ID)
  using index tablespace CORE_index;
