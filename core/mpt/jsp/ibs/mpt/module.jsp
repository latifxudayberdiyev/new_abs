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
	String module_code = request.getParameter("module_code");
	boolean is_edit = (module_code != null && !module_code.equals(""));
	if (is_edit) {
		PreparedStatement ps = null;
		ResultSet rs = null;
		try {
			ps = conn.prepareStatement(
				"select json_object(" +
				"'module_code' value module_code, " +
				"'module_name' value module_name, " +
				"'is_active' value is_active" +
				") as json_data from mpt_modules where module_code = ?");
			ps.setString(1, module_code);
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
				<input name="module_code" mask="20|" <%=is_edit?"readonly":""%> r="1" class="form-control">
				<label><%=lang.get(si_code)%> <q></q>:</label>
			</div>
			<div class="form-group">
				<input name="module_name" mask="200|" r="1" class="form-control">
				<label><%=lang.get(si_name)%> <q></q>:</label>
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
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setProcedure("Mpt_Admin_Api.Save_Module");
			cs.setString("i_Module_Code", request.getParameter("module_code"));
			cs.setString("i_Module_Name", request.getParameter("module_name"));
			cs.setString("i_Is_Active", request.getParameter("is_active"));
			cs.setNumberParameter("i_User_Id", "user_id");
			cs.execute();

			out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			out.print("<script>parent.pageLock(false);</script>");
		}
	%></t:request>
</t:requests>
<%!
	static final int si_add_title = SI("Добавление модуля", "Модул кушиш", "Modul qo'shish", "Add module");
	static final int si_edit_title = SI("Изменение модуля", "Модулни узгартириш", "Modulni o'zgartirish", "Edit module");
	static final int si_save = SI("Сохранить", "Саклаш", "Saqlash", "Save");
	static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit = SI("Выход", "Чикиш", "Chiqish", "Exit");
	static final int si_code = SI("Код модуля", "Модул коди", "Modul kodi", "Module code");
	static final int si_name = SI("Название модуля", "Модул номи", "Modul nomi", "Module name");
	static final int si_state = SI("Состояние", "Холат", "Holat", "State");
	static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_inactive = SI("Неактивный", "Нофаол", "Nofaol", "Inactive");
%>
<%@ include file="/language.jsp" %>
