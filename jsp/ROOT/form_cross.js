/* document object ini o`rniga ishlatish uchun
 * document.write("Hello World!");
 * _.write("Hello World!");
 */
var CMS_VERSION = "0.0.1", __contextPath = "", _ = document, _locklayer, isShowModalDialog, clWidth;
var onSubmit = _.createEvent("HTMLEvents");
onSubmit.initEvent("submit", true, false);
var oldClose = window.close;
var isModal = false;
var theme = "light"
window.close = function () {
	windowClose();
}

function windowClose() {
	var isIframe;
	if (is.def(window.parent)) isIframe = (window.location != window.parent.location);
	if (isIframe) {
		var x = getWindowParent().document.getElementById("imodal" + getIframeNextIndex());
		goParent(x, 2).querySelector(".modal-close").click();
		isModal = false;
	} else {
		oldClose();
	}
}

/* function replaceQGH(str)
 * str kelgan textdagi barcha q, h, g' html symbol unicode ga almashtirib beradi
 */
function replaceQGH(v) {
	var newStr = new String(v)
		.replace(new RegExp("&#1178;", "g"), "\u049A").replace(new RegExp("&#1179;", "g"), "\u049B")
		.replace(new RegExp("&#1170;", "g"), "\u0492").replace(new RegExp("&#1171;", "g"), "\u0493")
		.replace(new RegExp("&#1202;", "g"), "\u04B2").replace(new RegExp("&#1203;", "g"), "\u04B3")
		.replace(new RegExp("&#1240;", "g"), "\u04D8").replace(new RegExp("&#1241;", "g"), "\u04D9")
		.replace(new RegExp("&#1186;", "g"), "\u04A2").replace(new RegExp("&#1187;", "g"), "\u04A3")
		.replace(new RegExp("&#1256;", "g"), "\u04E8").replace(new RegExp("&#1257;", "g"), "\u04E9")
		.replace(new RegExp("&#1200;", "g"), "\u04B0").replace(new RegExp("&#1201;", "g"), "\u04B1")
		.replace(new RegExp("&#1198;", "g"), "\u04AE").replace(new RegExp("&#1199;", "g"), "\u04AF")
		.replace(new RegExp("&#1210;", "g"), "\u04BA").replace(new RegExp("&#1211;", "g"), "\u04BB")
		.replace(new RegExp("&#699;", "g"), "\u02BB").replace(new RegExp("&#171;", "g"), "\u00AB")
		.replace(new RegExp("&#187;", "g"), "\u00BB").replace(new RegExp("&lt;", "g"), "\u003C")
		.replace(new RegExp("&gt;", "g"), "\u003E").replace(new RegExp("&#40;", "g"), "\u0028")
		.replace(new RegExp("&#41;", "g"), "\u0029").replace(new RegExp("&#39;", "g"), "\u0027");
	return newStr;
}

/* function replaceUniCode(str)
 * str kelgan textdagi barcha unicode ni html symbol ga almashtirib beradi
 */
function replaceUniCode(v) {
	var newStr = new String(v)
		.replace(new RegExp("\u049A", "g"), "&#1178;").replace(new RegExp("\u049B", "g"), "&#1179;")
		.replace(new RegExp("\u0492", "g"), "&#1170;").replace(new RegExp("\u0493", "g"), "&#1171;")
		.replace(new RegExp("\u04B2", "g"), "&#1202;").replace(new RegExp("\u04B3", "g"), "&#1203;")
		.replace(new RegExp("\u04D8", "g"), "&#1240;").replace(new RegExp("\u04D9", "g"), "&#1241;")
		.replace(new RegExp("\u04A2", "g"), "&#1186;").replace(new RegExp("\u04A3", "g"), "&#1187;")
		.replace(new RegExp("\u04E8", "g"), "&#1256;").replace(new RegExp("\u04E9", "g"), "&#1257;")
		.replace(new RegExp("\u04B0", "g"), "&#1200;").replace(new RegExp("\u04B1", "g"), "&#1201;")
		.replace(new RegExp("\u04AE", "g"), "&#1198;").replace(new RegExp("\u04AF", "g"), "&#1199;")
		.replace(new RegExp("\u04BA", "g"), "&#1210;").replace(new RegExp("\u04BB", "g"), "&#1211;")
		.replace(new RegExp("\u02BB", "g"), "&#699;").replace(new RegExp("\u00AB", "g"), "&#171;")
		.replace(new RegExp("\u00BB", "g"), "&#187;");
	return newStr;
}

/* Berilgan element o'zidan yuqori barcha parentlari ichidan class yoki id bo'yicha birinchi uchragan elementini qaytaradi
 *	n - class yoki id nomi //masalan: ".classname" yoki "#id"
 * agar hech qanday parametr berilmasa eng yuqoridagi document ni qaytaradi
*/
function megaQuerySelector(n, el) {
	var result, m, doc = el;
	m = el;
	if (is.undef(el)) {
		el = (is.def(window.frameElement)) ? window.frameElement : window.document;
	} else {
		el = (is.def(el.frameElement)) ? el.frameElement : el.document;
	}
	if (is.def(n) && ((n[0] == ".") || (n[0] == "#"))) {
		if (el.tagName == "IFRAME") {
			doc = el.contentDocument || el.contentWindow.document;
		} else if (is.def(el.document)) {
			doc = el.document;
		}
		if (is.def(doc.document)) {
			result = doc.document.querySelector(n);
			if (is.def(doc.document.documentElement)) {
				result = doc.document.documentElement.querySelector(n);
			}
		} else {
			result = doc.querySelector(n);
		}
		if (is.undef(result)) {
			if (is.def(GetOwnerWindow(el))) {
				return megaQuerySelector(n, GetOwnerWindow(el));
			} else {
				console.log(n + " nomli element topilmadi!");
				return;
			}
		} else {
			return result;
		}
	} else {
		if (is.undef(n)) {
			if (is.def(GetOwnerWindow(el))) {
				return megaQuerySelector(null, GetOwnerWindow(el));
			} else {
				return el;
			}
		} else {
			console.log("megaQuerySelector() funksiyasiga class yoki id nomi noto'g'ri kiritilgan!");
		}
	}
}

function GetOwnerWindow(el) {
	if (is.undef(el.ownerDocument)) return;
	return (el.ownerDocument.defaultView) ? el.ownerDocument.defaultView : el.ownerDocument.parentWindow;
}

function isModal() {
	return isModal || top.location.search.indexOf("modal") == 1;
}

window.close = close;
top.close = window.close;

//---------------------------------------------------------------------------
function loadCss(filename) {
	let cssNode = document.createElement("link");
	cssNode.setAttribute("rel", "stylesheet");
	cssNode.setAttribute("type", "text/css");
	cssNode.setAttribute("href", filename);
	document.getElementsByTagName("head")[0].appendChild(cssNode);
}

function loadFont(filename) {
	let cssNode = document.createElement("link");
	cssNode.setAttribute("rel", "stylesheet");
	cssNode.setAttribute("href", filename);
	document.getElementsByTagName("head")[0].appendChild(cssNode);
}

function loadJS(filename) {
	let jsNode = document.createElement("script");
	jsNode.setAttribute("type", "text/javascript");
	jsNode.setAttribute("src", filename);
	document.getElementsByTagName("head")[0].appendChild(jsNode);
}

loadCss(`/ibs/user/icons/icons.css?v=${CMS_VERSION}`);
loadCss(`/ibs/user/util/preload/preload.css?v=${CMS_VERSION}`);
loadFont(`/ibs/user/css/fa-4.7/css/font-awesome.min.css?v=${CMS_VERSION}`);
loadFont(`/ibs/user/font/opensans/css.css?v=${CMS_VERSION}`);
loadJS(`/ibs/user/util/preload/preload.js?v=${CMS_VERSION}`);

// select, multi-select
loadCss(`/ibs/user/util/select/vars/light.css?v=${CMS_VERSION}`);
loadCss(`/ibs/user/util/select/select.2.0.css?v=${CMS_VERSION}`);
loadJS(`/ibs/user/util/select/select.2.0.js?v=${CMS_VERSION}`);
//-------------------------------------------------------------------------------------
var allElement = _.querySelector("*");
if (allElement.hasAttribute("reference")) {
	allElement.createAttribute("tabindex", 0);
}

function IEVersion() {
	try {
		return Number((/(msie) ([\w.]+)/.exec(navigator.userAgent.toLowerCase()) || [])[2] || "0");
	} catch (e) {
		return 6;
	}
}

HTMLElement.prototype.wrap = function (tag) {
	if (!is.string(tag) && is.def(tag.tagName)) {
		tag = tag.tagName;
	}
	var tagObj = _.createElement(tag);
	tagObj.innerHTML = this.outerHTML;
	this.parentNode.insertBefore(tagObj, this);
	this.remove();
};

/* function getDOM(id, index)
 * berilgan ID yoki form bo`yicha document ichidan olish uchun
 * agar id ichida "." belgisi bo`lsa formadan qidiradi
 * getDOM("MyButton").click();
 */
function getDOM(d, i) {
	function g(d) {
		if (!is.string(d)) return d;
		if (d.indexOf(".") > 0) return eval(d);
		return _.getElementById(d);
	}

	d = g(d);
	if (is.def(i)) {
		if (i == 0) {
			if (is.def(d.tagName)) return d; else return d[0];
		} else {
			return d[i];
		}
	}
	return d;
}

/* function hideDOM(dom)
 * domni yashirish uchun
 */
function hideDOM(d, s) {
	d = getDOM(d);
	if (arguments.length > 1) disableElements(d, s);
	d.style.display = "none";
	if (is.string(d.getAttribute("onhide"))) d.onhide = window[d.getAttribute("onhide")];
	if (is.func(d.getAttribute("onhide"))) d.onhide();
}

/* function showDOM(dom)
 * domni ko`rsatish uchun
 */
function showDOM(d, s) {
	d = getDOM(d);
	if (arguments.length > 1) {
		disableElements(d, s);
		enableElements(d);
	}
	// d.style.display = "inline";
	d.style.display = "";
	if (is.string(d.getAttribute("onshow"))) d.onshow = window[d.getAttribute("onshow")];
	if (is.func(d.getAttribute("onshow"))) d.onshow();
}

/* function disableElements(dom, state)
 * berilgan domni ichidagi formaningn controllarini disable yoki enable qilish uchun
 */
function disableElements(d, st) {
	var s = ["input", "select", "textarea"], e;
	for (var j = 0; j < s.length; j++) {
		e = d.getElementsByTagName(s[j]);
		for (var i = 0; i < e.length; i++) {
			e[i].disabled = st;
			if (is.func(e[i].check)) {
				e[i].check();
			}
		}
	}
}

/* function setDOMValue(element, value)
 * agar formaning elementi bo`lsa valuesi
 * aks holda innerTextini o`zgartiradi
 */
function setDOMValue(e, v) {
	e = getDOM(e);
	if (is.def(e.setValue)) {
		e.setValue(replaceQGH(v));
		if (is.func(e.check)) e.check();
		if (is.func(e.callED)) e.callED();
	} else e.innerText = replaceQGH(v);
}

/* function getDOMValue(element)
 * agar formaning elementi bo`lsa valuesini oladi
 * aks holda innerTexti
 */
function getDOMValue(e) {
	e = getDOM(e);
	if (is.def(e.getValue)) return e.getValue();
	return e.innerText;
}

/* is object o`zgaruvchilarni tipini aniqlash uchun
 * if(is.number(v)) { .. }			// agar v number bo`lsa
 * if(is.string(v)) { .. }			// agar v string bo`lsa
 * if(is.array(v)) { .. }				// agar v massiv bo`lsa
 * if(is.hash(v)) { .. }				// agar v hash bo`lsa ex: {a:1,b:2}
 * if(is.func(f)) { .. }				// agar f function bo`lsa
 * if(is.def(v)) { .. }					// agar v o`zgaruvchiga qiymat berilgan bo`lsa
 * if(is.def(o.k)) { .. }				// agar o obyektining k elementi bo`lsa
 * if(is.undef(v)) { .. }				// ager v o`zgaruvhiga qiymat berilmagan bo`lsa
 * if(is.undef(o.k)) { .. }			// agar o obyektining k elementi bo`lmasa
 * if(is.hasFlag(f, i) { .. }		// agar f flagda i qiymat bo`lsa
 */
(function () {
	var toString = Object.prototype.toString, undefined;

	function t(o) {
		return toString.call(o);
	}

	window.is = {
		number: function (o) {
			return t(o) === "[object Number]";
		}, string: function (o) {
			return t(o) === "[object String]";
		}, array: function (o) {
			return t(o) === "[object Array]";
		}, hash: function (o) {
			return t(o) === "[object Object]";
		}, func: function (o) {
			return t(o) === "[object Function]";
		}, def: function (o) {
			return !is.undef(o);
		}, undef: function (o) {
			return (o === undefined || o == null);
		}, hasFlag: function (f, i) {
			if (f & i) return true;
			return false;
		}
	};
})();

/* function nvl(o, d)
 * agar o o`zgaruvchi null yoki undefined bo`lsa
 * d o`zgaruvchini qaytaradi
 * aks holda o`zini
 */
function nvl(o, d) {
	if (is.def(o)) return o; else return d;
}

/* function parent(node, number to up (k))
 * k marta yuqoridagi nodeni qaytaradi
 */
function goParent(t, k) {
	if (!is.number(k)) k = 1;
	var ret = t;
	for (var i = 0; i < k; i++) {
		ret = ret.parentElement;
	}
	return ret;
}

/* JsonToString()
 * JSON ning text ko`rinishga o`tkazadi
 * var a = {a : 1, b : "hi"};
 * alert(JsonToString(json));
 */
