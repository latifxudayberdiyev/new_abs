create or replace package phys_person_pk is

  -- Author  : A.RAXMATILLAYEV
  -- Created : 03.08.2026 15:16:26
  -- Purpose : Getter Setter Save Update methods for Physical Clients
  
  

end phys_person_pk;
/
create or replace package body phys_person_pk is

 Procedure Client_Save(Io_Hash in out nocopy hash_t,o_Code out varchar2,o_Msg otuu varchar2,o_Ora_Msg out varchar2) is 
   v_Esbo_Req hash_t := hash_t();
 begin
   v_Esbo_Req.Put('pinfl',Io_Hash.Get_Optional_Varchar2('pinfl'));
   v_Esbo_Req.Put('last_name',Io_Hash.Get_Optional_Varchar2('last_name'));
   v_Esbo_Req.Put('first_name',Io_Hash.Get_Optional_Varchar2('first_name'));
   v_Esbo_Req.Put('patronymic',Io_Hash.Get_Optional_Varchar2('patronymic'));
   v_Esbo_Req.Put('last_name_cyr',Io_Hash.Get_Optional_Varchar2('last_name_cyr'));
   v_Esbo_Req.Put('first_name_cyr',Io_Hash.Get_Optional_Varchar2('first_name_cyr'));
   v_Esbo_Req.Put('patronymic_cyr',Io_Hash.Get_Optional_Varchar2('patronymic_cyr'));
   v_Esbo_Req.Put('physical_status_cd',Io_Hash.Get_Optional_Varchar2('physical_status_cd'));
   v_Esbo_Req.Put('death_date',Io_hash.Get_Optional_Date('death_date'));
   v_Esbo_Req.Put('birth_date',Io_Hash.Get_Optional_('birth_date'));
   v_Esbo_Req.Put('birth_place',Io_Hash.Get_Optional_Varchar2('birth_place'));
   v_Esbo_Req.Put('birth_place_id',IO_Hash.Get_Optional_Varchar2('birth_place_id'));
   v_Esbo_Req.Put('birth_country_code',Io_Hash.Get_Optional_Varchar2('birth_county_code'));
   v_Esbo_Req.Put('citizenship',Io_Hash.Get_Optional_Varchar2('citizenship'));
   v_Esbo_Req.Put('nationality_code',Io_Hash.Get_Optional_Varchar2('nationality_code'));
   v_Esbo_Req.Put('gender_cd',Io_Hash.Get_Optional_Varchar2('gender_cd'));
   v_Esbo_Req.Put('resident_flag',Io_Hash.Get_Optional_Varchar2('resident_flag'));
   v_Esbo_Req.Put('secret_word_enc',Io_Hash.Get_Optional_Varchar2('secret_word_enc'));
   v_Esbo_Req.Put('segment_code',Io_Hash.Get_Optional_Varchar2('segment_code'));
   v_Esbo_Req.Put('sub_segment_cd',Io_Hash.Get_Optional_Varchar2('sub_segment_cd'));
   v_Esbo_Req.Put('client_status_cd',Io_Hash.Get_Optional_Varchar2('client_status_cd'));
    --
    Io_Hash.Put('esbo_request', v_Esbo_Req);
    --
    Esbo_Sm_Api.Psb_Service_Api(Io_Hash   => Io_Hash,
                                o_Code    => o_Code,
                                o_Msg     => o_Msg,
                                o_Ora_Msg => o_Ora_Msg);
 end Client_Save;
 
 --------------------------------------------------------------------- 
 Procedure Open_Client() is 
   
 begin
   
 end Open_Client;
 
end phys_person_pk;
/
