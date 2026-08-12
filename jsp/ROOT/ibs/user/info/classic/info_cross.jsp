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
  String operDay =(String) session.getValue("operDay");
try {
	ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	cs.setFunction("Core_info.Get_Info_Data");
	cs.execute();
	out.print("<script> var info_data = "+cs.getStringResult()+";</script>");
} catch (Exception ex) {
	out.print("<script> var info_data = {};</script>");
	out.print(Util.getUserMessage(ex));
}
%>
<t:form emptyForm="">
<!DOCTYPE html>
<html lang="en">
<head>
	<title><%= lang.get(si_form_title)%></title>
	<link rel="stylesheet" href="/ibs/user/icons/icons.css" />
	<link rel="stylesheet" href="/ibs/user/font/roboto/css.css" />
    <link rel="stylesheet" href="/ibs/user/font/opensans/css.css" />
	<link rel="stylesheet" href="files/css/svgmap.css" />
	<link rel="stylesheet" href="files/css/style.css" />
	<link rel="stylesheet" href="files/css/calendar.css" />
	<link rel="stylesheet" href="files/css/custom-select.css" />
	<link rel="stylesheet" href="files/css/jquery.toast.min.css" />
</head>
<body>
<script>
	var si_selling_rate = "<%= lang.get(si_selling_rate)%>";
	var si_buying_rate = "<%= lang.get(si_buying_rate)%>";
	var si_currency_CB = "<%= lang.get(si_currency_CB)%>";
	var si_form_title = "<%= lang.get(si_form_title)%>";
	var si_not_found_branch = "<%= lang.get(si_not_found_branch)%>";
	var si_no_data_found = "<%= lang.get(si_no_data_found)%>";
</script>
<style>
.for_loader {
	display:flex;
	align-items:center;
	justify-content:center;
}
</style>
	<div class="ipanel">
		<div class="ipanel-top">
			<a href="#">
				<div class="ipt-item" onclick="goClients()">
					<div class="ipt-icon">
						<i class="fas fa-user-friends"></i>
					</div>
					<div class="ipt-value">
						<div class="ipt-title" id="client_cnt"></div>
						<div class="ipt-text"><%= lang.get(si_clients)%></div>
					</div>
				</div>
			</a>
			<a href="#">
				<div class="ipt-item" onclick="goDocument()">
					<div class="ipt-icon">
						<i class="fas fa-folder"></i>
					</div>
					<div class="ipt-value">
						<div class="ipt-title" id="doc_cnt"></div>
						<div class="ipt-text"><%= lang.get(si_docs)%></div>
					</div>
				</div>
			</a>
			<a href="#">
				<div class="ipt-item" onclick="goMessage()">
					<div class="ipt-icon" >
						<i class="fas fa-envelope"></i>
					</div>
					<div class="ipt-value">
						<div class="ipt-title" id="message_cnt"></div>
						<div class="ipt-text"><%= lang.get(si_message)%></div>
					</div>
				</div>
			</a>
				<a onclick="getCalendar({});">
				<div class="ipt-item" id="main-calendar">
					<div class="ipt-icon">
						<i class="far fa-calendar-alt"></i>
					</div>
					<div class="ipt-value">
						<div class="ipt-title" id="time">00:00</div>
						<div class="ipt-text" id="cur_day"><%= operDay %></div>
					</div>
					<div id="calendar"></div>
				</div>
			</a>
			
		</div>
		<div class="ipanel-body">
			<div class="ipb-item" id="currency-list">
				<div class="ipb-title">
					<div class="ipb-icon">
						<i class="fas fa-exchange-alt fa-rotate-90"></i>
					</div>
					<div class="ipb-text">
						<%= lang.get(si_currency) %>
					</div>
				</div>
				<div class="ipb-content" id="cb_currency"></div>
				<div class="icalendar">
					<div class="date-prev" onclick="prevOperDay('currency')">
						<i class="fas fa-angle-left"></i>
					</div>
					<div class="icalendar-input">
						<form><input type="text" id="curr_oper_day" readonly value="<%= operDay %>" mask="date"/></form>
					</div>
					<div class="date-next" onclick="nextOperDay('currency')">
						<i class="fas fa-angle-right"></i>
					</div>
				</div>
			</div>
			  <div class="ipb-item provedennoy-vremya">
				<div class="ipb-title">
					<div class="ipb-icon">
						<i class="far fa-clock"></i>
					</div>
					<div class="ipb-text">
						<%= lang.get(si_working_time)%>
					</div>
				</div>
				<div class="ipb-content" id="time-list">
				</div>
				<div class="ipbc-item" id="timechart">
					<div class="time-chart">
						<div class="time-graphic"></div>
					</div>
				</div>
				<div class="icalendar">
					<div class="date-prev" onclick="prevOperDay('working_time')">
						<i class="fas fa-angle-left"></i>
					</div>
					<div class="icalendar-input">
						<form>
							<input type="text" id="working_day" readonly value="<%= operDay %>" mask="date" />
						</form>
					</div>
					<div class="date-next" onclick="nextOperDay('working_time')">
						<i class="fas fa-angle-right"></i>
					</div>
				</div>
			</div>		
		</div>
		<div class="ipanel-bottom">
			<div class="chart-box" id="chart_box">
				<div class="chart-box-top">
					<div class="chbt-title"><%= lang.get(si_currency) %></div>
					<div class="chbt-select">
						<div class="cdt-icon">
							<img id="currency-img2" src="files/icons/flags/USD.svg"  />
						</div>
						<div class="cdt-title">
							<div class="custom-select2">
								<select id="currency-select2">
									<option value="">Select:</option>
									<option value="EUR">Евро</option>
									<option value="USD" selected>Доллар США</option>
									<option value="RUB">Российский рубль</option>
									<option value="GBP">Английский фунт стерлингов</option>
									<option value="KZT">Казахстанский тенге</option>
									<option value="CHF">Швейцарский франк</option>
									<option value="JPY">Японская иена</option>
								</select>
							</div>
						</div>
					</div>
					<div class="chbt-date">
					<div class="chbt-title">
                                                <i class="far fa-calendar-alt" style="color:#00B374;"></i>
						<b id="begin_date"></b> - 
						<b id="end_date"></b>
                                        </div>
