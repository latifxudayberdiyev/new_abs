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
	<table class="formToolbar" align="center">
		<tr>
			<td></td>
			<td id="tableControls" align="right"></td>
		</tr>
		<tr align="center">
			<td colspan="2">
				<span id="filterControls"></span></td>
		</tr>
	</table>
	<t:table from="mpt_products_v">
		<t:field id="1" name="group_code" label="<%=si_code%>">
			<t:filter operator="_search_" mask="100|" />
		</t:field>
		<t:field id="2" name="group_name" label="<%=si_name%>" type="quote">
			<t:filter operator="_search_" mask="200|" />
		</t:field>
		<t:field id="3" name="product_type" label="<%=si_type%>" />
		<t:field id="4" name="module_code" label="<%=si_module%>" />
		<t:field id="5" name="template_code" label="<%=si_template_type_code%>" />
		<t:field id="6" name="template_name" label="<%=si_template_type%>" type="quote" />
		<t:field id="7" name="workflow_state" label="<%=si_state%>" />
		<t:field id="8" name="is_active" label="<%=si_active%>" />
		<t:field id="9" name="param_count" label="<%=si_param_count%>" />
		<t:field id="10" name="template_count" label="<%=si_template_count%>" />
		<t:field id="11" name="use_count" label="<%=si_use_count%>" />
		<t:field id="12" name="created_date" label="<%=si_created%>" type="date" />
		<t:field id="13" name="updated_date" label="<%=si_updated%>" type="date" />
		<t:grid page="" numbering="" withoutCursor="" rowColor="(d(8)=='N')?'#AAAAAA':''">
			<t:column for="1" />
			<t:column for="2" align="left" />
			<t:column for="3" />
			<t:column for="4" />
			<t:column for="7" />
			<t:column for="9" />
			<t:column for="10" />
			<t:column for="12" />
			<t:column for="13" />
			<t:foot><t:row>
				<t:cell for="6" size="100%" />
				<t:cell for="11" size="100%" />
			</t:row></t:foot>
		</t:grid>
	</t:table>
</t:form>
</t:page>
<%!
	static final int si_title = SI("Настройки шаблонов печати", "Чоп шаблонлари созламалари", "Chop shablonlari sozlamalari", "Print template settings");
	static final int si_code = SI("Код", "Код", "Kod", "Code");
	static final int si_name = SI("Название продукта", "Продукт номи", "Product nomi", "Product name");
	static final int si_type = SI("Тип", "Тури", "Turi", "Type");
	static final int si_module = SI("Модуль", "Модул", "Modul", "Module");
	static final int si_template_type_code = SI("Код типа шаблона", "Шаблон тури коди", "Shablon turi kodi", "Template type code");
	static final int si_template_type = SI("Тип шаблона", "Шаблон тури", "Shablon turi", "Template type");
	static final int si_state = SI("Состояние", "Холат", "Holat", "State");
	static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_param_count = SI("Параметры", "Параметрлар", "Parametrlar", "Parameters");
	static final int si_template_count = SI("Шаблоны", "Шаблонлар", "Shablonlar", "Templates");
	static final int si_use_count = SI("Использований", "Ишлатилган", "Ishlatilgan", "Uses");
	static final int si_created = SI("Дата создания", "Яратилган сана", "Yaratilgan sana", "Created");
	static final int si_updated = SI("Дата обновления", "Янгиланган сана", "Yangilangan sana", "Updated");
%>
<%@ include file="/language.jsp" %>
