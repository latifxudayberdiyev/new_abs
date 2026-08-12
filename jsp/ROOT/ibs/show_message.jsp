<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.driver.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//------------------------------------------------------------------------------------
%><t:page><%
	String index = Util.nvl(request.getParameter("index"),"0");
	String action = request.getParameter("action");
	if(action != null) {
		try {
			if("resolved".equals(action)) {
				ServletCallableStatement cs = new ServletCallableStatement(stored, request);
				cs.setProcedure("Mlm_Api.User_Resolved");
				cs.setAllParameters("request");
				cs.execute();
			} else if("send_fido".equals(action)) {
				ServletCallableStatement cs = new ServletCallableStatement(stored, request);
				cs.setProcedure("Mlm_Api.Send_Fido");
				cs.setAllParameters("request");
				cs.execute();
			} else if("send_admin".equals(action)) {
				ServletCallableStatement cs = new ServletCallableStatement(stored, request);
				cs.setProcedure("Mlm_Api.Send_Admin");
				cs.setAllParameters("request");
				cs.execute();
			}
			%><script>alert("<%=lang.get(si_success)%>")</script><%
		} catch(Exception ex) {
			//Util.alertUserMessage(ex, out);
			Util.showUserMessage(stored, ex, out);
		}
	}
%><script>var data = <%=stored.execFunction("Mlm_Api.Last_Errors_Of_User")%></script><%
%><t:form title="<%=si_formTitle%>" minHeight="fill" minWidth="fill" >
<iframe name=frm style="display:none"></iframe>
<script>
function changeLangIndex(index) {
	for(var i = 0; i < 4; i++) {
		if(index == i) {
			getDOM(fm.user_msg, i).style.display = "";
		} else {
			getDOM(fm.user_msg, i).style.display = "none";
		}
	}
}
function changeState(index) {
	if(index == "") return;
	var action;
	switch(index) {
		case "2":
			action = "send_fido"; break;
		case "3":
			action = "resolved"; break;
		case "4":
			action = "send_admin"; break;
		default:
			fm.action_id.focus(); return;
	}
	go({param:{protocol_ids:fm.protocol_id.getValue(), action:action}});
}
function goUrl() {
	top._t().showUserMessage("fill","fill","mlm/header/mistake.jsp?action=Y&protocol_id=132424812"/*+fm.protocol_id.getValue()*/);
}
function closePage() {
	if(/[?&]modal/.test(_.URL)) {
		top.close();
	} else {
		top._t().hideUserMessage();
	}
}
function onLoad() {
	changeLangIndex(<%=index%>);
	setDOMValue(fm.language, <%=index%>);
}
</script>
<div id="basepanel" class="panel">
<form name="fm" target="frm">
<input type="hidden" name="protocol_id">
<table class="formToolbar" align="center" >
<col width="33%" ><col width="33%" align="center"><col width="33%" align="right">
<tr>
	<td><select name="action_id" onchange="changeState(this.value)">
			<option value="" style="color:red;">--* <%=lang.get(si_action)%> *--
			<t:options from="mlm_actions_v" code="action_id" name="action_name" where="action_id in (2,3,4)" />
		</select>
	<td><%=lang.get(si_language)%> :
		<select name="language" onchange="changeLangIndex(this.value);">
			<option value="0">Русский
			<option value="1">Ўзбекча кирилл
			<option value="2">O'zbekcha lotin
			<option value="3">English
		</select>
	<td><input type="button" onclick="closePage();" value="<%=lang.get(si_exit)%>">
</table>
<fieldset><legend><%= lang.get(si_mistext) %></legend>
	<textarea name="user_msg" style="width:100%" rows=5 tabindex=-1 readonly ></textarea>
	<textarea name="user_msg" style="width:100%" rows=5 tabindex=-1 readonly ></textarea>
	<textarea name="user_msg" style="width:100%" rows=5 tabindex=-1 readonly ></textarea>
	<textarea name="user_msg" style="width:100%" rows=5 tabindex=-1 readonly ></textarea>
</fieldset>
</form><br>
<input type="button" onclick="goUrl()" value="<%=lang.get(si_info)%>">
</div>
</t:form>
</t:page>
<%!
	static final int si_formTitle			= SI("Работа с ошибками","Xатоликлар билан ишлаш","Xatoliklar bilan ishlash");
	static final int si_action				= SI("Выберите действия","Харакатни танланг","Harakatni tanlang","Select the action");
	static final int si_language			= SI("Язык","Тил","Til","");
	static final int si_exit					= SI("Закрыть","Чи&#1179;иш","Chiqish","Exit");
	static final int si_mistext				= SI("Текст ошибки","","");
	static final int si_info					= SI("Подробно","Батафсил","Batafsil","Detail");
	static final int si_success				= SI("Успешно выполнено!","Мувоффа&#1179;иятли бажарилди!","Muvoffaqiyatli bajarildi!","Successfully executed!");
	//----------------------------------------------------------------
%><%@ include file="/language.jsp" %>