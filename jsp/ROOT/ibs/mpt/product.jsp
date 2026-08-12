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
	String group_code = request.getParameter("group_code");
	boolean is_edit = (group_code != null && !group_code.equals(""));
	if (is_edit) {
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			ps = conn.prepareStatement(
				"select json_object(" +
				"'group_code' value group_code, " +
				"'group_name' value group_name, " +
				"'product_type' value product_type, " +
				"'module_code' value module_code, " +
				"'category_code' value category_code, " +
				"'workflow_state' value workflow_state, " +
				"'history_retention_days' value history_retention_days, " +
				"'description' value description" +
				") as json_data from mpt_products_v where group_code = ?");
			ps.setString(1, group_code);
			rs = ps.executeQuery();
			if (rs.next()) {
				out.println("<script>var data=" + rs.getString("json_data") + ";</script>");
			}
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		} finally {
			if (rs != null) rs.close();
			if (ps != null) ps.close();
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<script>
		function onLoad() {
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" target="frm">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>
			<div class="form-group">
				<input name="group_code" mask="100|" <%=is_edit?"readonly":""%> r="1" class="form-control">
				<label><%=lang.get(si_code)%> <q></q>:</label>
			</div>
			<div class="form-group">
				<input name="group_name" mask="200|" r="1" class="form-control">
				<label><%=lang.get(si_name)%> <q></q>:</label>
			</div>
			<div class="form-group">
				<select name="product_type" class="form-control" r="1">
					<option value="KREDIT"><%=lang.get(si_t_loan)%></option>
					<option value="IPOTEKA"><%=lang.get(si_t_mortgage)%></option>
					<option value="KAFILLIK"><%=lang.get(si_t_guarantee)%></option>
					<option value="DEPOZIT"><%=lang.get(si_t_deposit)%></option>
					<option value="KASSA"><%=lang.get(si_t_cashdesk)%></option>
					<option value="XALQARO"><%=lang.get(si_t_international)%></option>
					<option value="HISOB"><%=lang.get(si_t_account)%></option>
					<option value="TERMINAL"><%=lang.get(si_t_terminal)%></option>
					<option value="AKKREDITIV"><%=lang.get(si_t_letter_of_credit)%></option>
				</select>
				<label><%=lang.get(si_type)%> <q></q>:</label>
			</div>
			<div class="form-group">
				<input name="module_code" mask="50|" r="1" class="form-control">
				<label><%=lang.get(si_module)%> <q></q>:</label>
			</div>
			<div class="form-group">
				<select name="category_code" class="form-control">
					<option value=""></option>
					<t:options code="category_code" name="category_name" from="mpt_template_types" />
				</select>
				<label><%=lang.get(si_category)%>:</label>
			</div>
			<div class="form-group">
				<select name="workflow_state" class="form-control" r="1">
					<option value="TASDIQLASHDA"><%=lang.get(si_s_pending)%></option>
					<option value="AKTIV"><%=lang.get(si_s_active)%></option>
					<option value="PASSIV"><%=lang.get(si_s_inactive)%></option>
					<option value="ARXIVDA"><%=lang.get(si_s_archived)%></option>
					<option value="BEKOR_QILINGAN"><%=lang.get(si_s_cancelled)%></option>
				</select>
				<label><%=lang.get(si_state)%> <q></q>:</label>
			</div>
			<div class="form-group">
				<input name="history_retention_days" mask="4|0-9" value="365" class="form-control">
				<label><%=lang.get(si_retention_days)%>:</label>
			</div>
			<div class="form-group">
				<textarea name="description" class="form-control" rows="3"></textarea>
				<label><%=lang.get(si_description)%>:</label>
			</div>
		</form>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Mpt_Admin_Api.Save_Product");
			cs.setString("i_Group_Code", request.getParameter("group_code"));
			cs.setString("i_Group_Name", request.getParameter("group_name"));
			cs.setString("i_Module_Code", request.getParameter("module_code"));
			cs.setString("i_Product_Type", request.getParameter("product_type"));
			cs.setString("i_Category_Code", request.getParameter("category_code"));
			cs.setNumberParameter("i_User_Id", "user_id");
			cs.setNumberParameter("i_Retention_Days", "history_retention_days");
			cs.setString("i_Description", request.getParameter("description"));
			cs.execute();

			ServletCallableStatement csState = new ServletCallableStatement(stored, request);
			csState.setProcedure("Mpt_Admin_Api.Set_Product_State");
			csState.setString("i_Group_Code", request.getParameter("group_code"));
			csState.setString("i_Workflow_State", request.getParameter("workflow_state"));
			csState.setNumberParameter("i_User_Id", "user_id");
			csState.execute();

			out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			out.print("<script>parent.pageLock(false);</script>");
		}
	%></t:request>
</t:requests>
<%!
	static final int si_add_title = SI("Добавление продукта", "Продукт кушиш", "Product qo'shish", "Add product");
	static final int si_edit_title = SI("Изменение продукта", "Продуктни узгартириш", "Productni o'zgartirish", "Edit product");
	static final int si_save = SI("Сохранить", "Саклаш", "Saqlash", "Save");
	static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit = SI("Выход", "Чикиш", "Chiqish", "Exit");
	static final int si_code = SI("Код продукта", "Продукт коди", "Product kodi", "Product code");
	static final int si_name = SI("Название продукта", "Продукт номи", "Product nomi", "Product name");
	static final int si_type = SI("Тип", "Тури", "Turi", "Type");
	static final int si_module = SI("Модуль", "Модул", "Modul", "Module");
	static final int si_category = SI("Категория", "Категория", "Kategoriya", "Category");
	static final int si_state = SI("Состояние", "Холат", "Holat", "State");
	static final int si_retention_days = SI("Срок хранения истории (дней)", "Тарих саклаш муддати (кун)", "Tarix saqlash muddati (kun)", "History retention (days)");
	static final int si_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
	static final int si_t_loan = SI("Кредит", "Кредит", "Kredit", "Loan");
	static final int si_t_mortgage = SI("Ипотека", "Ипотека", "Ipoteka", "Mortgage");
	static final int si_t_guarantee = SI("Гарантия", "Кафиллик", "Kafillik", "Guarantee");
	static final int si_t_deposit = SI("Депозит", "Депозит", "Depozit", "Deposit");
	static final int si_t_cashdesk = SI("Касса", "Касса", "Kassa", "Cash desk");
	static final int si_t_international = SI("Международные операции", "Халкаро амалиётлар", "Xalqaro amaliyotlar", "International operations");
	static final int si_t_account = SI("Счет", "Хисоб", "Hisob", "Account");
	static final int si_t_terminal = SI("Терминал", "Терминал", "Terminal", "Terminal");
	static final int si_t_letter_of_credit = SI("Аккредитив", "Аккредитив", "Akkreditiv", "Letter of credit");
	static final int si_s_pending = SI("На согласовании", "Тасдиклашда", "Tasdiqlashda", "Pending approval");
	static final int si_s_active = SI("Активный", "Актив", "Aktiv", "Active");
	static final int si_s_inactive = SI("Неактивный", "Пассив", "Passiv", "Inactive");
	static final int si_s_archived = SI("В архиве", "Архивда", "Arxivda", "Archived");
	static final int si_s_cancelled = SI("Отменен", "Бекор килинган", "Bekor qilingan", "Cancelled");
%>
<%@ include file="/language.jsp" %>
