function isCross() {
	var ua = window.navigator.userAgent;
	var msie = ua.indexOf('MSIE ');
	var trident = ua.indexOf('Trident/');
	return !(msie > 0 || trident > 0);
}

function getDOM(d) {
	function g(d) {
		if (!is.string(d)) return d;
		if (d.indexOf(".") > 0) return eval(d);
		return document.getElementById(d);
	}

	return g(d);
}

function hideDOM(d) {
	d = getDOM(d);
	d.style.display = "none";
}

function showDOM(d, s) {
	d = getDOM(d);
	d.style.display = "block";
}

function getDOMValue(e) {
	e = getDOM(e);
	if (is.def(e.value)) return e.value;
	return e.innerText;
}

function makeArray(o) {
	if (is.array(o)) return o;
	return [o];
}

(function () {
	var toString = Object.prototype.toString,
		undefined;

	function t(o) {
		return toString.call(o);
	}

	window.is = {
		number: function (o) {
			return t(o) === "[object Number]";
		},
		string: function (o) {
			return t(o) === "[object String]";
		},
		array: function (o) {
			return t(o) === "[object Array]";
		},
		hash: function (o) {
			return t(o) === "[object Object]";
		},
		func: function (o) {
			return t(o) === "[object Function]";
		},
		def: function (o) {
			return !is.undef(o);
		},
		undef: function (o) {
			return (o === undefined || o == null);
		},
		hasFlag: function (f, i) {
			if (f & i) return true;
			return false;
		}
	};
})();

function nvl(o, d) {
	if (is.def(o)) return o;
	else return d;
}

function nocacheURL(url) {
	var j = url.indexOf("_=");
	if (j > -1) url = url.substring(0, j - 1);
	return url + (url.match(/\?/) ? "&" : "?") + "_=" + (new Date()).getTime();
}

AJAX = ajax = {
	load: function (D) {
		var xhr = new XMLHttpRequest();
		var mtd = "GET";
		if (is.def(D.HEAD)) mtd = "HEAD";
		if (is.def(D.GET)) mtd = "GET";
		if (is.def(D.POST)) mtd = "POST";
		else D.POST = null;

		if (is.undef(D.url)) D.url = document.URL.split("?")[0];
		else if (is.undef(D.async)) D.async = false;

		D.url = nocacheURL(D.url);
		if (D.GET) {
			for (var v in D.GET)
				D.url += "&" + v + "=" + encodeURIComponent(D.GET[v]);
		}

		xhr.open(mtd, D.url, D.async);
		xhr.setRequestHeader("aj", "ax");

		if (D.HEAD) {
			for (var v in D.HEAD)
				xhr.setRequestHeader(v, D.HEAD[v]);
		}
		var post = null;
		if (D.POST) {
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			post = "";
			for (var v in D.POST) {
				var vl = makeArray(D.POST[v]);
				for (var i = 0; i < vl.length; i++) {
					post += v + "=" + encodeURIComponent(vl[i]) + "&";
				}
			}
		}
		xhr.onreadystatechange = function () {
			if (xhr.readyState == 4) {
				if (xhr.status == 200) {
					switch (xhr.getResponseHeader("RT")) {
						case "error":
							D.onError(xhr.responseText);
							break;
						case "alert":
							alert(xhr.responseText);
							break;
						case "json":
							D.onSuccess(eval(xhr.responseText));
							break;
						case "xml":
							D.onSuccess(xhr.responseXML);
							break;
						case "script":
							eval(xhr.responseText.getAlert().replaceAll("\\n", ""));
							break;
						default:
							D.onSuccess(xhr.responseText);
					}
					waitImage(false);
				} else {
					if (is.func(D.onError)) D.onError("Http status=" + xhr.status);
					else if (confirm("HTTP Status " + xhr.status + " - " + xhr.statusText)) window.open("").document.write(xhr.responseText);
				}
			}
		};

		xhr.send(post);
	}
};

