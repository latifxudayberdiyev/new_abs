<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%@ page import="java.io.*" %>
<%@ page import="com.ibm.useful.http.*" %>
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	PostData request2 = new PostData(request);
	String format = request2.getParameter("format");
	if (format != null && format != "") {
%>
	<script><%
		OracleCallableStatement cs = null;
		String query="";
		
		File tempF = File.createTempFile("screenshot",".gif");
			tempF.deleteOnExit();
		try {
			query = "begin Core_Adm_Api.Save_Theme("
							+ "i_url => ?/*1*/,"
							+ "i_screenshot => ?/*2*/"
							+ ");end;";
			cs = (OracleCallableStatement) conn.prepareCall(query);
			
			FileData fileData = request2.getFileData("screenshot");
			FileOutputStream fos = new FileOutputStream(tempF);
				fos.write(fileData.getByteData());
				fos.close();
			
			FileInputStream	 fis = new FileInputStream(tempF);
			cs.setString(1,request2.getParameter("url"));
			if (tempF.length()>50000) {
				fis.close();
				tempF.delete();
				throw new SQLException("Размер слишком большой (рекомендуем 3см/4см. 85px/113px)!");
			}
					cs.setBinaryStream(2, fis, (int) tempF.length());
					cs.execute();
						fis.close();
			%>alert('Данные сохранены успешно!');
	<%
			} catch (SQLException err) {
				%>alert('<%= Util.quotesEsc(Util.getUserMessage(err)) %>');
	<%
			} finally {
				tempF.delete();
				%>parent.pageLock(false);<%
		}
	%></script>
	<%
		}
	%>

	<t:form title="<%= si_formTitle %>" minHeight="fill" minWidth="fill">
		<script>
			function save1() {
				var urlF = fm.screenshot.value;
				var format = urlF.split('.')[1];
				if (typeof (format) != "undefined") {
					fm.format.value = format;
				}
			}
		</script>
		<iframe width=0 height=0 name=frm></iframe>
		<form name=fm enctype='multipart/form-data' method="POST">
			<input type=hidden name=id>
			<table align=center class=formToolbar cellspacing=2>
				<tr>
					<td><input type=submit name=save style="width:90" value="<%= lang.get(si_save) %>">
			</table>
			<div id=basepanel class=panel>
				<table>
					<tr>
						<td align=center><%=lang.get(si_file)%>:<input name=url r=1>
					<tr>
						<td align=center><input type=file name=screenshot onchange="save1()" r=1>
							<input type=hidden name=format value="" r=1>
					<tr>
						<td id="td_photo" align=center>
							<!-- 4 x 5 : 113 x 142 -->
							<!-- 3 x 4 : 85 x 113 -->
							<!-- 3 x 4 : 117 x 156 -->
				</table>
			</div>
		</form>
	</t:form>
</t:page><%!
	static final int si_formTitle = SI("Фото");
	static final int si_save = SI("Сохранить", "Саклаш", "Saqlash");
	static final int si_file = SI("Путь файла", "", "", "");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
