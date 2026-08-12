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

		function history() {
			if (!getDOM("bHistory").disabled) {
				go({
					url: "template_type_history.jsp",
					param: {
						template_code: getData(1)
					},
					target: "modalE",
					dialogHeight: 520,
					dialogWidth: 900,
					lock: false,
					callback: responseModal
				});
			}
		}

		function vars() {
			if (!getDOM("bVars").disabled) {
				go({
					url: "template_type_vars.jsp",
					param: {
						template_code: getData(1),
						template_name: getData(2),
						type_module_code: getData(15)
					},
					target: "modalE",
					dialogHeight: 560,
					dialogWidth: 920,
					lock: false,
					callback: responseModal
				});
			}
		}

		function add() {
			go({
				url: "template_type.jsp?process_code=CREATE_TEMPLATE_TYPE",
				target: "modalE",
				dialogHeight: 640,
				dialogWidth: 640,
				lock: false,
				callback: responseModal
			});
		}

		function edit() {
			if (!getDOM("bEdit").disabled) {
				go({
					url: "template_type.jsp?process_code=EDIT_TEMPLATE_TYPE",
					param: {
						model_process_code: "MODEL_TEMPLATE_TYPE",
						template_code: getData(1),
						sm_relation_id: getData(11)
					},
					target: "modalE",
					dialogHeight: 640,
					dialogWidth: 640,
					lock: false,
					callback: responseModal
				});
			}
		}

		function onAction() {
			edit();
		}

		function onLoad() {
			if (!dataExist()) {
				getDOM("bEdit").setDisable(true);
				getDOM("bVars").setDisable(true);
				getDOM("bHistory").setDisable(true);
			}
		}

		/* Filter oynasidagi Kod polyasi (f1 - t:field id'iga mos)
		 * add/edit formadagi bilan bir xil avtomat-upper xulq-atvorga ega bo'lishi uchun -
		 * filter polyalari dinamik yaratilgani sababli document darajasida delegatsiya ishlatiladi.
		 */
		document.addEventListener("input", function (e) {
			var t = e.target;
			if (t && t.tagName == "INPUT" && t.name == "f1") {
				t.value = t.value.toUpperCase();
			}
		}, true);
	</script>
	<table class="formToolbar" align="center">
		<tr>
			<td>
				<input type="button" name="bAdd" onclick="add();" value="<%=lang.get(si_add)%>">
				<input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
				<input type="button" name="bVars" onclick="vars();" value="<%=lang.get(si_vars)%>">
				<input type="button" name="bHistory" onclick="history();" value="<%=lang.get(si_history)%>">
			</td>
			<td id="tableControls" align="right"></td>
		</tr>
		<tr align="center">
			<td colspan="2">
				<span id="filterControls"></span></td>
		</tr>
	</table>
	<t:table from="mpt_template_types_v">
		<t:field id="1" name="template_code" label="<%=si_code%>">
			<t:filter operator="_search_" mask="50|A-Za-z" />
		</t:field>
		<t:field id="2" name="template_name" label="<%=si_name%>" type="quote">
			<t:filter operator="_search_" mask="200|" />
		</t:field>
		<t:field id="5" name="module_name" label="<%=si_module%>" type="quote">
			<t:filter operator="_search_" mask="200|" />
		</t:field>
		<t:field id="6" name="description" label="<%=si_description%>" type="quote">
			<t:filter operator="_search_" mask="1000|" />
		</t:field>
		<t:field id="7" name="is_active" label="<%=si_active%>">
			<t:filter option="<%=si_active_option%>" />
		</t:field>
		<t:field id="9" name="modified_on" label="<%=si_updated%>" type="datetime">
			<t:filter operator="range" mask="datetime" />
		</t:field>
		<t:field id="11" name="sm_relation_id" label="<%=si_sm_id%>" />
		<t:field id="12" name="state_name" label="<%=si_active%>" type="quote" />
		<t:field id="13" name="modified_by" label="<%=si_updated_by%>">
			<t:filter mask="9|0-9" size="9" />
		</t:field>
		<t:field id="14" name="modified_by_name" label="<%=si_updated_by%>" type="quote" />
		<t:field id="15" name="module_code" label="<%=si_module%>" />
		<t:grid page="" numbering="" withoutCursor="" rowColor="(d(7)=='N')?'#AAAAAA':''">
			<t:column for="1" />
			<t:column for="2" align="left" />
			<t:column for="5" align="left" />
			<t:column for="12" />
			<t:column for="14" align="left" />
			<t:column for="9" />
			<t:foot><t:row>
				<t:cell for="6" size="100%" />
			</t:row></t:foot>
		</t:grid>
	</t:table>
</t:form>
</t:page>
<%!
	static final int si_title = SI("Типы шаблонов", "Шаблон турлари", "Shablon turlari", "Template types");
	static final int si_history = SI("История", "Тарих", "Tarix", "History");
	static final int si_vars = SI("Переменные", "Узгарувчилар", "O'zgaruvchilar", "Variables");
	static final int si_add = SI("Добавить", "Кушиш", "Qo'shish", "Add");
	static final int si_edit = SI("Изменить", "Узгартириш", "O'zgartirish", "Edit");
	static final int si_code = SI("Код", "Код", "Kod", "Code");
	static final int si_name = SI("Название", "Номи", "Nomi", "Name");
	static final int si_module = SI("Модуль", "Модул", "Modul", "Module");
	static final int si_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
	static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_active_option = SI("<option value=''><option value='Y'>Активный<option value='N'>Неактивный", "<option value=''><option value='Y'>Фаол<option value='N'>Нофаол", "<option value=''><option value='Y'>Faol<option value='N'>Nofaol", "<option value=''><option value='Y'>Active<option value='N'>Inactive");
	static final int si_created = SI("Дата создания", "Яратилган сана", "Yaratilgan sana", "Created");
	static final int si_updated = SI("Дата изменения", "Янгиланган сана", "Yangilangan sana", "Updated");
	static final int si_sm_id = SI("SM ID", "SM ID", "SM ID", "SM ID");
	static final int si_updated_by = SI("Кем изменено", "Ким узгартирган", "Kim o'zgartirgan", "Updated by");
%>
<%@ include file="/language.jsp" %>
