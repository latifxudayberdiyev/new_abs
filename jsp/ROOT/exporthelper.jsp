<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	response.reset();
	String fileType = request.getParameter("file_type");
	String fileName = "excel." + fileType;

	java.io.OutputStream os = response.getOutputStream();
	uz.fido_biznes.cms.report.Table table = null;
	// if("Y".equals(request.getParameter("archive"))){
	// response.setContentType("application/zip;charset=Windows-1251");
	// response.addHeader("content-disposition","attachment; filename=excel.xls.zip");
	// java.util.zip.GZIPOutputStream gzipos = new java.util.zip.GZIPOutputStream(os);
	// table = new uz.fido_biznes.cms.report.Table(pageContext, request.getParameter("SN"),gzipos);
	// table.setIsAutoSize("Y".equals(request.getParameter("autosize")));
	// table.print();
	// gzipos.close();
	// } else {
	if ("XLS".equalsIgnoreCase(fileType)) {
		response.setContentType("application/vnd.ms-excel;charset=Windows-1251");
	} else {
		response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
	}

	response.addHeader("content-disposition", "attachment; filename=" + fileName);
	table = new uz.fido_biznes.cms.report.Table(pageContext, request.getParameter("SN"), os);
	table.setIsAutoSize("Y".equals(request.getParameter("autosize")));

	if ("XLS".equalsIgnoreCase(fileType)) {
		table.print();
	} else {
		table.printx();
	}
	os.close();
%>
