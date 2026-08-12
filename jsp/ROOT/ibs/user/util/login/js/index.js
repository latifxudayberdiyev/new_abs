var d = document, lHolder, pHolder, langId = 0, encrypt = "", password_version = "";
var lang = {
	type: ["Русский", "Ўзбекча кирилл", "O'zbekcha lotin", "English"],
	login: ["Пользователь", "Фойдаланувчи", "Foydalanuvchi", "User"],
	login_fill: ["Заполните 'Пользователь'", "'Фойдаланувчи' тўлдиринг", "'Foydalanuvchi' to'ldiring", "Fill in the 'User'"],
	password: ["Пароль", "Калит сўзи", "Kalit so'zi", "Password"],
	password_fill: ["Заполните 'Пароль'", "'Калит сўзи' тўлдиринг", "'Kalit so'zi' to'ldiring", "Fill in the 'Password'"],
	language: ["Язык", "Тил", "Til", "Language"],
	enter: ["Вход в систему", "Тизимга кириш", "Tizimga kirish", "Logon"],
	version: ["Версия 7.0.0", "Версия 7.0.0", "Versiya 7.0.0", "Version 7.0.0"],
	iabs_title: ["Интегрированная Автоматизированная Банковская Система", "Интеграллаштирилган Автоматлаштирилган Банк Тизими", "Integrallashtirilgan Avtomatlashtirilgan Bank Tizimi", "Integrated Automated Banking System"],
	title: [" - ИАБС7", " - ИАБС7", " - IABS7", " - IABS7"],
	ltd: ["OOO", "МЧЖ", "MCHJ", "Ltd"],
	help: ["Описание настроек Internet Explorer", "Internet Explorer созлаш тавсифи", "Internet Explorer sozlash tavsifi", "Description of the Internet Explorer settings"],
	base: ["РЕАЛЬНАЯ БАЗА", "ХА&#1178;И&#1178;ИЙ БАЗА", "HAQIQIY BAZA", "REAL BASE"],
	nls: ["RU", "UZC", "UZL", "EN"],
	textLang: {
		"RU": {
			"leftTitle": "Добро пожаловать в iABS 7",
			"leftText": "Для входа в систему введите свой \n логин и пароль",
			"loginHolder": "Пользователь",
			"passwordHolder": "Пароль",
			"forgotPassword": "Забыли пароль?",
			"enter": "Войти",
			"rightTitle": "Интегрированная автоматизированная банковская cистема",
			"rightText": "Комплексная автоматизация всех аспектов финансовой и хозяйственной деятельности коммерческого банка на базе современных информационных технологий.",
			"help": "Описание настроек браузера",
			"iabsClient": "Мы рекомендуем вам обновить iABS7 Client до последней версии, чтобы воспользоваться всеми преимуществами системы iABS 7!"
		},
		"UZC": {
			"leftTitle": "iABS 7га хуш келибсиз",
			"leftText": "Кириш учун логинингиз ва паролингизни киритинг",
			"loginHolder": "Фойдаланувчи",
			"passwordHolder": "Пароль",
			"forgotPassword": "Паролни унутдингизми?",
			"enter": "Кириш",
			"rightTitle": "Интеграциялашган автоматлаштирилган банк тизими",
			"rightText": "Замонавий ахборот технологиялари асосида тижорат банки молиявий ва тадбиркорлик фаолиятининг барча жаб\u04B3аларини комплекс автоматлаштириш.",
			"help": "Браузер созламаларининг тавсифи",
			"iabsClient": "IABS7 тизимидан тўли\u049B фойдаланиш учун IABS7 Clientининг сўнгги версиясини ўрнатишни тавсия \u049Bиламиз!"
		},
		"UZL": {
			"leftTitle": "iABS 7ga xush kelibsiz",
			"leftText": "Kirish uchun loginingiz va parolingizni kiriting",
			"loginHolder": "Foydalanuvchi",
			"passwordHolder": "Parol",
			"forgotPassword": "Parolni unutdingizmi?",
			"enter": "Kirish",
			"rightTitle": "Integratsiyalashgan avtomatlashtirilgan bank tizimi",
			"rightText": "Zamonaviy axborot texnologiyalari asosida tijorat banki moliyaviy va tadbirkorlik faoliyatining barcha jabhalarini kompleks avtomatlashtirish.",
			"help": "Brauzer sozlamalarining tavsifi",
			"iabsClient": "IABS7 tizimidan to‘liq foydalanish uchun IABS7 Clientining so‘nggi versiyasini o‘rnatishni tavsiya qilamiz!"
		},
		"EN": {
			"leftTitle": "Welcome to iABS 7",
			"leftText": "To enter the system, please enter your \n username and password",
			"loginHolder": "Username",
			"passwordHolder": "Password",
			"forgotPassword": "Forgot password?",
			"enter": "Login",
			"rightTitle": "Integrated Automated Banking System",
			"rightText": "Comprehensive automation of all aspects of a commercial bank's financial and business activities based on modern information technologies.",
			"help": "Browser settings description",
			"iabsClient": "We recommend installing the latest version of the IABS7 Client for full use of the IABS7 system!"
		}
	}
}

