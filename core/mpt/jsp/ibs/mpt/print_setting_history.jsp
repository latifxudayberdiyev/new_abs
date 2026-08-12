<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.util.*, uz.fido_biznes.cms.*" %>
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	/* Ikkita mustaqil t:table/t:form (Sozlama tarixi + Fayllar) bitta
	 * t:form ichida ishlamaydi - CMS TableTag forma darajasida bitta
	 * umumiy maydonlar ro'yxatini kutadi, ikkinchi jadval ustunlarini
	 * birinchisining view'iga qo'shib yuboradi (ORA-00904 STATE_NAME).
	 * Shu sababli ikkala tarix alohida, mustaqil JSP'larda (har biri o'z
	 * yagona t:form/t:table jufti bilan) va shu yerda ikkita iframe orqali
	 * bitta oynada ko'rsatiladi. Har bir ichki sahifa o'zining t:form
	 * title'ini (sarlavha panelini) allaqachon chizadi, shuning uchun bu
	 * yerda alohida bo'lim sarlavhasi qo'shilmaydi - aks holda ikki marta
	 * takrorlanib ko'rinadi. */
	Language lang = new Language(user.getLanguageIndex(), sentences);
	String settingId = request.getParameter("setting_id");
%><!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
<style>
	html, body { height: 100%; margin: 0; padding: 0; font-family: Tahoma, Arial, sans-serif; font-size: 12px; }
	.toolbar { padding: 6px 8px; text-align: right; border-bottom: 1px solid #ccc; }
	.histFrame { width: 100%; border: 0; display: block; }
</style>
</head>
<body>
	<div class="toolbar">
		<input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
	</div>
	<iframe class="histFrame" style="height:280px" src="print_setting_settings_history.jsp?setting_id=<%=java.net.URLEncoder.encode(settingId == null ? "" : settingId, "UTF-8")%>"></iframe>
	<iframe class="histFrame" style="height:280px" src="print_setting_file_history.jsp?setting_id=<%=java.net.URLEncoder.encode(settingId == null ? "" : settingId, "UTF-8")%>"></iframe>
</body>
</html>
<%!
	static final int si_exit            = SI("Закрыть", "Ёпиш", "Yopish", "Close");
	static final int si_setting_history = SI("История настройки", "Созлама тарихи", "Sozlama tarixi", "Setting history");
	static final int si_files           = SI("Файлы", "Файллар", "Fayllar", "Files");
%>
<%@ include file="/language.jsp" %>
