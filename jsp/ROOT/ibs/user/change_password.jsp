<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if(conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//----------------------------------------------------------------------------------------------------
%><t:page><%
	String login = request.getParameter("login");
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setFunction("Core_Adm_Api.User_Password_Model");
		cs.setAllParameters("request");
		cs.execute();
		%><script>var data=<%=cs.getStringResult()%></script><%
	} catch(Exception ex) {
		response.setHeader("RT", "alert");
		%><script>/*alert('<%= Util.quotesEsc(ex.getMessage()) %>');*/</script><%
	}
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
<script>
var const_min = 2, const_sec = 1, const_time;
function checkPassword() {
	if(this.value != getDOMValue("password_new")) {
		alert("<%=lang.get(si_alert)%>");
		fm.password_new.focus();
		return false;
	}
	return true;
}
function checkSMS() {
	if(this.value != getDOMValue("sms_number") && getDOMValue("sms_number") != "") {
		alert("<%=lang.get(si_alert)%>");
		//fm.sms_number_check.focus();
		return false;
	}
	getDOM("bSave").disabled = false;
	run();
	return true;
}
function checkTime() {
  const_sec--;
  if (const_sec == -1) {
    const_sec = 59;
    const_min--;
  }
	if((const_min == 0) && (const_sec == 0)) {
		getDOM("resend").innerHTML = '<input type="button" name="bReSend" onclick="send(true)" value="<%=lang.get(si_resend)%>">';
		initDOM(getDOM("resend"));
		const_min = 2;
	} else {
    const_time = setTimeout("checkTime()", 1000);
		setDOMValue("resend","<%=lang.get(si_wait)%> " + const_min + ":" + ((const_sec < 10)? "0" + const_sec : const_sec));
		getDOM("phone").innerHTML = "<%=lang.get(si_send)%> " + fm.phone_number.value + "<br><a class='withFilter' onclick='edit()'><%=lang.get(si_reset)%></a>";
	}
}
function checkForm() {
	if(fm.password_old.value == "") {
		fm.password_old.focus();
		return false;
	} else if(fm.password_new.value == "") {
		fm.password_new.focus();
		return false;
	} else if(fm.password_new2.value == "") {
		fm.password_new2.focus();
		return false;
	} else if(fm.sms_confirmation.value == "Y" && fm.phone_number.value == "") {
		fm.phone_number.focus();
		return false;
	} else {
		return true;
	}
}
function send(bool) {
	if(bool || checkForm() && confirm("<%=lang.get(si_ask)%>\n" + fm.phone_number.value)) {
		AJAX.load({
			POST:{
				request : "send_sms"
				, system_id: fm.system_id.value
				, login: fm.login.value
				, password_old: fm.password_old.value
				, password_new: fm.password_new.value
				, password_new2: fm.password_new2.value
				, phone_number: fm.phone_number.value
			},
			onSuccess:function (d) {
				hideDOM("bCheck");
				showDOM("bSave");
				getDOM("bSave").disabled = true;
				setDOMValue(fm.sms_number, d.trim());
				hideDOM("fm_data");
				showDOM("fm_detail");
				fm.sms_number_check.focus();
				checkTime();
			},
			onError:function (d) {
				alert(d);
			}
		});
	}
}
function edit() {
	const_min = 2, const_sec = 1;
	clearTimeout(const_time);
	hideDOM("bSave");
	showDOM("bCheck");
	showDOM("fm_data");
	hideDOM("fm_detail");
	fm.phone_number.focus();
}
function run() {
	if(checkForm()) fm.submit();
}
function onLoad() {
	if(fm.sms_confirmation.value == "Y") {
		hideDOM("bSave");
		showDOM("bCheck");
	}
}
</script>
<div id="basepanel" class="panel">
<iframe name="frm" style="display:none"></iframe>
<form name="fm" target="frm">
<input type="hidden" name="request" value="save">
<input type="hidden" name="system_id" value="0" >
<input type="hidden" name="login" value="<%=login%>">
<input type="hidden" name="sms_number" value="">
<input type="hidden" name="sms_confirmation" value="">
<table align="center" class="formToolbar">
<tr><td>
		<input type="button" name="bCheck" onclick="send()" value="<%=lang.get(si_check)%>" style="display:none">
		<input type="button" name="bSave" onclick="run()" value="<%=lang.get(si_save)%>" >
	<td align="right">
		<input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
