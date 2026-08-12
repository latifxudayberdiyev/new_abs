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
String notify_id = request.getParameter("notify_id");
if(notify_id != null) {
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setFunction("User_Calendar_Api.Calendar_Notify_Model");
		cs.setAllParameters("request");
		cs.execute();
		%><script>var data=<%=cs.getStringResult()%></script><%
	} catch(Exception ex) {
		response.setHeader("RT", "alert");
		%><script>alert('<%= Util.quotesEsc(ex.getMessage()) %>');</script><%
	}
}	
%><t:form title="<%=(notify_id!=null)?si_editTitle:si_addTitle%>" minWidth="fill" minHeight="fill"  >
<script>
function onLoad(){

}
</script>
<div id="basepanel" class="panel" >
<iframe name="frm" style="display:none;"></iframe>
<form name="fm" method="post" target="frm" >
<input type="hidden" name="request" value="save">
<input type="hidden" name="notify_id" >
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
	<col width="25%">
	<tr>
		<td><%=lang.get(si_type_id)%> <q></q>:
		<td><select name="calendar_type_id" style="width:95%" r=1>
				<t:options from="user_calendar_types_v" code="calendar_type_id" name="name" where="state = 'A'" />
			</select>
		<td><%=lang.get(si_notify_date)%> <q></q>:
		<td><input name="notify_date" mask="date" value="<%=stored.execFunction("Setup.Get_Operday")%>" size="10" r=1>
		
	<tr>
		<td><%=lang.get(si_label)%> (Русский) <q></q>:
		<td colspan="3"><input name="label" mask="255|" style="width:95%" r=1 >
	<tr><td>(Ўзбекча кирилл) :<td colspan="3"><input name="label" mask="255|" style="width:95%" >
	<tr><td>(O'zbekcha lotin) :<td colspan="3"><input name="label" mask="255|" style="width:95%" >
	<tr><td>(English) :<td colspan="3"><input name="label" mask="255|" style="width:95%" >
	<tr>
		<td><%=lang.get(si_description)%> :
		<td colspan="3"><textarea name="description" mask="2000|" rows="10" style="width:95%" ></textarea>
</table>
</t:form></t:page>
<t:request name="save"><%
	try{
		ServletCallableStatement cs = new ServletCallableStatement(stored,request);
		cs.setProcedure("User_Calendar_Api.Save_Calendar_Notify");
		cs.setAllParameters("request");
		cs.execute();
		%><script>alert('<%=lang.get(si_success)%>');window.returnValue=true;top.close();</script><%
	/*} catch (SQLException err){
		%><%=util.alert(util.getMessage(err.toString()))%><%
		%><script>parent.pageLock(false);</script><%
	}*/
	} catch(Exception ex) {
		response.setHeader("RT", "alert");
		Util.alertUserMessage(ex, out);
		%><script>parent.pageLock(false);</script><%
	}
%></t:request>
<%!
	static final int si_addTitle		= SI("Добавление","&#1179;ўшиш","Qo'shish","Adding");
	static final int si_editTitle		= SI("Изменение","Ўзгартириш","O'zgartirish","Editing");
	static final int si_save				= SI("Сохранить","Са&#1179;лаш","Saqlash","Save");
	static final int si_exit				= SI("Закрыть","Чи&#1179;иш","Chiqish","Exit");
	static final int si_notify_id		= SI("ID","","","");
	static final int si_type_id			= SI("Тип календаря","","","");
	static final int si_notify_date	= SI("Дата","Сана","Sana","Date");
	static final int si_label				= SI("Наименование","Номланиши","Nomlanishi","Name");
	static final int si_description	= SI("Описание","Тавсиф","Tavsif","");
	static final int si_success			= SI("Успешно выполнено!","Мувоффа&#1179;иятли бажарилди!","Muvoffaqiyatli bajarildi!","Successfully executed!");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>