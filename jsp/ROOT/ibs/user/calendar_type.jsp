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
String calendar_type_id = request.getParameter("calendar_type_id");
if(calendar_type_id != null) {
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setFunction("User_Calendar_Api.Calendar_Type_Model");
		cs.setAllParameters("request");
		cs.execute();
		%><script>var data=<%=cs.getStringResult()%></script><%
	} catch(Exception ex) {
		response.setHeader("RT", "alert");
		%><script>alert('<%= Util.quotesEsc(ex.getMessage()) %>');</script><%
	}
}	
%><t:form title="<%=(calendar_type_id!=null)?si_editTitle:si_addTitle%>" minWidth="fill" minHeight="fill"  >
<script>
function onLoad(){

}
</script>
<div id="basepanel" class="panel" >
<iframe name="frm" style="display:none;"></iframe>
<form name="fm" method="post" target="frm" >
<input type="hidden" name="request" value="save">
<input type="hidden" name="calendar_type_id" >
<table class="formToolbar" align="center" >
	<tr>
		<td>
			<input type="submit" value="<%=lang.get(si_save)%>">
		<td align="right">
			<input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close();">
</table>
<table align="center" border=0>
	<col width="25%" align="right">
	<col width="25%">
	<col width="25%" align="right">
	<col width="75%">
	<tr>
		<td><%=lang.get(si_name)%> (Русский) <q></q>:
		<td colspan="3"><input name="calendar_type_name" mask="100|" style="width:95%" r=1 >
	<tr><td>(Ўзбекча кирилл) :<td colspan="3"><input name="calendar_type_name" mask="100|" style="width:95%" >
	<tr><td>(O'zbekcha lotin) :<td colspan="3"><input name="calendar_type_name" mask="100|" style="width:95%" >
	<tr><td>(English) :<td colspan="3"><input name="calendar_type_name" mask="100|" style="width:95%" >
	<tr>
		<td><%=lang.get(si_day_before)%> <q></q>:
		<td><input name="day_before" mask="3|0-9" size="4" r=1>
		<td><%=lang.get(si_day_after)%> <q></q>:
		<td><input name="day_after" mask="3|0-9" size="4" r=1>
	<tr>
		<td><%=lang.get(si_state)%> <q></q>:
		<td colspan="3"><select name="state" r=1><%=lang.get(si_state_option)%></select>
	<tr>
		<td><%=lang.get(si_description)%> :
		<td colspan="3"><textarea name="description" mask="200|" rows="2" style="width:95%" ></textarea>
</table>
</t:form></t:page>
<t:request name="save"><%
	try{
		ServletCallableStatement cs = new ServletCallableStatement(stored,request);
		cs.setProcedure("User_Calendar_Api.Save_Calendar_Type");
		cs.setAllParameters("request");
		cs.execute();
		%><script>alert('<%=lang.get(si_success)%>');window.returnValue=true;top.close();</script><%
	} catch(Exception ex) {
		response.setHeader("RT", "alert");
		Util.alertUserMessage(ex, out);
		%><script>parent.pageLock(false);</script><%
	}
%></t:request>
<%!
	static final int si_addTitle			= SI("Добавление","&#1179;ўшиш","Qo'shish","Adding");
	static final int si_editTitle			= SI("Изменение","Ўзгартириш","O'zgartirish","Editing");
	static final int si_save					= SI("Сохранить","Са&#1179;лаш","Saqlash","Save");
	static final int si_exit					= SI("Закрыть","Чи&#1179;иш","Chiqish","Exit");
	static final int si_name					= SI("Наименование","Номланиши","Nomlanishi","Name");
	static final int si_day_before		= SI("Предыдущие дни","","","");
	static final int si_day_after			= SI("Последующие дни ","","","");
	static final int si_state_option	= SI("<option value='A'>Актив<option value='P'>Пассив","<option value='A'>Фаолиятли<option value='P'>Фаолиятсиз","<option value='A'>Faoliyatli<option value='P'>Faoliyatsiz","<option value='A'>Active<option value='P'>Passive");
	static final int si_state					= SI("Состояние","&#1202;олат","Holat","State");
	static final int si_description		= SI("Описание","Тавсиф","Tavsif","");
	static final int si_success				= SI("Успешно выполнено!","Мувоффа&#1179;иятли бажарилди!","Muvoffaqiyatli bajarildi!","Successfully executed!");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>