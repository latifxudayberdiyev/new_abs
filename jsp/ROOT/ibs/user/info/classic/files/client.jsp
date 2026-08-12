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
String client_code = request.getParameter("code");
String subject = request.getParameter("subject");
%><t:form emptyForm="">
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="ie=edge">
  <title><%= lang.get(si_client)%></title>
  <link rel="stylesheet" href="../font/roboto/css.css">
  <link rel="stylesheet" href="css/style_cl.css">
  <script>
  var code="<%= client_code%>";
  var subject = "<%= subject %>";
  </script>
</head>

<body>
	<div class="breadcrumb-box client-breadcrumb" style="margin-top:16px;">
		<nav>
		  <ol class="breadcrumb">
			<li class="breadcrumb-item"><a href="../info_cross.jsp"><%= lang.get(si_panel)%></a></li>
			<li class="breadcrumb-item"><a href="clients.jsp"><%= lang.get(si_clients)%></a></li>
			<li class="breadcrumb-item active" aria-current="page"><%= lang.get(si_client)%></li>
		  </ol>
		</nav>
	</div>
	
	<form>
		<div class="searchbox">
			<div class="client-data">
				<div id="client_name"></div>
			</div>			
			<div class="button-group">
				<label class="button-group__btn">
					<input type="radio" name="client_info" value="ACCOUNT" checked>
					<span class="button-group__label">
						<%= lang.get(si_account)%>
					</span>
				</label>
				<label class="button-group__btn">
					<input type="radio" name="client_info" value="LEAD">
					<span class="button-group__label">
						<%= lang.get(si_lead)%>
					</span>
				</label>
				<label class="button-group__btn" id="card2">
					<input type="radio" name="client_info" value="CARD2">
					<span class="button-group__label">
						<%= lang.get(si_card2)%>
					</span>
				</label>
				<label class="button-group__btn">
					<input type="radio" name="client_info" value="LOAN">
					<span class="button-group__label">
						<%= lang.get(si_loan)%>
					</span>
				</label>
				<label class="button-group__btn">
					<input type="radio" name="client_info" value="DEP">
					<span class="button-group__label">
						<%= lang.get(si_deposit)%>
					</span>
				</label>
				<label class="button-group__btn">
					<input type="radio" name="client_info" value="SV">
					<span class="button-group__label">
						<%= lang.get(si_smart_vist)%>
					</span>
				</label>
				
			</div>		
		</div>
	</form>
	<div class="clients-list">
		<iframe name="client_info" frameborder="0" width="100%" height="100%"></iframe>
	</div>
<script src="js/jquery-3.5.1.min.js"></script>
<script src="js/client.js"></script>
 </body>
</html>
</t:form>
</t:page>
<%!
static final int si_formTitle 	= SI("Инфо","Маълумот","Ma`lumot","");
static final int si_prev	  	= SI("Предыдущий","Маълумот","Oldingi","Previous");
static final int si_next      	= SI("Следующий","Маълумот","Keyingi","Next");
static final int si_addres	  	= SI("Адрес","","","");	
static final int si_photo	  	= SI("Фото","","","");
static final int si_name	  	= SI("Имя Фамиля","","","");
static final int si_type	  	= SI("Тип","","","");
static final int si_inn	      	= SI("ИНН","","","");
static final int si_code	  	= SI("Код клиента","","","");
static final int si_date_open 	= SI("Созданный","","","");
static final int si_date_end  	= SI("Закрыть","","","");
static final int si_card2  		= SI("Картотека","","","");
static final int si_loan  		= SI("Кредиты","","","");
static final int si_lead  		= SI("Проводки","","","");
static final int si_account  	= SI("Счеты","","","");
static final int si_smart_vist  = SI("Пластиковие карточки","","","");
static final int si_deposit  	= SI("Депозиты","","","");
static final int si_panel  		= SI("Интерактивная панель","","","");
static final int si_clients  	= SI("Клиенты","","","");
static final int si_client  	= SI("Клиент","","","");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
