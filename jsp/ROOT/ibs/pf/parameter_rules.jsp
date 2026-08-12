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
	String parameterId = request.getParameter("parameter_id");
	String parameterLabel = "";
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<script>
		function responseModal(r) {
			go({});
		}
		function addRule() {
			go({
				url: "version_rule.jsp?process_code=CREATE_PF_VERSION_RULE&parameter_id=<%=parameterId%>",
				target: "modalE",
				dialogHeight: 640,
				dialogWidth: 760,
				lock: false,
				callback: responseModal
			});
		}
		function editRule(id) {
			go({
				url: "version_rule.jsp?process_code=EDIT_PF_VERSION_RULE",
				param: {
					model_process_code: "MODEL_PF_VERSION_RULE",
					version_rule_id: id,
					parameter_id: "<%=parameterId%>"
				},
				target: "modalE",
				dialogHeight: 640,
				dialogWidth: 760,
				lock: false,
				callback: responseModal
			});
		}
		function deleteRule(id) {
			if (confirm("<%=lang.get(si_confirm_delete)%>")) {
				document.getElementById("pfVrDelId").value = id;
				document.fmVrDel.submit();
			}
		}
		function onLoad() {
		}
	</script>
	<div id="basepanel" class="panel">
		<table class="formToolbar" align="center">
			<tr>
				<td>
					<b><%=lang.get(si_parameter)%>:</b> <%=parameterLabel%>
				<td id="tableControls" align="right">
					<input type="button" onclick="addRule();" value="<%=lang.get(si_add)%>">
					<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</tr>
		</table>
		<table class="grid-card" style="width:100%;border-collapse:collapse;">
			<thead>
				<tr>
					<th style="text-align:left;padding:4px;"><%=lang.get(si_scope)%></th>
					<th style="text-align:left;padding:4px;"><%=lang.get(si_rule_type)%></th>
					<th style="text-align:left;padding:4px;"><%=lang.get(si_error_message)%></th>
					<th style="text-align:center;padding:4px;"><%=lang.get(si_sort_order)%></th>
					<th style="padding:4px;"></th>
				</tr>
			</thead>
			<tbody><%
				PreparedStatement psParamName = null;
				ResultSet rsParamName = null;
				try {
					psParamName = conn.prepareStatement("select ATTRIBUTE_NAME, NAME from PF_R_PARAMETERS_V where ID = ?");
					psParamName.setLong(1, Long.parseLong(parameterId));
					rsParamName = psParamName.executeQuery();
					if (rsParamName.next()) {
						parameterLabel = esc(rsParamName.getString("ATTRIBUTE_NAME")) + " / " + esc(rsParamName.getString("NAME"));
					}
				} finally {
					if (rsParamName != null) rsParamName.close();
					if (psParamName != null) psParamName.close();
				}

				PreparedStatement psRules = null;
				ResultSet rsRules = null;
				try {
					psRules = conn.prepareStatement("select ID, SCOPE_TYPE, SCOPE_NAME, RULE_TYPE, ERROR_MESSAGE, SORT_ORDER from PF_VERSION_RULES_V where PARAMETER_ID = ? order by SORT_ORDER");
					psRules.setLong(1, Long.parseLong(parameterId));
					rsRules = psRules.executeQuery();
					boolean any = false;
					while (rsRules.next()) {
						any = true;
						long id = rsRules.getLong("ID");
			%>
				<tr style="border-bottom:1px solid #e0e0e0;">
					<td style="padding:4px;"><%=esc(rsRules.getString("SCOPE_TYPE"))%>: <%=esc(rsRules.getString("SCOPE_NAME"))%></td>
					<td style="padding:4px;"><%=esc(rsRules.getString("RULE_TYPE"))%></td>
					<td style="padding:4px;"><%=esc(rsRules.getString("ERROR_MESSAGE"))%></td>
					<td style="padding:4px;text-align:center;"><%=rsRules.getInt("SORT_ORDER")%></td>
					<td style="padding:4px;white-space:nowrap;">
						<input type="button" value="<%=lang.get(si_edit)%>" onclick="editRule(<%=id%>);">
						<input type="button" value="<%=lang.get(si_delete)%>" onclick="deleteRule(<%=id%>);">
					</td>
				</tr><%
					}
					if (!any) {
			%>
				<tr><td colspan="5" style="padding:10px;color:#888;"><%=lang.get(si_no_rules)%></td></tr><%
					}
				} finally {
					if (rsRules != null) rsRules.close();
					if (psRules != null) psRules.close();
				}
			%>
			</tbody>
		</table>
		<iframe name="frmVrDel" style="display:none"></iframe>
		<form name="fmVrDel" method="post" target="frmVrDel">
			<input type="hidden" name="request" value="delete">
			<input type="hidden" name="process_code" value="DELETE_PF_VERSION_RULE">
			<input type="hidden" name="version_rule_id" id="pfVrDelId" value="">
			<input type="hidden" name="parameter_id" value="<%=parameterId%>">
			<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
		</form>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="delete"><%
		try {
			stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
			out.print("<script>parent.location.reload();</script>");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			Util.alertUserMessage(ex, out);
		}
	%></t:request>
</t:requests>
<%!
	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
	}
	static final int si_title          = SI("Параметр правилалари", "Параметр &#1178;оидалари", "Parametr qoidalari", "Parameter rules");
	static final int si_parameter      = SI("Параметр", "Параметр", "Parametr", "Parameter");
	static final int si_add            = SI("Добавить", "&#1178;&#1118;шиш", "Qo'shish", "Add");
	static final int si_edit           = SI("Изменить", "&#1038;згартириш", "O'zgartirish", "Edit");
	static final int si_delete         = SI("Удалить", "&#1038;чириш", "O'chirish", "Delete");
	static final int si_exit           = SI("Закрыть", "Ёпиш", "Yopish", "Close");
	static final int si_confirm_delete = SI("Удалить правило?", "&#1178;оидани &#1118;чирасизми?", "Qoidani o'chirasizmi?", "Delete rule?");
	static final int si_scope          = SI("Область", "Соха", "Soha", "Scope");
	static final int si_rule_type      = SI("Тип правила", "&#1178;оида тури", "Qoida turi", "Rule type");
	static final int si_error_message  = SI("Сообщение об ошибке", "Хато хабари", "Xato xabari", "Error message");
	static final int si_sort_order     = SI("Порядок", "Тартиб", "Tartib", "Sort order");
	static final int si_no_rules       = SI("Правила не заданы.", "&#1178;оидалар киритилмаган.", "Qoidalar kiritilmagan.", "No rules defined.");
%>
<%@ include file="/language.jsp" %>
