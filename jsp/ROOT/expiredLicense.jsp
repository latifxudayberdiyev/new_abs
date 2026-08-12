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
%>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title><%=lang.get(si_error)%>
	</title>
	<link rel="stylesheet" href="/ibs/user/font/inter/inter.css" />
	<link id="ie" rel="stylesheet" type="text/css" href="/ibs/user/util/license/css/main.css">
</head>
<body onload="onLoad()">
<div id="waitImage" style="display:none;"></div>
<div id="basepanel" class="panel">
	<div id="myModal" class="modal" style="padding-top: 106.6px;">
		<div id="modal-contents" class="modal-contents">
			<div class="closediv">
				<h2>Ошибка
				</h2>
				<span id="close" class="close" onclick="spanFunc()">?</span>
			</div>
			<div id="tableDiv" class="tableDiv">
				<table width="100%" border="1" style=" border-collapse: collapse;">
					<tbody>
					<tr valign="top">
						<td style="overflow-wrap: anywhere;" id="errorText">null ~ null
						</td>
					</tr>
					</tbody>
				</table>
			</div>
		</div>
	</div>
	<div id="pageNotFound" class="pageNotFound" style="width:100%;">
		<div class="pulse">
			<img class="png_svg" style="width:8rem;" src="/ibs/user/util/license/img/bg.png">
		</div>
		<span style="text-align:center"> Срок действия лицензии на модуль истек.</span>
		<p>Свяжитесь с администраторами! <br> Приносим свои извинения за неудобства.
		</p>
		<div></div>
	</div>
</div>
</body>
</html>
<%!
	static final int si_error = SI("Ошибка", "Хато", "Xato", "Error");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>