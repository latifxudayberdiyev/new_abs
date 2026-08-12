create or replace package Json_Parser is

  Procedure Parse_Json
  (
    i_Json_Str in varchar2,
    Io_Json    in out nocopy Hash_t,
    i_Set_Temp in boolean default false
  );

  Procedure Parse_Json
  (
    i_Json_Str in Long_String,
    Io_Json    in out nocopy Hash_t,
    i_Set_Temp in boolean default false
  );

  Procedure Parse_Json
  (
    i_Json_Str in Array_Varchar2,
    Io_Json    in out nocopy Hash_t,
    i_Set_Temp in boolean default false
  );

  Procedure Parse_Json
  (
    i_Json_Str in clob,
    Io_Json    in out nocopy Hash_t,
    i_Set_Temp in boolean default false
  );

  Function Parse_Json(i_Json_Str varchar2) return Hash_t;

  Function Parse_Json(i_Json_Str Long_String) return Hash_t;

  Function Parse_Json(i_Json_Str Array_Varchar2) return Hash_t;

  Function Parse_Json(i_Json_Str clob) return Hash_t;

end Json_Parser;
/
create or replace package body Json_Parser is

  c_Err_Code       constant number := -20000;
  c_Tt_Error       constant pls_integer := 0;
  c_Tt_Ident       constant pls_integer := 1;
  c_Tt_Number      constant pls_integer := 2;
  c_Tt_Number_e    constant pls_integer := 20;
  c_Tt_String      constant pls_integer := 3;
  c_Tt_Long_String constant pls_integer := 30;
  c_Tt_Boolean     constant pls_integer := 4;
  c_Tt_Null        constant pls_integer := 5;
  c_Tt_Json_Beg    constant pls_integer := 6;
  c_Tt_Json_End    constant pls_integer := 7;
  c_Tt_Array_Beg   constant pls_integer := 8;
  c_Tt_Array_End   constant pls_integer := 9;
  c_Tt_Comma       constant pls_integer := 10;
  c_Tt_Dbl_Point   constant pls_integer := 11;

  c_Tt_Buffer_End constant pls_integer := 99;

  c_Ch_Json_Beg     constant pls_integer := Ascii('{');
  c_Ch_Json_End     constant pls_integer := Ascii('}');
  c_Ch_Array_Beg    constant pls_integer := Ascii('[');
  c_Ch_Array_End    constant pls_integer := Ascii(']');
  c_Ch_Space        constant pls_integer := Ascii(' ');
  c_Ch_Tab          constant pls_integer := 9;
  c_Ch_Lf           constant pls_integer := 10;
  c_Ch_Cr           constant pls_integer := 13;
  c_Ch_Numb_0       constant pls_integer := Ascii('0');
  c_Ch_Numb_9       constant pls_integer := Ascii('9');
  c_Ch_Minus        constant pls_integer := Ascii('-');
  c_Ch_Plus         constant pls_integer := Ascii('+');
  c_Ch_Alpha_a      constant pls_integer := Ascii('a');
  c_Ch_Alpha_Ha     constant pls_integer := Ascii('A');
  c_Ch_Alpha_z      constant pls_integer := Ascii('z');
  c_Ch_Alpha_Hz     constant pls_integer := Ascii('Z');
  c_Ch_e_Notation   constant pls_integer := Ascii('E');
  c_Ch_e_Notation_l constant pls_integer := Ascii('e');
  c_Ch_Underline    constant pls_integer := Ascii('_');
  c_Ch_Point        constant pls_integer := Ascii('.');
  c_Ch_Dpoint       constant pls_integer := Ascii(':');
  c_Ch_Sngl_Quote   constant pls_integer := Ascii('''');
  c_Ch_Dbl_Quote    constant pls_integer := Ascii('"');
  c_Ch_Comma        constant pls_integer := Ascii(',');
  c_Ch_Comment      constant pls_integer := Ascii('/');
  c_Ch_Star         constant pls_integer := Ascii('*');

  c_Fmt_Number   constant varchar2(43) := '99999999999999999999.99999999999999999999';
  c_Fmt_Number_e constant varchar2(26) := '9.99999999999999999999EEEE';
  g_Set_Param boolean := false;
  Procedure Set_Temp_Table
  (
    i_Key   in varchar2,
    i_Value varchar2
  ) is
  begin
    insert into Temp_Json_Data
      (Key_Name, Key_Value)
    values
      (i_Key, i_Value);
  end;

  Procedure Raise_Syntax_Error
  (
    i_Long  Long_String,
    i_Short varchar2,
    i_Pos   pls_integer,
    i_Msg   varchar2 := ''
  ) is
    v_Ind  pls_integer := 0;
    v_Line pls_integer := 1;
    v_Symb pls_integer := i_Pos;
  begin
  
    while v_Ind < i_Pos
    loop
    
      if i_Long is not null then
        v_Ind := i_Long.Find_Substr(Chr(10), v_Ind + 1);
      else
        v_Ind := Instr(i_Short, Chr(10), v_Ind + 1);
      end if;
    
      exit when(v_Ind = 0 or v_Ind > i_Pos);
    
      v_Line := v_Line + 1;
      v_Symb := i_Pos - v_Ind + 1;
    end loop;
  
    Raise_Application_Error(c_Err_Code,
                            'Синтаксическая ошибка (строка: ' || v_Line || ', символ: ' || v_Symb || ')!' ||
                            Chr(10) || i_Msg);
  end Raise_Syntax_Error;

  Procedure Raise_Syntax_Error
  (
    i_Buf varchar2,
    i_Pos pls_integer,
    i_Msg varchar2 := ''
  ) is
  begin
  
    Raise_Syntax_Error(null, i_Buf, i_Pos, i_Msg);
  end Raise_Syntax_Error;

  Procedure Raise_Syntax_Error
  (
    i_Buf Long_String,
    i_Pos pls_integer,
    i_Msg varchar2 := ''
  ) is
  begin
  
    Raise_Syntax_Error(i_Buf, null, i_Pos, i_Msg);
  end Raise_Syntax_Error;

  Function Unescape(i_Str varchar2) return varchar2 is
  begin
  
    if Instr(i_Str, '\') = 0 then
      return i_Str;
    else
      return replace(replace(replace(replace(replace(replace(replace(replace(i_Str, '\\', '\'),
                                                                     '\/',
                                                                     '/'),
                                                             '\"',
                                                             '"'),
                                                     '\b',
                                                     Chr(8)),
                                             '\t',
                                             Chr(9)),
                                     '\r',
                                     Chr(10)),
                             '\f',
                             Chr(12)),
                     '\n',
                     Chr(13));
    end if;
  end Unescape;

  Function Unescape(i_Str Long_String) return Long_String is
  begin
    return i_Str.Unescape();
  end Unescape;

  Procedure Internal_Parse_Json
  (
    i_Buf   in varchar2,
    Io_Pos  in out pls_integer,
    Io_Json in out nocopy Hash_t
  ) is
    v_Buf_Size   pls_integer;
    v_Token      varchar2(32767);
    v_Buf_Index  pls_integer;
    v_Token_Pos  pls_integer;
    v_Token_Type pls_integer;
    v_Field_Name varchar2(32767);
    v_Set_Param  boolean := false;
  
    Procedure Syntax_Error
    (
      i_Msg varchar2 := '',
      i_Pos pls_integer := null
    ) is
    begin
    
      Raise_Syntax_Error(i_Buf, Nvl(i_Pos, v_Token_Pos), i_Msg);
    end Syntax_Error;
  
    Function Is_Paired_Escape_Sym(i_Pos pls_integer) return boolean is
      v_Index pls_integer := i_Pos - 1;
      result  boolean := false;
    begin
      while (v_Index > 0 and Substr(i_Buf, v_Index, 1) = '\')
      loop
        result  := not result;
        v_Index := v_Index - 1;
      end loop;
      return result;
    end Is_Paired_Escape_Sym;
  
    Procedure Get_Ident(i_Is_Value boolean) is
      p     pls_integer := v_Buf_Index;
      v_Sym pls_integer;
    begin
    
      loop
      
        p := p + 1;
      
        v_Sym := Ascii(Substr(i_Buf, p, 1));
      
        exit when not((v_Sym >= c_Ch_Numb_0 and v_Sym <= c_Ch_Numb_9) or
                      (v_Sym >= c_Ch_Alpha_Ha and v_Sym <= c_Ch_Alpha_Hz) or
                      (v_Sym >= c_Ch_Alpha_a and v_Sym <= c_Ch_Alpha_z) or
                      (v_Sym = c_Ch_Underline));
      end loop;
    
      v_Token := Substr(i_Buf, v_Buf_Index, p - v_Buf_Index);
    
      if i_Is_Value then
      
        if v_Token = 'true' or v_Token = 'false' then
          v_Token_Type := c_Tt_Boolean;
        elsif v_Token = 'null' then
          v_Token_Type := c_Tt_Null;
        else
          Syntax_Error(i_Pos => v_Buf_Index);
        end if;
      else
        v_Token_Type := c_Tt_Ident;
      end if;
    
      v_Buf_Index := p;
    end Get_Ident;
  
    Procedure Get_Number(i_First_Sym pls_integer) is
      p       pls_integer := v_Buf_Index;
      v_Start pls_integer := v_Buf_Index;
      v_Point boolean := (i_First_Sym = c_Ch_Point);
      v_Sym   pls_integer;
    begin
    
      if i_First_Sym = c_Ch_Minus or i_First_Sym = c_Ch_Plus then
      
        if i_First_Sym = c_Ch_Plus then
          v_Start := v_Start + 1;
        end if;
      
        while Ascii(Substr(i_Buf, p + 1, 1)) in (c_Ch_Space, c_Ch_Tab)
        loop
          p := p + 1;
        end loop;
      end if;
    
      loop
      
        p := p + 1;
      
        v_Sym := Ascii(Substr(i_Buf, p, 1));
      
        if v_Sym >= c_Ch_Numb_0 and v_Sym <= c_Ch_Numb_9 then
        
          continue;
        elsif v_Sym = c_Ch_Point then
        
          if v_Point then
          
            Syntax_Error('', i_Pos => v_Buf_Index);
          else
            v_Point := true;
            continue;
          end if;
        else
        
          exit;
        end if;
      end loop;
    
      v_Token_Type := c_Tt_Number;
    
      if v_Sym = c_Ch_e_Notation or v_Sym = c_Ch_e_Notation_l then
      
        p := p + 1;
      
        v_Sym := Ascii(Substr(i_Buf, p, 1));
      
        if (v_Sym = c_Ch_Minus or v_Sym = c_Ch_Plus) then
          p     := p + 1;
          v_Sym := Ascii(Substr(i_Buf, p, 1));
        end if;
      
        if v_Sym not between c_Ch_Numb_0 and c_Ch_Numb_9 then
        
          Syntax_Error('', i_Pos => v_Buf_Index);
        end if;
      
        loop
        
          p := p + 1;
        
          exit when Ascii(Substr(i_Buf, p, 1)) not between c_Ch_Numb_0 and c_Ch_Numb_9;
        end loop;
      
        v_Token_Type := c_Tt_Number_e;
      end if;
    
      v_Token := Substr(i_Buf, v_Start, p - v_Start);
    
      v_Buf_Index := p;
    end Get_Number;
  
    Procedure Get_String(i_Quote varchar2) is
      p        pls_integer := v_Buf_Index;
      v_Quotes boolean := false;
    begin
    
      loop
      
        p := Instr(i_Buf, i_Quote, p + 1);
      
        if p = 0 then
        
          Syntax_Error('Синтаксическая ошибка: пропущена закрывающая кавычка!!');
        elsif p > 1 and Substr(i_Buf, p - 1, 1) = '\' then
        
          if Is_Paired_Escape_Sym(p - 1) then
            exit;
          end if;
        elsif Substr(i_Buf, p + 1, 1) = i_Quote then
        
          v_Quotes := true;
          p        := p + 1;
        else
          exit;
        end if;
      end loop;
    
      v_Token_Type := c_Tt_String;
    
      v_Token := Substr(i_Buf, v_Buf_Index + 1, p - v_Buf_Index - 1);
    
      if v_Quotes then
        v_Token := replace(v_Token, i_Quote || i_Quote, i_Quote);
      end if;
    
      if Instr(v_Token, '\') > 0 then
        v_Token := Unescape(v_Token);
      end if;
    
      v_Buf_Index := p + 1;
    end Get_String;
  
    Procedure Skip_Block_Comment is
      p pls_integer;
    begin
    
      p := Instr(i_Buf, '*' || '/', v_Buf_Index + 2);
    
      if p = 0 then
      
        Syntax_Error('Синтаксическая ошибка: не закрыть блочный комментарий!!');
      end if;
    
      v_Buf_Index := p + 2;
    end Skip_Block_Comment;
  
    Procedure Skip_Line_Comment is
    begin
    
      while Ascii(Substr(i_Buf, v_Buf_Index, 1)) not in (c_Ch_Lf, c_Ch_Cr)
      loop
        v_Buf_Index := v_Buf_Index + 1;
      end loop;
    
      while Ascii(Substr(i_Buf, v_Buf_Index, 1)) in (c_Ch_Lf, c_Ch_Cr)
      loop
        v_Buf_Index := v_Buf_Index + 1;
      end loop;
    end Skip_Line_Comment;
  
    Procedure Get_Token(i_Is_Value boolean := false) is
      v_Sym pls_integer;
    begin
    
      loop
        v_Token := Substr(i_Buf, v_Buf_Index, 1);
        v_Sym   := Ascii(v_Token);
      
        if v_Sym in (c_Ch_Space, c_Ch_Tab, c_Ch_Cr, c_Ch_Lf) then
          v_Buf_Index := v_Buf_Index + 1;
          exit when(v_Buf_Index > v_Buf_Size);
        elsif v_Sym = c_Ch_Comment and v_Buf_Index < v_Buf_Size then
        
          case Ascii(Substr(i_Buf, v_Buf_Index + 1, 1))
            when c_Ch_Comment then
              Skip_Line_Comment;
            when c_Ch_Star then
              Skip_Block_Comment;
            else
              exit;
          end case;
        else
          exit;
        end if;
      end loop;
    
      v_Token_Pos := v_Buf_Index;
    
      if v_Buf_Index > v_Buf_Size then
        v_Token_Type := c_Tt_Buffer_End;
        return;
      end if;
    
      if v_Sym = c_Ch_Sngl_Quote or v_Sym = c_Ch_Dbl_Quote then
      
        Get_String(v_Token);
        return;
      elsif v_Sym = c_Ch_Comma then
      
        v_Token_Type := c_Tt_Comma;
      elsif v_Sym = c_Ch_Dpoint then
      
        v_Token_Type := c_Tt_Dbl_Point;
      elsif v_Sym = c_Ch_Json_Beg then
      
        v_Token_Type := c_Tt_Json_Beg;
      elsif v_Sym = c_Ch_Json_End then
      
        v_Token_Type := c_Tt_Json_End;
      elsif v_Sym = c_Ch_Array_Beg then
      
        v_Token_Type := c_Tt_Array_Beg;
      elsif v_Sym = c_Ch_Array_End then
      
        v_Token_Type := c_Tt_Array_End;
      elsif (v_Sym >= c_Ch_Numb_0 and v_Sym <= c_Ch_Numb_9) or (v_Sym = c_Ch_Point) or
            (v_Sym = c_Ch_Minus or v_Sym = c_Ch_Plus) then
      
        Get_Number(v_Sym);
        return;
      elsif (v_Sym >= c_Ch_Alpha_Ha and v_Sym <= c_Ch_Alpha_Hz) or
            (v_Sym >= c_Ch_Alpha_a and v_Sym <= c_Ch_Alpha_z) or v_Sym = c_Ch_Underline then
      
        Get_Ident(i_Is_Value);
        return;
      else
      
        v_Token_Type := c_Tt_Error;
        return;
      end if;
    
      v_Buf_Index := v_Buf_Index + 1;
    end Get_Token;
  
    Procedure Find_Symbol(i_Symbol varchar2) is
    begin
    
      while Ascii(Substr(i_Buf, v_Buf_Index, 1)) in (c_Ch_Space, c_Ch_Tab, c_Ch_Lf, c_Ch_Cr)
      loop
        v_Buf_Index := v_Buf_Index + 1;
      end loop;
    
      if v_Buf_Index > v_Buf_Size or Substr(i_Buf, v_Buf_Index, 1) != i_Symbol then
      
        Syntax_Error();
      end if;
    end Find_Symbol;
  
    Function Get_Json return Hash_t is
      v_Json Hash_t;
    begin
    
      Internal_Parse_Json(i_Buf, v_Buf_Index, v_Json);
    
      return v_Json;
    end Get_Json;
  
    Function Parse_Array return Arraylist is
      v_Array Arraylist := Arraylist();
    begin
      v_Buf_Index := v_Buf_Index;
    
      loop
      
        Get_Token(true);
      
        if v_Token_Type = c_Tt_String then
          v_Array.Push(v_Token);
        elsif v_Token_Type = c_Tt_Number then
          v_Array.Push(to_number(v_Token, c_Fmt_Number));
        
        elsif v_Token_Type = c_Tt_Number_e then
          v_Array.Push(to_number(v_Token, c_Fmt_Number_e));
        
        elsif v_Token_Type = c_Tt_Json_Beg then
          v_Buf_Index := v_Token_Pos;
          v_Array.Push(Get_Json());
        elsif v_Token_Type = c_Tt_Array_Beg then
          v_Array.Push(Parse_Array());
        elsif v_Token_Type = c_Tt_Null then
          v_Array.Push('');
        elsif v_Token_Type = c_Tt_Boolean then
          v_Array.Push(v_Token);
        
        elsif v_Token_Type = c_Tt_Array_End then
          exit;
        else
          Syntax_Error();
        end if;
      
        Get_Token;
      
        if v_Token_Type = c_Tt_Array_End then
          exit;
        elsif v_Token_Type != c_Tt_Comma then
          Syntax_Error();
        end if;
      end loop;
    
      return v_Array;
    end Parse_Array;
  
  begin
  
    if i_Buf is null then
      Raise_Application_Error(c_Err_Code, 'не задано JSON-строка!');
    end if;
  
    Io_Json     := Hash_t();
    v_Buf_Index := Io_Pos;
    v_Token_Pos := Io_Pos;
    v_Buf_Size  := Length(i_Buf);
  
    Find_Symbol('{');
    v_Buf_Index := v_Buf_Index + 1;
  
    while v_Buf_Index <= v_Buf_Size
    loop
      v_Set_Param := false;
      Get_Token;
    
      if v_Token_Type = c_Tt_Json_End then
        exit;
      elsif v_Token_Type != c_Tt_String and v_Token_Type != c_Tt_Ident then
        Syntax_Error();
      end if;
    
      v_Field_Name := v_Token;
      Find_Symbol(':');
      v_Buf_Index := v_Buf_Index + 1;
      Get_Token(true);
    
      if v_Token_Type = c_Tt_String then
      
        Io_Json.Put(v_Field_Name, v_Token);
        v_Set_Param := true;
      elsif v_Token_Type = c_Tt_Number then
      
        Io_Json.Put(v_Field_Name, to_number(v_Token, c_Fmt_Number));
        v_Set_Param := true;
      
      elsif v_Token_Type = c_Tt_Number_e then
        Io_Json.Put(v_Field_Name, to_number(v_Token, c_Fmt_Number_e));
        v_Set_Param := true;
      
      elsif v_Token_Type = c_Tt_Json_Beg then
      
        v_Buf_Index := v_Token_Pos;
      
        Io_Json.Put(v_Field_Name, Get_Json());
      elsif v_Token_Type = c_Tt_Array_Beg then
      
        Io_Json.Put(v_Field_Name, Parse_Array());
      elsif v_Token_Type = c_Tt_Null then
      
        Io_Json.Put(v_Field_Name, '');
        v_Set_Param := true;
      
      elsif v_Token_Type = c_Tt_Boolean then
      
        Io_Json.Put(v_Field_Name, v_Token);
        v_Set_Param := true;
      
      else
        Syntax_Error();
      end if;
      -- set temp 
      if g_Set_Param and v_Set_Param then
        Set_Temp_Table(v_Field_Name, v_Token);
      end if;
      --
      Get_Token;
    
      if v_Token_Type = c_Tt_Json_End then
        exit;
      elsif v_Token_Type = c_Tt_Comma then
        continue;
      else
        Syntax_Error();
      end if;
    end loop;
  
    Io_Pos := v_Buf_Index;
  end Internal_Parse_Json;

  Procedure Internal_Parse_Json
  (
    i_Buf   in Long_String,
    Io_Pos  in out pls_integer,
    Io_Json in out nocopy Hash_t
  ) is
    v_Buf_Size   pls_integer;
    v_Token      varchar2(32767);
    v_Token_Long Long_String;
    v_Buf_Index  pls_integer;
    v_Token_Pos  pls_integer;
    v_Token_Type pls_integer;
    v_Field_Name varchar2(32767);
    v_Set_Param  boolean := false;
  
    Procedure Syntax_Error
    (
      i_Msg varchar2 := '',
      i_Pos pls_integer := null
    ) is
    begin
    
      Raise_Syntax_Error(i_Buf, Nvl(i_Pos, v_Token_Pos), i_Msg);
    end Syntax_Error;
  
    Function Is_Paired_Escape_Sym(i_Pos pls_integer) return boolean is
      v_Index pls_integer := i_Pos - 1;
      result  boolean := false;
    begin
      while (v_Index > 0 and i_Buf.Get_Char(v_Index) = '\')
      loop
        result  := not result;
        v_Index := v_Index - 1;
      end loop;
      return result;
    end Is_Paired_Escape_Sym;
  
    Procedure Get_Ident(i_Is_Value boolean) is
      p     pls_integer := v_Buf_Index;
      v_Sym pls_integer;
    begin
    
      loop
      
        p := p + 1;
      
        v_Sym := i_Buf.Get_Char_Code(p);
      
        exit when not((v_Sym >= c_Ch_Numb_0 and v_Sym <= c_Ch_Numb_9) or
                      (v_Sym >= c_Ch_Alpha_Ha and v_Sym <= c_Ch_Alpha_Hz) or
                      (v_Sym >= c_Ch_Alpha_a and v_Sym <= c_Ch_Alpha_z) or
                      (v_Sym = c_Ch_Underline));
      end loop;
    
      v_Token := i_Buf.Sub_Str(v_Buf_Index, p - v_Buf_Index);
    
      if i_Is_Value then
      
        if v_Token = 'true' or v_Token = 'false' then
          v_Token_Type := c_Tt_Boolean;
        elsif v_Token = 'null' then
          v_Token_Type := c_Tt_Null;
        else
          Syntax_Error(i_Pos => v_Buf_Index);
        end if;
      else
        v_Token_Type := c_Tt_Ident;
      end if;
    
      v_Buf_Index := p;
    end Get_Ident;
  
    Procedure Get_Number(i_First_Sym pls_integer) is
      p       pls_integer := v_Buf_Index;
      v_Start pls_integer := v_Buf_Index;
      v_Point boolean := (i_First_Sym = c_Ch_Point);
      v_Sym   pls_integer;
    begin
    
      if i_First_Sym = c_Ch_Minus or i_First_Sym = c_Ch_Plus then
      
        if i_First_Sym = c_Ch_Plus then
          v_Start := v_Start + 1;
        end if;
      
        while i_Buf.Get_Char_Code(p + 1) in (c_Ch_Space, c_Ch_Tab)
        loop
          p := p + 1;
        end loop;
      end if;
    
      loop
      
        p := p + 1;
      
        v_Sym := i_Buf.Get_Char_Code(p);
      
        if v_Sym >= c_Ch_Numb_0 and v_Sym <= c_Ch_Numb_9 then
        
          continue;
        elsif v_Sym = c_Ch_Point then
        
          if v_Point then
          
            Syntax_Error('', i_Pos => v_Buf_Index);
          else
            v_Point := true;
            continue;
          end if;
        else
        
          exit;
        end if;
      end loop;
    
      v_Token_Type := c_Tt_Number;
    
      if v_Sym = c_Ch_e_Notation or v_Sym = c_Ch_e_Notation_l then
      
        p := p + 1;
      
        v_Sym := i_Buf.Get_Char_Code(p);
      
        if (v_Sym = c_Ch_Minus or v_Sym = c_Ch_Plus) then
          p     := p + 1;
          v_Sym := i_Buf.Get_Char_Code(p);
        end if;
      
        if v_Sym not between c_Ch_Numb_0 and c_Ch_Numb_9 then
        
          Syntax_Error('', i_Pos => v_Buf_Index);
        end if;
      
        loop
        
          p := p + 1;
        
          exit when i_Buf.Get_Char_Code(p) not between c_Ch_Numb_0 and c_Ch_Numb_9;
        end loop;
      
        v_Token_Type := c_Tt_Number_e;
      end if;
    
      v_Token := i_Buf.Sub_Str(v_Start, p - v_Start);
    
      v_Buf_Index := p;
    end Get_Number;
  
    Procedure Get_String(i_Quote varchar2) is
      p        pls_integer := v_Buf_Index;
      v_Quotes boolean := false;
      v_Length pls_integer;
    begin
    
      loop
      
        p := i_Buf.Find_Substr(i_Quote, p + 1);
      
        if p = 0 then
        
          Syntax_Error('');
        elsif p > 1 and i_Buf.Get_Char(p - 1) = '\' then
        
          if Is_Paired_Escape_Sym(p - 1) then
            exit;
          end if;
        elsif i_Buf.Get_Char(p + 1) = i_Quote then
        
          v_Quotes := true;
          p        := p + 1;
        else
          exit;
        end if;
      end loop;
    
      v_Length := p - v_Buf_Index - 1;
    
      if v_Length <= 32767 then
        v_Token_Type := c_Tt_String;
      
        v_Token := i_Buf.Sub_Str(v_Buf_Index + 1, v_Length);
      
        if v_Quotes then
          v_Token := replace(v_Token, i_Quote || i_Quote, i_Quote);
        end if;
      
        if Instr(v_Token, '\') > 0 then
          v_Token := Unescape(v_Token);
        end if;
      else
        v_Token_Type := c_Tt_Long_String;
      
        v_Token_Long := i_Buf.Sub_Str_Long(v_Buf_Index + 1, v_Length);
      
        if v_Quotes then
          v_Token_Long := v_Token_Long.Replace(i_Quote || i_Quote, i_Quote);
        end if;
      
        if v_Token_Long.Find_Substr('\', 1) > 0 then
          v_Token_Long := v_Token_Long.Unescape();
        end if;
      end if;
    
      v_Buf_Index := p + 1;
    end Get_String;
  
    Procedure Skip_Block_Comment is
      p pls_integer;
    begin
    
      p := i_Buf.Find_Substr('*' || '/', v_Buf_Index + 2);
    
      if p = 0 then
      
        Syntax_Error('Синтаксическая ошибка: не закрыть блочный комментарий!');
      end if;
    
      v_Buf_Index := p + 2;
    end Skip_Block_Comment;
  
    Procedure Skip_Line_Comment is
    begin
    
      while i_Buf.Get_Char_Code(v_Buf_Index) not in (c_Ch_Lf, c_Ch_Cr)
      loop
        v_Buf_Index := v_Buf_Index + 1;
      end loop;
    
      while i_Buf.Get_Char_Code(v_Buf_Index) in (c_Ch_Lf, c_Ch_Cr)
      loop
        v_Buf_Index := v_Buf_Index + 1;
      end loop;
    end Skip_Line_Comment;
  
    Procedure Get_Token(i_Is_Value boolean := false) is
      v_Sym pls_integer;
    begin
    
      loop
        v_Token := i_Buf.Get_Char(v_Buf_Index);
        v_Sym   := Ascii(v_Token);
      
        if v_Sym in (c_Ch_Space, c_Ch_Tab, c_Ch_Cr, c_Ch_Lf) then
          v_Buf_Index := v_Buf_Index + 1;
          exit when(v_Buf_Index > v_Buf_Size);
        elsif v_Sym = c_Ch_Comment and v_Buf_Index < v_Buf_Size then
        
          case i_Buf.Get_Char_Code(v_Buf_Index + 1)
            when c_Ch_Comment then
              Skip_Line_Comment;
            when c_Ch_Star then
              Skip_Block_Comment;
            else
              exit;
          end case;
        else
          exit;
        end if;
      end loop;
    
      v_Token_Pos := v_Buf_Index;
    
      if v_Buf_Index > v_Buf_Size then
        v_Token_Type := c_Tt_Buffer_End;
        return;
      end if;
    
      if v_Sym = c_Ch_Sngl_Quote or v_Sym = c_Ch_Dbl_Quote then
      
        Get_String(v_Token);
        return;
      elsif v_Sym = c_Ch_Comma then
      
        v_Token_Type := c_Tt_Comma;
      elsif v_Sym = c_Ch_Dpoint then
      
        v_Token_Type := c_Tt_Dbl_Point;
      elsif v_Sym = c_Ch_Json_Beg then
      
        v_Token_Type := c_Tt_Json_Beg;
      elsif v_Sym = c_Ch_Json_End then
      
        v_Token_Type := c_Tt_Json_End;
      elsif v_Sym = c_Ch_Array_Beg then
      
        v_Token_Type := c_Tt_Array_Beg;
      elsif v_Sym = c_Ch_Array_End then
      
        v_Token_Type := c_Tt_Array_End;
      elsif (v_Sym >= c_Ch_Numb_0 and v_Sym <= c_Ch_Numb_9) or (v_Sym = c_Ch_Point) or
            (v_Sym = c_Ch_Minus or v_Sym = c_Ch_Plus) then
      
        Get_Number(v_Sym);
        return;
      elsif (v_Sym >= c_Ch_Alpha_Ha and v_Sym <= c_Ch_Alpha_Hz) or
            (v_Sym >= c_Ch_Alpha_a and v_Sym <= c_Ch_Alpha_z) or v_Sym = c_Ch_Underline then
      
        Get_Ident(i_Is_Value);
        return;
      else
      
        v_Token_Type := c_Tt_Error;
        return;
      end if;
    
      v_Buf_Index := v_Buf_Index + 1;
    end Get_Token;
  
    Procedure Find_Symbol(i_Symbol varchar2) is
    begin
    
      while i_Buf.Get_Char_Code(v_Buf_Index) in (c_Ch_Space, c_Ch_Tab, c_Ch_Lf, c_Ch_Cr)
      loop
        v_Buf_Index := v_Buf_Index + 1;
      end loop;
    
      if v_Buf_Index > v_Buf_Size or i_Buf.Get_Char(v_Buf_Index) != i_Symbol then
      
        Syntax_Error();
      end if;
    end Find_Symbol;
  
    Function Get_Json return Hash_t is
      v_Json Hash_t;
    begin
    
      Internal_Parse_Json(i_Buf, v_Buf_Index, v_Json);
    
      return v_Json;
    end Get_Json;
  
    Function Parse_Array return Arraylist is
      v_Array Arraylist := Arraylist();
    begin
      v_Buf_Index := v_Buf_Index;
    
      loop
      
        Get_Token(true);
      
        if v_Token_Type = c_Tt_String then
          v_Array.Push(v_Token);
        elsif v_Token_Type = c_Tt_Number then
          v_Array.Push(to_number(v_Token, c_Fmt_Number));
        
        elsif v_Token_Type = c_Tt_Number_e then
          v_Array.Push(to_number(v_Token, c_Fmt_Number_e));
        
        elsif v_Token_Type = c_Tt_Long_String then
          v_Array.Push(String_Object_t(v_Token_Long));
          v_Token_Long := null;
        
        elsif v_Token_Type = c_Tt_Json_Beg then
          v_Buf_Index := v_Token_Pos;
          v_Array.Push(Get_Json());
        elsif v_Token_Type = c_Tt_Array_Beg then
          v_Array.Push(Parse_Array());
        elsif v_Token_Type = c_Tt_Null then
          v_Array.Push('');
        elsif v_Token_Type = c_Tt_Boolean then
          v_Array.Push(v_Token);
        
        elsif v_Token_Type = c_Tt_Array_End then
          exit;
        else
          Syntax_Error();
        end if;
      
        Get_Token;
      
        if v_Token_Type = c_Tt_Array_End then
          exit;
        elsif v_Token_Type != c_Tt_Comma then
          Syntax_Error();
        end if;
      end loop;
    
      return v_Array;
    end Parse_Array;
  
  begin
  
    if i_Buf is null then
      Raise_Application_Error(c_Err_Code, 'Не задано JSON-строка!');
    end if;
  
    Io_Json     := Hash_t();
    v_Buf_Index := Io_Pos;
    v_Token_Pos := Io_Pos;
    v_Buf_Size  := i_Buf.Get_Length();
  
    Find_Symbol('{');
    v_Buf_Index := v_Buf_Index + 1;
  
    while v_Buf_Index <= v_Buf_Size
    loop
      v_Set_Param := false;
      Get_Token;
    
      if v_Token_Type = c_Tt_Json_End then
        exit;
      elsif v_Token_Type != c_Tt_String and v_Token_Type != c_Tt_Ident then
        Syntax_Error();
      end if;
    
      v_Field_Name := v_Token;
      Find_Symbol(':');
      v_Buf_Index := v_Buf_Index + 1;
      Get_Token(true);
    
      if v_Token_Type = c_Tt_String then
      
        Io_Json.Put(v_Field_Name, v_Token);
        v_Set_Param := true;
      elsif v_Token_Type = c_Tt_Number then
      
        Io_Json.Put(v_Field_Name, to_number(v_Token, c_Fmt_Number));
        v_Set_Param := true;
      
      elsif v_Token_Type = c_Tt_Number_e then
        Io_Json.Put(v_Field_Name, to_number(v_Token, c_Fmt_Number_e));
        v_Set_Param := true;
      
      elsif v_Token_Type = c_Tt_Long_String then
        Io_Json.Put(v_Field_Name, String_Object_t(v_Token_Long));
        v_Token_Long := null;
      
      elsif v_Token_Type = c_Tt_Json_Beg then
      
        v_Buf_Index := v_Token_Pos;
      
        Io_Json.Put(v_Field_Name, Get_Json());
      elsif v_Token_Type = c_Tt_Array_Beg then
      
        Io_Json.Put(v_Field_Name, Parse_Array());
      elsif v_Token_Type = c_Tt_Null then
      
        Io_Json.Put(v_Field_Name, '');
        v_Set_Param := true;
      
      elsif v_Token_Type = c_Tt_Boolean then
      
        Io_Json.Put(v_Field_Name, v_Token);
        v_Set_Param := true;
      
      else
        Syntax_Error();
      end if;
      -- set temp 
      if g_Set_Param and v_Set_Param then
        Set_Temp_Table(v_Field_Name, v_Token);
      end if;
      --
    
      Get_Token;
    
      if v_Token_Type = c_Tt_Json_End then
        exit;
      elsif v_Token_Type = c_Tt_Comma then
        continue;
      else
        Syntax_Error();
      end if;
    end loop;
  
    Io_Pos := v_Buf_Index;
  end Internal_Parse_Json;

  Procedure Parse_Json
  (
    i_Json_Str in varchar2,
    Io_Json    in out nocopy Hash_t,
    i_Set_Temp in boolean default false
  ) is
    v_Pos pls_integer := 1;
  begin
    g_Set_Param := i_Set_Temp;
  
    Internal_Parse_Json(i_Json_Str, v_Pos, Io_Json);
  end Parse_Json;

  Procedure Parse_Json
  (
    i_Json_Str in Long_String,
    Io_Json    in out nocopy Hash_t,
    i_Set_Temp in boolean default false
  ) is
    v_Pos pls_integer := 1;
  begin
  
    g_Set_Param := i_Set_Temp;
    if i_Json_Str.Get_Length() <= 32767 then
      Internal_Parse_Json(i_Json_Str.To_String(), v_Pos, Io_Json);
    else
      Internal_Parse_Json(i_Json_Str, v_Pos, Io_Json);
    end if;
  end Parse_Json;

  Procedure Parse_Json
  (
    i_Json_Str in Array_Varchar2,
    Io_Json    in out nocopy Hash_t,
    i_Set_Temp in boolean default false
  ) is
    v_Pos pls_integer := 1;
  begin
    g_Set_Param := i_Set_Temp;
  
    if i_Json_Str is not null and i_Json_Str.Count = 1 then
    
      Internal_Parse_Json(i_Json_Str(1), v_Pos, Io_Json);
    else
    
      Parse_Json(Long_String(i_Json_Str), Io_Json, i_Set_Temp);
    end if;
  end Parse_Json;

  Procedure Parse_Json
  (
    i_Json_Str in clob,
    Io_Json    in out nocopy Hash_t,
    i_Set_Temp in boolean default false
  ) is
  begin
  
    Parse_Json(Long_String(i_Json_Str), Io_Json, i_Set_Temp);
  end Parse_Json;

  Function Parse_Json(i_Json_Str varchar2) return Hash_t is
    v_Pos  pls_integer := 1;
    v_Json Hash_t;
  begin
  
    Internal_Parse_Json(i_Json_Str, v_Pos, v_Json);
  
    return v_Json;
  end Parse_Json;

  Function Parse_Json(i_Json_Str Long_String) return Hash_t is
    v_Json Hash_t;
  begin
  
    Parse_Json(i_Json_Str, v_Json);
  
    return v_Json;
  end Parse_Json;

  Function Parse_Json(i_Json_Str Array_Varchar2) return Hash_t is
    v_Json Hash_t;
  begin
  
    Parse_Json(i_Json_Str, v_Json);
  
    return v_Json;
  end Parse_Json;

  Function Parse_Json(i_Json_Str clob) return Hash_t is
  begin
  
    return Parse_Json(Long_String(i_Json_Str));
  end Parse_Json;

end Json_Parser;
/