function chooseLang() {
	var t = d.getElementById("selector");
	if (t.style.display == "none" || t.style.display == "")
		t.style.display = "inline";
	else
		t.style.display = "none";
}

function setLang(i) {
	chooseLang();
	langId = i;
	d.title = lang.iabs_title[i] + lang.title[i];
	d.getElementById("currentLang").innerText = lang.type[i];
	d.getElementById("language").innerText = lang.language[i] + ' :';
	d.getElementById("lHolder").value = lang.login[i];
	d.getElementById("pHolder").value = lang.password[i];
	d.getElementById("enter").value = lang.enter[i];
	d.getElementById("ltd").innerText = lang.ltd[i];
	d.getElementById("help").innerText = lang.help[i];
	d.getElementById("version").innerText = lang.version[i];
	d.getElementById("iabs").innerText = lang.iabs_title[i];
	d.getElementById("nls").value = lang.nls[i];
	//d.getElementById("base").innerHTML = lang.base[i];
}

function trim(str) {
	return str.replace(/^\s+|\s+$/g, "");
}

function hexChar(charCode) {
	if (charCode < 127 || charCode == 160 || charCode == 173) {
		return ('00' + charCode.toString(16)).slice(-2);
	} else if (charCode > 1024 && charCode < 1120) {
		return (charCode - 864).toString(16);
	} else if (charCode == 8470) {
		return (charCode - 8230).toString(16);
	} else if (charCode == 167) {
		return (263).toString(16);
	}
}

function hexString(s) {
	var ss = "";
	for (i = 0; i < s.length; i++) {
		ss = ss + hexChar(s.charCodeAt(i));
	}
	return ss.toUpperCase();
}

function rpad(str, length, symbol) {
	if (str.length > length)
		str = str.substring(0, length);
	for (var i = str.length; i < length; i++) {
		str = str + symbol;
	}
	return str;
}

function encryptByDES(message, key, isBase) {
	var keyHex = ((isBase) ? CryptoJS.enc.Hex.parse(key) : CryptoJS.enc.Utf8.parse(key));
	var iv = '\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000';
	var ivHex = CryptoJS.enc.Hex.parse(CryptoJS.enc.Utf8.parse(iv).toString(CryptoJS.enc.Hex));
	var encrypted = CryptoJS.TripleDES.encrypt(message, keyHex, {
		iv: ivHex,
		mode: CryptoJS.mode.CBC,
		padding: CryptoJS.pad.Pkcs7
	});
	if (isBase) {
		return encrypted.toString();
	} else {
		return encrypted.ciphertext.toString();
	}
}

function decryptByDES(ciphertext, key) {
	var keyHex = CryptoJS.enc.Hex.parse(key);
	var iv = '\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000';
	var ivHex = CryptoJS.enc.Hex.parse(CryptoJS.enc.Utf8.parse(iv).toString(CryptoJS.enc.Hex));
	var decrypted = CryptoJS.TripleDES.decrypt({
		ciphertext: CryptoJS.enc.Base64.parse(ciphertext)
	}, keyHex, {
		iv: ivHex,
		mode: CryptoJS.mode.CBC,
		padding: CryptoJS.pad.Pkcs7
	});
	return decrypted.toString(CryptoJS.enc.Utf8);
}

