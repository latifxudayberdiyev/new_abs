<%@ page import="java.sql.*,java.net.*,uz.fido_biznes.cms.*,java.io.*" contentType="text/html;charset=Windows-1251" %>
<%
	Connection conn = null;
	try {
		System.out.println("HIT: " + request.getRequestURI());
		if (isIncorrectReferer(request.getHeader("Referer"))) {
			throw new RuntimeException("Hacking attempt!");
		}
		String login = Util.encodeISO(request.getParameter("u"), "UTF8");
		String password = Util.encodeISO(request.getParameter("p"), "UTF8");

		String fs = System.getProperty("file.separator");
		String url = application.getRealPath(fs) + fs + "ibs" + fs + "iabs.parameters";
		ServletCallableStatement cs = null;

		iabs.oraDBConnection cods = new iabs.oraDBConnection();
		pageContext.setAttribute("cods", cods, PageContext.SESSION_SCOPE);
		iabs.DBParameters params = new iabs.DBParameters(url);
		params.initConnection(cods);
		conn = cods.getConnection();
		if (conn == null) {
			throw new RuntimeException("Соединение с базой данных не установлено!");
		}
		iabs.StoredObject storedObj = new iabs.StoredObject();
		pageContext.setAttribute("storedObj", storedObj, PageContext.SESSION_SCOPE);
		storedObj.setConnection(conn);

		uz.fido_biznes.sql.StoredObject stored = new uz.fido_biznes.sql.StoredObject();
		pageContext.setAttribute("stored", stored, PageContext.SESSION_SCOPE);
		stored.setConnection(conn);

		cs = new ServletCallableStatement(stored, request);
		cs.setFunction("Test_User_Mfi.Get_Uuid");
		cs.setString("i_Login", login);
		cs.setString("i_Password", password);
		cs.execute();
		String uuid = cs.getStringResult();

		response.setHeader("L", "S");
		out.print(uuid);
	} catch (Exception ex) {
		out.print(Util.getUserMessage(ex));
		// out.print(ex.toString());
		if (conn != null) {
			conn.close();
		}
	} catch (Throwable ex) {
		out.print(ex.toString());
		ex.printStackTrace();
		if (conn != null) {
			conn.close();
		}
	}
%><%!
	private boolean isIncorrectReferer(String referer) {
		return false;
	}
%>