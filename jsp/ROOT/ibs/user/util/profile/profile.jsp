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
	function onLoad() {
		var lang_prefix, lang_index = "<%=user.getLanguageIndex()%>";
		switch(parseInt(lang_index)) {
			case 1: lang_prefix = "RU"; break;
			case 2: lang_prefix = "UZC"; break;
			case 3: lang_prefix = "UZL"; break;
			case 4: lang_prefix = "EN"; break;
			default: lang_prefix = "RU";
		}
		setDOMValue("nls_index", lang_prefix);
	}
	function changeTheme(id) {
		AJAX.load({
			POST: {
				request: 'change_lang',
				langIndex: id
			},
			onSuccess: function (d) {
				alert(d);
				setDOMValue("nls_index", id);
			}
		});
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
		<td><input name="user_name" style="width:75%" disabled readonly value="<%=user.getUserName()%>">
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
			<select id="nls_index" name="nls_index" style="width:25%" onchange="changeTheme(this.value)" >
				<option value="RU">Русский</option>
				<option value="UZC">Узбекча кирилл</option>
				<option value="UZL">O'zbekcha lotin</option>
				<option value="EN">English</option>
			</select>
</table>
</t:form>
</t:page>
<t:requests>
	<t:request name="change_lang" responseType="text"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("core_menu.Change_User_Lang");
			cs.setStringParameter("i_Lang", "langIndex");
			cs.execute();
			out.print(lang.get(si_success));
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(ex.getMessage());
		}
	%></t:request>
</t:requests>
<%!
static final int si_editTitle  = SI("Данные пользователя","Фойдаланувчи маълумотлари","Foydalanuvchi ma`lumotlari","");
static final int si_save       = SI("Сохранить","Са&#1179;лаш","Saqlash","Save");
static final int si_local_code = SI("Локальный код","Локал код","Lokal kod","");
static final int si_name       = SI("Ф.И.О сотрудника","Ходим Ф.И.О си","Xodim F.I.O si","");
static final int si_login      = SI("Логин","Логин","Login","");
static final int si_password   = SI("Пароль","Парол","Parol","");
static final int si_rank_code  = SI("Должность","Лавозим","Lavozim","");
static final int si_language   = SI("Язык","Тил","Til","Language");
static final int si_success    = SI("Успешно завершено! Пожалуйста, войдите снова, чтобы изменить язык","Муваффа&#1179;иятли якунланди! Тилни ўзгартириш учун &#1179;айта киринг","Muvaffaqiyatli yakunlandi! Tilni o'zgartirish uchun qayta kiring","Successfully completed! Please log in again to change the language");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
