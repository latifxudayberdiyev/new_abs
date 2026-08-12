<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<t:page>
	<!DOCTYPE HTML>
	<html lang="ru">
	<head>
		<meta http-equiv="Content-Type" content="text/html;charset=WINDOWS-1251">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<title>MBP</title>
		<link rel="shortcut icon" href="user/util/login/icon/iabs.ico">
		<link rel="stylesheet" href="user/util/login/css/index.css?v=<%= System.currentTimeMillis() %>">
	</head>
	<body>
	<div class="layout">

		<!-- Chap panel -->
		<div class="left">
			<div class="box">
				<!-- Logo + til -->
				<div class="header">
					<div class="logo-wrap">
						<svg class="logo-mark" width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="40" height="40" rx="10" fill="#2563eb"></rect><path d="M12 27V16l8-5 8 5v11" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path><path d="M9 27h22M14 27v-6M20 27v-8M26 27v-6" stroke="#fff" stroke-width="2" stroke-linecap="round"></path></svg>
						<span class="logo-text">SQB</span>
					</div>
					<div class="lang-wrap" id="langWrap">
						<button class="lang-btn" onclick="toggleLang()">
							<img src="user/util/login/img/ru.png" class="lang-flag" id="langFlag" alt="">
							<span id="langLabel">RU</span>
							<span class="chevron"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"></path></svg></span>
						</button>
						<div class="lang-drop">
							<a href="#" data-lang="RU" class="active" onclick="setLang('RU');return false;">
								<img src="user/util/login/img/ru.png" class="lang-flag"> Русский
							</a>
							<a href="#" data-lang="UZ" onclick="setLang('UZ');return false;">
								<img src="user/util/login/img/uz.png" class="lang-flag"> O'zbek
							</a>
							<a href="#" data-lang="EN" onclick="setLang('EN');return false;">
								<img src="user/util/login/img/en.png" class="lang-flag"> English
							</a>
						</div>
					</div>
				</div>

				<!-- Kontent -->
				<div class="content">
					<h1 data-i18n="title">Вход в систему</h1>
					<p class="desc" data-i18n-html="desc">Единая рабочая среда для банковских операций.<br/>Войдите, чтобы продолжить работу.</p>

					<!-- Tablar -->
					<div class="tabs" id="tabsBar">
						<button class="tab active" data-tab="login" data-i18n="login" onclick="switchTab('login')">Логин</button>
						<button class="tab" data-tab="ad" onclick="switchTab('ad')">AD</button>
						<button class="tab" data-tab="dsc" data-i18n="dsc" onclick="switchTab('dsc')">ЭЦП</button>
					</div>

					<!-- LOGIN panel -->
					<div id="panel-login" class="tab-panel active">
						<form onsubmit="return doLogin(event)">
							<div class="error-box" id="loginError"></div>
							<input type="text" id="username" name="u" data-i18n-ph="username" value="super_user" placeholder="Логин" autocomplete="username">
							<div class="pwd-row">
								<div class="pwd-wrap">
									<input type="password" id="password" name="p" data-i18n-ph="password" value="Test12345" placeholder="Пароль"
									       autocomplete="current-password">
									<button type="button" class="eye-btn" onclick="togglePwd()"><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"></path><circle cx="12" cy="12" r="3"></circle></svg></button>
								</div>
								<button type="submit" class="submit-btn" data-i18n="btn">Войти</button>
							</div>
							<button type="button" class="forgot" data-i18n="forgot" onclick="showForgot()">Забыли пароль?</button>
						</form>
					</div>

					<!-- AD panel -->
					<div id="panel-ad" class="tab-panel">
						<div class="indev">
							<div class="indev-icon">&#9881;</div>
							<div data-i18n="indev">В разработке</div>
						</div>
					</div>

					<!-- DSC panel -->
					<div id="panel-dsc" class="tab-panel">
						<div class="indev">
							<div class="indev-icon">&#128274;</div>
							<div data-i18n="indev">В разработке</div>
						</div>
					</div>


					<!-- FORGOT PASSWORD panel -->
					<div id="panel-forgot" class="tab-panel">
						<p class="desc" data-i18n="forgotDesc">Введите логин, и мы отправим инструкцию по восстановлению пароля.</p>
						<div class="error-box" id="forgotError"></div>
						<div class="success-box" id="forgotSuccess" style="display:none"></div>
						<form id="fmForgot" onsubmit="return doForgot(event)">
							<input type="text" id="forgotLogin" data-i18n-ph="username" placeholder="Логин" autocomplete="username">
							<button type="submit" class="submit-btn" data-i18n="forgotSend" style="width:100%">Отправить</button>
						</form>
						<button type="button" class="forgot" data-i18n="forgotBack" onclick="backToLogin()" style="margin-top:14px">Вернуться к входу</button>
					</div>
				</div>

				<div class="footer">&copy; 2026 SANOAT QURILISH BANKI</div>
			</div>
		</div>

		<!-- O'ng panel -->
		<div class="right">
			<img src="user/util/login/img/auth-bg.jpg" alt="">
		</div>

	</div>
	<script>
		// ==== Tarjimalar (i18n) - JS obyekt. Kodlash: WINDOWS-1251 ====
		var I18N = {
			RU: {
				title: "Вход в систему",
				desc: "Единая рабочая среда для банковских операций.<br/>Войдите, чтобы продолжить работу.",
				login: "Логин",
				username: "Логин",
				password: "Пароль",
				btn: "Войти",
				forgot: "Забыли пароль?",
				indev: "В разработке",
				dsc: "ЭЦП",
				empty: "Заполните все поля",
				authFailed: "Ошибка соединения с сервером. Попробуйте ещё раз.",
				forgotDesc: "Введите логин, и мы отправим инструкцию по восстановлению пароля.",
				forgotSend: "Отправить",
				forgotBack: "Вернуться к входу",
				forgotEmpty: "Введите логин"
			},
			UZ: {
				title: "Tizimga kirish",
				desc: "Bank operatsiyalari uchun yagona ish maydoni.<br/>Ishlashni davom ettirish uchun kiring.",
				login: "Login",
				username: "Login",
				password: "Parol",
				btn: "Kirish",
				forgot: "Parolni unutdingizmi?",
				indev: "Ishlab chiqilmoqda",
				dsc: "DSC",
				empty: "Barcha maydonlarni to'ldiring",
				authFailed: "Tizimga ulanishda xatolik. Qaytadan urinib ko'ring.",
				forgotDesc: "Login kiriting, tiklash bo'yicha ko'rsatma yuboramiz.",
				forgotSend: "Yuborish",
				forgotBack: "Kirishga qaytish",
				forgotEmpty: "Login kiriting"
			},
			EN: {
				title: "System Login",
				desc: "Unified workspace for banking operations.<br/>Login to continue working.",
				login: "Login",
				username: "Username",
				password: "Password",
				btn: "Login",
				forgot: "Forgot password?",
				indev: "In development",
				dsc: "DSC",
				empty: "Please fill in all fields",
				authFailed: "Connection error. Please try again.",
				forgotDesc: "Enter your login and we'll send reset instructions.",
				forgotSend: "Send",
				forgotBack: "Back to login",
				forgotEmpty: "Enter your login"
			}
		};

		var curLang = "RU";

		// Tanlangan tilni butun sahifaga qo'llash
		function applyLang(code) {
			var t = I18N[code];
			if (!t) { code = "RU"; t = I18N.RU; }
			curLang = code;

			var i, els;
			els = document.querySelectorAll("[data-i18n]");
			for (i = 0; i < els.length; i++) {
				var k = els[i].getAttribute("data-i18n");
				if (t[k] != null) els[i].textContent = t[k];
			}
			els = document.querySelectorAll("[data-i18n-html]");
			for (i = 0; i < els.length; i++) {
				var kh = els[i].getAttribute("data-i18n-html");
				if (t[kh] != null) els[i].innerHTML = t[kh];
			}
			els = document.querySelectorAll("[data-i18n-ph]");
			for (i = 0; i < els.length; i++) {
				var kp = els[i].getAttribute("data-i18n-ph");
				if (t[kp] != null) els[i].setAttribute("placeholder", t[kp]);
			}

			// Til tugmasi (bayroq + belgi)
			document.getElementById("langLabel").textContent = code;
			document.getElementById("langFlag").src = "user/util/login/img/" + code.toLowerCase() + ".png";

			// Ochilgan ro'yxatda faol holat
			var links = document.querySelectorAll(".lang-drop a");
			for (i = 0; i < links.length; i++) {
				links[i].className = (links[i].getAttribute("data-lang") === code) ? "active" : "";
			}

			document.documentElement.setAttribute("lang", code.toLowerCase());
			try { localStorage.setItem("mbp_lang", code); } catch (e) {}
		}

		function setLang(code) {
			applyLang(code);
			document.getElementById("langWrap").classList.remove("open");
		}

		function switchTab(name) {
			var tabs = document.querySelectorAll(".tab");
			for (var i = 0; i < tabs.length; i++) {
				tabs[i].classList.toggle("active", tabs[i].getAttribute("data-tab") === name);
			}
			var panels = document.querySelectorAll(".tab-panel");
			for (var j = 0; j < panels.length; j++) panels[j].classList.remove("active");
			var p = document.getElementById("panel-" + name);
			if (p) p.classList.add("active");
		}


		function showForgot() {
			document.getElementById("tabsBar").style.display = "none";
			var panels = document.querySelectorAll(".tab-panel");
			for (var j = 0; j < panels.length; j++) panels[j].classList.remove("active");
			document.getElementById("panel-forgot").classList.add("active");
			document.getElementById("forgotError").style.display = "none";
			document.getElementById("forgotSuccess").style.display = "none";
			document.getElementById("fmForgot").style.display = "flex";
			document.getElementById("forgotLogin").value = "";
		}

		function backToLogin() {
			document.getElementById("tabsBar").style.display = "";
			switchTab("login");
		}

		function doForgot(e) {
			if (e && e.preventDefault) e.preventDefault();
			var login = document.getElementById("forgotLogin").value.trim();
			var err = document.getElementById("forgotError");
			err.style.display = "none";

			if (!login) {
				err.textContent = I18N[curLang].forgotEmpty;
				err.style.display = "block";
				return false;
			}

			var fm = document.getElementById("fmForgot");
			var btn = fm.querySelector(".submit-btn");
			btn.disabled = true;

			var xhr = new XMLHttpRequest();
			xhr.open("POST", "auth_forgot_password.jsp", true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
			xhr.onreadystatechange = function () {
				if (xhr.readyState !== 4) return;
				btn.disabled = false;
				fm.style.display = "none";
				var s = document.getElementById("forgotSuccess");
				s.textContent = xhr.responseText;
				s.style.display = "block";
			};
			xhr.send("u=" + encodeURIComponent(login));
			return false;
		}
		function togglePwd() {
			var p = document.getElementById("password");
			p.type = p.type === "password" ? "text" : "password";
		}

		function toggleLang() {
			document.getElementById("langWrap").classList.toggle("open");
		}

		document.addEventListener("click", function (e) {
			var wrap = document.getElementById("langWrap");
			if (!wrap.contains(e.target)) wrap.classList.remove("open");
		});

		function doLogin(e) {
			if (e && e.preventDefault) e.preventDefault();
			var u = document.getElementById("username").value.trim();
			var p = document.getElementById("password").value;
			var err = document.getElementById("loginError");
			err.style.display = "none";

			if (!u || !p) {
				err.textContent = I18N[curLang].empty;
				err.style.display = "block";
				return false;
			}

			var btn = document.querySelector("#panel-login .submit-btn");
			btn.disabled = true;

			var xhr = new XMLHttpRequest();
			xhr.open("POST", "auth_login.jsp", true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
			xhr.onreadystatechange = function () {
				if (xhr.readyState !== 4) return;
				btn.disabled = false;
				if (xhr.status !== 200) {
					err.textContent = xhr.status + " - " + xhr.statusText;
					err.style.display = "block";
					return;
				}
				if (xhr.getResponseHeader("L") === "U") {
					if (xhr.getResponseHeader("MCP") === "Y") {
						window.location.href = "change_password_first.jsp?u=" + encodeURIComponent(u);
						return;
					}
					window.location.href = "main.jsp?_=" + (new Date()).getTime();
				} else {
					err.textContent = xhr.responseText || I18N[curLang].authFailed;
					err.style.display = "block";
				}
			};
			xhr.send("u=" + encodeURIComponent(u) + "&p=" + encodeURIComponent(p) +
				"&x=" + screen.availWidth + "&y=" + screen.availHeight);
			p = null;
			return false;
		}

		// ==== Boshlang'ich holat: URL ?lang / ?tab yoki localStorage ====
		(function () {
			var qs = new URLSearchParams(location.search);
			var qLang = qs.get("lang");
			var saved = null;
			try { saved = localStorage.getItem("mbp_lang"); } catch (e) {}
			var initLang = (qLang || saved || "RU").toUpperCase();
			if (!I18N[initLang]) initLang = "RU";
			applyLang(initLang);

			var qTab = qs.get("tab");
			if (qTab && document.getElementById("panel-" + qTab)) switchTab(qTab);
		})();
	</script>
	</body>
	</html>
</t:page>
