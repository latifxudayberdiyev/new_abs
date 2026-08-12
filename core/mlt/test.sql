
  -------------------------------------------------------------------------------------------------------------
-- get message for developer

-- 1-variant: i_Params bilan
declare
  v_Code number;
  v_Msg  varchar2(4000);
begin
  Mle_Util.Get_Error_Message(
    i_Module_Code   => 'MLT',
    i_Message_Code  => 'TEMPLATE_CREATED',
    i_Lang_Index    => 3,
    i_Format_String => '$',
    i_Params        => Array_Varchar2('ali'),
    o_Code          => v_Code,
    o_Msg           => v_Msg
  );
  dbms_output.put_line( v_msg);
end;


  -------------------------------------------------------------------------------------------------------------
-- get error message for developer

declare 
 v_msg varchar(2000);
 v_code number;
begin 
 -- mlt_core_api.get_error_message(i_Module_Code   => 'MLT',
                                -- i_Message_Code  => 'TEMPLATE_NOT_FOUND',
                               --  o_Code          => v_Code,
                              --   o_Msg           => v_Msg);

   Mlt_Util.Get_Error_Message(i_Module_Code  => 'MFI',
                                 i_Message_Code => 'TEST12',
                                 o_Code         => v_Code,
                                 o_Msg          => v_Msg  )  ;                            
  dbms_output.put_line('result ' || v_msg || ' ' || v_Code);
end;

  -------------------------------------------------------------------------------------------------------------
-- create error message with code for developer

declare
  v_code number(12);
  v_msg varchar2(4000);
begin 
  mle_dev_api.Save_Template_Error(
  i_Message_Code        => 'TEST12',
  i_Description         => 'Module code talab qilinadi',
  i_Param_Count         => 1,
  i_Format_String       => '$',
  i_Message_Mask_Lang1  => 'templateD $1 CREATED rus',
  i_Message_Mask_Lang2  => 'template $1 CREATED krill',
  i_Message_Mask_Lang3  => 'template $1 CREATED uzbek',
  i_Message_Mask_Lang4  => null,
  i_Message_Mask_Lang5  => null,
  i_Message_Mask_Lang6  =>null ,
  i_Message_Mask_Lang7  => null,
  i_Message_Mask_Lang8  => null,
  i_Message_Mask_Lang9  => null,
  i_Message_Mask_Lang10 => null,
  i_Module_Code         => 'MFI',
  i_Error_Code          => null,
  o_code                => v_code,
  o_Msg                 => v_msg);
  dbms_output.put_line('result: ' || v_msg);
end;

  -------------------------------------------------------------------------------------------------------------
-- create template with sm api 

declare
  v_Hash Core.Hash_t := Core.Hash_t;
  v_Arr  core.Array_Varchar2;
  v_cache Core.Hash_t:=Core.hash_t;
  v_Code number;
  v_Msg  varchar2(200);
  v_Ora  varchar2(4000);
begin
  v_Hash :=Core.Hash_t();

  v_Arr:=Core.Array_varchar2();
  v_Arr.extend(3);
  
  v_Cache.Put('is_create','Y');
  v_Hash.Put('sm_cache',v_Cache);
  
  v_Hash.Put('message_code', 'MESSAGE_CODE_REQUIRED_TEST1');
  v_Hash.Put('description', 'Message kernel');
  v_Hash.Put('param_count', 1);
  v_Hash.Put('format_string','$');

  v_Arr(1):='Message code talab etiladi';
  v_Arr(2):='Message code required';
  v_Arr(3):='Код сообщения обязателен';
  
  v_Hash.Put('message_masks',v_Arr);
  Mlt_Sm_Api.Save_Template(Io_Hash => v_Hash, o_Msg => v_Msg);
  Dbms_Output.Put_Line(v_Code || ' - ' || v_Msg);
end;

  -------------------------------------------------------------------------------------------------------------
-- Procedure sifatida:
declare
  v_Label varchar2(4000);
  v_Code  number;
  v_Msg   varchar2(4000);
