<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.util.*,java.net.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<%
	// Standalone entry point (like auth_login.jsp) - completes a password reset
	// given a token from the reset link (reset_password.jsp?token=...).
	String fs = System.getProperty("file.separator");
	String url = application.getRealPath(fs) + fs + "ibs" + fs + "iabs.parameters";

	iabs.oraDBConnection cods = new iabs.oraDBConnection();
	pageContext.setAttribute("cods", cods, PageContext.SESSION_SCOPE);
	iabs.DBParameters params = new iabs.DBParameters(url);
	params.initConnection(cods);
	Connection conn = cods.getConnection();

	uz.fido_biznes.sql.StoredObject stored = new uz.fido_biznes.sql.StoredObject();
	pageContext.setAttribute("stored", stored, PageContext.SESSION_SCOPE);
	stored.setConnection(conn);
//-------------------------------------------------------------------------------------------------
	try {
		if (conn == null) {
			throw new RuntimeException("Ma'lumotlar bazasiga ulanish o'rnatilmadi!");
		}

		String token     = request.getParameter("token");
		String password  = Util.encodeISO(request.getParameter("p"), "UTF8");
		String clientIp  = request.getRemoteAddr();
		String userAgent = request.getHeader("User-Agent");

		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("Auth_Legacy_Bridge.Reset_With_Token");
		cs.setString("i_Token", token);
		cs.setString("i_New_Password", password);
		cs.setString("i_Client_Ip", clientIp);
		cs.setString("i_User_Agent", userAgent);
		cs.registerString("o_Code");
		cs.registerString("o_Msg");
		cs.execute();

		response.setHeader("RT", "0".equals(cs.getString("o_Code")) ? "success" : "error");
		out.print(cs.getString("o_Msg"));
	} catch (Exception ex) {
		out.print(Util.getUserMessage(ex));
	} finally {
		if (conn != null) {
			try { conn.close(); } catch (Exception ex) {}
		}
	}
%>
