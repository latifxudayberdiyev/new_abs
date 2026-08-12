create or replace package Sql_Util authid current_user is

  Debug boolean := false;

  type Hash_Array_Varchar2 is table of Array_Varchar2 not null index by varchar2(30) not null;
  type Hash_Varchar2 is table of varchar2(32767) index by varchar2(30) not null;

  c_Num_Format constant varchar2(40) := '999999999999999999999D9999999999';
  c_Num_Char   constant varchar2(30) := 'NLS_NUMERIC_CHARACTERS=''. ''';

  c_Min_Date        constant date := to_date('01.01.1900', 'dd.mm.yyyy');
  c_Max_Date        constant date := to_date('31.12.9999', 'dd.mm.yyyy');
  c_Date_Format     constant varchar2(10) := 'dd.mm.yyyy';
  c_Datetime_Format constant varchar2(21) := 'dd.mm.yyyy hh24:mi:ss';

  Maxbufpagelen constant binary_integer := 16384;
  Minbufpagelen constant binary_integer := 4096;

  type Varchar2_Code_Aat is table of varchar2(4000) index by varchar2(100);
  type Varchar2_Id_Aat is table of varchar2(4000) index by binary_integer;
  type Number_Code_Aat is table of number index by varchar2(100);
  type Number_Id_Aat is table of number index by binary_integer;
  type Date_Code_Aat is table of date index by varchar2(100);
  type Date_Id_Aat is table of date index by binary_integer;
  type Boolean_Code_Aat is table of boolean index by varchar2(100);
  type Boolean_Id_Aat is table of boolean index by binary_integer;

  subtype Rowid_t is rowid;
  type Array_Rowid is table of rowid;

  User_Exception exception;
  pragma exception_init(User_Exception, -20000);
  c_User_Exception_Code constant number := -20000; -- User_Exception bilan bir xil kod, named-constant sifatida raise sitelarida ishlatish uchun

  Ora_Exception exception;
  pragma exception_init(Ora_Exception, -20999);

  Ora_Child_Record_Found     exception;
  Ora_Check_Violated         exception;
  Ora_Parent_Key_Not_Found   exception;
  Ora_Null_Column_Ins        exception;
  Ora_Null_Column_Upd        exception;
  Ora_Resource_Busy          exception;
  Ora_Value_Too_Large        exception;
  Ora_Number_Too_Large       exception;
  Ora_Numeric_Or_Value_Error exception;
  pragma exception_init(Ora_Child_Record_Found, -02292);
  pragma exception_init(Ora_Check_Violated, -02290);
  pragma exception_init(Ora_Parent_Key_Not_Found, -02291);
  pragma exception_init(Ora_Null_Column_Ins, -1400);
  pragma exception_init(Ora_Null_Column_Upd, -1407);
  pragma exception_init(Ora_Resource_Busy, -54);
  pragma exception_init(Ora_Value_Too_Large, -12899);
  pragma exception_init(Ora_Number_Too_Large, -01438);
  pragma exception_init(Ora_Numeric_Or_Value_Error, -6502);

  Procedure Set_Debug(i_Debug boolean);
  Function Debug_Yn return varchar2;

  Procedure Set_User;
  Procedure Check_User;

  Function Getformcode return number;
  Function Quotesql(i_Txt varchar2) return varchar2;
  Function Quotesesc(s varchar2) return varchar2;
  Function Quotesesc2(s varchar2) return varchar2;
  Function Quoteshtml(s varchar2) return varchar2;
  Function Executesql(Fieldname varchar2,
                      Viewname  varchar2,
                      Filter    varchar2,
                      Defvalue  varchar2 := null) return varchar2;
  Procedure Executesql(Fieldname varchar2,
                       Viewname  varchar2,
                       Filter    varchar2);
  Function Executestored(Objtype binary_integer, Sqlstmt varchar2)
    return varchar2;

  Procedure Execute_Procedure(i_Stmt      varchar2,
                              i_Par_Count number := 0,
                              i_P1        varchar2 := null,
                              i_P2        varchar2 := null,
                              i_P3        varchar2 := null,
                              i_P4        varchar2 := null,
                              i_P5        varchar2 := null,
                              i_P6        varchar2 := null,
                              i_P7        varchar2 := null,
                              i_P8        varchar2 := null,
                              i_P9        varchar2 := null,
                              i_P10       varchar2 := null,
                              i_P11       varchar2 := null,
                              i_P12       varchar2 := null,
                              i_P13       varchar2 := null,
                              i_P14       varchar2 := null,
                              i_P15       varchar2 := null,
                              i_P16       varchar2 := null);

  Function Execute_Function(i_Stmt      varchar2,
                            i_Par_Count number := 0,
                            i_P1        varchar2 := null,
                            i_P2        varchar2 := null,
                            i_P3        varchar2 := null,
                            i_P4        varchar2 := null,
                            i_P5        varchar2 := null,
                            i_P6        varchar2 := null,
                            i_P7        varchar2 := null,
                            i_P8        varchar2 := null,
                            i_P9        varchar2 := null,
                            i_P10       varchar2 := null,
                            i_P11       varchar2 := null,
                            i_P12       varchar2 := null,
                            i_P13       varchar2 := null,
                            i_P14       varchar2 := null,
                            i_P15       varchar2 := null,
                            i_P16       varchar2 := null) return varchar2;

  Function Execute_Stored(i_Stmt      varchar2,
                          i_Stmt_Type number,
                          i_Par_Count number := 0,
                          i_P1        varchar2 := null,
                          i_P2        varchar2 := null,
                          i_P3        varchar2 := null,
                          i_P4        varchar2 := null,
                          i_P5        varchar2 := null,
                          i_P6        varchar2 := null,
                          i_P7        varchar2 := null,
                          i_P8        varchar2 := null,
                          i_P9        varchar2 := null,
                          i_P10       varchar2 := null,
                          i_P11       varchar2 := null,
                          i_P12       varchar2 := null,
                          i_P13       varchar2 := null,
                          i_P14       varchar2 := null,
                          i_P15       varchar2 := null,
                          i_P16       varchar2 := null) return varchar2;

  Function Sql_Getfirst(Hasmoredata   out binary_integer,
                        Sql_Text      in varchar2,
                        Linedelimeter in varchar2 := null) return varchar2;
  Function Sql_Getfirst(Sql_Text      in varchar2,
                        Linedelimeter in varchar2 := null) return varchar2;
  Function Sql_Getfirst(Hasmoredata   out binary_integer,
                        Sql_Text      in varchar2,
                        Pagenumber    in binary_integer,
                        Linesperpage  in binary_integer,
                        Linedelimeter in varchar2 := null) return varchar2;
  Function Sql_Executefirst_Bind(Hasmoredata   out binary_integer,
                                 Sql_Text      in varchar2,
                                 Hasrownum     in boolean,
                                 Linedelimeter in varchar2,
                                 Bindname      in Array_Varchar2,
                                 Bindtype      in Array_Varchar2,
                                 Bindvalue     in Array_Varchar2)
    return varchar2;
  Function Sql_Getfirst_Ex(Sql_Text      in varchar2,
                           Linedelimeter in varchar2 := null) return varchar2;
  Function Sql_Getfirst_Ex(Sql_Text      in varchar2,
                           Pagenumber    in binary_integer,
                           Linesperpage  in binary_integer,
                           Linedelimeter in varchar2 := null) return varchar2;
  Function Sql_Getfirst_Ex_Bind(Sql_Text      in varchar2,
                                Pagenumber    in binary_integer,
                                Linesperpage  in binary_integer,
                                Linedelimeter in varchar2 := null,
                                Bindname      in Array_Varchar2,
                                Bindtype      in Array_Varchar2,
                                Bindvalue     in Array_Varchar2)
    return varchar2;
  Function Sql_Getnext(Hasmoredata out binary_integer) return varchar2;
  Function Sql_Getnext return varchar2;
  Function Sql_Getnext_Ex return varchar2;
  Function Sql_Getrowcount return binary_integer;
  Function Sql_Getsize return binary_integer;
  Function Sql_Hasmore return binary_integer;

  Function Dump(v varchar2) return varchar2;

  Function Qs(v varchar2) return varchar2;

  Function Qs(v number) return varchar2;

  Function Qs(v date) return varchar2;

  Function Qs(v Mlt_Name_t) return varchar2;

  Function Qs(v Mlt_Text_t) return varchar2;

  Function Qs(v Mlt_t) return varchar2;

  Function Qs(v Mlt_Label_t) return varchar2;

  Procedure Write_Separator(i_Out        in out nocopy clob,
                            i_Table_Name varchar2);

  Function Sql_Of_Records(i_Table_Name         varchar2,
                          i_Where_Clause       varchar2 := null,
                          i_Owner              varchar2 := null,
                          i_With_Update_Clause boolean := true) return clob;

  Procedure Trace_Text(i_User_Key varchar2, i_Text varchar2);

  Procedure Trace_Text(i_Text varchar2);

  Procedure Trace_Request(i_User_Key varchar2, Request Hashtable);

  Procedure Clear_Trace(i_User_Key varchar2);

  Function Get_Request(i_Id integer) return Hashtable;

  Function Module_Code(i_Object_Name varchar2) return varchar2;

  Function Remove_Ora(Message varchar2) return varchar2;

  Function Split(i_Val varchar2, i_Delimiter varchar2) return Array_Varchar2;

  Function Gather(i_Val Array_Varchar2, i_Delimiter varchar2) return varchar2;

  Function Gather(i_Val       Array_Number,
                  i_Delimiter varchar2,
                  i_Format    varchar2 := null) return varchar2;

  Function Gather(i_Val       Array_Date,
                  i_Delimiter varchar2,
                  i_Format    varchar2 := null) return varchar2;

  Function Equal(i_Val1 varchar2, i_Val2 varchar2) return boolean;

  Function Equal(i_Val1 number, i_Val2 number) return boolean;

  Function Equal(i_Val1 date, i_Val2 date) return boolean;

  Function Week_Day(i_Date date) return pls_integer;

  Function Read_Clob(i_Clob clob) return Array_Varchar2;

  Function Decode2(i_Value varchar2,
                   i_St1   varchar2,
                   i_Ans1  varchar2,
                   i_St2   varchar2,
                   i_Ans2  varchar2) return varchar2;

  Function Decode2(i_Value varchar2,
                   i_St1   varchar2,
                   i_Ans1  varchar2,
                   i_Ans2  varchar2) return varchar2;

  Function Decode2(i_Value varchar2, i_St1 varchar2, i_Ans1 varchar2)
    return varchar2;

  Function Decode2(i_Decode varchar2) return varchar2;

  Function Nvl2(i_Value varchar2, i_Ans1 varchar2, i_Ans2 varchar2)
    return varchar2;

  Function Cur_Nls(i_Label Mlt_Name_t, i_Lang_Index number) return varchar2;

  Function Cur_Nls(i_Label Mlt_Text_t, i_Lang_Index number) return varchar2;

  Function Has_Common_Bits(i_R1 raw, i_R2 raw) return number deterministic;

  Function Is_Bit_Set(i_R1 raw, i_Bit_Order pls_integer) return number;

  Function Is_Bit_Set_Yn(i_R1 raw, i_Bit_Order pls_integer) return varchar2;

  Function Is_Bit_Set(i_Bit_Set number, i_Bit_Order pls_integer)
    return number;

  Function Is_Bit_Set_Yn(i_Bit_Set number, i_Bit_Order pls_integer)
    return varchar2;

  Procedure Who_Called_Me(i_Cnt   number,
                          o_Owner out varchar2,
                          o_Name  out varchar2);

  Function Str(i_Value varchar2) return varchar2;

  Function Str(i_Value number) return varchar2;

  Function Str(i_Value date) return varchar2;

  Function Str(i_Value timestamp) return varchar2;

  Function Str(i_Value Array_Varchar2) return varchar2;

  Function Str(i_Value Array_Number) return varchar2;

  Function Str(i_Value Array_Date) return varchar2;

  Function Str(i_Value Mlt_Text_t) return varchar2;

  Function Str(i_Value Mlt_Label_t) return varchar2;

  Function Str(i_Value Mlt_Name_t) return varchar2;

  Function Str(i_Value blob) return varchar2;

  Function Str(i_Value clob) return varchar2;

  Procedure Fill_Col_Set(i_Col_Set in out nocopy Sql_Util.Number_Code_Aat,
                         i_f       varchar2);

  Function Is_Different(i_a number, i_b number) return boolean;

  Function Is_Different(i_a varchar2, i_b varchar2) return boolean;

  Function Is_Different(i_a date, i_b date) return boolean;

  Function Is_Different(i_a timestamp, i_b timestamp) return boolean;

  Function Is_Different(i_a Mlt_Name_t, i_b Mlt_Name_t) return boolean;

  Function Is_Different(i_a Mlt_Text_t, i_b Mlt_Text_t) return boolean;

  Function Is_Different(i_a Mlt_Label_t, i_b Mlt_Label_t) return boolean;

  Function Is_Different(i_a blob, i_b blob) return boolean;

  Function Is_Different(i_a Xmltype, i_b Xmltype) return boolean;
