<%
//	************************************************************************
//	***                                                                  ***
//	***  Данный файл должен подключаться для замены стандартного потока  ***
//	***  вывода на поток вывода.                                         ***
//	***                                                                  ***
//	***  Copyright (C) 2008, 2012, Fido-Biznes MChJ.                     ***
//	***  Автор:  Шаюсупов Ш.А.                                           ***
//	***                                                                  ***
//	************************************************************************

	Hashtable sessCache = (Hashtable)session.getValue("user_cache");
	if (sessCache == null) {
		sessCache = new Hashtable();
		session.putValue("user_cache", sessCache);
	}

	// Начало: Изменён от 23.03.2012
/*
  -- Закомментируем старый вариант
	iabs.JspCacheWriter cacheOut = new iabs.JspCacheWriter(out, sessCache, "");
	out = cacheOut;
	try {
*/
	iabs.CacheOutSupport cacheOut = new iabs.CacheOutSupport (out, sessCache, "");
	out = cacheOut.getOut();
	// Открываем обработчик исключений

	// Конец: Изменён от 23.03.2012

	try {

%>