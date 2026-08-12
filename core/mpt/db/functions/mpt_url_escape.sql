
  CREATE OR REPLACE EDITIONABLE FUNCTION "MPT_URL_ESCAPE" (p_text in varchar2) return varchar2 is
  begin
    if p_text is null then
      return null;
    end if;
    return Utl_Url.Escape(p_text, true, 'UTF-8');
  end Mpt_Url_Escape;
/