begin
  Mll_Core_Api.Get_Label(
    i_Module_Code  => 'MLT',
    i_Message_Code => 'SAVE_BUTTON',
    i_Lang_Index   =>2, --IXTIYORIY DEFAULT 3
    i_Format_String => '$',  -- IXTIYORIY DEFAULT $ BELGISI
    i_Params       => Core.Array_Varchar2('salom'),
    o_Label        => v_Label,
    o_Code         => v_Code,
    o_Msg          => v_Msg
  );
  dbms_output.put_line(v_Label);
end;
 --------------------------------------------------------------------------------------------------------------
-- Function sifatida
select Mll_Core_Api.Get_Label(i_Module_Code   => 'MLT',
                             i_Message_Code  => 'SAVE_BUTTON',
                             i_Lang_Index    => 2,  --IXTIYORIY DEFAULT 3
                             i_Format_String => '$', -- IXTIYORIY DEFAULT $ BELGISI
                             i_Params        => CORE.ARRAY_VARCHAR2('SALOM')
                           ) FROM DUAL;



  -------------------------------------------------------------------------------------------------------------
----------- selec mlt template

select  t.* from mlt_templates t;
union all
select  e.* from mlt_error_codes e;
union all
select  l.* from mlt_languages l;

select * from mlt_error_codes;

select * from mlt_languages;

-------------------------------
-----------delect mlt template 
declare 
 v_msg varchar2(4000);

begin 
  Mlt_Kernel.Delete_Error_Code(
  i_Module_Code => 'MFI',
  i_Message_Code => 'Test_Error_1',
  o_msg=> v_msg
  );
end;  

------------------------------

declare
 v_msg varchar2(4000);
 v_code number;
begin 
  mlt_core_api.set_Lang_index(1, v_msg, v_code);
  dbms_output.put_line('result' || v_msg || ' ' || v_code);
end;
-----------------------------

begin 
 Mlt_Core_Api.Clear_Lang_Index;
end;


begin 
  dbms_output.put_line('lang=' || mlt_cache.Lang_Index);
  
end;
------------------------------------------------------------
-- error  yaratish template bilan bittada
------------------------------------------------------------

declare
    v_msg  varchar2(4000);
    v_code number;
begin

    mle_dev_api.Save_Template_Error(
        i_Message_Code      => 'LABEL_UPDATED',
        i_Description       => 'Label yangilandi',
        i_Param_Count       => 1,
        i_Format_String     => '$',

        
        i_Message_Mask_Lang1 => 'Метка $ успешно обновлена',
        i_Message_Mask_Lang2 => '$ label muvaffaqiyatli yangilandi',
        i_Message_Mask_Lang3 => '$ label muvaffaqiyatli yangilandi',
        i_Message_Mask_Lang4 => '$ label updated successfully',


        i_Message_Mask_Lang5 => null,
        i_Message_Mask_Lang6 => null,
        i_Message_Mask_Lang7 => null,
        i_Message_Mask_Lang8 => null,
        i_Message_Mask_Lang9 => null,
        i_Message_Mask_Lang10 => null,

        i_Module_Code       => 'MLT',
        i_Error_Code        => null,

        o_Code              => v_code,
        o_Msg               => v_msg
    );

    dbms_output.put_line(
        'result: ' || v_msg || ' code ' || v_code
    );

end;

-------------------------------------------------------

select * from mlt_error_codes ;

select t.*, t.rowid from mlt_error_codes t;

select * from mlt_templates;

select mlt_dev_api.Get_Next_Error_Code('MFI') as next_code from dual;

select mlt_dev_api.Get_free_error_code('MFI') as next_code from dual;





-------------------------------------------------------------



declare 
 v_Code number;
 v_Msg  varchar2(4000);
begin 
   mlt_util.Get_Error_Message(i_Module_Code   => 'MLT',
                              i_Message_Code  => 'LABEL_CREATED',
                              i_Params        => Core.Array_Varchar2('test'),
                              o_Code          => v_Code ,
                              o_Msg           => v_Msg);
   dbms_output.put_line( 'result ' || v_code || ' ' || v_msg);
end;

------------------------------------------------------------------------------------------------------


declare 

begin
  mlt_core_api.Raise_Error(i_Module_Code   => 'MFI',
                           i_Message_Code  => 'TEMPLATE_CREATED',
                           i_Params        => array_varchar2('ali'));

