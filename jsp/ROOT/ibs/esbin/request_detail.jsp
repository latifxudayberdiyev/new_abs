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
	String id = request.getParameter("id");

	String extRequestId = "", partnerName = "", userName = "", methodName = "", state = "", syncType = "";
	String createdOn = "", startedOn = "", finishedOn = "";
	String requestBody = "", responseBody = "";
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<script>
		function onLoad() {
		}
	</script>
	<div id="basepanel" class="panel">
		<table class="formToolbar" align="center">
			<tr>
				<td>
				<td id="tableControls" align="right">
					<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</tr>
		</table><%
			PreparedStatement psReq = null;
			ResultSet rsReq = null;
			try {
				psReq = conn.prepareStatement(
					"select EXT_REQUEST_ID, PARTNER_NAME, USER_NAME, METHOD_NAME, STATE, SYNC_TYPE, " +
					"CREATED_ON, STARTED_ON, FINISHED_ON from ESBIN_REQUESTS_V where ID = ?");
				psReq.setLong(1, Long.parseLong(id));
				rsReq = psReq.executeQuery();
				if (rsReq.next()) {
					extRequestId = esc(rsReq.getString("EXT_REQUEST_ID"));
					partnerName = esc(rsReq.getString("PARTNER_NAME"));
					userName = esc(rsReq.getString("USER_NAME"));
					methodName = esc(rsReq.getString("METHOD_NAME"));
					state = esc(rsReq.getString("STATE"));
					syncType = esc(rsReq.getString("SYNC_TYPE"));
					createdOn = String.valueOf(rsReq.getTimestamp("CREATED_ON"));
					startedOn = String.valueOf(rsReq.getTimestamp("STARTED_ON"));
					finishedOn = String.valueOf(rsReq.getTimestamp("FINISHED_ON"));
				}
			} finally {
				if (rsReq != null) rsReq.close();
				if (psReq != null) psReq.close();
			}

			PreparedStatement psDet = null;
			ResultSet rsDet = null;
			try {
				psDet = conn.prepareStatement("select REQUEST, RESPONSE from ESBIN_REQUEST_DETAILS_V where REQUEST_ID = ?");
				psDet.setLong(1, Long.parseLong(id));
				rsDet = psDet.executeQuery();
				if (rsDet.next()) {
					requestBody = esc(rsDet.getString("REQUEST"));
					responseBody = esc(rsDet.getString("RESPONSE"));
				}
			} finally {
				if (rsDet != null) rsDet.close();
				if (psDet != null) psDet.close();
			}
		%>
		<div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;padding:8px;">
			<div><b><%=lang.get(si_ext_request_id)%>:</b> <%=extRequestId%></div>
			<div><b><%=lang.get(si_state)%>:</b> <%=state%> (<%=syncType%>)</div>
			<div><b><%=lang.get(si_partner)%>:</b> <%=partnerName%></div>
			<div><b><%=lang.get(si_user)%>:</b> <%=userName%></div>
			<div><b><%=lang.get(si_method)%>:</b> <%=methodName%></div>
			<div></div>
			<div><b><%=lang.get(si_created_on)%>:</b> <%=createdOn%></div>
			<div><b><%=lang.get(si_started_on)%>:</b> <%=startedOn%></div>
			<div><b><%=lang.get(si_finished_on)%>:</b> <%=finishedOn%></div>
		</div>
		<div style="padding:8px;">
			<div class="section-label"><%=lang.get(si_request)%></div>
			<textarea readonly style="width:100%;height:140px;font-family:monospace;font-size:12px;"><%=requestBody%></textarea>
			<div class="section-label" style="margin-top:8px;"><%=lang.get(si_response)%></div>
			<textarea readonly style="width:100%;height:140px;font-family:monospace;font-size:12px;"><%=responseBody%></textarea>
		</div>
	</div>
</t:form>
</t:page>
<%!
	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
	}
	static final int si_title         = SI("Просмотр запроса", "Со&#1179;ровни к&#1118;риш", "So'rovni ko'rish", "View request");
	static final int si_exit          = SI("Закрыть", "Ёпиш", "Yopish", "Close");
	static final int si_ext_request_id = SI("Внешний ID", "Таш&#1179;и ID", "Tashqi ID", "External ID");
	static final int si_state         = SI("Статус", "&#1202;олат", "Holat", "State");
	static final int si_partner       = SI("Партнер", "&#1202;амкор", "Hamkor", "Partner");
	static final int si_user          = SI("Пользователь", "Фойдаланувчи", "Foydalanuvchi", "User");
	static final int si_method        = SI("Метод", "Метод", "Metod", "Method");
	static final int si_created_on    = SI("Создано", "Яратилган", "Yaratilgan", "Created");
	static final int si_started_on    = SI("Начато", "Бошланган", "Boshlangan", "Started");
	static final int si_finished_on   = SI("Завершено", "Якунланган", "Yakunlangan", "Finished");
	static final int si_request       = SI("Запрос", "Со&#1179;ров", "So'rov", "Request");
	static final int si_response      = SI("Ответ", "Жавоб", "Javob", "Response");
%>
<%@ include file="/language.jsp" %>
