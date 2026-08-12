<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
	pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String pers_id = stored.execFunction("Core_Env.Pers_Id");
%><t:form emptyForm="">
<style>
.navbut {
	font-family: webdings;
	color: #cd5c5c;
}

.innerList {
	padding-left: 30px;
	display: none;
	width: 100%;
}

.innerList td {
	color: #206e9f;
	font: 12px "Trebuchet MS", Tahoma, Verdana, sans-serif;
	cursor: pointer;
	list-style: circle;
	padding-left: 30px;
}

li {
	cursor:pointer;
	margin-left:-30px;
	font: bold 12px;
	list-style: none;
	width: 100%;
	text-align:left;
}
li:hover {
	margin-left:-20px;
	cursor: pointer;
	color: #FF2626;
}

a {
	color: #13245c;
	font: bold 12px "Trebuchet MS", Tahoma, Verdana, sans-serif;
	text-decoration: none;
}

navbut:hover {
	cursor: pointer;
}

.itemSelected {
	color: white !important;
	filter: progid:DXImageTransform.Microsoft.gradient(startColorstr = '#7abcff', endColorstr = '#4096ee', GradientType = 0);
	border: 1px solid #`;
}

.itemDeselected {
	filter: none;
	border: none;
	color: #206e9f !important;
}
</style>
<div class="main" style="text-align:center">
		<img src="get_image.jsp?id=<%=pers_id%>&image_type=EMP" border=0 width=150 >
<ul><%=
stored.execSelect("select '<li onclick=\"go({url:'''||substr(menu_url,10)||''', target:parent._right, lock:false});\"><span class=navbut>4</span><a>'||label||'</a>' from core_menus_v where task_code = 241 and state='A'")
%></ul>
</div>
</div>
</t:form></t:page>
<%!
	static final int si_account				= SI("Учетный запись","","","");
	static final int si_login					= SI("Логин","","","");
	static final int si_password			= SI("Пароль","","","");
	static final int si_design				= SI("Оформления","","","");
	static final int si_design_new		= SI("Добавит оформления","","","");

//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>