<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%><t:page><t:form minWidth="fill" minHeight="fill" emptyForm="">
<style>
	html, body { height: 100%; margin: 0; }
	.panel table {
		width: 100% !important;
	}
	iframe {
		border: none !important;
	}
</style>
<script type="text/javascript">
	function onLoad() {
		go({
			url: 'esbin_users_grid.jsp',
			target: esbinUsers,
			lock: false
		});
	}
</script>
<table width="100%" height="100%" align="center" cellspacing="0" cellpadding="0">
	<thead>
		<tr>
			<td align="center" colspan="3">
				<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</td>
		</tr>
		<tr style="height:5px !important">
			<td></td>
		</tr>
	</thead>
	<tbody>
		<tr width="100%" height="100%">
			<td style="width:50%">
				<iframe width="100%" height="100%" name="esbinUsers"></iframe>
			</td>
			<td style="width:50%">
				<iframe width="100%" height="100%" name="esbinRelMethods"></iframe>
			</td>
		</tr>
	</tbody>
</table>
</t:form>
</t:page>
<%!
	static final int si_title = SI("Доступы к методам", "Метод дост&#1179;лари", "Metod dostuplari", "Method access");
	static final int si_exit  = SI("Закрыть", "Ёпиш", "Yopish", "Close");
%>
<%@ include file="/language.jsp" %>
