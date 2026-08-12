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
	String variable_code = request.getParameter("variable_code");
	boolean is_edit = (variable_code != null && !variable_code.equals(""));
	if (is_edit) {
		try {
			out.println("<script>var data=" + stored.execJsonRequestFunction("Mpt_Admin_Api.Get_Model_Clob", request) + ";</script>");
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<script>
		function toggleSource() {
			var src = fm.var_source.value;
			getDOM("valueField").style.display = (src == "STATIC") ? "" : "none";
			getDOM("queryField").style.display = (src == "DYNAMIC") ? "" : "none";
		}

		function onLoad() {
			toggleSource();
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" target="frm">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="sm_relation_id" value="">
			<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>
			<div style="display:grid;grid-template-columns:1fr 2fr;gap:5px">
				<div class="form-group">
					<input name="variable_code" mask="100|A-Za-z0-9_" <%=is_edit?"readonly":""%> r="1" class="form-control" placeholder="g_bank_name">
					<label><%=lang.get(si_code)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<input name="var_name" mask="200|" r="1" class="form-control">
					<label><%=lang.get(si_name)%> <q></q>:</label>
				</div>
			</div>
			<div class="form-group">
				<select name="module_code" class="form-control">
					<option value=""><%=lang.get(si_module_all)%></option>
					<t:options code="module_code" name="module_name" from="mpt_modules_v" />
				</select>
				<label><%=lang.get(si_module)%>:</label>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<select name="var_type" class="form-control" r="1">
						<option value=""></option>
						<t:options code="type_code" name="type_name" from="mpt_variable_types" />
					</select>
					<label><%=lang.get(si_type)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<select name="var_source" class="form-control" r="1" onchange="toggleSource();">
						<option value="STATIC"><%=lang.get(si_source_static)%></option>
						<option value="DYNAMIC"><%=lang.get(si_source_dynamic)%></option>
					</select>
					<label><%=lang.get(si_source)%> <q></q>:</label>
				</div>
			</div>
			<div class="form-group" id="valueField">
				<input name="var_value" mask="500|" class="form-control">
				<label><%=lang.get(si_var_value)%>:</label>
			</div>
			<div class="form-group" id="queryField">
				<textarea name="var_query" class="form-control" rows="3"></textarea>
				<label><%=lang.get(si_var_query)%>:</label>
			</div>
			<div class="form-group">
				<textarea name="description" class="form-control" rows="2"></textarea>
				<label><%=lang.get(si_description)%>:</label>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<input name="example_value" mask="500|" class="form-control">
					<label><%=lang.get(si_example)%>:</label>
				</div>
				<div class="form-group">
					<input name="usage_note" mask="500|" class="form-control">
					<label><%=lang.get(si_usage_note)%>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<select name="needs_translit" class="form-control">
						<option value="N"><%=lang.get(si_no)%></option>
						<option value="Y"><%=lang.get(si_yes)%></option>
					</select>
					<label><%=lang.get(si_needs_translit)%>:</label>
				</div>
				<div class="form-group">
					<select name="is_required" class="form-control">
						<option value="N"><%=lang.get(si_no)%></option>
						<option value="Y"><%=lang.get(si_yes)%></option>
					</select>
					<label><%=lang.get(si_is_required)%>:</label>
				</div>
			</div>
			<div class="form-group">
				<select name="is_active" class="form-control" r="1">
					<option value="Y"><%=lang.get(si_active)%></option>
					<option value="N"><%=lang.get(si_inactive)%></option>
				</select>
				<label><%=lang.get(si_state)%>:</label>
			</div>
		</form>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			stored.execJsonRequestProcedure("Mpt_Admin_Api.Execute_Process_Clob", request);
			out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			out.print("<script>parent.pageLock(false);</script>");
		}
	%></t:request>
</t:requests>
<%!
	static final int si_add_title = SI("Добавление глобальной переменной", "Глобал узгарувчи кушиш", "Global o'zgaruvchi qo'shish", "Add global variable");
	static final int si_edit_title = SI("Изменение глобальной переменной", "Глобал узгарувчини узгартириш", "Global o'zgaruvchi o'zgartirish", "Edit global variable");
	static final int si_save = SI("Сохранить", "Саклаш", "Saqlash", "Save");
	static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit = SI("Выход", "Чикиш", "Chiqish", "Exit");
	static final int si_code = SI("Код переменной", "Узгарувчи коди", "O'zgaruvchi kodi", "Variable code");
	static final int si_name = SI("Название", "Номи", "Nomi", "Name");
	static final int si_type = SI("Тип", "Тури", "Turi", "Type");
	static final int si_module = SI("Модуль", "Модуль", "Modul", "Module");
	static final int si_module_all = SI("Все модули", "Барча модуллар", "Barcha modullar", "All modules");
	static final int si_source = SI("Источник значения", "Кийимат манбаи", "Qiymat manbai", "Value source");
	static final int si_source_static = SI("Статический", "Статик", "Statik", "Static");
	static final int si_source_dynamic = SI("Динамический (SQL)", "Динамик (SQL)", "Dinamik (SQL)", "Dynamic (SQL)");
	static final int si_var_value = SI("Статическое значение", "Статик кийимат", "Statik qiymat", "Static value");
	static final int si_var_query = SI("SQL запрос", "SQL суорови", "SQL so'rovi", "SQL query");
	static final int si_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
	static final int si_example = SI("Пример значения", "Кийимат намунаси", "Qiymat namunasi", "Example value");
	static final int si_usage_note = SI("Примечание по использованию", "Фойдаланиш изохи", "Foydalanish izohi", "Usage note");
	static final int si_needs_translit = SI("Нужна транслитерация", "Транслитерация керакми", "Transliteratsiya kerakmi", "Needs transliteration");
	static final int si_is_required = SI("Обязательно", "Мажбурийми", "Majburiymi", "Required");
	static final int si_yes = SI("Да", "Ха", "Ha", "Yes");
	static final int si_no = SI("Нет", "Йук", "Yo'q", "No");
	static final int si_state = SI("Состояние", "Холат", "Holat", "State");
	static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_inactive = SI("Неактивный", "Нофаол", "Nofaol", "Inactive");
%>
<%@ include file="/language.jsp" %>
