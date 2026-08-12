<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.util.*,java.net.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<%
	// Standalone entry point (like auth_login.jsp) - completes a mandatory password
	// change right after login (password_must_be_changed='Y', e.g. after an admin
	// reset). Requires the current (temp) password, matching Auth_Pwd_Kernel.Change_Password.
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

		String login       = Util.encodeISO(request.getParameter("u"), "UTF8");
		String oldPassword = Util.encodeISO(request.getParameter("op"), "UTF8");
		String newPassword = Util.encodeISO(request.getParameter("np"), "UTF8");
		String clientIp     = request.getRemoteAddr();
		String userAgent    = request.getHeader("User-Agent");

		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("Auth_Legacy_Bridge.Change_Password");
		cs.setString("i_Username", login);
		cs.setString("i_Old_Password", oldPassword);
		cs.setString("i_New_Password", newPassword);
		cs.setString("i_Client_Ip", clientIp);
		cs.setString("i_User_Agent", userAgent);
		cs.registerString("o_Code");
		cs.registerString("o_Msg");
		cs.execute();

		response.setHeader("RT", "0".equals(cs.getString("o_Code")) ? "success" : "error");
		out.print(cs.getString("o_Msg"));
		// Connection intentionally left open (session-scoped cods/stored) - the
		// browser redirects to main.jsp right after success and reuses it, same
		// convention as auth_login.jsp. Only close on a genuine unexpected error.
	} catch (Exception ex) {
		out.print(Util.getUserMessage(ex));
		if (conn != null) {
			try { conn.close(); } catch (Exception ex2) {}
		}
	}
%>
