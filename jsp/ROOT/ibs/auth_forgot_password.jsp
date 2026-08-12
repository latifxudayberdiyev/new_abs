<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.util.*,java.net.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<%
	// Standalone entry point (like auth_login.jsp / forgot_password.jsp) - "forgot
	// password" request. Always returns a generic message regardless of whether the
	// login exists (Auth_Legacy_Bridge.Request_Password_Reset / Auth_Pwd_Kernel
	// enforce this) - do not add branching here that could leak account existence.
	// No token/link is ever returned to the browser - delivery (email/SMS) is not
	// wired yet, see Auth_Pwd_Kernel.Request_Password_Reset comment.
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

		String login     = Util.encodeISO(request.getParameter("u"), "UTF8");
		String clientIp  = request.getRemoteAddr();
		String userAgent = request.getHeader("User-Agent");

		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("Auth_Legacy_Bridge.Request_Password_Reset");
		cs.setString("i_Username", login);
		cs.setString("i_Client_Ip", clientIp);
		cs.setString("i_User_Agent", userAgent);
		cs.registerString("o_Code");
		cs.registerString("o_Msg");
		cs.execute();

		out.print(cs.getString("o_Msg"));
	} catch (Exception ex) {
		out.print(Util.getUserMessage(ex));
	} finally {
		if (conn != null) {
			try { conn.close(); } catch (Exception ex) {}
		}
	}
%>
