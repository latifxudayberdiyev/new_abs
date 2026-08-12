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
	user.putValue("formJsUrl", "form");
	user.putValue("tableJsUrl", "table");
	String bxmCode = (String) session.getValue("bxmCode");
	String filialCode = Util.nvl(user.getFilialCode(), "");

	if (!filialCode.equals(bxmCode) && (bxmCode != null)) filialCode = bxmCode;
%><t:page><%
	String serverApi = (String) session.getValue("server.ip");
	Hashtable userCache = new Hashtable();
	session.putValue(Resource.STR_USER_CACHE, userCache);
	String allowed24x7 = "N", isFutureOperDay = "N", num_of_logins = "", hasFBSD = "N", hasServerIp = "N";
	session.putValue("oldOperDay", session.getValue("operDay"));

	try {
		hasServerIp = "N";
	} catch (Exception ex) {
	}

	String drawIpAddress = "";
	if ("Y".equals(hasServerIp)) {
		drawIpAddress = "<span style='display:inline-block; font-weight:500'> &nbsp; | &nbsp;(IP-адрес: " + serverApi + ")</span>";
	}

%><t:form minWidth="fill" minHeight="fill" emptyForm=""><%
	String employee = "<span><b id='filialcode'>" + filialCode + "(" + user.getLocalCode() + ")" + " / " + user.getUserCode() + "</b>" + drawIpAddress + "</span>" + user.getUserName();

	try {
		allowed24x7 = "N";
	} catch (Exception ex) {
	}
	try {
		isFutureOperDay = "N";
	} catch (Exception ex) {
	}
	try {
		hasFBSD = "N";
	} catch (Exception ex) {
	}

