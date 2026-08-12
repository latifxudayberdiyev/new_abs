<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
	response.setHeader("Cache-Control", "no-store");
	response.setHeader("X-Frame-Options", "DENY");
	user.putValue("formJsUrl", "form_light");
	user.putValue("tableJsUrl", "table_light");
	String bxmCode = (String) session.getValue("bxmCode");
	String filialCode = Util.nvl(user.getFilialCode(), "");
	if (!filialCode.equals(bxmCode) && (bxmCode != null)) filialCode = bxmCode;
%><t:page><%
	String serverApi = (String) session.getValue("server.ip");
	Hashtable userCache = new Hashtable();
	session.putValue(Resource.STR_USER_CACHE, userCache);
	String allowed24x7 = "N", isFutureOperDay = "N", num_of_logins = "", hasFBSD = "N", hasServerIp = "N";
	session.putValue("oldOperDay", session.getValue("operDay"));
	String themeId = (String) session.getValue("ibs.cms.themeId");
	String themeName = "";
	if ("1".equals(themeId)) {
		themeName = "light";
	} else if ("2".equals(themeId)) {
		themeName = "dark";
	}

	try {
		hasServerIp = stored.execFunction("setup.Get_Env(409,'N')");
	} catch (Exception ex) {
	}

	String drawIpAddress = "";
	if ("Y".equals(hasServerIp)) {
		drawIpAddress = "<span style='display:inline-block; font-weight:500'> &nbsp; | &nbsp;(IP-адрес: " + serverApi + ")</span>";
	}

%><t:form minWidth="fill" minHeight="fill" emptyForm=""><%
	String employee = "<span><b id='filialcode'>" + filialCode + "(" + user.getLocalCode() + ")" + " / " + user.getUserCode() + "</b>" + drawIpAddress + "</span>" + user.getUserName();
	try {
		allowed24x7 = stored.execFunction("Core_Ac_24x7_Support_Api.Is_User_Allowed_24x7");
	} catch (Exception ex) {
	}
	try {
		isFutureOperDay = stored.execFunction("setup.is_Future_Yn");
	} catch (Exception ex) {
	}
	try {
		hasFBSD = stored.execFunction("Core_Menu.Has_Fbsd");
	} catch (Exception ex) {
	}
	try {
		if ("09005".equals(user.getHeaderCode())) {
			num_of_logins = stored.execFunction("Hr_Api.Get_Emp_Log_Ins_Count(" + user.getUserCode() + ")");
		}
	} catch (Exception e) {
	}
