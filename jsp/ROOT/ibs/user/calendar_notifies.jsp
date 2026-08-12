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
//-------------------------------------------------------------------------------------------------
%><t:page><%
String action = request.getParameter("action");
if("del".equals(action)) {
	try {
		ServletCallableStatement cs = new ServletCallableStatement(stored, request);
		cs.setProcedure("User_Calendar_Api.Delete_Calendar_Notify");
		cs.setAllParameters("request");
		cs.execute();
		%><script>alert("<%=lang.get(si_success)%>")</script><%
	} catch(Exception ex) {
		Util.alertUserMessage(ex, out);
	}
}
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
<script>
function add() {
	if(go({url:"calendar_notify.jsp", target:"modalE", dialogHeight:400, dialogWidth:1000, lock:false})) go({});
}
function edit() {
	if(getDOM("bEdit").disabled == false) {
		if(go({url:"calendar_notify.jsp", param:{notify_id:getData(1)}, target:"modalE", dialogHeight:400, dialogWidth:1000, lock:false})) go({});
	}
}
function onAction() {
	edit();
}
function del() {
	if(confirm("<%=lang.get(si_ask)%>"))
		go({url:"calendar_notifies.jsp?notify_id="+getData(1), param:{action:"del"}});
}
function onLoad() {
	if(!dataExist()) {
		getDOM("bEdit").disabled = true;
		getDOM("bDel").disabled = true;
	}
}
</script>
<table class="formToolbar" align="center" >
	<tr>
		<td>
			<input type="button" name="bAdd" onclick="add()" value="<%=lang.get(si_add)%>" >
			<input type="button" name="bEdit" onclick="edit()" value="<%=lang.get(si_edit)%>" >
			<input type="button" name="bDel" onclick="del()" value="<%=lang.get(si_del)%>" >
		<td id="tableControls" align="right" >
	<tr class="filterControls"><td colspan=4 align="center"><b><%=lang.get(si_search)%></b><span id="filterControls"></span>
</table>
<t:table from="user_calendar_notifies_v" >
	<t:field id="1" name="notify_id" label="<%=si_notify_id%>" >
		<t:filter operator="_like_" size="10" mask="10|0-9" />
	</t:field>
	<t:field id="2" name="calendar_type_id" label="<%=si_type_id%>" >
		<t:filter optionSQL="select '<option value=' || calendar_type_id ||'>' || name from user_calendar_types_v where state = 'A'" showInGrid="" />
	</t:field>
	<t:field id="3" name="calendar_type_name" label="<%=si_type_id%>" type="quote" />
	<t:field id="4" name="notify_date" label="<%=si_notify_date%>" type="date" >
		<t:filter operator="range" mask="date" size="9" />
	</t:field>
	<t:field id="5" name="label" label="<%=si_label%>" type="quote" />
	<t:field id="6" name="modified_on" label="<%=si_modified_on%>" type="date" >
		<t:filter operator="range" mask="date" size="9" />
	</t:field>
	<t:field id="7" name="modified_by" label="<%=si_modified_by%>" >
		<t:filter mask="9|0-9" size="9" referenceName="user_name" referenceURL="/ibs/core/util/references.jsp" requestName="user_name" requestURL="/ibs/core/util/references.jsp"/>
	</t:field>
	<t:field id="8" name="modified_by_name" label="<%=si_modified_by%>" type="quote" />
	<t:field id="9" name="created_on" label="<%=si_created_on%>" type="date" >
		<t:filter operator="range" mask="date" size="9" />
	</t:field>
	<t:field id="10" name="created_by" label="<%=si_created_by%>" >
		<t:filter mask="9|0-9" size="9" referenceName="user_name" referenceURL="/ibs/core/util/references.jsp" requestName="user_name" requestURL="/ibs/core/util/references.jsp"/>
	</t:field>
	<t:field id="11" name="created_by_name" label="<%=si_created_by%>" type="quote" />
	<t:field id="12" name="description" label="<%=si_description%>" type="quote" >
		<t:filter operator="_search_" />
	</t:field>
	<t:grid page="" withoutCursor="" numbering="">
		<t:column for="1" />
		<t:column for="3" />
		<t:column for="4" />
		<t:column for="5" align="left" />		
		<t:foot>
			<t:row>
				<t:cell for="12" size="100%" colspan="3" align="left"/>
			</t:row>
			<t:row>
				<t:cell for="9"	size="50%"/>
				<t:cell for="11" align="left" size="100%"/>
			</t:row>
			<t:row>
				<t:cell for="6" size="50%"/>
				<t:cell for="8" align="left" size="100%"/>
			</t:row>
		</t:foot>
	</t:grid>
</t:table>
</t:form>
</t:page>
<%!
	static final int si_title				= SI("Календарь уведомлений","","","");
	static final int si_add					= SI("Добавить","&#1178;ўшиш","Qo'shish","Add");
	static final int si_edit				= SI("Изменить","Ўзгартириш","O'zgartirish","Edit");
	static final int si_del					= SI("Удалить","Ўчириш","O'chirish","Delete");
	static final int si_ask					= SI("Вы действительно хотите удалить эту запись?","Сиз ха&#1179;и&#1179;атдан хам шу ёзувни ўчирмокчимисиз?","Siz haqiqatdan ham shu yozuvni o'chirmoqchimisiz?","Do you really want to delete this record?");
	static final int si_success			= SI("Успешно выполнено!","Мувоффа&#1179;иятли бажарилди!","Muvoffaqiyatli bajarildi!","Successfully executed!");
	static final int si_search			= SI("Поиск : ","&#1178;идирув : ","Qidiruv : ","Search : ");
	static final int si_notify_id		= SI("ID","","","");
	static final int si_type_id			= SI("Тип календаря","","","");
	static final int si_notify_date	= SI("Дата","Сана","Sana","Date");
	static final int si_label				= SI("Наименование","Номланиши","Nomlanishi","Name");
	static final int si_created_by	= SI("Кто создал","Ким яратган","Kim yaratgan","");
	static final int si_created_on	= SI("Дата создания","Яратган ва&#1179;ти","Yaratgan vaqti","");
	static final int si_modified_by	= SI("Кто изменил","Ким ўзгартирган","Kim o`zgartirgan","");
	static final int si_modified_on	= SI("Дата изменения","Ўзгартириш ва&#1179;ти","O`zgartirish vaqti","");
	static final int si_description	= SI("Описание","Тавсиф","Tavsif","");

//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>