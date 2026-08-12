CMS_VERSION = '10.1';
__contextPath = ''; //'/ibs';
/* document object ini o`rniga ishlatish uchun
 * document.write("Hello World!");
 * _.write("Hello World!");
 */
var _ = document
	, _locklayer;

function IEVersion() {
	try {
		return Number((/(msie) ([\w.]+)/.exec(navigator.userAgent.toLowerCase()) || [])[2] || "0")
	} catch(e) {
		return 6
	}
}
/* function getDOM(id, index)
 * berilgan ID yoki form bo`yicha document ichidan olish uchun
 * agar id ichida "." belgisi bo`lsa formadan qidiradi
 * getDOM("MyButton").click();
 */
function getDOM(d, i) {
	function g(d) {
		if(!is.string(d)) return d;
		if(d.indexOf(".") > 0) return eval(d);
		return _.getElementById(d)
	}
	d = g(d);
	if(is.def(i)) {
		if(i == 0) {
			if(is.def(d.tagName)) return d;
			else return d[0];
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
	if(arguments.length > 1) disableElements(d, s);
	d.style.display = "none";
	if(is.string(d.onhide)) d.onhide = window[d.onhide];
	if(is.func(d.onhide)) d.onhide();
}
/* function showDOM(dom)
 * domni ko`rsatish uchun
 */
function showDOM(d, s) {
	d = getDOM(d);
	if(arguments.length > 1) {
		disableElements(d, s);
		enableElements(d);
	}
	d.style.display = "inline";
	if(is.string(d.onshow)) d.onshow = window[d.onshow];
	if(is.func(d.onshow)) d.onshow();
}
/* function disableElements(dom, state)
 * berilgan domni ichidagi formaningn controllarini disable yoki enable qilish uchun
 */
function disableElements(d, st) {
	var s = ["input", "select", "textarea"]
		, e;
	for(var j = 0; j < s.length; j++) {
		e = d.getElementsByTagName(s[j]);
		for(var i = 0; i < e.length; i++) {
			e[i].disabled = st;
			if(is.func(e[i].check)) {
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
	if(is.def(e.setValue)) {
		e.setValue(replaceQGH(v));
		if(is.func(e.check)) e.check();
		if(is.func(e.callED)) e.callED();
	} else e.innerText = replaceQGH(v);
}
/* function getDOMValue(element)
 * agar formaning elementi bo`lsa valuesini oladi
 * aks holda innerTexti
 */
function getDOMValue(e) {
	e = getDOM(e);
	if(is.def(e.getValue)) return e.getValue();
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
	var toString = Object.prototype.toString
		, undefined;

	function t(o) {
		return toString.call(o)
	}
	window.is = {
		number: function (o) {
			return t(o) === "[object Number]"
		}
		, string: function (o) {
			return t(o) === "[object String]"
		}
		, array: function (o) {
			return t(o) === "[object Array]"
		}
		, hash: function (o) {
			return t(o) === "[object Object]"
		}
		, func: function (o) {
			return t(o) === "[object Function]"
		}
		, def: function (o) {
			return !is.undef(o)
		}
		, undef: function (o) {
			return(o === undefined || o == null)
		}
		, hasFlag: function (f, i) {
			if(f & i) return true;
			return false
		}
	}
})();
/* function nvl(o, d)
 * agar o o`zgaruvchi null yoki undefined bo`lsa
 * d o`zgaruvchini qaytaradi
 * aks holda o`zini
 */
function nvl(o, d) {
	if(is.def(o)) return o;
	else return d;
}
/* function parent(node, number to up (k))
 * k marta yuqoridagi nodeni qaytaradi
 */
function goParent(t, k) {
	if(!is.number(k)) k = 1;
	var ret = t;
	for(var i = 0; i < k; i++) {
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
	if(is.number(v)) {
		return v;
	}
	if(is.string(v)) {
		return "'" + v.replace(/\\/g, "\\\\").replace(/'/g, "\\\'") + "'";
	}
	if(is.array(v)) {
		var r = "[";
		for(var i = 0; i < v.length; i++) {
			if(i != 0) r += ",";
			r += JsonToString(v[i]);
		}
		return r + "]";
	}
	if(is.hash(v)) {
		var r = "{"
			, f = false;
		for(a in v) {
			if(f) r += ",";
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
	if(is.array(o)) return o;
	return [o];
}
/* string.trim()
 * stringni trim qilish uchun
 * var k = "	 hi		".trim();		// k = "hi";
 */
String.prototype.trim = function () {
	var t = this
		, len = t.length
		, st = 0;
	while((st < len) && (t.charCodeAt(st) <= 32)) st++;
	while((st < len) && (t.charCodeAt(len - 1) <= 32)) len--;
	return((st > 0) || (len < t.length)) ? t.substring(st, len) : t;
};
/* function nocacheURL(url)
 * Internet Explorer sahifani cache qilmasligi uchun
 * uning addressiga vaqt parameteri qo`sh uchun
 */
function nocacheURL(url) {
	var j = url.indexOf("_=");
	if(j > -1) url = url.substring(0, j - 1);
	return url + (url.match(/\?/) ? "&" : "?") + "_=" + (new Date()).getTime();
}
/* function go(D)
 * go({url : "a.jsp", target : "modalE"})
 * D obyekt bo`lib, qo`yidagi attributelar beriladi
 * attribute						default			description
 * ---------						-------			-----------
 * url									_.URL				ochiladigan sahifaning URL
 * clearParams					false				URL parameterilarini o`chirib tashlash uchun
 * target								null				berilgan oynaga sahifa ochiladi
 * param								null				qo`shimcha parameterlar
 * form									null				formani submit qilish uchun
 * arg									null				modal oynasi uchun argumentlar
 * action								null				modalE oynasi uchun qo`shimcha action (function)
 * dialogWidth					800					modal oynasining kengligi
 * dialogHeight					550					modal oynasining balandligi
 * dialogFill						false				modal oynasinig ekranga to'ldirish uchun {true, false}
 * lock									true				formanini QOTIRISH uchun : )
 * dialogScroll					no					modal oynasiga scroll qo`shish
 * cmsHelperTiltle			""					modal oynasiga title qo'shish
 * --------------------------------------------
 * agar param berilgan bo`lsa va target modal bo`lmasa faqat post request bo`ladi
 * agar target modal bo`lsa param atributi ishlatilmaydi
 * 1
 */
function go(D) {
	D.url = nvl(D.url, _.URL);
	if(D.url.match(/^\/|http(s)?:/)) {
		if(D.url.match(/^\//)) {
			D.url = nvl(__contextPath, "") + D.url;
		}
	} else {
		var o;
		if(_.URL.match(/cmshelper.jsp[?]modal/)) {
			o = window.dialogArguments.opener;
		} else {
			o = window;
		}
		o = o._.URL + (o._.URL.match(/\?/) ? "" : "?");
		D.url = o.replace(/[\/][^\/?]+[?].*$/, "") + "/" + D.url
	}
	/*D.url = D.url.match(/^\/|http(s)?:/) ? D.url.match(/^\//) ? nvl(__contextPath, "") + D.url : D.url : (_.URL.match(/cmshelper.jsp[?]modal/) ? window.dialogArguments.opener : window)._.URL.replace(/[\/][^\/?]+[?].*$/, "") + "/" + D.url;*/
	if(D.clearParams) D.url = D.url.split("?")[0];
	D.url = nocacheURL(D.url);
	/* target modal bo`lganda
	 * modal oynaning window.dialogArguments ning strukturasi quydagicha
	 * {arg : Arguments, opener : window(chaqirilayotgan oyna), param : param}
	 */
	if(/modal/.test(D.target)) {
		if(is.undef(D.dialogWidth)) D.dialogWidth = 800;
		if(is.undef(D.dialogHeight)) D.dialogHeight = 550;
		if(is.undef(D.dialogScroll)) D.dialogScroll = "no";
		if(is.undef(D.dialogFill)) D.dialogFill = false;
		if(D.dialogFill) {
			D.dialogWidth = screen.availWidth;
			D.dialogHeight = screen.availHeight;
		}
		var r = showModalDialog((D.target == "modalE" ? nvl(__contextPath, "") + "/cmshelper.jsp?" : D.url + "&") + "modal=" + CMS_VERSION, {
			arg: D.arg
			, param: D.param
			, opener: window
			, url: D.url
			, action: D.action
			, cmsHelperTiltle: (is.def(D.cmsHelperTiltle) && D.target == "modalE") ? D.cmsHelperTiltle : ""
		}, "resizable:yes;scroll=" + D.dialogScroll + ";dialogWidth:" + D.dialogWidth + "px;dialogHeight:" + D.dialogHeight + "px;status=no;help=no");
		return r;
	} else if(is.def(D.param) && D.target !== 1) {
		var fh = _.createElement("<input type=hidden>")
			, h, pr;
		if(is.undef(D.form)) {
			D.form = _.createElement("<form method=post>");
			_.body.appendChild(D.form);
		} else if(!D.form.fireEvent("onsubmit")) return;
		if(is.def(D.target) && D.form.target == "") {
			if(D.target == "new") {
				D.form.target = "_blank";
			} else {
				D.form.target = D.target.name;
			}
		}
		if(D.form.action == "") D.form.action = D.url;
		D.form.method = "post";
		var hs = [];
		for(var p in D.param) {
			pr = makeArray(D.param[p]);
			for(var i = 0; i < pr.length; i++) {
				h = fh.cloneNode(false);
				h.name = p;
				h.value = pr[i];
				D.form.appendChild(h);
				hs.push(h);
			}
		}
		D.form.submit();
		for(var p in hs) D.form.removeChild(hs[p]);
	} else {
		if(is.undef(D.target)) D.target = window;
		if(D.target == "new") top._t().open(D.url, "", D.arg);
		else {
			D.target.location = D.url;
		}
	}
	if(nvl(D.lock, true)) pageLock(true);
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
function parseMask(o, mask) {
	function dateFill() {
		var v = this.value
			, k = v.substr(6, 4).replace(/_/g, "");
		if(k.length == 2) {
			k = Number(k);
			if(k > 50) k += 1900;
			else k += 2000;
			this.setValue(v.substr(0, 6) + k + v.substr(10));
		}
		v = this.value;
		if(v.length > 10) {
			var s = v.substr(0, 11)
				, d;
			v += ":";
			for(var i = 0; i < 3; i++) {
				d = v.substr(11 + i * 3, 3).replace(/_/g, "");
				s += "00".substr(0, 3 - d.length) + d;
			}
			this.setValue(s);
		}
	}

	function dateValidate() {
		var v = this.value
			, d = parseInt(v.substr(0, 2), 10)
			, m = parseInt(v.substr(3, 2), 10)
			, l = parseInt(v.substr(6, 4), 10)
			, ml = [, 31, (l % 4 == 0 && l % 100 != 0 || l % 400 == 0) ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
		if(l <= 0) return false;
		if(m > 12 || d > ml[m] || m < 1 || d < 1) return false;
		if(v.length > 10) {
			d = parseInt(v.substr(11, 2), 10);
			m = parseInt(v.substr(14, 2), 10);
			l = parseInt(v.substr(17, 2), 10);
			if(d < 0 || 23 < d) return false;
			if(m < 0 || 59 < m) return false;
			if(l < 0 || 59 < l) return false;
		}
		return true
	}

	function getTermExp(v) {
		if(v.charAt(0) == "$") {
			try {
				return eval(v.substring(1));
			} catch(e) {
				throw "im";
			}
		} else if(v == "") return "^\x00";
		else return v;
	}
	if(mask) o.mask = mask;
	o.cm = {
		type: "none"
	};
	if(o.mask) {
		o.maxLength = 0x7FFFFFFF;
		var cm = o.mask;
		switch(cm) {
		case "date":
			cm = "{2|0-9}.{2|0-9}.{4|0-9}";
			o.isValid = dateValidate;
			o.fill = dateFill;
			o.a = "c";
			o.title = "dd.mm.yyyy";
			break;
		case "date2":
			cm = "{2|0-9}\/{2|0-9}\/{4|0-9}";
			o.isValid = dateValidate;
			o.a = "c";
			o.title = "dd/mm/yyyy";
			break;
		case "datetime":
			cm = "{2|0-9}.{2|0-9}.{4|0-9} {2|0-9}:{2|0-9}:{2|0-9}";
			o.isValid = dateValidate;
			o.fill = dateFill;
			o.a = "c";
			o.title = "dd.mm.yyyy hh:mi:ss";
			break;
		case "acc":
			cm = "{20|0-9}";
			break;
		case "acc2":
			cm = "{5|0-9}.{3|0-9}.{1|0-9}.{8|0-9}.{3|0-9}";
			o.size = "26";
			break;
		case "mfo":
			cm = "{5|0-9}";
			o.fill = function () {
				if(!(this.isEmpty() || this.isFilled())) {
					var v = this.value.replace(/_/g, "");
					this.setValue("00000".substr(0, 5 - v.length) + v);
				}
			};
			break;
		case "clientcode":
			cm = "{8|0-9}";
			o.fill = function () {
				if(!(this.isEmpty() || this.isFilled())) {
					var v = this.value.replace(/_/g, "");
					this.setValue("00000000".substr(0, 8 - v.length) + v);
				}
			};
			break;
		case "localcode":
			cm = "{2|0-9A-Z}{3|0-9}";
			o.fill = function () {
				if(!(this.isEmpty() || this.isFilled())) {
					var v = this.value.replace(/_/g, "");
					this.setValue("00000".substr(0, 5 - v.length) + v);
				}
			};
		/* case "passport":
			cm = "{2|A-Z} {7|0-9}"; */
		}
		try {
			var m;
			if((m = cm.match(/^number\((\d+)\,?(\d*)\)$/)) != null) {
				cm = [parseInt(m[1]), m[2] == "" ? 0 : parseInt(m[2])];
				cm = [cm[0] - cm[1], cm[1]];
				if(cm[0] <= 0) throw "err";
				var l = (cm[0] + cm[1]) * 4 / 3;
				if(l > parseInt(o.size)) o.size = l;
				o.cm = {
					type: "number"
					, pr: cm[0]
					, sc: cm[1]
				};
				o.style.textAlign = "right";
			} else if(cm == "number") {
				o.cm = {
					type: "number"
					, pr: 999
					, sc: -1
				};
				o.style.textAlign = "right";
			} else if((m = cm.match(/^(\d+)-?(\d*)\|(.*)$/)) != null) {
				cm = [parseInt(m[1]), m[2] == "" ? 0 : parseInt(m[2]), getTermExp(m[3])];
				if((cm[0] + cm[1]) > 0) {
					if(cm[0] > cm[1]) {
						s = cm[0];
						cm[0] = cm[1];
						cm[1] = s
					}
					o.cm = {
						type: "avail"
						, min: cm[0]
						, max: cm[1]
						, re: new RegExp("^[" + cm[2] + "]$")
					};
				} else throw "ex";
			} else if((m = cm.match(/^(\d+)\*(\d+)\|(.*)$/)) != null) {
				if(o.tagName != "TEXTAREA") throw "ex";
				o.cm = {
					type: "textarea"
					, maxLines: parseInt(m[1])
					, maxLength: parseInt(m[2])
					, re: new RegExp("^[" + getTermExp(m[3]) + "]$")
				}
			} else {
				/* TODO {[ maska kiritganda escape qilish
				 */
				var len = cm.length
					, ret = []
					, c, s, t;
				for(var i = 0; i < len; i++) {
					c = cm.charAt(i);
					if(c == "{") {
						s = ++i;
						while(cm.charAt(i) != "}") {
							i++;
							if(i >= len) throw "im";
						}
						if((m = cm.substring(s, i).match(/^(\d+)\|(.+)$/)) != null) {
							t = [parseInt(m[1]), getTermExp(m[2])];
							if(t[0] <= 0 || t[1] == null) throw "im";
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
					type: "mask"
					, cm: cm
				};
				o.chars = [];
				o.enter = [];
				for(var i = 0; i < cm.length; i++) {
					if(cm[i][0] == 0) {
						o.chars.push(cm[i][1]);
						o.enter.push(cm[i][1])
					} else {
						for(var j = 0; j < cm[i][0]; j++) {
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
					for(var lv = 0; lv < this.enter.length; lv++) {
						if(typeof (this.chars[lv]) != "string" && this.enter[lv] != null) {
							return false
						}
					}
					return true
				};
				/* isFilled agar polya to`ppa to`la bo`lsa true qaytaradi, yarmi to`lgan bo`lsa yoki bo`m bo`sh bo`lsa false qaytaradi
				 * faqatgina mask tipdagi polyaplarda ishlatiladi
				 */
				o.isFilled = function () {
					for(var lv = 0; lv < this.enter.length; lv++) {
						if(typeof (this.chars[lv]) != "string" && this.enter[lv] == null) {
							return false
						}
					}
					return true
				};
			}
		} catch(er) {
			if(er == "im") alert("Incorrect mask " + o.outerHTML);
			else throw er;
		}
	}
}
/* function showReference(ref)
 * name reference nomi (required)
 * get olish polyasi {name : object, name2 : object2}
 * put solish polyasi [object, object2]
 * w	width
 * h height
 * isValid
 */
function showReference(t) {
	eval("ref=" + t.reference);
	var v = ref.get
		, g = {}
		, si = -1
		, se;
	se = eval(t.form.name + "." + t.name);
	if(se != t) {
		si = 0;
		while(se[si] != t) si++;
	}
	if(is.def(ref.isValid)) {
		if(!ref.isValid(si)) return;
	}
	for(var k in v) {
		if(is.string(v[k])) {
			g[k] = v[k];
		} else {
			se = getDOM(v[k]);
			if(se.tagName != "SELECT" && se[si]) {
				se = se[si];
			}
			g[k] = getDOMValue(se);
		}
	}
	t.refOpened = true;
	var r = go({
		target: "modalE"
		, url: nvl(ref.url, _.URL).split("?")[0] + "?reference=" + ref.name
		, param: g
		, dialogWidth: ref.w
		, dialogHeight: ref.h
	});
	t.refOpened = false;
	if(r == null) return;
	v = makeArray(ref.put);
	for(var i = 0; i < v.length; i++) {
		/* agar biror qiymat uchun control berilmagan bo`lsa, shu qiymatni tashlab o`tib ketadi
		 */
		if(v[i] == null) continue;
		se = getDOM(v[i]);
		/* alert(se.outerHTML);
		if (se[si]) */
		if(is.undef(se.tagName)) {
			se = se[si];
		}
		setDOMValue(se, r[i])
	}
	if(is.def(ref.callback)) ref.callback(r, ref, t);
}
/* function formatNumber(number, scale = 0)
 * alert qilish uchun kerak bo`ladi
 */
function formatNumber(v, sc) {
	if(is.number(v)) v = new String(v);
	if(sc == null) sc = 0;
	var sign = "";
	if(v.charAt(0) == "-") sign = "-";
	if(v.indexOf(".") >= 0) v = v.replace(/[,]/g, "");
	v = v.replace(/[,.]/, "@")
		.replace(/[,.]/g, "")
		.replace(/@/, ".")
		.replace(/[^0-9.]/g, "")
		.replace(/^[0]+/, "");
	if(v == "") v = "0";
	if(v.charAt(0) == ".") v = "0" + v;
	if(sc) {
		if(!v.match(/[.]/)) v = v + ".";
		v = v.split(".");
		if(sc != -1) {
			if(v[1].length > sc) v[1] = v[1].slice(0, sc);
			else
				for(var i = v[1].length; i < sc; i++) v[1] = v[1] + "0";
		} else {
			var i = v[1].length - 1;
			while(i >= 0 && v[1].charAt(i) == "0") i--;
			v[1] = v[1].substring(0, i + 1);
		}
		if(v[1].length > 0) v = v[0] + "." + v[1];
		else v = v[0];
	} else v = v.replace(/[.].*/, "");
	var d = v.indexOf(".")
		, v2;
	if(d == -1) d = v.length - 3;
	else if(d > 3) d -= 3;
	else d = 0;
	v2 = v.substring(d);
	for(var i = d; i > 0; i -= 3) {
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
	if(is.def(t.refOpened) && t.refOpened) return false;
	if(t.request.charAt(0) != "{") eval("req=" + window[t.request]);
	else eval("req=" + t.request);
	var v = {
			request: req.name
		}
		, si = 0
		, se;
	se = eval(t.form.name + "." + t.name);
	if(se != t) {
		while(se[si] != t) si++;
	}
	var se, valueCheck;
	if(is.def(req.put)) {
		var e = makeArray(req.put);
		for(var i = 0; i < e.length; i++) {
			se = getDOM(e[i]);
			if(is.undef(se.setValue))
				if(se[si]) se = se[si];
			setDOMValue(se, "");
		}
	}
	if(t.getValue() == "") {
		t.error = 0;
	}
	var lastError = nvl(t.error, 0)
		, el;
	t.error = 0;
	if(t.fill) t.fill();
	for(var k in req.get) {
		el = req.get[k];
		if(is.string(el)) {
			v[k] = el;
		} else {
			se = getDOM(req.get[k]);
			if(typeof (se.valueCheck) == "boolean") {
				valueCheck = se.valueCheck;
				se = se.field;
			} else {
				valueCheck = true;
			}
			if(se.tagName != "SELECT" && se[si]) {
				se = se[si];
			}
			v[k] = getDOMValue(se);
			if(valueCheck) {
				if(se.check && !se.check(1) || String(v[k]) == "") {
					t.error = lastError;
					return false;
				}
			}
		}
	}
	AJAX.load({
		url: req.url
		, POST: v
		, onSuccess: function (d) {
			var se;
			if(is.def(req.put)) {
				var e = makeArray(req.put);
				for(var i = 0; i < e.length; i++) {
					se = getDOM(e[i]);
					if(is.undef(se.setValue))
						if(se[si]) se = se[si];
					setDOMValue(se, d[i]);
				}
			}
			if(is.func(req.callback)) {
				req.callback(d, req, t);
			}
		}
		, onError: function (d) {
			var txt = (new String(d)).trim();
			if(txt.length > 0) {
				alert(txt);
			}
			t.error = 1;
		}
	});
	return true;
}
(function () {
	function setID(t, id) {
		if(id) t.id = id;
		else if(t.id == "") t.id = "gen" + t.sourceIndex
	}

	function setDisable(s) {
		this.disabled = s;
		if(this.check) this.check();
	}

	function setReadOnly(s) {
		this.readOnly = s;
		if(this.check) this.check();
	}

	function getStart() {
		if(_.selection) return Math.abs(_.selection.createRange().moveStart("character", -1000000));
		return 0
	}

	function getEnd() {
		if(_.selection) return this.value.length - Math.abs(_.selection.createRange().moveEnd("character", 1000000));
		return 0
	}

	function setCaret(s, e) {
		var t = this
			, len = t.value.length;
		if(isNaN(parseInt(s))) {
			return false
		} else {
			s = parseInt(s);
			if(s < 0) {
				s = 0
			} else if(s > len) {
				s = len
			}
		}
		if(e == null || isNaN(parseInt(e)) || parseInt(e) < s) {
			e = s
		} else {
			e = parseInt(e);
			if(e < 0) {
				e = 0
			} else if(e > len) {
				e = len
			}
		}
		/* if(typeof(t.createTextRange) == "object") */
		if(typeof (t.createTextRange) == "object" && t.type != "file") {
			var range = t.createTextRange();
			range.moveEnd("character", e - t.value.length);
			range.moveStart("character", s);
			range.select();
			return true
		}
		return false
	}

	function getPrev(pos) {
		if(pos - 1 < 0) {
			return null
		}
		if(typeof (this.chars[pos - 1]) == "string") {
			return this.getPrev(pos - 1)
		}
		return pos - 1
	}

	function getNext(pos) {
		var t = this;
		if(pos + 1 >= t.enter.length) {
			return null
		}
		if(typeof (t.chars[pos + 1]) == "string") {
			return t.getNext(pos + 1)
		}
		return pos + 1
	}

	function maskGetValue() {
		var t = this;
		if(t.cm.type == "mask") {
			if(t.isEmpty()) return "";
		} else if(t.cm.type == "number") {
			var v = t.value.replace(/ /g, "");
			if(is.def(t.nullable) && v == "") return "";
			if(v == "") return 0;
			else return Number(v);
		}
		return t.value;
	}

	function maskSetValue(v) {
		var t = this;
		if(t.cm.type == "mask") {
			if(v == null) {
				v = ""
			}
			var val = "";
			for(var lv = 0; lv < t.chars.length; lv++) {
				if(lv < v.length) {
					if(typeof (t.chars[lv]) != "string") {
						if(t.chars[lv].test(v.charAt(lv))) {
							t.enter[lv] = v.charAt(lv);
							val += v.charAt(lv)
						} else {
							t.enter[lv] = null;
							val += "_"
						}
					} else {
						t.enter[lv] = t.chars[lv];
						val += t.chars[lv]
					}
				} else if(arguments.length > 0) {
					if(typeof (t.chars[lv]) == "string") {
						val += t.chars[lv]
					} else {
						t.enter[lv] = null;
						val += "_"
					}
				} else {
					if(typeof (t.chars[lv]) == "string") {
						val += t.chars[lv]
					} else {
						val += t.enter[lv] == null ? "_" : t.enter[lv]
					}
				}
			}
			t.value = val
		} else if(t.cm.type == "number") {
			if(arguments.length > 0) {
				if(!is.string(v)) {
					var k = Math.pow(10, t.cm.sc);
					v = Math.round(v * k) / k;
				}
				v = new String(v);
			} else v = t.value;
			if(t.nullable && v.length == 0) {
				t.value = "";
				return;
			}
			var sign = "";
			t.value = formatNumber(v, t.cm.sc);
		} else if(arguments.length > 0) t.value = v;
		if(t.tagName == "TEXTAREA" && is.def(t.increaseRow)) t.increaseRow();
	}
	/* s = 1(request) */
	function maskcheck(s) {
		var t = this;
		if(t.disabled) {
			t.style.background = t.currentStyle["input-background-disabled"];
			return true;
		}
		try {
			if(t.tagName == "TEXTAREA") t.innerText = t.value.trim();
			else if(t.tagName == "INPUT") t.value = t.value.trim();
			if(t.cm) {
				if(t.cm.type == "mask") {
					t.setValue(t.value);
					if(t.isEmpty()) {
						t.value = ""
					} else {
						if(is.func(t.fill)) t.fill();
						if(!t.isFilled() || (t.isValid && !t.isValid())) throw "err";
					}
				} else if(t.cm.type == "avail") {
					if(t.value.length != 0 && (t.value.length < t.cm.min || t.value.length > t.cm.max)) throw "err";
					for(var i = 0; i < t.value.length; i++) {
						if(!(t.cm.re.test(t.value.charAt(i)) || t.value.charCodeAt(i) <= 13)) throw "err";
					}
				} else if(t.cm.type == "textarea") {
					var lines = t.innerText.split("\r\n");
					if(lines.length > t.cm.maxLines) throw "err";
					for(var i = 0; i < lines.length; i++) {
						var line = lines[i];
						if(line.length > t.cm.maxLength) throw "err";
						for(var j = 0; j < line.length; j++) {
							if(!t.cm.re.test(line.charAt(j))) throw "err";
						}
					}
				} else if(t.cm.type == "number") {
					if(!(t.nullable && t.value.length == 0)) {
						this.setValue();
						var m = this.value.replace(/ /g, "").match(/^-?([0-9]+)\.?([0-9]*)$/);
						if(!(m && m[1].length <= t.cm.pr)) throw "err";
					}
				}
			}
			if(event && s != 1 && (event.type == "submit" || event.type == "blur")) {
				if(t.validate && !t.validate()) {
					throw "err";
				}
				if(is.def(t.r)) {
					if(t.r == "1") {
						if(t.value == "") throw "err";
					} else if(t.r == "0") {} else if(!eval("__=" + t.r)) throw "err";
				}
			}
			if(is.def(t.error) && t.error != 0) throw "err";
		} catch(er) {
			if(er == "err") {
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
		if(s) t.style.background = t.currentStyle["input-background-error"];
		else t.style.background = t.currentStyle[t.readOnly ? "input-background-disabled" : "input-background"];
	}

	function maskdblclick() {
		if(this.reference && !this.readOnly) {
			showReference(this);
		}
	}

	function maskkeydown() {
		var t = this;
		if(event.keyCode == 120 && t.reference && !t.readOnly) {
			showReference(this);
		}
		if(t.readOnly == true) {
			return(event.keyCode == 9 || event.keyCode == 13);
		}
		if(t.cm.type == "mask") {
			var key = event.keyCode
				, selStart = t.getStart()
				, selEnd = t.getEnd();
			t.setValue(t.value);
			t.setCaret(selStart, selEnd);
			if(selStart == selEnd) {
				if(key == 8) {
					var newPos = t.getPrev(selStart);
					if(newPos == null || newPos == selStart) {
						return false
					}
					t.enter[newPos] = null;
					t.setValue();
					t.setCaret(newPos);
					return false
				}
				if(key == 46) {
					if(typeof (t.chars[selStart]) == "string") {
						return false
					}
					t.enter[selStart] = null;
					t.setValue();
					t.setCaret(selStart);
					return false
				}
			} else {
				if(key == 8 || key == 46) {
					for(var lv = selStart; lv < selEnd; lv++) {
						if(typeof (t.chars[lv]) != "string") {
							t.enter[lv] = null
						}
					}
					t.setValue();
					t.setCaret(selStart);
					return false
				}
			}
		}
		return true
	}

	function maskkeypress() {
		var t = this;
		if(t.tagName == "TEXTAREA" && event.keyCode == 13) {
			t.increaseRow();
		}
		if(t.cm.type == "mask") {
			if(t.readOnly) return false;
			var newChar = String.fromCharCode(event.keyCode)
				, pos = t.getStart();
			if(typeof (t.chars[pos]) == "string") {
				var newPos = t.getNext(pos);
				if(newPos == null || newPos == pos) return false;
				t.setCaret(newPos);
				pos = newPos
			}
			if(pos >= t.chars.length || typeof (t.chars[pos]) != "string" && !(newChar.match(t.chars[pos]) ? true : ((newChar = newChar.toUpperCase())
					.match(t.chars[pos])) ? true : ((newChar = newChar.toLowerCase())
					.match(t.chars[pos])) ? true : false)) {
				t.setValue(t.value);
				t.setCaret(pos)
			} else {
				var selStart = t.getStart()
					, selEnd = t.getEnd();
				for(var lv = selStart; lv < selEnd; lv++) {
					if(typeof (t.chars[lv]) != "string") {
						t.enter[lv] = null
					}
				}
				t.setValue();
				t.setCaret(selStart);
				t.enter[pos] = newChar;
				t.setValue();
				var newPos = t.getNext(pos);
				if(newPos == null) {
					newPos = pos + 1
				}
				t.setCaret(newPos)
			}
			return false
		} else if(t.cm.type == "avail") {
			/* TODO enter key ni olib tashlash kerak keyinchalik
			 */
			if(event.keyCode == 13) return true;
			var nc = String.fromCharCode(event.keyCode);
			if(t.value.length - _.selection.createRange().text.length >= t.cm.max) return false;
			if(nc.match(t.cm.re)) return true;
			return false
		} else if(t.cm.type == "textarea") {
			var nc = String.fromCharCode(event.keyCode);
			if(nc.match(t.cm.re)) return true;
			return false
		} else if(t.cm.type == "number") {
			var newChar = String.fromCharCode(event.keyCode);
			if(this.oldkeypress) this.oldkeypress();
			if(newChar.match(/^[0-9]$/)) return true;
			else if(newChar.match(/^[.,]$/)) {
				if(event.keyCode != 46) event.keyCode = 46;
				if(!this.value.match(/.+[.,].*/)) return true;
			} else if(newChar == "-") return true;
			return false
		}
		return true;
	}

	function maskchange() {
		var t = this;
		if(t.cm.type == "mask") {
			if(t.fill) t.fill();
			t.setValue(t.value);
		}
	}

	function maskfocus() {
		var t = this
			, f = t.check();
		if(f) t.style.background = t.currentStyle[t.disabled || t.readOnly ? "input-background-disabled" : "input-background-focus"];
		if(t.cm) {
			if(t.cm.type == "mask") {
				t.setValue(t.value);
				if(t.isEmpty()) {
					if(t.value != "") t.setValue(t.value);
				}
			} else if(t.cm.type == "number") {
				t.value = t.value.replace(/[ ]/g, "");
			}
		} else t.setValue();
		t.setCaret(0, t.value.length);
	}

	function maskblur() {
		this.style.background = this.currentStyle[this.disabled || this.readOnly ? "input-background-disabled" : "input-background"];
		this.check();
	}

	function runEvent() {
		//try {
			var et = event.type
				, t = this
				, r, r2;
			if(t.disabled) return false;
			if(et == "blur" || et == "change" || et == "propertychange" && t.callED) {
				t.callED();
			}
			if(et == "change" && t.tagName == "SELECT" && t.request) {
				callRequest(t);
			}
			if(et == "blur" && t.tagName == "INPUT" && t.request) {
				callRequest(t);
			}
			if(t["mask" + et]) r = t["mask" + et]();
			if(t["own" + et]) r2 = t["own" + et]();
			if(is.def(r2)) r = r && r2;
			/*
			if(et == "keydown" && event.keyCode == 13) {
				try {
					var lE = t.form.elements[t.form.elements.length - 1];
					if(lE == t && is.undef(t.form.nocycle)) {
						setTimeout("_.all[" + t.form.elements[0].sourceIndex + "].focus()", 1);
					}
				} catch(e) {

				}
			}
			*/
			event.returnValue = r;
			return r;
		/*} catch(er) {
			event.returnValue = false;
			throw er;
		}*/
	}

	function onPaste() {
		this.setValue(this.value.substr(0, this.getStart()) + clipboardData.getData("Text") + this.value.substr(this.getEnd()));
		event.keyCode = 0;
		event.cancelBubble = true;
		event.returnValue = false
	}

	function InsDel() {
		var t = o = this
			, tbl, tmpID, m;
		for(var i = 0; i < t.insdel; i++) {
			while(o.parentNode.tagName != "TR") o = o.parentNode;
			o = o.parentNode;
		}
		tbl = o.parentNode;
		if(t.value == "-") {
			if((t.confirm && window.confirm(t.confirm)) || !t.confirm) {
				tbl.deleteRow(o.sectionRowIndex);
				getDOM(t.mbid).disabled = false;
			}
		} else {
			t.value = "-";
			tmpID = t.id;
			t.id = "";
			var nr = o.cloneNode(true);
			t.id = tmpID;
			t.value = "+";
			m = eval("__=" + t.max);
			if(m < 2) {
				alert("InsDel: max is undefined or less than 2");
				throw "err";
			}
			/* attributes
			 * beforeInsert(new row)
			 * afterInsert(new row)
			 */
			if(is.def(t.beforeInsert)) {
				if(t.beforeInsert(nr) == false) return;
			}
			tbl.replaceChild(nr, tbl.insertRow());
			initDOM(nr);
			if(is.def(t.afterInsert)) t.afterInsert(nr);
			if(o.parentNode.rows.length - o.sectionRowIndex >= m) {
				t.disabled = true;
			}
		}
		evalDivSize(getDOM("base"));
	}

	function getControlIndex() {
		var se, si = 0;
		se = eval(this.form.name + "." + this.name);
		if(se != this) {
			while(se[si] != this) {
				si++;
				if(si > 10000) throw "er";
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
		t.setDisable = setDisable;
		t.setReadOnly = setReadOnly;
		if(is.undef(t.check)) t.check = function () {
			return true
		};
		if(is.string(t.validate)) {
			t.validate = window[t.validate];
		}
		t.getIndex = getControlIndex;
		if(t.enable) {
			var enb = t.enable
				, si = 0
				, sOR, sAND, m, n, vED, se;
			se = eval(t.form.name + "." + t.name);
			if(se != t) {
				while(se[si] != t) si++;
			}
			t.EDis = false;
			if(enb.charAt(0) == "@") {
				t.EDis = true;
				enb = enb.substr(1);
			}
			t.ED = [];
			sOR = enb.split("||");
			for(var k = 0; k < sOR.length; k++) {
				sAND = sOR[k].split("&&");
				vED = [];
				for(var i = 0; i < sAND.length; i++) {
					vED[i] = sAND[i].match(/^([!]?)(\w+)(\[.*\])$/);
					if(vED[i][1] == "!") vED[i][1] = true;
					else vED[i][1] = false;
					n = eval(t.form.name + "." + vED[i][2]);
					if(is.undef(n.tagName)) {
						if(n[si].type != "radio") n = n[si];
					}
					if(is.undef(n.EN_DES)) n.EN_DES = [];
					n.EN_DES.push(t.form.name + "." + t.name);
					vED[i][3] = eval(vED[i][3]);
				}
				if(vED.length > 0) t.ED.push(vED);
			}
			t.enableElement = function () {
				var t = this
					, s = false
					, si = 0
					, sOR, sAND, el;
				el = eval(t.form.name + "." + t.name);
				if(el != t) {
					while(el[si] != t) si++;
				}
				for(var i = 0; i < t.ED.length; i++) {
					sOR = true;
					for(var k = 0; k < t.ED[i].length; k++) {
						sAND = false;
						el = eval(t.form.name + "." + t.ED[i][k][2]);
						if(!(el.tagName || el[0].type == "radio")) {
							el = el[si]
						}
						var elv = "";
						if(is.def(el.getValue)) {
							elv = el.getValue();
						}
						for(var j = 0; el && j < t.ED[i][k][3].length; j++) {
							sAND = sAND || (elv == t.ED[i][k][3][j]);
						}
						if(t.ED[i][k][1]) sAND = !sAND;
						sOR = sOR && sAND;
					}
					s = s || sOR;
				}
				if(t.type != "checkbox") {
					if(s) {
						if(t.oldValue) t.setValue(t.oldValue);
					} else {
						if(!(t.readOnly || t.disabled)) {
							t.oldValue = t.getValue();
						}
						if(!t.saveValue) t.value = "";
					}
				}
				if(t.EDis) t.setDisable(!s);
				else t.setReadOnly(!s);
				if(t.check) t.check();
			};
			t.enable = false;
		}
		t.callED = function () {
			var t = this
				, si = 0
				, k, se;
			if(!t.name || !t.form || !t.form.name) return;
			se = eval(t.form.name + "." + t.name);
			if(se != t) {
				while(se[si] != t) si++;
			}
			if(t.type == "radio") {
				if(!t.checked) return;
				t = se;
			}
			k = t.EN_DES;
			for(var i = 0; k && i < k.length; i++) {
				var el = (eval(k[i]));
				if(el.enableElement) {
					el.enableElement();
				} else {
					if(si) {
						el[si].enableElement();
					} else {
						for(var j = 0; j < el.length; j++) el[j].enableElement();
					}
				}
			}
			if(is.array(t.OSH)) {
				for(var i = 0; i < t.OSH.length; i++) {
					var o = getDOM(t.OSH[i]);
					o.showHideDOM();
				}
			}
		};
		if(t.tagName == "SELECT") {
			if(is.undef(t.sid)) {
				t.sid = t.sourceIndex;
				t.ownchange = t.onchange;
				t.onchange = runEvent;
				t.ownblur = t.onblur;
				t.onblur = runEvent;
				t.onkeydown = runEvent;
				t.check = maskcheck;
				t.setError = setError;
				t.setValue = function (v) {
					this.value = v;
				};
				t.getValue = function () {
					return this.value;
				};
			}
			if(t.sid != t.sourceIndex) {
				t.sid = t.sourceIndex;
				t.onchange = runEvent;
				t.onblur = runEvent;
			}
		} else if((t.tagName == "INPUT" && (t.type == "submit" || t.type == "button" || t.type == "reset")) || t.tagName == "BUTTON") {
			if(is.undef(t.sid)) {
				t.sid = t.sourceIndex;
				t.isButton = true;
				if(t.insdel) {
					t.className = "mbtn";
					t.value = "+";
					t.insdel = Number(t.insdel);
					setID(t);
					var o = t
						, s = ["input", "select", "textarea"]
						, e;
					for(var i = 0; i < t.insdel; i++) {
						while(o.parentNode.tagName != "TR") o = o.parentNode;
						o = o.parentNode;
					}
					for(var j = 0; j < s.length; j++) {
						e = o.getElementsByTagName(s[j]);
						for(var i = 0; i < e.length; i++) {
							e[i].mbid = t.id;
						}
					}
					if(is.def(t.beforeInsert)) t.beforeInsert = window[t.beforeInsert];
					if(is.def(t.afterInsert)) t.afterInsert = window[t.afterInsert];
					t.maskclick = InsDel;
				}
				t.ownclick = t.onclick;
				t.onclick = runEvent;
			}
			if(t.sid != t.sourceIndex) {
				t.sid = t.sourceIndex;
				t.onclick = runEvent;
			}
			t.style.background = t.currentStyle["button-background"];
			t.style.border = t.currentStyle["button-border"];
			t.onmouseout = function () {
				this.style.background = this.currentStyle["button-background"]
			};
			t.onmouseover = function () {
				this.style.background = this.currentStyle["button-background-hover"]
			};
			if(t.tagName == "BUTTON") {
				t.setValue = function (v) {
					this.innerHTML = v
				};
				t.getValue = function () {
					return this.innerHTML
				};
			} else {
				t.setValue = function (v) {
					this.value = v
				};
				t.getValue = function () {
					return this.value
				};
			}
		} else if(t.tagName == "INPUT" && (t.type == "checkbox" || t.type == "radio")) {
			if(is.undef(t.sid)) {
				if(t.parentNode.tagName == "LABEL") {
					setID(t);
					t.parentNode.htmlFor = t.id;
				}
				t.sid = t.sourceIndex;
				t.style.marginLeft = "0px";
				t.ownpropertychange = t.onpropertychange;
				t.onpropertychange = runEvent;
				t.ownblur = t.ownblur;
				t.onblur = runEvent;
				t.onkeydown = runEvent;
				if(t.type == "checkbox") {
					t.getValue = function (d) {
						if(this.checked) return this.value;
						else return is.def(d) ? d : null;
					};
					t.setValue = function (v) {
						if(this.value == v) this.checked = true;
						else this.checked = false;
					}
				} else {
					var o = eval(t.form.name + "." + t.name);
					o.getValue = function () {
						for(var i = 0; i < this.length; i++)
							if(this[i].checked) return this[i].value;
						return null;
					};
					o.setValue = function (v) {
						for(var i = 0; i < this.length; i++) {
							if(this[i].value == v) this[i].checked = true;
							else this[i].checked = false;
						}
					}
				}
			}
			if(t.sid != t.sourceIndex) {
				t.onpropertychange = t.onblur = t.onkeydown = runEvent;
			}
		} else if((t.tagName == "INPUT" && (t.type == "text" || t.type == "file" || t.type == "password" || t.type == "hidden")) || t.tagName == "TEXTAREA") {
			if(is.undef(t.sid)) {
				t.sid = t.sourceIndex;
				t.style.background = t.currentStyle[t.disabled || t.readOnly ? "input-background-disabled" : "input-background"];
				t.style.border = t.currentStyle["input-border"];
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
				if(t.tagName != "TEXTAREA") {
					t.onpaste = onPaste;
				} else {
					t.increaseRow = function () {
						var t = this;
						if(is.def(t.maxRows)) {
							if(is.string(t.maxRows)) t.maxRows = Number(t.maxRows);
							var lineLength = t.value.split("\r\n").length;
							if(t.rows <= lineLength && lineLength < t.maxRows) t.rows++;
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
			if(t.sid != t.sourceIndex) {
				if(t.tagName != "TEXTAREA") t.onpaste = onPaste;
				t.ondblclick = t.onkeydown = t.onkeypress = t.onchange = t.onfocus = t.onblur = runEvent;
				if(t.copyValue) t.setValue(t.value);
				else t.setValue("");
				t.check();
				t.sid = t.sourceIndex;
			}
		} else if(t.tagName == "INPUT" && t.type == "hidden") return;
		else if(t.tagName == "FORM") {
			if(!t.noEnter) t.onkeydown = function () {
				var e = event.srcElement
					, k = event.keyCode;
				if(k != 13 || e.type == "submit" || e.type == "button" || e.type == "reset" || e.tagName == "TEXTAREA" || e.tagName == "BUTTON"
					/* || e.name == null */
				) return true;
				event.keyCode = 9;
			};
			t.method = "post";
			t.ownsubmit = t.onsubmit;
			t.check = function () {
				var k = true
					, t = this
					, el = t.elements
					, F, e;
				for(var i = 0; i < el.length; i++) {
					e = el[i];
					if(!e.disabled) {
						if(e.check && !e.check()) {
							if(k) F = e;
							k = false;
						}
						if(e.validate && !e.validate()) {
							if(k) F = e;
							k = false;
							e.setError(true);
						}
					}
				}
				for(var i = 0; k && i < el.length; i++) {
					e = el[i];
					if(e.cm && e.cm.type == "number") {
						e.value = e.value.replace(/[ ]/g, "")
					}
					if(e.cm && e.mask == "acc2") {
						e.value = e.value.replace(/[.]/g, "")
					}
				}
				if(!k) {
					if(t.alert) alert(t.alert);
					try {
						F.focus();
					} catch(ex) {
						alert("Cannot focus on " + F.name);
						throw ex;
					}
				}
				return k;
			};
			t.masksubmit = function () {
				if(this.check()) {
					if(this.lock != 0) pageLock(true);
					return true;
				} else {
					return false;
				}
			};
			t.onsubmit = runEvent;
			t.Submit = function () {
				if(this.fireEvent("onsubmit")) {
					this.submit();
					if(this.lock != 0) pageLock(true)
				}
			};
		} else alert("element initialize error " + t.outerHTML);
		if(t.a) {
			switch(t.a) {
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
		if(t.showhide) {
			var shd = t.showhide
				, sOR, sAND, m, n, vSH, se, w;
			sOR = shd.split("||");
			t.SH = [];
			for(var i = 0; i < sOR.length; i++) {
				vSH = [];
				sAND = sOR[i].split("&&");
				for(var j = 0; j < sAND.length; j++) {
					vSH[j] = sAND[j].match(/^([!]?)(\w+[.]?\w+)(\[.*\])$/);
					if(vSH[j] == null) alert(sAND[j] + " is incorrect");
					if(vSH[j][1] == "!") vSH[j][1] = true;
					else vSH[j][1] = false;
					n = getDOM(vSH[j][2]);
					if(is.undef(n.OSH)) n.OSH = [];
					setID(t);
					n.OSH.push(t.id);
					vSH[j][3] = eval(vSH[j][3]);
				}
				if(vSH.length > 0) t.SH.push(vSH);
			}
			t.showHideDOM = function () {
				var t = this
					, s = false
					, sOR, sAND, el;
				for(var i = 0; i < t.SH.length; i++) {
					sOR = true;
					for(var k = 0; k < t.SH[i].length; k++) {
						sAND = false;
						el = getDOM(t.SH[i][k][2]);
						var elv = el.getValue();
						for(var j = 0; j < t.SH[i][k][3].length; j++) {
							sAND = sAND || (elv == t.SH[i][k][3][j]);
						}
						if(t.SH[i][k][1]) sAND = !sAND;
						sOR = sOR && sAND;
					}
					s = s || sOR;
				}
				if(s) {
					showDOM(t, false);
				} else {
					hideDOM(t, true);
				}
			};
			t.showhide = false;
			t.showHideDOM();
		}
	};
	if(/[?&]modal/.test(_.URL)) {
		top._t = function () {
			return window.dialogArguments.opener.top._t()
		};
		_.write("<title>");
		var m = ((is.def(window.dialogArguments.cmsHelperTiltle)) ?  window.dialogArguments.cmsHelperTiltle : "");/*top._t().modalTitle +*/
		if(is.def(m)) _.write(m);
		for(var i = 0; i < 1000; i++) _.write("&nbsp;");
		_.write("</title>");
		window.isModal = true;
	} else {
		if(top == window) top.isModal = false;
	}
})();
/* function evalDivSize(DOM)
 * Domning id siga panel so`zini qo`shib
 */
function evalDivSize(d, s) {
	var t;
	t = getDOM(d.id + "panel");
	if(is.undef(t)) return;
	var clWidth;
	if(d.minWidth != "done") {
		if(d.minWidth == "fill") {
			d.width = "100%";
			clWidth = t.offsetWidth - (_.body.scrollWidth - _.body.clientWidth);
			d.width = "";
		} else if(!is.undef(d.minWidth)) {
			var w = parseInt(Number(d.minWidth) * parseFloat(d.currentStyle["coeff"]));
			if(w > d.clientWidth) {
				clWidth = w;
			}
		}
		if(_.body.scrollWidth - _.body.clientWidth > 0) {
			d.width = "100%";
			clWidth = t.offsetWidth - (_.body.scrollWidth - _.body.clientWidth);
			d.width = "";
		}
		if(is.undef(clWidth)) {
			clWidth = t.offsetWidth;
		} else if(clWidth > _.body.clientWidth - 14) {
			clWidth = _.body.clientWidth - 20;
		}
		t.style.overflow = "auto";
		t.style.width = clWidth;
	}
	var r = t.getClientRects()(0)
		, clHeight = _.body.clientHeight - _.body.scrollHeight + r.bottom - r.top - 5;
	if(clHeight > _.body.clientHeight - d.clientHeight) {
		clHeight = _.body.clientHeight - d.clientHeight + r.bottom - r.top - 7;
	}
	if(d.minHeight == "fill") {
		t.style.height = clHeight;
	} else if(!is.undef(d.minHeight)) {
		var h = parseInt(Number(d.minHeight) * parseFloat(d.currentStyle["coeff"]));
		if(h > t.clientHeight) t.style.height = h;
	}
	if(t.clientHeight > clHeight) {
		t.style.height = clHeight;
	}
	if(s == null) evalDivSize(d, 1);
	else {
		if(t.scrollWidth - t.clientWidth < 20 && t.scrollWidth - t.clientWidth > 0) {
			t.style.paddingRight = t.scrollWidth - t.clientWidth;
			t.style.overflowX = "hidden";
		} else {
			t.style.paddingRight = 0;
			t.style.overflow = "auto";
		}
		d.minWidth = "done";
	}
}
/* function enableElements(dom)
 * berilgan DOM dagi enable attributelarini chaqirish uchun
 */
function enableElements(d) {
	var s = ["input", "select", "textarea", "fieldset", "div", "tr", "span"]
		, e;
	if(d == null) d = _.body;
	for(var j = 0; j < s.length; j++) {
		e = d.getElementsByTagName(s[j]);
		for(var i = 0; i < e.length; i++) {
			if(e[i].enableElement) {
				e[i].enableElement();
			}
			if(e[i].showHideDOM) e[i].showHideDOM();
		}
	}
}
/* function initDOM(dom)
 * DOM ni initialize qilish uchun
 */
function initDOM(d) {
	var s = ["input", "select", "textarea", "form", "button"]
		, e;
	e = d.getElementsByTagName("q");
	for(var i = 0; i < e.length; i++) {
		e[i].innerText = "*";
	}
	for(var j = 0; j < s.length; j++) {
		e = d.getElementsByTagName(s[j]);
		for(var i = 0; i < e.length; i++) {
			initElement(e[i]);
		}
	}
	enableElements(d);
	var sDOM = ["fieldset", "div", "tr", "span"];
	for(var j = 0; j < sDOM.length; j++) {
		e = d.getElementsByTagName(sDOM[j]);
		for(var i = 0; i < e.length; i++) {
			initDOMShowHide(e[i]);
		}
	}
}

function dragOBJ(d) {
	function xy(v) {
		return(v ? event.clientY + _.body.scrollTop : event.clientX + _.body.scrollTop);
	}

	function drag(e) {
		_.onselectstart = Function("return false");
		if(!stop) {
			d.style.top = (tX = xy(1) + oY - eY + "px");
			d.style.left = (tY = xy() + oX - eX + "px");
		}
	}
	var oX = parseInt(d.style.left)
		, oY = parseInt(d.style.top)
		, eX = xy()
		, eY = xy(1)
		, tX, tY, stop;
	_.onmousemove = drag;
	_.onmouseup = function () {
		stop = 1;
		_.onmousemove = "";
		_.onmouseup = "";
		_.onselectstart = "";
	}
}
if(typeof (data) == "undefined") {
	data = {};
}
/* function initForm(form, data, top, left)
 * berilgan formani initialized qilish uchun
 * id = base base panel
 */
function initForm(d, data, t, l) {
	d = getDOM(d);
	if(is.undef(d)) return false;
	if(d.inited) return d;
	initDOM(d);
	if(is.undef(window.dialogArguments)) {
		if(d.id == "base") {
			d.style.zIndex = 0;
		} else {
			d.style.zIndex = 1;
			d.onkeyup = function () {
				if(event.keyCode == 27) this.style.display = "none";
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
		d.onmousedown = function () {
			event.cancelBubble = true;
			if(this.id == "base") {
				if(is.def(this.popup)) getDOM(this.popup).hide();
			}
		};
		d.tBodies[0].rows[0].cells[0].onmousedown = function () {
			if(this.className == "formTitle") {
				dragOBJ(this.parentNode.parentNode.parentNode);
			}
			return false;
		};
		if(is.def(data)) fillForm(data);
		d.style.position = "absolute";

		function evalDivSize2() {
			evalDivSize(d);
			if(t == null) t = 5;
			if(l == null) l = (_.body.clientWidth - d.clientWidth) / 2;
			d.style.top = t;
			d.style.left = l;
		}
		evalDivSize2();
		setTimeout(evalDivSize2, 0);
	} else {
		/* window.dialogTop = (screen.availHeight - parseInt(window.dialogHeight)) / 2 - 50;
		window.dialogLeft = (screen.availWidth - parseInt(window.dialogWidth)) / 2; */
		d.minWidth = "fill";
		d.minHeight = "fill";
		_.body.style.margin = "0px";
		_.body.style.background = _.body.currentStyle["modal-background"];
		if(typeof (data) != "undefined" && is.def(data)) fillForm(data);
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
	function setElValue(e, v) {
		if(is.def(v.c)) e.style.color = v.c;
		if(is.def(v.ro)) e.readOnly = v.ro != 0;
		/* agar ro == 0 bo`lsa readonly false bo`ladi
		 */
		if(is.def(v.d)) e.disabled = v.d != 0;
		/* agar d == 0 bo`lsa disabled false bo`ladi
		 */
		if(is.def(v.v)) v = v.v;
		if(e.setValue) {
			e.setValue(replaceQGH(v));
			if(e.check) e.check();
		} else {
			e.innerText = replaceQGH(v);
		}
	}
	for(var con in data) {
		var val = data[con]
			, f, v, c, b, el, e;
		if(typeof val != "object" || is.def(val.v)) {
			setElValue(getDOM(con), val);
		} else {
			f = window[con];
			for(var elv in val) {
				try {
					v = val[elv];
					el = f[elv];
					if(is.def(v[0])) {
						if(el.tagName) {
							c = 1;
							e = el;
							if(v.length == 1) {
								setElValue(el, v[0]);
								continue;
							}
						} else {
							c = el.length;
							e = el[0];
						}
						c = v.length - c;
						if(c < 0) {
							alert("fillForm: Error in form values");
							throw "err";
						}
						if(e.mbid) {
							b = getDOM(e.mbid);
							for(var i = 0; i < c; i++) b.click();
						}
						el = f[elv];
						for(var i = 0; i < v.length; i++) {
							try {
								setElValue(el[i], v[i]);
							} catch(ex) {
								alert("Incorrect data to fill form.");
							}
						}
					} else {
						setElValue(el, val[elv]);
					}
				} catch(e) {
					alert("Error:" + elv);
					throw e
				}
			}
		}
	}
	enableElements();
}
/* AJAX.load(d)
 * url		 string - default _.URL.split("?")[0]
 * async	 boolean - default false
 * HEAD		 object
 * GET		 object
 * POST		 object
 * onSuccess	function
 * onError		function
 * method default GET, ketma ket bo`yicha HEAD, GET, POST
 * RT type exception, json, text, xml, script
 */
AJAX = ajax = {
	load: function (D) {
		xhr = new ActiveXObject("Microsoft.XMLHTTP"), mtd = "GET";
		if(is.def(D.HEAD)) mtd = "HEAD";
		if(is.def(D.GET)) mtd = "GET";
		if(is.def(D.POST)) mtd = "POST";
		else D.POST = null;
		if(is.undef(D.url)) D.url = _.URL.split("?")[0];
		if(IEVersion() < 6) D.async = true;
		else if(is.undef(D.async)) D.async = false;
		D.url = nocacheURL(D.url);
		if(D.GET) {
			for(var v in D.GET) D.url += "&" + v + "=" + encodeURIComponent(D.GET[v]);
		}
		xhr.open(mtd, D.url, D.async);
		xhr.setRequestHeader("aj", "ax");
		if(D.HEAD) {
			for(var v in D.HEAD) xhr.setRequestHeader(v, D.HEAD[v]);
		}
		var post = null;
		if(D.POST) {
			xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
			post = "";
			for(var v in D.POST) {
				var vl = makeArray(D.POST[v]);
				for(var i = 0; i < vl.length; i++) {
					post += v + "=" + encodeURIComponent(vl[i]) + "&";
				}
			}
		}
		xhr.onreadystatechange = function () {
			if(xhr.readyState == 4) {
				if(xhr.status == 200) {
					switch(xhr.getResponseHeader("RT")) {
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
					if(is.func(D.onError)) D.onError("Http status=" + xhr.status);
					else if(confirm("HTTP Status " + xhr.status + "-" + xhr.statusText)) window.open("").document.write(xhr.responseText);
				}
			}
		};
		xhr.send(post);
	}
};
/* onLoad			function to call on document loading
 * onBeforeInit function init qilishdan oldin chaqiriladi
 * funcLoad		functions to call on document loading
 */
window.funcLoad = [];
window.onload = function () {
	/*try {
		if((new String(window.location).indexOf("ibs/main.jsp")==-1))
			top._t();
	} catch (e) {
		window.location = nocacheURL(nvl(__contextPath, "") + "/ibs/logoff.jsp");
	}*/
	if(typeof onBeforeInit == "function") onBeforeInit();
	initForm("base", data);
	for(var i = 0; i < this.funcLoad.length; i++) this.funcLoad[i]();
	if(typeof onLoad == "function") onLoad();
	_.body.onkeydown = function () {
		var e = event.srcElement;
		if(e == _locklayer || (event.keyCode == 8 && !((e.tagName == "INPUT" && (e.type == "text" || e.type == "password" || e.type == "file")) || e.tagName == "TEXTAREA"))) {
			/* alert(e.outerHTML); */
			event.returnValue = false;
			return false;
		}
		if(is.def(window.dialogArguments) || is.def(top.dialogArguments)) {
			if(event.keyCode == 27) {
				window.returnValue = null;
				close();
			}
		}
	};
	_.body.onmousedown = function () {
			if(event.srcElement == _locklayer) {
				event.returnValue = false;
				return false;
			}
		}
		/* _.body.oncontextmenu = function(){
			if(!(event.altKey && event.ctrlKey))event.returnValue=false;
		} */
};
/* function lpad(str, length, symbol) kelgan stringi OLDIga symbol qo'yib qaytaradi
 * str bu keladigan string
 * length kelgan string uzunligi qancha bolishi kerak
 * symbol qaysi symbol qoyish kerarligi agar qiymat berilmasa probel(" ") qoyiladi 
 */
function lpad(str, length, symbol) {
	if(is.undef(symbol))
		symbol = " ";
	if(str.length > length)
		str = str.substring(0, length);
	for(var i = str.length; i < length; i++) {
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
	if(is.undef(symbol))
		symbol = " ";
	if(str.length > length)
		str = str.substring(0, length);
	for(var i = str.length; i < length; i++) {
		str = str + symbol;
	}
	return str;
}
/* function replaceQGH(str)
 * str kelgan textdagi barcha q, h, g' html symbol unicode ga almashtirib beradi
 */
function replaceQGH(v) {
	var newStr = new String(v).replace(new RegExp("&#1178;",'g'),"\u049A").replace(new RegExp("&#1179;",'g'),"\u049B").replace(new RegExp("&#1170;",'g'),"\u0492").replace(new RegExp("&#1171;",'g'),"\u0493").replace(new RegExp("&#1202;",'g'),"\u04B2").replace(new RegExp("&#1203;",'g'),"\u04B3");
	return newStr;
}
/* function hideFirstLastButton()
 * tableControls birinchi va oxirgi pagega o'tish knopkalarini hide qilish
 */
function hideFirstLastButton() {
	var tagName = getDOM("tableControls").getElementsByTagName("button");
	for(i=0; i<tagName.length; i++) {
		if(tagName[i].innerText == "9" || tagName[i].innerText == ":")
			hideDOM(tagName[i]);
	}
}

function createLockLayer() {
	var l = _.createElement("div");
	l.className = "locklayer";
	l.innerHTML = "<!--[if lte IE 6.5]><iframe></iframe><![endif]-->";
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
	if(is.undef(_locklayer)) {
		_locklayer = createLockLayer();
		_.body.appendChild(_locklayer);
		_locklayer.onblur = function () {
			if(is.undef(this.counter)) {
				this.counter = 0;
			}
			if(this.counter <= 3) {
				if(this.style.display == "block") this.focus();
				this.counter++;
			} else {
				this.counter = 0;
			}
		};
	}
	_locklayer.setSize(_.body.scrollWidth, _.body.scrollHeight);
	if(state) {
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
	}
	while (o = o.offsetParent);
	return z;
}

function drawMenu(menu, x, y, pr) {
	var cnt = _.createElement("<span>")
		, mo = _.createElement("table");
	cnt.appendChild(mo);
	cnt.style.position = "absolute";
	cnt.style.zIndex = 11;
	mo.cellSpacing = 2;
	mo.className = "Menu";
	mo.onselectstart = new Function("return false");
	mo.onmouseover = function () {
		event.cancelBubble = true;
	};
	for(var m in menu) {
		var mi = mo.insertRow()
			, mia;
		mi.tag = menu[m];
		if(is.undef(menu[m].label)) {
			mia = mi.insertCell();
			mia.className = "MenuSeparator";
			mia.innerHTML = "&nbsp;";
			mi._SEP = "T";
			continue;
		}
		mia = "<table width=100% cellpadding=0 cellspacing=0><tr><td nowrap>" + menu[m].label + "<td class=MenuArrow>&nbsp;";
		if(mi.tag.items) {
			mia += "4";
		} else {
			mia += "&nbsp;&nbsp;";
		}
		mia += "</table>";
		mi.insertCell().innerHTML = mia;
		mi.cells[0].className = "MenuItem";
		mi._M = true;
		mi.onmouseover = function () {
			var t = this
				, c = t.parentNode.rows
				, r;
			for(var i = 0; i < c.length; i++) {
				r = c[i];
				if(r != t && r._SEP != "T") {
					r.cells[0].className = "MenuItem";
					if(r.items) {
						r.items.removeNode(true);
						r.items = null;
					}
				}
			}
			t.cells[0].className = "MenuItemHover";
			if(t.tag.items) {
				if(!t.items) t.items = drawMenu(t.tag.items, t.offsetWidth, t.offsetTop, t.cells[0]);
			}
		};
		mi.onclick = function () {
			event.cancelBubble = true;
			var o = this;
			while(!(o.tagName == "SPAN" && o._TOP == "T")) o = o.parentNode;
			o.removeNode(true);
			if(is.func(this.tag.action)) this.tag.action();
		}
	}
	var z = 0
		, w = 150;
	pr = nvl(pr, _.body);
	pr.appendChild(cnt);
	if(pr != _.body) {
		z = goParent(cnt, 4).clientWidth;
	}
	cnt.style.left = x;
	cnt.style.top = y;
	if(mo.clientWidth > w) w = mo.clientWidth;
	mo.style.width = w + "px";
	if(_.body.clientWidth < pos(cnt, "Left") + mo.offsetWidth) {
		x = x - mo.offsetWidth - z;
	}
	z = _.body.clientHeight - pos(cnt, "Top") - mo.offsetHeight;
	if(z < 0) {
		y = y + z;
	}
	cnt.style.left = x;
	cnt.style.top = y;
	var ll = createLockLayer();
	cnt.appendChild(ll);
	ll.setSize(mo.offsetWidth, mo.offsetHeight);
	ll.style.display = "block";
	if(pr == _.body || pr.tagName == "SPAN") {
		cnt.focus();
		cnt._TOP = "T";
		/* TODO hato shu clickda
		 */
		cnt.onmousedown = function () {
			var o = event.srcElement
				, i = 0;
			while(is.def(o) && (!(o.tagName == "TR" && o._M) || i++ > 1)) o = o.parentNode;
			if(is.def(o) && o._M) {
				o.onclick();
			}
		};
		cnt.onblur = function () {
			this.removeNode(true)
		}
	}
	return cnt;
}

function drawTab(tab, asTab) {
	var cnt = getDOM("tabControls")
		, ti;
	/*----function showMenu----*/
	function showMenu(t) {
		t.style.background = t.currentStyle["background-hover"];
		t.style.border = t.currentStyle["border-outset"];
		for(var v in tab) {
			if(ti.tag.items) {
				_.body.focus();
				break
			}
		}
		if(t.tag.items) {
			drawMenu(t.tag.items, t.offsetParent.offsetLeft + t.offsetLeft, t.offsetParent.offsetTop + t.offsetTop + t.offsetHeight + 3, t);
		}
	}
	for(var v in tab) {
		ti = _.createElement("span");
		ti.className = "tab";
		ti.onselectstart = new Function("return false");
		ti.tag = tab[v];
		ti.asTab = nvl(asTab, false);
		ti.selected = false;
		ti.innerHTML = tab[v].label;
		cnt.appendChild(ti);
		/*----onmouseout----*/
		ti.onmouseout = function () {
			if(!this.selected) {
				this.style.background = "#EBE9E6";
				this.style.border = "1px solid #EBE9E6";
			}
		};
		/*----onmouseover----*/
		ti.onmouseover = function () {
			showMenu(this);
		};
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
		if(ti.tag.action) {
			ti.onclick = function () {
				if(this.asTab) {
					var tabs = this.parentNode.children;
					for(var i = 0; i < tabs.length; i++) {
						if(tabs[i] == this) tabs[i].Select();
						else tabs[i].unSelect();
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

function printPreview(url) {
	go({
		url: url
		, target: 'new'
		, lock: false
		, arg: "left=0, top=0, width=" + (screen.availWidth - 10) + ", height=" + (screen.availHeight - 70) + ", scrollbars=1,directories=0,location=0,menubar=1,resizable=1,status=1,titlebar=0,toolbar=0"
	});
}

function editFormLanguages(val) {
	window.showModalDialog(nvl(__contextPath, "") + "/mlmhelper.jsp?fileUrl=" + val, '', "resizable:yes; scroll:no; status:no; help:no ;dialogWidth:" + screen.availWidth + "px; dialogHeight:" + screen.availHeight + "px;");
}

/*top._t().CACHE=top._t().CACHE||{
	uc:{},
	gn:function(d,n){
		if(is.number(n))n=d.URL.split("?")[0]+n;
		return n
	},
	put:function(d,n,s){
		this.uc[this.gn(d,n)]=s;
		d.write(s);
	},
	get:function(d,n){
		d.write(this.uc[this.gn(d,n)])
	}
};*/
