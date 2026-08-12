// This function is used to define if the browser supports the needed
// Karimboyev A'loxon
c = 0;

function hasSupport() {
	if (typeof hasSupport.support != "undefined")
		return hasSupport.support;

	var ie55 = /msie 5\.[56789]/i.test(navigator.userAgent);

	hasSupport.support = (typeof document.implementation != "undefined" &&
		document.implementation.hasFeature("html", "1.0") || ie55)

	// IE55 has a serious DOM1 bug... Patch it!
	if (ie55) {
		document._getElementsByTagName = document.getElementsByTagName;
		document.getElementsByTagName = function (sTagName) {
			if (sTagName == "*")
				return document.all;
			else
				return document._getElementsByTagName(sTagName);
		};
	}
	return hasSupport.support;
}

function WebFXTabPane(el, bUseCookie) {
	if (!hasSupport() || el == null) return;

	this.element = el;
	this.element.tabPane = this;
	this.pages = [];
	this.selectedIndex = null;
	this.useCookie = bUseCookie != null ? bUseCookie : true;

	// add class name tag to class name
	this.element.className = this.classNameTag + " " + this.element.className;

	// add tab row
	this.tabRow = document.createElement("div");
	this.tabRow.className = "tab-row";
	el.insertBefore(this.tabRow, el.firstChild);

	var tabIndex = 0;
	this.selectedIndex = tabIndex;
	// loop through child nodes and add them
	var cs = el.childNodes;
	var n;
	for (var i = 0; i < cs.length; i++) {
		if (cs[i].nodeType == 1 && cs[i].className == "tab-page") {
			this.addTabPage(cs[i]);
		}
	}
}

WebFXTabPane.prototype.classNameTag = "dynamic-tab-pane-control";

WebFXTabPane.prototype.setSelectedIndex = function (n) {
	if (this.selectedIndex != n) {
		if (this.selectedIndex != null && this.pages[this.selectedIndex] != null)
			this.pages[this.selectedIndex].hide();
		this.selectedIndex = n;
		this.pages[this.selectedIndex].show();
	}
};

WebFXTabPane.prototype.getSelectedIndex = function () {
	return this.selectedIndex;
};

WebFXTabPane.prototype.addTabPage = function (oElement) {
	if (!hasSupport()) return;

	if (oElement.tabPage == this)	// already added
		return oElement.tabPage;

	var n = this.pages.length;
	var tp = this.pages[n] = new WebFXTabPage(oElement, this, n);
	tp.tabPane = this;

	// move the tab out of the box
	this.tabRow.appendChild(tp.tab);

	if (n == this.selectedIndex)
		tp.show();
	else
		tp.hide();

	return tp;
};

WebFXTabPane.prototype.dispose = function () {
	this.element.tabPane = null;
	this.element = null;
	this.tabRow = null;

	for (var i = 0; i < this.pages.length; i++) {
		this.pages[i].dispose();
		this.pages[i] = null;
	}
	this.pages = null;
};


function WebFXTabPage(el, tabPane, nIndex) {
	if (!hasSupport() || el == null) return;

	this.element = el;
	this.element.tabPage = this;
	this.index = nIndex;

	var cs = el.childNodes;
	for (var i = 0; i < cs.length; i++) {
		if (cs[i].nodeType == 1 && cs[i].className == "tab") {
			this.tab = cs[i];
			break;
		}
	}
	// insert a tag around content to support keyboard navigation
	var a = document.createElement("A");
	this.aElement = a;
	a.href = "#";

	a.onclick = function () {
		return false;
	};
	while (this.tab.hasChildNodes()) {
		c++;
		a.id = c;
		a.appendChild(this.tab.firstChild);
	}
	this.tab.appendChild(a);
	// hook up events, using DOM0
	var oThis = this;
	this.tab.onclick = function () {
		c = this.children[0].id;
		var children = this.parentNode.nextSibling.firstChild.nextSibling;
		txtarea = document.getElementsByName(children.name)[0];
		if (txtarea && txtarea.r == 1 && txtarea.value == "") {
			txtarea.focus();
			return;
		}
		oThis.select();
		if (children.tagName == "TEXTAREA" || children.tagName == "SELECT")
			document.getElementsByName(children.name)[oThis.index].focus();
		if (c == '3' && document.getElementsByName(children.name)[2] && document.getElementsByName(children.name)[1])// kirill - lotin
			document.getElementsByName(children.name)[2].value = deconvert(document.getElementsByName(children.name)[1].value);
		if (c == '2' && document.getElementsByName(children.name)[2] && document.getElementsByName(children.name)[1])// lotin - kirill
			document.getElementsByName(children.name)[1].value = deconvert(document.getElementsByName(children.name)[2].value);
	}
	this.tab.onmouseover = function () {
		WebFXTabPage.tabOver(oThis);
	};
	this.tab.onmouseout = function () {
		WebFXTabPage.tabOut(oThis);
	};
}

