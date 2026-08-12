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
%><t:page><t:form title="<%=si_users%>" minWidth="fill" minHeight="fill">
	<script type="text/javascript">
		/* dynamicGrid'da getData(N) dagi N - core_grid_fields.FIELD_ORDER (grid_id=12).
		   select field_order, field_name from core_grid_fields where grid_id = 12 order by field_order. */
		var FO_USER_ID = 1;

		function onSelect() {
			go({
				url: "esbin_rel_methods.jsp?user_id=" + encodeURIComponent(getData(FO_USER_ID)),
				target: parent.esbinRelMethods,
				lock: false
			});
		}
		function onLoad() {
			if (!dataExist()) {
				go({
					url: "esbin_rel_methods.jsp",
					target: parent.esbinRelMethods,
					lock: false
				});
			}
		}
	</script>
	<table class="formToolbar" align="center">
		<tr>
			<td>
			<td id="tableControls" align="right">
		</tr>
		<tr style="display:none">
			<td colspan="2" align="left">
				<b><%=lang.get(si_search)%></b><span id="filterControls"></span>
			</td>
		</tr>
	</table>
	<div class="grid-card">
		<t:dynamicGrid gridId="12" />
	</div>
</t:form>
</t:page>
<%!
	static final int si_users  = SI("Пользователи", "Фойдаланувчилар", "Foydalanuvchilar", "Users");
	static final int si_search = SI("Поиск:", "&#1178;идирув:", "Qidiruv:", "Search:");
%>
<%@ include file="/language.jsp" %>