<%--					<!--	January 2018--%>
<%--					<!--	<i class="fas fa-angle-down"></i> <!--fas fa-angle-down-->--%>
					</div>
				</div>
				<div class="chart-box-body">
					<div class="chart-radio" id="chart_radio">
						
					</div>
					<div id="chart-container"></div>
				</div>
			</div>
		</div>
	</div>
	
	<div class="currency-data md-effect">
		<div class="cd-box">
			<div class="cd-top">
				<div class="cdt-icon">
					<img id="currency-img" src="files/icons/flags/USD.svg" />
				</div> 
				<div class="cdt-title">
					<div class="custom-select">
					  <select id="currency-select">
						<option value="">Select:</option>
						<option value="EUR">Евро</option>
						<option value="USD">Доллар США</option>
						<option value="RUB">Российский рубль</option>
						<option value="GBP">Английский фунт стерлингов</option>
						<option value="KZT">Казахстанский тенге</option>
						<option value="CHF">Швейцарский франк</option>
						<option value="JPY">Японская иена</option>
					  </select>
					</div>
				</div>
				<div class="cdt-close">
					<i class="fas fa-times"></i>
				</div>
			</div>
			<div class="cd-content">
				<div class="cdc" id="curr_content">
								
				</div>
				<form>
					<div class="button-group" id="end_sum_btn">
						
					</div>
				</form>
				
				<div class="cdc" id="cross_curs">
					
				</div>
			</div>
			<div class="cd-bottom">
				<button><%= lang.get(si_exit) %></button>
			</div>
		</div>
	</div>
	
	<div class="md-bg"></div>
	<script src="files/js/chart/fusioncharts.js"></script>
	<script src="files/js/chart/fusioncharts.theme.fusion.js"></script>
	<script src="files/js/chart/Data.js"></script>
	<script src="files/js/chart/main.js"></script>	
	<script src="files/js/jquery-3.5.1.min.js"></script>
	<script src="files/js/custom-select.js"></script>
	<script src="files/js/info.js"></script>
	<script src="files/js/jquery.toast.min.js"></script>
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
<t:request name="get_currency" responseType="text"><%
try {
	ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	cs.setFunction("Core_info.Info_Form_As_Json");
	cs.setAllParameters("Request");
	cs.execute();
	out.print(cs.getStringResult());
} catch (Exception ex) {
	response.setHeader("RT", "error");
	out.print(Util.getUserMessage(ex));
}
%></t:request>
<t:request name="get_working_time" responseType="text"><%
try {
	ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	cs.setFunction("Core_info.Get_Working_Time");
	cs.setAllParameters("Request");
	cs.execute();
	out.print(cs.getStringResult());
} catch (Exception ex) {
	response.setHeader("RT", "error");
	out.print(Util.getUserMessage(ex));
}
%></t:request>
<t:request name="get_bank" responseType="text"><%
try {
	ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	cs.setFunction("Core_info.Get_Bank_Data");
	cs.setStringParameter("i_Region_Code","region_code");
	cs.execute();
	out.print(cs.getStringResult());
} catch (Exception ex) {
	response.setHeader("RT", "error");
	out.print(Util.getUserMessage(ex));
}
%></t:request>
<t:request name="get_info_data" responseType="text"><%
try {
	ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	cs.setFunction("Core_info.Get_Info_Data");
	cs.execute();
	out.print(cs.getStringResult());
} catch (Exception ex) {
	response.setHeader("RT", "error");
	out.print(Util.getUserMessage(ex));
}
%></t:request>
<t:request name="get_calendar" responseType="HTML"><%
try {
	ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	cs.setFunction("Core_info.Draw_Calendar");
	cs.setAllParameters("Request");
	cs.execute();
	out.print(cs.getStringResult());
} catch (Exception ex) {
	response.setHeader("RT", "error");
	out.print(Util.getUserMessage(ex));
}
%></t:request>
<t:request name="get_chart_data" responseType="script"><%
try {
	ServletCallableStatement cs = new ServletCallableStatement(stored, request);
	cs.setProcedure("Core_info.Get_Info_For_Chart_arr");
	cs.setAllParameters("Request");
	cs.registerArrayString("o_results");
	cs.execute();
	String[] datas = cs.getArray("o_results");
	StringBuilder result  = new StringBuilder();
	for(String data:datas){
		result.append(data);
	}
//	out.print("drawChartData("+cs.getStringResult()+")");
	out.print("drawChartData("+result.toString()+")");
} catch (Exception ex) {
	response.setHeader("RT", "error");
	out.print(Util.getUserMessage(ex));
}
%></t:request>
</t:requests>
<%!
	static final int si_selling_rate 		= SI("Продажа","Сотиш","Sotish","Selling");
	static final int si_buying_rate  		= SI("Покупка","Сотиб олиш","Sotib olish","Buying");
	static final int si_currency_CB  		= SI("Курс ЦБ","Марказий банк курси","Markaziy bank kursi","Currency of CB");
	static final int si_form_title   		= SI("Интерактивный панел","Интерфаол панели","Interfaol paneli","Interactive panel");
	static final int si_not_found_branch    = SI("В этом регионе не существует филиала","Бу худудда филиаллар мавжуд емас","Bu xududda filiallar mavjud emas","This region is not exist branch");
	static final int si_no_data_found   	= SI("Данные не найдены","Маьлумот топилмади","Ma'lumot topilmadi","No Data Found");
	static final int si_clients   			= SI("Клиенты","Мижозлар","Mijozlar","Clients");
	static final int si_message   			= SI("Сообщении","Хабарлар","Xabarlar","Messages");
	static final int si_docs   				= SI("Документы","Хужжатлар","Xujjatlar","Documents");
	static final int si_info_branch   		= SI("Информация о банках","Банк хакида маьлумот","Bank haqida ma'lumot","Bank Information");
	static final int si_currency   			= SI("Курс валюты","Валюталар курси","Valyuta kursi","Rate currency");
	static final int si_working_time   		= SI("Проведенное время","Уткан вакт","O'tgan vaqt","Spent time");
	static final int si_exit   			    = SI("Выход","Чикиш","Chiqish","Exit");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
