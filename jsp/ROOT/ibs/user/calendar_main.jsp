<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String is_main = request.getParameter("is_main");
%><t:form minWidth="fill" minHeight="fill" emptyForm="">
	<style>
		body {
			padding: 0;
			margin: 0;
			background: #fff;
			font: 100% "Trebuchet MS", Tahoma, Verdana, sans-serif
		}

		#bExit {
			margin: 5px;
		}
	</style>
	<% if ("N".equals(is_main)) { %>
	<script>
		var mn =<%=stored.execFunction("User_Calendar_Api.Get_Calendar_Menu")%>;

		function onLoad() {
			drawTab(mn.items);
			initElement(getDOM("bExit"));
			tabControls.children[0].click();
		}
	</script>
	<table width="100%" height="100%" cellspacing=0 cellpadding=0>
		<tr height="30px">
			<td id="tabControls" class="menuBlock">&nbsp;
			<td align="right" class="menuBlock">
				<input type="button" id="bExit" class="withFilter" onclick="top.close();" value="<%=lang.get(si_exit)%>">
		<tr>
			<td style="height:100%" colspan=2>
				<iframe name="menuBody" src="" width=100% height=100% marginheight=0 frameborder=0></iframe>
	</table>
	<% } else { %>
	<script>
		var mn =<t:menu labelText="Root" target="menuBody">
			<t:menu labelText="Календарь уведомлений" url="calendar_notifies.jsp" />
			<t:menu labelText="Тип календаря" url="calendar_types.jsp" />
			</t:menu>;

		function onLoad() {
			if (mn.items.length == 0) alert("<%=lang.get(si_error)%>");
			drawTab(mn.items);
			initElement(getDOM("bExit"));
		}
	</script>
	<table width="100%" height="100%" cellspacing=0 cellpadding=0>
		<tr height="30px">
			<td id="tabControls" class="menuBlock">&nbsp;
			<td align="right" class="menuBlock">
				<input type="button" id="bExit" class="withFilter" onclick="go({url:'/ibs/contents.jsp'});"
				       value="<%=lang.get(si_exit)%>">
		<tr>
			<td style="height:100%" colspan=2>
				<iframe name="menuBody" src="calendar_notifies.jsp" width=100% height=100% marginheight=0
				        frameborder=0></iframe>
	</table>
	<% } %>
</t:form>
</t:page>
<%!
	static final int si_error = SI("У Вас нет доступа к меню подсистемы.\\nЗакрепите доступные формы меню за ролями.", "&#1178;уйи тизим менюсига кириш &#1203;у&#1179;у&#1179;ингиз йў&#1179;.\\nРухсат этилган меню шаклларини ролларга бириктиринг.", "Quyi tizim menyusiga kirish huquqingiz yo`q.\\nRuxsat etilgan menyu shakllarini rollarga biriktiring.", "");
	static final int si_exit = SI("Выход", "Чи&#1179;иш", "Chiqish", "Exit");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
