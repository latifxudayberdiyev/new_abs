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
%><t:page><t:form emptyForm="">
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta http-equiv="X-UA-Compatible" content="ie=edge">
	<title><%= lang.get(si_clients)%></title>
	<link rel="stylesheet" href="/ibs/user/icons/icons.css" />
	<link rel="stylesheet" href="/ibs/user/font/roboto/css.css" />
	<link rel="stylesheet" href="css/style_cl.css" />
<script>
	var si_prev 	 		= "<%= lang.get(si_prev )%>";
	var si_next 	 		= "<%= lang.get(si_next )%>";
	var si_addres 	 		= "<%= lang.get(si_addres)%>";
	var si_photo	 		= "<%= lang.get(si_photo)%>";
	var si_name	  	 		= "<%= lang.get(si_name)%>";
	var si_type	  	 		= "<%= lang.get(si_type)%>";
	var si_inn	  	 		= "<%= lang.get(si_inn)%>";
	var si_code	  	 		= "<%= lang.get(si_code)%>";
	var si_date_open 		= "<%= lang.get(si_date_open)%>";
	var si_date_end  		= "<%= lang.get(si_date_end)%>";
	var si_no_data_found  	= "<%= lang.get(si_no_data_found)%>";
	var si_passport  		= "<%= lang.get(si_passport)%>";
</script>
</head>
<body>
<div id="waitImage" style="display:none;" >
	<img src="img/ajax-loader6.gif"  alt="Загрузка" id="loadingImage" style="margin:var(--size-50) var(--size-50) var(--size-10) var(--size-50);"/><br>
	<p style="margin-top: var(--size-5);font: var(--size-14) Verdana, sans-serif;font-weight:600;"><%= lang.get(si_loading)%></p>
</div>
	<form>
		<div class="searchbox">
			<div class="breadcrumb-box">
				<nav>
				  <ol class="breadcrumb">
					<li class="breadcrumb-item"><a href="../info.jsp"><%= lang.get(si_panel)%></a></li>
					<li class="breadcrumb-item active" aria-current="page"><%= lang.get(si_clients)%></li>
				  </ol>
				</nav>
			</div>
		
			<div class="button-group">
				<label class="button-group__btn" onclick="selectSubject(this,'ALL')">
					<input type="radio" name="subject" value="ALL" checked>
					<span class="button-group__label">
						<%= lang.get(si_all)%>
					</span>
				</label>
				<label class="button-group__btn" onclick="selectSubject(this,'P')">
					<input type="radio" name="subject" value="P">
					<span class="button-group__label">
						<%= lang.get(si_physic)%>
					</span>
				</label>
				<label class="button-group__btn" onclick="selectSubject(this,'J')">
					<input type="radio" name="subject" value="J">
					<span class="button-group__label">
						<%= lang.get(si_juridic)%>
					</span>
				</label>
			</div>
			<div class="searchbar">
				<div class="button-group grid-buttons">
					<label class="button-group__btn" onclick="selectGridType(this,'WIDGET')">
						<input type="radio" name="grid_type" value="WIDGET" checked>
						<span class="button-group__label">
							<i class="fas fa-th"></i>
						</span>
					</label>
					<label class="button-group__btn" onclick="selectGridType(this,'LIST')">
						<input type="radio" name="grid_type" value="LIST">
						<span class="button-group__label">
							<i class="fas fa-th-list"></i>
						</span>
					</label>
				</div>
			</div>			
		</div>
	</form>
	<form>
		<div class="filterbox">
			<div class="filter-content" id="filter_content">
				<div class="filter-name">
					<input type="text" onkeyup="filtered(this)" id="client_name" name="client_name" placeholder="<%= lang.get(si_name)%>" />
				</div>
				<div class="filter-inn">
					<input type="text" mask="8|0-9" onkeyup="filtered(this)" id="code" name="code" placeholder="<%= lang.get(si_code)%>" />
				</div>
				<div class="filter-inn">
					<input type="text" mask="9|0-9" onkeyup="filtered(this)" id="inn" name="inn" placeholder="<%= lang.get(si_inn)%>" />
				</div>
				<div class="filter-branch">
					<select  id="filial" name="filial" onchange="filtered(this)">
						<option value="" selected><%= lang.get(si_filial)%></option>
						<t:options from="v_filials" code="code_bank" name="name" where="code_type='F' and condition='A'"/>
					</select>
				</div>
				<div class="search-button">
					<button id="search_btn"  onclick="search()" onsubmit="return false" ><%= lang.get(si_search)%></button>
				</div>
			</div>
		</div>
	</form>

	<div class="client-content" id="clients"></div>
	<div class="client-pagination" id="pagination"></div>

	<script src="js/jquery-3.5.1.min.js"></script>
	<script src="js/main.js"></script>
</body>
</html>
</t:form>
</t:page><t:requests>
<t:request name="get_clients" responseType="text"><%
try {
	ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	cs.setFunction("Core_info.Get_Clients_As_Clob");
	cs.setAllParameters("Request");
	cs.execute();
	out.print(cs.getStringResult());
} catch (Exception ex) {
	response.setHeader("RT", "error");
	out.print(Util.getUserMessage(ex));
}
%></t:request>
</t:requests>
<%!
	static final int si_formTitle 		= SI("Инфо","Маълумот","Ma`lumot","");
	static final int si_prev	  		= SI("Предыдущий","Маълумот","Oldingi","Previous");
	static final int si_next      		= SI("Следующий","Маълумот","Keyingi","Next");
	static final int si_addres	  		= SI("Адрес","Манзил","Manzil","");	
	static final int si_photo	  		= SI("Фото","Расм","Rasm","Photo");
	static final int si_name	  		= SI("Имя Фамиля","","","");
	static final int si_type	  		= SI("Тип","Тур","Tur","Type");
	static final int si_inn	      		= SI("ИНН","СТИР","STIR","");
	static final int si_code	  		= SI("Код клиента","Мижоз коди","Mijoz kodi","Client Code");
	static final int si_date_open 		= SI("Дата открытия ","","","");
	static final int si_date_end  		= SI("Дата закрытия ","","","");
	static final int si_passport  		= SI("Пасспорт","","","");
	static final int si_no_data_found   = SI("Данные не найдены","Маьлумот топилмади","Ma'lumot topilmadi","No Data Found");
	static final int si_panel  			= SI("Интерактивная панель","","","");
	static final int si_clients  		= SI("Клиенты","","","");
	static final int si_client  		= SI("Клиент","","","");
	static final int si_loading  		= SI("Подождите, список клиентов загружается...","","","");
	static final int si_all 	 		= SI("Все","","","");
	static final int si_physic  		= SI("Физическое лицо","","","");
	static final int si_juridic  		= SI("Юридическое лицо","","","");
	static final int si_search  		= SI("Поиск","","","");
	static final int si_filial  		= SI("Филиал","","","");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