WebFXTabPage.prototype.show = function () {
	var el = this.tab;
	var s = el.className + " selected";
	s = s.replace(/ +/g, " ");
	el.className = s;

	this.element.style.display = "block";
};

WebFXTabPage.prototype.hide = function () {
	var el = this.tab;
	var s = el.className;
	s = s.replace(/ selected/g, "");
	el.className = s;

	this.element.style.display = "none";
};

WebFXTabPage.prototype.select = function () {
	this.tabPane.setSelectedIndex(this.index);
};

WebFXTabPage.prototype.dispose = function () {
	this.aElement.onclick = null;
	this.aElement = null;
	this.element.tabPage = null;
	this.tab.onclick = null;
	this.tab.onmouseover = null;
	this.tab.onmouseout = null;
	this.tab = null;
	this.tabPane = null;
	this.element = null;
};

WebFXTabPage.tabOver = function (tabpage) {
	var el = tabpage.tab;
	var s = el.className + " hover";
	s = s.replace(/ +/g, " ");
	el.className = s;
};

WebFXTabPage.tabOut = function (tabpage) {
	var el = tabpage.tab;
	var s = el.className;
	s = s.replace(/ hover/g, "");
	el.className = s;
};


// This function initializes all uninitialized tab panes and tab pages
function setupAllTabs() {
	if (!hasSupport()) return;

	var all = document.getElementsByTagName("*");
	var l = all.length;
	var tabPaneRe = /tab\-pane/;
	var tabPageRe = /tab\-page/;
	var cn, el;
	var parentTabPane;

	for (var i = 0; i < l; i++) {
		el = all[i]
		cn = el.className;

		// no className
		if (cn == "") continue;

		// uninitiated tab pane
		if (tabPaneRe.test(cn) && !el.tabPane)
			new WebFXTabPane(el);

		// unitiated tab page wit a valid tab pane parent
		else if (tabPageRe.test(cn) && !el.tabPage &&
			tabPaneRe.test(el.parentNode.className)) {
			el.parentNode.tabPane.addTabPage(el);
		}
	}
}

function disposeAllTabs() {
	if (!hasSupport()) return;

	var all = document.getElementsByTagName("*");
	var l = all.length;
	var tabPaneRe = /tab\-pane/;
	var cn, el;
	var tabPanes = [];

	for (var i = 0; i < l; i++) {
		el = all[i]
		cn = el.className;

		// no className
		if (cn == "") continue;

		// tab pane
		if (tabPaneRe.test(cn) && el.tabPane)
			tabPanes[tabPanes.length] = el.tabPane;
	}

	for (var i = tabPanes.length - 1; i >= 0; i--) {
		tabPanes[i].dispose();
		tabPanes[i] = null;
	}
}

// DOM2
if (typeof window.addEventListener != "undefined")
	window.addEventListener("load", setupAllTabs, false);

// IE 
else if (typeof window.attachEvent != "undefined") {
	window.attachEvent("onload", setupAllTabs);
	window.attachEvent("onunload", disposeAllTabs);
} else {
	if (window.onload != null) {
		var oldOnload = window.onload;
		window.onload = function (e) {
			oldOnload(e);
			setupAllTabs();
		};
	} else
		window.onload = setupAllTabs;
}

