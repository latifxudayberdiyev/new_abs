<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if(conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
stored.execProcedure("User_Session.Put_Number('calendar_type_id','"+request.getParameter("calendar_type_id")+"')");
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
<script>
</script>
<t:table from="user_calendars_v" >
	<t:field id="1" name="notify_date" label="<%=si_notify_date%>" type="date" />
	<t:field id="2" name="label" label="<%=si_label%>" type="quote" />
	<t:field id="3" name="description" label="<%=si_description%>" type="quote" />
	<t:field id="4" name="color" type="quote" />
	<t:grid withoutCursor="" numbering="" withoutSortButtons="" hideExcelButton="" withoutRefreshButton="" rowColor="d(4)">
		<t:column for="1" size="10"/>
		<t:column for="2" align="left"/>
		<t:foot>
			<t:row>
				<t:cell for="3" type="textarea" rows="5" size="100%" align="left"/>
			</t:row>
		</t:foot>
	</t:grid>
</t:table>
</t:form>
</t:page>
<%!
	static final int si_title				= SI("Информации","","","");
	static final int si_notify_date	= SI("Дата","Сана","Sana","Date");
	static final int si_label				= SI("Текст информации","","","");
	static final int si_description	= SI("Примечания","","","");

//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>