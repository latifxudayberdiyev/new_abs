<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%!
	static final int si_favorite = SI("Недавно посещенные формы", "Охирги кўрилган формалар", "Oxirgi ko'rilgan formalar", "Recently visited form");
	static final int si_shortcut = SI("Помеченные", "Танланганлар", "Tanlanganlar", "Favorites");
	static final int si_report = SI("Отчёты", "Хисоботлар", "Hisobotlar", "Reports");
	static final int si_pie = SI("PIE", "Хисоботлар", "Hisobotlar", "Reports");
	static final int si_sysdate = SI("Системная дата", "Тизим санаси", "Tizim sanasi", "System date");
	static final int si_messages = SI("Сообщения", "Хабарлар", "Xabarlar", "Messages");
	static final int si_exit = SI("Выход", "Чи&#1179;иш", "Chiqish", "Exit");
	static final int si_ask = SI("Вы действительно хотите выйти?", "Сиз ха&#1179;и&#1179;атдан хам тизимдан чи&#1179;мо&#1179;чимисиз?", "Siz haqiqatdan ham tizimdan chiqmoqchimisiz?", "Are you sure you want to log out?");
	static final int si_open = SI("Открыт", "Очик", "Ochiq", "Opened");
	static final int si_close = SI("Закрыт", "Ёпи&#1179;", "Yopiq", "Closed");
	static final int si_iabs = SI("Интегрированная Автоматизированная Банковская Система", "Интеграллаштирилган Автоматлаштирилган Банк Тизими", "Integrallashtirilgan Avtomatlashtirilgan Bank Tizimi", "Integrated Automated Banking System");
	static final int si_info = SI("Инфо", "Маълумот", "Ma`lumot", "Info");
	//static final int si_info							= SI("Интерактивная панель","Интерактив панел","Interaktiv panel","Interactive panel");
	static final int si_emp = SI("Сотрудник", "Ходим", "Hodim", "Employee");
	static final int si_oper = SI("Опердень", "Амалиёт куни", "Amaliyot kuni", "Operden");
	static final int si_hide = SI("Закрыть", "Чи&#1179;иш", "Chiqish", "Exit");
	static final int si_base_real = SI("РЕАЛЬНАЯ БАЗА", "ХА&#1178;И&#1178;ИЙ БАЗА", "HAQIQIY BAZA", "REAL BASE");
	static final int si_settings = SI("Настройки и помощь", "Созлаш ва ёрдам", "Sozlash va yordam", "Settings and help");
	static final int si_documents = SI("Документация", "", "", "");
	static final int si_video = SI("ВИДЕО ИНСТРУКЦИЯ", "", "", "");
	static final int si_help = SI("Инструкция по подсистеме", "&#1178;уйи тизим бўйича &#1179;ўлланма", "Quyi tizim bo'yicha qo'llanma", "Instruction on the subsystem");
	static final int si_not_help_url = SI("Для этой подсистемы нет Инструкции", "Ушбу тизим учун &#1179;ўлланма йў&#1179;", "Ushbu tizim uchun qo'llanma yo'q", "There is no Instruction for this subsystem");
	static final int si_mlm = SI("Служба поддержки", "", "", "");
	static final int si_changeOperday = SI("Вы изменили опердень на", "", "", "");
	static final int si_search = SI("Поиск формы", "&#1178;идирув формаси", "Qidiruv formasi", "Form search");
	static final int si_success = SI("Успешно выполнено!", "Мувоффа&#1179;иятли бажарилди!", "Muvoffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_next = SI("Язык будет принимается со следующего раза!", "Ўзгартирилган тил кейинги маротаба кирганизда &#1179;абул &#1179;илинади!", "O'zgartirilgan til keyingi marotaba kirganizda qabul qilinadi!", "Language will be taken from the next time!");
	static final int si_bpm = SI("BPM", "BPM", "BPM", "BPM");
	static final int si_time = SI("Время", "Ва&#1179;т", "Vaqt", "Time");
	static final int si_calendar = SI("Календарь", "Календарь", "Kalendar", "Calendar");
	static final int si_compile_object_msg = SI("Ведется установка обновлений на базу данных. Для продолжения работы требуется заново перезайти в форму. Извените за доставленное неудобство.", "", "", "");
	static final int si_user_timeout_msg = SI("Время сессии истекло, войдите в систему заново.", "", "", "");
	static final int si_currencies = SI("Курсы валют на", "Валюта курслари бўйича", "Valyuta kurslari bo'yicha", "Exchange rates on");
	static final int si_min_zp_title = SI("Минимальная зарплата", "Енг кам иш &#1203;а&#1179;и", "Eng kam ish haqi", "Minimum wage");
	static final int si_mb_title = SI("Режим работы межбанковской платежной системы", "Режим работы межбанковской платежной системы", "Режим работы межбанковской платежной системы", "Режим работы межбанковской платежной системы");
	static final int si_dr_title = SI("Режим работы межбанковской платежной системы денежного рынка", "Режим работы межбанковской платежной системы денежного рынка", "Режим работы межбанковской платежной системы денежного рынка", "Режим работы межбанковской платежной системы денежного рынка");
	static final int si_dk_title = SI("Режим работы межбанковской денежно кредитной платежной системы ЦБ РУз", "Режим работы межбанковской денежно кредитной платежной системы ЦБ РУз", "Режим работы межбанковской денежно кредитной платежной системы ЦБ РУз", "Режим работы межбанковской денежно кредитной платежной системы ЦБ РУз");
	static final int si_search_smart = SI("Умный поиск", "А?лли ?идирув", "Aqlli qidiruv", "Smart search");
	static final int si_search_simple = SI("Обычный поиск", "Оддий ?идирув", "Oddiy qidiruv", "Normal search");
//-------------------------------------------------------------------------------------------------
%>
