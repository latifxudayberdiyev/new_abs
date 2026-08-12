----------------------------------------------------------------------------------------------------
--  Manba bazadagi 19 ta REF_* spravochnik jadvalidan INSERT skriptini generatsiya qilish
--  (bizdagi CBR_* jadvallarimiz nomiga mos, lekin manbada REF_ prefiksi bilan).
--  Ishga tushirish: ushbu (tayyor ma'lumotli) bazaga ulanib, F8 (Execute as Script).
--  Natija spool fayliga yoziladi: export_ref_source_tables.sql
----------------------------------------------------------------------------------------------------
set serveroutput on size unlimited
set linesize 32767
set trimspool on
set pagesize 0
set feedback off
set heading off
set echo off

spool export_ref_source_tables.sql

declare
  type t_names is table of varchar2(60);
  v_names t_names := t_names(
    'ref_subject_type',
    'ref_subject_sexual_identity',
    'ref_verifying_document_type',
    'ref_bank',
    'ref_bank_type',
    'ref_region',
    'ref_currency',
    'ref_country',
    'ref_document',
    'ref_rez_cl',
    'ref_district',
    'ref_tax_organization',
    'ref_form_property',
    'ref_organization_legal_form',
    'ref_nation',
    'ref_obraz',
    'ref_coato',
    'ref_business_form',
    'ref_mahalla'
  );
  --------------------------------------------------------------------------------------------------
  procedure Export_Data(p_table_name in varchar2) is
    c_cursor      integer;
    v_desc_tab    Dbms_Sql.Desc_Tab2;
    v_col_cnt     integer;
    v_col_list    varchar2(4000) := '';
    v_sql         varchar2(4000);
    v_row_cnt     pls_integer := 0;
    v_line        varchar2(32000);
    v_val_str     varchar2(4000);
    v_val_num     number;
    v_val_date    date;
  begin
    for r in (select column_name, data_type
                from all_tab_columns
               where table_name = upper(p_table_name)
                 and owner = (select owner from all_tables where table_name = upper(p_table_name) and rownum = 1)
               order by column_id)
    loop
      if r.data_type in ('NUMBER', 'FLOAT', 'VARCHAR2', 'CHAR', 'NVARCHAR2', 'NCHAR', 'DATE') or r.data_type like 'TIMESTAMP%' then
        v_col_list := v_col_list || case when v_col_list is not null then ', ' end || r.column_name;
      end if;
    end loop;
    --
    v_sql := 'select ' || v_col_list || ' from ' || p_table_name;
    c_cursor := Dbms_Sql.Open_Cursor;
    Dbms_Sql.Parse(c_cursor, v_sql, Dbms_Sql.Native);
    Dbms_Sql.Describe_Columns2(c_cursor, v_col_cnt, v_desc_tab);
    --
    for i in 1 .. v_col_cnt loop
      case
        when v_desc_tab(i).col_type in (2, 100, 101) then
          Dbms_Sql.Define_Column(c_cursor, i, v_val_num);
        when v_desc_tab(i).col_type in (12, 178, 179, 180, 181) then
          Dbms_Sql.Define_Column(c_cursor, i, v_val_date);
        else
          Dbms_Sql.Define_Column(c_cursor, i, v_val_str, 4000);
      end case;
    end loop;
    --
    v_row_cnt := Dbms_Sql.Execute(c_cursor);
    --
    Dbms_Output.Put_Line('-- DATA: ' || p_table_name);
    while Dbms_Sql.Fetch_Rows(c_cursor) > 0 loop
      v_line := 'insert into ' || p_table_name || ' (' || v_col_list || ') values (';
      for i in 1 .. v_col_cnt loop
        if v_desc_tab(i).col_type in (2, 100, 101) then
          Dbms_Sql.Column_Value(c_cursor, i, v_val_num);
          v_line := v_line || nvl(to_char(v_val_num), 'null');
        elsif v_desc_tab(i).col_type in (12, 178, 179, 180, 181) then
          Dbms_Sql.Column_Value(c_cursor, i, v_val_date);
          if v_val_date is null then
            v_line := v_line || 'null';
          else
            v_line := v_line || 'to_date(''' || to_char(v_val_date, 'dd.mm.yyyy hh24:mi:ss') || ''',''dd.mm.yyyy hh24:mi:ss'')';
          end if;
        else
          Dbms_Sql.Column_Value(c_cursor, i, v_val_str);
          if v_val_str is null then
            v_line := v_line || 'null';
          else
            v_line := v_line || '''' || replace(v_val_str, '''', '''''') || '''';
          end if;
        end if;
        if i < v_col_cnt then
          v_line := v_line || ', ';
        end if;
      end loop;
      v_line := v_line || ');';
      Dbms_Output.Put_Line(v_line);
    end loop;
    Dbms_Output.Put_Line('commit;');
    Dbms_Output.Put_Line(' ');
    Dbms_Sql.Close_Cursor(c_cursor);
  exception
    when others then
      if Dbms_Sql.Is_Open(c_cursor) then
        Dbms_Sql.Close_Cursor(c_cursor);
      end if;
      Dbms_Output.Put_Line('-- DATA OLINMADI (' || p_table_name || '): ' || sqlerrm);
  end;
  --------------------------------------------------------------------------------------------------
begin
  for i in 1 .. v_names.count loop
    Dbms_Output.Put_Line('================================================================================');
    Dbms_Output.Put_Line('=== ' || i || '/' || v_names.count || ' :: ' || v_names(i));
    Dbms_Output.Put_Line('================================================================================');
    Export_Data(v_names(i));
  end loop;
end;
/

spool off
