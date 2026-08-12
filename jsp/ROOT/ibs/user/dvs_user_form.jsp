<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String empCode = request.getParameter("empCode");
	ServletCallableStatement cs = null;
	if (request.getParameter("sbmt") != null) {
		try {
			cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("User_Api.Save_Users_Ekeys");
			cs.setEncryptedParameter("empCode", "CORE_USERS");
			cs.setNumberParameter("i_Emp_Code", "empCode");
			cs.setArrayNumberParameter("i_Ekey_Type_Id_List", "ekeyTypeId");
			cs.setArrayNumberParameter("i_Ekey_Id_List", "ekeyId");
			cs.setArrayStringParameter("i_serial_number_list", "serialNumber");
			cs.setNumberParameter("i_Active_Ekey_Index", "aii");
			cs.setStringParameter("i_Check_Signature_Onlogon", "checkOnLogon");
			cs.execute();
			%><script>function onLoad(){alert('Данные сохранены успешно!');top.returnValue=true;top.close();}</script><%
		} catch(Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			%><script>parent.pageLock(false);</script><%
		}
	}
	cs = new ServletCallableStatement(stored, request);
	cs.setFunction("User_Api.Asa_User_Model");
	cs.setEncryptedParameter("empCode", "CORE_USERS");
	cs.setNumberParameter("i_Emp_Code", "empCode");
	cs.execute();
	%><script>data=<%= cs.getStringResult() %></script><%
%><t:form noCache="" titleText="Закрепление DVS-ключей" minWidth="fill" minHeight="fill">
<script>
function AI(){
	for(var i=2;i<fm.aii.length;i++){
		fm.aii[i].value=i;
	}
}
function onLoad(){
	setDOMValue(fm.empCode,"<%=empCode%>");
}
</script>
<form name=fm>
<input type=hidden name=empCode>
<table align=center class=formToolbar cellspacing=2>
	<tr><td><input type=submit value=Сохранить name=sbmt>
	<td align=right><button onclick="top.close()">Выход</button>
</table>
<div id=basepanel class=panel>
<table>
	<tr><td>Ползователь:<td id=emp>
	<tr><td><td><label><input type=checkbox name=checkOnLogon value=Y>Проверить подпись при подключении</label>
	<table class=multiple><tr><td>Система<td>Идентификатор пользователя<td>Серийный номер<br><b>(64|0-9A-Z)</b><td>Активный ключ<br><input type=radio name=aii value=0 checked><td>&nbsp;
				 <tr><td><select name=ekeyTypeId><option value=1>AS<option value=2>DVS<option value=3>STYX<option value=4>GAuth
				 <%if("09005".equals(user.getHeaderCode())) {%><option value=11>MKB<%}%></select>
				 <%if("09048".equals(user.getHeaderCode())) {%><option value=11>UBANK<%}%></select>
				 <%if("09030".equals(user.getHeaderCode())) {%><option value=11>TBANK<%}%></select>
						 <td><input name=ekeyId mask="12|0-9" a=r nullable=1>
						 <td><input name=serialNumber mask="64|0-9A-Za-z" a=r nullable=1>
						 <td><input type=radio name=aii value=1>
						 <td><input type=button insdel=1 afterInsert=AI>
	</table>
</table>
</t:form>
</t:page>
<%!
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
