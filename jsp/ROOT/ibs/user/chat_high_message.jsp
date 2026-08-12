<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="util" class="iabs.oraUtil" scope="session" /><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
%><jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session"/><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
String message_id = request.getParameter("message_id");
String message_text = new String(request.getParameter("message_text").getBytes("ISO8859_1"),"WINDOWS-1251");
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill"  >
<style>
.message {
	height:100%;
	margin:10px;
	padding:15px;
	font-size:12pt;
	border: 1px solid 
}
</style>
<div id="basepanel" class="panel" >
<iframe name="frm" style="display:none;"></iframe>
<form name="fm" method="post" target="frm" >
<input type="hidden" name="request" value="save">
<input type="hidden" name="message_id" value="<%=message_id%>">
<table class="formToolbar" align="center" >
	<tr>
		<td><input type="submit" value="<%=lang.get(si_save)%>">
		<td align="right"><input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close();">
</table>
<fieldset class="message"><%=message_text%></fieldset>
</t:form></t:page>
<t:request name="save"><%
	try{
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("User_Api.Delete_Chat_Message");
		cs.setArrayNumberParameter("i_message_ids","message_id");
		cs.execute();
		%><script>alert('<%=lang.get(si_success)%>');window.returnValue=true;top.close();</script><%
	} catch(Exception ex) {
		response.setHeader("RT", "alert");
		Util.alertUserMessage(ex, out);
		%><script>parent.pageLock(false);</script><%
	}
%></t:request>
<%!
	static final int si_title				= SI("Срочная сообщения","&#1179;ўшиш","Qo'shish","Adding");
	static final int si_save				= SI("Отметить как прочитанное","Ў&#1179;илган деб белгилаш","O'qilgan deb belgilash","Mark as Read");
	static final int si_exit				= SI("Закрыть","Чи&#1179;иш","Chiqish","Exit");
	static final int si_success			= SI("Успешно выполнено!","Мувоффа&#1179;иятли бажарилди!","Muvoffaqiyatli bajarildi!","Successfully executed!");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>