%>
	<link rel="stylesheet" type="text/css" href="/ibs/user/css/main-shell.css?v=<%= System.currentTimeMillis() %>" />
	<% if (Util.isCross(request)) {%>
	<link rel="stylesheet" type="text/css" href="/ibs/user/util/toast/beautyToast.css" />
	<%}%>
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
		top.user_code = "<%=user.getUserCode() %>";
		var serverApi = "<%=serverApi%>";

		function _t() {
			return window;
		}

		<% if(!Util.isCross(request)){ %>
		<%=(String)user.getValue("signFunction")%>
		<% } %>

		function calendarAndLang() {
			changeLangImg("");
		}

		_.title = "CROBS - 2";//<%= lang.get(si_iabs)%>
	</script>
	<% if (Util.isCross(request)) {%>
	<script type="text/javascript" src="/ibs/user/util/toast/beautyToast.js"></script>
	<%}%>
	<script type="text/javascript" src="/ibs/user/js/main.js"></script>

	<!-- ================= SQB app-shell ================= -->
	<div class="app" id="cnt">

		<!-- Brand (logo + collapse) -->
		<div class="brand">
			<svg class="logo-mark" width="28" height="28" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="40" height="40" rx="10" fill="#2563eb"></rect><path d="M12 27V16l8-5 8 5v11" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path><path d="M9 27h22M14 27v-6M20 27v-8M26 27v-6" stroke="#fff" stroke-width="2" stroke-linecap="round"></path></svg>
			<span class="brand-name">SQB</span>
			<button class="icon-btn collapse-btn" onclick="toggleSidebar()" title="Menyuni yig'ish">
				<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"></rect><path d="M9 3v18"></path></svg>
			</button>
		</div>

		<!-- Topbar -->
		<div class="topbar">
			<button class="icon-btn burger" onclick="toggleMobileSidebar()" title="Menyu">
				<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 6h16M4 12h16M4 18h16"></path></svg>
			</button>
			<div class="breadcrumb">
				<span>Страницы</span>
				<span class="crumb-sep">&rsaquo;</span>
				<span id="formTitle" class="crumb-cur">Dashboard</span>
			</div>
			<div id="formcode" style="display:none"></div>
			<div class="spacer"></div>

			<button class="icon-btn notify-btn" onclick="void 0" title="Bildirishnomalar">
				<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"></path><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"></path></svg>
				<span class="badge" id="notify_count" data-count=""></span>
			</button>
			<span id="message_count" style="display:none"></span>

			<div class="user-box" onclick="toggleSettings()">
				<span class="user-avatar" id="userAvatar" style="display:flex;align-items:center;justify-content:center;font-size:12px;font-weight:700;color:#374151"><%= Util.nvl(user.getUserName(), "?").trim().length() > 0 ? user.getUserName().trim().substring(0,1).toUpperCase() : "?" %></span>
				<span class="user-name"><%= user.getUserName() %></span>
			</div>
			<span id="employee" style="display:none"><%= employee %></span>
		</div>

		<!-- Sidebar -->
		<div class="sidebar" id="sidebar">
			<nav class="side-menu" id="sidebarMenu"></nav>
			<div class="side-footer">
				<button class="mi" onclick="toggleSettings()">
					<span class="mi-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg></span>
					<span class="mi-label"><%= lang.get(si_settings) %></span>
				</button>
				<button class="mi" onclick="logout()">
					<span class="mi-icon"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path><path d="M16 17l5-5-5-5"></path><path d="M21 12H9"></path></svg></span>
					<span class="mi-label"><%= lang.get(si_exit) %></span>
				</button>
			</div>
		</div>

		<!-- Main -->
		<div class="main">
			<iframe width="100%" height="100%" marginheight="0" frameborder="0" name="contents" src="/ibs/user/util/dashboard/dashboard.jsp"></iframe>
		</div>

		<div class="side-overlay" onclick="toggleMobileSidebar()"></div>
	</div>

	<!-- main.js talab qiladigan yordamchi elementlar (yashirin) -->
	<div id="showhide" class="showhide"></div>
	<div id="rightmenu" style="display:none;"></div>
	<textarea id="for_copy" style="position:absolute;left:-9999px;top:-9999px"></textarea>
	<div id="msg" style="display:none"></div>

	<%
		int curLang = user.getLanguageIndex();
	%>
	<!-- Sozlamalar (til) paneli -->
	<div id="settingsOverlay" onclick="toggleSettings()"></div>
	<div id="settingsPanel">
		<h3><%= lang.get(si_lang_title) %></h3>
		<div class="lang-option<%= (curLang == 1) ? " active" : "" %>" onclick="changeLanguage(1)">
			<img src="/ibs/user/img/lang_rus.png" alt="RU" /><span>Русский</span>
		</div>
		<div class="lang-option<%= (curLang == 2) ? " active" : "" %>" onclick="changeLanguage(2)">
			<img src="/ibs/user/img/lang_uzc.png" alt="UZC" /><span>Ўзбекча (кирил)</span>
		</div>
		<div class="lang-option<%= (curLang == 3) ? " active" : "" %>" onclick="changeLanguage(3)">
			<img src="/ibs/user/img/lang_uzl.png" alt="UZL" /><span>O'zbekcha (lotin)</span>
		</div>
		<div class="lang-option<%= (curLang == 4) ? " active" : "" %>" onclick="changeLanguage(4)">
			<img src="/ibs/user/img/lang_eng.png" alt="EN" /><span>English</span>
		</div>
	</div>

	<script>
		// ================= SQB shell logikasi =================
		var SEP = String.fromCharCode(1);

		// menu_type -> inline SVG ikonka (CSP-safe, CDN yo'q). Default: kvadrat.
		function miIcon(type) {
			var p;
			switch ((type || "").toLowerCase()) {
				case "dashboard": p = '<rect x="3" y="3" width="7" height="7" rx="1"></rect><rect x="14" y="3" width="7" height="7" rx="1"></rect><rect x="3" y="14" width="7" height="7" rx="1"></rect><rect x="14" y="14" width="7" height="7" rx="1"></rect>'; break;
				case "admin": p = '<path d="M12 2 4 6v6c0 5 8 8 8 8s8-3 8-8V6z"></path>'; break;
				case "users": p = '<path d="M16 21v-2a4 4 0 0 0-8 0v2"></path><circle cx="12" cy="7" r="4"></circle>'; break;
				case "book": case "ref": p = '<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path>'; break;
				case "monitor": p = '<path d="M22 12h-4l-3 9L9 3l-3 9H2"></path>'; break;
				case "report": case "chart": p = '<path d="M3 3v18h18"></path><path d="M18 17V9M13 17V5M8 17v-3"></path>'; break;
				default: p = '<circle cx="12" cy="12" r="2.5"></circle>';
			}
			return '<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' + p + '</svg>';
		}

		function chevronSvg() {
			return '<svg class="mi-chevron" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m9 18 6-6-6-6"></path></svg>';
		}

		// Yaproqni iframe'ga yuklaydi + faol holat + breadcrumb
		function openMenuUrl(url, label, el) {
			if (url && url !== "#") {
				var fr = document.getElementsByName("contents")[0];
				if (fr) fr.src = url;
			}
			var act = document.querySelectorAll("#sidebarMenu .mi.active");
			for (var i = 0; i < act.length; i++) act[i].classList.remove("active");
			if (el) el.classList.add("active");
			var ft = document.getElementById("formTitle");
			if (ft && label) ft.textContent = label;
			// mobil rejimda tanlashdan keyin sidebar yopiladi
			if (window.innerWidth <= 768) document.getElementById("cnt").classList.remove("side-open");
		}

		// Bitta tugunni (yaproq yoki guruh) DOM'ga quradi. Label -> textContent (XSS yo'q).
		function buildNode(node) {
			var hasKids = node.children && node.children.length;
			var btn = document.createElement(hasKids ? "button" : "a");
			btn.className = "mi";
			if (!hasKids) { btn.href = "javascript:void(0)"; }

			var ic = document.createElement("span");
			ic.className = "mi-icon";
			ic.innerHTML = miIcon(node.type);
			btn.appendChild(ic);

			var lb = document.createElement("span");
			lb.className = "mi-label";
			lb.textContent = node.label;
			btn.appendChild(lb);

			node.el = btn;

			if (hasKids) {
				btn.insertAdjacentHTML("beforeend", chevronSvg());
				var box = document.createElement("div");
				box.className = "mi-children";
				for (var i = 0; i < node.children.length; i++) box.appendChild(buildNode(node.children[i]));
				btn.onclick = (function (b, x, n) {
					return function () {
						var opening = !b.classList.contains("open");
						b.classList.toggle("open");
						x.classList.toggle("open");
						// guruh ochilganda birinchi ichki band (masalan, Дашборд) avtomatik yuklanadi
						if (opening) {
							var leaf = firstLeaf(n);
							if (leaf && leaf.el) openMenuUrl(leaf.url, leaf.label, leaf.el);
						}
					};
				})(btn, box, node);
				var wrap = document.createElement("div");
				wrap.appendChild(btn);
				wrap.appendChild(box);
				return wrap;
			} else {
				btn.onclick = (function (u, l, b) {
					return function () { openMenuUrl(u, l, b); };
				})(node.url, node.label, btn);
				return btn;
			}
		}

		// Guruh (parent) tugmasi bosilganda ochiladigan birinchi "yaproq" bandni topadi (rekursiv).
		function firstLeaf(node) {
			if (!node.children || !node.children.length) return node;
			return firstLeaf(node.children[0]);
		}

		// AJAX javobidan (get_sidebar_menu) chaqiriladi: 5 maydonli daraxt
		function renderSidebarMenu(items) {
			var host = document.getElementById("sidebarMenu");
			host.innerHTML = "";
			if (!items || !items.length) return;

			var byId = {}, roots = [], order = [];
			for (var i = 0; i < items.length; i++) {
				var f = items[i].split(SEP);
				var n = { id: f[0], parent: f[1], url: f[2] || "#", label: f[3] || "", type: f[4] || "", children: [] };
				byId[n.id] = n;
				order.push(n);
			}
			for (var j = 0; j < order.length; j++) {
				var nd = order[j];
				if (byId[nd.parent]) byId[nd.parent].children.push(nd);
				else roots.push(nd);
			}
			for (var r = 0; r < roots.length; r++) host.appendChild(buildNode(roots[r]));
		}

		function getSidebarMenu() {
			AJAX.load({POST: {request: "get_sidebar_menu"}});
		}

		// Collapse (desktop)
		function toggleSidebar() {
			var app = document.getElementById("cnt");
			app.classList.toggle("collapsed");
			try { localStorage.setItem("mbp_side_collapsed", app.classList.contains("collapsed") ? "1" : "0"); } catch (e) {}
		}

		// Off-canvas (mobil)
		function toggleMobileSidebar() {
			document.getElementById("cnt").classList.toggle("side-open");
		}

		// Til / sozlamalar paneli
		function toggleSettings() {
			var p = getDOM("settingsPanel"), o = getDOM("settingsOverlay");
			var open = p.classList.contains("open");
			p.classList.toggle("open", !open);
			o.style.display = open ? "none" : "block";
		}

		(function initShell() {
			try {
				if (localStorage.getItem("mbp_side_collapsed") === "1" && window.innerWidth > 768)
					document.getElementById("cnt").classList.add("collapsed");
			} catch (e) {}
			getSidebarMenu();
		})();
	</script>
	</body>
	</html>
</t:form>
</t:page>
<%!
	static final int si_lang_title = SI("&#1071;&#1079;&#1099;&#1082; &#1080;&#1085;&#1090;&#1077;&#1088;&#1092;&#1077;&#1081;&#1089;&#1072;", "&#1048;&#1085;&#1090;&#1077;&#1088;&#1092;&#1077;&#1081;&#1089; &#1090;&#1080;&#1083;&#1080;", "Interfeys tili", "Interface language");
%>
<%@ include file="/ibs/user/util/core/main_request.jsp" %>
<%@ include file="/ibs/user/util/core/main_si.jsp" %>
<%@ include file="/language.jsp" %>
