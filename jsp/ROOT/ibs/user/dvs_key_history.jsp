<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String user_id = request.getParameter("user_id");
	String user_id_d = stored.decryptParameterValue(request,"user_id","CORE_USERS");
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
<script>
</script>
<table class="formToolbar" align="center" >
	<tr>
		<td>
		<td id="tableControls" align="right" >
</table><%
	String iWhere = "1 != 1";
	if(user_id!=null)
		iWhere = "user_id =" + Util.quotesSQL(user_id_d) + " and user_type_id = 1";
%>
<t:table from="asa_ekeys_his_v" where="<%=iWhere%>" >
	<t:field id="1" name="attach_type" label="<%=si_attach_type%>" type="quote" />
	<t:field id="2" name="ekey_type_id" label="<%=si_ekey_type_id%>" />
	<t:field id="3" name="ekey_id" label="<%=si_ekey_id%>" type="quote" />
	<t:field id="4" name="user_type_id" label="<%=si_user_type_id%>" />
	<t:field id="5" name="user_id" label="<%=si_user_id%>" />
	<t:field id="6" name="created_on" label="<%=si_created_on%>" type="datetime" />
	<t:field id="7" name="created_by" label="<%=si_created_by%>" />
	<t:field id="8" name="created_name" label="<%=si_created_by%>" type="quote" />
	<t:grid page="" withoutCursor="" numbering="">
		<t:column for="1" />
		<t:column for="3" />
		<t:column for="6" />
		<t:column for="8" />
	</t:grid>
</t:table>
</t:form>
</t:page>
<%!
static final int si_title        = SI("История","Тарих","Tarix","History");
static final int si_attach_type  = SI("Действие","&#1202;аракат","Harakat","Action");
static final int si_ekey_type_id = SI("ekey_type_id");
static final int si_ekey_id      = SI("DVS коды","DVS кодлари","DVS kodlari","DVS Code");
static final int si_user_type_id = SI("user_type_id");
static final int si_user_id      = SI("user_id");
static final int si_created_on   = SI("Дата действий","&#1202;аракатлар санаси","Harakatlar sanasi","Date of action");
static final int si_created_by   = SI("Сотрудник","Ходим","Xodim","Staff");

//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
