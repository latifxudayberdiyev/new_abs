<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.driver.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String action = request.getParameter("action");
	if (request.getParameter("mark") != null) {
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("User_Api.Delete_Chat_Message");
			cs.setArrayNumberParameter("i_message_ids", "messageId");
			cs.execute();
%>
	<script>var result = true;</script>
	<%
			} catch (Exception ex) {
				Util.alertUserMessage(ex, out, true);
			}
		}
	%><t:form title="<%=(action!=null)?si_hisTitle:si_curTitle%>" minHeight="fill" minWidth="fill">
		<script>
			function del() {
				go({form: tblForm, param: {mark: "read"}});
			}

			function his() {
				go({url: "chat_messages.jsp?action=show"});
			}

			function back() {
				go({url: "chat_messages.jsp"});
			}

			function pageClose() {
				if (typeof (result) != "undefined") {
					window.returnValue = true;
					top.close();
				} else {
					top.close();
				}
			}

			function onLoad() {
				if (!dataExist()) {
					if (is.def(getDOM("bDel"))) getDOM("bDel").disabled = true;
				}
			}
		</script>
		<iframe name=frm width=0 height=0></iframe>
		<table class=formToolbar cellspacing=6>
			<tr><% if(action == null) {%>
				<td><input type="button" name="bDel" onclick="del()" value="<%=lang.get(si_del)%>">
					<input type="button" onclick="his()" value="<%=lang.get(si_hisTitle)%>">
				<td id="tableControls" align="right"><input type="button" onclick="pageClose()" value="<%=lang.get(si_exit)%>">
							<% } else {%>
				<td id="tableControls" align="right"><input type="button" onclick="back()" value="<%=lang.get(si_back)%>">
			<% } %></table>
		<%
			String iTable = "chat_messages_v";
			if (action != null)
				iTable = "chat_messages_hs_v";
		%>
		<t:table from="<%=iTable%>" sessionName="<%=action%>">
			<t:field id="1" name="message_id" />
			<t:field id="2" name="message" label="<%=si_message%>" type="quote" />
			<t:field id="3" name="created_on" label="<%=si_created_on%>" type="datetime" />
			<%--	<t:field id="4" name="created_name" label="<%=si_created_name%>" type="quote"/>--%>
			<t:grid page="" withoutCursor="true" numbering="" withoutSortButtons="">
				<% if (action == null) {%><t:column for="1" type="checkbox" name="messageId" /><% } %>
				<t:column for="3" />
				<t:column for="2" align="left" />
				<%--		<t:column for="4" align="left"/> --%>
			</t:grid>
		</t:table>
	</t:form>
</t:page>
<%!
	static final int si_curTitle = SI("Принятое сообщение", "&#1178;абул &#1179;илинган хабар", "Qabul qilingan xabar", "Received messages");
	static final int si_hisTitle = SI("Прочитанное сообщение", "Ў&#1179;илган хабар", "O`qilgan xabar", "All Read messages");
	static final int si_del = SI("Отметить как прочитанное", "Ў&#1179;илган деб белгилаш", "O`qilgan deb belgilash", "Mark as Read");
	static final int si_his = SI("История", "Тарих", "Tarix", "History");
	static final int si_exit = SI("Выход", "Чи&#1179;иш", "Chiqish", "Exit");
	static final int si_back = SI("Назад", "Ор&#1179;ага", "Orqaga", "Back");
	static final int si_message = SI("Сообщение", "Хабар", "Xabar", "Message");
	static final int si_created_on = SI("Дата", "Сана", "Sana", "Date");
	static final int si_created_name = SI("Кто создал", "Ким яратган", "Kim yaratgan", "Created name");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
