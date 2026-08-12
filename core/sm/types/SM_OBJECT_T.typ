create or replace type "SM_OBJECT_T" as object
(
  Object_Code                varchar2(100),
  Process_Code               varchar2(100),
  Process_Type               varchar2(50),
  Parent_Object_Code         varchar2(100),
  Relation_Id                number(10),
  Parent_Relation_Id         number(10),
  Relation_Key               varchar2(50),
  Parent_Relation_Key        varchar2(50),
  Object_Id                  number,
  Parent_Object_Id           number,
  Process_Id                 number,
  Initioal_State             varchar2(50),
  Object_State_New           varchar2(50),
  Seq_Getter                 varchar2(100),
  Cur_State                  varchar2(50),
  Has_Tranzition             varchar2(1),
  o_Code                     number,
  o_Msg                      varchar2(3000),
  o_Ora_Msg                  varchar2(3000),
  Process_Run_State          varchar2(1),
  Procedure_Name             varchar2(100),
  Procedure_Code             varchar2(100),
  Event_Code                 varchar2(100),
  Event_Execute_Mode         varchar2(10),
  Event_State_Id             number,
  Event_Hold_Check_Procedure varchar2(100),
  Is_Create                  varchar2(1),
  Is_Approve                 varchar2(1),
  Is_Deal                    varchar2(1),
  static Function Init return Sm_Object_t
)
;
/
create or replace type body "SM_OBJECT_T" as
  static Function Init return Sm_Object_t is
    t Sm_Object_t := Sm_Object_t(null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null,
                                 null);
  begin
    return t;
  end Init;
end;
/
