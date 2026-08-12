create or replace package Core_Sidebar is

  ----------------------------------------------------------------------------------------------------
  -- main.jsp uchun ruxsat-nazoratli, IERARXIK sidebar. To'g'ridan-to'g'ri user->menu grant
  -- (ADM_REL_USER_MENUS), ROL YO'Q. Faqat o'qish uchun.
  --
  -- Foydalanuvchi FAQAT ishonchli UAPP kontekstidan olinadi (Core.User_Env.Get_User_Id).
  -- Parametr sifatida user_id QABUL QILINMAYDI - chaqiruvchi uzatgan identifikatorga
  -- ishonmaslik (spoofing'ga qarshi) uchun. Kontekstni auth (Auth_Session.Set_Context)
  -- har so'rovda o'rnatib beradi.
  --
  -- Qaytariladigan to'plam = grant qilingan yaproqlar + ularning barcha ota-guruhlari
  -- (guruh sarlavhalari ular alohida grant qilinmasa ham ko'rinishi uchun).
  --
  -- Har bir o_Items elementi, Chr(1) bilan ajratilgan 5 maydon:
  --   Menu_Id || Chr(1) || Parent_Menu_Id || Chr(1) || Page_Url || Chr(1) || Label || Chr(1) || Menu_Type
  -- Page_Url guruh-parent'da '#'. Grant yo'q / kontekst yo'q bo'lsa - bo'sh kolleksiya.
  ----------------------------------------------------------------------------------------------------
  procedure Get_User_Menu
  (
    o_Items out Array_Varchar2
  );

  ----------------------------------------------------------------------------------------------------
  -- PageInitFilter uchun: joriy foydalanuvchiga GRANT qilingan, navigatsiya qilinadigan
  -- (page_url is not null va '#' emas) sahifa URL'lari. Get_User_Menu'dan farqli -
  -- ota-guruhlarni QO'SHMAYDI (filter uchun daraxt kerak emas, faqat "shu URL'ga ruxsat
  -- bormi" degan yassi to'plam). Bir xil URL bir nechta menu_id ostida ro'yxatga olingan
  -- bo'lishi mumkin (masalan bir nechta modulda ishlatiladigan umumiy JSP) - shulardan
  -- BIRIGA ham grant bo'lsa, URL ruxsat ro'yxatiga kiradi.
  ----------------------------------------------------------------------------------------------------
  procedure Get_User_Page_Urls
  (
    o_Urls out Array_Varchar2
  );

  ----------------------------------------------------------------------------------------------------
  -- PageInitFilter uchun: hozircha CORE_R_MENUS'da RO'YXATGA OLINGAN barcha faol
  -- sahifa URL'lari (foydalanuvchidan qat'i nazar). Filter buni "bu sahifa umuman
  -- ro'yxatdami" tekshiruvi uchun ishlatadi - ro'yxatda yo'q sahifalar hali page-init
  -- nazoratiga o'tkazilmagan deb hisoblanadi (bloklanmaydi), ro'yxatda bor lekin
  -- grant qilinmagan sahifalar esa bloklanadi.
  ----------------------------------------------------------------------------------------------------
  procedure Get_All_Page_Urls
  (
    o_Urls out Array_Varchar2
  );

  ----------------------------------------------------------------------------------------------------
  -- PageInitFilter uchun: joriy userga GRANT qilingan sahifa+button juftliklari.
  -- Har element: Page_Url || Chr(1) || Process_Code (Core_Api.Check_Process_Access bilan bir
  -- xil avtorizatsiya identifikatori - Action_Code emas, u faqat ko'rsatish/i18n kaliti).
  ----------------------------------------------------------------------------------------------------
  procedure Get_User_Button_Codes
  (
    o_Items out Array_Varchar2
  );

  ----------------------------------------------------------------------------------------------------
  -- PageInitFilter uchun: RO'YXATGA OLINGAN barcha faol sahifa+button (process_code) juftliklari
  -- (userdan qat'i nazar). "Bu sahifada umuman qanday buttonlar bor" tekshiruvi uchun.
  ----------------------------------------------------------------------------------------------------
  procedure Get_All_Button_Codes
  (
    o_Items out Array_Varchar2
  );

end Core_Sidebar;
/
create or replace package body Core_Sidebar is
  ----------------------------------------------------------------------------------------------------
  procedure Get_User_Menu
  (
    o_Items out Array_Varchar2
  ) is
    v_User_Id number := Core.User_Env.Get_User_Id;
  begin
    o_Items := Array_Varchar2();

    -- Kontekstda user_id yo'q bo'lsa (auth kontekstni o'rnatmagan) - bo'sh, xato bermaydi.
    if v_User_Id is null then
      return;
    end if;

    -- Ko'rinadigan menyular = grant qilingan yaproqlar + ularning barcha ota-guruhlari.
    --   * Ichki so'rov (vis): grant'langan menyulardan boshlab ierarxiya bo'ylab YUQORIGA
    --     yurib (prior parent = menu_id) barcha ota-guruhlarni yig'adi.
    --   * Tashqi so'rov: butun faol daraxtni ildizdan PASTGA qurib, order siblings by order_by
    --     bilan to'g'ri ko'rsatish tartibida qaytaradi; keyin ko'rinadigan to'plamga filtrlaydi.
    -- Ildiz = parent_menu_id biror faol menu_id'ga ishora qilmaydigan tugun. Bind: v_User_Id.
    select m.Menu_Id            || Chr(1) ||
           m.Parent_Menu_Id     || Chr(1) ||
           Nvl(m.Page_Url, '#') || Chr(1) ||
           Mll_Core_Api.Get_Label(i_Module_Code   => m.module_code ,
                                  i_Message_Code  => m.name_mll_code
                                  ) || Chr(1) ||
           Nvl(m.Menu_Type, '')
      bulk collect into o_Items
      from Core.Core_R_Menus m
     where m.State = 'A'
       -- PAGE = sidebar'da ko'rinmaydigan, faqat ruxsat-nazorat uchun ro'yxatga
       -- olingan ichki sahifa (masalan users.jsp'dan ochiladigan user.jsp).
       -- PUBLIC = har bir login qilgan userga ochiq sahifa (grant kerak emas).
       and Nvl(m.Menu_Type, ' ') not in ('PAGE', 'PUBLIC')
       and m.Menu_Id in
           ( select vis.Menu_Id
               from Core.Core_R_Menus vis
              where vis.State = 'A'
              start with vis.Menu_Id in
                    ( select um.Menu_Id
                        from Core.ADM_REL_USER_MENUS um
                       where um.User_Id = v_User_Id
                         and um.State   = 'A'
                         and sysdate between um.Date_Activate and um.Date_Deactivate )
            connect by nocycle prior vis.Parent_Menu_Id = To_Char(vis.Menu_Id) )
     start with m.Parent_Menu_Id not in
                ( select To_Char(r.Menu_Id) from Core.Core_R_Menus r where r.State = 'A' )
    connect by nocycle prior To_Char(m.Menu_Id) = m.Parent_Menu_Id
     order siblings by m.Order_By;

  end Get_User_Menu;
  ----------------------------------------------------------------------------------------------------
  procedure Get_User_Page_Urls
  (
    o_Urls out Array_Varchar2
  ) is
    v_User_Id number := Core.User_Env.Get_User_Id;
  begin
    o_Urls := Array_Varchar2();

    if v_User_Id is null then
      return;
    end if;

    -- 1-qism: to'g'ridan-to'g'ri menu granti bilan ochiladigan sahifalar.
    -- 2-qism: grant qilingan NAVIGATSIYA buttonlari ochib beradigan ichki
    -- sahifalar (Button_Menu_Id -> PAGE-turdagi menyu satri). Ichki sahifaga
    -- alohida menu-grant KERAK EMAS - button granti o'zi yetadi.
    select Page_Url
      bulk collect into o_Urls
      from ( select m.Page_Url
               from Core.Core_R_Menus m
               join Core.ADM_REL_USER_MENUS um on um.Menu_Id = m.Menu_Id
              where m.State    = 'A'
                and m.Page_Url is not null
                and m.Page_Url != '#'
                and um.User_Id = v_User_Id
                and um.State   = 'A'
                and sysdate between um.Date_Activate and um.Date_Deactivate
             union
             select m2.Page_Url
               from Core.Core_R_Menu_Buttons b
               join Core.ADM_REL_USER_BUTTONS ub
                 on ub.Menu_Id = b.Menu_Id and ub.Button_Id = b.Button_Id
               join Core.Core_R_Menus m2 on m2.Menu_Id = b.Button_Menu_Id
              where b.State    = 'A'
                and m2.State   = 'A'
                and m2.Page_Url is not null
                and m2.Page_Url != '#'
                and ub.User_Id = v_User_Id
                and ub.State   = 'A'
                and sysdate between ub.Date_Activate and ub.Date_Deactivate
             union
             -- 3-qism: PUBLIC sahifalar - har bir login qilgan userga doimiy
             -- ochiq (parol almashtirish kabi). Grant talab qilinmaydi.
             select m3.Page_Url
               from Core.Core_R_Menus m3
              where m3.State     = 'A'
                and m3.Menu_Type = 'PUBLIC'
                and m3.Page_Url  is not null
                and m3.Page_Url != '#' );
  end Get_User_Page_Urls;
  ----------------------------------------------------------------------------------------------------
  procedure Get_All_Page_Urls
  (
    o_Urls out Array_Varchar2
  ) is
  begin
    select distinct m.Page_Url
      bulk collect into o_Urls
      from Core.Core_R_Menus m
     where m.State    = 'A'
       and m.Page_Url is not null
       and m.Page_Url != '#';
  end Get_All_Page_Urls;
  ----------------------------------------------------------------------------------------------------
  procedure Get_User_Button_Codes
  (
    o_Items out Array_Varchar2
  ) is
    v_User_Id number := Core.User_Env.Get_User_Id;
  begin
    o_Items := Array_Varchar2();

    if v_User_Id is null then
      return;
    end if;

    select m.Page_Url || Chr(1) || b.Process_Code
      bulk collect into o_Items
      from Core.Core_R_Menus m
      join Core.Core_R_Menu_Buttons b on b.Menu_Id = m.Menu_Id
      join Core.ADM_REL_USER_BUTTONS ub
        on ub.Menu_Id = b.Menu_Id and ub.Button_Id = b.Button_Id
     where m.State        = 'A'
       and m.Page_Url     is not null
       and m.Page_Url     != '#'
       and b.State        = 'A'
       and b.Process_Code is not null
       and ub.User_Id     = v_User_Id
       and ub.State       = 'A'
       and sysdate between ub.Date_Activate and ub.Date_Deactivate;
  end Get_User_Button_Codes;
  ----------------------------------------------------------------------------------------------------
  procedure Get_All_Button_Codes
  (
    o_Items out Array_Varchar2
  ) is
  begin
    select distinct m.Page_Url || Chr(1) || b.Process_Code
      bulk collect into o_Items
      from Core.Core_R_Menus m
      join Core.Core_R_Menu_Buttons b on b.Menu_Id = m.Menu_Id
     where m.State        = 'A'
       and m.Page_Url     is not null
       and m.Page_Url     != '#'
       and b.State        = 'A'
       and b.Process_Code is not null;
  end Get_All_Button_Codes;
  ----------------------------------------------------------------------------------------------------
end Core_Sidebar;
/