function encryptPassword5(message) {
	var sha1 = CryptoJS.SHA1(CryptoJS.enc.Utf8.parse(message));
	var sha2 = CryptoJS.SHA1(sha1);
	var key = CryptoJS.enc.Hex.parse((sha1 + sha2).toString().substring(14, 62));
	var iv = '\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000';
	var ivHex = CryptoJS.enc.Hex.parse(CryptoJS.enc.Utf8.parse(iv).toString(CryptoJS.enc.Hex));
	var encrypted = CryptoJS.TripleDES.encrypt(key, key, {
		iv: ivHex,
		mode: CryptoJS.mode.CBC,
		padding: CryptoJS.pad.Pkcs7
	});
	return encrypted.toString();
}

function decryptPassword5(ciphertext, key) {
	var keyHex = CryptoJS.enc.Utf8.parse(key);
	var iv = '\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000';
	var ivHex = CryptoJS.enc.Hex.parse(CryptoJS.enc.Utf8.parse(iv).toString(CryptoJS.enc.Hex));
	var decrypted = CryptoJS.TripleDES.decrypt({
		ciphertext: CryptoJS.enc.Base64.parse(ciphertext)
	}, keyHex, {
		iv: ivHex,
		mode: CryptoJS.mode.CBC,
		padding: CryptoJS.pad.Pkcs7
	});
	return decrypted.toString(CryptoJS.enc.Utf8);
}

function checkSubmit() {
	if (isCross() && (iabsClientRequired === "Y")) {
		if (!fbws.isOpenWS()) {
			alert("Запустите программу «crobs-client», затем обновите сайт!");
			return false;
		}
	}
	fm.s.setAttribute("disabled", true);
	if (trim(fm.u.value) == "") {
		fm.s.removeAttribute("disabled");
		showErrorNotification(lang.login_fill[langId], true);
		lHolder.onfocus();
		return false;
	}
	if (trim(fm.p.value) == "") {
		fm.s.removeAttribute("disabled");
		showErrorNotification(lang.password_fill[langId], true);
		pHolder.onfocus();
		return false;
	}
	getPasswordVersion(trim(fm.u.value).toLowerCase());
	return false;
}

function getErrorTxt(txt) {
	return txt;
}

function showErrorNotification(errorTxt, v) {
	var notification = document.getElementById("notification");
	var notificationTxt = document.getElementById("notificationText");
	var login = document.getElementById("lHolder");
	var password = document.getElementById("pHolder");
	var t;
	if (v) {
		notification.className = "show";
		login.className = "error";
		password.className = "error";
		notificationTxt.innerHTML = getErrorTxt(errorTxt.trim());
		t = setTimeout(function () {
			notification.className = "hide";
		}, 10000);
	} else {
		notification.className = "hide";
		login.className = "";
		password.className = "";
		if (t) clearTimeout(t);
	}
}

function getPasswordVersion(login) {
	s5("");
	return;

	var r = new XMLHttpRequest() /*new ActiveXObject("Microsoft.XMLHTTP")*/, t;
	r.onreadystatechange = function () {
		if (r.readyState == 4) {
			if (r.status == 200) {
				if (r.getResponseHeader("L")) {
					password_version = r.responseText;
					if (password_version == "V5") {
						s5("");
					} else {
						s("");
					}
				} else {
					fm.s.removeAttribute("disabled");
					showErrorNotification(r.responseText, true);
					password.onfocus();
				}
			} else {
				fm.s.removeAttribute("disabled");
				alert(r.status + '-' + r.statusText);
			}
		}
	};
	r.open("POST", "login_before.jsp", true);
	r.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	r.send("u=" + encodeURIComponent(login));
}

function s5(d) {
	if (d != "" && encrypt != "") {
		run(d, encrypt);
		return;
	}
	var message = trim(fm.u.value).toLowerCase() + "\u0001" + fm.p.value;
	var ciphertext = encryptPassword5(message);
	var encrypt_password = encryptPassword5(ciphertext);
	var r = new XMLHttpRequest() /*new ActiveXObject("Microsoft.XMLHTTP")*/, t;
	r.onreadystatechange = function () {
		if (r.readyState == 4) {
			if (r.status == 200) {
				if (r.getResponseHeader("L")) {
					var text = r.responseText;
					var uuid = decryptPassword5(text, ciphertext);
					encrypt = CryptoJS.enc.Hex.parse(encryptByDES(CryptoJS.enc.Hex.parse(hexString(fm.p.value)).toString(CryptoJS.enc.Base64), rpad(uuid, 24, "\u0000"), false)).toString(CryptoJS.enc.Base64);
					if (encrypt != "") {
						run(d, encrypt);
					}
				} else {
					fm.s.removeAttribute("disabled");
					showErrorNotification(r.responseText, true);
					pHolder.onfocus();
				}
			} else {
				fm.s.removeAttribute("disabled");
				alert(r.status + '-' + r.statusText);
			}
		}
	};
	r.open("POST", "login_after.jsp", true);
	r.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	r.send("u=" + encodeURIComponent(trim(fm.u.value)) + "&p=" + encodeURIComponent(encrypt_password) + "&pv=" + encodeURIComponent(password_version) + makeURLParam());
}

