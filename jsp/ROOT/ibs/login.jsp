<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*,java.net.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
//-------------------------------------------------------------------------------------------------
	try {
		if (isIncorrectReferer(request.getHeader("Referer"))) {
			throw new RuntimeException("Hacking attempt!");
		}

		String login = Util.encodeISO(request.getParameter("u"), "UTF8");
		String password = Util.encodeISO(request.getParameter("p"), "UTF8");
		String nls = request.getParameter("nls");
		String fs = System.getProperty("file.separator");
		String url = application.getRealPath(fs) + fs + "ibs" + fs + "iabs.parameters";
		String required = null;
		String sn = request.getParameter("sn");
		String settingSN = "N";
		ServletCallableStatement cs = null;
		if (request.getParameter("crp") == null) {
			cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Test_User_Mfi.Required_Signature_Onlogon");
			cs.setString("i_Login", login);
			cs.setString("i_Password", password);
			cs.registerString("o_Registered_User_In_Asa");
			cs.registerString("o_Required");
			cs.registerString("o_Query_Line1");
			cs.registerString("o_Crp_Line1");
			cs.registerString("o_Query_Line2");
			cs.registerString("o_Signature_Js_Functions");
			cs.registerString("o_Serial_Number");
			cs.execute();
			String registeredUserInDVS = cs.getString("o_Registered_User_In_Asa");
			required = cs.getString("o_Required");
			String queryLine1 = cs.getString("o_Query_Line1");
			String crpLine1 = cs.getString("o_Crp_Line1");
			String queryLine2 = cs.getString("o_Query_Line2");
			String signFunction = cs.getString("o_Signature_Js_Functions");
			String serialNumber = cs.getString("o_Serial_Number");
			session.putValue("signFunction", signFunction);
			if ("Y".equals(required)) {
				response.setHeader("L", "S");
				out.println("try{");
				if (Util.isCross(request)) {
					out.println("window['settingSN']='" + settingSN + "';window['serialNumber']='" + serialNumber + "';window['queryLine2']='" + queryLine2 + "'; fbws.getSerialNumber(callBackSerialNumber); ");
				} else {
					out.print(signFunction);
					if (queryLine1 != null) {
						out.print("if(!verify('" + queryLine1 + "','" + crpLine1 + "'))throw new Error('Ё?ѕ неверна');");
					}
					out.print("run('&crp='+encodeURIComponent(sign('" + queryLine2 + "')), encrypt)");
				}

				out.print("}catch(e){ alert(e.message) }");
				return;
			}
		}
		iabs.User user = new iabs.User();

		cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("Test_User_Mfi.Logon");
		cs.setString("i_Login", login);
		cs.setString("i_Password", password);
		cs.registerString("o_Employee_Code");
		cs.registerString("o_Employee_Name");
		cs.registerString("o_Filial_Code");
		cs.registerString("o_Filial_Name");
		cs.registerString("o_Header_Code");
		cs.registerString("o_Header_Name");
		cs.registerString("o_Local_Code");
		cs.registerString("o_Local_Name");
		cs.registerString("o_Nls_Index");
		cs.registerString("o_Theme_Id");
		cs.registerString("o_Theme_Url");
		cs.registerString("o_Debug");
		cs.registerString("o_Change_Password");
		cs.execute();
		String employeeCode = cs.getString("o_Employee_Code");
		String employeeName = cs.getString("o_Employee_Name");
		String filialCode = cs.getString("o_Filial_Code");
		String filialName = cs.getString("o_Filial_Name");
		String headerCode = cs.getString("o_Header_Code");
		String headerName = cs.getString("o_Header_Name");
		String localCode = cs.getString("o_Local_Code");
		String localName = cs.getString("o_Local_Name");
		int langIndex = Integer.parseInt(cs.getString("o_Nls_Index"));
		String themeId = cs.getString("o_Theme_Id");
		String themeUrl = cs.getString("o_Theme_Url");
		String debug = "Y";//cs.getString("o_Debug");
		if ("Y".equals(debug)) {
			stored.setDebug(true);
			session.putValue("debug", debug);
		} else {
			stored.setDebug(false);
		}

		user.setUserCode(employeeCode);
		user.setUserName(employeeName);
		user.setFilialCode(filialCode);
		user.setFilialName(filialName);
		user.setHeaderCode(headerCode);
		user.setHeaderName(headerName);
		user.setLocalCode(localCode);
		user.setLocalName(localName);
		user.setLanguageIndex(langIndex);
		user.lockParameters();

		try {
			uz.fido_biznes.cms.Resource.setThemeURL(employeeCode, themeUrl);
		} catch (Exception ex) {
		}

		user.putValue("signFunction", session.getValue("signFunction"));
		pageContext.setAttribute("user", user, PageContext.SESSION_SCOPE);

		session.putValue("employee", employeeCode);
		session.putValue("emplName", employeeName);
		session.putValue("filialCode", filialCode);
		session.putValue("filialName", filialName);
		session.putValue("bxmCode", "440");
		session.putValue("ibs.chief.clientWidth", request.getParameter("x"));
		session.putValue("ibs.chief.clientHeight", request.getParameter("y"));
		session.putValue("operDay", "01.01.2025");
		session.putValue("ibs.cms.themeId", themeId);
		session.putValue("ibs.cms.themeUrl", themeUrl);
		session.putValue("server.ip", InetAddress.getLocalHost().getHostAddress());

		Resource.generateSecurityCredentials(pageContext, stored);

		response.setHeader("L", "U");
		if (("1".equals(themeId) || "2".equals(themeId)) && Util.isCross(request)) {
			out.print("location='main_.jsp?_='+(new Date()).getTime()");
		} else {
			session.putValue("ibs.cms.themeId", "0");
			out.print("location='main.jsp?_='+(new Date()).getTime()");
		}
	} catch (Exception ex) {
		out.print(Util.getUserMessage(ex));
		//out.print(ex.toString());
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