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
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<table class="formToolbar" align="center">
		<tr>
			<td></td>
			<td id="tableControls" align="right"></td>
		</tr>
		<tr align="center">
			<td colspan="2">
				<span id="filterControls"></span></td>
		</tr>
	</table>
	<t:table from="mpt_modules_v">
		<t:field id="1" name="module_code" label="<%=si_code%>">
			<t:filter operator="_search_" mask="20|" />
		</t:field>
		<t:field id="2" name="module_name" label="<%=si_name%>" type="quote">
			<t:filter operator="_search_" mask="200|" />
		</t:field>
		<t:field id="3" name="is_active" label="<%=si_active%>" />
		<t:field id="4" name="order_by" label="<%=si_order%>" />
		<t:field id="5" name="state_name" label="<%=si_active%>" type="quote" />
		<t:grid page="" numbering="" withoutCursor="" rowColor="(d(3)=='N')?'#AAAAAA':''">
			<t:column for="1" />
			<t:column for="2" align="left" />
			<t:column for="5" />
			<t:column for="4" />
			<t:foot><t:row>
				<t:cell for="2" size="100%" />
			</t:row></t:foot>
		</t:grid>
	</t:table>
</t:form>
</t:page>
<%!
	static final int si_title = SI("Модули", "Модуллар", "Modullar", "Modules");
	static final int si_code = SI("Код", "Код", "Kod", "Code");
	static final int si_name = SI("Название", "Номи", "Nomi", "Name");
	static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_order = SI("Порядок", "Тартиби", "Tartibi", "Order");
%>
<%@ include file="/language.jsp" %>