end Sql_Util;
/
create or replace package body Sql_Util is

  type Resultbuffer is table of varchar2(32767);

  Resultbuf      Resultbuffer := Resultbuffer('');
  Bufpagelen     binary_integer := Maxbufpagelen;
  Resultlength   binary_integer := 0;
  Resultrowcount binary_integer := 0;
  Selectedindex  binary_integer := 1;

  Field_Type_Text        constant pls_integer := 0;
  Field_Type_Quote       constant pls_integer := 1;
  Field_Type_Date        constant pls_integer := 2;
  Field_Type_Number      constant pls_integer := 3;
  Field_Type_Sum         constant pls_integer := 4;
  Field_Type_Sum2        constant pls_integer := 5;
  Field_Type_Datetime    constant pls_integer := 6;
  Field_Type_Time        constant pls_integer := 7;
  Field_Type_Notsend     constant pls_integer := 8;
  Field_Type_Free_Format constant pls_integer := 9;
  Field_Type_Integer     constant pls_integer := 10;
  Field_Type_Sum100      constant pls_integer := 11;
  Filter_Type_Single     constant pls_integer := 1;

  Filter_Type_Range  constant pls_integer := 2;
  Filter_Type_Choice constant pls_integer := 3;

  Procedure Set_Debug(i_Debug boolean) is
  begin
    Debug := i_Debug;
  end Set_Debug;

  Function Debug_Yn return varchar2 is
  begin
    if Debug then
      return 'Y';
    else
      return 'N';
    end if;
  end Debug_Yn;

  Procedure Set_User is
  begin
    return;
  end Set_User;

  Procedure Check_User is
    v_Curr_Emp_Code     number := User_Env.Get_User_Id;
    v_Logged_Emp_Code   number := User_Env.Get_User_Id;
    v_Logged_Local_Code varchar2(5) := User_Env.Get_Local_Code;
  begin
    null;
  end Check_User;

  Function Executestored(Objtype binary_integer, Sqlstmt varchar2)
    return varchar2 is
    result          varchar2(32767);
    v_Handle        pls_integer;
    v_Employee_Code number(6) := User_Env.Get_User_Id;
    v_Gen_Error_Msg varchar2(2000) := null;
  
  begin
  
    if Objtype = 0 then
      execute immediate 'begin ' || Sqlstmt || ';end;';
      Check_User;
      return null;
    end if;
    execute immediate 'begin :R := ' || Sqlstmt || '; end;'
      using out result;
    Check_User;
    return result;
  
  exception
    when others then
    
      Check_User;
      v_Gen_Error_Msg := Chr(13) || (case
                                       when Sql_Util.Debug_Yn = 'Y' then
                                        Sqlstmt || Chr(13)
                                       else
                                        ''
                                     end) || sqlcode || ' ' ||
                         Substr(sqlerrm, 1, 3000);
      Raise_Application_Error(c_User_Exception_Code, v_Gen_Error_Msg || Sqlstmt);
  end Executestored;

  Procedure Execute_Procedure(i_Stmt      varchar2,
                              i_Par_Count number := 0,
                              i_P1        varchar2 := null,
                              i_P2        varchar2 := null,
                              i_P3        varchar2 := null,
                              i_P4        varchar2 := null,
                              i_P5        varchar2 := null,
                              i_P6        varchar2 := null,
                              i_P7        varchar2 := null,
                              i_P8        varchar2 := null,
                              i_P9        varchar2 := null,
                              i_P10       varchar2 := null,
                              i_P11       varchar2 := null,
                              i_P12       varchar2 := null,
                              i_P13       varchar2 := null,
                              i_P14       varchar2 := null,
                              i_P15       varchar2 := null,
                              i_P16       varchar2 := null) is
    v_Stmt varchar2(32767) := 'begin ' || i_Stmt || '; end;';
  begin
    case i_Par_Count
      when 0 then
        execute immediate v_Stmt;
      when 1 then
        execute immediate v_Stmt
          using i_P1;
      when 2 then
        execute immediate v_Stmt
          using i_P1, i_P2;
      when 3 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3;
      when 4 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4;
      when 5 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5;
      when 6 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6;
      when 7 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7;
      when 8 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8;
      when 9 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9;
      when 10 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10;
      when 11 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11;
      when 12 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12;
      when 13 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12, i_P13;
      when 14 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12, i_P13, i_P14;
      when 15 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12, i_P13, i_P14, i_P15;
      when 16 then
        execute immediate v_Stmt
          using i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12, i_P13, i_P14, i_P15, i_P16;
    end case;
  end Execute_Procedure;

  Function Execute_Function(i_Stmt      varchar2,
                            i_Par_Count number := 0,
                            i_P1        varchar2 := null,
                            i_P2        varchar2 := null,
                            i_P3        varchar2 := null,
                            i_P4        varchar2 := null,
                            i_P5        varchar2 := null,
                            i_P6        varchar2 := null,
                            i_P7        varchar2 := null,
                            i_P8        varchar2 := null,
                            i_P9        varchar2 := null,
                            i_P10       varchar2 := null,
                            i_P11       varchar2 := null,
                            i_P12       varchar2 := null,
                            i_P13       varchar2 := null,
                            i_P14       varchar2 := null,
                            i_P15       varchar2 := null,
                            i_P16       varchar2 := null) return varchar2 is
    v_Result varchar2(32767);
    v_Stmt   varchar2(32767) := 'begin :R := ' || i_Stmt || '; end;';
  begin
  
    case i_Par_Count
      when 0 then
        execute immediate v_Stmt
          using out v_Result;
      when 1 then
        execute immediate v_Stmt
          using out v_Result, i_P1;
      when 2 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2;
      when 3 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3;
      when 4 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4;
      when 5 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5;
      when 6 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6;
      when 7 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7;
      when 8 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8;
      when 9 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9;
      when 10 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10;
      when 11 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11;
      when 12 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12;
      when 13 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12, i_P13;
      when 14 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12, i_P13, i_P14;
      when 15 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12, i_P13, i_P14, i_P15;
      when 16 then
        execute immediate v_Stmt
          using out v_Result, i_P1, i_P2, i_P3, i_P4, i_P5, i_P6, i_P7, i_P8, i_P9, i_P10, i_P11, i_P12, i_P13, i_P14, i_P15, i_P16;
    end case;
  
    return v_Result;
  end Execute_Function;

  Function Execute_Stored(i_Stmt      varchar2,
                          i_Stmt_Type number,
                          i_Par_Count number := 0,
                          i_P1        varchar2 := null,
                          i_P2        varchar2 := null,
                          i_P3        varchar2 := null,
                          i_P4        varchar2 := null,
                          i_P5        varchar2 := null,
                          i_P6        varchar2 := null,
                          i_P7        varchar2 := null,
                          i_P8        varchar2 := null,
                          i_P9        varchar2 := null,
                          i_P10       varchar2 := null,
                          i_P11       varchar2 := null,
                          i_P12       varchar2 := null,
                          i_P13       varchar2 := null,
                          i_P14       varchar2 := null,
                          i_P15       varchar2 := null,
                          i_P16       varchar2 := null) return varchar2 is
  begin
  
    if i_Stmt_Type = 0 then
    
      Execute_Procedure(i_Stmt,
                        i_Par_Count,
                        i_P1,
                        i_P2,
                        i_P3,
                        i_P4,
                        i_P5,
                        i_P6,
                        i_P7,
                        i_P8,
                        i_P9,
                        i_P10,
                        i_P11,
                        i_P12,
                        i_P13,
                        i_P14,
                        i_P15,
                        i_P16);
    
      return null;
    else
    
      return Execute_Function(i_Stmt,
                              i_Par_Count,
                              i_P1,
                              i_P2,
                              i_P3,
                              i_P4,
                              i_P5,
                              i_P6,
                              i_P7,
                              i_P8,
                              i_P9,
                              i_P10,
                              i_P11,
                              i_P12,
                              i_P13,
                              i_P14,
                              i_P15,
                              i_P16);
    end if;
  end Execute_Stored;

  Function Getformcode return number is
  begin
    return 0;
  end Getformcode;

  Function Quotesql(i_Txt varchar2) return varchar2 is
  begin
    return replace(replace(replace(i_Txt, Chr(10), '''||chr(10)||'''),
                           Chr(13),
                           '''||chr(13)||'''),
                   '''',
                   '''''');
  end;

  Function Quotesesc(s varchar2) return varchar2 is
  begin
    return replace(replace(replace(replace(replace(s, '\', '\\'),
                                           '''',
                                           '\'''),
                                   '"',
                                   '\"'),
                           Chr(10),
                           '\n'),
                   Chr(13),
                   '\r');
  end Quotesesc;

  Function Quotesesc2(s varchar2) return varchar2 is
  begin
    return replace(replace(replace(replace(s, '\', '\\'), '''', '\'''),
                           Chr(10),
                           '\n'),
                   Chr(13),
                   '\r');
  end Quotesesc2;

  Function Quoteshtml(s varchar2) return varchar2 is
  begin
    return replace(replace(replace(replace(replace(replace(replace(s,
                                                                   '\',
                                                                   '&#92;'),
                                                           '''',
                                                           '&#39;'),
                                                   '"',
                                                   '&quot;'),
                                           '<',
                                           '&lt;'),
                                   '>',
                                   '&gt;'),
                           Chr(10),
                           '&#10;'),
                   Chr(13),
                   '&#13;');
  end Quoteshtml;

  Procedure Resultbuf_First is
  begin
    Selectedindex := 1;
  end Resultbuf_First;

  Procedure Resultbuf_Init is
  begin
    if Resultbuf.Count > 1 then
      Resultbuf := null;
      Dbms_Session.Free_Unused_User_Memory;
      Resultbuf := Resultbuffer('');
    end if;
    Resultlength   := 0;
    Resultrowcount := 0;
    Resultbuf_First;
    Resultbuf(Selectedindex) := '';
  end Resultbuf_Init;

  Function Resultbuf_Get return varchar2 is
  begin
    if Selectedindex > Resultbuf.Count then
      return null;
    end if;
    Selectedindex := Selectedindex + 1;
    return Resultbuf(Selectedindex - 1);
  end Resultbuf_Get;

  Function Resultbuf_Hasmore return boolean is
  begin
    return(Selectedindex <= Resultbuf.Count);
  end Resultbuf_Hasmore;

  Procedure Resultbuf_Put(Val varchar2) is
    Valuelen      binary_integer := Nvl(Length(Val), 0);
    Selectedvalue varchar2(32767) := Resultbuf(Selectedindex);
  begin
    if (Nvl(Length(Selectedvalue), 0) + Valuelen) > Bufpagelen then
      Resultbuf.Extend;
      Selectedindex := Selectedindex + 1;
      Selectedvalue := '';
    end if;
    Resultbuf(Selectedindex) := Selectedvalue || Val;
    Resultlength := Resultlength + Valuelen;
  end Resultbuf_Put;

  Function Executesql(Fieldname varchar2,
                      Viewname  varchar2,
                      Filter    varchar2,
                      Defvalue  varchar2 := null) return varchar2 is
    Dsql   varchar2(32767) := 'select ' || Fieldname || ' from ' ||
                              Viewname || ' where ' || Filter;
    result varchar2(32767);
  begin
    execute immediate Dsql
      into result;
    return result;
  exception
    when No_Data_Found then
      if Defvalue is null then
        raise;
      end if;
      return Defvalue;
  end Executesql;

  Procedure Executesql(Fieldname varchar2,
                       Viewname  varchar2,
                       Filter    varchar2) is
    Dummy varchar2(32767);
  begin
    Dummy := Executesql(Fieldname, Viewname, Filter);
  end Executesql;

  Function Sql_Executefirst(Hasmoredata   out binary_integer,
                            Sql_Text      in varchar2,
                            Hasrownum     in boolean,
                            Linedelimeter in varchar2) return varchar2 is
    type Refcursor is ref cursor;
    Curs      Refcursor;
    Buf       varchar2(32767);
    Buf_List  Array_Varchar2;
    Rnum_List Array_Number;
    v_Handle  pls_integer;
  begin
  
    Resultbuf_Init;
    open Curs for Sql_Text;
    loop
      if Hasrownum then
        fetch Curs bulk collect
          into Buf_List, Rnum_List limit 500;
      else
        fetch Curs bulk collect
          into Buf_List limit 500;
      end if;
    
      exit when Buf_List.Count = 0;
    
      for i in Buf_List.First .. Buf_List.Last loop
        if (i > 1 or Resultlength > 0) and Linedelimeter is not null then
          Resultbuf_Put(Linedelimeter || Buf_List(i));
        else
          Resultbuf_Put(Buf_List(i));
        end if;
      end loop;
      Resultrowcount := Resultrowcount + Buf_List.Count;
    end loop;
    close Curs;
    Resultbuf_First;
    Buf         := Resultbuf_Get;
    Hasmoredata := Sql_Hasmore;
  
    return Buf;
  end Sql_Executefirst;

  Function Sql_Executefirst_Bind(Hasmoredata   out binary_integer,
                                 Sql_Text      in varchar2,
                                 Hasrownum     in boolean,
                                 Linedelimeter in varchar2,
                                 Bindname      in Array_Varchar2,
                                 Bindtype      in Array_Varchar2,
                                 Bindvalue     in Array_Varchar2)
    return varchar2 is
    type Refcursor is ref cursor;
    Curs        Refcursor;
    Buf         varchar2(32767);
    Rnum        pls_integer;
    Cursorid    number;
    d           number;
    Curvaluen   number := 0;
    Curbindtype number := 0;
    Buf_List    Array_Varchar2;
    Rnum_List   Array_Number;
    v_Handle    pls_integer;
  begin
  
    Resultbuf_Init;
    Cursorid := Dbms_Sql.Open_Cursor;
    Dbms_Sql.Parse(Cursorid, Sql_Text, Dbms_Sql.Native);
    for i in 1 .. Bindname.Count loop
      if Bindtype(i) = Field_Type_Number then
      
        Curvaluen := to_number(Bindvalue(i), '99999999999999999999990.90');
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               to_number(Bindvalue(i),
                                         '99999999999999999999990.90'));
      elsif Bindtype(i) = Field_Type_Integer then
      
        Curvaluen := to_number(Bindvalue(i), '99999999999999999999990');
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               to_number(Bindvalue(i),
                                         '99999999999999999999990'));
      elsif Bindtype(i) = Field_Type_Sum then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               to_number(Bindvalue(i)));
      elsif Bindtype(i) = Field_Type_Sum2 then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               to_number(Bindvalue(i)));
      elsif Bindtype(i) = Field_Type_Sum100 then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               to_number(Bindvalue(i)) * 100);
      elsif Bindtype(i) = Field_Type_Text then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               trim(Bindvalue(i)));
      elsif Bindtype(i) = Field_Type_Quote then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               trim(Bindvalue(i)));
      elsif Bindtype(i) = Field_Type_Date then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               to_date(trim(Bindvalue(i)), 'dd.mm.yyyy'));
      elsif Bindtype(i) = Field_Type_Datetime then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               to_date(trim(Bindvalue(i)),
                                       'dd.mm.yyyy hh24:mi:ss'));
      elsif Bindtype(i) = Field_Type_Time then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               to_date(trim(Bindvalue(i)), 'hh24:mi:ss'));
      elsif Bindtype(i) = Field_Type_Free_Format then
      
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               trim(Bindvalue(i)));
      elsif Bindtype(i) = Field_Type_Notsend then
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               trim(Bindvalue(i)));
      else
        Dbms_Sql.Bind_Variable(Cursorid,
                               ':' || Bindname(i),
                               trim(Bindvalue(i)));
      end if;
    end loop;
    d    := Dbms_Sql.Execute(c => Cursorid);
    Curs := Dbms_Sql.To_Refcursor(Cursor_Number => Cursorid);
  
    loop
      if Hasrownum then
        fetch Curs bulk collect
          into Buf_List, Rnum_List limit 500;
      else
        fetch Curs bulk collect
          into Buf_List limit 500;
      end if;
    
      exit when Buf_List.Count = 0;
    
      for i in Buf_List.First .. Buf_List.Last loop
        if (i > 1 or Resultlength > 0) and Linedelimeter is not null then
          Resultbuf_Put(Linedelimeter || Buf_List(i));
        else
          Resultbuf_Put(Buf_List(i));
        end if;
      end loop;
      Resultrowcount := Resultrowcount + Buf_List.Count;
    end loop;
    close Curs;
    Resultbuf_First;
    Buf         := Resultbuf_Get;
    Hasmoredata := Sql_Hasmore;
  
    return Buf;
  end Sql_Executefirst_Bind;

  Function Sql_Getfirst(Hasmoredata   out binary_integer,
                        Sql_Text      in varchar2,
                        Linedelimeter in varchar2 := null) return varchar2 is
  begin
    return Sql_Executefirst(Hasmoredata, Sql_Text, false, Linedelimeter);
  end Sql_Getfirst;

  Function Sql_Getfirst(Sql_Text      in varchar2,
                        Linedelimeter in varchar2 := null) return varchar2 is
    Hasmoredata binary_integer;
  begin
    return Sql_Getfirst(Hasmoredata, Sql_Text, Linedelimeter);
  end Sql_Getfirst;

  Function Sql_Getfirst(Hasmoredata   out binary_integer,
                        Sql_Text      in varchar2,
                        Pagenumber    in binary_integer,
                        Linesperpage  in binary_integer,
                        Linedelimeter in varchar2 := null) return varchar2 is
    Dsql varchar2(32767);
  begin
    Dsql := 'select * from (select p.*, RowNum RNum from ( ' || Sql_Text ||
            ') p where RowNum <= ' || + (Linesperpage * Pagenumber) ||
            ') where RNum > ' || (Linesperpage * (Pagenumber - 1));
    return Sql_Executefirst(Hasmoredata, Dsql, true, Linedelimeter);
  end Sql_Getfirst;

  Function Sql_Getfirst_Ex(Sql_Text      in varchar2,
                           Linedelimeter in varchar2 := null) return varchar2 is
    Hasmore binary_integer;
    result  varchar2(32767);
  begin
    result := Sql_Getfirst(Hasmore, Sql_Text, Linedelimeter);
    return to_char(Hasmore) || '@' || result;
  end Sql_Getfirst_Ex;

  Function Sql_Getfirst_Ex(Sql_Text      in varchar2,
                           Pagenumber    in binary_integer,
                           Linesperpage  in binary_integer,
                           Linedelimeter in varchar2 := null) return varchar2 is
    Hasmore binary_integer;
    result  varchar2(32767);
  begin
    result := Sql_Getfirst(Hasmore,
                           Sql_Text,
                           Pagenumber,
                           Linesperpage,
                           Linedelimeter);
    return to_char(Hasmore) || '@' || result;
  end Sql_Getfirst_Ex;

  Function Sql_Getfirst_Ex_Bind(Sql_Text      in varchar2,
                                Pagenumber    in binary_integer,
                                Linesperpage  in binary_integer,
                                Linedelimeter in varchar2 := null,
                                Bindname      in Array_Varchar2,
                                Bindtype      in Array_Varchar2,
                                Bindvalue     in Array_Varchar2)
    return varchar2 is
    Hasmore binary_integer;
    result  varchar2(32767);
    Dsql    varchar2(32767);
    Vstr    varchar2(32767);
  begin
    Vstr := 'SqlText = ' || Sql_Text;
    Vstr := Vstr || ' BindName = ';
    for i in 1 .. Bindname.Count loop
      Vstr := Vstr || Bindname(i) || '~';
    end loop;
    Vstr := Vstr || ' BindType = ';
    for i in 1 .. Bindtype.Count loop
      Vstr := Vstr || Bindtype(i) || '~';
    end loop;
    Vstr := Vstr || ' BindValue = ';
    for i in 1 .. Bindvalue.Count loop
      Vstr := Vstr || Bindvalue(i) || '~';
    end loop;
    if Pagenumber > 0 and Linesperpage > 0 then
      Dsql   := 'select * from (select p.*, RowNum RNum from ( ' ||
                Sql_Text || ') p where RowNum <= ' || +
                (Linesperpage * Pagenumber) || ') where RNum > ' ||
                (Linesperpage * (Pagenumber - 1));
      result := Sql_Executefirst_Bind(Hasmore,
                                      Dsql,
                                      true,
                                      Linedelimeter,
                                      Bindname,
                                      Bindtype,
                                      Bindvalue);
    else
      result := Sql_Executefirst_Bind(Hasmore,
                                      Sql_Text,
                                      false,
                                      Linedelimeter,
                                      Bindname,
                                      Bindtype,
                                      Bindvalue);
    end if;
    return to_char(Hasmore) || '@' || result;
  exception
    when others then
      Raise_Application_Error(c_User_Exception_Code,
                              'DSql=' || Dsql || Vstr || ' PN=' ||
                              Pagenumber || ' LPP=' || Linesperpage ||
                              ' -- ' || sqlerrm);
  end Sql_Getfirst_Ex_Bind;

  Function Sql_Getnext(Hasmoredata out binary_integer) return varchar2 is
    result varchar2(32767) := Resultbuf_Get;
  begin
    Hasmoredata := Sql_Hasmore;
    if Hasmoredata <= 0 then
      Resultbuf_Init;
    end if;
    return result;
  end Sql_Getnext;

  Function Sql_Getnext return varchar2 is
    Hasmoredata binary_integer;
  begin
    return Sql_Getnext(Hasmoredata);
  end Sql_Getnext;

  Function Sql_Getnext_Ex return varchar2 is
    Hasmore binary_integer;
    result  varchar2(32767);
  begin
    result := Sql_Getnext(Hasmore);
    return to_char(Hasmore) || '@' || result;
  end Sql_Getnext_Ex;

  Function Sql_Getrowcount return binary_integer is
  begin
    return Resultrowcount;
  end Sql_Getrowcount;

  Function Sql_Getsize return binary_integer is
  begin
    return Resultlength;
  end Sql_Getsize;

  Function Sql_Hasmore return binary_integer is
  begin
    return(Resultbuf.Count - Selectedindex + 1);
  end Sql_Hasmore;

  Function Dump(v varchar2) return varchar2 is
    result varchar2(32767);
  begin
    select Dump(v) into result from Dual;
    return result;
  end Dump;

  Function Qs(v varchar2) return varchar2 is
  begin
    return '''' || replace(replace(replace(v, Chr(10), '''||chr(10)||'''),
                                   Chr(13),
                                   '''||chr(13)||'''),
                           '''',
                           '''''') || '''';
  end Qs;

  Function Qs(v number) return varchar2 is
  begin
    return Qs(to_char(v));
  end Qs;

  Function Qs(v date) return varchar2 is
    f varchar2(100) := 'yyyymmddhh24miss';
  begin
    return 'to_date(''' || to_char(v, f) || ''',''' || f || ''')';
  end Qs;

  Function Qs(v Mlt_Name_t) return varchar2 is
    r varchar2(2000);
  begin
    if v is null then
      return 'null';
    end if;
    r := 'Ml_Name_t(';
    for i in 1 .. v.Count loop
      if i <> v.Count then
        r := r || Qs(v(i)) || ',';
      else
        r := r || Qs(v(i));
      end if;
    end loop;
    r := r || ')';
    return r;
  end Qs;

  Function Qs(v Mlt_Text_t) return varchar2 is
    r varchar2(2000);
  begin
    if v is null then
      return 'null';
    end if;
    r := 'Ml_Text_t(';
    for i in 1 .. v.Count loop
      if i <> v.Count then
        r := r || Qs(v(i)) || ',';
      else
        r := r || Qs(v(i));
      end if;
    end loop;
    r := r || ')';
    return r;
  end Qs;

  Function Qs(v Mlt_t) return varchar2 is
    r varchar2(2000);
  begin
    if v is null then
      return 'null';
    end if;
    r := 'MLM_T(';
    for i in 1 .. v.Count loop
      if i <> v.Count then
        r := r || Qs(v(i)) || ',';
      else
        r := r || Qs(v(i));
      end if;
    end loop;
    r := r || ')';
    return r;
  end Qs;

  Function Qs(v Mlt_Label_t) return varchar2 is
    r varchar2(2000);
  begin
    if v is null then
      return 'null';
    end if;
    r := 'Ml_Label_t(';
    for i in 1 .. v.Count loop
      if i <> v.Count then
        r := r || Qs(v(i)) || ',';
      else
        r := r || Qs(v(i));
      end if;
    end loop;
    r := r || ')';
    return r;
  end Qs;

  Procedure Write_Separator(i_Out        in out nocopy clob,
                            i_Table_Name varchar2) is
  begin
    Dbms_Lob.Writeappend(i_Out,
                         Nvl(Length(i_Table_Name), 0) + 62,
                         Lpad('-', 10, '-') || i_Table_Name ||
                         Lpad('-', 50, '-') || Chr(13) || Chr(10));
  end Write_Separator;

  Procedure Sql_Of_Records(i_Table_Name         varchar2,
                           i_Where_Clause       varchar2 := null,
                           i_Out                in out nocopy clob,
                           i_Owner              varchar2 := null,
                           i_With_Update_Clause boolean := true) is
    v_Owner       varchar2(30) := Upper(Nvl(i_Owner,
                                            Sys_Context('USERENV',
                                                        'CURRENT_SCHEMA')));
    v_Table_Name  varchar2(30) := Upper(i_Table_Name);
    v_Sql         varchar2(4000);
    v_Sql_Insert  varchar2(4000);
    v_Sql_Insert1 varchar2(4000);
    v_Sql_Insert2 varchar2(4000);
    v_Sql_Update  varchar2(4000);
    v_Sql_Update1 varchar2(4000);
    v_Sql_Update2 varchar2(4000);
    v_Columns     Array_Varchar2;
    v_Col_Types   Array_Varchar2;
    v_Pk_Name     varchar2(30);
    v_Pk_Columns  Array_Varchar2;
    k             pls_integer;
    Curs          sys_refcursor;
    Tmp           varchar2(32767);
  begin
  
    select t.Column_Name, t.Data_Type
      bulk collect
      into v_Columns, v_Col_Types
      from All_Tab_Columns t
     where t.Owner = v_Owner
       and t.Table_Name = v_Table_Name
     order by t.Column_Id;
  
    begin
      select t.Constraint_Name
        into v_Pk_Name
        from All_Constraints t
       where t.Owner = v_Owner
         and t.Table_Name = v_Table_Name
         and t.Constraint_Type = 'P';
    
      select t.Column_Name
        bulk collect
        into v_Pk_Columns
        from All_Cons_Columns t
       where t.Owner = v_Owner
         and t.Constraint_Name = v_Pk_Name
       order by t.Position;
    exception
      when No_Data_Found then
        v_Pk_Columns := Array_Varchar2();
    end;
  
    k := 0;
    for i in 1 .. v_Columns.Count loop
    
      v_Sql_Insert1 := v_Sql_Insert1 || v_Columns(i);
      v_Sql_Insert2 := v_Sql_Insert2 || 'core.sql_util.qs(' || v_Columns(i) || ')';
      if i <> v_Columns.Count then
        v_Sql_Insert1 := v_Sql_Insert1 || ',';
        v_Sql_Insert2 := v_Sql_Insert2 || '||'',''||';
      end if;
    
      if v_Columns(i) member of v_Pk_Columns then
        k             := k + 1;
        v_Sql_Update2 := v_Sql_Update2 || '''' || v_Columns(i) || '=''||' ||
                         'core.sql_util.qs(' || v_Columns(i) || ')';
        if k < v_Pk_Columns.Count then
          v_Sql_Update2 := v_Sql_Update2 || '||'' and ''||';
        end if;
      else
        v_Sql_Update1 := v_Sql_Update1 || '''' || v_Columns(i) || '=''||' ||
                         'core.sql_util.qs(' || v_Columns(i) || ')';
        if i <> v_Columns.Count then
          v_Sql_Update1 := v_Sql_Update1 || '||'',''||';
        end if;
      end if;
    
    end loop;
  
    v_Sql_Insert := '''INSERT INTO ' || v_Table_Name || '(' ||
                    v_Sql_Insert1 || ') VALUES(''||' || v_Sql_Insert2 ||
                    '||'');''';
    if v_Pk_Columns.Count <> 0 then
      v_Sql_Update := '''UPDATE ' || v_Table_Name || ' SET ''||' ||
                      v_Sql_Update1 || '||'' WHERE ''||' || v_Sql_Update2 ||
                      '||'';''';
    else
      v_Sql_Update := '''''';
    end if;
    v_Sql := 'SELECT ' || v_Sql_Insert || '||chr(13)||chr(10)';
    if i_With_Update_Clause then
      v_Sql := v_Sql || '||' || v_Sql_Update || '||chr(13)||chr(10)';
    end if;
    v_Sql := v_Sql || ' FROM ' || v_Table_Name;
    if i_Where_Clause is not null then
      v_Sql := v_Sql || ' WHERE ' || i_Where_Clause;
    end if;
  
    if Debug then
      Htp.Print('<p><code>');
      Htp.Print(v_Sql);
      Htp.Print('</code></p>');
    end if;
  
    open Curs for v_Sql;
    loop
      fetch Curs
        into Tmp;
      if Curs%notfound then
        exit;
      end if;
      Dbms_Lob.Writeappend(i_Out, Length(Tmp), Tmp);
    end loop;
  
  end Sql_Of_Records;

  Function Sql_Of_Records(i_Table_Name         varchar2,
                          i_Where_Clause       varchar2 := null,
                          i_Owner              varchar2 := null,
                          i_With_Update_Clause boolean := true) return clob is
    result clob;
  begin
    Dbms_Lob.Createtemporary(result, false);
    Dbms_Lob.Open(result, Dbms_Lob.Lob_Readwrite);
    Sql_Of_Records(i_Table_Name,
                   i_Where_Clause,
                   result,
                   i_Owner,
                   i_With_Update_Clause);
    Dbms_Lob.Close(result);
    return result;
  end Sql_Of_Records;

  Procedure Trace_Debug(i_User_Key varchar2,
                        i_Text     varchar2,
                        Request    Hashtable,
                        i_Rec_Sql  varchar2,
                        i_Rec_Form varchar2) is
    pragma autonomous_transaction;
    v_Id   integer;
    v_Text varchar2(4000);
  begin
  
    insert into Sql_Debug
      (Id,
       User_Key,
       Text,
       Request,
       Test_Sql,
       Rec_Sql,
       Rec_Form,
       Call_Stack,
       Error_Stack,
       Created_On)
    values
      (Sql_Debug_Sq.Nextval,
       i_User_Key,
       i_Text,
       Request,
       '',
       Substr(i_Rec_Sql, 1, 3990),
       Substr(i_Rec_Form, 1, 3990),
       Dbms_Utility.Format_Call_Stack,
       Dbms_Utility.Format_Error_Backtrace,
       sysdate) return Id into v_Id;
    if Request is not null then
      update Sql_Debug t
         set t.Test_Sql = 'Sql_Util.Get_Request(' || v_Id ||
                          ').Print_To_Htp;'
       where t.Id = v_Id;
    end if;
  
    commit;
  exception
    when others then
      rollback;
      v_Text := sqlerrm;
    
      insert into Sql_Debug
        (Id, User_Key, Text)
      values
        (Sql_Debug_Sq.Nextval, i_User_Key, v_Text);
      commit;
    
  end Trace_Debug;

  Procedure Trace_Text(i_User_Key varchar2, i_Text varchar2) is
  begin
    /*if Event.Get_Event_Global(36) = 'Y' then
      Trace_Debug(i_User_Key, i_Text, null, null, null);
    end if;*/
    null;
  end;

  Procedure Trace_Text(i_Text varchar2) is
    v_Caller_Name   varchar2(30);
    v_Caller_Owner  varchar2(30);
    v_Caller_Lineno number;
    v_Caller_Type   varchar2(30);
  begin
    Owa_Util.Who_Called_Me(v_Caller_Owner,
                           v_Caller_Name,
                           v_Caller_Lineno,
                           v_Caller_Type);
    Trace_Debug(Nvl(Module_Code(v_Caller_Name), 'TEST'),
                i_Text,
                null,
                null,
                null);
  end;

  Procedure Trace_Request(i_User_Key varchar2, Request Hashtable) is
    v_Bucket Hash_Bucket;
    v_Sql    varchar2(32767);
    v_Form   varchar2(32767);
    v_Sql2   varchar2(2000);
    v_Form2  varchar2(2000);
  begin
    v_Bucket := Request.Get_Bucket;
    for i in 1 .. v_Bucket.Count loop
      v_Sql2  := 'v_rec.' || v_Bucket(i).Key ||
                 ' := request.get_varchar2(''' || v_Bucket(i).Key || ''');' ||
                 Chr(13) || Chr(10);
      v_Form2 := 'v_form.put(''' || v_Bucket(i).Key || ''', v_rec.' || v_Bucket(i).Key || ');' ||
                 Chr(13) || Chr(10);
      if Length(v_Sql) + Length(v_Sql2) > 1000 then
        exit;
      else
        v_Sql := v_Sql || v_Sql2;
      end if;
      if Length(v_Form) + Length(v_Sql2) > 1000 then
        exit;
      else
        v_Form := v_Form || v_Form2;
      end if;
    end loop;
    Trace_Debug(i_User_Key, null, Request, v_Sql, v_Form);
  end Trace_Request;

  Procedure Clear_Trace(i_User_Key varchar2) is
    pragma autonomous_transaction;
  begin
    delete from Sql_Debug t where t.User_Key = i_User_Key;
    commit;
  exception
    when others then
      rollback;
  end Clear_Trace;

  Function Get_Request(i_Id integer) return Hashtable is
    Request Hashtable;
  begin
    select t.Request into Request from Sql_Debug t where t.Id = i_Id;
    return Request;
  end Get_Request;

  Function Module_Code(i_Object_Name varchar2) return varchar2 is
    v_Pos         pls_integer;
    v_Object_Name varchar2(30) := Upper(i_Object_Name);
  begin
    v_Pos := Instr(v_Object_Name, '_');
    if v_Pos > 0 then
      return Substr(v_Object_Name, 1, v_Pos - 1);
    end if;
    return v_Object_Name;
  exception
    when others then
      return v_Object_Name;
  end Module_Code;

  Function Remove_Ora(Message varchar2) return varchar2 is
    v_Msg      varchar2(4000) := Message;
    v_Err_Code varchar2(10);
    y          pls_integer;
    Txy        varchar2(2000);
    result     varchar2(4000);
  begin
    while Instr(v_Msg, 'ORA-') != 0 loop
      v_Err_Code := Substr(v_Msg, 1, 10);
      v_Msg      := Substr(v_Msg, 12);
      y          := Instr(v_Msg, 'ORA-');
      if y > 0 then
        Txy   := Substr(v_Msg, 1, y - 1) || Chr(13);
        v_Msg := Substr(v_Msg, y);
        if (Instr(v_Err_Code, 'ORA-20') > 0) then
          result := result || Txy;
        end if;
      else
        result := result || v_Msg;
      end if;
    end loop;
    return Nvl(result, v_Msg);
  end Remove_Ora;

  Function Split(i_Val varchar2, i_Delimiter varchar2) return Array_Varchar2 is
    v_Pos      pls_integer := 1;
    v_Last_Pos pls_integer := 1;
    result     Array_Varchar2 := Array_Varchar2();
  begin
    if i_Val is null then
      return result;
    end if;
  
    loop
      v_Pos := Instr(i_Val, i_Delimiter, v_Last_Pos);
    
      Result.Extend;
    
      if v_Pos > 0 then
        result(Result.Count) := Substr(i_Val,
                                       v_Last_Pos,
                                       v_Pos - v_Last_Pos);
      else
        result(Result.Count) := Substr(i_Val, v_Last_Pos);
        exit;
      end if;
    
      v_Last_Pos := v_Pos + Length(i_Delimiter);
    
    end loop;
    return result;
  end;

  Function Gather(i_Val Array_Varchar2, i_Delimiter varchar2) return varchar2 is
    result varchar2(32767);
  begin
  
    if i_Val is null then
      return '';
    end if;
  
    for i in 1 .. i_Val.Count loop
      result := result || i_Val(i);
      if i <> i_Val.Count then
        result := result || i_Delimiter;
      end if;
    end loop;
  
    return result;
  end;

  Function Gather(i_Val       Array_Number,
                  i_Delimiter varchar2,
                  i_Format    varchar2 := null) return varchar2 is
    v_Format varchar2(50) := Nvl(i_Format, 'TM9');
    result   varchar2(32767);
  begin
  
    if i_Val is null then
      return '';
    end if;
  
    for i in 1 .. i_Val.Count loop
      result := result || to_char(i_Val(i), v_Format);
      if i <> i_Val.Count then
        result := result || i_Delimiter;
      end if;
    end loop;
  
    return result;
  end;

  Function Gather(i_Val       Array_Date,
                  i_Delimiter varchar2,
                  i_Format    varchar2 := null) return varchar2 is
    v_Format varchar2(50) := Nvl(i_Format, 'dd.mm.yyyy');
    result   varchar2(32767);
  begin
  
    if i_Val is null then
      return '';
    end if;
  
    for i in 1 .. i_Val.Count loop
      result := result || to_char(i_Val(i), v_Format);
      if i <> i_Val.Count then
        result := result || i_Delimiter;
      end if;
    end loop;
  
    return result;
  end;

  Function Equal(i_Val1 varchar2, i_Val2 varchar2) return boolean is
  begin
    if (i_Val1 is null and i_Val2 is null) or (i_Val1 = i_Val2) then
      return true;
    else
      return false;
    end if;
  end;

  Function Equal(i_Val1 number, i_Val2 number) return boolean is
  begin
    if (i_Val1 is null and i_Val2 is null) or (i_Val1 = i_Val2) then
      return true;
    else
      return false;
    end if;
  end;

  Function Equal(i_Val1 date, i_Val2 date) return boolean is
  begin
    if (i_Val1 is null and i_Val2 is null) or (i_Val1 = i_Val2) then
      return true;
    else
      return false;
    end if;
  end;

  Function Week_Day(i_Date date) return pls_integer is
  begin
    return Trunc(i_Date) - Trunc(i_Date, 'IW');
  end;

  Function Read_Clob(i_Clob clob) return Array_Varchar2 is
    c_Block_Size constant number := 32000;
    v_Len  number;
    v_Iter number;
    result Array_Varchar2;
  begin
    if i_Clob is null then
      return result;
    end if;
  
    v_Len  := Length(i_Clob);
    v_Iter := Ceil(v_Len / c_Block_Size);
  
    result := Array_Varchar2();
    Result.Extend(v_Iter);
    for i in 1 .. v_Iter loop
      result(i) := Substr(i_Clob, (i - 1) * c_Block_Size + 1, c_Block_Size);
    end loop;
    return result;
  end;

  Function Decode2(i_Value varchar2,
                   i_St1   varchar2,
                   i_Ans1  varchar2,
                   i_St2   varchar2,
                   i_Ans2  varchar2) return varchar2 is
    result varchar2(4000);
  begin
    select Decode(i_Value, i_St1, i_Ans1, i_St2, i_Ans2)
      into result
      from Dual;
    return result;
  end Decode2;

  Function Decode2(i_Value varchar2,
                   i_St1   varchar2,
                   i_Ans1  varchar2,
                   i_Ans2  varchar2) return varchar2 is
    result varchar2(4000);
  begin
    select Decode(i_Value, i_St1, i_Ans1, i_Ans2) into result from Dual;
    return result;
  end Decode2;

  Function Decode2(i_Value varchar2, i_St1 varchar2, i_Ans1 varchar2)
    return varchar2 is
    result varchar2(4000);
  begin
    select Decode(i_Value, i_St1, i_Ans1) into result from Dual;
    return result;
  end Decode2;

  Function Decode2(i_Decode varchar2) return varchar2 is
    result varchar2(4000);
  begin
    execute immediate ('select decode(' || i_Decode || ') from Dual')
      into result;
    return result;
  end Decode2;

  Function Nvl2(i_Value varchar2, i_Ans1 varchar2, i_Ans2 varchar2)
    return varchar2 is
    result varchar2(4000);
  begin
    select Nvl2(i_Value, i_Ans1, i_Ans2) into result from Dual;
    return result;
  end Nvl2;

  Function Cur_Nls(i_Label Mlt_Name_t, i_Lang_Index number) return varchar2 is
    result varchar2(500) := 'Нет данных';
  begin
    if i_Label.Count < i_Lang_Index then
      result := i_Label(1);
    else
      result := Nvl(i_Label(i_Lang_Index), i_Label(1));
    end if;
    return result;
  exception
    when others then
      return result;
  end Cur_Nls;

  Function Cur_Nls(i_Label Mlt_Text_t, i_Lang_Index number) return varchar2 is
    result varchar2(500) := 'Нет данных';
  begin
    if i_Label.Count < i_Lang_Index then
      result := i_Label(1);
    else
      result := Nvl(i_Label(i_Lang_Index), i_Label(1));
    end if;
    return result;
  exception
    when others then
      return result;
  end Cur_Nls;

  Function Has_Common_Bits(i_R1 raw, i_R2 raw) return number deterministic is
  begin
    return Util_Raw.Has_Common_Bits(R1 => i_R1, R2 => i_R2);
  end Has_Common_Bits;

  Function Is_Bit_Set(i_R1 raw, i_Bit_Order pls_integer) return number is
  begin
    return Util_Raw.Has_Common_Bits(i_R1,
                                    Util_Raw.Raw_From_Bit(i_Bit_Order));
  end Is_Bit_Set;

  Function Is_Bit_Set_Yn(i_R1 raw, i_Bit_Order pls_integer) return varchar2 is
  begin
    if Is_Bit_Set(i_R1 => i_R1, i_Bit_Order => i_Bit_Order) = 1 then
      return 'Y';
    end if;
    return 'N';
  end Is_Bit_Set_Yn;

  Function Is_Bit_Set(i_Bit_Set number, i_Bit_Order pls_integer)
    return number is
  begin
    return case when Bitand(i_Bit_Set, Power(2, i_Bit_Order)) != 0 then 1 else 0 end;
  end Is_Bit_Set;

  Function Is_Bit_Set_Yn(i_Bit_Set number, i_Bit_Order pls_integer)
    return varchar2 is
  begin
    if Is_Bit_Set(i_Bit_Set, i_Bit_Order) = 1 then
      return 'Y';
    end if;
    return 'N';
  end Is_Bit_Set_Yn;

  Procedure Who_Called_Me(i_Cnt   number,
                          o_Owner out varchar2,
                          o_Name  out varchar2) as
    v_Call_Stack varchar2(4096) := Dbms_Utility.Format_Call_Stack;
    n            number;
    Found_Stack  boolean default false;
    Line         varchar2(255);
    t            varchar2(255);
    Cnt          number := 0;
    v_Lineno     number;
    v_Caller_t   varchar2(32767);
  begin
  
    loop
      n := Instr(v_Call_Stack, Chr(10));
      exit when(Cnt = i_Cnt or n is null or n = 0);
    
      Line         := Ltrim(Substr(v_Call_Stack, 1, n - 1));
      v_Call_Stack := Substr(v_Call_Stack, n + 1);
    
      if (not Found_Stack) then
        if (Line like '%handle%number%name%') then
          Found_Stack := true;
        end if;
      else
        Cnt := Cnt + 1;
      
        if (Cnt = i_Cnt) then
        
          n := Instr(Line, ' ');
          if (n > 0) then
            t := Ltrim(Substr(Line, n));
            n := Instr(t, ' ');
          end if;
          if (n > 0) then
            v_Lineno := to_number(Substr(t, 1, n - 1));
            Line     := Ltrim(Substr(t, n));
          else
            v_Lineno := 0;
          end if;
          if (Line like 'pr%') then
            n := Length('procedure ');
          elsif (Line like 'fun%') then
            n := Length('function ');
          elsif (Line like 'package body%') then
            n := Length('package body ');
          elsif (Line like 'pack%') then
            n := Length('package ');
          else
            n := Length('anonymous block ');
          end if;
          v_Caller_t := Ltrim(Rtrim(Upper(Substr(Line, 1, n - 1))));
          Line       := Substr(Line, n);
          n          := Instr(Line, '.');
          o_Owner    := Ltrim(Rtrim(Substr(Line, 1, n - 1)));
          o_Name     := Ltrim(Rtrim(Substr(Line, n + 1)));
        end if;
      end if;
    end loop;
  end;

  Function Str(i_Value varchar2) return varchar2 is
  begin
    return i_Value;
  end;

  Function Str(i_Value number) return varchar2 is
  begin
    return to_char(i_Value, 'TM9', 'NLS_NUMERIC_CHARACTERS=''. ''');
  end;

  Function Str(i_Value date) return varchar2 is
  begin
    return to_char(i_Value, 'yyyymmddhh24miss');
  end;

  Function Str(i_Value timestamp) return varchar2 is
  begin
    return to_char(i_Value, 'yyyymmddhh24missxff');
  end;

  Function Str(i_Value Array_Varchar2) return varchar2 is
    result varchar2(32767);
  begin
    if i_Value is null or i_Value.Count = 0 then
      result := null;
    else
    
      for i in 1 .. i_Value.Count loop
        result := result || i_Value(i);
        if i <> i_Value.Count then
          result := result || Chr(1);
        end if;
      end loop;
    end if;
    return result;
  end;

  Function Str(i_Value Array_Number) return varchar2 is
    result varchar2(32767);
  begin
    if i_Value is null or i_Value.Count = 0 then
      result := null;
    else
    
      for i in 1 .. i_Value.Count loop
        result := result ||
                  to_char(i_Value(i),
                          'TM9',
                          'NLS_NUMERIC_CHARACTERS=''. ''');
        if i <> i_Value.Count then
          result := result || Chr(1);
        end if;
      end loop;
    end if;
    return result;
  end;

  Function Str(i_Value Array_Date) return varchar2 is
    result varchar2(32767);
  begin
    if i_Value is null or i_Value.Count = 0 then
      result := null;
    else
    
      for i in 1 .. i_Value.Count loop
        result := result || to_char(i_Value(i), 'yyyymmddhh24miss');
        if i <> i_Value.Count then
          result := result || Chr(1);
        end if;
      end loop;
    end if;
    return result;
  end;

  Function Str(i_Value Mlt_Text_t) return varchar2 is
    result varchar2(32767);
  begin
    if i_Value is null or i_Value.Count = 0 then
      result := null;
    else
    
      for i in 1 .. i_Value.Count loop
        result := result || i_Value(i);
        if i <> i_Value.Count then
          result := result || Chr(1);
        end if;
      end loop;
    end if;
    return result;
  end;

  Function Str(i_Value Mlt_Label_t) return varchar2 is
    result varchar2(32767);
  begin
    if i_Value is null or i_Value.Count = 0 then
      result := null;
    else
    
      for i in 1 .. i_Value.Count loop
        result := result || i_Value(i);
        if i <> i_Value.Count then
          result := result || Chr(1);
        end if;
      end loop;
    end if;
    return result;
  end;

  Function Str(i_Value Mlt_Name_t) return varchar2 is
    result varchar2(32767);
  begin
    if i_Value is null or i_Value.Count = 0 then
      result := null;
    else
    
      for i in 1 .. i_Value.Count loop
        result := result || i_Value(i);
        if i <> i_Value.Count then
          result := result || Chr(1);
        end if;
      end loop;
    end if;
    return result;
  end;

  Function Str(i_Value blob) return varchar2 is
  begin
    if i_Value is null then
      null;
    end if;
    return null;
  end;

  Function Str(i_Value clob) return varchar2 is
  begin
    if i_Value is null then
      null;
    end if;
    return null;
  end;

  Procedure Fill_Col_Set(i_Col_Set in out nocopy Sql_Util.Number_Code_Aat,
                         i_f       varchar2) is
  begin
    if i_f is not null then
      i_Col_Set(i_f) := 1;
    end if;
  end;

  Function Is_Different(i_a number, i_b number) return boolean is
  begin
    if i_a is null and i_b is null then
      return false;
    end if;
    if i_a is null and i_b is not null then
      return true;
    end if;
    if i_a is not null and i_b is null then
      return true;
    end if;
    return i_a <> i_b;
  end;

  Function Is_Different(i_a varchar2, i_b varchar2) return boolean is
  begin
    if i_a is null and i_b is null then
      return false;
    end if;
    if i_a is null and i_b is not null then
      return true;
    end if;
    if i_a is not null and i_b is null then
      return true;
    end if;
    return i_a <> i_b;
  end;

  Function Is_Different(i_a date, i_b date) return boolean is
  begin
    if i_a is null and i_b is null then
      return false;
    end if;
    if i_a is null and i_b is not null then
      return true;
    end if;
    if i_a is not null and i_b is null then
      return true;
    end if;
    return i_a <> i_b;
  end;

  Function Is_Different(i_a timestamp, i_b timestamp) return boolean is
  begin
    if i_a is null and i_b is null then
      return false;
    end if;
    if i_a is null and i_b is not null then
      return true;
    end if;
    if i_a is not null and i_b is null then
      return true;
    end if;
    return i_a <> i_b;
  end;

  Function Is_Different(i_a Mlt_Name_t, i_b Mlt_Name_t) return boolean is
    i_Aa varchar2(4000);
    i_Ab varchar2(4000);
  begin
    select Sql_Util.Gather(cast(i_a as Array_Varchar2), ',')
      into i_Aa
      from Dual;
    select Sql_Util.Gather(cast(i_b as Array_Varchar2), ',')
      into i_Ab
      from Dual;
    if i_Aa is null and i_Ab is null then
      return false;
    end if;
    if i_Aa is null and i_Ab is not null then
      return true;
    end if;
    if i_Aa is not null and i_Ab is null then
      return true;
    end if;
    return i_Aa <> i_Ab;
  end;

  Function Is_Different(i_a Mlt_Text_t, i_b Mlt_Text_t) return boolean is
    i_Aa varchar2(4000);
    i_Ab varchar2(4000);
  begin
    select Sql_Util.Gather(cast(i_a as Array_Varchar2), ',')
      into i_Aa
      from Dual;
    select Sql_Util.Gather(cast(i_b as Array_Varchar2), ',')
      into i_Ab
      from Dual;
    if i_Aa is null and i_Ab is null then
      return false;
    end if;
    if i_Aa is null and i_Ab is not null then
      return true;
    end if;
    if i_Aa is not null and i_Ab is null then
      return true;
    end if;
    return i_Aa <> i_Ab;
  end;

  Function Is_Different(i_a Mlt_Label_t, i_b Mlt_Label_t) return boolean is
    i_Aa varchar2(4000);
    i_Ab varchar2(4000);
  begin
    select Sql_Util.Gather(cast(i_a as Array_Varchar2), ',')
      into i_Aa
      from Dual;
    select Sql_Util.Gather(cast(i_b as Array_Varchar2), ',')
      into i_Ab
      from Dual;
    if i_Aa is null and i_Ab is null then
      return false;
    end if;
    if i_Aa is null and i_Ab is not null then
      return true;
    end if;
    if i_Aa is not null and i_Ab is null then
      return true;
    end if;
    return i_Aa <> i_Ab;
  end;

  Function Is_Different(i_a blob, i_b blob) return boolean is
  begin
    if Dbms_Lob.Compare(i_a, i_b) = 0 then
      return true;
    else
      return false;
    end if;
  end;

  Function Is_Different(i_a Xmltype, i_b Xmltype) return boolean is
  begin
    return Is_Different(i_a.Getclobval(), i_b.Getclobval());
  end;

end Sql_Util;
/
