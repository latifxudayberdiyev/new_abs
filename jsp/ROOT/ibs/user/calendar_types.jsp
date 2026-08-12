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
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
<script>
function add() {
	if(go({url:"calendar_type.jsp", target:"modalE", dialogHeight:300, dialogWidth:800, lock:false})) go({});
}
function edit() {
	if(getDOM("bEdit").disabled == false) {
		if(go({url:"calendar_type.jsp", param:{calendar_type_id:getData(1)}, target:"modalE", dialogHeight:300, dialogWidth:800, lock:false})) go({});
	}
}
<%if(user.isHeaderBank()) { %>
function onAction() {
	edit();
}
<% } %>
function onLoad() {
	if(!dataExist()) {
		getDOM("bEdit").disabled = true;
	}
}
</script>
<table class="formToolbar" align="center" >
	<tr>
		<td><%if(user.isHeaderBank()) { %>
			<input type="button" name="bAdd" onclick="add()" value="<%=lang.get(si_add)%>" >
			<input type="button" name="bEdit" onclick="edit()" value="<%=lang.get(si_edit)%>" >
		<% } %>
		<td id="tableControls" align="right" >
	<tr class="filterControls"><td colspan=4 align="center"><b><%=lang.get(si_search)%></b><span id="filterControls"></span>
</table>
<t:table from="user_calendar_types_v" >
	<t:field id="1" name="calendar_type_id" label="<%=si_id%>" >
		<t:filter operator="_like_" mask="2|0-9" size="3" showInGrid=""/>
	</t:field>
	<t:field id="2" name="name" label="<%=si_name%>" type="quote">
		<t:filter operator="_search_" showInGrid=""/>
	</t:field>
	<t:field id="3" name="day_before" label="<%=si_day_before%>" >
		<t:filter mask="3|0-9" />
	</t:field>
	<t:field id="4" name="day_after" label="<%=si_day_after%>" >
		<t:filter mask="3|0-9" />
	</t:field>
	<t:field id="5" name="state" label="<%=si_state%>" >
		<t:filter option="<%=si_state_option%>" showInGrid=""/>
	</t:field>
	<t:field id="6" name="state_name" label="<%=si_state%>" type="quote"/>
	<t:field id="7" name="modified_on" label="<%=si_modified_on%>" type="date">
		<t:filter operator="range" mask="date" size="9" />
	</t:field>
	<t:field id="8" name="modified_by" label="<%=si_modified_by%>" >
		<t:filter mask="9|0-9" size="9" referenceName="user_name" referenceURL="/ibs/core/util/references.jsp" requestName="user_name" requestURL="/ibs/core/util/references.jsp"/>
	</t:field>
	<t:field id="9" name="modified_by_name" label="<%=si_modified_by%>" type="quote"/>
	<t:field id="10" name="created_on" label="<%=si_created_on%>" type="date">
		<t:filter operator="range" mask="date" size="9" />
	</t:field>
	<t:field id="11" name="created_by" label="<%=si_created_by%>" >
		<t:filter mask="9|0-9" size="9" referenceName="user_name" referenceURL="/ibs/core/util/references.jsp" requestName="user_name" requestURL="/ibs/core/util/references.jsp"/>
	</t:field>
	<t:field id="12" name="created_by_name" label="<%=si_created_by%>" type="quote"/>
	<t:field id="13" name="description" label="<%=si_description%>" type="quote">
		<t:filter operator="_search_" mask="200|" />
	</t:field>
	<t:grid page="" withoutCursor="" numbering="" rowColor="(d(5)=='P')?'#AAAAAA':''">
		<t:column for="1" />
		<t:column for="2" />
		<t:column for="3" />
		<t:column for="4" />
		<t:column for="6" />
		<t:foot>
			<t:row>
				<t:cell for="13" size="100%" colspan="3" align="left"/>
			</t:row>
			<t:row>
				<t:cell for="10" size="50%"/>
				<t:cell for="12" align="left" size="100%"/>
			</t:row>
			<t:row>
				<t:cell for="7" size="50%"/>
				<t:cell for="9" align="left" size="100%"/>
			</t:row>
		</t:foot>
	</t:grid>
</t:table>
</t:form>
</t:page>
<%!
	static final int si_title					= SI("Тип календаря","","","");
	static final int si_add						= SI("Добавить","&#1178;ўшиш","Qo'shish","Add");
	static final int si_edit					= SI("Изменить","Ўзгартириш","O'zgartirish","Edit");
	static final int si_del						= SI("Удалить","Ўчириш","O'chirish","Delete");
	static final int si_ask						= SI("Вы действительно хотите удалить эту запись?","Сиз ха&#1179;и&#1179;атдан хам шу ёзувни ўчирмокчимисиз?","Siz haqiqatdan ham shu yozuvni o'chirmoqchimisiz?","Do you really want to delete this record?");
	static final int si_success				= SI("Успешно выполнено!","Мувоффа&#1179;иятли бажарилди!","Muvoffaqiyatli bajarildi!","Successfully executed!");
	static final int si_search				= SI("Поиск : ","&#1178;идирув : ","Qidiruv : ","Search : ");
	static final int si_id						= SI("ID","","","");
	static final int si_name					= SI("Наименование","Номланиши","Nomlanishi","Name");
	static final int si_day_before		= SI("Предыдущие дни","","","");
	static final int si_day_after			= SI("Последующие дни ","","","");
	static final int si_state_option	= SI("<option value='A'>Актив<option value='P'>Пассив","<option value='A'>Фаолиятли<option value='P'>Фаолиятсиз","<option value='A'>Faoliyatli<option value='P'>Faoliyatsiz","<option value='A'>Active<option value='P'>Passive");
	static final int si_state					= SI("Состояние","&#1202;олат","Holat","State");
	static final int si_created_by		= SI("Кто создал","Ким яратган","Kim yaratgan","");
	static final int si_created_on		= SI("Дата создания","Яратган ва&#1179;ти","Yaratgan vaqti","");
	static final int si_modified_by		= SI("Кто изменил","Ким ўзгартирган","Kim o`zgartirgan","");
	static final int si_modified_on		= SI("Дата изменения","Ўзгартириш ва&#1179;ти","O`zgartirish vaqti","");
	static final int si_description		= SI("Описание","Тавсиф","Tavsif","");

//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>