function s(d) {
	if (d != "" && encrypt != "") {
		run(d, encrypt);
		return;
	}
	var message = trim(fm.u.value).toLowerCase() + "" + trim(fm.p.value);
	var key = rpad(message, 24, "\u0000");
	var ciphertext = encryptByDES(message, key, false);
	var encrypt_password = encryptByDES(CryptoJS.enc.Hex.parse(ciphertext).toString(CryptoJS.enc.Base64), rpad(ciphertext, 48, "00"), true);
	var r = new XMLHttpRequest() /*new ActiveXObject("Microsoft.XMLHTTP")*/, t;
	r.onreadystatechange = function () {
		if (r.readyState == 4) {
			if (r.status == 200) {
				if (r.getResponseHeader("L")) {
					var text = r.responseText;
					var result = decryptByDES(trim(text), rpad(ciphertext, 48, "00"));
					encrypt = CryptoJS.enc.Hex.parse(encryptByDES(CryptoJS.enc.Hex.parse(hexString(trim(fm.p.value))).toString(CryptoJS.enc.Base64), rpad(result, 24, "\u0000"), false)).toString(CryptoJS.enc.Base64);
					if (encrypt != "") {
						run(d, encrypt);
					}
				} else {
					fm.s.removeAttribute("disabled");
					showErrorNotification(r.responseText, true);
					pHolder.onfocus();
				}
			} else {
				fm.s.removeAttribute("disabled");
				alert(r.status + '-' + r.statusText);
			}
		}
	};
	r.open("POST", "login_after.jsp", true);
	r.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	r.send("u=" + encodeURIComponent(trim(fm.u.value)) + "&p=" + encodeURIComponent(encrypt_password) + makeURLParam());
}

function isCross() {
	var ua = window.navigator.userAgent;
	var msie = ua.indexOf('MSIE ');
	var trident = ua.indexOf('Trident/');
	return !(msie > 0 || trident > 0);
}

/*-----*/
function callBackLogin(o, sn) {
	var code = (typeof o.code == "undefined") ? o.errorCode : o.code;
	var msg = o.msg || o.comments;
	var res = o.responseBody || o.signedMsg;
	if (code != 0) {
		alert(msg);
		fm.s.removeAttribute("disabled");
	} else {
		run('&crp=' + encodeURIComponent(res), encrypt, sn);
	}
}

function checkSerialNumber(s) {
	if (window['settingSN'] == "Y") {
		if (s == window["serialNumber"]) {
			fbws.signedMsg(window["queryLine2"], function (o) {
				callBackLogin(o, s)
			});
		} else {
			alert('Серийный номер, зарегистрированный на ключе, не совпал!');
			fm.s.removeAttribute("disabled");
		}
	} else {
		fbws.signedMsg(window["queryLine2"], function (o) {
			callBackLogin(o, s)
		});
	}
}

/*-----*/
function callBackSerialNumber(o) {
	var code = (typeof o.code == "undefined") ? o.errorCode : o.code;
	var msg = o.msg || o.comments;
	var res = o.responseBody || o.signedMsg;
	if (code != 0 || !res) {
		alert(msg);
		fm.s.removeAttribute("disabled");
		throw new Error("Ошибка получения серийного номера ключа!");
	} else {
		checkSerialNumber(res);
	}
}


