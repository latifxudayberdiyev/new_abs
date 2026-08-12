<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------

%><t:page><%
String id300 = stored.encryptValue("300", "REP_ID");
String id301 = stored.encryptValue("301", "REP_ID");
String id302 = stored.encryptValue("302", "REP_ID");
String id303 = stored.encryptValue("303", "REP_ID");
%><t:form title="<%=si_formTitle%>" minHeight="fill" minWidth="fill" noCache="">
<script>
function edit() {
	if(go({url:'dvs_user_form.jsp',param:{empCode:encodeURI(getData(101))},target:'modalE'}))
		go({});
}
function history() {
	if(go({url:'dvs_key_history.jsp?user_id='+encodeURIComponent(getData(101)),target:'modalE'}))
		go({});
}
function settings() {
	go({url:'dvs_settings.jsp',target:'modalE'});
}

function checkState(val) {
	if(val >9 && val < 20 ){
		showDOM(fm.mime);
	}else{
		hideDOM(fm.mime);
	}	
}

function print_form(val) {
	var to = "", id = "";
	
	if(val == "") {
		return false;
	}else if(val == "20"){
		go({url:'../core/adm/log/user_posts.jsp?user_id='+encodeURIComponent(getData(101)), target:"modalE", dialogHeight:600, dialogWidth:1000, cmsHelperTiltle:"<%=lang.get(si_name)%>: "+getData(4), lock:false});
		return;
	}else if(val == "21"){
		go({url:'../core/adm/log/user_roles.jsp?user_id='+encodeURIComponent(getData(101)), target:"modalE", dialogHeight:600, dialogWidth:1000, cmsHelperTiltle:"<%=lang.get(si_name)%>: "+getData(4), lock:false});
		return;
	} 
	/*else if(val == "22"){
		to = "log/user_reports.jsp?role_id="+getData(18);
		return;
	} */
	else if(val == "23"){
		go({url:'../core/adm/log/user_access.jsp?user_id='+encodeURIComponent(getData(101)), target:"modalE", dialogHeight:600, dialogWidth:1000, cmsHelperTiltle:"<%=lang.get(si_name)%>: "+getData(4), lock:false});
		return;
	}else if(val == "24"){
		go({url:'../core/adm/log/user_groups.jsp?user_id='+encodeURIComponent(getData(101)), target:"modalE", dialogHeight:600, dialogWidth:1000, cmsHelperTiltle:"<%=lang.get(si_name)%>: "+getData(4), lock:false});
		return;
	}else if(val == "25"){
		go({url:'../core/adm/log/user_logs.jsp?user_id='+encodeURIComponent(getData(101)), target:"modalE", dialogHeight:600, dialogWidth:1000, cmsHelperTiltle:"<%=lang.get(si_name)%>: "+getData(4), lock:false});
		return;
	}else if(val == "26"){
		go({url:'../core/adm/log/user_history.jsp?user_id='+encodeURIComponent(getData(101)), target:"modalE", dialogHeight:600, dialogWidth:1000, cmsHelperTiltle:"<%=lang.get(si_name)%>: "+getData(4), lock:false});
		return;
	}else if(val == "1") {
		history(); return;
	} else if(val == "10"){
		to = "accessed/user_posts";
		id = "<%=id300%>"; // id = "300";
	} else if(val == "11") {
		to = "accessed/user_roles";
		id = "<%=id301%>"; // id = "301";
	} else if(val == "12") {
		to = "accessed/user_reports";
		id = "<%=id302%>"; // id = "302";
	} else if(val=="13") {
		to = "accessed/user_access_levels";
		id = "<%=id303%>"; // id = "303";
	}
	setDOMValue(fm.REP_ID, id);
	if(getDOMValue(fm.mime) == ""){
		go({url:"../core/adm/"+to+".jsp?user_id="+encodeURIComponent(getData(101)), target:"modalE", dialogHeight:600, dialogWidth:1200, cmsHelperTiltle:"<%=lang.get(si_name)%>: "+getData(4), lock:false});
	}
	if(getDOMValue(fm.mime) != ""){
		go({url:"../core/util/print_report.jsp", param:{user_id:encodeURI(getData(101)), REP_ID:fm.REP_ID.getValue(), mime:fm.mime.getValue()}, target:"_blank", lock:false});
	}
}

