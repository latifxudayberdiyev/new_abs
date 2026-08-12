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
	String versionRuleId = request.getParameter("version_rule_id");
	boolean is_edit = (versionRuleId != null && !versionRuleId.equals(""));
	String parameterId = request.getParameter("parameter_id");
	String parameterLabel = "";
	if (parameterId != null && !parameterId.equals("")) {
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
	}
%><t:page><%
	if (is_edit) {
		try {
			out.println("<script>var data=" + stored.execJsonRequestFunction("Core_Api.Get_Model_Clob", request) + ";</script>");
		} catch (Exception ex) {
			Util.alertUserMessage(ex, out);
		}
	}
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
	<script>
		var OPS = ["=", "!=", ">", "<", ">=", "<=", "BETWEEN", "IN"];

		function opOptionsHtml(sel) {
			var h = "";
			for (var i = 0; i < OPS.length; i++) {
				h += "<option value=\"" + OPS[i] + "\"" + (OPS[i] === sel ? " selected" : "") + ">" + OPS[i] + "</option>";
			}
			return h;
		}

		function paramOptionsHtml(sel) {
			var sel_str = (sel == null) ? "" : String(sel);
			var h = document.getElementById("pfParamOptionsTemplate").innerHTML;
			if (sel_str !== "") {
				h = h.replace("value=\"" + sel_str + "\"", "value=\"" + sel_str + "\" selected");
			}
			return h;
		}

		function toggleValue2(row) {
			var op = row.querySelector(".pfOp").value;
			var v2 = row.querySelector(".pfValue2Wrap");
			v2.style.display = (op === "BETWEEN") ? "" : "none";
		}

		function conditionRowHtml(paramId, op, value, value2) {
			return "" +
				"<div class=\"pfRuleRow\" style=\"display:flex;gap:6px;align-items:center;margin-bottom:6px;\">" +
				"<select class=\"pfParam form-control\" style=\"flex:2;\">" + paramOptionsHtml(paramId) + "</select>" +
				"<select class=\"pfOp form-control\" style=\"flex:1;\" onchange=\"toggleValue2(this.parentNode);\">" + opOptionsHtml(op) + "</select>" +
				"<input class=\"pfValue form-control\" style=\"flex:1;\" value=\"" + (value == null ? "" : esc(value)) + "\">" +
				"<span class=\"pfValue2Wrap\" style=\"flex:1;display:" + (op === "BETWEEN" ? "" : "none") + ";\">" +
				"<input class=\"pfValue2 form-control\" value=\"" + (value2 == null ? "" : esc(value2)) + "\">" +
				"</span>" +
				"<input type=\"button\" value=\"&#8722;\" onclick=\"this.parentNode.remove();\">" +
				"</div>";
		}

		function targetRowHtml(op, value, value2) {
			return "" +
				"<div class=\"pfRuleRow\" style=\"display:flex;gap:6px;align-items:center;margin-bottom:6px;\">" +
				"<select class=\"pfOp form-control\" style=\"flex:1;\" onchange=\"toggleValue2(this.parentNode);\">" + opOptionsHtml(op) + "</select>" +
				"<input class=\"pfValue form-control\" style=\"flex:1;\" value=\"" + (value == null ? "" : esc(value)) + "\">" +
				"<span class=\"pfValue2Wrap\" style=\"flex:1;display:" + (op === "BETWEEN" ? "" : "none") + ";\">" +
				"<input class=\"pfValue2 form-control\" value=\"" + (value2 == null ? "" : esc(value2)) + "\">" +
				"</span>" +
				"</div>";
		}

		function addConditionRow(paramId, op, value, value2) {
			document.getElementById("pfConditionRows").insertAdjacentHTML("beforeend", conditionRowHtml(paramId, op, value, value2));
		}

		function renderTargetRow(op, value, value2) {
			document.getElementById("pfTargetRows").innerHTML = targetRowHtml(op, value, value2);
		}

		function readConditionRow(row) {
			var op = row.querySelector(".pfOp").value;
			var o = {
				parameter_id: Number(row.querySelector(".pfParam").value),
				op: op,
				value: row.querySelector(".pfValue").value
			};
			if (op === "BETWEEN") {
				o.value2 = row.querySelector(".pfValue2").value;
			}
			return o;
		}

		function readTargetRow(row) {
			var op = row.querySelector(".pfOp").value;
			var o = {
				op: op,
				value: row.querySelector(".pfValue").value
			};
			if (op === "BETWEEN") {
				o.value2 = row.querySelector(".pfValue2").value;
			}
			return o;
		}

		function collectRuleJson() {
			var conditions = [];
			document.querySelectorAll("#pfConditionRows .pfRuleRow").forEach(function (row) {
				conditions.push(readConditionRow(row));
			});
			document.fm.condition.value = JSON.stringify(conditions);

			var targetRow = document.querySelector("#pfTargetRows .pfRuleRow");
			document.fm.target.value = targetRow ? JSON.stringify(readTargetRow(targetRow)) : "{}";

			return true;
		}

		function esc(s) {
			return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
		}

		function onLoad() {
<%
	if (is_edit) {
%>
			document.fm.version_rule_id.value = data.version_rule_id;
			document.fm.parameter_id.value = data.parameter_id;
			document.fm.rule_type.value = data.rule_type;
			document.fm.error_message.value = data.error_message;
			document.fm.sort_order.value = data.sort_order;
			document.fm.category_id.value = data.category_id;
<%
	} else {
%>
			document.fm.parameter_id.value = "<%=parameterId==null?"":parameterId%>";
<%
	}
%>
		}
	</script>
	<div id="basepanel" class="panel">
		<iframe name="frm" style="display:none"></iframe>
		<form name="fm" method="post" action="version_rule.jsp?process_code=<%=is_edit?"EDIT_PF_VERSION_RULE":"CREATE_PF_VERSION_RULE"%>" target="frm" onsubmit="return collectRuleJson();">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="version_rule_id" value="">
			<input type="hidden" name="parameter_id" value="">
			<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
			<input type="hidden" name="condition" value="">
			<input type="hidden" name="target" value="">
			<table class="formToolbar" align="center">
				<tr>
					<td>
						<input type="submit" value="<%=lang.get(si_save)%>">
					<td id="tableControls" align="right">
						<input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
			</table>

			<%
				List<Long> catIds = new ArrayList<Long>();
				List<String> catNames = new ArrayList<String>();
				if (parameterId != null && !parameterId.equals("")) {
					PreparedStatement psCat = null;
					ResultSet rsCat = null;
					try {
						psCat = conn.prepareStatement(
							"select ac.CATEGORY_ID as ID, ac.CATEGORY_NAME as NAME from PF_R_ATTRIBUTE_CATEGORIES_V ac " +
							"where ac.ATTRIBUTE_ID = (select p.ATTRIBUTE_ID from PF_R_PARAMETERS_V p where p.ID = ?) " +
							"order by ac.CATEGORY_NAME");
						psCat.setLong(1, Long.parseLong(parameterId));
						rsCat = psCat.executeQuery();
						while (rsCat.next()) {
							catIds.add(rsCat.getLong("ID"));
							catNames.add(rsCat.getString("NAME"));
						}
					} finally {
						if (rsCat != null) rsCat.close();
						if (psCat != null) psCat.close();
					}
				}
			%>
			<div style="display:grid;grid-template-columns:<%=catIds.size()==0?"1fr":"1fr 1fr"%>;gap:5px">
				<div class="form-group filled">
					<div class="form-control" style="background:#f4f4f4;"><%=parameterLabel%></div>
					<label><%=lang.get(si_parameter)%>:</label>
				</div><%
					if (catIds.size() == 1) {
				%>
				<div class="form-group filled">
					<div class="form-control" style="background:#f4f4f4;"><%=esc(catNames.get(0))%></div>
					<input type="hidden" name="category_id" value="<%=catIds.get(0)%>">
					<label><%=lang.get(si_category)%>:</label>
				</div><%
					} else if (catIds.size() > 1) {
				%>
				<div class="form-group">
					<select name="category_id" r="1" class="form-control"><%
						for (int i = 0; i < catIds.size(); i++) {
					%>
						<option value="<%=catIds.get(i)%>"><%=esc(catNames.get(i))%></option><%
						}
					%>
					</select>
					<label><%=lang.get(si_category)%> <q></q>:</label>
				</div><%
					} else {
				%>
				<input type="hidden" name="category_id" value=""><%
					}
				%>
			</div>

			<div style="display:grid;grid-template-columns:1fr;gap:5px">
				<div class="form-group">
					<select name="rule_type" r="1" class="form-control">
						<option value="VALUE_CHECK_IF"><%=lang.get(si_rt_value_check)%></option>
						<option value="FORBIDDEN_IF"><%=lang.get(si_rt_forbidden)%></option>
						<option value="REQUIRED_IF"><%=lang.get(si_rt_required)%></option>
					</select>
					<label><%=lang.get(si_rule_type)%> <q></q>:</label>
				</div>
			</div>

			<div class="section-label"><%=lang.get(si_conditions)%></div>
			<div id="pfConditionRows"></div>
			<input type="button" value="+ <%=lang.get(si_add_condition)%>" onclick="addConditionRow(null,'=','','');">

			<div class="section-label" style="margin-top:12px;"><%=lang.get(si_target)%></div>
			<div id="pfTargetRows"></div>

			<div style="display:grid;grid-template-columns:2fr 1fr;gap:5px;margin-top:10px;">
				<div class="form-group">
					<input name="error_message" r="1" mask="500|" class="form-control">
					<label><%=lang.get(si_error_message)%> <q></q>:</label>
				</div>
				<div class="form-group">
					<input name="sort_order" mask="10|0-9" value="0" r="1" class="form-control">
					<label><%=lang.get(si_sort_order)%>:</label>
				</div>
			</div>
		</form>
		<div id="pfParamOptionsTemplate" style="display:none"><%
			Statement stParam = null;
			ResultSet rsParam = null;
			try {
				String paramSql;
				if (catIds.size() > 0) {
					StringBuilder inList = new StringBuilder();
					for (int i = 0; i < catIds.size(); i++) {
						if (i > 0) inList.append(",");
						inList.append(catIds.get(i));
					}
					paramSql = "select ID, NAME, ATTRIBUTE_NAME from PF_R_PARAMETERS_V where ATTRIBUTE_ID in " +
						"(select ac.ATTRIBUTE_ID from PF_R_ATTRIBUTE_CATEGORIES_V ac where ac.CATEGORY_ID in (" + inList + ")) " +
						"order by ATTRIBUTE_NAME, NAME";
				} else {
					paramSql = "select ID, NAME, ATTRIBUTE_NAME from PF_R_PARAMETERS_V order by ATTRIBUTE_NAME, NAME";
				}
				stParam = conn.createStatement();
				rsParam = stParam.executeQuery(paramSql);
				while (rsParam.next()) {
		%><option value="<%=rsParam.getLong("ID")%>"><%=esc(rsParam.getString("ATTRIBUTE_NAME"))%> / <%=esc(rsParam.getString("NAME"))%></option><%
				}
			} finally {
				if (rsParam != null) rsParam.close();
				if (stParam != null) stParam.close();
			}
		%></div>
		<script>
