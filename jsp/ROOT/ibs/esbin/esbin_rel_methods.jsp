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
	String userIdParam = request.getParameter("user_id");
	long userId = 0;
	boolean hasUser = false;
	try {
		if (userIdParam != null && !userIdParam.equals("")) {
			userId = Long.parseLong(userIdParam.trim());
			hasUser = true;
		}
	} catch (NumberFormatException ex) {
		hasUser = false;
	}
	String iWhere = hasUser ? (" user_id=" + userId) : " 1=2";
%><t:page><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<script type="text/javascript">
		/* dynamicGrid'da getData(N) dagi N - core_grid_fields.FIELD_ORDER (grid_id=13).
		   select field_order, field_name from core_grid_fields where grid_id = 13 order by field_order. */
		function save() {
			pageLock(true);
			var codes = [];
			if (tdd.d.length == 1) {
				if (tblForm.method_codes.checked) {
					codes.push(tblForm.method_codes.value);
				}
			} else {
				for (var i = 0; i < tdd.d.length; i++) {
					if (tblForm.method_codes[i].checked) {
						codes.push(tblForm.method_codes[i].value);
					}
				}
			}
			AJAX.load({
				POST: {
					request: 'save',
					process_code: 'SAVE_ESBIN_USER_METHODS',
					user_id: "<%=hasUser ? String.valueOf(userId) : ""%>",
					method_codes: codes
				},
				onSuccess: function (d) {
					pageLock(false);
					go({});
				}
			});
		}
		function onLoad() {
			if (!dataExist()) {
				getDOM("bSave").setDisable(true);
			}
		}
	</script><%
		if (!hasUser) {
	%>
	<div style="color:#888;padding:20px;text-align:center;"><%=lang.get(si_pick_user_hint)%></div><%
		} else {
	%>
	<table class="formToolbar" align="center">
		<tr>
			<td><input type="button" id="bSave" onclick="save();" value="<%=lang.get(si_save)%>">
			<td id="tableControls" align="right">
		</tr>
		<tr style="display:none">
			<td colspan="2" align="left">
				<b><%=lang.get(si_search)%></b><span id="filterControls"></span>
			</td>
		</tr>
	</table>
	<div class="grid-card">
		<t:dynamicGrid gridId="13" where="<%=iWhere%>" />
	</div><%
		}
	%>
</t:form>
</t:page>
<t:requests>
	<t:request name="save" responseType="text"><%
		try {
			stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
			out.print("OK");
		} catch (Exception ex) {
			response.setHeader("RT", "alert");
			out.print(Util.getUserMessage(ex));
		}
	%></t:request>
</t:requests>
<%!
	static final int si_title          = SI("Методы пользователя", "Фойдаланувчи методлари", "Foydalanuvchi metodlari", "User methods");
	static final int si_pick_user_hint = SI("Выберите пользователя слева.", "Чапдан фойдаланувчини танланг.", "Chapdan foydalanuvchini tanlang.", "Pick a user on the left.");
	static final int si_save           = SI("Сохранить", "Са&#1179;лаш", "Saqlash", "Save");
	static final int si_search         = SI("Поиск:", "&#1178;идирув:", "Qidiruv:", "Search:");
%>
<%@ include file="/language.jsp" %>