function getWindowParent() {
	if (window.opener == null) {
		return window.top._t();
	} else {
		return window.opener.top._t();
	}
}

function escapeRegExp(string) {
	return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // $& means the whole matched string
}

function replaceAll(str, match, replacement) {
	return str.replace(new RegExp(escapeRegExp(match), 'g'), replacement);
}

String.prototype.replaceAll = function (search, replacement) {
	var target = this;
	return target.split(search).join(replacement);
};
String.prototype.getAlert = function () {
	var target = this;
	var i = target.indexOf("alert");
	return target.substring(i, target.length);
};

function waitImage(s) {
	getDOM("waitImage").style.display = s ? "" : "none";
}

/*-----------------------------------------------------------*/

// When the user clicks the button, open the modal
function btnFunc() {
	showDOM("myModal");
}

function sendERROR() {
	if (confirm("Вы действительно хотите отправить эту ошибки на Администратор Банка?")) {
		waitImage(true);
		ajax.load({
			url: '/ibs/fbsd/lists/list/issue/add_issue.jsp',
			POST: {
				form_code: getWindowParent().getDOMValue("formcode"),
				description: replaceAll(getDOMValue("errorText"), "\n", ""),
				theme: "Системный ошибка в модуле: " + getWindowParent().getDOMValue("formTitle"),
				system_error: "Y",
				statusCode: statusCode
			},
			async: true
		});
	}
}

function onLoad() {
	if (statusCode == "404") {
		getDOM("errorText").innerHTML = "Страница не найдена: URL=" + urlJSP;
	}
	/*if(hasFBSD=="Y"){
	ajax.load({
            url: '/ibs/fbsd/lists/list/issue/add_issue.jsp',
            POST: {
                form_code: getWindowParent().getDOMValue("formcode"),
                description: replaceAll(getDOMValue("errorText"), "\n", ""),
                theme: "Системный ошибка в модуле: " + getWindowParent().getDOMValue("formTitle"),
                system_error: "Y",
		is_automated: "Y",
                statusCode: statusCode
            },
            async: true
        });		
	}*/

}

// When the user clicks on <span> (x), close the modal
function spanFunc() {
	var modal = document.getElementById("myModal");
	var pageNotFound = document.getElementById("pageNotFound");
	if (!isCross()) {
		showDOM(pageNotFound);
	}
	hideDOM(modal);
}

if (!(isCross())) {
	document.getElementById("tableDiv").style.height = document.body.clientHeight / 2;
	document.getElementById("pageNotFound").style.top = (document.body.clientHeight - 250) / 2;
	document.getElementById("modal-contents").style.top = (document.body.clientHeight / 4) - 60;
} else {
	document.getElementById("myModal").style.paddingTop = ((document.getElementById("pageNotFound").clientHeight) * 0.4) / 2 - 30;
}

if (isCross() === true) {
	var pageNotFound = document.getElementById("pageNotFound");
	var body_width = document.body.clientWidth;
	if (body_width < 700) {
		pageNotFound.childNodes[1].childNodes[1].width = (body_width) / 2;
		pageNotFound.childNodes[3].style.fontSize = "1rem";
	}
} else {
	var pageNotFound = document.getElementById("pageNotFound");
	var body_width = document.body.clientWidth;
	if (body_width < 700) {
		pageNotFound.childNodes[0].childNodes[0].width = (body_width) / 2;
		pageNotFound.childNodes[1].style.fontSize = "16px"
	}
}
// When the user clicks anywhere outside of the modal, close it
window.onclick = function (event) {
	var modal = document.getElementById("myModal");
	if (event.target == modal) {
		hideDOM(modal);
	}
}
document.onkeydown = function (evt) {
	evt = evt || window.event;
	if (evt.keyCode === 27) {
		var modal = document.getElementById("myModal");
		hideDOM(modal);
	}
}; 