function JsonToString(v) {
	if (is.number(v)) {
		return v;
	}
	if (is.string(v)) {
		return "'" + v.replace(/\\/g, "\\\\").replace(/'/g, "\\\'") + "'";
	}
	if (is.array(v)) {
		var r = "[";
		for (var i = 0; i < v.length; i++) {
			if (i != 0) r += ",";
			r += JsonToString(v[i]);
		}
		return r + "]";
	}
	if (is.hash(v)) {
		var r = "{", f = false;
		for (a in v) {
			if (f) r += ",";
			f = true;
			r += a + ":" + JsonToString(v[a]);
		}
		return r + "}";
	}
	return v;
}

/* function makeArray(o)
 * berilgan parameter massiv bo`lsa o`zini qaytaradi
 * aks holda massiv yasab va uning birinchi indexdagi qiymatiga
 * shu obyektni joylashtirib qaytaradi
 * var k = makeArray("Hi");			// k = ["Hi"]
 * var d = makeArray(["Hi"]);		// d = ["Hi"]
 */
function makeArray(o) {
	if (is.array(o)) return o;
	return [o];
}

/* string.trim()
 * stringni trim qilish uchun
 * var k = "	 hi		".trim();		// k = "hi";
 */
/* String.prototype.trim = function() {
    var t = this,
        len = t.length,
        st = 0;
    while ((st < len) && (t.charCodeAt(st) <= 32)) st++;
    while ((st < len) && (t.charCodeAt(len - 1) <= 32)) len--;
    return ((st > 0) || (len < t.length)) ? t.substring(st, len) : t;
}; */

/* function nocacheURL(url)
 * Internet Explorer sahifani cache qilmasligi uchun
 * uning addressiga vaqt parameteri qo`sh uchun
 */
function nocacheURL(url) {
	var j = url.indexOf("_=");
	if (j > -1) url = url.substring(0, j - 1);
	return url + (url.match(/\?/) ? "&" : "?") + "_=" + (new Date()).getTime();
}

/* function go(D)
 * go({url : "a.jsp", target : "modalE"})
 * D obyekt bo`lib, qo`yidagi attributelar beriladi
 * attribute				default			description
 * ---------				-------			-----------
 * url						_.URL			ochiladigan sahifaning URL
 * clearParams				false			URL parameterilarini o`chirib tashlash uchun
 * target					null			berilgan oynaga sahifa ochiladi
 * param					null			qo`shimcha parameterlar
 * form						null			formani submit qilish uchun
 * arg						null			modal oynasi uchun argumentlar
 * action					null			modalE oynasi uchun qo`shimcha action (function)
 * dialogWidth				800				modal oynasining kengligi
 * dialogHeight				550				modal oynasining balandligi
 * dialogFill				false			modal oynasinig ekranga to'ldirish uchun {true, false}
 * lock						true			formanini QOTIRISH uchun : )
 * dialogScroll				no				modal oynasiga scroll qo`shish
 * cmsHelperTiltle			""				modal oynasiga title qo'shish
 * --------------------------------------------
 * agar param berilgan bo`lsa va target modal bo`lmasa faqat post request bo`ladi
 * agar target modal bo`lsa param atributi ishlatilmaydi
 * 1
 */
function go(D) {
	isShowModalDialog = true;
	D.url = nvl(D.url, _.URL);
	if (D.url.match(/^\/|http(s)?:/)) {
		if (D.url.match(/^\//)) {
			D.url = nvl(__contextPath, "") + D.url;
		}
		isFilter = is.def(D.isFilter) ? D.isFilter : false;
	} else {
		var o;
		if (_.URL.match(/cmshelper.jsp[?]modal/)) {
			o = window.dialogArguments.opener;
		} else {
			o = window;
		}
		o = o._.URL + (o._.URL.match(/\?/) ? "" : "?");
		D.url = o.replace(/[\/][^\/?]+[?].*$/, "") + "/" + D.url;
	}
	/*D.url = D.url.match(/^\/|http(s)?:/) ? D.url.match(/^\//) ? nvl(__contextPath, "") + D.url : D.url : (_.URL.match(/cmshelper.jsp[?]modal/) ? window.dialogArguments.opener : window)._.URL.replace(/[\/][^\/?]+[?].*$/, "") + "/" + D.url;*/
	if (D.clearParams) D.url = D.url.split("?")[0];
	D.url = nocacheURL(D.url);
	/* target modal bo`lganda
	 * modal oynaning window.dialogArguments ning strukturasi quydagicha
	 * {arg : Arguments, opener : window(chaqirilayotgan oyna), param : param}
	 */
	if (/modal/.test(D.target)) {
		if (is.undef(D.dialogWidth)) D.dialogWidth = 800;
		if (is.undef(D.dialogHeight)) D.dialogHeight = 550;
		if (is.undef(D.dialogScroll)) D.dialogScroll = "no";
		if (is.undef(D.dialogFill)) D.dialogFill = false;
		if (D.dialogFill) {
			D.dialogWidth = getWindowParent().innerWidth;
			D.dialogHeight = getWindowParent().innerHeight - 30;
		}
		if (D.dialogHeight > getWindowParent().innerHeight - 30) {
			D.dialogHeight = getWindowParent().innerHeight - 30;
		}
		clWidth = (((clWidth) ? clWidth : _.body.clientWidth) - 35);
		if (!isShowModalDialog && (clWidth - 35) < D.dialogWidth) D.dialogWidth = clWidth - 35;
		/*if (!isShowModalDialog && (_.body.scrollHeight - 45) < D.dialogHeight)
			// console.log(_.body.scrollHeight);
			// D.dialogHeight = _.body.scrollHeight - 45;
			if (window.showModalDialog) {
			var r = showModalDialog((D.target == "modalE" ? nvl(__contextPath, "") + "/cmshelper.jsp?" : D.url + "&") + "modal=" + CMS_VERSION, {
			arg: D.arg,
			param: D.param,
			opener: window,
			url: D.url,
			action: D.action,
			cmsHelperTitle: (is.def(D.cmsHelperTitle) && D.target == "modalE") ? D.cmsHelperTitle : ""
			}, "resizable:yes;scroll=" + D.dialogScroll + ";dialogWidth:" + D.dialogWidth + "px;dialogHeight:" + D.dialogHeight + "px;status=no;help=no", D.param);
			return r;
			} else {
			console.log("D=>",D);
			}*/
		return showModalDialog2(D);
	} else if (is.def(D.param) && D.target !== 1) {
		var fh = _.createElement("input"), h, pr;
		fh.type = "hidden";
		if (is.undef(D.form)) {
			D.form = _.createElement("form");
			_.body.appendChild(D.form);
		} else if (!D.form.fireEvent("onsubmit")) {
			return;
		}
		if (is.def(D.target) && D.form.target == "") {
			if (D.target == "new") {
				D.form.target = "_blank";
			} else {
				D.form.target = D.target.name;
			}
		}
		if (is.def(D.url)/*D.form.action == ""*/) {
			D.form.action = D.url;
		}
		D.form.method = "post";
		var hs = [];
		for (var p in D.param) {
			pr = makeArray(D.param[p]);
			if (p == "dispatchEvent") {
				continue;
			}
			for (var i = 0; i < pr.length; i++) {
				h = fh.cloneNode(false);
				h.name = p;
				h.value = pr[i];
				D.form.appendChild(h);
				hs.push(h);
			}
		}

		setCSRF(D.form);

		D.form.submit();
		//for(var p in hs) D.form.removeChild(hs[p]);
	} else {
		if (is.undef(D.target)) {
			D.target = window;
		}
		if (D.target == "new") {
			top._t().open(D.url, "", D.arg);
		} else {
			D.target.location = D.url;
		}
	}
	if (nvl(D.lock, true)) pageLock(true);
}

var isFilter = false;
var isFormCreated = false;

function showModalDialog2(D) {
	var parentObj = getWindowParent();
	var frmWobj = undefined;
	/**---------------Modal------------------*/
	parentObj._ = is.undef(parentObj._) ? parentObj.document : parentObj._;
	var div = parentObj._.createElement("div");
	div.className = (D.dialogFill || screen.availHeight - D.dialogHeight < 100) ? "modal" : "modal mini";
	div.style.display = "flex";
	/**---------------Content------------------*/
	var divContent = parentObj._.createElement("div");
	divContent.className = "modal-content";
	divContent.style.width = D.dialogWidth + "px";
	divContent.style.height = parseInt(D.dialogHeight) + 30 + "px";
	divContent.draggable = true;
	div.appendChild(divContent);
	/*--------------------------------------------------------*/
	parentObj._.body.appendChild(div);
	/**---------------Header------------------*/
	var divHeader = parentObj._.createElement("div");
	var spanHeader = parentObj._.createElement("span");
	divHeader.className = "modal-header";
	divHeader.draggable = true;
	spanHeader.className = "modal-close";
	spanHeader.innerHTML = "&times;";
	// spanHeader.attachEvent()
	divHeader.appendChild(spanHeader);
	divContent.appendChild(divHeader);
	/**---------------Body------------------*/
	var divBody = parentObj._.createElement("div");
	divBody.className = "modal-body";
	divContent.appendChild(divBody);
	if (is.def(D.action) && is.undef(D.url)) {
		D.action(divBody);
	} else {
		var iframe = parentObj._.createElement("iframe");
		iframe.id = "imodal" + getIframeNextIndex();
		iframe.name = "imodal" + getIframeNextIndex();
		iframe.width = "100%";
		iframe.setAttribute("dialogHeight", D.dialogHeight);
		(is.def(D.dialogHeight)) ? iframe.height = parseInt(D.dialogHeight) + "px" : iframe.height = "100%";
		iframe.frameBorder = "no";
		divBody.appendChild(iframe);
		if (is.undef(D.param)) {
			iframe.src = D.url;
		} else {
			var fh = parentObj._.createElement("input"), h, pr;
			fh.type = "hidden";
			if (is.undef(D.form)) {
				D.form = parentObj._.createElement("form");
				parentObj._.body.appendChild(D.form);
			} else if (!D.form.dispatchEvent(onSubmit)) return;
			D.form.target = iframe.contentWindow.name;
			D.form.action = D.url;
			D.form.method = "post";
			var hs = [];
			for (var p in D.param) {
				pr = makeArray(D.param[p]);
				if (p == "dispatchEvent") continue;
				for (var i = 0; i < pr.length; i++) {
					h = fh.cloneNode(false);
					h.name = p;
					h.value = pr[i];
					D.form.appendChild(h);
					hs.push(h);
				}
			}
			isFormCreated = true;
			setCSRF(D.form);
			D.form.submit();
		}
		spanHeader.onclick = function () {
			var returnValue = (iframe.contentWindow) ? iframe.contentWindow.returnValue : null;
			parentObj._.body.removeChild(div);
			if (is.def(D.ref)) {
				fillRefField(D.elem, D.ref, returnValue, D.v, D.se, D.si);
			}
			if (returnValue && (typeof returnValue === "boolean")) {
				go({});
				return;
			}
			if (is.def(D.callback)) {
				if (is.func(D.callback)) {
					D.callback(returnValue);
				} else {
					alert(D.callback + " not a function");
				}
			}
			window.dialogArguments = null;
			top.dialogArguments = null;
		};
		iframe.addEventListener("load", function () {
			iframe.contentWindow._ = is.undef(iframe.contentWindow._) ? iframe.contentWindow.document : iframe.contentWindow._;
			iframe.contentWindow.focus();
			window.dialogArguments = iframe.contentWindow;
			top.dialogArguments = iframe.contentWindow;
			isModal = true;
			if (is.def(D.action)) {
				D.action(iframe.contentWindow);
			}
			if (isFilter) {
				iframe.contentWindow._.body.classList.add("filterbody");
				fixfilterModalSize(iframe, 1);
				isFilter = false;
			}
			if (is.def(D.form) && is.def(D.param) && isFormCreated) {
				parentObj._.body.removeChild(D.form);
				isFormCreated = false;
			}
			iframe.contentWindow._.body.classList.add(goParent(iframe, 3).className.replace(/\s/g, "") + "body");
		});
	}
	throw ("waiting modal window opened");
}

function fixfilterModalSize(iframe, s) {
	let base, baseW, baseH, modal, modalH;
	base = iframe.contentWindow.getDOM("base");
	if (is.def(base)) {
		baseW = parseInt(base.scrollWidth);
		baseH = parseInt(base.scrollHeight);
	} else {
		return;
	}
	iframe.style.width = (baseW + 30) + "px";
	modal = iframe.closest(".modal-content");
	modal.style.width = (baseW + 30) + "px";
	modalH = getMaxHeight(baseH, 30);
	modal.style.height = modalH + "px";
	modal.childNodes[1].style.height = (modalH - 30) + "px";
	if (s) {
		fixfilterModalSize(iframe);
		var mHeight = parseInt(modal.childNodes[1].style.height.match(/(\d+)/)[0]);
		iframe.style.height = mHeight + "px";
	}
}

/*
	getMaxHeight berilgan songa diff qo'shilganda ekran balandligidan oshib ketsa, ekran klient height sonini qaytaradi
	num - boshlang'ich berilgan son
	diff - farq son, musbat bo'lsa num ga qo'shiladi yoki manfiy bo'lsa num dan ayriladi
*/
function getMaxHeight(num, diff) {
	var maxH, mainW;
	if (is.number(num)) {
		mainW = megaQuerySelector();
		if (is.def(mainW)) {
			maxH = mainW.documentElement.clientHeight;
			maxH -= 20;
		} else {
			maxH = (is.def(window.clientHeight)) ? window.innerHeight : document.body.clientHeight;
			maxH += 40;
		}

		if (is.number(diff)) {
			if (diff > 0) {
				return ((num + diff) > maxH) ? maxH : (num + diff);
			} else {
				if ((num + Math.abs(diff)) > maxH) {
					return (num + diff);
				} else {
					return (num > maxH) ? maxH : num;
				}
			}
		} else {
			return (num > maxH) ? maxH : num;
		}
	}
	return;
}

function getIframeLastIndex() {
	let objMainWindow = getWindowParent();
	let divs = objMainWindow._.getElementsByClassName("modal-body");
	return divs.length - 1;
}

function getIframeNextIndex() {
	return getIframeLastIndex() + 1;
}

function getWindowParent() {
	if (window.opener == null) {
		return window.top._t();
	} else {
		return window.opener.top._t();
	}
}

/* mask turlari 3 xil bo`lib
 * 1 - ) number(precision, [scale])
 * 2 - ) avail	a[ - b] | term -> a va b qiymat orasida termga mos bo`lgan xarf kiritish mumkun
 * 3 - ) mask {a1 | term}[static xarflar][{a2 | term}]...[{an | term}]
 * term quyidagicha beriladi
 * agar boshida $ belgisi uchrasa javascriptda e`lon qilingan variableni qiymatini oladi
 * regular expression shaklida ishlaydi (agar bo`sh bo`lsa istalgan xarfni kiritish mumkin)
 * "^[" + term + "]$"
 */
function parseMask(o, mask) { // mask parameter undefined bo'lib kelyapti
	function dateFill() {
		var v = this.value, k = v.substr(6, 4).replace(/_/g, "");
		if (k.length == 2) {
			k = Number(k);
			if (k > 50) k += 1900; else k += 2000;
			this.setValue(v.substr(0, 6) + k + v.substr(10));
		}
		v = this.value;
		if (v.length > 10) {
			var s = v.substr(0, 11), d;
			v += ":";
			for (var i = 0; i < 3; i++) {
				d = v.substr(11 + i * 3, 3).replace(/_/g, "");
				s += "00".substr(0, 3 - d.length) + d;
			}
			this.setValue(s);
		}
	}

	function dateValidate() {
		var v = this.value, d = parseInt(v.substr(0, 2), 10), m = parseInt(v.substr(3, 2), 10),
			l = parseInt(v.substr(6, 4), 10),
			ml = [, 31, (l % 4 == 0 && l % 100 != 0 || l % 400 == 0) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
		if (l <= 0) return false;
		if (m > 12 || d > ml[m] || m < 1 || d < 1) return false;
		if (v.length > 10) {
			d = parseInt(v.substr(11, 2), 10);
			m = parseInt(v.substr(14, 2), 10);
			l = parseInt(v.substr(17, 2), 10);
			if (d < 0 || 23 < d) return false;
			if (m < 0 || 59 < m) return false;
			if (l < 0 || 59 < l) return false;
		}
		return true;
	}

	function emailValidate() {
		var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
		return reg.test(this.value);
	}

	function getTermExp(v) {
		if (v.charAt(0) == "$") {
			try {
				return eval(v.substring(1));
			} catch (e) {
				throw "im";
			}
		} else if (v == "") return "^\x00"; else return v;
	}

	if (is.def(mask)) {
		o.setAttribute("mask", mask);
	}
	o.cm = {
		type: "none"
	};
	if (is.def(o.getAttribute("mask")) && o.getAttribute("mask") != "") {
		o.maxLength = 0x7FFFFFFF;
		var cm = o.getAttribute("mask");
		switch (cm) {
			case "card":
				cm = "{4|0-9} {4|0-9} {4|0-9} {4|0-9}";
				o.a = "c";
				o.size = "24";
				break;
			case "card_sv":
				cm = "8600 {4|0-9} {4|0-9} {4|0-9}";
				o.a = "c";
				o.size = "24";
				break;
			case "card_gl":
				cm = "9860 {4|0-9} {4|0-9} {4|0-9}";
				o.a = "c";
				o.size = "24";
				break;
			case "date":
				cm = "{2|0-9}.{2|0-9}.{4|0-9}";
				o.isValid = dateValidate;
				o.fill = dateFill;
				o.setAttribute("align", "center");
				o.setAttribute("title", "dd.mm.yyyy");
				break;
			case "date2":
				cm = "{2|0-9}\/{2|0-9}\/{4|0-9}";
				o.isValid = dateValidate;
				o.setAttribute("align", "center");
				o.setAttribute("title", "dd/mm/yyyy");
				break;
			case "datetime":
				cm = "{2|0-9}.{2|0-9}.{4|0-9} {2|0-9}:{2|0-9}:{2|0-9}";
				o.isValid = dateValidate;
				o.fill = dateFill;
				o.setAttribute("align", "center");
				o.setAttribute("title", "dd.mm.yyyy hh:mi:ss");
				break;
			case "datetime2":
				cm = "{4|0-9}.{2|0-9}.{2|0-9} {2|0-9}:{2|0-9}:{2|0-9}";
				o.isValid = dateValidate;
				o.fill = dateFill;
				o.setAttribute("align", "center");
				o.setAttribute("title", "yyyy.mm.dd hh:mi:ss");
				break;
			case "acc":
				cm = "{20|0-9}";
				break;
			case "acc2":
				cm = "{5|0-9}.{3|0-9}.{1|0-9}.{8|0-9}.{3|0-9}";
				o.setAttribute("size", "26");
				break;
			case "mfo":
				cm = "{5|0-9}";
				o.fill = function () {
					if (!(this.isEmpty() || this.isFilled())) {
						var v = this.value.replace(/_/g, "");
						this.setValue("00000".substr(0, 5 - v.length) + v);
					}
				};
				break;
			case "clientcode":
				cm = "{8|0-9}";
				o.fill = function () {
					if (!(this.isEmpty() || this.isFilled())) {
						var v = this.value.replace(/_/g, "");
						this.setValue("00000000".substr(0, 8 - v.length) + v);
					}
				};
				break;
			case "localcode":
				cm = "{2|0-9A-Z}{3|0-9}";
				o.fill = function () {
					if (!(this.isEmpty() || this.isFilled())) {
						var v = this.value.replace(/_/g, "");
						this.setValue("00000".substr(0, 5 - v.length) + v);
					}
				};
				break;
			case "email":
				cm = "200|0-9A-Za-z@_\.";
				o.isValid = emailValidate;
				break;
			/* case "passport":
                cm = "{2|A-Z} {7|0-9}"; */
		}
		try {
			var m;
			if ((m = cm.match(/^number\((\d+)\,?(\d*)\)$/)) != null) {

				cm = [parseInt(m[1]), m[2] == "" ? 0 : parseInt(m[2])];
				cm = [cm[0] - cm[1], cm[1]];
				if (cm[0] <= 0) throw "err";
				var l = (cm[0] + cm[1]) * 4 / 3;
				if (l > parseInt(o.size)) o.size = l;
				o.cm = {
					type: "number", pr: cm[0], sc: cm[1]
				};
				o.style.textAlign = "right";
			} else if (cm == "number") {
				o.cm = {
					type: "number", pr: 999, sc: -1
				};
				o.style.textAlign = "right";
			} else if ((m = cm.match(/^(\d+)-?(\d*)\|(.*)$/)) != null) {
				cm = [parseInt(m[1]), m[2] == "" ? 0 : parseInt(m[2]), getTermExp(m[3])];

				if ((cm[0] + cm[1]) > 0) {
					if (cm[0] > cm[1]) {
						s = cm[0];
						cm[0] = cm[1];
						cm[1] = s
					}
					o.cm = {
						type: "avail", min: cm[0], max: cm[1], re: new RegExp("^[" + cm[2] + "]$")
					};
				} else throw "ex";
			} else if ((m = cm.match(/^(\d+)\*(\d+)\|(.*)$/)) != null) {
				if (o.tagName != "TEXTAREA") throw "ex";
				o.cm = {
					type: "textarea",
					maxLines: parseInt(m[1]),
					maxLength: parseInt(m[2]),
					re: new RegExp("^[" + getTermExp(m[3]) + "]$")
				}
			} else {

				/* TODO {[ maska kiritganda escape qilish
                 */
				var len = cm.length, ret = [], c, s, t;
				for (var i = 0; i < len; i++) {
					c = cm.charAt(i);
					if (c == "{") {
						s = ++i;
						while (cm.charAt(i) != "}") {
							i++;
							if (i >= len) throw "im";
						}
						if ((m = cm.substring(s, i).match(/^(\d+)\|(.+)$/)) != null) {
							t = [parseInt(m[1]), getTermExp(m[2])];
							if (t[0] <= 0 || t[1] == null) throw "im";
						} else throw "im";
						ret.push(t);
						continue;
					} else {
						ret.push([0, c]);
					}
				}

				cm = ret;
				o.style.letterSpacing = "1px";
				o.cm = {
					type: "mask", cm: cm
				};
				o.chars = [];
				o.enter = [];
				for (var i = 0; i < cm.length; i++) {
					if (cm[i][0] == 0) {
						o.chars.push(cm[i][1]);
						o.enter.push(cm[i][1])
					} else {
						for (var j = 0; j < cm[i][0]; j++) {
							o.chars.push(new RegExp("^[" + cm[i][1] + "]$"));
							o.enter.push(null)
						}
					}
				}
				o.style.letterSpacing = "1px";
				/* isEmpty agar polya bo`m bo`sh bo`sa true qaytaradi, yarmi to`gan bo`lsa yoki to`la bo`lsa false qaytaradi
                 * faqatgina mask tipdagi polyaplarda ishlatiladi
                 */
				o.isEmpty = function () {
					for (var lv = 0; lv < this.enter.length; lv++) {
						if (typeof (this.chars[lv]) != "string" && this.enter[lv] != null) {
							return false
						}
					}
					return true
				};
				/* isFilled agar polya to`ppa to`la bo`lsa true qaytaradi, yarmi to`lgan bo`lsa yoki bo`m bo`sh bo`lsa false qaytaradi
                 * faqatgina mask tipdagi polyaplarda ishlatiladi
                 */
				o.isFilled = function () {
					for (var lv = 0; lv < this.enter.length; lv++) {
						if (typeof (this.chars[lv]) != "string" && this.enter[lv] == null) {
							return false
						}
					}
					return true
				};
			}
			o.setAttribute("title", getMaskDesc(o, cm));
		} catch (er) {
			if (er == "im") alert("Incorrect mask " + o.outerHTML); else throw er;
		}
	}
}

function getMaskDesc(o, m) {
	try {
		if (o.getAttribute("mask") == "date") {
			return "dd.mm.yyyy";
		} else if (o.cm.type == "mask") {
			return m[0][m[0].length - 1];
		} else if (o.cm.type == "avail") {
			return m[m.length - 1];
		} else if (o.cm.type == "number") {
			return "number";
		} else {
			return "";
		}
	} catch (e) {
		// console.log(e);
		return "";
	}
}

/* function showReference(ref)
 * name reference nomi (required)
 * get olish polyasi {name : object, name2 : object2}
 * put solish polyasi [object, object2]
 * w	width
 * h height
 * isValid
 * callback
 */
function showReference(t) {
	eval("ref=" + t.getAttribute("reference"));
	var v = ref.get, g = {}, si = -1, se;
	se = eval(t.form.name + "." + t.name);
	if (se != t) {
		si = 0;
		while (se[si] != t) si++;
	}
	if (is.def(ref.isValid)) {
		if (!ref.isValid(si)) return;
	}
	for (var k in v) {
		if (is.string(v[k])) {
			g[k] = v[k];
		} else {
			se = getDOM(v[k]);
			if (se.tagName != "SELECT" && se[si]) {
				se = se[si];
			}
			g[k] = getDOMValue(se);
		}
	}
	// t.setAttribute("refOpened", true);
	t.setAttribute("refOpened", true);
	ref.w = (((((clWidth) ? clWidth : _.body.clientWidth) - 35) < ref.w) ? (((clWidth) ? clWidth : _.body.clientWidth) - 35) : ref.w);
	ref.h = (((_.body.scrollHeight - 55) < ref.h) ? _.body.scrollHeight - 55 : ref.h);
	go({
		target: "modalE",
		url: nvl(ref.url, _.URL).split("?")[0] + "?reference=" + ref.name,
		param: g,
		dialogWidth: ref.w,
		dialogHeight: ref.h,
		elem: t,
		ref: ref,
		v: v,
		se: se,
		si: si
	});
}

function fillRefField(t, ref, r, v, se, si) {
	// t.setAttribute("refOpened", false);
	t.removeAttribute("refOpened");
	if (is.undef(r)) return;
	v = makeArray(ref.put);
	for (var i = 0; i < v.length; i++) {
		/* agar biror qiymat uchun control berilmagan bo`lsa, shu qiymatni tashlab o`tib ketadi */
		if (v[i] == null) continue;
		se = getDOM(v[i]);
		/* alert(se.outerHTML);
		if (se[si]) */
		if (is.undef(se.tagName)) {
			se = se[si];
		}
		setDOMValue(se, r[i])
	}
	if (is.def(ref.callback)) ref.callback(r, ref, t);
	t.select();
	t.focus();
}

/* function formatNumber(number, scale = 0)
 * alert qilish uchun kerak bo`ladi
 */
function formatNumber(v, sc) {
	if (is.number(v)) v = new String(v);
	if (sc == null) sc = 0;
	var sign = "";
	if (v.charAt(0) == "-") sign = "-";
	if (v.indexOf(".") >= 0) v = v.replace(/[,]/g, "");
	v = v.replace(/[,.]/, "@")
		.replace(/[,.]/g, "")
		.replace(/@/, ".")
		.replace(/[^0-9.]/g, "")
		.replace(/^[0]+/, "");
	if (v == "") v = "0";
	if (v.charAt(0) == ".") v = "0" + v;
	if (sc) {
		if (!v.match(/[.]/)) v = v + ".";
		v = v.split(".");
		if (sc != -1) {
			if (v[1].length > sc) v[1] = v[1].slice(0, sc); else for (var i = v[1].length; i < sc; i++) v[1] = v[1] + "0";
		} else {
			var i = v[1].length - 1;
			while (i >= 0 && v[1].charAt(i) == "0") i--;
			v[1] = v[1].substring(0, i + 1);
		}
		if (v[1].length > 0) v = v[0] + "." + v[1]; else v = v[0];
	} else v = v.replace(/[.].*/, "");
	var d = v.indexOf("."), v2;
	if (d == -1) d = v.length - 3; else if (d > 3) d -= 3; else d = 0;
	v2 = v.substring(d);
	for (var i = d; i > 0; i -= 3) {
		v2 = v.substring(i - 3, i) + " " + v2;
	}
	v = v2;
	return sign + v;
}

/* name , javasript dagi tayyor variable bilan ham ishlay oladi
 * get control or {field : control, valueCheck : boolean} default valueCheck = true
 * put
 * callback(returnData, req, this)
 */
function callRequest(t) {
	if (is.def(t.getAttribute("refOpened")) && t.getAttribute("refOpened")) return false;
	if (t.getAttribute("request").charAt(0) != "{") eval("tempReq=" + window[t.getAttribute("request")]); else eval("tempReq=" + t.getAttribute("request"));
	const req = {...tempReq};
	var v = {
		request: req.name
	}, si = 0, se;
	se = eval(t.form.name + "." + t.name);
	if (se != t) {
		while (se[si] != t) si++;
	}
	var se, valueCheck;
	if (is.def(req.put)) {
		var e = makeArray(req.put);
		for (var i = 0; i < e.length; i++) {
			se = getDOM(e[i]);
			if (is.undef(se.setValue)) if (se[si]) se = se[si];
			setDOMValue(se, "");
		}
	}
	if (t.getValue() == "") {
		t.setAttribute("error", 0);
	}
	var lastError = nvl(t.getAttribute("error"), 0), el;
	t.setAttribute("error", 0);
	if (t.fill) t.fill();
	for (var k in req.get) {
		el = req.get[k];
		if (is.string(el)) {
			v[k] = el;
		} else {
			se = getDOM(req.get[k]);
			if (typeof (se.valueCheck) == "boolean") {
				valueCheck = se.valueCheck;
				se = se.field;
			} else {
				valueCheck = true;
			}
			if (se.tagName != "SELECT" && se[si]) {
				se = se[si];
			}
			v[k] = getDOMValue(se);
			if (valueCheck) {
				if (se.check && !se.check(1) || String(v[k]) == "") {
					t.setAttribute("error", lastError);
					return false;
				}
			}
		}
	}
	var e = undefined;
	if (is.def(req.put)) e = makeArray(req.put);
	AJAX.load({
		url: req.url, POST: v, onSuccess: function (d) {
			var se;
			if (is.def(e)) {
				for (var i = 0; i < e.length; i++) {
					se = getDOM(e[i]);
					if (is.undef(se.setValue)) if (se[si]) se = se[si];
					setDOMValue(se, d[i]);
				}
			}
			if (is.func(req.callback)) {
				req.callback(d, req, t);
			}
		}, onError: function (d) {
			var txt = (new String(d)).trim();
			if (txt.length > 0) {
				alert(replaceQGH(txt));
			}
			t.setError(true);
			t.setAttribute("error", 1);
		}
	});
	return true;
}

function getMetaContent(name) {
	return top.document.getElementsByTagName("meta")[name].getAttribute("content");
}

function setCSRF(t) {
	if (t.tagName === "FORM") {
		if (!t.elements["x-csrf-token"]) {
			const inpToken = document.createElement("input");
			inpToken.name = "x-csrf-token";
			inpToken.type = "hidden";
			inpToken.value = getCookie("x-csrf-token");
			t.append(inpToken);
		} else {
			t.elements["x-csrf-token"].value = encodeURIComponent(getCookie("x-csrf-token"));
		}
	} else {
		if (typeof t.setRequestHeader !== "undefined") {
			t.setRequestHeader("x-csrf-token", encodeURIComponent(getCookie("x-csrf-token")));
		}
	}
}

(function (e) {
	var event = e || window.event;

	function setID(t, id) {
		if (id) {
			t.setAttribute("id", id);
		} else if (t.getAttribute("id") == "" || t.getAttribute("id") == "insdel") {
			t.setAttribute("id", "gen" + t.sourceIndex);
		}
	}

	function setDisable(s) {
		this.disabled = s;
		if (this.check) this.check();
	}

	function setReadOnly(s) {
		this.readOnly = s;
		if (this.check) this.check();
	}

	function getStart() {
		if (_.selection) {
			return Math.abs(_.selection.createRange().moveStart("character", -1000000));
		} else if (window.getSelection()) {
			return Math.abs(this.selectionStart);
		} else {
			return 0;
		}
	}


	function getEnd() {
		if (_.selection) {
			return this.value.length - Math.abs(_.selection.createRange().moveEnd("character", 1000000));
		} else if (window.getSelection()) {
			return this.selectionEnd;
			// return this.value.length - Math.abs(this.selectionEnd);
		} else {
			return 0;
		}
	}

	/*---------*/
	function setCaret(s, e) {
		var t = this, len = t.value.length;
		if (isNaN(parseInt(s))) {
			return false
		} else {
			s = parseInt(s);
			if (s < 0) {
				s = 0;
			} else if (s > len) {
				s = len;
			}
		}
		if (e == null || isNaN(parseInt(e)) || parseInt(e) < s) {
			e = s
		} else {
			e = parseInt(e);
			if (e < 0) {
				e = 0;
			} else if (e > len) {
				e = len;
			}
		}
		if (_.selection) {
			if (typeof (t.createTextRange) == "object" && t.type != "file") {
				var range = t.createTextRange();
				range.moveEnd("character", e - t.value.length);
				range.moveStart("character", s);
				range.select();
				return true;
			}
		} else {
			if (t.type != "file") {
				t.selectionStart = s;
				t.selectionEnd = e;
				t.focus();
				return true;
			}
		}
		return false
	}

	function getPrev(pos) {
		if (pos - 1 < 0) {
			return null
		}
		if (typeof (this.chars[pos - 1]) == "string") {
			return this.getPrev(pos - 1)
		}
		return pos - 1
	}

	function getNext(pos) {
		var t = this;
		if (pos + 1 >= t.enter.length) {
			return null
		}
		if (typeof (t.chars[pos + 1]) == "string") {
			return t.getNext(pos + 1)
		}
		return pos + 1
	}

	function maskGetValue() {
		var t = this;
		if (t.cm.type == "mask") {
			if (t.isEmpty()) return "";
		} else if (t.cm.type == "number") {
			var v = t.value.replace(/ /g, "");
			if (is.def(t.nullable) && v == "") return "";
			if (v == "") return 0; else return Number(v);
		}
		return t.value;
	}

	function maskSetValue(v) {
		var t = this;
		if (t.cm.type == "mask") {
			if (v == null) {
				v = "";
			}
			var val = "";
			for (var lv = 0; lv < t.chars.length; lv++) {

				if (lv < v.length) {
					if (typeof (t.chars[lv]) != "string") {
						if (t.chars[lv].test(v.charAt(lv))) {
							t.enter[lv] = v.charAt(lv);
							val += v.charAt(lv);
						} else {
							t.enter[lv] = null;
							val += "_";
						}
					} else {
						t.enter[lv] = t.chars[lv];
						val += t.chars[lv];
					}
				} else if (arguments.length > 0) {
					if (typeof (t.chars[lv]) == "string") {
						val += t.chars[lv];
					} else {
						t.enter[lv] = null;
						val += "_";
					}
				} else {
					if (typeof (t.chars[lv]) == "string") {
						val += t.chars[lv];
					} else {
						val += t.enter[lv] == null ? "_" : t.enter[lv];
					}
				}
			}
			t.value = val
		} else if (t.cm.type == "number") {
			if (arguments.length > 0) {
				if (!is.string(v)) {
					var k = Math.pow(10, t.cm.sc);
					v = Math.round(v * k) / k;
				}
				v = new String(v);
			} else v = t.value;
			if (t.getAttribute("nullable") && v.length == 0) {
				t.value = "";
				return;
			}
			var sign = "";
			t.value = formatNumber(v, t.cm.sc);
		} else if (arguments.length > 0) t.value = v;
		if (t.tagName == "TEXTAREA" && is.def(t.increaseRow)) t.increaseRow();
	}

	/* s = 1(request) */
	function maskcheck(s) {
		var t = this;
		if (t.disabled) {
			t.style.background = _getStyle(t, "input-background-disabled");
			return true;
		}
		try {
			if (t.tagName == "TEXTAREA") t.innerText = t.value.trim(); else if (t.type != "file" && t.tagName == "INPUT") t.value = t.value.trim();

			if (t.cm) {

				if (t.cm.type == "mask") {
					t.setValue(t.value);
					if (t.isEmpty()) {
						t.value = ""
					} else {
						if (is.func(t.fill)) t.fill();
						if (!t.isFilled() || (t.isValid && !t.isValid())) throw "err";
					}
				} else if (t.cm.type == "avail") {
					if (t.value.length != 0 && (t.value.length < t.cm.min || t.value.length > t.cm.max)) throw "err";
					if (t.value.length != 0 && (t.isValid && !t.isValid())) throw "err";
					for (var i = 0; i < t.value.length; i++) {
						if (!(t.cm.re.test(t.value.charAt(i)) || t.value.charCodeAt(i) <= 13)) throw "err";
					}
				} else if (t.cm.type == "textarea") {
					var lines = t.innerText.split("\r\n");
					if (lines.length > t.cm.maxLines) throw "err";
					for (var i = 0; i < lines.length; i++) {
						var line = lines[i];
						if (line.length > t.cm.maxLength) throw "err";
						for (var j = 0; j < line.length; j++) {
							if (!t.cm.re.test(line.charAt(j))) throw "err";
						}
					}
				} else if (t.cm.type == "number") {
					if (!(t.getAttribute("nullable") && t.value.length == 0)) {
						this.setValue();
						var m = this.value.replace(/ /g, "").match(/^-?([0-9]+)\.?([0-9]*)$/);
						if (!(m && m[1].length <= t.cm.pr)) throw "err";
					}
				}
			}
			if (window.event && s != 1 && ((window.event.type == "click" && window.event.target.type == "submit") || window.event.type == "submit" || window.event.type == "blur")) {

				if (t.getAttribute("validate") && !t.validate()) {
					throw "err";
				}
				if (is.def(t.getAttribute("r"))) {
					if (t.getAttribute("r") == "1") {
						if (t.value.trim() == "") throw "err";
					} else if (t.getAttribute("r") == "0") {
					} else if (!eval("__=" + t.getAttribute("r"))) throw "err";
				}
			}
			// if (is.def(t.error) && t.error != 0) throw "err";
			if (is.def(t.getAttribute("error")) && t.getAttribute("error") != "0") throw "err";
		} catch (er) {
			if (er == "err") {
				t.setError(true);
				return false;
			}
			throw er;
		}
		t.setError(false);
		return true
	}

	function setError(s) {
		var t = this;
		if (s) {
			t.style.background = _getStyle(t, "input-background-error");
			t.style.border = _getStyle(t, "input-border-error");
		} else {
			var clName = (t.readOnly ? "input-background-disabled" : "input-background");
			t.style.background = _getStyle(t, clName);
			t.style.border = _getStyle(t, "input-border");
		}
	}

	function maskdblclick() {
		if (is.def(this.getAttribute("reference")) && !this.readOnly) {
			showReference(this);
		}
	}

	function maskkeydown() {
		var t = this;
		var event = window.event;
		var key = event.keyCode || event.which;
		if (key == 120 && is.def(t.getAttribute("reference")) && !t.readOnly) {
			showReference(this);
		}
		if (t.readOnly == true) {
			return (key == 9 || key == 13);
		}
		if (t.cm.type == "mask") {
			// var selStart = t.getStart(),selEnd = t.getEnd();
			var selStart = t.selectionStart, selEnd = t.selectionEnd;
			t.setValue(t.value);
			t.setCaret(selStart, selEnd);
			if (selStart == selEnd) {
				/*------backspace-----*/
				if (key == 8) {
					var newPos = t.getPrev(selStart);
					if (newPos == null || newPos == selStart) {
						return false;
					}
					t.enter[newPos] = null;
					t.setValue();
					t.setCaret(newPos);
					return false;
				}
				/*------delete----*/
				if (key == 46) {
					if (typeof (t.chars[selStart]) == "string") {
						return false
					}
					t.enter[selStart] = null;
					t.setValue();
					t.setCaret(selStart);
					return false;
				}
			} else {
				/*--------Backspace or delete----------*/
				if (key == 8 || key == 46) {
					for (var lv = selStart; lv < selEnd; lv++) {
						if (typeof (t.chars[lv]) != "string") {
							t.enter[lv] = null;
						}
					}
					t.setValue();
					t.setCaret(selStart);
					return false;
				}
			}
		}
		return true;
	}

	function maskkeypress() {
		var t = this;
		var event = window.event;
		var key = event.keyCode || event.which;
		if (t.tagName == "TEXTAREA" && key == 13) {
			t.increaseRow();
		}
		if (t.cm.type == "mask") {
			if (t.readOnly) return false;
			var newChar = String.fromCharCode(key), pos = t.getStart();
			if (typeof (t.chars[pos]) == "string") {
				var newPos = t.getNext(pos);
				if (newPos == null || newPos == pos) return false;
				t.setCaret(newPos);
				pos = newPos;
			}
			if (pos >= t.chars.length || typeof (t.chars[pos]) != "string" && !(newChar.match(t.chars[pos]) ? true : ((newChar = newChar.toUpperCase())
				.match(t.chars[pos])) ? true : ((newChar = newChar.toLowerCase())
				.match(t.chars[pos])) ? true : false)) {
				t.setValue(t.value);
				t.setCaret(pos);
			} else {
				var selStart = t.getStart(), selEnd = t.getEnd();
				for (var lv = selStart; lv < selEnd; lv++) {
					if (typeof (t.chars[lv]) != "string") {
						t.enter[lv] = null;
					}
				}
				t.setValue();
				t.setCaret(selStart);
				t.enter[pos] = newChar;
				t.setValue();
				var newPos = t.getNext(pos);
				if (newPos == null) {
					newPos = pos + 1
				}
				t.setCaret(newPos);
			}
			return false;
		} else if (t.cm.type == "avail") {
			if (key == 13) return true;
			/**TODO shu joyini chrome podderjka qilmaydi*/
			if (_.selection) {
				if (t.value.length - _.selection.createRange().text.length >= t.cm.max) return false;
			} else {
				// if (t.value.length - window.getSelection().toString().length >= t.cm.max) {
				if (t.value.length - getSelectionText(t).length >= t.cm.max) {
					return false;
				}
			}
			var nc = String.fromCharCode(key);
			if (nc.match(t.cm.re)) return true;
			return false;
		} else if (t.cm.type == "textarea") {
			var nc = String.fromCharCode(key);
			if (nc.match(t.cm.re)) return true;
			return false;
		} else if (t.cm.type == "number") {
			var newChar = String.fromCharCode(key);
			if (this.oldkeypress) this.oldkeypress();
			if (newChar.match(/^[0-9]$/)) return true; else if (newChar.match(/^[.,]$/)) {
				if (key != 46) key = 46;
				if (!this.value.match(/.+[.,].*/)) return true;
			} else if (newChar == "-") return true;
			return false;
		}
		return true;
	}

	/*
        getSelectionText() - window.selection() funksiyasi barcha browserlarda ishlashi uchun
        - berilgan element tanlangan qiymatini qaytaradi
    */
	function getSelectionText(el) {
		if (window.getSelection) {
			try {
				var ta = el;
				return ta.value.substring(ta.selectionStart, ta.selectionEnd);
			} catch (e) {
				console.log("Cant get selection text")
			}
		}
		// For IE
		if (document.selection && document.selection.type != "Control") {
			return document.selection.createRange().text;
		}
	}

	function maskchange(t) {
		if (this.cm.type == "mask") {
			if (this.fill) this.fill();
			this.setValue(this.value);
		}
	}

	function maskfocus() {
		var t = this, f = t.check();
		if (f) t.style.background = _getStyle(t, (t.disabled || t.readOnly ? "input-background-disabled" : "input-background-focus"));
		if (t.cm) {
			if (t.cm.type == "mask") {
				t.setValue(t.value);
				if (t.isEmpty()) {
					if (t.value != "") t.setValue(t.value);
				}
			} else if (t.cm.type == "number") {
				t.value = t.value.replace(/[ ]/g, "");
			}
		} else {
			t.setValue();
		}
		t.setCaret(0, t.value.length);
	}

	function maskblur() {
		this.style.background = _getStyle(this, (this.disabled || this.readOnly ? "input-background-disabled" : "input-background"));
		this.check();
	}

	/**
	 * Agar majburiy input yashirin parent elementga ega bo'lsa, tekshiradi.
	 * Agar parent element `display: none` yoki `visibility: hidden` bo'lsa, elementni console ga chiqaradi.
	 */
	function hiddenParentElements(element) {
		let parent = element.parentNode;
		while (parent) {
			if (parent.style?.display === "none" || parent.style?.visibility === "hidden") {
				console.log("Hidden parent element found:", element, "(required)");
				break;
			}
			parent = parent.parentNode;
		}
	}

	function runEvent() {
		var event, et, t, r, r2, clickFunc;
		event = event || window.event;
		et = event.type;
		t = this;
		if (t.disabled) return false;
		clickFunc = t.getAttribute("onclick");

		if (et == "click" && is.def(clickFunc) && clickFunc.indexOf(".close()") > -1) {
			windowClose();
			return false;
		}

		if (et == "blur" || et == "change" || et == "propertychange" && t.callED) {
			t.callED();
		}
		if (et == "blur" && t.hasAttribute("amount-text")) {
			sumToWord(t, t.getAttribute("amount-text"));
		}
		if (et == "change" && t.tagName == "SELECT" && is.def(t.getAttribute("request"))) {
			callRequest(t);
		}
		if (et == "blur" && t.tagName == "INPUT" && is.def(t.getAttribute("request"))) {
			callRequest(t);
		}
		if (et == "click" && t.tagName == "INPUT" && t.type == "submit") {
			if (is.def(this.form)) {
				let err = false;
				et = "submit";
				t = this.form;
				for (let i = 0; i < t.elements.length; i++) {
					if (t.elements[i].tagName != "FIELDSET" && !t.elements[i].check()) {
						hiddenParentElements(t.elements[i])
						err = true;
						t.elements[i].focus();
						break;
					} else {
						t.elements[i].value = replaceUniCode(sanitize(t.elements[i].value));
					}
				}
				if (!err) setCSRF(t);
				if (err) return false;
			}
		}
		if (t["mask" + et]) r = t["mask" + et]();
		if (t["own" + et]) r2 = t["own" + et]();
		if (is.def(r2)) r = r && r2;
		event.returnValue = r;
		return r;
	}

	function onPaste() {
		var e, clipdata;
		e = event || window.event;
		clipdata = e.clipboardData || window.clipboardData;
		this.setValue(this.value.substr(0, this.getStart()) + clipdata.getData("text/plain") + this.value.substr(this.getEnd()));
		window.event.keyCode = 0;
		window.event.stopPropagation();
		window.event.returnValue = false;
	}

	let isInsDel = false;

	function InsDel() {
		var t = o = this, tbl, tmpID, m;
		var insdel = t.insdel || t.getAttribute("insdel");
		for (var i = 0; i < insdel; i++) {
			while (o.parentNode.tagName != "TR") o = o.parentNode;
			o = o.parentNode;
		}
		tbl = o.parentNode;
		if (t.value == "-") {
			if ((t.getAttribute("confirm") && window.confirm(t.getAttribute("confirm"))) || !t.getAttribute("confirm")) {
				getDOM(t.getAttribute("mbid")).disabled = false;
				tbl.deleteRow(o.sectionRowIndex);
			}
		} else {
			t.value = "-";
			t.setAttribute("mbid", t.getAttribute("id"));
			tmpID = t.getAttribute("id");
			t.setAttribute("id", "");

			var newRow = "";
			if (t.getAttribute("data-plus") === "Y") {
				var insertIndex = o.sectionRowIndex + 1;
				newRow = tbl.insertRow(insertIndex);
			}

			var nr = o.cloneNode(true);

			if (t.getAttribute("data-plus") !== "Y") {
				var plus = _.createElement("input");
				plus.setAttribute("type", "button");
				plus.setAttribute("insdel", "1");
				plus.setAttribute("data-plus", "Y");
				plus.value = "+";
				nr.appendChild(plus);
			}

			t.setAttribute("id", tmpID);
			t.value = "+";
			m = eval("__=" + t.getAttribute("max"));
			m = (m !== null) ? m : undefined;
			if (m < 2) {
				alert("InsDel: max is undefined or less than 2");
				throw "err";
			}
			/* attributes
             * beforeInsert(new row)
             * afterInsert(new row)
             */
			if (is.def(t.getAttribute("beforeInsert"))) {
				if (!is.func(t.beforeInsert)) t.beforeInsert = eval("(" + t.getAttribute("beforeInsert") + ")");
				if (t.beforeInsert(nr) == false) return;
			}
			/*initDOM qilishdan oldin sidlarni tozalab tashlaymiz*/
			clearSID(nr);
			isInsDel = true;
			if (t.getAttribute("data-plus") === "Y") newRow.replaceWith(nr); else tbl.replaceChild(nr, tbl.insertRow());
			nr.classList.add("insdel-animate-row");
			initDOM(nr);
			isInsDel = false;
			if (is.def(t.getAttribute("afterInsert"))) {
				if (!is.func(t.afterInsert)) t.afterInsert = eval("(" + t.getAttribute("afterInsert") + ")");
				t.afterInsert(nr);
			}
			if (o.parentNode.rows.length - o.sectionRowIndex >= m) {
				t.disabled = true;
			}
		}
		evalDivSize(getDOM("base"));
	}

	function clearSID(d) {
		let s = ["input", "select", "textarea", "form", "button"], e;
		for (let j = 0; j < s.length; j++) {
			e = d.getElementsByTagName(s[j]);
			for (let i = 0; i < e.length; i++) {
				const z = e[i].getAttribute("type");
				getDOM(e[i]).removeAttribute("sid");
				if (s[j] == "input" || s[j] == "textarea") {
					if ((z !== "checkbox") && (z !== "radio")) {
						getDOM(e[i]).value = "";
					}
				}
			}
		}
	}

	function getControlIndex() {
		var se, si = 0;
		se = eval(this.form.name + "." + this.name);
		if (se != this) {
			while (se[si] != this) {
				si++;
				if (si > 10000) throw "er";
			}
		}
		return si;
	}

	/* element attributes
	 * a : (l, c, r) style = "text-align:(left, center, right)"
	 * r : required (eval function)
	 * callED : enableElement chaqirish
	 * validate :
	 * enable : readonly elements @ -> disable, faqat bitta formani ichida ishlaydi
	 * saveValue : save value for enable
	 * insdel : number to do multiple fields
	 * beforeInsert : yangi qator qo`shishdan oldin chaqiriladigan funktsiya (agar false qaytarsa qo`shmaydi)
	 * afterInsert : yangi qatorni qo`shgandan so`ng chaqiriladigan funktsiya
	 * copyValue : insdel qilganda valuesini yangi qatorga ko`chirish uchun
	 * confirm : only for if it has insdel attributes, confirm message on deleting row
	 * max : maximum rows for multi row items (eval)
	 * element dynamic attributes
	 * isButton : true -> button else not
	 * getIndex : massivni ichidagi joyini aniqlash uchun
	 * form attributes
	 * noEnter
	 * nocycle
	 * alert : alert message if it has error on submiting
	 */
	window.initElement = function (t) {
		var gt = {}
		t.setDisable = setDisable;
		t.setReadOnly = setReadOnly;

		if (is.undef(t.check)) t.check = function () {
			return true
		};
		if (is.undef(t.getAttribute("placeholder"))) {
			t.setAttribute("placeholder", " ");
		}
		if (is.undef(t.getAttribute("id"))) {
			t.setAttribute("id", t.name);
		}
		;
		if (is.string(t.getAttribute("validate"))) {
			// t.validate = eval("("+t.getAttribute("validate")+")");
			t.validate = window[t.getAttribute("validate")];
		}
		t.getIndex = getControlIndex;
		if (t.getAttribute("enable")) {
			var enb = t.getAttribute("enable"), si = 0, sOR, sAND, m, n, vED, se;
			se = eval(t.form.name + "." + t.name);
			if (se != t) {
				while (se[si] != t) si++;
			}
			t.EDis = false;
			if (enb.charAt(0) == "@") {
				t.EDis = true;
				enb = enb.substr(1);
			}
			t.ED = [];
			sOR = enb.split("||");
			for (var k = 0; k < sOR.length; k++) {
				sAND = sOR[k].split("&&");
				vED = [];
				for (var i = 0; i < sAND.length; i++) {
					vED[i] = sAND[i].match(/^([!]?)(\w+)(\[.*\])$/);
					if (vED[i][1] == "!") vED[i][1] = true; else vED[i][1] = false;
					n = eval(t.form.name + "." + vED[i][2]);
					if (is.undef(n.tagName)) {
						if (n[si].type != "radio") n = n[si];
					}
					if (is.undef(n.EN_DES)) n.EN_DES = [];
					n.EN_DES.push(t.form.name + "." + t.name);
					vED[i][3] = eval(vED[i][3]);
				}
				if (vED.length > 0) t.ED.push(vED);
			}
			t.enableElement = function () {
				var t = this, s = false, si = 0, sOR, sAND, el;
				el = eval(t.form.name + "." + t.name);
				if (el != t) {
					while (el[si] != t) si++;
				}
				for (var i = 0; i < t.ED.length; i++) {
					sOR = true;
					for (var k = 0; k < t.ED[i].length; k++) {
						sAND = false;
						el = eval(t.form.name + "." + t.ED[i][k][2]);
						if (!(el.tagName || el[0].type == "radio")) {
							el = el[si]
						}
						var elv = "";
						if (is.def(el.getValue)) {
							elv = el.getValue();
						}
						for (var j = 0; el && j < t.ED[i][k][3].length; j++) {
							sAND = sAND || (elv == t.ED[i][k][3][j]);
						}
						if (t.ED[i][k][1]) sAND = !sAND;
						sOR = sOR && sAND;
					}
					s = s || sOR;
				}
				if (t.type != "checkbox") {
					if (s) {
						if (t.oldValue) t.setValue(t.oldValue);
					} else {
						if (!(t.readOnly || t.disabled)) {
							t.oldValue = t.getValue();
						}
						if (!t.getAttribute("saveValue")) t.value = "";
					}
				}
				if (t.EDis) t.setDisable(!s); else t.setReadOnly(!s);
				if (t.check) t.check();
			};
			t.removeAttribute("enable");
		}
		t.callED = function () {
			var t = this, si = 0, k, se;
			if (!t.name || !t.form || !t.form.name) return;
			se = eval(t.form.name + "." + t.name);
			if (se != t) {
				while (se[si] != t) si++;
			}
			if (t.type == "radio") {
				if (!t.checked) return;
				t = se;
			}
			k = t.EN_DES;
			for (var i = 0; k && i < k.length; i++) {
				var el = (eval(k[i]));
				if (el.enableElement) {
					el.enableElement();
				} else {
					if (si) {
						el[si].enableElement();
					} else {
						for (var j = 0; j < el.length; j++) el[j].enableElement();
					}
				}
			}
			if (is.array(t.OSH)) {
				for (var i = 0; i < t.OSH.length; i++) {
					var o = getDOM(t.OSH[i]);
					o.showHideDOM();
				}
			}
		};
		if (t.tagName == "SELECT") {
			if (t.options.length > 0) {
				if (!t.options[0].hasAttribute("value")) {
					t.options[0].setAttribute("value", "");
				}
			}
			if (is.undef(t.getAttribute("sid"))) {
				t.setAttribute("sid", t.sourceIndex);
				t.ownchange = t.onchange;
				t.onchange = runEvent;
				t.ownblur = t.onblur;
				t.onblur = runEvent;
				t.onkeydown = runEvent;
				t.check = maskcheck;
				t.setError = setError;
				t.setValue = function (v) {
					this.value = replaceQGH(v);
				};
				t.getValue = function () {
					return this.value;
				};
			}
			if (t.getAttribute("sid") != t.sourceIndex) {
				t.setAttribute("sid", t.sourceIndex);
				t.onchange = runEvent;
				t.onblur = runEvent;
			}
		} else if ((t.tagName == "INPUT" && (t.type == "submit" || t.type == "button" || t.type == "reset")) || t.tagName == "BUTTON") {
			/**TODO SHUNI qayta ko'rib chiqish kk*/
			if (is.undef(t.getAttribute("sid"))) {
				t.setAttribute("sid", t.sourceIndex);
				t.setAttribute("isButton", true);
				if (t.getAttribute("insdel")) {
					t.setAttribute("className", "mbtn");
					if (t.getAttribute("data-plus") !== "Y") t.value = (isInsDel) ? "-" : "+"; else t.value = "+";
					//-------------------------------------
					const tP = t.closest("table");
					if (is.def(tP) && (tP.rows.length < 2)) {
						t.value = "+";
					}
					//-------------------------------------
					t.setAttribute("insdel", Number(t.getAttribute("insdel")));
					setID(t);
					var o = t, s = ["input", "select", "textarea"], e;
					for (var i = 0; i < t.getAttribute("insdel"); i++) {
						while (o.parentNode.tagName != "TR") o = o.parentNode;
						o = o.parentNode;
					}
					for (var j = 0; j < s.length; j++) {
						e = o.getElementsByTagName(s[j]);
						for (var i = 0; i < e.length; i++) {
							e[i].setAttribute("mbid", t.getAttribute("id"));
						}
					}
					if (is.def(t.getAttribute("beforeInsert")) && !isInsDel) {
						t.beforeInsert = window[t.getAttribute("beforeInsert")];
					}
					if (is.def(t.getAttribute("afterInsert")) && !isInsDel) {
						t.afterInsert = window[t.getAttribute("afterInsert")];
					}
					t.maskclick = InsDel;
				}
				t.ownclick = t.onclick;
				t.onclick = runEvent;
			}
			if (t.getAttribute("sid") != t.sourceIndex) {
				t.setAttribute("sid", t.sourceIndex);
				t.onclick = runEvent;
			}
			t.style.background = _getStyle(t, "button-background");
			t.style.border = _getStyle(t, "button-border");

			t.onmouseout = function () {
				this.style.background = _getStyle(this, "button-background");
			};
			t.onmouseover = function () {
				this.style.background = _getStyle(this, "button-background-hover");
			};
			if (t.tagName == "BUTTON") {
				if (is.undef(t.getAttribute("type"))) {
					t.type = "button";
				}
				t.setValue = function (v) {
					this.innerHTML = replaceQGH(v);
				};
				t.getValue = function () {
					return this.innerHTML;
				};
			} else {
				t.setValue = function (v) {
					this.value = replaceQGH(v);
				};
				t.getValue = function () {
					return this.value;
				};
			}
		} else if (t.tagName == "INPUT" && (t.type == "checkbox" || t.type == "radio")) {
			if (is.undef(t.getAttribute("sid"))) {
				if (t.parentNode.tagName == "LABEL") {
					setID(t);
					t.parentNode.htmlFor = t.id;
					if (is.def(getDOM(t.id))) {
						replaceSameID(t.id);
					}
				}
				t.setAttribute("sid", t.sourceIndex);
				t.style.marginLeft = "0px";
				t.ownpropertychange = t.onpropertychange;
				t.onpropertychange = runEvent;
				t.ownblur = t.ownblur;
				t.ownchange = t.onchange;
				t.onblur = runEvent;
				t.onkeydown = runEvent;
				t.onchange = runEvent;
				if (t.type == "checkbox") {
					t.getValue = function (d) {
						if (this.checked) return this.value; else return is.def(d) ? d : null;
					};
					t.setValue = function (v) {
						if (this.value == v) this.checked = true; else this.checked = false;
					};
				} else {
					var o = eval(t.form.name + "." + t.name);
					o.getValue = function () {
						for (var i = 0; i < this.length; i++) if (this[i].checked) return this[i].value;
						return null;
					};
					o.setValue = function (v) {
						for (var i = 0; i < this.length; i++) {
							if (this[i].value == v) this[i].checked = true; else this[i].checked = false;
						}
					};
				}

			}
			if (t.getAttribute("sid") != t.sourceIndex) {
				t.onchange = t.onblur = t.onkeydown = runEvent;
			}
		} else if ((t.tagName == "INPUT" && (t.type == "text" || t.type == "file" || t.type == "password" || t.type == "hidden")) || t.tagName == "TEXTAREA") {
			if (is.undef(t.getAttribute("sid"))) {
				t.setAttribute("sid", t.sourceIndex);
				t.mask = "";
				t.style.background = _getStyle(t, (t.disabled || t.readOnly ? "input-background-disabled" : "input-background"));
				t.style.border = _getStyle(t, "input-border");
				t.ownkeydown = t.onkeydown;
				t.ownkeypress = t.onkeypress;
				t.ownchange = t.onchange;
				t.ownfocus = t.onfocus;
				t.ownblur = t.onblur;
				t.owndblclick = t.ondblclick;
				parseMask(t);
				t.getStart = getStart;
				t.getEnd = getEnd;
				t.getPrev = getPrev;
				t.getNext = getNext;
				t.setCaret = setCaret;
				t.setValue = maskSetValue;
				t.getValue = maskGetValue;
				t.check = maskcheck;
				t.setError = setError;
				if (t.tagName != "TEXTAREA") {
					t.onpaste = onPaste;
				} else {
					t.increaseRow = function () {
						var t = this;
						if (is.def(t.maxRows)) {
							if (is.string(t.maxRows)) t.maxRows = Number(t.maxRows);
							var lineLength = t.value.split("\r\n").length;
							if (t.rows <= lineLength && lineLength < t.maxRows) t.rows++;
						}
					}
				}

				t.maskkeydown = maskkeydown;
				t.maskkeypress = maskkeypress;
				t.maskchange = maskchange;
				t.maskfocus = maskfocus;
				t.maskblur = maskblur;
				t.maskdblclick = maskdblclick;
				t.ondblclick = t.onkeydown = t.onkeypress = t.onchange = t.onfocus = t.onblur = runEvent;
				t.setValue(t.value);
				t.check();
			}
			if (t.getAttribute("sid") != t.sourceIndex) {
				if (t.tagName != "TEXTAREA") {
					t.onpaste = onPaste;
				}
				t.ondblclick = t.onkeydown = t.onkeypress = t.onchange = t.onfocus = t.onblur = runEvent;
				if (t.getAttribute("copyValue")) {
					t.setValue(replaceQGH(t.value));
				} else {
					if (is.func(t.setValue)) {
						t.setValue("");
					} else {
						t.setValue = function (v) {
							t.value = v;
						};
						t.setValue("");
					}
				}
				t.check();
				t.setAttribute("sid", t.sourceIndex);
			}
		} else if (t.tagName == "INPUT" && t.type == "hidden") return; else if (t.tagName == "FORM") {
			if (!t.getAttribute("noEnter")) {
				t.onkeydown = function (evt) {
					var event = evt || window.event;
					var e = event.target || event.srcElement;
					var k = event.keyCode || event.which;
					if (k != 13 || e.type == "submit" || e.type == "button" || e.type == "reset" || e.tagName == "TEXTAREA" || e.tagName == "BUTTON") return true;
					k = 9;
				};
			}
			t.method = "post";
			t.ownsubmit = t.onsubmit;
			t.check = function () {
				var k = true, t = this, el = t.elements, F, e;
				for (var i = 0; i < el.length; i++) {
					e = el[i];
					if (!e.disabled) {
						if (e.check && !e.check()) {
							if (k) F = e;
							k = false;
						}
						if (e.getAttribute("validate") && !e.validate()) {
							if (k) F = e;
							k = false;
							e.setError(true);
						}
					}
				}
				for (var i = 0; k && i < el.length; i++) {
					e = el[i];
					if (e.cm && e.cm.type == "number") {
						e.value = e.value.replace(/[ ]/g, "")
					}
					if (e.cm && e.mask == "acc2") {
						e.value = e.value.replace(/[.]/g, "")
					}
				}
				if (!k) {
					if (t.getAttribute("alert")) alert(replaceQGH(t.getAttribute("alert")));
					try {
						F.focus();
					} catch (ex) {
						alert("Cannot focus on " + F.name);
						throw ex;
					}
				}
				return k;
			};
			t.masksubmit = function () {
				if (this.check()) {
					if (this.getAttribute("lock") != 0) pageLock(true);
					return true;
				} else {
					return false;
				}
			};
			t.onsubmit = runEvent;
			t.Submit = function () {
				// if (this.dispatchEvent(onSubmit)) {
				if (this.fireEvent("onsubmit")) {
					this.submit();
					if (this.getAttribute("lock") != 0) pageLock(true)
				}

			};
		} else {
			alert("element initialize error " + t.outerHTML);
		}
		if (t.getAttribute("a")) {
			switch (t.getAttribute("a")) {
				case "l":
					t.style.textAlign = "left";
					break;
				case "c":
					t.style.textAlign = "center";
					break;
				case "r":
					t.style.textAlign = "right";
			}
		}
	};

	window.initDOMShowHide = function (t) {
		if (t.getAttribute("showhide")) {
			var shd = t.getAttribute("showhide"), sOR, sAND, m, n, vSH, se, w;
			sOR = shd.split("||");
			t.SH = [];
			for (var i = 0; i < sOR.length; i++) {
				vSH = [];
				sAND = sOR[i].split("&&");
				for (var j = 0; j < sAND.length; j++) {
					vSH[j] = sAND[j].match(/^([!]?)(\w+[.]?\w+)(\[.*\])$/);
					if (vSH[j] == null) alert(sAND[j] + " is incorrect");
					if (vSH[j][1] == "!") vSH[j][1] = true; else vSH[j][1] = false;
					n = getDOM(vSH[j][2]);
					if (is.undef(n.OSH)) n.OSH = [];
					setID(t);
					// n.OSH.push(t.id);
					n.OSH.push(t);
					vSH[j][3] = eval(vSH[j][3]);
				}
				if (vSH.length > 0) t.SH.push(vSH);
			}
			t.showHideDOM = function () {
				var t = this, s = false, sOR, sAND, el;
				for (var i = 0; i < t.SH.length; i++) {
					sOR = true;
					for (var k = 0; k < t.SH[i].length; k++) {
						sAND = false;
						el = getDOM(t.SH[i][k][2]);
						var elv = el.getValue();
						for (var j = 0; j < t.SH[i][k][3].length; j++) {
							sAND = sAND || (elv == t.SH[i][k][3][j]);
						}
						if (t.SH[i][k][1]) sAND = !sAND;
						sOR = sOR && sAND;
					}
					s = s || sOR;
				}
				if (s) {
					showDOM(t, false);
				} else {
					hideDOM(t, true);
				}
			};
			t.showhide = false;
			t.showHideDOM();
		}
	};
	if (/[?&]modal/.test(_.URL)) {
		top._t = function () {
			/*if(is.def(window.dialogArguments)) {
                return window.dialogArguments.opener.top._t();
            } else {*/
			return window;
			//}
		};
		_.write("<title>");
		var m = ((is.def(window.dialogArguments.cmsHelperTiltle)) ? window.dialogArguments.cmsHelperTiltle : "");
		if (is.def(m)) _.write(m);
		for (var i = 0; i < 1000; i++) _.write("&nbsp;");
		_.write("</title>");
		window.isModal = true;
	} else {
		if (top == window) top.isModal = false;
	}
})();

/* function evalDivSize(DOM)
 * Domning id siga panel so`zini qo`shib
 */
function evalDivSize(d, s) {
	var t;
	t = getDOM(d.id + "panel");
	if (is.undef(t)) return;
	clWidth = undefined;
	if (d.getAttribute("minWidth") != "done") {
		if (d.getAttribute("minWidth") == "fill") {
			clWidth = t.offsetWidth - (_.body.scrollWidth - _.body.clientWidth);
			d.style.width = "";
		} else if (is.def(d.getAttribute("minWidth"))) {
			var w = parseInt(Number(d.getAttribute("minWidth")) * (isNaN(parseFloat(_getStyle(d, "coeff"))) ? 1 : parseFloat(_getStyle(d, "coeff"))));
			clWidth = w;
			d.style.width = "auto";
		}
		if (_.body.scrollWidth - _.body.clientWidth > 0) {
			d.width = "100%";
			clWidth = t.offsetWidth - (_.body.scrollWidth - _.body.clientWidth);
			d.width = "";
		}
		if (is.undef(clWidth)) {
			clWidth = t.offsetWidth;
		} else if (clWidth > _.body.clientWidth) {
			clWidth = _.body.clientWidth - 20;
		}
		t.style.overflow = "auto";
		t.style.width = clWidth;
	}
	var r = t.getBoundingClientRect(), clHeight = _.body.clientHeight - _.body.scrollHeight + r.bottom; //- r.top;// - 5;
	if (clHeight > _.body.clientHeight - d.clientHeight) {
		clHeight = _.body.clientHeight - d.clientHeight + r.bottom - r.top - 7;
	}
	if (d.getAttribute("minHeight") == "fill") {
		t.style.height = clHeight;
		if (getDOM("footForm")) {
			t.style.height = clHeight - 25;
		}
	} else if (!is.undef(d.getAttribute("minHeight"))) {
		var h = parseInt(Number(d.getAttribute("minHeight")) * isNaN(parseFloat(_getStyle(d, "coeff"))) ? 1 : parseFloat(_getStyle(d, "coeff")));
		if (h > t.clientHeight) t.style.height = h;
	}
	if (t.clientHeight > clHeight) {
		t.style.height = clHeight;
	}

	if (s == null) {
		evalDivSize(d, 1);
	} else {
		if (t.scrollWidth - t.clientWidth < 20 && t.scrollWidth - t.clientWidth > 0) {
			t.style.paddingRight = t.scrollWidth - t.clientWidth;
			t.style.overflowX = "hidden";
		} else {
			t.style.paddingRight = 0;
			t.style.overflow = "auto";
		}
		d.setAttribute("minWidth", "done");
	}/**/
}

/* function enableElements(dom)
 * berilgan DOM dagi enable attributelarini chaqirish uchun
 */
function enableElements(d) {
	var s = ["input", "select", "textarea", "fieldset", "div", "tr", "span"], e;
	if (d == null) d = _.body;
	for (var j = 0; j < s.length; j++) {
		e = d.getElementsByTagName(s[j]);
		for (var i = 0; i < e.length; i++) {
			if (is.def(e[i].getAttribute("enableElement")) && e[i].getAttribute("enableElement") != "") {
				e[i].enableElement = window[e[i].getAttribute("enableElement")];
			}
			if (e[i].showHideDOM) e[i].showHideDOM();
		}
	}
}

/* function initDOM(dom)
 * DOM ni initialize qilish uchun
 */
function initDOM(d) {
	var s = ["input", "select", "textarea", "form", "button"], e;
	e = _.getElementsByTagName("q");
	for (var i = 0; i < e.length; i++) {
		e[i].innerText = "*";
	}
	for (var j = 0; j < s.length; j++) {
		e = d.getElementsByTagName(s[j]);
		for (var i = 0; i < e.length; i++) {
			initElement(e[i]);
		}
	}
	enableElements(d);
	var sDOM = ["fieldset", "div", "tr", "span"];
	for (var j = 0; j < sDOM.length; j++) {
		e = d.getElementsByTagName(sDOM[j]);
		for (var i = 0; i < e.length; i++) {
			initDOMShowHide(e[i]);
		}
	}
}

function dragOBJ(d) {
	function xy(v) {
		return (v ? window.event.clientY + _.body.scrollTop : window.event.clientX + _.body.scrollTop);
	}

	function drag(e) {
		_.onselectstart = Function("return false");
		if (!stop) {
			d.style.top = (tX = xy(1) + oY - eY + "px");
			d.style.left = (tY = xy() + oX - eX + "px");
		}
	}

	var oX = parseInt(d.style.left), oY = parseInt(d.style.top), eX = xy(), eY = xy(1), tX, tY, stop;
	_.onmousemove = drag;
	_.onmouseup = function () {
		stop = 1;
		_.onmousemove = "";
		_.onmouseup = "";
		_.onselectstart = "";
	}
}

if (typeof (data) == "undefined") {
	data = {};
}

/* function initForm(form, data, top, left)
 * berilgan formani initialized qilish uchun
 * id = base base panel
 */
function initForm(d, data, t, l) {
	d = getDOM(d);
	if (is.undef(d)) return false;
	if (d.inited) return d;
	initDOM(d);
	if (is.undef(window.dialogArguments)) {
		if (d.id == "base") {
			d.style.zIndex = 0;
		} else {
			d.style.zIndex = 1;
			d.onkeyup = function (e) {
				var event = e || window.event;
				var key = event.keyCode || event.which;
				if (key == 27) this.style.display = "none";
			};
			d.show = function () {
				getDOM("base").popup = d.id;
				this.style.display = "block";
			};
			d.hide = function () {
				getDOM("base").popup = null;
				this.style.display = "none";
			};
			d.show();
		}
		d.onmousedown = function (e) {
			var event = e || window.event;
			event.stopPropagation();
			if (this.id == "base") {
				if (is.def(this.popup)) getDOM(this.popup).hide();
			}
		};
		d.tBodies[0].rows[0].cells[0].onmousedown = function () {
			if (this.className == "formTitle") {
				dragOBJ(this.parentNode.parentNode.parentNode);
			}
			return false;
		};
		if (is.def(data)) fillForm(data);
		d.style.position = "absolute";

		function evalDivSize2() {
			evalDivSize(d);
			// if (t == null) t = 5;
			if (t == null) t = 0;
			if (l == null) l = (_.body.clientWidth - d.clientWidth) / 2;
			d.style.top = t;
			d.style.left = l;
		}

		evalDivSize2();
		//setTimeout(evalDivSize2, 0);
	} else {
		if (isShowModalDialog) window.dialogTop = (screen.availHeight - parseInt(window.dialogHeight)) / 2 - 50;
		if (isShowModalDialog) window.dialogLeft = (screen.availWidth - parseInt(window.dialogWidth)) / 2;
		d.setAttribute("minWidth", "fill");
		d.setAttribute("minHeight", "fill");
		_.body.style.margin = "0px";
		_.body.style.background = _getStyle(_.body, "modal-background");
		_.body.className = "modal-background";
		if (typeof (data) != "undefined" && is.def(data)) fillForm(data);
		evalDivSize(d);
	}
	d.inited = true;
	return d;
}

/* hech qaysi polyaning yoki id ni nomi "v" bo`lmasligi kerak
 */
function fillForm(data) {
	/* e element, v qiymat, string yoki {v : value, ro : readonly, d : disable, c : color}
     */
	function setElValue(el, v) {
		if (is.def(v.c)) el.style.color = v.c;
		if (is.def(v.ro)) el.readOnly = v.ro != 0;
		/* agar ro == 0 bo`lsa readonly false bo`ladi
         */
		if (is.def(v.d)) el.disabled = v.d != 0;
		/* agar d == 0 bo`lsa disabled false bo`ladi
         */
		if (is.def(v.v)) v = v.v;
		if (el.setValue) {
			el.setValue(replaceQGH(v));
			if (el.check) el.check();
		} else {
			el.innerText = replaceQGH(v);
		}
	}

	for (var con in data) {
		var val = data[con], f, v, c, b, el, e;
		if (typeof val != "object" || is.def(val.v)) {
			setElValue(getDOM(con), val);
		} else {
			f = window[con];
			for (var elv in val) {
				try {
					v = val[elv];
					el = f[elv];
					if (is.array(v) && v.length != 0) {
						if (el.tagName) {
							c = 1;
							e = el;
							if (v.length == 1) {
								setElValue(el, v[0]);
								continue;
							}
						} else {
							c = el.length;
							e = el[0];
						}
						c = v.length - c;
						if (c < 0) {
							alert("fillForm: Error in form values");
							throw "err";
						}
						if (e.getAttribute("mbid")) {
							b = getDOM(e.getAttribute("mbid"));
							for (var i = 0; i < c; i++) b.click();
						}
						el = f[elv];
						for (var i = 0; i < v.length; i++) {
							try {
								setElValue(el[i], v[i]);
							} catch (ex) {
								alert("Incorrect data to fill form.");
							}
						}
					} else {
						if (typeof val[elv] === "object") {
							setElValue(el, val[elv]);
						} else {
							setDOMValue(el, val[elv]);
						}
					}
				} catch (e) {
					alert("Error: " + elv);
					throw e
				}
			}
		}
	}
	enableElements();
}

/* AJAX.load(d)
 * url		 	string - default _.URL.split("?")[0]
 * async	 	boolean - default false
 * HEAD		 	object
 * GET		 	object
 * POST		 	object
 * onSuccess	function
 * onError		function
 * method default GET, ketma ket bo`yicha HEAD, GET, POST
 * RT type exception, json, text, xml, script
 */
AJAX = ajax = {
	load: function (D) {
		var xhr = new XMLHttpRequest();
		mtd = "GET";
		if (is.def(D.HEAD)) mtd = "HEAD";
		if (is.def(D.GET)) mtd = "GET";
		if (is.def(D.POST)) mtd = "POST"; else D.POST = null;

		if (is.undef(D.url)) D.url = _.URL.split("?")[0];
		if (IEVersion() < 6) D.async = true; else if (is.undef(D.async)) D.async = false;

		D.url = nocacheURL(D.url);
		if (D.GET) {
			for (var v in D.GET) D.url += "&" + v + "=" + encodeURIComponent(D.GET[v]);
		}

		xhr.open(mtd, D.url, D.async);
		xhr.setRequestHeader("aj", "ax");
		setCSRF(xhr);
		if (D.HEAD) {
			for (var v in D.HEAD) xhr.setRequestHeader(v, D.HEAD[v]);
		}
		var post = null;
		if (D.POST) {
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			post = "";
			for (var v in D.POST) {
				var vl = makeArray(D.POST[v]);
				for (var i = 0; i < vl.length; i++) {
					post += v + "=" + encodeURIComponent(sanitize(vl[i])) + "&";
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
							eval(xhr.responseText);
							break;
						default:
							D.onSuccess(xhr.responseText);
					}
				} else {
					if (is.func(D.onError)) D.onError("Http status=" + xhr.status); else if (confirm("HTTP Status " + xhr.status + " - " + xhr.statusText)) window.open("").document.write(xhr.responseText);
				}
				if (is.def(D.callback)) {
					if (is.func(D.callback)) {
						D.callback(xhr.status);
					} else {
						alert(D.callback + " not a function");
					}
				}
			}
		};
		xhr.send(post);
	}
};

/* onLoad		function to call on document loading
 * onBeforeInit function init qilishdan oldin chaqiriladi
 * funcLoad		functions to call on document loading
 */
function openFileNotepad() {
	try {
		var TomcatFileUrl = TomcatURL + (_.URL.substring(_.URL.indexOf("/ibs/") + 1, _.URL.indexOf(".jsp") + 4));
		var activeXObj = new ActiveXObject("Shell.Application");
		activeXObj.ShellExecute("Notepad++.exe", TomcatFileUrl, "", "Open", "1");
	} catch (e) {
		/*alert(e);*/
	}
}

if (typeof document.documentElement.sourceIndex == "undefined") {
	HTMLElement.prototype.__defineGetter__("sourceIndex", (function (indexOf) {
		return function sourceIndex() {
			return indexOf.call(this.ownerDocument.getElementsByTagName("*"), this);
		};
	})(Array.prototype.indexOf));
}
/**fireEvent chrome va mozillada ishlamagnligi uchun uni qayta yozamiz*/
HTMLElement.prototype.fireEvent = function (event) {
	if (_.createEventObject) {
		var evt = _.createEventObject("Event");
		return this.fireEvent(event, evt)
	} else {
		var evt = _.createEvent("HTMLEvents");
		evt.initEvent(event.substring(2), true, true); // event type,bubbling,cancelable
		return this.dispatchEvent(evt);
	}
};
window.funcLoad = [];
window.onload = function (evt) {
	if (typeof onBeforeInit == "function") onBeforeInit();
	initForm("base", data);
	for (var i = 0; i < this.funcLoad.length; i++) this.funcLoad[i]();
	if (getDOM("base")) {
		evalDivSize(getDOM("base"));
	}
	if (typeof onLoad == "function") onLoad();
	_.body.onkeydown = function () {
		var e = event.target || event.srcElement;
		if (e == _locklayer || (event.keyCode == 8 && !((e.tagName == "INPUT" && (e.type == "text" || e.type == "password" || e.type == "file")) || e.tagName == "TEXTAREA" || e.tagName == "DIV"))) {
			event.returnValue = false;
			return false;
		}
		if (is.def(window.dialogArguments) || is.def(top.dialogArguments)) {
			if (event.keyCode == 27) { //esc
				window.returnValue = null;
				windowClose();
			}
		}
		if (event.keyCode == 112 && typeof onHelp == "function") {
			onHelp();
			window.event.keyCode = 0;
			return true;
		}
	};
	_.body.onmousedown = function () {
		if (event.srcElement == _locklayer) {
			event.returnValue = false;
			return false;
		}
	}
	if (typeof vfm != "undefined") {
		vfmDrawFields(vfm);
	}
	controlButtons();
};

function controlButtons() {
	if (typeof btns != "undefined") {
		btns = btns.buttons;
		for (var i = 0; i < btns.length; i++) {
			if (getDOM(btns[i].c)) {
				if (btns[i].a == "N") {
					hideDOM(getDOM(btns[i].c));
				} else if (btns[i].a == "Y") {
					showDOM(getDOM(btns[i].c));
				}
			}
		}
	}
}

function defHeightWidth(obj) {
	var h = w = x = y = 0;
	obj = is.string(obj) ? getDOM(obj) : obj;
	if (obj) {
		if (obj.getBoundingClientRect) {
			var rect = obj.getBoundingClientRect();
			x = rect.left;
			y = rect.top;
			w = rect.right - rect.left;
			h = rect.bottom - rect.top;
			return {
				x: x, y: y, h: h, w: w
			}
		}
	} else {
		return null;
	}
}

/* function lpad(str, length, symbol) kelgan stringi OLDIga symbol qo'yib qaytaradi
 * str bu keladigan string
 * length kelgan string uzunligi qancha bolishi kerak
 * symbol qaysi symbol qoyish kerarligi agar qiymat berilmasa probel(" ") qoyiladi
 */
function lpad(str, length, symbol) {
	if (is.undef(symbol)) symbol = " ";
	if (str.length > length) str = str.substring(0, length);
	for (var i = str.length; i < length; i++) {
		str = symbol + str;
	}
	return str;
}

/* function rpad(str, length, symbol) kelgan stringi ORQASIga symbol qo'yib qaytaradi
 * str bu keladigan string
 * length kelgan string uzunligi qancha bolishi kerak
 * symbol qaysi symbol qoyish kerarligi agar qiymat berilmasa probel(" ") qoyiladi
 */
function rpad(str, length, symbol) {
	if (is.undef(symbol)) symbol = " ";
	if (str.length > length) str = str.substring(0, length);
	for (var i = str.length; i < length; i++) {
		str = str + symbol;
	}
	return str;
}

/* function hideFirstLastButton()
 * tableControls birinchi va oxirgi pagega o'tish knopkalarini hide qilish
 */
function hideFirstLastButton() {
	var tagName = getDOM("tableControls").getElementsByTagName("button");
	for (i = 0; i < tagName.length; i++) {
		if (tagName[i].innerText == "\u23EA" || tagName[i].innerText == "\u23E9") hideDOM(tagName[i]);
	}
}

/* function formReadOnly(boolean)
 * bu formadagi hamma polyalarni readonly qiladi
 * va polyadagi request tozalab tashaydi
 * va submit knopkasi disable qiladi boshqa buttonlarga tegilmaydi
 * parametr boolean true bolsa select optionlari o'chiriladi "remove"
 * agar berilmasa optionla disabled qilinadi
 */
function formReadOnly(bool) {
	var inputs = ["input", "select", "textarea"];
	for (var i = 0; i < inputs.length; i++) {
		var obj = document.getElementsByTagName(inputs[i]);
		for (var j = 0; j < obj.length; j++) {
			if (obj[j].type == "text" || obj[j].type == "password" || inputs[i] == "textarea") {
				obj[j].setReadOnly(true);
				obj[j].request = "";
			} else if (inputs[i] == "select") {
				for (var s = obj[j].options.length - 1; s >= 0; s--) {
					if (obj[j].options[s].value != obj[j].value) {
						if (bool) {
							obj[j].remove(s);
						} else {
							obj[j].options[s].disabled = "disabled";
						}
					}
				}
			} else if (obj[j].type == "radio" && !obj[j].checked || obj[j].type == "submit") {
				obj[j].setDisable(true);
			}
		}
	}
}

/* function hexToBase64(str)
 * kelgan str(HEX)ni base 64 formatga otkazib beradi
 */
function hexToBase64(str) {
	if (!window.btoa) window.btoa = base64.encode;
	if (!window.atob) window.atob = base64.decode;
	return btoa(String.fromCharCode.apply(null, str.replace(/\r|\n/g, "").replace(/([\da-fA-F]{2}) ?/g, "0x$1 ").replace(/ +$/, "").split(" ")));
	//<img src='data:image/x-ms-bmp;base64,"+hexToBase64(plugin().get_img_url())+"'>"
}

function createLockLayer() {
	var l = _.createElement("div");
	l.className = "locklayer";
	l.setSize = function (w, h) {
		this.style.left = 0;
		this.style.top = 0;
		this.style.width = w + "px";
		this.style.height = h + "px";
	};
	return l;
}

/* function pageLock(state)
 * state true to lock page
 */
function pageLock(state) {
	if (is.undef(_locklayer)) {
		_locklayer = createLockLayer();
		_.body.appendChild(_locklayer);
		_locklayer.onblur = function () {
			if (is.undef(this.counter)) {
				this.counter = 0;
			}
			if (this.counter <= 3) {
				if (this.style.display == "block") this.focus();
				this.counter++;
			} else {
				this.counter = 0;
			}
		};
	}
	_locklayer.setSize(_.body.scrollWidth, _.body.scrollHeight);
	if (state) {
		_locklayer.style.display = "block";
		_locklayer.focus();
	} else {
		_locklayer.style.display = "none";
	}
}

/* function pos(object, direction)
 * direction = "Left" | "Top";
 * absolute positionni hissoblash uchun
 */
function pos(o, d) {
	var z = 0;
	do {
		z += o["offset" + d] + o["client" + d];
	} while (o == o.offsetParent);
	return z;
}

function drawMenu(menu, x, y, pr) {
	var cnt = _.createElement("span"), mo = _.createElement("table");
	cnt.appendChild(mo);
	cnt.style.position = "absolute";
	cnt.style.zIndex = 11;
	cnt.classList = "openedMenu";
	mo.cellSpacing = 2;
	mo.className = "Menu";
	mo.onselectstart = new Function("return false");
	/* mo.onmouseover = function(e) {
        var event = e || window.event;
        event.stopPropagation();
    };*/
	mo.onmouseoout = function (e) {
		var event = e || window.event;
		event.stopPropagation();
	};
	for (var m in menu) {
		var mi = mo.insertRow(), mia;
		mi.tag = menu[m];
		if (is.undef(menu[m].label)) {
			mia = mi.insertCell();
			mia.className = "MenuSeparator";
			mia.innerHTML = "&nbsp;";
			mi._SEP = "T";
			continue;
		}
		mia = "<table width=100% cellpadding=0 cellspacing=0><tr><td nowrap>" + menu[m].label;
		if (mi.tag.items) {
			mia += "<td class=MenuArrow>&#9654;";
		}
		mia += "</table>";
		mi.insertCell().innerHTML = mia;
		mi.cells[0].className = "MenuItem";
		mi._M = true;
		mi.onmouseover = function () {
			var t = this, c = t.parentNode.rows, r;
			for (var i = 0; i < c.length; i++) {
				r = c[i];
				if (r != t && r._SEP != "T") {
					r.cells[0].className = "MenuItem";
					if (r.items) {
						r.items.parentNode.removeChild(r.items);
						r.items = null;
					}
				}
			}
			t.cells[0].className = "MenuItemHover";
			if (t.tag.items) {
				if (!t.items) t.items = drawMenu(t.tag.items, t.offsetWidth, t.offsetTop, t.cells[0]);
			}
		};
		mi.onclick = function (e) {
			var event = e || window.event;
			if (is.def(event)) event.stopPropagation();
			remOpenMenu();
			/* var o = this;
             while (!(o.tagName == "SPAN" && o._TOP == "T")) o = o.parentNode;
             o.parentNode.removeChild(o);*/
			if (is.func(this.tag.action)) this.tag.action();
		}
	}
	var z = 0, w = 150;
	pr = nvl(pr, _.body);
	pr.appendChild(cnt);
	if (pr != _.body) {
		z = goParent(cnt, 4).clientWidth;
	}
	cnt.style.left = x;
	cnt.style.top = y;
	if (mo.clientWidth > w) w = mo.clientWidth;
	mo.style.width = w + "px";
	if (_.body.clientWidth < pos(cnt, "Left") + mo.offsetWidth) {
		x = x - mo.offsetWidth - z;
	}
	z = _.body.clientHeight - pos(cnt, "Top") - mo.offsetHeight;
	if (z < 0) {
		y = y + z;
	}
	cnt.style.left = x;
	cnt.style.top = y;
	var ll = createLockLayer();
	cnt.appendChild(ll);
	ll.setSize(mo.offsetWidth, mo.offsetHeight);
	ll.style.display = "block";
	if (pr == _.body || pr.tagName == "SPAN") {
		cnt.focus();
		cnt._TOP = "T";
		/* TODO hato shu clickda
         */
		cnt.onmousedown = function (e) {
			let event = e || window.event;
			if (is.def(event) && is.def(event.target)) {
				if (!(is.def(event.target.tagName) && event.target.tagName == "TD")) {
					event.stopPropagation();
					remOpenMenu();
				}
			}
			/*var event = e || window.event;
            var o = event.target || event.srcElement,
                i = 0;
            while (is.def(o) && (!(o.tagName == "TR" && o._M) || i++ > 1)) o = o.parentNode;
            if (is.def(o) && o._M) {
                o.onclick();
            }*/
		};
		cnt.onblur = function () {
			this.parentNode.removeChild(this);
		}
	}
	return cnt;
}

function drawTab2(tab, asTab) {
	var cnt = getDOM("tabControls"), ti;

	/*----function showMenu----*/
	function showMenu(t) {
		t.style.background = _getStyle(t, "background-hover");
		t.style.border = _getStyle(t, "border-outset");
		remOpenMenu();
		for (var v in tab) {
			if (ti.tag.items) {
				_.body.focus();
				break
			}
		}
		if (t.tag.items) {
			drawMenu(t.tag.items, t.offsetParent.offsetLeft + t.offsetLeft, t.offsetParent.offsetTop + t.offsetTop + t.offsetHeight + 3, t);
		}
	}

	for (var v in tab) {
		ti = _.createElement("span");
		ti.className = "tab";
		ti.onselectstart = new Function("return false");
		ti.tag = tab[v];
		ti.asTab = nvl(asTab, false);
		ti.selected = false;
		if (is.def(tab[v].label)) ti.innerHTML = tab[v].label;
		cnt.appendChild(ti);
		/*----onmouseout----*/
		ti.onmouseout = function () {
			if (!this.selected) {
				this.style.background = "#EBE9E6";
				this.style.border = "1px solid #EBE9E6";
			}
		};

		/*----onmouseover----*/
		ti.addEventListener("mouseenter", function () {
			showMenu(this);
		});

		ti.addEventListener("mouseleave", function () {
			var t = this;
			for (var i = 0; i < t.children.length; i++) {
				t.children.item(i).remove();
			}
		});

		ti.addEventListener("click", function () {
			for (var i = 0; i < this.children.length; i++) {
				this.children.item(i).remove();
			}
		});

		ti.unSelect = function () {
			this.style.background = "#EBE9E6";
			this.style.border = "1px solid #EBE9E6";
			this.style.fontWeight = "";
			this.selected = false;
		};
		ti.Select = function () {
			this.style.background = "#eee";
			this.style.border = "1px solid #bebdbd";
			this.style.fontWeight = "bold";
			this.selected = true;
			this.parentNode.selectedTab = this;
		};
		/*----onclick----*/
		if (ti.tag.action) {
			ti.onclick = function () {
				if (this.asTab) {
					var tabs = this.parentNode.children;
					for (var i = 0; i < tabs.length; i++) {
						if (tabs[i] == this) tabs[i].Select(); else tabs[i].unSelect();
					}
				}
				this.tag.action();
			};
		} else {
			ti.onclick = function () {
				showMenu(this);
			};
		}
	}
}

function removedActiveMenus() {
	let elms = _.querySelectorAll("#tabControls .parent.active");
	if ((is.def(elms)) && (elms.length > 0)) {
		for (let i = 0; i < elms.length; i++) {
			removeActive(elms[i]);
		}
	}
	remOpenMenu();
}

function performFunc(d) {
	d = unescape(d);
	removedActiveMenus();
	var f = undefined;
	if (is.string(d)) {
		f = eval("(" + d + ")");
	}
	if (is.func(d)) {
		d();
	} else if (is.func(f)) {
		f();
	}
}

function drawTab(data) {
	let div = "", t = "", cl = "";
	div += "<ul id='menu'>";

	function dtab(data) {
		for (var i = 0; i < data.length; i++) {
			if (is.array(data[i].items) && data[i].items.length > 0) {
				t = "<span class='expand'>&#155;</span>";
			} else {
				t = "";
			}
			if (is.def(data[i].action)) {
				if (is.func(data[i].action)) {
					cl = "onclick=performFunc(\"" + escape(String(data[i].action)) + "\")";
				} else {
					cl = "onclick='removedActiveMenus(); " + data[i].action + "'";
				}
			} else {
				cl = "";
			}
			div += "<li class='parent' onmouseover='openMenu(this)' onmouseout='removeActive(this)'><a " + cl + "><div>" + data[i].label + "</div>" + t + "</a>";
			if (is.array(data[i].items) && data[i].items.length > 0) {
				div += "<ul class='child'>";
				dtab(data[i].items);
			} else {
				div += "</li>";
			}
		}
		div += "</ul>";
	}

	if (is.hash(data)) {
		dtab(data.items);
	} else {
		dtab(data);
	}
	div += "</ul>";
	if (div != "") {
		getDOM("tabControls").innerHTML = div;
	}
}

function openMenu(el) {
	addActive(el);
	fixMenuPos(el);
}

function fixMenuPos(el) {
	let child = el.getElementsByClassName("child")[0];
	if (is.def(child)) {
		let parw = elx = chldw = space = ifraw = "";
		parw = getDOM("tabControls").offsetWidth;
		elx = el.offsetLeft;
		space = parw - elx;
		ifraw = window.frameElement.offsetWidth;
		if (ifraw > parw) {
			parw = ifraw;
		}
		child.style.removeProperty("left");
		child.style.removeProperty("width");
		if (el.parentNode.id == "menu") {
			chldw = child.offsetWidth;
			if (space < chldw) {
				child.style.left = space - chldw - 1;
				child.setAttribute("spacex", "0");
			} else {
				child.setAttribute("spacex", (elx + chldw));
			}
			child.setAttribute("elw", chldw);
		} else {
			let elw = 0;
			let inpTxt = "";
			child.childNodes.forEach(function (item) {
				inpTxt = item.querySelector("a > div") ? item.querySelector("a > div").innerHTML : "";
				if (getWidthByText(inpTxt) > elw) elw = getWidthByText(inpTxt);
			});
			let pelw = 0;
			let spacex = parseInt(goParent(el).getAttribute("spacex"));
			if (is.def(child.getAttribute("elw"))) {
				pelw = parseInt(child.getAttribute("elw"));
			}
			if (spacex == 0) {
				child.style.left = pelw * (-1) + "px";
				child.style.width = parseInt(child.getAttribute("elw")) + 15;
			} else if (parw < (spacex + elw)) {
				child.setAttribute("spacex", spacex);
				child.style.left = pelw * (-1) + "px";
				child.style.width = parseInt(child.getAttribute("elw")) + 15;
			} else {
				child.setAttribute("spacex", (spacex + elw));
			}
			child.setAttribute("elw", elw);
		}
	}
}

function showTab(event, lang) {
	event.preventDefault();
	var container = event.target.closest(".multilang-container");
	var currentPanel = container.querySelector(".multilang-panel.active");
	if (currentPanel) {
		var currentTextarea = currentPanel.querySelector("textarea");
		if (currentTextarea && currentTextarea.hasAttribute("r")) {
			if (!currentTextarea.value.trim()) {
				currentTextarea.focus();
				currentTextarea.setError(true);
				setTimeout(function () {
					currentTextarea.setError(false);
				}, 2000);
				return false; // O'tkazmaslik
			}
		}
	}
	container.querySelectorAll(".multilang-tabs li").forEach(li => {
		li.classList.remove("active");
	});
	event.target.parentElement.classList.add("active");
	container.querySelectorAll(".multilang-panel").forEach(panel => {
		panel.classList.remove("active");
	});
	var panel = container.querySelector("#panel-" + lang) ||
		container.querySelectorAll(".multilang-panel")[getTabIndex(event.target)];
	if (panel) {
		panel.classList.add("active");
		var textarea = panel.querySelector("textarea");
		if (textarea) {
			textarea.focus();
		}
	}
}

function getTabIndex(tab) {
	var tabs = tab.closest(".multilang-tabs");
	var index = 0;
	tabs.forEach((t, i) => {
		if (t.contains(tab)) index = i;
	});
	return index;
}

function getWidthByText(txt) {
	font = "16px times new roman";
	canvas = document.createElement("canvas");
	context = canvas.getContext("2d");
	context.font = font;
	width = context.measureText(txt).width;
	return Math.ceil(width);
}

function addActive(el) {
	if (!hasClass(el, "active")) el.classList.add("active");
}

function removeActive(el) {
	if (is.def(el)) {
		if (hasClass(el, "active")) el.classList.remove("active");
	}
}

function hasClass(element, className) {
	return (" " + element.className + " ").indexOf(" " + className + " ") > -1;
}

function printPreview(url) {
	go({
		url: url,
		target: "new",
		lock: false,
		arg: "left=0, top=0, width=" + (screen.availWidth - 10) + ", height=" + (screen.availHeight - 70) + ", scrollbars=1,directories=0,location=0,menubar=1,resizable=1,status=1,titlebar=0,toolbar=0"
	});
}

function editFormLanguages(val) {
	window.open(nvl(__contextPath, "") + "/mlmhelper.jsp?fileUrl=" + val, "", "width=" + screen.availWidth + "; height=" + screen.availHeight + ";");
}

const cssVariables = {
	"button-background": "#F1F1F5",
	"button-background-hover": "#4C81B5",
	"button-border": "none",
	"input-border": "1px solid #C8CFDD",
	"input-border-error": "1px solid #E11A1A",
	"input-background": "#ffffff",
	"input-background-focus": "#ffffff",
	"input-background-error": "#ffffff",
	"input-background-disabled": "#F8F9FC",
	"background-hover": "#F1EFED",
	"border-inset": "1px inset #ffffff",
	"border-outset": "1px outset #ffffff",
	"modal-background": "#ffffff",
	"main-font": "'Open Sans', sans-serif"
};

//-- Cross browser method to get style properties:
function _getStyle(el, property) {
	if (window.getComputedStyle) {
		if (isCross()) {
			var view = el.ownerDocument.defaultView;
			if (!view || !view.opener) {
				view = window;
			}
			return view.getComputedStyle(el).getPropertyValue("--" + property);
		} else {
			return cssVariables[property];
		}
	}
	if (el.currentStyle) {
		return el.currentStyle[property];
	}
}

// Id si bir xil elementlar idlarinio'zgartirish, bu faqat idsi va name bir xil elementlar uchun
function replaceSameID(name) {
	let allEl = document.querySelectorAll('input[name="' + name + '"]');
	if (is.def(allEl)) {
		if (allEl.length > 1) {
			for (var i in allEl) {
				if (i > 0) allEl[i].id = name + i;
			}
		}
	}
}

// avval ochiq qolib ketgan menularni remove qiladi
function remOpenMenu() {
	let elements = _.getElementsByClassName("selCheckbox");
	if (is.def(elements)) {
		while (elements.length > 0) {
			elements[0].parentNode.removeChild(elements[0]);
		}
	}

	let el = _.getElementsByClassName("openedMenu");
	if (is.def(el)) {
		while (el.length > 0) {
			el[0].parentNode.removeChild(el[0]);
		}
	}
}

function isCross() {
	var ua = window.navigator.userAgent;
	var msie = ua.indexOf("MSIE ");
	var trident = ua.indexOf("Trident/");
	return !(msie > 0 || trident > 0);
}

/*
top._t().CACHE = top._t().CACHE || {
	uc: {},
	gn: function (d, n) {
		if (is.number(n))
			n = d.URL.split("?")[0] + n;
		return n
	},
	put: function (d, n, s) {
		this.uc[this.gn(d, n)] = s;
		d.write(s);
	},
	get: function (d, n) {
		d.write(this.uc[this.gn(d, n)])
	}
};
*/
function setCookie(cname, cvalue, exdays, path) {
	if (!is.def(cvalue)) {
		cvalue = ""
	}
	if (!is.number(exdays)) {
		exdays = 1
	}
	if (!is.def(path)) {
		path = "/"
	}
	var d = new Date();
	d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
	var expires = "expires=" + d.toUTCString();
	window.document.cookie = cname + "=" + cvalue + ";" + expires + ";path=" + path;
}

function getCookie(cname) {
	var name = cname + "=";
	var ca = window.document.cookie.split(";");
	for (var i = 0; i < ca.length; i++) {
		var c = ca[i];
		while (c.charAt(0) == " ") {
			c = c.substring(1);
		}
		if (c.indexOf(name) == 0) {
			return c.substring(name.length, c.length);
		}
	}
	return "";
}

function isVisible(element) {
	while (element) {
		const style = window.getComputedStyle(element);
		if (style.display === "none" || style.visibility === "hidden") {
			return false; // Agar parent elementlaridan biri display: none bo'lsa yoki visibility: hidden bo'lsa, element ko'rinmas
		}
		element = element.parentElement;
	}
	return true;
}

function setFocus(form, index, way) {
	let tabIndex, readOnly, max, type, nextEl, disabled, display, nextIndex;
	max = form.elements.length;
	if (way) {
		nextIndex = index + 1;
		if (nextIndex >= max) {
			index = 0;
			nextIndex = index + 1;
		}
	} else {
		nextIndex = index - 1;
		if (nextIndex <= 0) {
			index = max;
			nextIndex = index - 1;
		}
	}
	nextEl = form.elements[nextIndex];
	tabIndex = nextEl.getAttribute("tabindex");
	readOnly = nextEl.getAttribute("readOnly");
	type = nextEl.getAttribute("type");
	disabled = nextEl.getAttribute("disabled");
	display = nextEl.style.display;
	if (!type && nextEl.tagName === "INPUT") {
		type = "text";
	}
	if (type) {
		type = type.toLowerCase();
	}
	if (nextEl.tagName !== "FIELDSET" && display !== "none" && type !== "checkbox" && isVisible(nextEl)) {
		if ((tabIndex > -1) && (readOnly == null) && (disabled == null) && type !== "hidden" && (nextEl.tagName === "INPUT" || nextEl.tagName === "SELECT" || nextEl.tagName === "TEXTAREA" || nextEl.tagName === "BUTTON")) {
			nextEl.focus();
			nextEl.focus();
		} else {
			setFocus(form, nextIndex, way);
		}
	} else {
		setFocus(form, nextIndex, way);
	}
	event.preventDefault();
}

document.addEventListener("keydown", function (event) {
	const nodeName = event.target.nodeName;
	//console.log(nodeName);

	if (nodeName === "INPUT" || nodeName === "SELECT" || nodeName === "TEXTAREA" || nodeName === "BUTTON") {
		if (event.shiftKey && event.key === "Tab") {
			const form = event.target.form;
			if (is.undef(form)) return;
			const index = Array.prototype.indexOf.call(form, event.target);
			setFocus(form, index, false);
		} else if (!event.shiftKey && (event.keyCode === 9 || event.keyCode === 13)) {
			try {
				const nodeName = event.target.nodeName;
				const type = event.target.getAttribute("type");
				if (nodeName !== "BUTTON" && !(nodeName === "INPUT" && (type === "button" || type === "reset" || type === "submit"))) {
					const form = event.target.form;
					if (is.undef(form)) return;
					const index = Array.prototype.indexOf.call(form, event.target);
					setFocus(form, index, true);
				}
			} catch (e) {
				console.log(e);
			}
		}
	}
});
window.addEventListener("scroll", function () {
	const toolbar = document.querySelector(".formToolbar");
	if (window.scrollY > 10) {
		toolbar.classList.add("scrolled");
	} else {
		toolbar.classList.remove("scrolled");
	}
});

function sumToWord(obj, currency) {
	try {
		AJAX.load({
			url: "/ibs/main.jsp",
			POST: {
				request: "get_sum_to_word",
				sum: obj.value.replace(/\s/g, "").replace(/,/g, "."),
				currency: currency
			},
			onSuccess: function (sum_text) {
				var formGroup = obj.closest(".form-group");
				if (!formGroup) return;

				// Span mavjudmi tekshirish
				var span = formGroup.querySelector(".form-amount-text");
				if (!span) {
					span = document.createElement("span");
					span.className = "form-amount-text";
					formGroup.appendChild(span);
					formGroup.classList.add("has-amount-text");
				}
				setDOMValue(span, sum_text);
				span.setAttribute("title", replaceQGH(sum_text));
			},
			onError: function (d) {
				alert(d);
			}
		});
	} catch (e) {
		alert("object: " + obj.name + "\n" + e);
	}
}

/*Virtual Field Manager*/

function vfmToggle(l) {
	let c, i;
	i = l.getElementsByTagName("span")[0];
	c = getDOM("vfm-content");
	if (c.style.display === "none") {
		i.innerHTML = "&#x25B2;";
		showDOM(c);
	} else {
		i.innerHTML = "&#x25BC;";
		hideDOM(c);
	}
}

function vfmDrawFields(o) {
	let s, c, j, q, v, attr = "", d, val, req = [];
	if (is.hash(o)) {
		j = o.d;
		d = o.v;
	} else {
		return false;
	}
	if (j.length === 0) {
		hideDOM("vfm");
		return false;
	}

	s = '<table><colgroup><col width="30%" style="text-align:right" /><col width="70%" /></colgroup><tbody>';
	c = getDOM("vfm-content");

	j.forEach(l => {
		attr = getAttr(l);
		val = getVal(l.n);
		if (is.def(val) && (val != "")) {
			v = val;
		} else {
			(is.def(l.v)) ? v = l.v : v = "";
		}
		(l.r === "Y") ? q = "<q>*</q>" : q = "";
		s += "<tr><td>" + l.l + q + ":</td><td>";
		if (l.t === "text" || l.t === "password" || l.t === "email" || l.t === "number" || l.t === "date" || l.t === "file") {
			if (is.def(v)) {
				attr += 'value="' + v + '" ';
			}
			if ((l.t === "date") || (l.t === "number")) {
				s += '<input type="text" ' + attr + ' />';
			} else {
				s += '<input type="' + l.t + '" ' + attr + ' />';
			}
			if ((l.t === "date") && (l.p === "Y")) {
				s += '- <input type="text" ' + attr + ' />';
			}
			if ((l.t === "text") && (is.def(l.vn))) {
				s += ' <input type="text" name="' + l.n + '_name" size="60" tabindex="-1" readonly /> <code>(F9)</code>';
			}
			// if(l.t === "date") {
			// s += ' <img class="cbutton" src="/ibs/user/util/calendar/icon/calendar_ico.bmp" onclick="ShowCalendar('+ l.n +')" />';
			// }
		} else if (l.t === "select") {
			s += '<select ' + attr + '>';
			if (l.o_v !== "") {
				let a;
				l.o_v.forEach(m => {
					if (m.s === "Y" && v == "") {
						a = "selected";
					} else if (v == m.v) {
						a = "selected";
					} else {
						a = "";
					}
					s += '<option value="' + m.v + '" ' + a + '>' + m.l + '</option>';
				});
			} else if (l.o_t !== "") {
				s += l.o_t;
			}
			s += "</select>";
		} else if (l.t === "textarea") {
			s += '<textarea ' + attr + '>' + v + '</textarea>';
		} else if (l.t === "checkbox-group") {
			let a;
			l.o_v.forEach((m, i) => {
				if (m.s === "Y" && v.length < 1) {
					a = "checked";
				} else if ((is.array(v)) && (v.indexOf(m.v) > -1)) {
					a = "checked";
				} else {
					(v === m.v) ? a = "checked" : a = "";
				}
				s += '<input type="checkbox" id="' + l.n + '_' + i + '" name="' + l.n + '" ' + a + ' value="' + m.v + '" />';
				s += '<label for="' + l.n + '_' + i + '">' + m.l + '</label><br />';
			});
		} else if (l.t === "radio-group") {
			let a;
			l.o_v.forEach((m, i) => {
				if (m.s === "Y" && v == "") {
					a = "checked";
				} else if (v == m.v) {
					a = "checked";
				} else {
					a = "";
				}
				s += '<input type="radio" id="' + l.n + '_' + i + '" name="' + l.n + '" ' + a + ' value="' + m.v + '" />';
				s += '<label for="' + l.n + '_' + i + '">' + m.l + '</label><br />';
			});
		} else {
			alert("Error. Anonym Field type: " + l.t);
		}
		s += "</td></tr>";
	});
	s += "</tbody></table>";
	c.innerHTML = s;
	initDOM(c);

	req.map(l => {
		callRequest(getDOM(l));
	});

	function getVal(n) {
		let c;
		d.forEach(l => {
			Object.entries(l).forEach(([k, v]) => {
				if (k === n) {
					c = v;
				}
			});
		});
		return c;
	}

	function getAttr(o) {
		let a = "", s = "";
		Object.entries(o).forEach(([k, v]) => {
			switch (k) {
				case "t":
					a += 'type="' + v + '" ';
					break;	// t - type
				case "r":
					(v === "Y") ? a += 'r = "1" ' : a += '';
					break;	// r - required
				case "m":
					a += 'mask="' + v + '" ';
					break;	// m - mask
				case "n":
					a += 'name="' + v + '" ';
					break;	// n - fname
				case "tl":
					a += 'title="' + v + '" ';
					break;	// tl - title
				case "ml":
					a += 'maxlength="' + v + '" ';
					break;	// ml - maxlength
				case "mt":
					a += "multiple ";
					break;	// mt - multiple
				case "mn":
					a += 'min = "' + v + '" ';
					break;	// mn - min
				case "mx":
					a += 'max = "' + v + '" ';
					break;	// mx - max
				case "st":
					a += 'step = "' + v + '" ';
					break;	// st - step
			}
			if (k === "a") {														// a - align
				switch (v) {
					case "l":
						s += "text-align:left; ";
						break;
					case "c":
						s += "text-align:center; ";
						break;
					case "r":
						s += "text-align:right; ";
						break;
				}
			} else if (k === "s") {												// s - size if type textarea rows,cols
				if (o.t === "textarea") {
					a += 'rows = "' + v.split(",")[0] + '" ';
					a += 'cols = "' + v.split(",")[1] + '" ';
				} else {
					a += 'size = "' + v + '" ';
				}
			} else if (k === "vn") {												// vn - view name
				let rq, rf, h;
				if (is.undef(getDOM("vfm" + o[k]))) {
					h = _.createElement("input");
					h.setAttribute("type", "hidden");
					h.setAttribute("id", "vfm" + o[k]);
					h.setAttribute("name", "vfm" + o[k]);
					h.setAttribute("value", o[k]);
					fm.appendChild(h);
				}
				rq = `request="{name:'vfm_req', get:{view_name:'` + o[k] + `', code:fm.` + o.n + `}, put:[fm.` + o.n + `_name],url:'/ibs/vfm/jsp/vfm_req_ref.jsp'}"`;
				rf = `reference="{name:'vfm_ref',get:{view_name:'` + o[k] + `', f1:fm.` + o.n + `}, put:[fm.` + o.n + `,fm.` + o.n + `_name],url:'/ibs/vfm/jsp/vfm_req_ref.jsp'}"`;
				req.push(o.n);
				a += rq + rf;
			}
		});
		a += ' style="' + s + '"';
		return a;
	}
}

/*------------------------start hashtable --------------------------------*/
var hash = function (string, max) {
	var hash = 0;
	for (var i = 0; i < string.length; i++) {
		hash += string.charCodeAt(i);
	}
	return hash % max;
};
var HashTable = function () {
	var storage = [];
	var storageLimit = 1;
	var keys = [];
	this.print = function () {
		console.log(storage);
	};
	this.put = function (key, value) {
		var index = hash(key, storageLimit);
		if (storage[index] === undefined) {
			storage[index] = [[key, value]];
		} else {
			var inserted = false;
			for (var i = 0; i < storage[index].length; i++) {
				if (storage[index][i][0] === key) {
					storage[index][i][1] = value;
					/* bu keyga value qo'yayotganda agar bo'lsa boshqa qo'ymasligi uchun*/
					inserted = true;
				}
			}
			if (inserted === false) {
				storage[index].push([key, value]);
			}
		}
	};
	this.remove = function (key) {
		var index = hash(key, storageLimit);
		if (storage[index].length === 1 && storage[index][0][0] === key) {
			delete storage[index];
		} else {
			for (var i = 0; i < storage[index].length; i++) {
				if (storage[index][i][0] === key) {
					delete storage[index][i];
				}
			}
		}
	};
	this.get = function (key) {
		try {
			var index = hash(key, storageLimit);
			if (isUndef(storage[index])) {
				return "";
			} else {
				for (var i = 0; i < storage[index].length; i++) {
					if (storage[index][i][0] === key) {
						return (isUndef(storage[index][i][1]) ? "" : storage[index][i][1]);
					}
				}
			}
		} catch (e) {
			return "";
		}
	};
	this.has = function (key) {
		var index = hash(key, storageLimit);
		if (storage[index] === undefined) {
			return false;
		} else {
			for (var i = 0; i < storage[index].length; i++) {
				if (storage[index][i][0] === key) {
					return true;
					break;
				} else {
					return false;
					break;
				}
			}
		}
	};
};

//----------------------------------------
function size(w) {
	let r = document.querySelector(":root");
	let rs = getComputedStyle(r);
	let i = rs.getPropertyValue("--index");
	return (i * w);
}

//----------------------------------------WEBSOCKET
window.FBWebSocket = function (url) {
	var iabsClientUrl = "localhost:8088/app";
	this.url = is.undef(url) ? iabsClientUrl : url;
	var obj = this;
	var ws = null;
	var callbackFunc;
	var callbackFuncs = [];
	var readyState;/*0-connection,1-open,2-closing,3-closed*/
	var iabsClientVersion = "";
	this.runWS = function () {
		if (window["WebSocket"]) {
			ws = new WebSocket("ws://" + obj.url);
			ws.onopen = function (d) {
				obj.readyState = d.currentTarget.readyState;
				if (obj.isIabsClientWS()) {
					obj.sendMSG(JSON.stringify({"action": "getVersion"}), obj.setIabsClientVersion);
				}
			};
			ws.onmessage = function (d) {
				obj.resultData(d);
			};
			ws.onclose = function (d) {
				obj.readyState = d.currentTarget.readyState;
				console.log("Conection closed Reason:", d);
			};
			ws.onerror = function (e) {
				obj.readyState = e.currentTarget.readyState;
				console.log("WebSocket error observed:", e);
			};
		} else {
			console.log("Your browser not supported WebSocket");
		}
		;
	};
	this.isOpenWS = function () {
		if (obj.hasWS()) {
			return obj.readyState == 1;
		} else {
			return false;
		}
	};
	this.isIabsClientWS = function () {
		return obj.url == iabsClientUrl;
	};
	this.hasWS = function () {
		return ws != null;
	};
	this.sendMSG = function (stringData, callback, uid) {
		if (!obj.isOpenWS()) {
			return;
		}
		ws.send(stringData);
		if (is.def(uid)) {
			if (is.func(callback)) {
				callbackFuncs[uid] = callback;
			}
		} else {
			if (is.func(callback)) {
				callbackFunc = callback;
			}
		}
	};
	this.execCallbackFunc = function (responseMsg) {
		if (is.def(responseMsg["uid"])) {
			var vRUid = responseMsg["uid"];
			if (is.func(callbackFuncs[vRUid])) {
				callbackFuncs[vRUid](responseMsg);
			}
		} else {
			if (is.func(callbackFunc)) {
				callbackFunc(responseMsg);
				callbackFunc = null;
			}
		}
	};
	this.resultData = function (d) {
		var responseMsg = JSON.parse(d.data);
		obj.execCallbackFunc(responseMsg);
	};
	this.setIabsClientVersion = function (d) {
		if (d["action"] == "getVersion") {
			iabsClientVersion = d["responseBody"];
		}
	};
	this.getIabsClientVersion = function () {
		return iabsClientVersion;
	};

	this.loadListForSearch = function (data) {
		obj.sendMSG(JSON.stringify({"action": "load", "data": data}));
	};
	this.searchData = function (data, callback, isTurnOnSmartSearch, isGlobalSearch) {
		data.searchMode = "normal";
		if (isTurnOnSmartSearch) {
			data.searchMode = "smart";
		}
		obj.sendMSG(JSON.stringify({"action": (isGlobalSearch) ? "globalSearch" : "search", "data": data}), callback);
	};
	this.getIPData = function (callback) {
		obj.sendMSG(JSON.stringify({"action": "getData"}), callback);
	};
	this.hashCode = function (txt) {
		var hash = 0, i, chr;
		if (txt.length === 0) return hash;
		for (i = 0; i < txt.length; i++) {
			chr = txt.charCodeAt(i);
			hash = ((hash << 5) - hash) + chr;
			hash |= 0; // Convert to 32bit integer
		}
		return hash;
	};
	this.signedMsg = function (queryLine, callback) {
		var vUid = obj.hashCode(queryLine);
		obj.sendMSG(JSON.stringify({
			"action": "signMessage", "uid": vUid, "data": {"signMessage": queryLine}
		}), callback, vUid);
	};
	this.signedMsgByStyx = function (queryLine, callback) {
		obj.sendMSG(JSON.stringify({"function": "cryptoSign", "obj": queryLine}), callback);
	};
	this.main = function () {
		obj.runWS();
	};
	/*-----------------------------------*/
	obj.main();
};

function sanitize(str) {
	var temp = document.createElement("div");
	temp.textContent = str;
	return temp.innerHTML;
}

(function () {
	document.querySelectorAll("a").forEach(link => {
		if (link.href == "" || is.undef(link.href)) return;
		const url = new URL(link.href);
		url.searchParams.append("x-csrf-token", getCookie("x-csrf-token"));
		link.href = url.toString();
	});
	document.querySelectorAll("iframe").forEach(frame => {
		if (frame.href == "" || is.undef(frame.href)) return;
		const url = new URL(frame.src);
		url.searchParams.append("x-csrf-token", getCookie("x-csrf-token"));
		frame.src = url.toString();
	});
})();

Object.defineProperty(window, "replaceQGH", {writable: false, configurable: false});
Object.defineProperty(window, "getDOM", {writable: false, configurable: false});
Object.defineProperty(window, "hideDOM", {writable: false, configurable: false});
Object.defineProperty(window, "showDOM", {writable: false, configurable: false});
Object.defineProperty(window, "disableElements", {writable: false, configurable: false});
Object.defineProperty(window, "setDOMValue", {writable: false, configurable: false});
Object.defineProperty(window, "getDOMValue", {writable: false, configurable: false});
Object.defineProperty(window, "is", {writable: false, configurable: false});
Object.defineProperty(window, "goParent", {writable: false, configurable: false});
Object.defineProperty(window, "JsonToString", {writable: false, configurable: false});
Object.defineProperty(window, "makeArray", {writable: false, configurable: false});
Object.defineProperty(window, "nocacheURL", {writable: false, configurable: false});
Object.defineProperty(window, "go", {writable: false, configurable: false});
Object.defineProperty(window, "showModalDialog2", {writable: false, configurable: false});
Object.defineProperty(window, "fixfilterModalSize", {writable: false, configurable: false});
Object.defineProperty(window, "getMaxHeight", {writable: false, configurable: false});
Object.defineProperty(window, "getIframeLastIndex", {writable: false, configurable: false});
Object.defineProperty(window, "getIframeNextIndex", {writable: false, configurable: false});
Object.defineProperty(window, "getWindowParent", {writable: false, configurable: false});
Object.defineProperty(window, "getTopWindow", {writable: false, configurable: false});
Object.defineProperty(window, "parseMask", {writable: false, configurable: false});
Object.defineProperty(window, "showReference", {writable: false, configurable: false});
Object.defineProperty(window, "formatNumber", {writable: false, configurable: false});
Object.defineProperty(window, "callRequest", {writable: false, configurable: false});
Object.defineProperty(window, "setCaret", {writable: false, configurable: false});
Object.defineProperty(window, "maskGetValue", {writable: false, configurable: false});
Object.defineProperty(window, "maskSetValue", {writable: false, configurable: false});
Object.defineProperty(window, "maskkeydown", {writable: false, configurable: false});
Object.defineProperty(window, "maskkeypress", {writable: false, configurable: false});
Object.defineProperty(window, "getSelectionText", {writable: false, configurable: false});
Object.defineProperty(window, "maskchange", {writable: false, configurable: false});
Object.defineProperty(window, "maskfocus", {writable: false, configurable: false});
Object.defineProperty(window, "maskblur", {writable: false, configurable: false});
Object.defineProperty(window, "runEvent", {writable: false, configurable: false});
Object.defineProperty(window, "onPaste", {writable: false, configurable: false});
Object.defineProperty(window, "InsDel", {writable: false, configurable: false});
Object.defineProperty(window, "initElement", {writable: false, configurable: false});
Object.defineProperty(window, "initDOMShowHide", {writable: false, configurable: false});
Object.defineProperty(window, "evalDivSize", {writable: false, configurable: false});
Object.defineProperty(window, "initDOM", {writable: false, configurable: false});
Object.defineProperty(window, "enableElements", {writable: false, configurable: false});
Object.defineProperty(window, "initForm", {writable: false, configurable: false});
Object.defineProperty(window, "fillForm", {writable: false, configurable: false});
Object.defineProperty(window, "AJAX", {writable: false, configurable: false});
Object.defineProperty(window, "ajax", {writable: false, configurable: false});
Object.defineProperty(window, "pageLock", {writable: false, configurable: false});
Object.defineProperty(window, "createLockLayer", {writable: false, configurable: false});
Object.defineProperty(window, "drawMenu", {writable: false, configurable: false});
Object.defineProperty(window, "isCross", {writable: false, configurable: false});
Object.defineProperty(window, "sanitize", {writable: false, configurable: false});
Object.defineProperty(window, "desanitize", {writable: false, configurable: false});
Object.defineProperty(window, "setCSRF", {writable: false, configurable: false});