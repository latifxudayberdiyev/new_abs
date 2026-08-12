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
%><t:form minWidth="fill" minHeight="fill">
	<script>
		/* dynamicGrid'da getData(N) dagi N - core_grid_fields.FIELD_ORDER (grid_id=10).
		   select field_order, field_name from core_grid_fields where grid_id = 10 order by field_order. */
		var FO_ID = 1;

		function responseModal(r) {
			if (r) {
				go({});
			}
		}
		function add() {
			go({
				url: "version_rule.jsp?process_code=CREATE_PF_VERSION_RULE",
				target: "modalE",
				dialogHeight: 640,
				dialogWidth: 760,
				lock: false,
				callback: responseModal
			});
		}
		function edit() {
			if (!getDOM("bEdit").disabled) {
				go({
					url: "version_rule.jsp?process_code=EDIT_PF_VERSION_RULE",
					param: {
						model_process_code: "MODEL_PF_VERSION_RULE",
						version_rule_id: getData(FO_ID)
					},
					target: "modalE",
					dialogHeight: 640,
					dialogWidth: 760,
					lock: false,
					callback: responseModal
				});
			}
		}
		function del() {
			if (!getDOM("bDelete").disabled) {
				if (confirm("<%=lang.get(si_confirm_delete)%>")) {
					document.getElementById("pfVrDelRelId").value = getData(FO_ID);
					document.fmVrDel.submit();
				}
			}
		}
		function onAction() {
			edit();
		}
		function onLoad() {
			if (!dataExist()) {
				getDOM("bEdit").setDisable(true);
				getDOM("bDelete").setDisable(true);
			}
		}
	</script>
	<table class="formToolbar" align="center">
		<tr>
			<td>
				<input type="button" name="bAdd" onclick="add();" value="<%=lang.get(si_add)%>">
				<input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
				<input type="button" name="bDelete" onclick="del();" value="<%=lang.get(si_delete)%>">
			<td id="tableControls" align="right">
		</tr>
	</table>
	<%-- table.js grid_id=10'da IS_FILTER='Y' maydon (SCOPE_NAME) borligi
	     sababli shu ID'li elementni MAJBURIY talab qiladi, aks holda butun
	     sahifa JS'i "filterControls is not found" xatosi bilan to'xtaydi
	     (2026-08-07, parameters.jsp'da topilgan/tuzatilgan muammo bilan bir
	     xil). --%>
	<span id="filterControls" style="display:none"></span>
	<div class="grid-card">
		<t:dynamicGrid gridId="10" />
	</div>
	<iframe name="frmVrDel" style="display:none"></iframe>
	<form name="fmVrDel" method="post" target="frmVrDel">
		<input type="hidden" name="request" value="delete">
		<input type="hidden" name="process_code" value="DELETE_PF_VERSION_RULE">
		<input type="hidden" name="version_rule_id" id="pfVrDelRelId" value="">
		<input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
	</form>
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
	static final int si_add            = SI("Добавить", "&#1178;&#1118;шиш", "Qo'shish", "Add");
	static final int si_edit           = SI("Изменить", "&#1038;згартириш", "O'zgartirish", "Edit");
	static final int si_delete         = SI("Удалить", "&#1038;чириш", "O'chirish", "Delete");
	static final int si_confirm_delete = SI("Удалить правило?", "&#1178;оидани &#1118;чирасизми?", "Qoidani o'chirasizmi?", "Delete rule?");
%>
<%@ include file="/language.jsp" %>