<%
	if (is_edit) {
%>
			(function () {
				var cond = JSON.parse(data.condition || "[]");
				for (var i = 0; i < cond.length; i++) {
					addConditionRow(cond[i].parameter_id, cond[i].op, cond[i].value, cond[i].value2);
				}
				var tgt = JSON.parse(data.target || "{}");
				renderTargetRow(tgt.op, tgt.value, tgt.value2);
			})();
<%
	} else {
%>
			addConditionRow(null, "=", "", "");
			renderTargetRow("=", "", "");
<%
	}
%>
		</script>
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
	static final int si_add_title      = SI("Добавить правило", "&#1178;оида &#1179;&#1118;шиш", "Qoida qo'shish", "Add rule");
	static final int si_edit_title     = SI("Изменить правило", "&#1178;оидани &#1118;згартириш", "Qoidani o'zgartirish", "Edit rule");
	static final int si_save           = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
	static final int si_success        = SI("Успешно выполнено!", "Муваффа&#1179;иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
	static final int si_exit           = SI("Отмена", "Бекор &#1179;илиш", "Bekor qilish", "Cancel");
	static final int si_parameter      = SI("Параметр", "Параметр", "Parametr", "Parameter");
	static final int si_scope_category = SI("Категория", "Категория", "Kategoriya", "Category");
	static final int si_scope_product  = SI("Продукт", "Ма&#1203;сулот", "Mahsulot", "Product");
	static final int si_category       = SI("Категория", "Категория", "Kategoriya", "Category");
	static final int si_product        = SI("Продукт", "Ма&#1203;сулот", "Mahsulot", "Product");
	static final int si_rule_type      = SI("Тип правила", "&#1178;оида тури", "Qoida turi", "Rule type");
	static final int si_rt_value_check = SI("Проверка значения", "&#1178;иймат текшируви", "Qiymat tekshiruvi", "Value check");
	static final int si_rt_forbidden   = SI("Запрещено, если", "Та&#1179;и&#1179;ланган, агар", "Taqiqlangan, agar", "Forbidden if");
	static final int si_rt_required    = SI("Обязательно, если", "Мажбурий, агар", "Majburiy, agar", "Required if");
	static final int si_conditions     = SI("Условия", "Шартлар", "Shartlar", "Conditions");
	static final int si_add_condition  = SI("Добавить условие", "Шарт &#1179;&#1118;шиш", "Shart qo'shish", "Add condition");
	static final int si_target         = SI("Результат", "Натижа", "Natija", "Target");
	static final int si_error_message  = SI("Сообщение об ошибке", "Хато хабари", "Xato xabari", "Error message");
	static final int si_sort_order     = SI("Порядок", "Тартиб", "Tartib", "Sort order");
%>
<%@ include file="/language.jsp" %>
