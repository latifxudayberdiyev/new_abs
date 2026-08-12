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
	String template_id = request.getParameter("template_id");
	String request_name = request.getParameter("request");
	if (template_id != null && !"save".equals(request_name)) {
		try {
			out.println("<script>var data=" + stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request) + ";</script>");
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
%><t:form title="<%=(template_id!=null)?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<style>
		.form-control { border-radius: 8px !important; }
		input[type="submit"], input[type="button"] {
			height: 30px; padding: 0 20px; border-radius: 20px !important; font: 600 12px Arial, sans-serif; cursor: pointer;
		}
		input[type="submit"] { border: 1px solid #0b3d75 !important; background: #0b3d75 !important; color: #fff !important; }
		input[type="submit"]:hover { background: #0a3268 !important; }
		input[type="button"] { border: 1px solid #d7dee8 !important; background: #fff !important; color: #344054 !important; }
		input[type="button"]:hover { background: #f4f7fb !important; border-color: #b8c9dd !important; }
	</style>
	<script>
		function onLoad() {
		}

		function beforeSave() {
			for (var i = 1; i <= 10; i++) {
				var mask = fm.elements["message_mask_lang" + i];
				var masks = fm.elements["message_masks"];
				var target = masks.length ? masks[i - 1] : masks;
				target.value = mask ? mask.value : "";
				if (mask) {
					mask.disabled = true;
				}
			}

			setTimeout(function () {
				for (var i = 1; i <= 10; i++) {
					var mask = fm.elements["message_mask_lang" + i];
					if (mask) {
						mask.disabled = false;
					}
				}
			}, 0);

			return true;
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" action="label.jsp?process_code=SAVE_LABEL_WITH_TEMPLATE" target="frm"
		      onsubmit="return beforeSave();">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="template_id" value="">
			<input type="hidden" name="label_id" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<input type="hidden" name="message_masks" value="">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>
			<div style="display:grid;grid-template-columns:2fr 2fr;gap:5px">
				<div class="form-group">
					<input name="message_code" r="1" class="form-control" readonly>
					<label><%=lang.get(si_message_code)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<input name="module_code" r="1" class="form-control" readonly>
					<label><%=lang.get(si_module_code)%> <q></q>:</label>
				</div>
<%--				<div class="form-group">--%>
<%--					<input name="error_code" mask="number" r="1" class="form-control">--%>
<%--					<label><%=lang.get(si_error_code)%> <q></q>:</label>--%>
<%--				</div>--%>
			</div>
			<div style="display:grid;grid-template-columns:2fr ;gap:5px">
				<div class="form-group">
					<input name="description" r="1" mask="50|" class="form-control">
					<label><%=lang.get(si_description)%> <q></q>:</label>
				</div>
				<!-- <div class="form-group">
					<input name="label_description" class="form-control">
					<label><%=lang.get(si_lang11)%>:</label>
				</div> -->
			</div>
			<div style="display:grid;grid-template-columns:2fr;gap:5px">
				<div class="form-group">
					<input name="field_hint" mask="50|" class="form-control">
					<label><%=lang.get(si_field_hint)%>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:2fr 2fr;gap:5px">
				<div class="form-group">
					<input name="format_string" class="form-control">
					<label><%=lang.get(si_format_string)%>:</label>
				</div>
				<div class="form-group">
					<input name="param_count" mask="number" class="form-control">
					<label><%=lang.get(si_param_count)%>:</label>
				</div>
			</div>
			<div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
				<div class="form-group">
					<input name="message_mask_lang1" mask="120|" class="form-control">
					<label><%=lang.get(si_lang1)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang2" mask="120|" class="form-control">
					<label><%=lang.get(si_lang2)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang3" mask="120|" class="form-control">
					<label><%=lang.get(si_lang3)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang4" mask="120|" class="form-control">
					<label><%=lang.get(si_lang4)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang5" mask="120|" class="form-control">
					<label><%=lang.get(si_lang5)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang6" mask="120|" class="form-control">
					<label><%=lang.get(si_lang6)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang7" mask="120|" class="form-control">
					<label><%=lang.get(si_lang7)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang8" mask="120|" class="form-control">
					<label><%=lang.get(si_lang8)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang9" mask="120|" class="form-control">
					<label><%=lang.get(si_lang9)%>:</label>
				</div>
				<div class="form-group">
					<input name="message_mask_lang10" mask="120|" class="form-control">
					<label><%=lang.get(si_lang10)%>:</label>
				</div>
			</div>
		</form>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
			out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
			out.print("<script>parent.pageLock(false);</script>");
		}
	%></t:request>
</t:requests>
<%!
	static final int si_add_title     = SI("Qo'shish", "Добавление", "Qo'shish", "Adding");
	static final int si_edit_title    = SI("O'zgartirish", "Изменение", "O'zgartirish", "Editing");
	static final int si_save          = SI("Saqlash", "Сохранить", "Saqlash", "Save");
	static final int si_exit          = SI("Chiqish", "Выход", "Chiqish", "Exit");
	static final int si_success       = SI("Muvaffaqiyatli bajarildi!", "Успешно выполнено!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_message_code  = SI("Xabar kodi", "Код сообщения", "Xabar kodi", "Message Code");
	static final int si_module_code   = SI("Modul", "Модуль", "Modul", "Module");
	static final int si_error_code    = SI("Xato kodi", "Код ошибки", "Xato kodi", "Error Code");
	static final int si_description   = SI("Tavsif", "Описание", "Tavsif", "Description");
	static final int si_field_hint    = SI("Field Hint", "", "Maydon bo'yicha yordam matni", "Field Hint");
	static final int si_param_count   = SI("Parametrlar soni", "Количество параметров", "Parametrlar soni", "Parameter Count");
	static final int si_format_string = SI("Format qatori", "Строка формата", "Format qatori", "Format String");
	static final int si_lang1 = SI("Русский", "Ruscha", "Русча", "Russian");
	static final int si_lang2 = SI("Узбекский", "O‘zbekcha", "Ўзбекча", "Uzbek");
	static final int si_lang3 = SI("Узбекский", "O‘zbekcha", "Ўзбекча ", "Uzbek");
	static final int si_lang4 = SI("Английский", "Inglizcha", "Инглизча", "English");
	static final int si_lang5 = SI("Каракалпакский", "Qoraqalpoqcha", "?ора?алпо?ча", "Karakalpak");
	static final int si_lang6 = SI("Таджикский", "Tojikcha", "Тожикча", "Tajik");
	static final int si_lang7         = SI("Lang 7", "Lang 7", "Lang 7", "Lang 7");
	static final int si_lang8         = SI("Lang 8", "Lang 8", "Lang 8", "Lang 8");
	static final int si_lang9         = SI("Lang 9", "Lang 9", "Lang 9", "Lang 9");
	static final int si_lang10        = SI("Lang 10", "Lang 10", "Lang 10", "Lang 10");
	static final int si_lang11        = SI("Label Tavsifi", "Label Desc", "Label Desc", "Label Desc");
%>
<%@ include file="/language.jsp" %>
