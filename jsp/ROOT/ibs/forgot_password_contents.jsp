<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="util" class="iabs.oraUtil" scope="session" />
<jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null) {
		throw new RuntimeException("Соединение с базой данных не установлено!");
	}
//-------------------------------------------------------------------------------------------------
	int TEMP_PASSWORD_EXPIRY_TIME_SEC = Integer.parseInt(stored.execFunction("Core_Setting.Get_Value('CORE_ADM', 'MODULE_BEHAVIOR', 'TEMP_PASSW_TIME', 60, 'N')"));
%>


<t:page>
	<t:form titleText="Форма восстановления пароля">
		<script type="text/javascript">
			var TEMP_PASSWORD_EXPIRY_TIME_SEC = <%=TEMP_PASSWORD_EXPIRY_TIME_SEC%>;
			var codeSent = false;
			var codeSentTime = (new Date()).getTime();

			function onLoad() {
				hideDOM("temp_password_timer");
			}

			function backToIndex() {
				top.go({url: "/ibs/index.jsp"});
			}

			// *****************************************
			// *********** TIMER ***********************
			function timerTic() {
				var now = new Date().getTime();
				var distance = now - codeSentTime;
				var secondsLeft = Math.ceil((TEMP_PASSWORD_EXPIRY_TIME_SEC * 1000 - distance) / 1000);
				setDOMValue("seconds_left", secondsLeft);
			}

			function runTimer() {
				showDOM("temp_password_timer");
				setDOMValue("seconds_left", TEMP_PASSWORD_EXPIRY_TIME_SEC);

				var timerId = setInterval(timerTic, 1000);
				setTimeout(function () {
					clearInterval(timerId);
					setDOMValue("seconds_left", 0);
					alert("Время действия временного пароля истёк.");
					fm.btnSendSMSCode.disabled = false;
				}, TEMP_PASSWORD_EXPIRY_TIME_SEC * 1000);
			}

			// *********** TIMER ***********************
			// *****************************************

			function reset_password() {
				var login = getDOMValue("login");
				var captchaInput = getDOMValue("captchaInput");
				if (login == '') {
					alert("Пожалуйста, введите логин");
					return;
				}
				if (captchaInput == '') {
					alert("Пожалуйста, введите результат (CAPTCHA)");
					return;
				}
				pageLock(true);
				AJAX.load({
					url: "forgot_password.jsp",
					POST: {login: login, captchaInput: captchaInput, request: "set_temp_password"},
					onSuccess: function (data) {
						try {
							var msg = (new String(data)).trim();
							if (msg.startsWith("success")) {
								alert("Если введённый логин существует, в течение <%=TEMP_PASSWORD_EXPIRY_TIME_SEC%> секунд на ваш номер телефона будет отправлен пароль для входа в систему в виде SMS-сообщения. Если сообщение не поступит, пожалуйста, обратитесь в службу поддержки.");
								fm.btnSendSMSCode.disabled = true;
								codeSent = true;
								codeSentTime = new Date().getTime();
								runTimer();
							} else if (msg.startsWith("error")) {
								alert(msg.substring(6)); // "error:" dan keyingi matn
								refreshCaptcha();
								fm.btnSendSMSCode.disabled = false;
							} else {
								alert("Неизвестный ответ от сервера: " + msg);
								refreshCaptcha();
								fm.btnSendSMSCode.disabled = false;
							}
						} catch (e) {
							alert("Ошибка обработки ответа: " + e.message);
							refreshCaptcha();
						} finally {
							pageLock(false);
						}
					},
					onError: function (data) {
						try {
							var msg = (new String(data)).trim();
							if (msg.startsWith("error")) {
								alert(msg.substring(6));
								refreshCaptcha();
								fm.btnSendSMSCode.disabled = false;
							} else {
								alert(msg);
								refreshCaptcha();
								fm.btnSendSMSCode.disabled = false;
							}
						} finally {
							refreshCaptcha();
							fm.btnSendSMSCode.disabled = false;
							pageLock(false);
						}
					}
				});
			}

			function refreshCaptcha() {

				go({});
			}

		</script>
		<table class="formToolbar" align="center">
			<tr>
				<td>
					<button name="btnBack" onclick="backToIndex()">Назад в форму входа</button>
				</td>
		</table>

		<%@ include file="captcha-image.jsp" %>

		<% if (errorMessage != null) { %>
		<p style="color:red; text-align:center"><%= errorMessage %>
		</p>
		<% } else { %>


		<form name="fm" id="fm" style="display: block; margin: 20px auto; width: 600px;">


			<fieldset>
				<legend>Заполните поля</legend>
				<table width="100%">
					<col width="40%">
					<col width="30%">
					<col width="20%" align="left">
					<col width="10%">
					<tr>
						<td>
							<label for="login">Введите ваш логин:<q></label>
						</td>
						<td>
							<input type="text" name="login" id="login" r=1>
						</td>
					</tr>
					<tr>
						<td>
							<label for="captchaInput">Арифметическая CAPTCHA</label>
						</td>
						<td>
							<p>
								<img id="captchaImage" width="120px" height="40px" src="<%=imgData%>" alt="CAPTCHA"
								     style="cursor:pointer;" onclick="refreshCaptcha()" title="Обновить CAPTCHA">
							</p>
						</td>
						<td>
							<button id="captchaRefresh" onclick="refreshCaptcha()">Обновить капчу</button>
						</td>
					</tr>
					<tr>
						<td>
							<label for="captchaInput">Введите результат (CAPTCHA):<q></label>
						</td>
						<td>
							<input type="text" name="captchaInput" id="captchaInput" r=1>
						</td>
						<td>
							<button id="btnSendSMSCode" onclick="reset_password()">Получить код</button>
						</td>
						<td>
							<div id="temp_password_timer">
								<span id="seconds_left">60</span> <span id="unit">с.</span>
							</div>
						</td>
					</tr>
				</table>
			</fieldset>
		</form>

		<% } %>
	</t:form>
</t:page>