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
	String code = request.getParameter("code");
	String attributeIdParam = request.getParameter("attribute_id");
	boolean is_edit = (code != null && !code.equals(""));
	if (is_edit) {
		try {
			out.println("<script>var data=" + stored.execJsonRequestFunction("Core_Api.Get_Model_Clob", request) + ";" +
				/* fillForm() data'dagi HAR bir kalitni id bo'yicha getElementById orqali
				   izlaydi va topilmasa BUTUN window.onload'ni xatosiz to'xtatib qo'yadi
				   (id="pfInputType" name="input_type"'ga mos kelmagani uchun aynan shu
				   yerda tutilib qolgan edi). Shu sabab data'ni o'z nusxamizga ko'chirib,
				   asl data'ni bo'shatamiz - fillForm shundan keyin hech narsa qilmaydi,
				   maydonlarni pfInit() ichida o'zimiz to'g'ri tartibda to'ldiramiz. */
				"var pfParamModel={};for(var k in data){pfParamModel[k]=data[k];delete data[k];}</script>");
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<script>
		function toggleValueFunction() {
			var v = document.fm.input_type.value;
			var showFn = v === "FUNCTION";
			var showRef = v === "REFERENCE";
			document.getElementById("pfValueFunctionRow").style.display = showFn ? "" : "none";
			/* value_function ATAYIN majburiy emas - bo'sh qoldirilsa, Bekhzod qurgan
			   qoida-jadval (Pf_Util.Get_Rule_Derived_Value) ishlaydi. */
			document.getElementById("pfReferenceRow").style.display = showRef ? "" : "none";
			document.fm.reference_id.required = showRef;
		}

		var pfInitDone = false;
		function pfInit() {
			if (pfInitDone) return;
			pfInitDone = true;
			/* select.2.0.js (SlimSelect) faqat asosiy <select>ga o'zining ichki
			   "change" listenerini addEventListener bilan qo'shadi va foydalanuvchi
			   custom widget orqali variant tanlaganda haqiqiy elementga native
			   "change" Event dispatch qiladi - lekin bu inline onchange="" atributi
			   orqali chaqirilgan funksiyani har doim ham ishonchli qayta
			   ishga tushiravermaydi. Shu sabab qo'shimcha addEventListener bilan
			   mustahkamlanmoqda (ikkalasi ham chaqirilsa muammo yo'q, funksiya idempotent). */
			document.fm.input_type.addEventListener("change", toggleValueFunction);
<%
	if (is_edit) {
%>
			document.fm.attribute_id.value = pfParamModel.attribute_id;
			document.fm.code.value = pfParamModel.code;
			document.fm.name.value = pfParamModel.name;
			document.fm.value_type.value = pfParamModel.value_type;
			document.fm.input_type.value = pfParamModel.input_type || 'MANUAL';
			document.fm.value_function.value = pfParamModel.value_function || '';
			document.fm.reference_id.value = pfParamModel.reference_id || '';
			document.fm.change_policy.value = pfParamModel.change_policy || 'VERSIONED';
			document.fm.sort_order.value = pfParamModel.sort_order || 0;
			document.fm.default_value.value = pfParamModel.default_value || '';
			document.fm.is_required.value = (pfParamModel.is_required == 1) ? "1" : "0";
			document.fm.parameter_id.value = pfParamModel.parameter_id;
<%
	}
%>
			/* input_type haqiqiy qiymati yuqorida to'g'ri o'rnatilgach chaqiriladi -
			   shundagina Функция/Справочник qatorlari to'g'ri ko'rsatiladi/yashiriladi. */
			toggleValueFunction();
		}

		function onLoad() {
			pfInit();
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" action="parameter.jsp?process_code=<%=is_edit?"EDIT_PF_PARAMETER":"CREATE_PF_PARAMETER"%>" target="frm">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="parameter_id" value="">
			<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<select name="attribute_id" r="1" class="form-control"><%
						Statement stAttr = null;
						ResultSet rsAttr = null;
						try {
							stAttr = conn.createStatement();
							rsAttr = stAttr.executeQuery("select ID, NAME from PF_R_ATTRIBUTES_V where SOURCE_TYPE != 'SPECIAL' order by SORT_ORDER");
							while (rsAttr.next()) {
								long attrId = rsAttr.getLong("ID");
								String attrName = rsAttr.getString("NAME");
								boolean preselected = !is_edit && attributeIdParam != null && attributeIdParam.equals(String.valueOf(attrId));
					%>
						<option value="<%=attrId%>" <%=preselected?"selected":""%>><%=esc(attrName)%></option><%
							}
						} finally {
							if (rsAttr != null) rsAttr.close();
							if (stAttr != null) stAttr.close();
						}
					%>
					</select>
					<label><%=lang.get(si_attribute)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<input name="code" r="1" mask="100|A-Za-z0-9_" oninput="this.value=this.value.toLowerCase();" <%=is_edit?"readonly":""%> class="form-control">
					<label><%=lang.get(si_code)%> <q></q>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<input name="name" r="1" mask="200|" class="form-control">
					<label><%=lang.get(si_name)%> <q></q>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<select name="value_type" r="1" class="form-control">
						<option value="STRING"><%=lang.get(si_vt_string)%></option>
						<option value="NUMBER"><%=lang.get(si_vt_number)%></option>
						<option value="BOOLEAN"><%=lang.get(si_vt_boolean)%></option>
						<option value="DATE"><%=lang.get(si_vt_date)%></option>
					</select>
					<label><%=lang.get(si_value_type)%>:</label>
				</div>
				<div class="form-group">
					<select name="input_type" r="1" onchange="toggleValueFunction();" class="form-control">
						<option value="MANUAL"><%=lang.get(si_it_manual)%></option>
						<option value="FUNCTION"><%=lang.get(si_it_function)%></option>
						<option value="REFERENCE"><%=lang.get(si_it_reference)%></option>
					</select>
					<label><%=lang.get(si_input_type)%>:</label>
				</div>
			</div>
			<div id="pfValueFunctionRow" style="display:none;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<select name="value_function" class="form-control"><%
						out.println("<option value=\"\">" + esc(lang.get(si_value_function_none)) + "</option>");
						Statement stFn = null;
						ResultSet rsFn = null;
						try {
							stFn = conn.createStatement();
							rsFn = stFn.executeQuery("select FUNCTION_NAME, NAME from PF_R_VALUE_FUNCTIONS_V order by SORT_ORDER");
							while (rsFn.next()) {
								String fnName = rsFn.getString("FUNCTION_NAME");
								String fnLabel = rsFn.getString("NAME");
					%>
						<option value="<%=esc(fnName)%>"><%=esc(fnLabel)%></option><%
							}
						} finally {
							if (rsFn != null) rsFn.close();
							if (stFn != null) stFn.close();
						}
					%>
					</select>
					<label><%=lang.get(si_value_function)%> <q></q>:</label>
				</div>
			</div>
			<div id="pfReferenceRow" style="display:none;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<select name="reference_id" class="form-control"><%
						Statement stRef = null;
						ResultSet rsRef = null;
						try {
							stRef = conn.createStatement();
							rsRef = stRef.executeQuery("select ID, NAME from PF_R_REFERENCE_VIEWS_V order by SORT_ORDER");
							boolean anyRef = false;
							while (rsRef.next()) {
								anyRef = true;
								long refId = rsRef.getLong("ID");
								String refName = rsRef.getString("NAME");
					%>
						<option value="<%=refId%>"><%=esc(refName)%></option><%
							}
							if (!anyRef) {
					%>
						<option value=""><%=lang.get(si_no_references)%></option><%
							}
						} finally {
							if (rsRef != null) rsRef.close();
							if (stRef != null) stRef.close();
						}
					%>
					</select>
					<label><%=lang.get(si_reference)%> <q></q>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<select name="change_policy" r="1" class="form-control">
						<option value="VERSIONED"><%=lang.get(si_cp_versioned)%></option>
						<option value="INPLACE"><%=lang.get(si_cp_inplace)%></option>
					</select>
					<label><%=lang.get(si_change_policy)%>:</label>
				</div>
				<div class="form-group">
					<input name="sort_order" mask="10|0-9" value="0" r="1" class="form-control">
					<label><%=lang.get(si_sort_order)%>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<input name="default_value" mask="4000|" class="form-control">
					<label><%=lang.get(si_default_value)%>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr;gap:5px">
				<div class="form-group">
					<select name="is_required" r="1" class="form-control">
						<option value="0"><%=lang.get(si_no)%></option>
						<option value="1"><%=lang.get(si_yes)%></option>
					</select>
					<label><%=lang.get(si_is_required)%>:</label>
				</div>
			</div>
		</form>
		<script>pfInit();</script>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
			out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			out.print("<script>parent.pageLock(false);</script>");
		}
	%></t:request>
</t:requests>
<%!
	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
	}
	static final int si_add_title = SI("Добавление параметра", "Параметр &#1179;&#1118;шиш", "Parametr qo'shish", "Add parameter");
	static final int si_edit_title = SI("Изменение параметра", "Параметрни &#1038;згартириш", "Parametrni o'zgartirish", "Edit parameter");
	static final int si_save = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
	static final int si_success = SI("Успешно выполнено!", "Муваффа&#1179;иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit = SI("Отмена", "Бекор &#1179;илиш", "Bekor qilish", "Cancel");
	static final int si_attribute = SI("Атрибут", "Атрибут", "Atribut", "Attribute");
	static final int si_code = SI("Код параметра", "Параметр коди", "Parametr kodi", "Parameter code");
	static final int si_name = SI("Наименование параметра", "Параметр номи", "Parametr nomi", "Parameter name");
	static final int si_value_type = SI("Тип значения", "&#1178;иймат тури", "Qiymat turi", "Value type");
	static final int si_vt_string = SI("Строка", "Сатр", "Satr", "String");
	static final int si_vt_number = SI("Число", "Сон", "Son", "Number");
	static final int si_vt_boolean = SI("Булево (Да/Нет)", "Мантикий (Ха/&#1202;у&#1179;)", "Mantiqiy (Ha/Yo'q)", "Boolean (Yes/No)");
	static final int si_vt_date = SI("Дата", "Сана", "Sana", "Date");
	static final int si_input_type = SI("Тип ввода", "Киритиш тури", "Kiritish turi", "Input type");
	static final int si_it_manual = SI("Вручную", "&#1178;&#1118;лда", "Qo'lda", "Manual");
	static final int si_it_function = SI("Функция", "Функция", "Funksiya", "Function");
	static final int si_it_module = SI("Модуль (readonly)", "Модуль (readonly)", "Modul (readonly)", "Module (readonly)");
	static final int si_it_reference = SI("Справочник", "Справочник", "Spravochnik", "Reference");
	static final int si_value_function = SI("Имя функции", "Функция номи", "Funksiya nomi", "Function name");
	static final int si_value_function_hint = SI("PLSQL пакет.процедура, например: PKG_PERCENT_SVC.F_GET_RATE", "PLSQL пакет.процедура, масалан: PKG_PERCENT_SVC.F_GET_RATE", "PLSQL paket.protsedura, masalan: PKG_PERCENT_SVC.F_GET_RATE", "PLSQL package.procedure, e.g.: PKG_PERCENT_SVC.F_GET_RATE");
	static final int si_value_function_none = SI("-- не выбрано --", "-- танланмаган --", "-- tanlanmagan --", "-- not selected --");
	static final int si_no_functions = SI("Сначала зарегистрируйте функцию.", "Аввал функцияни ро&#1179;атдан &#1118;тказинг.", "Avval funksiyani ro'yxatdan o'tkazing.", "Register a function first.");
	static final int si_reference = SI("Справочник", "Справочник", "Spravochnik", "Reference");
	static final int si_no_references = SI("Сначала зарегистрируйте справочник.", "Аввал справочникни ро&#1179;атдан &#1118;тказинг.", "Avval spravochnikni ro'yxatdan o'tkazing.", "Register a reference first.");
	static final int si_reference_hint = SI("Значение будет выбрано из зарегистрированного справочника.", "&#1178;иймат ро&#1179;атдан &#1118;тказилган справочникдан танланади.", "Qiymat ro'yxatdan o'tkazilgan spravochnikdan tanlanadi.", "The value will be selected from the registered reference.");
	static final int si_change_policy = SI("Политика изменения", "&#1038;згариш сиёсати", "O'zgarish siyosati", "Change policy");
	static final int si_cp_versioned = SI("Новая версия (VERSIONED)", "Янги версия (VERSIONED)", "Yangi versiya (VERSIONED)", "New version (VERSIONED)");
	static final int si_cp_inplace = SI("На месте (INPLACE)", "&#1038;з жойида (INPLACE)", "Joyida (INPLACE)", "In place (INPLACE)");
	static final int si_sort_order = SI("Порядок", "Тартиб ра&#1179;ами", "Tartib raqami", "Sort order");
	static final int si_default_value = SI("Значение по умолчанию", "&#1178;иймат (одатий)", "Standart qiymat", "Default value");
	static final int si_default_value_hint = SI("Необязательно. Для NUMBER - число, для DATE - ДД.ММ.ГГГГ, для BOOLEAN - 0 или 1.", "Мажбурий эмас. NUMBER учун - сон, DATE учун - КК.ОО.ЙЙЙЙ, BOOLEAN учун - 0 ёки 1.", "Majburiy emas. NUMBER uchun - son, DATE uchun - KK.OO.YYYY, BOOLEAN uchun - 0 yoki 1.", "Optional. For NUMBER - a number, for DATE - DD.MM.YYYY, for BOOLEAN - 0 or 1.");
	static final int si_is_required = SI("Обязательный параметр", "Мажбурий параметр", "Majburiy parametr", "Required parameter");
	static final int si_yes = SI("Да", "&#1202;а", "Ha", "Yes");
	static final int si_no = SI("Нет", "&#1202;у&#1179;", "Yo'q", "No");
%>
<%@ include file="/language.jsp" %>
