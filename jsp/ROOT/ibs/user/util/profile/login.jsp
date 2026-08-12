<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
%><jsp:useBean id="util" class="iabs.oraUtil" scope="session" /><%
%><jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session"/><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
<style>
	th{
		text-align:right;
	}
</style>
<iframe name=frm style="display:none" ></iframe>
<form name=fm target=frm>
<input type=hidden name=request value=save>
<table align=center class=formToolbar >
	<tr>
		<td><input type="submit" value="<%=lang.get(si_save)%>" >
</table>
<table align=center>
	<tr>
		<th><%=lang.get(si_old)%> <q></q>:
		<td><input name="old_login" r=1>
	<tr>
		<th><%=lang.get(si_new)%> <q></q>:
		<td><input name="new_login" r=1>
	<tr>
		<th><%=lang.get(si_conf)%> <q></q>:
		<td><input name="confirm_login" r=1>
</table>
</t:form>
</t:page>
<t:request name="save"><script><%
	try{
		ServletCallableStatement cs = new ServletCallableStatement(stored,request);
		cs.setProcedure("core_adm_api.change_user_login");
		cs.setStringParameter("i_login_old","old_login");
		cs.setStringParameter("i_login_new","new_login");
		cs.setStringParameter("i_login_new2","confirm_login");
		cs.execute();
		%>alert('<%=lang.get(si_success)%>');parent.go({});<%
	}  catch(Exception ex) {
    Util.alertUserMessage(ex, out, false);
    %>parent.pageLock(false);<%
  }
%></script></t:request>
<%!
static final int si_title   = SI("Изменение логина пользователя","Фойдаланувчи логинини ўзгартириш","Foydalanuvchi loginini o`zgartirish","");
static final int si_save    = SI("Сохранить","Са&#1179;лаш","Saqlash","Save");
static final int si_exit    = SI("Закрыть","Ёпиш","Yopish","Exit");
static final int si_old     = SI("Введите старый логин","Эски логинни киритинг","Eski loginni kiriting","");
static final int si_new     = SI("Введите новый логин","Янги логинни киритинг","Yangi loginni kiriting","");
static final int si_conf    = SI("Подтверждение логина","Логинни тасди&#1179;лаш","Loginni tasdiqlash","");
static final int si_success = SI("Успешно выполнено!","Муваффа&#1179;иятли бажарилди!","Muvaffaqiyatli bajarildi!","Successfully executed!");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
