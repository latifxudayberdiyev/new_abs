<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" trimDirectiveWhitespaces="true" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
	String usersCount = "-", rolesCount = "-", sessionsActive = "-", loginsToday = "-";
	try { usersCount = stored.execFunction("Core_Dashboard.Users_Count"); } catch (Exception ex) {}
	try { rolesCount = stored.execFunction("Core_Dashboard.Roles_Count"); } catch (Exception ex) {}
	try { sessionsActive = stored.execFunction("Core_Dashboard.Sessions_Active"); } catch (Exception ex) {}
	try { loginsToday = stored.execFunction("Core_Dashboard.Logins_Today"); } catch (Exception ex) {}

	// 7 kunlik kirishlar dinamikasi va hodisalar turi (Core_Dashboard - definer rights,
	// UAPP'ga Auth_Audit_Log'ga to'g'ridan-to'g'ri grant kerak emas).
	String loginsJson = "[]", eventsJson = "[]";
	try { loginsJson = stored.execFunction("Core_Dashboard.Logins_Last7_Json"); } catch (Exception ex) {}
	try { eventsJson = stored.execFunction("Core_Dashboard.Events_By_Type_Json"); } catch (Exception ex) {}
%><t:page>
	<!DOCTYPE HTML>
	<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=WINDOWS-1251">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<style>
			* { margin: 0; padding: 0; box-sizing: border-box; }

			body {
				font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Arial, sans-serif;
				background: #f9fafb;
				padding: 24px;
				color: #111827;
			}

			.dash-title {
				font-size: 20px;
				font-weight: 700;
				color: #111827;
				margin-bottom: 2px;
			}

			.dash-subtitle {
				font-size: 13px;
				color: #9ca3af;
				margin-bottom: 20px;
			}

			.stat-grid {
				display: grid;
				grid-template-columns: repeat(4, 1fr);
				gap: 16px;
				margin-bottom: 16px;
			}

			@media (max-width: 900px) {
				.stat-grid { grid-template-columns: repeat(2, 1fr); }
			}

			.card {
				background: #fff;
				border: 1px solid #f3f4f6;
				border-radius: 16px;
				padding: 20px;
				box-shadow: 0 1px 2px rgba(0, 0, 0, .03);
			}

			.stat-icon {
				width: 40px;
				height: 40px;
				border-radius: 12px;
				display: flex;
				align-items: center;
				justify-content: center;
				margin-bottom: 16px;
			}

			.stat-icon.blue { background: #eff6ff; color: #2563eb; }
			.stat-icon.violet { background: #f5f3ff; color: #7c3aed; }
			.stat-icon.green { background: #f0fdf4; color: #16a34a; }
			.stat-icon.orange { background: #fff7ed; color: #ea580c; }

			.stat-value {
				font-size: 26px;
				font-weight: 700;
				color: #1f2937;
			}

			.stat-label {
				font-size: 13px;
				color: #9ca3af;
				margin-top: 4px;
			}

			.chart-grid {
				display: grid;
				grid-template-columns: 2fr 1fr;
				gap: 16px;
			}

			@media (max-width: 900px) {
				.chart-grid { grid-template-columns: 1fr; }
			}

			.chart-title {
				font-size: 14px;
				font-weight: 600;
				color: #1f2937;
			}

			.chart-subtitle {
				font-size: 12px;
				color: #9ca3af;
				margin: 2px 0 12px;
			}

			.bars {
				height: 220px;
				display: flex;
				align-items: flex-end;
				gap: 10px;
			}

			.bar-col {
				flex: 1;
				display: flex;
				flex-direction: column;
				align-items: center;
				gap: 4px;
			}

			.bar-stack {
				width: 100%;
				display: flex;
				flex-direction: column-reverse;
				justify-content: flex-start;
				height: 180px;
			}

			.bar-ok { background: #2563eb; border-radius: 4px 4px 0 0; }
			.bar-fail { background: #f87171; border-radius: 0 0 0 0; }
			.bar-day { font-size: 11px; color: #9ca3af; }

			.legend { display: flex; gap: 14px; margin-top: 10px; font-size: 12px; color: #6b7280; }
			.legend-dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; margin-right: 5px; }

			.donut-row { display: flex; align-items: center; gap: 16px; }

			.donut-legend { font-size: 12px; color: #374151; }
			.donut-legend div { display: flex; align-items: center; gap: 6px; margin-bottom: 6px; }

			.empty-hint { color: #9ca3af; font-size: 12px; padding: 30px 0; text-align: center; }
		</style>
	</head>
	<body>
	<div class="dash-title"><%= lang.get(si_dash_title) %></div>
	<div class="dash-subtitle"><%= lang.get(si_dash_subtitle) %></div>

	<div class="stat-grid">
		<div class="card">
			<div class="stat-icon blue">&#128101;</div>
			<div class="stat-value"><%= usersCount %></div>
			<div class="stat-label"><%= lang.get(si_dash_users) %></div>
		</div>
		<div class="card">
			<div class="stat-icon violet">&#128737;</div>
			<div class="stat-value"><%= rolesCount %></div>
			<div class="stat-label"><%= lang.get(si_dash_roles) %></div>
		</div>
		<div class="card">
			<div class="stat-icon green">&#9889;</div>
			<div class="stat-value"><%= sessionsActive %></div>
			<div class="stat-label"><%= lang.get(si_dash_sessions) %></div>
		</div>
		<div class="card">
			<div class="stat-icon orange">&#128274;</div>
			<div class="stat-value"><%= loginsToday %></div>
			<div class="stat-label"><%= lang.get(si_dash_logins) %></div>
		</div>
	</div>

	<div class="chart-grid">
		<div class="card">
			<div class="chart-title"><%= lang.get(si_dash_chart1_title) %></div>
			<div class="chart-subtitle"><%= lang.get(si_dash_chart1_sub) %></div>
			<div id="loginsChart" class="bars"></div>
			<div class="legend">
				<span><span class="legend-dot" style="background:#2563eb"></span><%= lang.get(si_dash_ok) %></span>
				<span><span class="legend-dot" style="background:#f87171"></span><%= lang.get(si_dash_fail) %></span>
			</div>
		</div>
		<div class="card">
			<div class="chart-title"><%= lang.get(si_dash_chart2_title) %></div>
			<div class="chart-subtitle"><%= lang.get(si_dash_chart2_sub) %></div>
			<div id="eventsChart" class="donut-row"></div>
		</div>
	</div>

	<script>
		var loginsData = <%= loginsJson %>;
		var eventsData = <%= eventsJson %>;

		(function drawBars() {
			var host = document.getElementById('loginsChart');
			if (!loginsData.length) { host.innerHTML = '<div class="empty-hint">-</div>'; return; }
			var max = 1;
			for (var i = 0; i < loginsData.length; i++) {
				max = Math.max(max, loginsData[i].ok + loginsData[i].fail);
			}
			var html = '';
			for (var i = 0; i < loginsData.length; i++) {
				var d = loginsData[i];
				var okH = Math.round((d.ok / max) * 180);
				var failH = Math.round((d.fail / max) * 180);
				html += '<div class="bar-col"><div class="bar-stack">' +
					'<div class="bar-fail" style="height:' + failH + 'px"></div>' +
					'<div class="bar-ok" style="height:' + okH + 'px"></div>' +
					'</div><div class="bar-day">' + d.d + '</div></div>';
			}
			host.innerHTML = html;
		})();

		(function drawDonut() {
			var host = document.getElementById('eventsChart');
			if (!eventsData.length) { host.innerHTML = '<div class="empty-hint">-</div>'; return; }
			var colors = ['#2563eb', '#7c3aed', '#16a34a', '#ea580c', '#f87171', '#9ca3af'];
			var total = 0;
			for (var i = 0; i < eventsData.length; i++) total += eventsData[i].c;
			var r = 40, cx = 50, cy = 50, circumf = 2 * Math.PI * r, offset = 0;
			var svg = '<svg width="100" height="100" viewBox="0 0 100 100">';
			for (var i = 0; i < eventsData.length; i++) {
				var frac = eventsData[i].c / total;
				var len = frac * circumf;
				svg += '<circle cx="' + cx + '" cy="' + cy + '" r="' + r + '" fill="none" stroke="' +
					colors[i % colors.length] + '" stroke-width="16" stroke-dasharray="' + len + ' ' + circumf +
					'" stroke-dashoffset="' + (-offset) + '" transform="rotate(-90 ' + cx + ' ' + cy + ')"></circle>';
				offset += len;
			}
			svg += '</svg>';
			var legend = '<div class="donut-legend">';
			for (var i = 0; i < eventsData.length; i++) {
				legend += '<div><span class="legend-dot" style="background:' + colors[i % colors.length] +
					'"></span>' + eventsData[i].t + ' (' + eventsData[i].c + ')</div>';
			}
			legend += '</div>';
			host.innerHTML = svg + legend;
		})();
	</script>
	</body>
	</html>
</t:page>
<%!
	static final int si_dash_title = SI("Панель управления", "Бош?арув панели", "Boshqaruv paneli", "Dashboard");
	static final int si_dash_subtitle = SI("Обзор текущего состояния системы", "Тизимнинг жорий ?олати кўриниши", "Tizimning joriy holati ko'rinishi", "Overview of current system state");
	static final int si_dash_users = SI("Пользователи", "Фойдаланувчилар", "Foydalanuvchilar", "Users");
	static final int si_dash_roles = SI("Роли", "Роллар", "Rollar", "Roles");
	static final int si_dash_sessions = SI("Активных сессий", "Актив сессиялар", "Faol sessiyalar", "Active sessions");
	static final int si_dash_logins = SI("Входов сегодня", "Бугунги киришлар", "Bugungi kirishlar", "Logins today");
	static final int si_dash_chart1_title = SI("Входы за последние 7 дней", "Сўнгги 7 кундаги киришлар", "So'nggi 7 kundagi kirishlar", "Logins over the last 7 days");
	static final int si_dash_chart1_sub = SI("Успешные и неудачные попытки входа", "Муваффа?иятли ва муваффа?иятсиз уринишлар", "Muvaffaqiyatli va muvaffaqiyatsiz urinishlar", "Successful and failed login attempts");
	static final int si_dash_chart2_title = SI("События по типу", "?одисалар тури бўйича", "Hodisalar turi bo'yicha", "Events by type");
	static final int si_dash_chart2_sub = SI("Аутентификация, за последние 7 дней", "Аутентификация, сўнгги 7 кун", "Autentifikatsiya, so'nggi 7 kun", "Authentication, last 7 days");
	static final int si_dash_ok = SI("Успешно", "Муваффа?иятли", "Muvaffaqiyatli", "Successful");
	static final int si_dash_fail = SI("Неудачно", "Муваффа?иятсиз", "Muvaffaqiyatsiz", "Failed");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
