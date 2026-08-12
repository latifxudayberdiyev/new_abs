
create or replace package File_Const is

-- Author  : B.URALOV
-- Purpose : File moduli konstantalari.

c_Log_Insert constant varchar2(1) := 'I';
c_Log_Update constant varchar2(1) := 'U';
c_Log_Delete constant varchar2(1) := 'D';

c_State_Entered      constant number := 0;
c_State_Sent_Confirm constant number := 1;
c_State_Approved     constant number := 3;
c_State_Rejected     constant number := 4;
c_State_Deleted      constant number := 8;
c_State_Archived     constant number := 9;

end File_Const;
/
