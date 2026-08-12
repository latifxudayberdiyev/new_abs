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
		/* dynamicGrid'da getData(N) dagi N - core_grid_fields.FIELD_ORDER (grid_id=6).
		   select field_order, field_name from core_grid_fields where grid_id = 6 order by field_order. */
		var FO_ID   = 1;
		var FO_CODE = 2;
		var FO_NAME = 3;

		function responseModal(r) {
			if (r) {
				go({});
			}
		}
		function add() {
			go({
				url: "category.jsp?process_code=CREATE_PF_CATEGORY",
				target: "modalE",
				dialogHeight: 420,
				dialogWidth: 560,
				lock: false,
				callback: responseModal
			});
		}
		function edit() {
			if (!getDOM("bEdit").disabled) {
				go({
					url: "category.jsp?process_code=EDIT_PF_CATEGORY",
					param: {
						model_process_code: "MODEL_PF_CATEGORY",
						code: getData(FO_CODE),
						category_id: getData(FO_ID)
					},
					target: "modalE",
					dialogHeight: 420,
					dialogWidth: 560,
					lock: false,
					callback: responseModal
				});
			}
		}
		function del() {
			if (!getDOM("bDelete").disabled) {
				if (confirm("<%=lang.get(si_confirm_delete)%> \"" + getData(FO_NAME) + "\"?")) {
					document.getElementById("pfCatDelRelId").value = getData(FO_ID);
					document.fmCatDel.submit();
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
		<tr style="display:none">
			<td colspan="2" align="left">
				<b><%=lang.get(si_search)%></b><span id="filterControls"></span>
			</td>
		</tr>
	</table>
	<div class="grid-card">
		<t:dynamicGrid gridId="6" />
	</div>
	<iframe name="frmCatDel" style="display:none"></iframe>
	<form name="fmCatDel" method="post" target="frmCatDel">
		<input type="hidden" name="request" value="delete">
		<input type="hidden" name="process_code" value="DELETE_PF_CATEGORY">
		<input type="hidden" name="category_id" id="pfCatDelRelId" value="">
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
	static final int si_confirm_delete = SI("Удалить категорию", "Категорияни &#1118;чирасизми", "Kategoriyani o'chirasizmi", "Delete category");
	static final int si_search         = SI("Поиск:", "Изланиш:", "Qidiruv:", "Search:");
%>
<%@ include file="/language.jsp" %>
