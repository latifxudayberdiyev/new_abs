<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.driver.*" %>
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
	storedObj.setConnection(conn, "22309");
//-------------------------------------------------------------------------------------------------
%><t:page>
	<t:form noCache="" title="<%= si_formTitle %>" minWidth="640" minHeight="300">
		<script type="text/javascript">
			function removeHtmlTags(input) {
				return input.replace(/<[^>]*>/g, '');
			}

			function save() {
				var message = removeHtmlTags(fm.message.value);
				var empCode = getDOMValue("empCode");
				var filialCode = getDOMValue("filialCode");
				var rankCode = getDOMValue("filialCode");

				if (filialCode && message) {
					AJAX.load({
						POST: {
							request: "save",
							message: message,
							empCode: empCode,
							filialCode: filialCode,
							rankCode: rankCode
						},
						onSuccess: function (d) {
							alert("Сообщение было успешно отправлено.");
							go({});
						},
						onError: function (e) {
							parent.pageLock(false);
						}
					});
				} else {
					alert("<%= lang.get(si_empty) %>");
				}
			}
		</script>
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" target="frm" alert="" onsubmit="return false">
			<table align=center class=formToolbar cellspacing=2>
				<tr>
					<td><input type="button" value="<%= lang.get(si_save) %>" onclick="save()" /></td>
				</tr>
			</table>
			<div id="basepanel" class="panel">
				<table align="center">
					<tbody>
					<tr>
						<td><br></td>
					</tr>
					<tr>
						<td><%= lang.get(si_filial) %>:</td>
						<td><input name="filialCode" mask="mfo" size="6" r="1" /></td>
						<td><%= lang.get(si_empCode) %>:</td>
						<td><input mask="number(10)" name="empCode" size=10 nullable=1></td>
					<tr>
						<td><%= lang.get(si_rankCode) %>:</td>
						<td colspan="3">
							<select name="rankCode">
								<option value=><%= lang.get(si_all) %>
								</option>
								<t:options from="vm_post" code="code" name="name" orderBy="code" />
							</select>
						</td>
					</tr>
					<tr>
						<td><%= lang.get(si_message) %>:</td>
						<td colspan="3">
							<textarea name="message" cols="60" rows="5" r="1" maxRows="13"></textarea>
						</td>
					</tr>
					<tr>
						<td><br></td>
					</tr>
					</tbody>
				</table>
			</div>
		</form>
	</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("User_Api.Send_Message");
			cs.setStringParameter("i_Message", "message");
			cs.setNumberParameter("i_Emp_Code", "empCode");
			cs.setStringParameter("i_Filial_Code", "filialCode");
			cs.setNumberParameter("i_Rank_Code", "rankCode");
			cs.execute();
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out, false);
		}
	%></t:request>
</t:requests>
<%!
	static final int si_formTitle = SI("Отправка сообщений", "Хабарларни жўнатиш", "Xabarlarni jo'natish", "Send message");
	static final int si_filial = SI("Филиал", "Филиал", "Filial", "Branch");
	static final int si_empCode = SI("Код сотрудника", "Ходим коди", "Xodim kodi", "Employee code");
	static final int si_rankCode = SI("Должность", "Лавозим", "Lavozim", "Job title");
	static final int si_all = SI("Все", "Хаммаси", "Hammasi", "All");
	static final int si_message = SI("Текст сообщения", "Хабар матни", "Xabar matni", "Message text");
	static final int si_empty = SI("Имеются заполненные некоректно или незаполненные обязательные поля!", "Мажбурий майдонлар нотўгри тўлдирилган ёки тўлдирилмаган!", "Majburiy maydonlar noto'g'ri to'ldirilgan yoki to'ldirilmagan!", "There are incorrectly filled in or mandatory fields that are not filled in!");
	static final int si_save = SI("Отправить сообщение", "Хабар юбориш", "Xabar yuborish", "Send message");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
