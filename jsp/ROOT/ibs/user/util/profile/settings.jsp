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
%><t:form emptyForm="">
<script>
	function onLoad(){
		go({url: "option.jsp", target: _left, lock: false});
		go({url: "profile.jsp", target: _right, lock: false});
	}
</script>
<table align="center" border="0" style="border-collapse:collapse; width:100%; height:100%">
	<colgroup>
		<col width="20%" />
		<col width="80%" />
	</colgroup>
	<tbody>
		<tr>
			<td>
				<iframe name="_left" width="100%" height="100%" marginheight="0" frameborder="0"></iframe>
			</td>
			<td>
				<iframe name="_right" width="100%" height="100%" marginheight="0" frameborder="0"></iframe>
			</td>
		</tr>
	</tbody>
</table>
</t:form>
</t:page>
<%!

//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>