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
	String settingId = request.getParameter("setting_id");
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("Core.User_Session.Put_Varchar2");
		cs.setString("i_Key", "mpt_print_setting_id");
		cs.setString("i_Value", settingId);
		cs.execute();
	} catch (Exception ex) {
		Util.alertUserMessage(ex, out);
	}
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<%-- t:table'ning ichki JS'i (table_cross.js) "tableControls" id'li elementni
	     har doim kutadi (masalan sahifalash tugmalarini shu yerga qo'yish uchun) -
	     bo'lmasa "tableControls is not found" xatosi bilan grid butunlay
	     chizilmay qoladi. Bu iframe ichidagi qism sahifa bo'lgani uchun
	     Yopish tugmasi shart emas, lekin id="tableControls" bo'sh bo'lsa ham
	     bo'lishi shart. --%>
	<table class="formToolbar" align="center">
		<tr>
			<td></td>
			<td id="tableControls" align="right"></td>
		</tr>
	</table>
	<t:table from="mpt_print_settings_h_v">
		<t:field id="1" name="log_id" label="<%=si_id%>" />
		<t:field id="2" name="setting_name" label="<%=si_setting_name%>" type="quote" />
		<t:field id="3" name="module_name" label="<%=si_module%>" type="quote" />
		<t:field id="4" name="template_name" label="<%=si_template_type%>" type="quote" />
		<t:field id="5" name="state_name" label="<%=si_active%>" type="quote" />
		<t:field id="6" name="action_code" label="<%=si_action%>" />
		<t:field id="7" name="action_name" label="<%=si_action%>" type="quote" />
		<t:field id="8" name="action_date" label="<%=si_date%>" type="datetime" />
		<t:field id="9" name="modified_by_name" label="<%=si_author%>" type="quote" />
		<t:grid page="" numbering="" withoutCursor="" withoutSortButtons="">
			<t:column for="2" align="left" />
			<t:column for="3" align="left" />
			<t:column for="4" align="left" />
			<t:column for="5" />
			<t:column for="7" align="left" />
			<t:column for="8" />
			<t:column for="9" align="left" />
		</t:grid>
	</t:table>
</t:form>
</t:page>
<%!
	static final int si_title         = SI("История настройки", "Созлама тарихи", "Sozlama tarixi", "Setting history");
	static final int si_id            = SI("ID", "ID", "ID", "ID");
	static final int si_setting_name  = SI("Название шаблона", "Шаблон номи", "Shablon nomi", "Template name");
	static final int si_module        = SI("Модуль", "Модул", "Modul", "Module");
	static final int si_template_type = SI("Тип шаблона", "Шаблон тури", "Shablon turi", "Template type");
	static final int si_active        = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_action        = SI("Действие", "Амал", "Amal", "Action");
	static final int si_date          = SI("Дата", "Сана", "Sana", "Date");
	static final int si_author        = SI("Автор", "Муаллиф", "Muallif", "Author");
%>
<%@ include file="/language.jsp" %>
