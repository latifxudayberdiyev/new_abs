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
	boolean is_edit = (code != null && !code.equals(""));
	if (is_edit) {
		try {
			out.println("<script>var data=" + stored.execJsonRequestFunction("Core_Api.Get_Model_Clob", request) + ";</script>");
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<script>
		function onLoad() {
<%
	if (is_edit) {
%>
			document.fm.code.value = data.code;
			document.fm.category_id.value = data.category_id;
<%
	}
%>
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" action="category.jsp?process_code=<%=is_edit?"EDIT_PF_CATEGORY":"CREATE_PF_CATEGORY"%>" target="frm">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="category_id" value="">
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
					<input name="code" r="1" mask="50|A-Za-z0-9_" oninput="this.value=this.value.toUpperCase();" <%=is_edit?"readonly":""%> class="form-control">
					<label><%=lang.get(si_code)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<input name="name" r="1" mask="200|" class="form-control">
					<label><%=lang.get(si_name)%> <q></q>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr;gap:5px">
				<div class="form-group">
					<select name="state" r="1" class="form-control">
						<option value="A"><%=lang.get(si_active)%></option>
						<option value="P"><%=lang.get(si_passive)%></option>
					</select>
					<label><%=lang.get(si_state)%>:</label>
				</div>
			</div>
		</form>
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
	static final int si_add_title = SI("Добавить категорию", "Категория &#1179;&#1118;шиш", "Kategoriya qo'shish", "Add category");
	static final int si_edit_title = SI("Изменить категорию", "Категорияни &#1118;згартириш", "Kategoriyani o'zgartirish", "Edit category");
	static final int si_save = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
	static final int si_success = SI("Успешно выполнено!", "Муваффа&#1179;иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit = SI("Отмена", "Бекор &#1179;илиш", "Bekor qilish", "Cancel");
	static final int si_code = SI("Код категории", "Категория коди", "Kategoriya kodi", "Category code");
	static final int si_name = SI("Наименование категории", "Категория номи", "Kategoriya nomi", "Category name");
	static final int si_state = SI("Статус", "&#1202;олати", "Holati", "State");
	static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
	static final int si_passive = SI("Пассивный", "Пассив", "Passiv", "Passive");
%>
<%@ include file="/language.jsp" %>
