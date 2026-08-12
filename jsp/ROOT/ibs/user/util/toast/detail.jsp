<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String messageId = request.getParameter("messageId");
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setFunction("Chat_Message_Api.Get_Chat_High_Message");
		cs.setNumber("i_Message_Id", messageId);
		cs.execute();
%>
	<script>var datas =<%=cs.getStringResult()%>;
	console.log(datas);</script>
	<%
	} catch (Exception ex) {
		response.setHeader("RT", "alert");
	%>
	<script>alert("<%=Util.quotesEsc(ex.getMessage())%>");</script>
	<%
		}
	%>
	<style>
		* {
			font-size: var(--size-14) !important;
		}

		form {
			margin-left: auto !important;
			margin-right: auto !important;
		}

		.mt-24 {
			margin-top: var(--size-24)
		}

		.d-none {
			display: none !important;
		}

		.text-right {
			text-align: right
		}

		textarea {
			min-height: var(--size-100);
			resize: none;
		}

		input[type=text], textarea {
			width: 100%;
			border: none !important;
			background: transparent !important;
		}

		td {
			vertical-align: top !important;
		}

		#basepanel {
			width: 100% !important;
		}

		#message {
			line-height: var(--size-24);
			max-height: var(--size-264);
			overflow-y: auto;
		}
	</style>
	<t:form title="<%= si_title %>" minWidth="fill" minHeight="fill">
		<div id="basepanel" class="panel">
			<form name="fm" method="post" target="frm" class="mt-24">
				<input type="hidden" name="message_id" />
				<input type="hidden" name="priority" />
				<table id="messageInfo" align="center" border="0">
					<colgroup>
						<col width="20%" />
						<col width="*" />
					</colgroup>
					<tbody>
					<tr class="d-none">
						<td><%= lang.get(si_created_name) %>:</td>
						<td>
							<input type="text" name="created_name" readonly />
						</td>
					</tr>
					<tr>
						<td><%= lang.get(si_created_on) %>:</td>
						<td>
							<input type="text" name="created_on" readonly />
						</td>
					</tr>
					<tr>
						<td><%= lang.get(si_message) %>:</td>
						<td>
							<div id="message"></div>
						</td>
					</tr>
					</tbody>
				</table>
				<p id="deletedMessage" style="display:none"><%= lang.get(si_deleted) %>
				</p>
				<div class="mt-24 text-right">
					<input type="button" value="<%=lang.get(si_close)%>" onclick="top.close();" />
				</div>
			</form>
		</div>
		<script>
			function drawData(d) {
				if (d.fm.created_name) {
					setDOMValue("created_name", d.fm.created_name);
				}
				if (d.fm.created_on) {
					setDOMValue("created_on", d.fm.created_on);
				}
				if (d.fm.message) {
					getDOM("message").innerHTML = d.fm.message;
				} else {
					hideDOM("messageInfo");
					showDOM("deletedMessage");
				}
			}

			function onLoad() {
				drawData(datas);
			}
		</script>
	</t:form>
</t:page>
<%!
	static final int si_title = SI("Подробности сообщения", "Хабар тафсилотлари", "Xabar tafsilotlari", "Message detail");
	static final int si_message = SI("Текст сообщения", "Хабар матни", "Xabar matni", "Message text");
	static final int si_created_name = SI("Имя создателя", "Яратган номи", "Yaratgan nomi", "Created name");
	static final int si_created_on = SI("Время создания", "Яратилган ва?т", "Yaratilgan vaqt", "Created on");
	static final int si_deleted = SI("Сообщение уже прочитано!", "Хабар алла&#1179;ачон ў&#1179;илган!", "Xabar allaqachon o'qilgan!", "The message has already been read!");
	static final int si_close = SI("Закрыть", "Ёпиш", "Yopish", "Close");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
