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
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setFunction("Core_Adm_Api.User_Profile_Model");
		cs.execute();
		%><script>var data=<%=cs.getStringResult()%></script><%
	} catch(Exception ex) {
		response.setHeader("RT", "alert");
		%><script>alert('<%= Util.quotesEsc(ex.getMessage()) %>');</script><%
	}
%><t:form title="<%=si_editTitle%>" minWidth="fill" minHeight="fill"  >
<script>
function onLoad(){

}
</script>
<iframe name=frm style="display:none;"></iframe>
<div id=basepanel class=panel >
<form name=fm method=post target=frm >
<table align=center border=0>
	<col width="25%" align="right" nowrap>
	<col width="75%" nowrap>
	<tr>
		<td><%=lang.get(si_name)%> :
		<td><input name="user_name" style="width:75%" disabled readonly >
	<tr>
		<td><%=lang.get(si_rank_code)%> :
		<td>
			<select name="post_id" style="width:75%" disabled >
				<t:options from="vm_post" code="code" name="name"/>
			</select>
	<tr>
		<td><%=lang.get(si_local_code)%> :
		<td>
			<select name="local_code" style="width:75%" disabled>
				<t:options from="vr_local_filial" code="code" name="name"/>
			</select>
	<tr>
		<td><%=lang.get(si_login)%> :
		<td><input name="login" style="width:25%"  disabled readonly >
	<tr>
		<td><%=lang.get(si_language)%> :
		<td>
			<select name="nls_index" style="width:25%" disabled >
				<option value="1">Русский</option>
				<option value="2">Узбекча кирилл</option>
				<option value="3">O'zbekcha lotin</option>
				<option value="4">English</option>
			</select>
</table>
</t:form></t:page>
<%!
	static final int si_editTitle		= SI("Данные пользователя","","","");
	static final int si_save				= SI("Сохранить","Саклаш","Saqlash","Save");
	static final int si_local_code	= SI("Локальный код","","","");
	static final int si_name				= SI("Ф.И.О сотрудника","","","");
	static final int si_login				= SI("Логин","","","");
	static final int si_password		= SI("Пароль","","","");
	static final int si_rank_code		= SI("Должность","","","");
	static final int si_language		= SI("Язык","Тил","Til","Language");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>