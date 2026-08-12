
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MPT_PRINT_SETTING_FILES_H_V" ("LOG_ID", "SETTING_ID", "LANG_CODE", "LANG_NAME", "FILE_ID", "FILE_NAME", "DOWNLOAD_LINK", "ACTION_CODE", "ACTION_NAME", "MODIFIED_BY", "MODIFIED_BY_NAME", "ACTION_DATE") AS
  select h.Log_Id,
         h.Setting_Id,
         h.Lang_Code,
         l.Lang_Name,
         h.File_Id,
         h.File_Name,
         '<a href="print_setting_download.jsp?file_id=' || h.File_Id ||
         '&file_name=' || Mpt_Url_Escape(Nvl(h.File_Name, 'file')) ||
         '" target="_blank">Yuklab olish</a>' as Download_Link,
         h.Action as Action_Code,
         Mpt_Action_Name(h.Action) as Action_Name,
         h.Modified_By,
         u.Name as Modified_By_Name,
         h.Action_Date
    from Mpt_Print_Setting_Files_H h
    left join Mpt_Languages_V l
      on l.Lang_Code = h.Lang_Code
    left join Core.Core_Users u
      on u.User_Id = h.Modified_By
   where h.Setting_Id = Core.User_Session.Get_Varchar2('mpt_print_setting_id')
   order by h.Log_Id desc
;

