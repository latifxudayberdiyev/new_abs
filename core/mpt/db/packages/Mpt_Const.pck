
  CREATE OR REPLACE EDITIONABLE PACKAGE "MPT_CONST" IS
  c_Module_Code constant varchar2(10) := 'MPT';
  c_Log_Insert constant varchar2(1) := 'I';
  c_Log_Update constant varchar2(1) := 'U';
  c_Log_Delete constant varchar2(1) := 'D';
END MPT_CONST;
/

