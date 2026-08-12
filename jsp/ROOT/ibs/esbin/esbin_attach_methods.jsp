<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
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
	String userId = request.getParameter("user_id");
%><t:page><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
	<div id="basepanel" class="panel">
		<table class="formToolbar" align="center">
			<tr>
				<td>
				<td id="tableControls" align="right">
					<input type="button" onclick="parent.close();" value="<%=lang.get(si_cancel)%>">
			</tr>
		</table>
		<form name="fm" method="post" action="esbin_attach_methods.jsp?process_code=ATTACH_ESBIN_USER_METHODS" target="frm" onsubmit="return true;">
			<input type="hidden" name="request" value="save">
			<input type="hidden" name="user_id" value="<%=esc(userId)%>">
			<iframe name="frm" style="display:none"></iframe>
			<div class="grid-card" style="max-height:400px;overflow-y:auto;">
				<table style="width:100%;border-collapse:collapse;">
					<thead>
						<tr>
							<th style="padding:6px;width:24px;border-bottom:2px solid #ddd;"></th>
							<th style="text-align:left;padding:6px;border-bottom:2px solid #ddd;"><%=lang.get(si_method)%></th>
							<th style="text-align:center;padding:6px;border-bottom:2px solid #ddd;"><%=lang.get(si_type)%></th>
							<th style="text-align:center;padding:6px;border-bottom:2px solid #ddd;"><%=lang.get(si_sync_type)%></th>
						</tr>
					</thead>
					<tbody><%
						PreparedStatement psMethods = null;
						ResultSet rsMethods = null;
						try {
							psMethods = conn.prepareStatement(
								"select m.METHOD_CODE, m.NAME, m.REQUEST_TYPE, m.SYNCHRONIZE_TYPE " +
								"from ESBIN_R_METHODS_V m " +
								"where m.STATE = 'A' and not exists (" +
								"  select 1 from ESBIN_R_USER_METHOD_REL_V r " +
								"   where r.METHOD_CODE = m.METHOD_CODE and r.USER_ID = ? and r.STATE = 'A') " +
								"order by m.NAME");
							psMethods.setLong(1, Long.parseLong(userId));
							rsMethods = psMethods.executeQuery();
							boolean anyMethod = false;
							while (rsMethods.next()) {
								anyMethod = true;
								String mc = rsMethods.getString("METHOD_CODE");
					%>
						<tr style="border-bottom:1px solid #eee;">
							<td style="padding:6px;text-align:center;">
								<input type="checkbox" name="method_codes" value="<%=esc(mc)%>">
							</td>
							<td style="padding:6px;"><%=esc(rsMethods.getString("NAME"))%> <span style="color:#999;">(<%=esc(mc)%>)</span></td>
							<td style="padding:6px;text-align:center;"><%=esc(rsMethods.getString("REQUEST_TYPE"))%></td>
							<td style="padding:6px;text-align:center;"><%=esc(rsMethods.getString("SYNCHRONIZE_TYPE"))%></td>
						</tr><%
							}
							if (!anyMethod) {
					%>
						<tr><td colspan="4" style="padding:10px;color:#888;"><%=lang.get(si_no_methods)%></td></tr><%
							}
						} finally {
							if (rsMethods != null) rsMethods.close();
							if (psMethods != null) psMethods.close();
						}
					%>
					</tbody>
				</table>
			</div>
			<div style="padding:8px;">
				<input type="submit" value="<%=lang.get(si_attach)%>">
			</div>
		</form>
	</div>
</t:form>
</t:page>
<t:requests>
	<t:request name="save"><%
		try {
			stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
			out.print("<script>parent.returnValue=true;parent.close();</script>");
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
	static final int si_title      = SI("Прикрепить методы", "Метод бириктириш", "Metod biriktirish", "Attach methods");
	static final int si_cancel     = SI("Отмена", "Бекор &#1179;илиш", "Bekor qilish", "Cancel");
	static final int si_method     = SI("Метод", "Метод", "Metod", "Method");
	static final int si_type       = SI("Тип", "Тури", "Turi", "Type");
	static final int si_sync_type  = SI("Синхр.", "Синхр.", "Sinx.", "Sync");
	static final int si_no_methods = SI("Нет доступных методов для прикрепления.", "Бириктириш учун методлар й&#1118;&#1179;.", "Biriktirish uchun metodlar yo'q.", "No methods available to attach.");
	static final int si_attach     = SI("Прикрепить", "Бириктириш", "Biriktirish", "Attach");
%>
<%@ include file="/language.jsp" %>
