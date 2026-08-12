<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
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
	String operDay = request.getParameter("operDay");
	if (operDay == null) operDay = (String) session.getValue("operDay");

%><t:form title="<%= si_formTitle %>" minWidth="fill" minHeight="fill">
	<script type="text/javascript">
		function updateData(obj) {
			if (obj.check()) {
				go({
					param: {
						operDay: obj.value
					}
				});
			}
		}
	</script>
	<form name="fm">
	<div id="basepanel" class="panel" align="center">
	<br />
	<table>
		<tbody>
		<%
			try {
				CallableStatement cs = conn.prepareCall("{? = call Core_Info.Info_Form(?)}");
				cs.setString(2, operDay);
				cs.registerOutParameter(1, Types.CLOB);
				cs.execute();
				Clob responseBodyClob = cs.getClob(1);
				String responseBody = responseBodyClob.getSubString(1, (int) responseBodyClob.length());
				out.print(responseBody);
			} catch (Exception ex) {
				Util.alertUserMessage(ex, out);
			}
		%>
		</tbody>
	</table>
</t:form>
</t:page>
<%!
	static final int si_formTitle = SI("Инфо", "Маълумот", "Ma`lumot", "");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
