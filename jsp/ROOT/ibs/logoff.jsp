<%@ page import="java.sql.*,java.net.*,uz.fido_biznes.cms.*" contentType="text/html;charset=Windows-1251" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<%
	Connection conn = cods.getConnection();
	try {
		stored.execProcedure("SC_API.Logoff");
		if (conn != null) {
			conn.close();
		}
	} catch (Exception ex) {
		if (conn != null) {
			try {
				conn.close();
			} catch (SQLException e) {
				System.out.println(e.getMessage());
			}
		}
	} finally {
		session.invalidate();
		response.setHeader("RT", "script");
		out.print("top._t().location='/ibs/index.jsp';");
	}
%>