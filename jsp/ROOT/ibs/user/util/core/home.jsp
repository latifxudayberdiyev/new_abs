<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String themeId = (String) session.getValue("ibs.cms.themeId");
	String module_code = request.getParameter("module_code");
%><t:form minWidth="fill" minHeight="fill" emptyForm="">
	<script>
		function onLoad() {
			var module_code_str = "<%=module_code%>";
			info(module_code_str);
			//info('ERS');
		}

		function info(module_code_str) {
			ajax.load({
				POST: {
					request: 'get_info',
					module_code: module_code_str
				},
				onSuccess: function (d) {
					let data = eval('(' + d.trim() + ')');
					console.dir(data);
					getDOM("module_name").innerText = data.module_name;
					getDOM("version").innerText = "<%= lang.get(si_vcs) %>" + data.version;
				}
			});
		}
	</script>
	<style>
		#td1 {
		<% if ("2".equals(themeId)) { %> background: #353945 !important;
		<% } %>
		}

		#h33 {
		<% if ("2".equals(themeId)) { %> color: #4b88ef !important;
		<% } %>
		}

		#module_name {
		<% if ("2".equals(themeId)) { %> color: white !important;
		<% } %>
		}

		#version {
		<% if ("2".equals(themeId)) { %> color: white !important;
		<% } %>
		}
	</style>
	<table width="100%" height="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td align=center id="td1"
			    style="vertical-align: middle; font-size:20px;font-family:Courier New; filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#ffffff', EndColorStr='#CCE4F7');background: linear-gradient(to top, #CCE4F7, #fff);">
				<h3 id="h33" style="color:#1263AD"><%= lang.get(si_welcome) %> <%=user.getUserName()%><br>
					<span id="module_name" style="font-size:20px;color:#414141;"></span><br>
					<span id="version" style="font-size:20px;color:#414141;"><%= lang.get(si_vcs) %></span></h3>
	</table>
</t:form>
</t:page><t:requests>
	<t:request name="get_info" responseType="text"><%
		try {
			ServletCallableStatement cs = new ServletCallableStatement(stored, request);
			cs.setFunction("Core_Info.Get_Info_Module");
			cs.setStringParameter("i_module_code", "module_code");
			cs.execute();
			out.print(cs.getStringResult());
		} catch (Exception ex) {
			response.setHeader("RT", "error");
			out.print(ex.toString());
		}
	%></t:request></t:requests>
<%!
	static final int si_welcome = SI("Добро пожаловать, ", "Хуш келибсиз, ", "Xush kelibsiz, ", "Welcome, ");
	static final int si_module_name = SI("Названия модуля: ", "Модул номи: ", "Modul nomi: ", "Module name: ");
	static final int si_vcs = SI("Текущая версия: ", "Жорий версия: ", "Joriy verisiya: ", "Current version: ");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>