function onAction() {
	<% if (user.getHeaderCode().equals("09003")){%>
		<% if(user.isHeaderBank()){%>
			edit();
		<%}} else{%>
		edit();
	<%}%>
}
function onLoad() {
	if(!dataExist()) {
		getDOM("bEdit").disabled = true;
		getDOM("bAction").disabled = true;
		getDOM("actions").disabled	= true;
		getDOM("mime").disabled = true;
	} else checkState("");
}
</script>
<table class=formToolbar cellspacing=6>
<tr><td>
		<% if(user.getHeaderCode().equals("09003")){ %>
			<% if(user.isHeaderBank()){%>
				<input type="button" name="bEdit" onClick="edit()" value="<%=lang.get(si_edit)%>" >
				<input type="button" onClick="settings()" value="<%=lang.get(si_settings)%>" >
		<%}} else{%>
				<input type="button" name="bEdit" onClick="edit()" value="<%=lang.get(si_edit)%>" >
				<input type="button" onClick="settings()" value="<%=lang.get(si_settings)%>" >
		<%}%>
		<td><%=lang.get(si_action)%> :
			<select name="actions" onchange="checkState(this.value);" >
				<option value="" style="color:red">--<%=lang.get(si_select_oper)%>--</option>
					<option value="1"><%=lang.get(si_history)%>
				<optgroup label="<%=lang.get(si_accesses)%>">
					<option value="10"><%=lang.get(si_access_posts)%>
					<option value="11"><%=lang.get(si_access_roles)%>
					<option value="12"><%=lang.get(si_access_reports)%>
					<option value="13"><%=lang.get(si_access_access)%>
				</optgroup>
				<optgroup label=<%=lang.get(si_protocols)%> >
					<option value="20"><%=lang.get(si_post_log)%>
					<option value="21"><%=lang.get(si_post_role)%>
					<!--<option value="22"><%=lang.get(si_post_report)%>-->
					<option value="23"><%=lang.get(si_post_access)%>
					<option value="24"><%=lang.get(si_post_groups)%>
					<option value="25"><%=lang.get(si_user_log)%>
					<option value="26"><%=lang.get(si_user_his)%>
				</optgroup>
			</select>
			<form name="fm" style="display:inline;margin-top:-25px;">
				<select name="mime" >
					<option><%=lang.get(si_form)%>
					<option value="HTML">HTML<option value="EXCEL">EXCEL
				</select><input type="hidden" name="REP_ID" value="300">
			</form>
			<input type="button" name="bAction" onclick="print_form(getDOM('actions').value);" value="<%=lang.get(si_run)%>" >
	<td align=right id=tableControls>
<%--	<tr class="filterControls"><td colspan=3 align="center"><b><%=lang.get(si_search)%></b><span id="filterControls"></span>--%>
</table>
<t:table from="asa_users_v">
		<t:field id="101" name="code" label="<%=si_code%>" encrypted="Y" entityName="CORE_USERS" />
		<t:field id="1" name="code" label="<%=si_code%>" >
			<t:filter mask="10|0-9" size="9" />
		</t:field>
		<t:field id="2" name="filial_code" label="<%=si_filial_code%>">
			<t:filter mask="5|0-9" size="9" />
		</t:field>
		<t:field id="3" name="branch_id" label="<%=si_branch%>" type="quote">
			<t:filter operator="_search_" size="30" />
		</t:field>
		<t:field id="4" name="local_code" label="<%=si_local_code%>">
			<t:filter operator="_search_" size="30" />
		</t:field>
		<t:field id="6" name="name" type="quote" label="<%=si_name%>">
			<t:filter operator="_search_" size="30" />
		</t:field>
		<t:field id="7" name="condition" label="<%=si_condition%>">
			<t:filter option="<%= si_condition_option %>" value="A" />
		</t:field>
		<t:field id="8" name="condition_name" label="<%=si_condition%>"/>		
		<t:field id="9" name="dvs_user_ids" label="<%=si_dvs_user%>"/>
		<t:field id="10" name="rank_code" label="<%=si_rank_name%>">
			<t:filter optionSQL="select '<option value=' || post_id ||'>' || name from core_posts_v" />
		</t:field>
		<t:field id="11" name="modified_on" label="<%=si_modified_on%>" type="datetime" />
		<t:field id="12" name="login" type="quote" label="<%=si_login%>">
			<t:filter operator="_search_" size="30"/>
		</t:field>
		<t:field id="13" name="modified_last_on" label="<%=si_modified_last_on%>" type="datetime" />	
		<t:field id="14" name="rank_name" label="<%=si_rank_name%>" />
		<t:field id="15" name="user_type_name" label="<%=si_user_type%>" type="quote" />
		<t:field id="16" name="User_Type_Id" label="<%=si_user_type%>">
			<t:filter optionSQL="select '<option value=' || t.user_type_id || '>' || t.label from core_r_user_types_v t where user_type_id in (1,4,5,8)" />
		</t:field>
		<t:field id="17" name="Conditin_State" label="<%=si_rank_level%>" />
		
		<t:grid page="" withoutCursor="" numbering="" rowColor="(d(7)=='P')?'#FFA500':(d(7)=='S')?'red':'black'">
			<t:column for="2" />
			<t:column for="3" />
			<t:column for="4" />
			<t:column for="1" />
			<t:column for="6" align="left" />
			<t:column for="12" align="left" />
			<t:column for="14" align="left" />
			<t:column for="17" />
			<t:column for="8" />
			<t:column for="9" />
			<t:foot>
			    <t:row>
                    <t:cell for="11" size="50%"/>
                    <t:cell for="13"  size="50%"/>
                </t:row>
            </t:foot>
		</t:grid>
