<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<script>
		function responseModal(r) {
			if (r) {
				go({});
			}
		}

		function add() {
			go({
				url: "print_setting.jsp",
				target: "modalE",
				dialogHeight: 800,
				dialogWidth: 700,
				lock: false,
				callback: responseModal
			});
		}

		function edit() {
			if (!getDOM("bEdit").disabled) {
				go({
					url: "print_setting.jsp",
					param: {
						setting_id: getData(1)
					},
					target: "modalE",
					dialogHeight: 640,
					dialogWidth: 640,
					lock: false,
					callback: responseModal
				});
			}
		}

		function testFill() {
			go({
				url: "print_template_fill_test.jsp",
				target: "modalE",
				dialogHeight: 600,
				dialogWidth: 700,
				lock: false
			});
		}

		function history() {
			if (!getDOM("bHistory").disabled) {
				go({
					url: "print_setting_history.jsp",
					param: {
						setting_id: getData(1)
					},
					target: "modalE",
					dialogHeight: 640,
					dialogWidth: 900,
					lock: false
				});
			}
		}

		function onAction() {
			edit();
		}

		function onLoad() {
			if (!dataExist()) {
				getDOM("bEdit").setDisable(true);
				getDOM("bHistory").setDisable(true);
			}
		}
	</script>
	<table class="formToolbar" align="center">
		<tr>
			<td>
				<input type="button" name="bAdd" onclick="add();" value="<%=lang.get(si_add)%>">
				<input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
				<input type="button" name="bTest" onclick="testFill();" value="<%=lang.get(si_test)%>">
				<input type="button" name="bHistory" onclick="history();" value="<%=lang.get(si_history)%>">
			</td>
			<td id="tableControls" align="right"></td>
		</tr>
		<tr align="center">
			<td colspan="2">
				<span id="filterControls"></span></td>
		</tr>
	</table>
	<t:table from="mpt_print_settings_v">
		<t:field id="1" name="setting_id" label="<%=si_id%>">
			<t:filter operator="=" />
		</t:field>
		<t:field id="2" name="setting_name" label="<%=si_name%>" type="quote">
			<t:filter operator="_search_" mask="200|" />
		</t:field>
		<t:field id="3" name="module_name" label="<%=si_module%>" type="quote">
			<t:filter operator="_search_" mask="100|" />
		</t:field>
		<t:field id="4" name="template_name" label="<%=si_template_type%>" type="quote">
			<t:filter operator="_search_" mask="200|" />
		</t:field>
		<t:field id="5" name="file_type" label="<%=si_file_type%>">
			<t:filter operator="choice" />
		</t:field>
		<t:field id="6" name="file_format" label="<%=si_file_format%>">
			<t:filter operator="choice" />
		</t:field>
		<t:field id="7" name="activation_date" label="<%=si_activation_date%>" type="date">
			<t:filter operator="range" mask="date" size="9" />
		</t:field>
		<t:field id="8" name="is_active" label="<%=si_active%>">
			<t:filter option="<%=si_active_option%>" />
		</t:field>
		<t:field id="9" name="description" label="<%=si_description%>" type="quote">
			<t:filter operator="_search_" mask="1000|" />
		</t:field>
		<t:field id="10" name="oper_day" label="<%=si_created%>" type="date">
			<t:filter operator="range" mask="date" size="9" />
		</t:field>
		<t:field id="11" name="deactivation_date" label="<%=si_deactivation_date%>" type="date">
			<t:filter operator="range" mask="date" size="9" />
		</t:field>
		<t:field id="12" name="state_name" label="<%=si_active%>" type="quote" />
		<t:field id="13" name="has_file" label="<%=si_file%>" type="quote" />
		<t:grid page="" numbering="" withoutCursor="" rowColor="(d(8)=='N')?'#AAAAAA':''">
			<t:column for="2" align="left" />
			<t:column for="3" />
			<t:column for="4" align="left" />
			<t:column for="5" />
			<t:column for="6" />
			<t:column for="13" align="center" />
			<t:column for="7" />
			<t:column for="11" />
			<t:column for="12" />
			<t:foot><t:row>
				<t:cell for="9" size="100%" />
				<t:cell for="10" size="100%" />
			</t:row></t:foot>
		</t:grid>
	</t:table>
</t:form>
</t:page>
<%!
	static final int si_title = SI("Настройки шаблона", "Шаблон созламалари", "Shablon sozlamalari", "Template settings");
	static final int si_add = SI("Добавить", "Кушиш", "Qo'shish", "Add");
	static final int si_edit = SI("Изменить", "Узгартириш", "O'zgartirish", "Edit");
	static final int si_test = SI("Тест", "Тест", "Test", "Test");
	static final int si_history = SI("История", "Тарих", "Tarix", "History");
	static final int si_id = SI("ID", "ID", "ID", "ID");
	static final int si_name = SI("Название шаблона", "Шаблон номи", "Shablon nomi", "Template name");
	static final int si_module = SI("Модуль", "Модул", "Modul", "Module");
	static final int si_template_type = SI("Тип шаблона", "Шаблон тури", "Shablon turi", "Template type");
	static final int si_file_type = SI("Тип файла", "Файл тури", "Fayl turi", "File type");
	static final int si_file_format = SI("Формат", "Формат", "Format", "Format");
	static final int si_file = SI("Файл", "Файл", "Fayl", "File");
	static final int si_activation_date = SI("Дата активации", "Активация санаси", "Aktivatsiya sanasi", "Activation date");
	static final int si_deactivation_date = SI("Дата деактивации", "Деактивация санаси", "Deaktivatsiya sanasi", "Deactivation date");
	static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_active_option = SI("<option value=''><option value='Y'>Активный<option value='N'>Неактивный", "<option value=''><option value='Y'>Фаол<option value='N'>Нофаол", "<option value=''><option value='Y'>Faol<option value='N'>Nofaol", "<option value=''><option value='Y'>Active<option value='N'>Inactive");
	static final int si_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
	static final int si_created = SI("Дата создания", "Яратилган сана", "Yaratilgan sana", "Created");
%>
<%@ include file="/language.jsp" %>
