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
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("User_API.Logon_By_VU");
		cs.setString("i_User_Id", request.getParameter("user_id"));
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
		String debug = cs.getString("o_Debug");

		if ("Y".equals(debug)) {
			stored.setDebug(true);
			session.putValue("debug", debug);
		} else {
			stored.setDebug(false);
		}

		user = new iabs.User();
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
		session.putValue("localCode", localCode);
		session.putValue("localName", localName);
		session.putValue("bxmCode", stored.execFunction("setup.Bxm_Code"));
		session.putValue("ibs.chief.clientWidth", request.getParameter("x"));
		session.putValue("ibs.chief.clientHeight", request.getParameter("y"));
		session.putValue("operDay", stored.execFunction("to_char(setup.Get_OperDay,'dd.mm.yyyy')"));
		session.putValue("ibs.cms.themeId", themeId);
		session.putValue("ibs.cms.themeUrl", themeUrl);

		iabs.ChatService.registerUser(employeeCode);
		iabs.ChatService.start();

		response.setHeader("L", "U");
		out.print("Y");
	} catch (Exception ex) {
		// out.print(Util.getUserMessage(ex));
		out.print(ex.toString());
	} catch (Throwable ex) {
		out.print(ex.toString());
		ex.printStackTrace();
	}
%>
<%@ include file="/language.jsp" %>