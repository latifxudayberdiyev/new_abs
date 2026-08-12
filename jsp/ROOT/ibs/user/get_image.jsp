<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<%@ page import="java.io.*,javax.servlet.*, javax.servlet.http.*" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
//-------------------------------------------------------------------------------------------------
	String id = request.getParameter("id");
	String image_type = request.getParameter("image_type");
	ServletOutputStream output = response.getOutputStream();
	OracleStatement statement = null;
	OracleResultSet resultset = null;
	try {
		String sqlCmd = "select Core_Adm_Api.Get_Image(" + id + ",'" + image_type + "') from dual";
		if ("FACE".equals(image_type) || "FACE_CAPTURED".equals(image_type) || "FACE_MATCHED".equals(image_type)) {
			sqlCmd = "select Bio_Api.Get_Image(" + id + ",'" + image_type + "') from dual";
		}
		statement = (OracleStatement) conn.createStatement();
		resultset = (OracleResultSet) statement.executeQuery(sqlCmd);
		if (resultset.next()) {
			response.setContentType("image/jpeg");
			byte[] buffer = new byte[1];
			InputStream is = resultset.getBinaryStream(1);
			while (is.read(buffer) > 0) {
				output.write(buffer);
			}
		}
		output.flush();
	} finally {
		if (resultset != null)
			try {
				resultset.close();
			} catch (SQLException ignore) {
			}
		if (statement != null)
			try {
				statement.close();
			} catch (SQLException ignore) {
			}
	}
%>