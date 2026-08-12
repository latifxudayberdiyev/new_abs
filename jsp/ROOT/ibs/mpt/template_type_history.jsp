<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
	String templateCode = request.getParameter("template_code");
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("Core.User_Session.Put_Varchar2");
		cs.setString("i_Key", "mpt_template_type_code");
		cs.setString("i_Value", templateCode);
		cs.execute();
	} catch (Exception ex) {
		Util.alertUserMessage(ex, out);
	}
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<table class="formToolbar" align="center">
		<tr>
			<td></td>
			<td id="tableControls" align="right">
				<input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
			</td>
		</tr>
	</table>
	<t:table from="mpt_template_types_h_v">
		<t:field id="1" name="log_id" label="<%=si_id%>" />
		<t:field id="2" name="action_code" label="<%=si_action%>" />
		<t:field id="3" name="action_name" label="<%=si_action%>" type="quote" />
		<t:field id="4" name="modified_on" label="<%=si_modified_on%>" type="datetime" />
		<t:field id="5" name="modified_by_name" label="<%=si_modified_by%>" type="quote" />
		<t:field id="6" name="template_name" label="<%=si_name%>" type="quote" />
		<t:field id="7" name="module_name" label="<%=si_module%>" type="quote" />
		<t:field id="8" name="state_name" label="<%=si_active%>" type="quote" />
		<t:field id="9" name="description" label="<%=si_description%>" type="quote" />
		<t:grid page="" numbering="" withoutCursor="" withoutSortButtons="">
			<t:column for="3" />
			<t:column for="4" />
			<t:column for="5" align="left" />
			<t:column for="6" align="left" />
			<t:column for="7" align="left" />
			<t:column for="8" />
			<t:column for="9" align="left" />
		</t:grid>
	</t:table>
</t:form>
</t:page>
<%!
	static final int si_title       = SI("История изменений", "Узгаришлар тарихи", "O'zgarishlar tarixi", "Change history");
	static final int si_exit        = SI("Закрыть", "Ёпиш", "Yopish", "Close");
	static final int si_id          = SI("ID", "ID", "ID", "ID");
	static final int si_action      = SI("Действие", "Амал", "Amal", "Action");
	static final int si_modified_on = SI("Дата", "Сана", "Sana", "Date");
	static final int si_modified_by = SI("Автор", "Муаллиф", "Muallif", "Author");
	static final int si_name        = SI("Название", "Номи", "Nomi", "Name");
	static final int si_module      = SI("Модуль", "Модул", "Modul", "Module");
	static final int si_active      = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
%>
<%@ include file="/language.jsp" %>