%>
	<meta name="viewport" content="width=device-width, initial-scale=1" />
	<link rel="shortcut icon" href="/ibs/user/img/iabs.ico" />
	<link rel="stylesheet" type="text/css" href="/ibs/user/font/inter/inter.css" />
	<link rel="stylesheet" type="text/css" href="/ibs/user/css/style_<%=themeName%>_cross.css" />
	<link rel="stylesheet" type="text/css" href="/ibs/user/util/toast/beautyToast.css" />
	<script>
		var sysdate = new Date(<%=stored.execSelect("select to_char(sysdate, 'YYYY, ') || to_number(to_char(sysdate, 'MM') - 1) || ', ' || to_number(to_char(sysdate, 'DD')) || ', ' || to_char(sysdate, 'HH24, MI, SS')from dual")%>).getTime() - new Date().getTime();
		var operday = "<%= (String)session.getValue("operDay") %>";
		var currday = operday;
		var isFutureOperDay = "<%= isFutureOperDay %>";
		var allowed24x7 = "<%= allowed24x7 %>";
		var si_changeOperday = "<%= lang.get(si_changeOperday)%>";
		var si_open = "<%= lang.get(si_open)%>";
		var si_close = "<%= lang.get(si_close)%>";
		var si_video = "<%=lang.get(si_video)%>";
		var si_ask = replaceQGH("<%=lang.get(si_ask)%>");
		var si_not_help_url = replaceQGH("<%=lang.get(si_not_help_url)%>");
		var si_succ_and_next = replaceQGH("<%=lang.get(si_success)%>\n<%=lang.get(si_next)%>");
		var si_ask = replaceQGH("<%=lang.get(si_ask)%>");
		var si_hide = "<%=lang.get(si_hide)%>";
		var si_time = "<%=lang.get(si_time)%>";
		var si_sysdate = "<%=lang.get(si_sysdate)%>";
		var si_favorite = "<%=lang.get(si_favorite)%>";
		var si_report = "<%=lang.get(si_report)%>";
		var si_messages = "<%=lang.get(si_messages)%>";
		var si_info = "<%=lang.get(si_info)%>";
		var si_search = "<%=lang.get(si_search)%>";
		var si_exit = "<%=lang.get(si_exit)%>";
		var COMPILE_OBJECT_MSG = "<%=lang.get(si_compile_object_msg)%>";
		var USER_TIMEOUT_MSG = "<%=lang.get(si_user_timeout_msg)%>";
		var date_interval = "30";
		var num_of_logins = "<%= num_of_logins %>";
		var si_currencies = "<%= lang.get(si_currencies)  %>";
		var si_min_zp_title = "<%= lang.get(si_min_zp_title)  %>";
		var si_transfer_times = ["<%= lang.get(si_mb_title) %>", "<%= lang.get(si_dr_title) %>", "<%= lang.get(si_dk_title) %>"];
		var themeName = "<%= themeName %>";
		top.user_code = "<%=user.getUserCode() %>";

		function _t() {
			return window;
		}

		function calendarAndLang() {
			changeLangImg("");
			<% try {
					if ("Y".equals(stored.execFunction("User_Calendar_Util.Is_Visible")) && !"0".equals(stored.execSelect("select count(*) name from user_calendars_v"))) {
			%>go({url: "user/calendar_main.jsp?is_main=N", target: "modalE", dialogWidth: 1000, lock: false});
			<%
							}
					} catch (Exception ex) {} %>
		}

		_.title = "iABS7 - <%= lang.get(si_iabs)%>";
	</script>
	<style>
		body {
			border: none;
		}

		body, table {
			margin: 0;
			padding: 0;
		}
	</style>
	<script type="text/javascript" src="/ibs/user/util/toast/beautyToast.js"></script>
	<script type="text/javascript" src="/ibs/user/js/main_.js"></script>
	<table cellspacing="0" cellpadding="0" width="100%" height="100%" id="cnt" align="center">
		<tbody>
		<tr id="banner_tr">
			<td>
				<table width="100%" cellspacing="0" cellpadding="0">
					<colgroup>
						<col width="70" />
						<col width="*" />
					</colgroup>
					<tbody>
					<tr>
						<td nowrap>
							<input name="for_copy" value="" style="width:0px;" />
							<span class="mainlogo">
									<img src="/ibs/user/icons/<%=themeName%>/logo.svg"
									     onclick="go({url:'/ibs/user/info/light_dark/info.jsp', target:contents, lock:false});" />
								</span>
						</td>
						<td align="right">
							<div class="header_block">
								<div>
									<div id="formcode" style="display:none"></div>
									<div id="formTitle"></div>
								</div>
								<div id="TXTOPDAY">
									<div class="oper_den_block">
										<div id="oper_den_img">
											<img src="/ibs/user/img/<%=themeName%>/svg/24x7.svg" id="hasopday"
											     onclick="changeOperDen()" class="ico_24x7" />
											<div id="list_operdays" class="list_operdays mainShadow"
											     style="display: none;"></div>
										</div>
										<b id="DS" class="change_operday" title="<%= lang.get(si_oper)%>"></b>
										<div id="opentime" class="opentime mainShadow"></div>
									</div>
								</div>
								<div id="trm_ico">
									<img id="trm_ico_img" class="trm_ico"
									     src="/ibs/user/img/<%=themeName%>/svg/currency.svg" onclick="rightMenu(true)" />
									<div id="rightmenu" class="mainShadow" style="display:none;"></div>
								</div>
								<div id="msg" onclick="chose_one(true)">
									<div class="msg_block">
										<img id="user_image" src="/ibs/user/img/<%=themeName%>/svg/avatar.svg" />
										<b id="employee"><%=employee%>
										</b>
										<%
											try {
												if (!"1".equals(stored.execSelect("select count(*) name from core_virtual_users_v"))) {
													String sql = "select '<div onclick=\"changeUser(this,'''|| user_id ||''','''|| filial_local ||''');\" onmousemove=\"changeClass(this,''move'')\" onmouseout=\"changeClass(this,'''')\" '|| decode(user_id , '" + user.getUserCode() + "', 'style=\"font-weight:bold\"', null)||'><label>'|| filial_local ||'-'|| user_id ||'</label><p>'||position ||'</p></div>' from core_virtual_users_v";
													out.print("<code class='selector mainShadow' style='display:none' id='user_sel' ><div class='selector-top'><input type='text' placeholder='Введите код филиала' class='input-search'  onkeyup='searchUser(this.value)' /></div><div class='selector-bottom'>");
													out.print(stored.execSelect(sql));
													out.print("</div><div class='noUsers' style='display:none'><img src='/ibs/user/img/" + themeName + "/svg/noUsers.svg' /><b>Неверный код филиала</b><p>Пожалуйста, попробуйте ещё раз.</p></div></code>");
													out.print("<img id='user' src='/ibs/user/img/" + themeName + "/svg/select-caret.svg' />");
												}
											} catch (Exception ex) {
												out.print("&nbsp;");
											} %>
									</div>
								</div>
								<div id="theme_buttons" class="selected_<%=themeName%>">
									<div id="btn-day" class="btn-day" onclick="changeTheme('<%=themeId%>', 1);">
										<img
											src="/ibs/user/img/<%=themeName%>/svg/<%=("light".equals(themeName)) ? "day-active" : "day" %>.svg" />
									</div>
									<div id="btn-night" class="btn-night" onclick="changeTheme('<%=themeId%>', 2);">
										<img
											src="/ibs/user/img/<%=themeName%>/svg/<%=("dark".equals(themeName)) ? "night-active" : "night" %>.svg" />
									</div>
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
			</td>
		</tr>
		<tr style="display:none;">
			<td id="tabControls" style="background-color:#EBE9E6;height:10px"></td>
		</tr>
		<tr>
			<td>
				<table width="100%" height="100%" cellspacing="0" border="0">
					<tbody>
					<tr>
						<td class="navigation" id="vertical_menu">
								<span id="side_bar_menu">
									<button class="side-bar-btn" onclick="openNav(this)" title="iABS">
										<img src="user/img/<%=themeName%>/svg/list-flat.svg" class="btn1" alt="iABS"
										     onmouseover="overSvg(this)" onmouseout="outSvg(this)">
									</button>
									<button class="side-bar-btn" onclick="openRecent(this)"
									        title="<%=lang.get(si_favorite)%>">
										<img src="user/img/<%=themeName%>/svg/recent.svg" class="btn1"
										     alt="<%=lang.get(si_favorite)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)">
									</button>
									<button class="side-bar-btn" onclick="openFavourite(this)"
									        title="<%=lang.get(si_shortcut)%>">
										<img src="user/img/<%=themeName%>/svg/favourite.svg" class="btn1"
										     alt="<%=lang.get(si_shortcut)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)">
									</button>
									<button class="side-bar-btn" onclick="openReport(this)"
									        title="<%=lang.get(si_report)%>">
										<img src="user/img/<%=themeName%>/svg/report.svg" class="btn1"
										     alt="<%=lang.get(si_report)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)">
									</button>
									<button class="side-bar-btn" onclick="goChat(this);"
									        title="<%=lang.get(si_messages)%>" style="position:relative">
										<img src="user/img/<%=themeName%>/svg/message.svg" class="btn1"
										     alt="<%=lang.get(si_messages)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)">
										 <span id="message_count" style="display:none"><h3>0</h3></span>
									</button>
			                        <button class="side-bar-btn" onclick="goInfo(this)" title="<%=lang.get(si_info)%>">
										<img src="user/img/<%=themeName%>/svg/info.svg" class="btn1"
										     alt="<%=lang.get(si_info)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)">
									</button>
									<button class="side-bar-btn" onclick="goHelp(this);" title="<%=lang.get(si_help)%>">
										<img src="user/img/<%=themeName%>/svg/help.svg" class="btn1"
										     alt="<%=lang.get(si_help)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)">
									</button>
									<% if ("Y".equals(hasFBSD)) { %>
									<button id="btnFeedback" class="side-bar-btn" onclick="goFeedback()"
									        title="<%=lang.get(si_mlm)%>">
										<img src="user/img/<%=themeName%>/svg/send.svg" class="btn1"
										     alt="<%=lang.get(si_mlm)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)" />
									</button>
									<button id="btnSD" class="side-bar-btn" onclick="goSD(this)"
									        title="<%=lang.get(si_mlm)%>" style="position:relative;">
										<img src="user/img/<%=themeName%>/svg/sd.svg" class="btn1"
										     alt="<%=lang.get(si_mlm)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)">
										<span id="notify_count" style="display:none"><h3>0</h3></span>
									</button>
									<% } %>
									<button class="side-bar-btn" id="pie_button" style="display:none"
									        onclick="goBI(this)" title="<%=lang.get(si_pie)%>">
										<img src="user/img/<%=themeName%>/svg/pie.svg" class="btn1"
										     alt="<%=lang.get(si_pie)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)">
									</button>
									<% if ((!"09062".equals(user.getHeaderCode())) && (!"09002".equals(user.getHeaderCode()))) { %>
										<button class="side-bar-btn" onclick="goElib(this)"
										        title="<%=lang.get(si_documents)%>">
											<img src="user/img/<%=themeName%>/svg/docs.svg" class="btn1"
											     title="<%=lang.get(si_documents)%>" onmouseover="overSvg(this)"
											     onmouseout="outSvg(this)" />
										</button>
									<% } %>
									<hr />
									<button class="side-bar-btn" onclick="goSetting(this)"
									        title="<%=lang.get(si_settings)%>">
										<img src="user/img/<%=themeName%>/svg/settings.svg" class="btn1"
										     title="<%=lang.get(si_settings)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)" />
									</button>
									<!--	<button class="side-bar-btn" onclick="goBPM()" title="<%=lang.get(si_bpm)%>" style="display:none" >
										<img src="user/img/<%=themeName%>/bpm.svg" class="btn1" title="<%=lang.get(si_bpm)%>" />
									</button>-->
									<button class="side-bar-btn logout-vertical" onclick="logout();"
									        title="<%=lang.get(si_exit)%>">
										<img src="user/img/<%=themeName%>/svg/logout.svg" class="btn1"
										     alt="<%=lang.get(si_exit)%>" onmouseover="overSvg(this)"
										     onmouseout="outSvg(this)" />
									</button>
								</span>
						</td>
						<td style="position:relative" class="maincontent">
							<div id="pinContent" style="display:none"></div>
							<div id="mySidenav" class="sidenav">
								<div id="searchForm">
										<span class="openAllMenuItem" onclick="openAllMenuItem()" style="display:none">
											<img src="user/img/<%=themeName%>/svg/add.svg" class="btn2 plus-minus"
											     onmouseover="overSvg(this)" onmouseout="outSvg(this)" />
										</span>
									<span class="openAllMenuItem" onclick="closeAllMenuItem()" style="display:none">
											<img src="user/img/<%=themeName%>/svg/remove.svg" class="btn2 plus-minus"
											     onmouseover="overSvg(this)" onmouseout="outSvg(this)" />
										</span>
									<span class="searchIcon" style="display:none">
											<img src="user/img/<%=themeName%>/svg/search.svg" class="btn2 plus-minus" />
										</span>
									<div id="keyword_menu_content">
										<input type="text" id="keyword_menu" name="keyword_menu" class="keyword_menu"
										       placeholder="<%=lang.get(si_search_smart)%>"
										       onkeyup="search_menu(this.value);" onpaste="search_menu(this.value);"
										       onfocus="input_close();" onblur="" autocomplete="off" />
										<img id="keyword_menu_close"
										     src="/ibs/user/img/<%=themeName%>/svg/close-mini.svg"
										     onclick="clearValue('keyword_menu')" />
									</div>
									<div id="keyword_report_content">
										<input type="text" id="keyword_report" name="keyword_report"
										       class="keyword_report" placeholder="<%=lang.get(si_search_smart)%>"
										       onkeyup="search_menu(this.value);" onpaste="search_menu(this.value);"
										       onfocus="input_close();" onblur="if(this.value == '') search_menu('');"
										       autocomplete="off" />
										<img id="keyword_report_close"
										     src="/ibs/user/img/<%=themeName%>/svg/close-mini.svg"
										     onclick="clearValue('keyword_report')" />
									</div>
									<span class="turnPin" is_smart="N" id="keyword_menu_smart"
									      onclick="smartOnOff('keyword_menu')">
											<img src="user/img/<%=themeName%>/svg/smart-search.svg" class="btn2"
											     placeholder="Включение и выключение умного поиска"
											     onmouseover="overSvg(this)" onmouseout="outSvg(this)" />
										</span>
									<span class="turnPin" is_smart="N" id="keyword_report_smart"
									      onclick="smartOnOff('keyword_report')">
											<img src="user/img/<%=themeName%>/svg/smart-search.svg" class="btn2"
											     placeholder="Включение и выключение умного поиска"
											     onmouseover="overSvg(this)" onmouseout="outSvg(this)" />
										</span>
									<span class="turnPin" open_pin="N" id="turnPin" onclick="turnOnPin(this)">
											<img src="user/img/<%=themeName%>/svg/star.svg" class="btn2"
											     onmouseover="overSvg(this)" onmouseout="outSvg(this)" />
										</span>
									<span class="reset_search" onclick="reset_search()">
											<img src="user/img/<%=themeName%>/svg/chevron-close.svg"
											     class="btn2 plus-minus" onmouseover="overSvg(this)"
											     onmouseout="outSvg(this)" />
										</span>
								</div>
								<div id="iabsDiv">
									<ul id="tree"></ul>
								</div>
								<div id="recentDiv" style="display:none">
									<ul id="recent"></ul>
								</div>
								<div id="reportsDiv" style="display:none">
									<ul id="reports"></ul>
								</div>
							</div>
							<div id="content"></div>
							<iframe width="100%" height="100%" marginheight="0" frameborder="0"
							        name="contents"></iframe>
						</td>
					</tr>
					</tbody>
				</table>
			</td>
		</tr>
		</tbody>
	</table>
	<div id="showhide" class="showhide"></div>
	</body>
	</html>
</t:form>
</t:page>
<%@ include file="/ibs/user/util/core/main_request.jsp" %>
<%@ include file="/ibs/user/util/core/main_si.jsp" %>
<%@ include file="/language.jsp" %>
