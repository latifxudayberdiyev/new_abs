<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
%><jsp:useBean id="util" class="iabs.oraUtil" scope="session" /><%
	Connection conn = cods.getConnection();
	if(conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="500" minHeight="300">
<style>
	th{
		text-align:right;
	}
</style>
<iframe name=frm style="display:none" ></iframe>
<form name=fm target=frm>
<input type=hidden name=request value=save>
<table align=center class=formToolbar>
	<tr>
		<td><input type="submit" value="<%=lang.get(si_save)%>" >
</table>
<table>
	<tr>
		<th><%=lang.get(si_old_pwd)%> <q></q>:
		<td><input type="password" name="old_password" r=1 >
	<tr>
		<th><%=lang.get(si_pwd)%> <q></q>:
		<td><input type="password" name="new_password" r=1 >
	<tr>
		<th><%=lang.get(si_new_pwd)%> <q></q>:
		<td><input type="password" name="confirm_password" r=1 >
</table>
</t:form>
</t:page>
<t:request name="save"><script><%
	try{
		ServletCallableStatement cs = new ServletCallableStatement(stored,request);
		cs.setProcedure("core_adm_api.change_user_password");
		cs.setStringParameter("i_password_old","old_password");
		cs.setStringParameter("i_password_new","new_password");
		cs.setStringParameter("i_password_new2","confirm_password");
		cs.execute();
		%>alert('<%=lang.get(si_success)%>');parent.go({});<%
	} catch(Exception ex) {
    Util.alertUserMessage(ex, out, false);
    %>parent.pageLock(false);<%
  }
%></script></t:request>
<%!
static final int si_title   = SI("»зменение парол€ пользовател€","‘ойдаланувчи паролини Ґзгартириш","Foydalanuvchi parolini o`zgartirish","");
static final int si_save    = SI("—охранить","—а&#1179;лаш","Saqlash","Save");
static final int si_old_pwd = SI("¬ведите старый пароль","Ёски паролни киритинг","Eski parolni kiriting","");
static final int si_pwd     = SI("¬ведите новый пароль","янги паролни киритинг","Yangi parolni kiriting","");
static final int si_new_pwd = SI("ѕодтверждение парол€","ѕаролни тасди&#1179;лаш","Parolni tasdiqlash","");
static final int si_success = SI("”спешно выполнено!","ћуваффа&#1179;и€тли бажарилди!","Muvaffaqiyatli bajarildi!","Successfully executed!");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