end;


declare
v_Code number;
v_Msg varchar2(4000);
begin
  mlt_dev_api.Connect_Error_Code(i_Module_Code  => 'MLT',
                                 i_Message_Code => 'TEMPLATE_UPDATED',
                                 i_Description  => 'template update uchun',
                                 o_Code         => v_Code,
                                 o_Msg          => v_Msg);
  dbms_output.put_line( 'result: ' ||  v_Msg || ' ' || v_Code);                               
end;
  


select t.*, rowid from mlt_error_codes t;


SELECT T.*, ROWID FROM MLT_TEMPLATES T;

SELECT * FROM MLT_LANGUAGES;


select * from mll_label_codes;

delete from mlt_templates where template_id=36;

---------------------------------------------------------------------------------------------------------------
select t.*, rowid from mll_label_codes t;

select t.*, rowid from mlt_error_codes t;

select t.*,rowid from mlt_templates t;
-----------------------------------------------------------------------------------

declare
    v_Hash   Core.Hash_t := Core.Hash_t;
    v_Arr    Core.Array_Varchar2;
    v_Cache  Core.Hash_t := Core.Hash_t;
    v_Code   number;
    v_Msg    varchar2(4000);
begin
    v_Hash := Core.Hash_t;
    v_Cache.Put('is_create', 'Y');
    v_Hash.Put('sm_cache', v_Cache);
    
    v_Arr := Core.Array_Varchar2();
    v_Arr.Extend(4);
    v_Arr(1) := 'Кнопка $ yangilandi';
    v_Arr(2) := '$ tugmasi yangilandi';
    v_Arr(3) := '$ tugmasi yangilandi';
    v_Arr(4) := '$ button yangilandi';
    
    v_Hash.Put('module_code', 'MLT');
    v_Hash.Put('message_code', 'CHAGE_BUTTON');
    v_Hash.Put('description', 'save button');
    v_Hash.Put('param_count', 1);
    v_Hash.Put('format_string', '$');
    v_Hash.Put('message_masks', v_Arr);
    Mll_Kernel.Save_Label_With_Template(
        Io_Hash => v_Hash,
        o_Code  => v_Code,
        o_Msg   => v_Msg
    );
    Dbms_Output.Put_Line('code = ' || v_Code);
    Dbms_Output.Put_Line('msg  = ' || v_Msg);
end;


------------------------------------



select * from mll_label_codes;

insert into core.r_menus (MODULE_CODE, MENU_ID, PARENT_ID, GROUP_NUMBER, ORDER_NUMBER, LABEL, JAVASCRIPT_ACTION, CONDITION, FORM_CODE, MENU_TYPE)
values ('TAX', 9001, 1000, 0, 13, '<Collection>', 'menuBody.go({url:"/ibs/tax/ref/test.jsp"})', 'A', 1000, 'M');

select t.*,rowid from core.r_menus t
 where t.module_code = 'TAX' and t.javascript_action like '%lazizbek%' or t.javascript_action like '%test%'
 
select menu_id, label
from core.r_menus
where menu_id = 9001;

update core.r_menus
set label = core.ml_label_t(
    'Тест',
    'Test',
    'Test',
    null
)
where menu_id = 9001;
-------------------------------------------


select * from sm_process_protocols;

select Core.User_Env from dual;
 Core.User_Env.Get_Format_Date



select * from sm_process_request_responses t where t.process_code = 'SAVE_TEMPLATE';

-----------------------------------------------------------------------------------------------------

declare
    v_Label varchar2(4000);
    v_Code  number;
    v_Msg   varchar2(4000);
begin
    Mll_Core_Api.Get_Label(
        i_Module_Code  => 'MLT',
        i_Message_Code => 'MLT_SUB_LABEL',
        o_Label        => v_Label,
        o_Code         => v_Code,
        o_Msg          => v_Msg
    );

    dbms_output.put_line('Code  = ' || v_Code);
    dbms_output.put_line('Msg   = ' || v_Msg);
    dbms_output.put_line('Label = ' || v_Label);
end;

-----------------------------------------------------------------------------------------------------








