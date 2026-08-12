<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.util.*,java.net.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<%
	// LOCAL login backed by CORE.AUTH_API (nonce + stage-token + PBKDF2+pepper,
	// see D:\Projects\git\new_abs\core\auth) instead of the legacy
	// Test_User_Mfi.Logon flow used by login.jsp. Only the LOCAL provider
	// (username/password) is wired here; AD/DSC tabs still go through login.jsp.
	//
	// Password travels once over HTTPS to this endpoint - that transport is
	// what protects it, not client-side crypto (see Auth_Legacy_Bridge.pck).
	//
	// Standalone entry point (no login_before.jsp/login_after.jsp call before
	// it), so - like forgot_password.jsp / login_crobs.jsp - it must open the
	// DB connection itself instead of assuming a session-scoped "cods" bean is
	// already connected (that assumption only holds for login.jsp, which is
	// always preceded by login_before/login_after in the same session).
	String fs = System.getProperty("file.separator");
	String url = application.getRealPath(fs) + fs + "ibs" + fs + "iabs.parameters";

	iabs.oraDBConnection cods = new iabs.oraDBConnection();
	pageContext.setAttribute("cods", cods, PageContext.SESSION_SCOPE);
	iabs.DBParameters params = new iabs.DBParameters(url);
	params.initConnection(cods);
	Connection conn = cods.getConnection();
	if (conn == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}

	iabs.StoredObject storedObj = new iabs.StoredObject();
	pageContext.setAttribute("storedObj", storedObj, PageContext.SESSION_SCOPE);
	storedObj.setConnection(conn);

	uz.fido_biznes.sql.StoredObject stored = new uz.fido_biznes.sql.StoredObject();
	pageContext.setAttribute("stored", stored, PageContext.SESSION_SCOPE);
	stored.setConnection(conn);
//-------------------------------------------------------------------------------------------------
	try {
		if (isIncorrectReferer(request.getHeader("Referer"))) {
			throw new RuntimeException("Hacking attempt!");
		}
		if (conn == null) {
			throw new RuntimeException("Ma'lumotlar bazasiga ulanish o'rnatilmadi!");
		}

		String login     = Util.encodeISO(request.getParameter("u"), "UTF8");
		String password  = Util.encodeISO(request.getParameter("p"), "UTF8");
		String clientIp  = request.getRemoteAddr();
		String userAgent = request.getHeader("User-Agent");

		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("Auth_Legacy_Bridge.Login_Local");
		cs.setString("i_Username", login);
		cs.setString("i_Password", password);
		cs.setString("i_Client_Ip", clientIp);
		cs.setString("i_User_Agent", userAgent);
		cs.registerString("o_Session_Token");
		cs.registerString("o_User_Id");
		cs.registerString("o_Name");
		cs.registerString("o_Cb_Code");
		cs.registerString("o_Local_Code");
		cs.registerString("o_Filial_Name");
		cs.registerString("o_Lang");
		cs.registerString("o_Must_Change_Password");
		cs.registerString("o_Code");
		cs.registerString("o_Msg");
		cs.execute();
		if (!"0".equals(cs.getString("o_Code"))) {
			out.print(cs.getString("o_Msg"));
			return;
		}

		String userId     = cs.getString("o_User_Id");
		String name       = cs.getString("o_Name");
		String cbCode     = cs.getString("o_Cb_Code");
		String localCode  = cs.getString("o_Local_Code");
		String filialName = cs.getString("o_Filial_Name");
		String lang       = cs.getString("o_Lang");
		boolean mustChangePassword = "Y".equals(cs.getString("o_Must_Change_Password"));

		// NOTE: header/local display NAMES and theme URL still have no
		// equivalent in CORE_USERS (only codes/filial name via Abs_Branches).
		// Using the code as a placeholder for those and skipping
		// Resource.setThemeURL - revisit once that lookup exists.
		int langIndex = 1; // RU
		/*if ("uz".equalsIgnoreCase(lang)) {
			langIndex = 2; // UZL (latin)
		} else if ("en".equalsIgnoreCase(lang)) {
			langIndex = 3;
		}*/

		iabs.User user = new iabs.User();
		user.setUserCode(userId);
		user.setUserName(name);
		user.setFilialCode(cbCode);
		user.setFilialName(filialName);
		user.setHeaderCode(cbCode);
		user.setHeaderName(cbCode);
		user.setLocalCode(localCode);
		user.setLocalName(localCode);
		user.setLanguageIndex(langIndex);
		user.lockParameters();

		pageContext.setAttribute("user", user, PageContext.SESSION_SCOPE);

		session.putValue("employee", userId);
		session.putValue("emplName", name);
		session.putValue("filialCode", cbCode);
		session.putValue("filialName", filialName);
		session.putValue("bxmCode", "440");
		session.putValue("ibs.chief.clientWidth", request.getParameter("x"));
		session.putValue("ibs.chief.clientHeight", request.getParameter("y"));
		session.putValue("operDay", "01.01.2025");
		session.putValue("ibs.cms.themeId", "0");
		session.putValue("server.ip", InetAddress.getLocalHost().getHostAddress());

		Resource.generateSecurityCredentials(pageContext, stored);

		response.setHeader("L", "U");
		if (mustChangePassword) {
			response.setHeader("MCP", "Y");
		}
		out.print("location='main.jsp?_='+(new Date()).getTime()");
	} catch (Exception ex) {
		out.print(Util.getUserMessage(ex));
		session.invalidate();
		if (conn != null) {
			conn.close();
		}
	} catch (Throwable ex) {
		out.print(ex.toString());
		ex.printStackTrace();
		session.invalidate();
		if (conn != null) {
			conn.close();
		}
	}
%><%!
	private boolean isIncorrectReferer(String referer) {
		return false;
	}
%>
