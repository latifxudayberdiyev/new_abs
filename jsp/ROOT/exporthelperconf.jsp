<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<jsp:useBean id="util" class="iabs.oraUtil" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String SN = request.getParameter("SN");
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<script>
		function onLoad() {
		}

		function mySubmit() {
			fm.submit();
			window.open('', '_self', '');
			window.close();
		}
	</script>
	</script>
	<div id="basepanel" class="panel" align="center">
	<form name="fm" action="exporthelper.jsp" target="_blank">
	<input type="hidden" name="SN" value="<%=SN%>">
	<table class="formToolbar">
		<tr>
			<!--td><input type="text" value="<%=SN%>"-->
			<td><input type="button" value="<%=lang.get(si_save)%>" onclick="mySubmit();">
			<td align="right"><input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
	</table>
	<table>
		<col width="40%" align="right">
		<tr>
			<th><%=lang.get(si_file_type)%> :
			<td><select name="file_type">
				<option value="xls">
							<%=lang.get(si_xls)%>
				<option value="xlsx"><%=lang.get(si_xlsx)%>
			</select>
		<tr>
			<th><%=lang.get(si_autosize)%> :
			<td><select name="autosize">
				<option value="N">
							<%=lang.get(si_no)%>
				<option value="Y"><%=lang.get(si_yes)%>
			</select>
				<!--tr>
		<th><%=lang.get(si_archive)%> :
		<td><select name="archive" >
				<option value="N"><%=lang.get(si_no)%><option value="Y"><%=lang.get(si_yes)%>
			</select-->
	</table>
</t:form>
</t:page>
<%!
	static final int si_title = SI("Настройки данных EXCEL", "Настройки данных EXCEL", "????????? ?????? EXCEL", "");
	static final int si_save = SI("Сформировать", "", "", "");
	static final int si_exit = SI("Закрыть", "Ёпиш", "Yopish", "");
	static final int si_autosize = SI("Авто ширина", "", "", "");
	static final int si_archive = SI("Архивировать", "", "", "");
	static final int si_no = SI("Нет", "", "", "");
	static final int si_yes = SI("Да", "", "", "");
	static final int si_xls = SI("xls", "", "", "");
	static final int si_xlsx = SI("xlsx", "", "", "");
	static final int si_file_type = SI("Выберите тип файла", "Faylni turini tanlang", "Choose file type", "");
//--------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
