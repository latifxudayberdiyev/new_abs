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

				<!-- Logo -->
				<div class="header">
					<div class="logo-wrap">
						<svg class="logo-mark" width="40" height="40" viewBox="0 0 40 40" fill="none" xmlns="http://www.w3.org/2000/svg">
							<rect width="40" height="40" rx="10" fill="#2563eb"></rect>
							<path d="M12 27V16l8-5 8 5v11" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"></path>
							<path d="M9 27h22M14 27v-6M20 27v-8M26 27v-6" stroke="#fff" stroke-width="2" stroke-linecap="round"></path>
						</svg>
						<span class="logo-text">SQB</span>
					</div>
				</div>

				<!-- Kontent -->
				<div class="content">
					<h1>Восстановление пароля</h1>
					<p class="desc">Введите новый пароль для вашей учётной записи.</p>

					<div class="error-box" id="formError"></div>
					<div id="successBox" class="success-box" style="display:none"></div>

					<form id="fm" onsubmit="return doReset(event)">
						<input type="password" id="password" placeholder="Новый пароль" autocomplete="new-password">
						<input type="password" id="passwordConfirm" placeholder="Подтверждение пароля" autocomplete="new-password">
						<button type="submit" class="submit-btn" id="btnSave" style="width:100%">Сохранить</button>
					</form>
					<button type="button" class="forgot" onclick="location.href='index.jsp'" style="margin-top:14px">Вернуться к входу</button>
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
		var token = new URLSearchParams(location.search).get("token");
		var errorMsgs = {
			empty: "Заполните оба поля",
			mismatch: "Пароли не совпадают",
			weak: "Пароль должен содержать не менее 8 символов, буквы и цифры",
			noToken: "Ссылка недействительна или устарела. Запросите восстановление пароля заново."
		};

		function showError(text) {
			var e = document.getElementById("formError");
			e.textContent = text;
			e.style.display = "block";
		}

		function onLoad() {
			if (!token) {
				showError(errorMsgs.noToken);
				document.getElementById("fm").style.display = "none";
			}
		}

		function doReset(e) {
			if (e && e.preventDefault) e.preventDefault();
			var err = document.getElementById("formError");
			err.style.display = "none";

			if (!token) {
				showError(errorMsgs.noToken);
				return false;
			}

			var p = document.getElementById("password").value;
			var pc = document.getElementById("passwordConfirm").value;

			if (!p || !pc) {
				showError(errorMsgs.empty);
				return false;
			}
			if (p !== pc) {
				showError(errorMsgs.mismatch);
				return false;
			}
			if (p.length < 8 || !/[0-9]/.test(p) || !/[A-Za-z]/.test(p)) {
				showError(errorMsgs.weak);
				return false;
			}

			var btn = document.getElementById("btnSave");
			btn.disabled = true;

			var xhr = new XMLHttpRequest();
			xhr.open("POST", "auth_reset_password.jsp", true);
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded; charset=UTF-8");
			xhr.onreadystatechange = function () {
				if (xhr.readyState !== 4) return;
				btn.disabled = false;
				if (xhr.getResponseHeader("RT") === "success") {
					document.getElementById("fm").style.display = "none";
					var s = document.getElementById("successBox");
					s.textContent = xhr.responseText + " — перенаправляем на вход...";
					s.style.display = "block";
					setTimeout(function () { location.href = "index.jsp"; }, 1800);
				} else {
					showError(xhr.responseText || errorMsgs.noToken);
				}
			};
			xhr.send("token=" + encodeURIComponent(token) + "&p=" + encodeURIComponent(p));
			return false;
		}

		onLoad();
	</script>
	</body>
	</html>
</t:page>
