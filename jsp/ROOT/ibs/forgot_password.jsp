<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	String fs = System.getProperty("file.separator");
	String url = application.getRealPath(fs) + fs + "ibs" + fs + "iabs.parameters";

	iabs.oraDBConnection cods = new iabs.oraDBConnection();
	pageContext.setAttribute("cods", cods, PageContext.SESSION_SCOPE);
	iabs.DBParameters params = new iabs.DBParameters(url);
	params.initConnection(cods);
	Connection conn = cods.getConnection();
	if (conn == null) {
		throw new RuntimeException("Соединение с базой данных не установлено!");
	}
	iabs.StoredObject storedObj = new iabs.StoredObject();
	pageContext.setAttribute("storedObj", storedObj, PageContext.SESSION_SCOPE);
	storedObj.setConnection(conn);

	uz.fido_biznes.sql.StoredObject stored = new uz.fido_biznes.sql.StoredObject();
	pageContext.setAttribute("stored", stored, PageContext.SESSION_SCOPE);
	stored.setConnection(conn);
//-------------------------------------------------------------------------------------------------
%>
<t:page>
	<t:form minWidth="fill" minHeight="fill" emptyForm="">
		<head>
			<title>Форма восстановления пароля</title>
		</head>
		<body>
		<script type="text/javascript">
			function onLoad() {
				go({url: "forgot_password_contents.jsp", target: getDOM(contents), lock: false});
			}

		</script>
		<iframe width="100%" height="100%" align="center" marginheight="0" frameborder="0" name="contents" id="contents"
		        src="forgot_password_contents.jsp">
		</iframe>
		</body>
	</t:form>
</t:page>


<t:requests>
	<t:request name="set_temp_password"><%
		String userInput = request.getParameter("captchaInput");
		Object correctObj = session.getAttribute("captchaResult");
		session.removeAttribute("captchaResult"); // captcha faqat 1 martalik
		boolean correct = false;

		if (userInput != null && correctObj != null) {
			try {
				int userAnswer = Integer.parseInt(userInput.trim());
				int correctAnswer = (Integer) correctObj;
				correct = (userAnswer == correctAnswer);
			} catch (Exception e) {
				correct = false;
			}
		}
		if (correct) {
			try {
				ServletCallableStatement cs = new ServletCallableStatement(stored, request);
				cs.setProcedure("Core_Adm_Api.Reset_User_Forgotten_Password");
				cs.setAllParameters("request");
				cs.execute();
				response.setHeader("RT", "success");
				out.print("success");
			} catch (Exception ex) {
				out.print("error: " + Util.getUserMessage(ex));
				response.setHeader("RT", "error");
			}
		} else {
			response.setHeader("RT", "error");
			out.print("error: Результат в CAPTCH неверный.");
		}
	%></t:request>
</t:requests>