</t:table>
</t:form>
</t:page>
<%!
static final int si_formTitle        = SI("Закрепление DVS-ключей за пользователями","DVS-калитларини фойдаланувчиларга бириктириш","DVS-kalitlarini foydalanuvchilarga biriktirish","Assigning DVS keys to users");
static final int si_edit             = SI("Изменить","Ўзгартириш","O`zgartirish","Edit");
static final int si_history          = SI("История","Тарих","Tarix","History");
static final int si_settings         = SI("Настройки","Созлашлар","Sozlashlar","Settings");
static final int si_action           = SI("Операция","Операция","Operatsiya","Operation");
static final int si_select_oper      = SI("Выберите операцию","Операцияни танланг","Operatsiyani tanlang","Select the operation");
static final int si_accesses         = SI("Разрешённые","Рухсат берилган","Ruxsat berilgan","Allowed");
static final int si_access_roles     = SI("Разрешённые роли","Рухсат берилган роллар","Ruxsat berilgan rollar","Allowed Roles");
static final int si_access_reports   = SI("Разрешённые отчеты","Рухсат берилган &#1203;исоботлар","Ruxsat berilgan hisobotlar","Allowed reports");
static final int si_access_access    = SI("Разрешённый уровень доступа","Рухсат этилган ваколатлар","Ruxsat etilgan vakolatlar","Permitted access level");
static final int si_form             = SI("В форме","Формада","Formada","In the shape of");
static final int si_run              = SI("Выполнить","Бажариш","Bajarish","Run");
static final int si_search           = SI("Поиск :","&#1178;идирув :","Qidiruv :","Search :");
static final int si_filial_code      = SI("Филиал","Филиал","Filial","Branch");
static final int si_code             = SI("Код сотрудника","Ходим коди","Xodim kodi","Employee code");
static final int si_local_code       = SI("Локальный код","Локал код","Lokal kod","Local code");
static final int si_name             = SI("Наименование","Номи","Nomi","Name");
static final int si_login            = SI("Логин","Логин","Login","Login");
static final int si_rank_name        = SI("Должность","Лавозим","Lavozim","Position");
static final int si_rank_level       = SI("Текущий статус сотрудника","Ходимнинг &#1203;озирги &#1203;олати","Xodimning hozirgi holati","The employee's current situation");
static final int si_dvs_user         = SI("DVS коды","DVS кодлари","DVS kodlari","DVS codes");
static final int si_modified_on      = SI("Дата изменения","&#1038;згартириш ва&#1179;ти","O`zgartirish vaqti","Date of change");
static final int si_modified_last_on = SI("Дата последнего изменения","Охирги &#1118;згартирилган сана","Oxirgi o'zgartirilgan sana","Last modified date");
static final int si_condition        = SI("Состояние","&#1202;олат","Holat","State");
static final int si_condition_option = SI("<option value=A>Активен<option value=P>Деактивизирован<option value=C>Уволен","<option value=A>Актив<option value=P>Ноактив<option value=C>Бўшатилган","<option value=A>Aktiv<option value=P>Noaktiv<option value=C>Bo`shatilgan","<option value=A>Active<option value=P>Deactivated<option value=C>Dismissed");
static final int si_access_posts     = SI("Разрешённые должности","Рухсат этилган лавозимлар","Ruxsat etilgan lavozimlar","","","");
static final int si_protocols        = SI("Протоколы","Баённомалар","Bayonnomalar","Protocols");
static final int si_post_log         = SI("Протокол должностей","Лавозимлар баённомаси","Lavozimlar bayonnomasi","Post protocol");
static final int si_post_role        = SI("Протокол ролей","Роллар баённомаси","Rollar bayonnomasi","Role protocol");
static final int si_post_report      = SI("Протокол отчетов","&#1202;исоботлар баённомаси","Hisobotlar bayonnomasi","Reporting protocol");
static final int si_post_access      = SI("Протокол уровня доступа","Ваколат даражаси баённомаси","Vakolat darajasi bayonnomasi","Access layer protocol");
static final int si_post_groups      = SI("Протокол группы","Гуру&#1203; протоколи","Guruh protokoli","Group protocol");
static final int si_user_log         = SI("Протокол пользователя","Фойдаланувчи баённомаси","Foydalanuvchi bayonnomasi","User protocol");
static final int si_user_his         = SI("История пользователя","Фойдаланувчи тарихи","Foydalanuvchi tarixi","User history");
static final int si_access_menu      = SI("Разрешённые формы","Рухсат этилган шакллар","Ruxsat etilgan shakllar","Permitted forms");
static final int si_branch           = SI("Подразделение", "БХМ", "BXM", "Subdivision");
static final int si_user_type        = SI("Типа пользователя", "Фойдаланувчи тури", "Foydalanuvchi turi", "Type user");

//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
