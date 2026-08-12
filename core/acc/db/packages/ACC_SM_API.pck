--------------------------------------------------------------------------------
-- ACC_SM_API - Core_Api.Execute_Process_Clob / Get_Model_Clob (Sm_Kernel)
-- tomonidan chaqiriladigan tashqi kirish nuqtasi. Hech qanday logika yo'q -
-- faqat ACC_KERNEL'dagi mos protsedurani chaqiradi (Pf_Sm_Api / Pf_Kernel
-- naqshiga mos).
--------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ACC_SM_API IS

  PROCEDURE Model_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                o_Code    OUT Number,
                                o_Msg     OUT Varchar2,
                                o_Ora_Msg OUT Varchar2);

  PROCEDURE Save_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                               o_Code    OUT Number,
                               o_Msg     OUT Varchar2,
                               o_Ora_Msg OUT Varchar2);

  PROCEDURE Delete_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                 o_Code    OUT Number,
                                 o_Msg     OUT Varchar2,
                                 o_Ora_Msg OUT Varchar2);

  PROCEDURE Model_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                       o_Code    OUT Number,
                                       o_Msg     OUT Varchar2,
                                       o_Ora_Msg OUT Varchar2);

  PROCEDURE Save_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                      o_Code    OUT Number,
                                      o_Msg     OUT Varchar2,
                                      o_Ora_Msg OUT Varchar2);

  PROCEDURE Delete_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                        o_Code    OUT Number,
                                        o_Msg     OUT Varchar2,
                                        o_Ora_Msg OUT Varchar2);

  PROCEDURE Model_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                           o_Code    OUT Number,
                           o_Msg     OUT Varchar2,
                           o_Ora_Msg OUT Varchar2);

  PROCEDURE Save_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                          o_Code    OUT Number,
                          o_Msg     OUT Varchar2,
                          o_Ora_Msg OUT Varchar2);

  PROCEDURE Delete_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                            o_Code    OUT Number,
                            o_Msg     OUT Varchar2,
                            o_Ora_Msg OUT Varchar2);

  PROCEDURE Model_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                  o_Code    OUT Number,
                                  o_Msg     OUT Varchar2,
                                  o_Ora_Msg OUT Varchar2);

  PROCEDURE Save_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                 o_Code    OUT Number,
                                 o_Msg     OUT Varchar2,
                                 o_Ora_Msg OUT Varchar2);

  PROCEDURE Delete_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                   o_Code    OUT Number,
                                   o_Msg     OUT Varchar2,
                                   o_Ora_Msg OUT Varchar2);

END ACC_SM_API;
/

CREATE OR REPLACE PACKAGE BODY ACC_SM_API IS

  PROCEDURE Model_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                o_Code    OUT Number,
                                o_Msg     OUT Varchar2,
                                o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Model_Account_Type(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Model_Account_Type;

  PROCEDURE Save_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                               o_Code    OUT Number,
                               o_Msg     OUT Varchar2,
                               o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Save_Account_Type(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Save_Account_Type;

  PROCEDURE Delete_Account_Type(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                 o_Code    OUT Number,
                                 o_Msg     OUT Varchar2,
                                 o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Delete_Account_Type(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Delete_Account_Type;

  PROCEDURE Model_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                       o_Code    OUT Number,
                                       o_Msg     OUT Varchar2,
                                       o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Model_Account_Type_Client(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Model_Account_Type_Client;

  PROCEDURE Save_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                      o_Code    OUT Number,
                                      o_Msg     OUT Varchar2,
                                      o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Save_Account_Type_Client(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Save_Account_Type_Client;

  PROCEDURE Delete_Account_Type_Client(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                        o_Code    OUT Number,
                                        o_Msg     OUT Varchar2,
                                        o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Delete_Account_Type_Client(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Delete_Account_Type_Client;

  PROCEDURE Model_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                           o_Code    OUT Number,
                           o_Msg     OUT Varchar2,
                           o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Model_Account(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Model_Account;

  PROCEDURE Save_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                          o_Code    OUT Number,
                          o_Msg     OUT Varchar2,
                          o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Save_Account(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Save_Account;

  PROCEDURE Delete_Account(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                            o_Code    OUT Number,
                            o_Msg     OUT Varchar2,
                            o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Delete_Account(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Delete_Account;

  PROCEDURE Model_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                  o_Code    OUT Number,
                                  o_Msg     OUT Varchar2,
                                  o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Model_Account_Module(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Model_Account_Module;

  PROCEDURE Save_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                 o_Code    OUT Number,
                                 o_Msg     OUT Varchar2,
                                 o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Save_Account_Module(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Save_Account_Module;

  PROCEDURE Delete_Account_Module(Io_Hash   IN OUT NOCOPY Core.Hash_t,
                                   o_Code    OUT Number,
                                   o_Msg     OUT Varchar2,
                                   o_Ora_Msg OUT Varchar2) IS
  BEGIN
    Acc_Kernel.Delete_Account_Module(Io_Hash, o_Code, o_Msg, o_Ora_Msg);
  END Delete_Account_Module;

END ACC_SM_API;
/
