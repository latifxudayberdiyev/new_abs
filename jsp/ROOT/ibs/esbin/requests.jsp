<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%><t:page><t:form minWidth="fill" minHeight="fill">
	<script type="text/javascript">
		/* dynamicGrid'da getData(N) dagi N - core_grid_fields.FIELD_ORDER (grid_id=14).
		   select field_order, field_name from core_grid_fields where grid_id = 14 order by field_order. */
		var FO_ID = 1;

		function responseModal(r) {
			go({});
		}
		function openAccess() {
			go({
				url: "user_methods.jsp",
				target: "modalE",
				dialogHeight: Math.max(800, screen.availHeight - 100),
				dialogWidth: Math.max(1500, screen.availWidth - 60),
				lock: false,
				callback: responseModal
			});
		}
		function view() {
			if (!getDOM("bView").disabled) {
				go({
					url: "request_detail.jsp?id=" + getData(FO_ID),
					target: "modalE",
					dialogHeight: 560,
					dialogWidth: 760,
					lock: false
				});
			}
		}
		function onAction() {
			view();
		}
		function onLoad() {
			if (!dataExist()) {
				getDOM("bView").setDisable(true);
			}
		}
	</script>
	<table class="formToolbar" align="center">
		<tr>
			<td>
				<input type="button" onclick="openAccess();" value="<%=lang.get(si_access)%>">
				<input type="button" id="bView" onclick="view();" value="<%=lang.get(si_view)%>">
			<td id="tableControls" align="right">
		</tr>
		<tr style="display:none">
			<td colspan="2" align="left">
				<b><%=lang.get(si_search)%></b><span id="filterControls"></span>
			</td>
		</tr>
	</table>
	<div class="grid-card">
		<t:dynamicGrid gridId="14" />
	</div>
</t:form>
</t:page>
<%!
	static final int si_access = SI("Доступы", "Дост&#1179;лар", "Dostuplar", "Access");
	static final int si_view   = SI("Просмотр", "К&#1118;риш", "Ko'rish", "View");
	static final int si_search = SI("Поиск:", "&#1178;идирув:", "Qidiruv:", "Search:");
%>
<%@ include file="/language.jsp" %>
