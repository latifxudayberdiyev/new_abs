<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="util" class="iabs.oraUtil" scope="session" />
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
	String foot_form_text = new String(request.getParameter("foot_form_text").getBytes("ISO8859_1"), "UTF8");
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<script>
		function onLoad() {
			setDOMValue("foot_form_text", decodeURIComponent("<%=foot_form_text%>"));
		}
	</script>
	<div id="basepanel" class="panel" >
	<textarea name="foot_form_text" style="width:100%;height:100%"></textarea>
</t:form></t:page>
<%!
	static final int si_title = SI("Текст", "", "", "");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>