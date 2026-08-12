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

	String templateCode = request.getParameter("template_code");
	String templateName = request.getParameter("template_name");
	String typeModuleCode = request.getParameter("type_module_code");

	/* SAQLASH - dvs_settings.jsp naqshi. Saqlash tugmasi go({form:tblForm,...})
	 * orqali BUTUN sahifani qayta yuklaydi (iframe emas): tblForm ichidagi
	 * belgilangan checkbox'lar (name="vc", value=variable_code) POST bilan keladi.
	 * Bu yerda ularni o'qib, Save_Type_Vars_Bulk (set-based sync) chaqiramiz,
	 * so'ng grid yangi holat bilan qayta chiziladi (checked holat DB'dan). */
	if (request.getParameter("save_submit") != null) {
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Mpt_Admin_Api.Save_Type_Vars_Bulk");
			cs.setString("i_Template_Code", templateCode);
			cs.setArrayStringParameter("i_Variable_Codes", "vc");
			cs.setNumber("i_User_Id", user.getUserCode());
			cs.execute();
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}

	/* TEMPLATE_CODE formatini tekshirish - t:table where="..." atributiga
	 * (SQL matni sifatida bevosita qo'yiladi) faqat xavfsiz qiymat tushsin. */
	String safeTemplateCode = (templateCode != null && templateCode.matches("[A-Za-z0-9_]{1,50}")) ? templateCode : "";
	String safeModuleCode = (typeModuleCode != null && typeModuleCode.matches("[A-Za-z0-9_]{1,20}")) ? typeModuleCode : null;
	/* t:table where atributi butunlay bitta JSP-ifoda bo'lishi kerak. Matn
	 * ichiga joylashtirilgan ifoda almashtirilmay, literal bo'lib qoladi va
	 * grid hech qanday qator qaytarmaydi - shu sabab shart shu yerda tayyorlanadi.
	 *
	 * Modul bo'yicha cheklov: shu shablon turining moduliga tegishli
	 * o'zgaruvchilar + barcha modullar uchun umumiy (module_code is null)
	 * global o'zgaruvchilar - boshqa modulga tegishli o'zgaruvchilar
	 * ko'rsatilmaydi. safeModuleCode aniqlanmasa (kutilmagan holat) -
	 * xavfsizlik uchun hech narsa ko'rsatilmaydi (1=0), modul cheksiz
	 * ro'yxat chiqib ketmasligi uchun. */
	String gridWhere = "template_code = '" + safeTemplateCode + "'"
		+ (safeModuleCode != null
			? " and (module_code = '" + safeModuleCode + "' or module_code is null)"
			: " and 1 = 0");
	String pageTitle = lang.get(si_title) + (templateName == null || templateName.equals("") ? "" : " - " + templateName);
%><t:page><%
%><t:form titleText="<%=pageTitle%>" minWidth="fill" minHeight="fill">
	<script>
		var TEMPLATE_CODE = <%=js(templateCode)%>;
		var TEMPLATE_NAME = <%=js(templateName)%>;
		var TYPE_MODULE_CODE = <%=js(typeModuleCode)%>;

		/* Framework'ning tblForm'ini (grid checkbox'lari shu forma ichida)
		 * to'g'ridan-to'g'ri POST qiladi - go() CSRF token qo'shadi va
		 * belgilangan checkbox'larning value'sini (variable_code) yuboradi.
		 * save_submit sahifa boshidagi saqlashni ishga tushiradi. */
		function save() {
			go({
				form: tblForm,
				param: {
					save_submit: "1",
					template_code: TEMPLATE_CODE,
					template_name: TEMPLATE_NAME,
					type_module_code: TYPE_MODULE_CODE
				}
			});
		}
	</script>
	<table class="formToolbar" align="center">
		<tr>
			<td>
				<input type="button" name="bSave" onclick="save();" value="<%=lang.get(si_save)%>">
			<td id="tableControls" align="right">
				<input type="button" onclick="top.close();" value="<%=lang.get(si_exit)%>">
		</tr>
		<tr align="center">
			<td colspan="2">
				<span id="filterControls"></span></td>
		</tr>
	</table>
	<t:table from="mpt_template_type_vars_v" where="<%=gridWhere%>">
		<t:field id="1" name="variable_code" label="<%=si_code%>">
			<t:filter operator="_search_" mask="100|" />
		</t:field>
		<t:field id="2" name="var_name" label="<%=si_name%>" type="quote">
			<t:filter operator="_search_" mask="200|" />
		</t:field>
		<t:field id="3" name="module_name" label="<%=si_module%>" type="quote" />
		<t:field id="4" name="module_code" label="<%=si_module%>">
			<t:filter operator="choice" />
		</t:field>
		<t:field id="5" name="type_name" label="<%=si_type%>" type="quote" />
		<t:field id="6" name="var_source" label="<%=si_source%>" />
		<t:field id="7" name="description" label="<%=si_description%>" type="quote">
			<t:filter operator="_search_" mask="2000|" />
		</t:field>
		<t:field id="8" name="example_value" label="<%=si_example%>" type="quote" />
		<t:field id="9" name="placeholder" label="<%=si_placeholder%>" />
		<t:field id="10" name="is_mapped" label="<%=si_mapped%>" />
		<%-- where sharti shu ustunga tayanadi: framework SELECT ro'yxatini
		     t:field'lardan quradi, e'lon qilinmagan ustun WHERE'da ko'rinmaydi. --%>
		<t:field id="11" name="template_code" label="<%=si_code%>" />
		<t:grid page="" numbering="" withoutCursor="" withoutSortButtons="">
			<t:column for="1" type="checkbox" name="vc" checked="10" nowrap="" labelText="<%=lang.get(si_mapped)%>" />
			<t:column for="9" align="left" />
			<t:column for="2" align="left" />
			<t:column for="3" align="left" />
			<t:column for="5" />
			<t:column for="6" />
			<t:foot><t:row>
				<t:cell for="7" size="100%" />
				<t:cell for="8" size="100%" />
			</t:row></t:foot>
		</t:grid>
	</t:table>
</t:form>
</t:page>
<%!
	static final int si_title = SI("Переменные типа шаблона", "Шаблон тури узгарувчилари", "Shablon turi o'zgaruvchilari", "Template type variables");
	static final int si_save = SI("Сохранить", "Саклаш", "Saqlash", "Save");
	static final int si_exit = SI("Закрыть", "Ёпиш", "Yopish", "Close");
	static final int si_code = SI("Код", "Код", "Kod", "Code");
	static final int si_placeholder = SI("Плейсхолдер", "Плейсхолдер", "Placeholder", "Placeholder");
	static final int si_name = SI("Переменная", "Узгарувчи", "O'zgaruvchi", "Variable");
	static final int si_module = SI("Модуль", "Модул", "Modul", "Module");
	static final int si_type = SI("Тип", "Тури", "Turi", "Type");
	static final int si_source = SI("Источник", "Манба", "Manba", "Source");
	static final int si_mapped = SI("Привязано", "Бириктирилган", "Biriktirilgan", "Attached");
	static final int si_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
	static final int si_example = SI("Пример", "Намуна", "Namuna", "Example");

	static String js(String s) {
		if (s == null) return "null";
		return "'" + s.replace("\\", "\\\\").replace("'", "\\'").replace("\r", "").replace("\n", "\\n") + "'";
	}
%>
<%@ include file="/language.jsp" %>
