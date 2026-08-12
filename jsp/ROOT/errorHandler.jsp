<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" isErrorPage="true" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	int langIndex = user.getLanguageIndex();
	if (langIndex == -1)
		langIndex = 1;
	Language lang = new Language(langIndex, sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><%
	String supportBrowser = request.getParameter("support_browser");
	String themeId = (String) session.getValue("ibs.cms.themeId");
	String themeUrl = (String) session.getValue("ibs.cms.themeUrl");
	String cssName = "cross", imgExt = ".svg", mode = "";
	if (themeId == null) {
		themeId = "0";
	}
	if (themeUrl == null) {
		themeUrl = "theme_FIDO";
	}
	if ("2".equals(themeId)) {
		mode = "_dark";
	}
	if (!Util.isCross(request)) {
		cssName = "ie";
		imgExt = ".png";
		themeUrl = "theme_FIDO";
	}
	mode += imgExt;
	String url = "";
	String hasFBSD = "N";
//    -----------------------------
	//   if (stored.isDebug()) {
	//       throw new JspException(exception);
	//   }
//    -----------------------------

	try {
		url = pageContext.getErrorData().getRequestURI();
	} catch (Exception e) {
		url = "";
	}
	try {
		hasFBSD = stored.execFunction("Core_Menu.Has_Fbsd");
	} catch (Exception e) {
		hasFBSD = "N";
	}
	int status = response.getStatus();
%>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title><%=lang.get(si_error)%>
	</title>
	<link rel="stylesheet" href="/ibs/user/font/inter/inter.css" />
	<link rel="stylesheet" type="text/css" href="/themes/<%= themeUrl+(Util.isCross(request)?"_cross":"") %>.css" />
	<link id="ie" rel="stylesheet" type="text/css" href="/ibs/user/util/errorHandler/css/<%= cssName %>.css" />
</head>
<body onload="onLoad()">
<script>
	var urlJSP = "<%=  url %>";
	var statusCode = "<%= status %>";
</script>
<style>
	#waitImage {
		position: absolute;
		width: 100%;
		height: 100%;
		text-align: center;
		background: url("/ibs/user/util/errorHandler/icons/pattern.png");
		z-index: 99999999;
	}

	#waitImage p {
		font-family: Verdana, sans-serif;
		font-size: 12px;
		margin: 8px auto;
	}
</style>
<div id="waitImage" style="display:none;"></div>
<div id="basepanel" class="panel">
	<div id="myModal" class="modal">
		<div id="modal-contents" class="modal-contents">
			<div class="closediv">
				<h2><%=lang.get(si_error)%>
				</h2>
				<span id="close" class="close" onclick="spanFunc()">&times;</span>
			</div>
			<div id="tableDiv" class="tableDiv">
				<table width="100%" border="1" style=" border-collapse: collapse;">
					<tbody>
					<tr valign="top">
						<td style="overflow-wrap: anywhere;" id="errorText"><%=  url %> ~ <%= exception %>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<div id="pageNotFound" class="pageNotFound" style="width:100%;">
		<div class="pulse">
			<% if (supportBrowser != null) { %>
			<img class="png_svg" style="width:8rem;"
			     src="/ibs/user/util/errorHandler/icons/support_browser<%= mode %>" />
			<% } else {%>
			<img class="png_svg"
			     src="/ibs/user/util/errorHandler/icons/error<%= ((status== 404)?"_404":"") + mode %>" />
			<% }%>
		</div>
		<% if (supportBrowser != null) {%>
		<span style="text-align:center"> <%=lang.get(si_supportB_A)%></span>
		<p><%= lang.get(("C".equals(supportBrowser) ? si_supportB_C : si_supportB_I))%>
		</p>
		<% } else { %>
		<span
			style="text-align:center"><%= lang.get(((status == 404) ? si_message_404 : si_message)) + ((status == 404) ? "<br/>" + url : "") %></span>
		<% }%>
		<div>
			<% if (status != 404 && supportBrowser == null) { %>
			<a class="more" style="margin:10px" id="myBtn" onclick="btnFunc()"><%= lang.get(si_more) %>
			</a>
			<% } %>
			<% if (supportBrowser == null && "Y".equals(hasFBSD)) { %>
			<a class="more" style="margin:10px" id="myBtn2" onclick="sendERROR()"><%= lang.get(si_error_btn_txt)%>
			</a>
			<% } %>
		</div>
	</div>
</div>
<script src="/ibs/user/util/errorHandler/js/script.js"></script>
</body>
</html>
<%!

	static final int si_title = SI("Обработки ошибок", "Хатоларни бош&#1179;ариш", "Xatolarni boshqarish", "Error handling");
	static final int si_message = SI("На странице произошла ошибка, <br> извините за неудобства", "Са&#1203;ифада хатолик юз берди, но&#1179;улайлик учун узр", "Sahifada xatolik yuz berdi, noqulaylik uchun uzr", "There was an error on the page, sorry for the inconvenience");
	static final int si_message_404 = SI("К сожалению, нам не удалось <br> найти страницу.", "Kechirasiz, sahifani topa olmadik.", "Кечирасиз, са&#1203ифани топа олмадик.", "Sorry, we couldn't find the page.");
	static final int si_error = SI("Ошибка", "Хато", "Xato", "Error");
	static final int si_supportB_C = SI("Данный модуль работает в других браузерах, <br> кроме Internet Explorer! <br> Приносим свои извинения за неудобства.", "Ushbu modul Internet Explorerdan tashqari  <br> boshqa brauzerlarda ishlaydi!  <br> Noqulaylik uchun uzr so'raymiz.", "Ушбу модул Интернет Ехплорердан таш?ари  <br> бош?а браузерларда ишлайди!  <br> Но?улайлик учун узр сўраймиз.", "This module works in other browsers  <br> besides Internet Explorer!  <br> We are sorry for the inconvenience.");
	static final int si_supportB_I = SI("Данный модуль работает только <br> в Internet Explorer! <br> Приносим свои извинения за неудобства.", "Ushbu modul faqat <br> Internet Explorer-da ishlaydi! <br> Noqulaylik uchun uzr so'raymiz.", "Ушбу модул фа?ат <br> Интернет Ехплорер-да ишлайди! <br> Но?улайлик учун узр сўраймиз.", "This module works only <br> in Internet Explorer! <br> We are sorry for the inconvenience.");
	static final int si_supportB_A = SI("Ваш браузер не поддерживает этот модуль.", "Sizning brauzeringiz ushbu modulni qo'llab-quvvatlamaydi.", "Сизнинг браузерингиз ушбу модулни ?ўллаб-?увватламайди.", "Your browser does not support this module.");
	static final int si_more = SI("Подробнее", "К&#254;про&#1179;", "Ko'proq", "More");
	static final int si_error_btn_txt = SI("Отправить ошибку", "Хатоликни ж&#1263;натиш", "Xatolikni jo'natish", "Send the error");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>