function deconvert(w) {
	var a = "";
	for (i = 0; i < w.length; i++) {
		if (c == '2') {// lotin - kirill
			d = {
				"B": "Á",
				"G": "Ã",
				"F": "Ô",
				"H": "Õ",
				"I": "È",
				"J": "Æ",
				"L": "Ë",
				"N": "Í",
				"P": "Ï",
				"Q": "K",
				"R": "Ð",
				"K": "Ê",
				"S": "C",
				"U": "Ó",
				"Z": "Ç",
				"D": "Ä",
				"Y": "É",
				"W": "Â",
				"V": "Â",
				"b": "á",
				"ã": "g",
				"f": "ô",
				"h": "õ",
				"i": "è",
				"j": "æ",
				"k": "ê",
				"l": "ë",
				"n": "í",
				"p": "ï",
				"r": "ð",
				"s": "c",
				"g": "ã",
				"u": "ó",
				"w": "â",
				"v": "â",
				"d": "ä",
				"y": "é",
				"q": "ê",
				"m": "ì",
				"t": "ò",
				"z": "ç",
				"'": "ü"
			};
		}
		if (c == '3') {// kirill - lotin
			d = {
				"Á": "B",
				"Â": "V",
				"Ã": "G",
				"Ô": "F",
				"Õ": "H",
				"È": "I",
				"Æ": "J",
				"Ë": "L",
				"Í": "N",
				"X": "X",
				"Ï": "P",
				"Ð": "R",
				"Ñ": "S",
				"Ó": "U",
				"Ä": "D",
				"Û": "I",
				"¡": "O'",
				"Ý": "E",
				"×": "Ch",
				"Ø": "Sh",
				"Ù": "Sh",
				"É": "Y",
				"ß": "YA",
				"Þ": "YU",
				"¨": "YO",
				"Ç": "Z",
				"á": "b",
				"ô": "f",
				"õ": "h",
				"è": "i",
				"æ": "j",
				"ë": "l",
				"í": "n",
				"ï": "p",
				"ð": "r",
				"ñ": "s",
				"c": "s",
				"ó": "u",
				"ä": "d",
				"é": "y",
				"ì": "m",
				"ì": "m",
				"ò": "t",
				"¢": "o'",
				"â": "v",
				"ã": "g",
				"ù": "sh",
				"ÿ": "ya",
				"þ": "yu",
				"¸": "yo",
				"Ö": "Ts",
				"ö": "ts",
				"ç": "z",
				"÷": "ch",
				"ø": "sh",
				"ü": "'",
				"û": "i",
				"ý": "e"
			};
		}
		if (d[w.charAt(i)] != undefined) {
			a = a + d[w.charAt(i)];
		}
		if (d[w.charAt(i)] == undefined) {
			a = a + w.charAt(i);
		}
		if (w.charAt(i) == "h" || w.charAt(i) == "'") {
			if (w.charAt(i - 1) == 'c' && w.charAt(i) == "h") {
				a = a.substring(0, a.length - 2) + "÷";
			}
			if (w.charAt(i - 1) == 's' && w.charAt(i) == "h") {
				a = a.substring(0, a.length - 2) + "ø";
			}
			if (w.charAt(i - 1) == 'o' && w.charAt(i) == "'") {
				a = a.substring(0, a.length - 2) + "¢";
			}
			if (w.charAt(i - 1) == 'g' && w.charAt(i) == "'") {
				a = a.substring(0, a.length - 2) + "ã";
			}
		}
		if (w.charAt(i) == "h" || w.charAt(i) == "'") {
			if (w.charAt(i - 1) == 'C' && w.charAt(i) == "h") {
				a = a.substring(0, a.length - 2) + "×";
			}
			if (w.charAt(i - 1) == 'S' && w.charAt(i) == "h") {
				a = a.substring(0, a.length - 2) + "Ø";
			}
			if (w.charAt(i - 1) == 'O' && w.charAt(i) == "'") {
				a = a.substring(0, a.length - 2) + "¡";
			}
			if (w.charAt(i - 1) == 'G' && w.charAt(i) == "'") {
				a = a.substring(0, a.length - 2) + "Ã";
			}
		}
	}
	return a;
}