</table>
<table id="fm_data">
	<tr>
		<td align="right"><%=lang.get(si_password_old)%>	<q></q>:
		<td><input type="password" name="password_old" r=1>
	<tr>
		<td align="right"><%=lang.get(si_password_new)%> <q></q>:
		<td><input type="password" name="password_new" id="new_password2" r=1 >
	<tr>
		<td align="right"><%=lang.get(si_password_new2)%> <q></q>:
		<td><input type="password" name="password_new2" validate="checkPassword" r=1 >
	<tr showhide="!fm.sms_confirmation['']&&fm.sms_confirmation['Y']">
		<td align="right"><%=lang.get(si_phone)%> <q></q>:
		<td><input name="phone_number" mask="(+998-{2|0-9}) {3|0-9} {2|0-9} {2|0-9}" r="((fm.sms_confirmation.value == 'Y') ? 1 : 0)" >
</table>
<table id="fm_detail" style="display:none;">
	<tr><th colspan="2" id="phone">&nbsp;
	<tr>
		<td align="right"><%=lang.get(si_sms_code)%> <q></q>:
		<td><input name="sms_number_check" mask="10|0-9" validate="checkSMS" r=1 >
	<tr><th colspan="2" id="resend">&nbsp;
</table>
</t:form>
</t:page>
<t:requests>
<t:request name="save"><%
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("Core_Adm_Api.Change_User_Password");
		cs.setNumberParameter("i_System_Id","system_id");
		cs.setStringParameter("i_Login","login");
		cs.setStringParameter("i_Password_Old","password_old");
		cs.setStringParameter("i_Password_New","password_new");
		cs.setStringParameter("i_Password_New2","password_new2");
		cs.setStringParameter("i_Phone_Number","phone_number");
		cs.execute();
		%><script>alert('<%=lang.get(si_success)%>');top.returnValue="Y";top.close();</script><%
	} catch(Exception ex) {
		Util.alertUserMessage(ex, out, true);
		%><script>parent.pageLock(false);</script><%
	}
%></t:request>
<t:request name="send_sms" responseType="txt"><%
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setFunction("Core_Adm_Api.Check_User_Password");
		cs.setNumberParameter("i_System_Id","system_id");
		cs.setStringParameter("i_Login","login");
		cs.setStringParameter("i_Password_Old","password_old");
		cs.setStringParameter("i_Password_New","password_new");
		cs.setStringParameter("i_Password_New2","password_new2");
		cs.setStringParameter("i_Phone_Number","phone_number");
		cs.execute();
		out.print(cs.getStringResult());
	} catch(Exception ex) {
		response.setHeader("RT", "error");
		out.print(Util.getUserMessage(ex));
	}
%></t:request>
</t:requests>
<%!
static final int si_title					= SI("Изменение пароля","Паролни ўзгартириш","Parolni o`zgartirish","");
static final int si_save					= SI("Сохранить","Са&#1179;лаш","Saqlash","Save");
static final int si_check					= SI("Проверка","","","");
static final int si_reset					= SI("Изменить номер телефона","","","Edit phone number");
static final int si_resend				= SI("Отправить код через SMS","","","Send code via SMS");
static final int si_send					= SI("Мы отправили код на номер","","","");
static final int si_exit					= SI("Закрыть","Ёпиш","Yopish","Exit");
static final int si_ask						= SI("Правильно введен номер телефона?","","","");
static final int si_alert					= SI("Не верно введен пароль. Повторите ввод","Парол нотў&#1171;ри киритилган. &#1178;айта киритинг","Parol noto`g`ri kiritilgan. Qayta kiriting","");
static final int si_login					= SI("Логин","Логин","Login","Login");
static final int si_password_old	= SI("Старый пароль","Эски парол","Eski parol","");
static final int si_password_new	= SI("Новый пароль","Янги парол","Yangi parol","");
static final int si_password_new2 = SI("Новый пароль для подтверждения","Тасди&#1179;лаш учун янги парол","Tasdiqlash uchun yangi parol","");
static final int si_phone					= SI("Мобильный телефон","Мобил номер","Mobil nomer","");
static final int si_sms_code			= SI("Введите ваш код","","","Enter your code");
static final int si_wait					= SI("Вы сможете запросить SMS через","","","You will be able to request SMS in");
static final int si_success				= SI("Новый пароль сохранен, \\nПожалуйста, войдите в систему заново","Янги парол са&#1179;ланди, \\nИлтимос, тизимга &#1179;айта киринг","Yangi parol saqlandi, \\nIltimos, tizimga qayta kiring","");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