/*-----*/
function run(d, password, sn) {
	var r = new XMLHttpRequest() /*new ActiveXObject("Microsoft.XMLHTTP")*/, t;
	r.onreadystatechange = function () {
		if (r.readyState == 4) {
			if (r.status == 200) {
				if (r.getResponseHeader("L")) {
					eval(r.responseText);
				} else {
					fm.s.removeAttribute("disabled");
					showErrorNotification(r.responseText, true);
					pHolder.onfocus();
				}
			} else {
				fm.s.removeAttribute("disabled");
				alert(r.status + '-' + r.statusText);
			}
		}
	};
	r.open("POST", "login.jsp", true);
	r.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	var nlsLangValue = document.getElementById("dropdown-btn").getAttribute("lang-value") || "RU";
	if (window['settingSN'] == "Y") {
		r.send("sn=" + sn + "&nls=" + nlsLangValue + "&u=" + encodeURIComponent(trim(fm.u.value)) + "&p=" + encodeURIComponent(password) + "&x=" + screen.availWidth + "&y=" + screen.availHeight + makeURLParam() + d);
	} else {
		r.send("&nls=" + nlsLangValue + "&u=" + encodeURIComponent(trim(fm.u.value)) + "&p=" + encodeURIComponent(password) + "&x=" + screen.availWidth + "&y=" + screen.availHeight + makeURLParam() + d);
	}
}

window.onload = function () {
	setCrossVersion();
	/**/
	if (!isCross()) {
		if (window.opener == null) {
			document.write("После завершения работы с программой, закройте это окно.");
			window.opener = window.open('index.jsp', '', 'scrollbars=auto, directories=no, location=no, menubar=no, resizable=yes, status=yes, titlebar=yes, toolbar=no, top=0, left=0, width=' + (screen.availWidth - 10) + ', height=' + (screen.availHeight - 50));
			window.close(self);
			return;
		}
	}
	/**/
	document.onkeydown = (function (e) {
		var e = window.event || e;
		var unicode = e.keyCode ? e.keyCode : e.charCode
		if (unicode == "13") {
			checkSubmit();
		}
	});
	lHolder = d.getElementById("lHolder");
	pHolder = d.getElementById("pHolder");
	d.body.onclick = function (e) {
		var e = window.event || e;
		if (e.srcElement.id == "language" || e.srcElement.id == "currentLang" || e.srcElement.id == "caret")
			return;
	}
	//lHolder.onfocus();

	initLanguageEvent()
}


function setCrossVersion() {
	if (document.getElementById("core-cross-version-text")) {
		var versionElement = document.getElementById("core-cross-version-text");
		versionElement.textContent = coreCrossVersion;
	}
}

function changePageLang(value) {
	var data = lang.textLang[value];
	var fields = ["leftTitle", "leftText", "lHolder", "pHolder", "forgotPassword", "rightTitle", "rightText", "help"];

	//if (isCross()) document.getElementById("iabs-client").getElementsByTagName("a")[0].innerText = data.iabsClient
	//document.getElementById("enter").setAttribute("value", data.enter)
	for (var i = 0; i < fields.length; i++) {
		var element = document.getElementById(fields[i]);
		if (element.tagName === "INPUT") {
			element.setAttribute("placeholder", data[fields[i]]);
		} else {
			element.innerText = data[fields[i]]
		}
	}
}

function initLanguageEvent() {
	var dropdownButton = document.getElementById('dropdown-btn');
	var dropdownContent = document.getElementById('dropdown-content');

	function toggleDropdown() {
		if (dropdownContent.style.display === 'block') {
			dropdownContent.style.display = 'none';
		} else {
			dropdownContent.style.display = 'block';
		}
	}

	dropdownButton.onclick = toggleDropdown;

	document.body.onclick = function (e) {
		var clickedElement = window.event.srcElement || window.event.target;
		if (!dropdownButton.contains(clickedElement) && !dropdownContent.contains(clickedElement)) {
			dropdownContent.style.display = 'none';
		}
	}

	var dropdownBtn = document.getElementById('dropdown-btn');
	var dropdownContent = document.getElementById('dropdown-content');
	var items = dropdownContent.getElementsByTagName('li');

	for (var i = 0; i < items.length; i++) {
		items[i].onclick = function () {

			for (var j = 0; j < items.length; j++) {
				items[j].className = items[j].className.replace(/\bactive\b/, '');
			}

			var value = this.getAttribute('value');
			var imgSrc = this.getElementsByTagName('img')[0].src;
			var text = this.textContent || this.innerText;

			dropdownBtn.innerHTML = '<img src="' + imgSrc + '" alt="">' + text + '<span class="arrow-down"></span>';
			dropdownBtn.setAttribute("lang-value", value);

			this.className = "active"

			changePageLang(value);
			toggleDropdown()
		};
	}
}