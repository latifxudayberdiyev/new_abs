/*--------------------=====global o'zgaruvchilar=======--------------------------*/
var mI = 0, h = 0, menu = null, esc = null, ifrm = null, fc = null, fl = null, ps = "", _mID = "", _mEndTime = "",
    _mTimeout, cache = new Array(), mn = [], rm = [], hm = {}, for_search = [], iabs_search = [], report_search = [],
    iabs = {}, recent = {}, reports = {}, modalTitle = "", global_search = "", is_turn_pin = false, isLoaded = false,
    posCursor = 0, fr = 0, dwn = 0, up = 0, readedMessages = [];
/*-------------------====datani formatlari uchun=====---------------------------*/
(function () {
    function g(a, c) {
        a.setHours(a.getHours() + parseFloat(c));
        return a
    }

    function h(a, c) {
        var b = "Sunday Monday Tuesday Wednesday Thursday Friday Saturday".split(" ");
        return c ? b[a.getDay()].substr(0, 3) : b[a.getDay()]
    }

    function k(a, c) {
        var b = "January February March April May June July August September October November December".split(" ");
        return c ? b[a.getMonth()].substr(0, 3) : b[a.getMonth()]
    }

    function e(a, c) {
        if (a) {
            if ("compound" == a) {
                if (!1 === c) return this.format.compound;
                var b = {}, d;
                for (d in Date.prototype.format.compound) b[d] =
                    this.format(Date.prototype.format.compound[d]);
                return b
            }
            if (Date.prototype.format.compound[a]) return this.format(Date.prototype.format.compound[a], c);
            if ("constants" == a) {
                if (!1 === c) return this.format.constants;
                b = {};
                for (d in Date.prototype.format.constants) b[d] = this.format(Date.prototype.format.constants[d]);
                return b
            }
            if (Date.prototype.format.constants[a]) return this.format(Date.prototype.format.constants[a], c);
            if ("pretty" == a) {
                if (!1 === c) return this.format.pretty;
                b = {};
                for (d in Date.prototype.format.pretty) b[d] =
                    this.format(Date.prototype.format.pretty[d]);
                return b
            }
            if (Date.prototype.format.pretty[a]) return this.format(Date.prototype.format.pretty[a], c);
            var b = a.split(""), e = "";
            for (d in b) {
                var f = b[d];
                f && /[a-z]/i.test(f) && !/\\/.test(e + f) && (b[d] = l[f] ? l[f].apply(this) : f);
                e = b[d]
            }
            return b.join("").replace(/\\/g, "")
        }
        return a
    }

    var l = {
        d: function () {
            var a = this.getDate();
            return 9 < a ? a : "0" + a
        }, D: function () {
            return h(this, !0)
        }, j: function () {
            return this.getDate()
        }, l: function () {
            return h(this)
        }, N: function () {
            return this.getDay() +
                1
        }, S: function () {
            var a = this.getDate();
            return /^1[0-9]$/.test(a) ? "th" : /1$/.test(a) ? "st" : /2$/.test(a) ? "nd" : /3$/.test(a) ? "rd" : "th"
        }, w: function () {
            return this.getDay()
        }, z: function () {
            return Math.round(Math.abs((this.getTime() - (new Date("1/1/" + this.getFullYear())).getTime()) / 864E5))
        }, W: function () {
            var a = new Date(this.getFullYear(), 0, 1);
            return Math.ceil(((this - a) / 864E5 + a.getDay() + 1) / 7)
        }, F: function () {
            return k(this)
        }, m: function () {
            var a = this.getMonth() + 1;
            return 9 < a ? a : "0" + a
        }, M: function () {
            return k(this, !0)
        }, n: function () {
            return this.getMonth() +
                1
        }, t: function () {
            return (new Date(this.getFullYear(), this.getMonth() + 1, 0)).getDate()
        }, L: function () {
            var a = this.getFullYear();
            return 0 == a % 4 && 0 != a % 100 || 0 == a % 400
        }, o: function () {
            return parseInt(this.getFullYear())
        }, Y: function () {
            return parseInt(this.getFullYear())
        }, y: function () {
            return parseInt((this.getFullYear() + "").substr(-2))
        }, a: function () {
            return 12 <= this.getHours() ? "pm" : "am"
        }, A: function () {
            return 12 <= this.getHours() ? "PM" : "AM"
        }, B: function () {
            return "@" + ("00" + Math.floor((60 * ((this.getHours() + 1) % 24 * 60 + this.getMinutes()) +
                this.getSeconds() + .001 * this.getMilliseconds()) / 86.4)).slice(-3)
        }, g: function () {
            var a = this.getHours();
            return 0 == a ? 12 : 12 >= a ? a : a - 12
        }, G: function () {
            return this.getHours()
        }, h: function () {
            var a = this.getHours(), a = 12 >= a ? a : a - 12;
            return 0 == a ? 12 : 9 < a ? a : "0" + a
        }, H: function () {
            var a = this.getHours();
            return 9 < a ? a : "0" + a
        }, i: function () {
            var a = this.getMinutes();
            return 9 < a ? a : "0" + a
        }, s: function () {
            var a = this.getSeconds();
            return 9 < a ? a : "0" + a
        }, u: function () {
            return this.getMilliseconds()
        }, e: function () {
            var a = this.toString().match(/ ([A-Z]{3,4})([-|+]?\d{4})/);
            return 1 < a.length ? a[1] : ""
        }, I: function () {
            var a = new Date(this.getFullYear(), 0, 1), c = new Date(this.getFullYear(), 6, 1),
                a = Math.max(a.getTimezoneOffset(), c.getTimezoneOffset());
            return this.getTimezoneOffset() < a ? 1 : 0
        }, O: function () {
            var a = this.toString().match(/ ([A-Z]{3,4})([-|+]?\d{4})/);
            return 2 < a.length ? a[2] : ""
        }, P: function () {
            var a = this.toString().match(/ ([A-Z]{3,4})([-|+]?\d{4})/);
            return 2 < a.length ? a[2].substr(0, 3) + ":" + a[2].substr(3, 2) : ""
        }, T: function () {
            return this.toLocaleString("en", {timeZoneName: "short"}).split(" ").pop()
        },
        Z: function () {
            return 60 * this.getTimezoneOffset()
        }, c: function () {
            return g(new Date(this), -(this.getTimezoneOffset() / 60)).toISOString()
        }, r: function () {
            return g(new Date(this), -(this.getTimezoneOffset() / 60)).toISOString()
        }, U: function () {
            return this.getTime() / 1E3 | 0
        }
    }, m = {
        commonLogFormat: "d/M/Y:G:i:s",
        exif: "Y:m:d G:i:s",
        isoYearWeek: "Y\\WW",
        isoYearWeek2: "Y-\\WW",
        isoYearWeekDay: "Y\\WWj",
        isoYearWeekDay2: "Y-\\WW-j",
        mySQL: "Y-m-d h:i:s",
        postgreSQL: "Y.z",
        postgreSQL2: "Yz",
        soap: "Y-m-d\\TH:i:s.u",
        soap2: "Y-m-d\\TH:i:s.uP",
        unixTimestamp: "@U",
        xmlrpc: "Ymd\\TG:i:s",
        xmlrpcCompact: "Ymd\\tGis",
        wddx: "Y-n-j\\TG:i:s"
    }, n = {
        AMERICAN: "F j, Y",
        AMERICANSHORT: "m/d/Y",
        AMERICANSHORTWTIME: "m/d/Y h:i:sA",
        ATOM: "Y-m-d\\TH:i:sP",
        COOKIE: "l, d-M-Y H:i:s T",
        EUROPEAN: "j F Y",
        EUROPEANSHORT: "d.m.Y",
        EUROPEANSHORTWTIME: "d.m.Y H:i:s",
        ISO8601: "Y-m-d\\TH:i:sO",
        LEGAL: "j F Y",
        RFC822: "D, d M y H:i:s O",
        RFC850: "l, d-M-y H:i:s T",
        RFC1036: "D, d M y H:i:s O",
        RFC1123: "D, d M Y H:i:s O",
        RFC2822: "D, d M Y H:i:s O",
        RFC3339: "Y-m-d\\TH:i:sP",
        RSS: "D, d M Y H:i:s O",
        W3C: "Y-m-d\\TH:i:sP"
    }, p = {
        "pretty-a": "g:i.sA l jS \\o\\f F, Y",
        "pretty-b": "g:iA l jS \\o\\f F, Y",
        "pretty-c": "n/d/Y g:iA",
        "pretty-d": "n/d/Y",
        "pretty-e": "F jS - g:ia",
        "pretty-f": "g:iA",
        "pretty-g": "F jS, Y",
        "pretty-h": "F jS, Y g:mA"
    };
    Object.defineProperty ? Object.defineProperty(e, "compound", {value: m}) : e.compound = m;
    Object.defineProperty ? Object.defineProperty(e, "constants", {value: n}) : e.constants = n;
    Object.defineProperty ? Object.defineProperty(e, "pretty", {value: p}) : e.pretty = p;
    Object.defineProperty && !Date.prototype.hasOwnProperty("format") ?
        Object.defineProperty(Date.prototype, "format", {value: e}) : Date.prototype.format = e
})();

/*======= kirilchadan lotinchaga o'tkazadi =====*/
function cyril_to_lat(word) {
    var A = {};
    var result = '';
    A["Ё"] = "YO";
    A["Й"] = "I";
    A["Ц"] = "TS";
    A["У"] = "U";
    A["К"] = "K";
    A["Е"] = "E";
    A["Н"] = "N";
    A["Г"] = "G";
    A["Ш"] = "SH";
    A["Щ"] = "SH";
    A["З"] = "Z";
    A["Х"] = "X";
    A["Ъ"] = "'";
    A["ё"] = "yo";
    A["й"] = "i";
    A["ц"] = "ts";
    A["у"] = "u";
    A["к"] = "k";
    A["е"] = "e";
    A["н"] = "n";
    A["г"] = "g";
    A["ш"] = "sh";
    A["щ"] = "sh";
    A["з"] = "z";
    A["х"] = "x";
    A["ъ"] = "'";
    A["Ф"] = "F";
    A["Ы"] = "I";
    A["В"] = "V";
    A["А"] = "A";
    A["П"] = "P";
    A["Р"] = "R";
    A["О"] = "O";
    A["Л"] = "L";
    A["Д"] = "D";
    A["Ж"] = "J";
    A["Э"] = "E";
    A["ф"] = "f";
    A["ы"] = "i";
    A["в"] = "v";
    A["а"] = "a";
    A["п"] = "p";
    A["р"] = "r";
    A["о"] = "o";
    A["л"] = "l";
    A["д"] = "d";
    A["ж"] = "j";
    A["э"] = "e";
    A["Я"] = "YA";
    A["Ч"] = "CH";
    A["С"] = "S";
    A["М"] = "M";
    A["И"] = "I";
    A["Т"] = "T";
    A["Ь"] = "'";
    A["Б"] = "B";
    A["Ю"] = "YU";
    A["я"] = "ya";
    A["ч"] = "ch";
    A["с"] = "s";
    A["м"] = "m";
    A["и"] = "i";
    A["т"] = "t";
    A["ь"] = "'";
    A["б"] = "b";
    A["ю"] = "yu";
    for (var i = 0; i < word.length; i++) {
        var c = word.charAt(i);
        result += A[c] || c;
    }
    return result;
}

/**=======================================*/
function overSvg(img) {
    if (goParent(img, 1).className.indexOf("active") == -1) {
        if (img.src.indexOf(".svg") != -1) {
            if (img.src.indexOf("2.svg") == -1)
                img.src = img.src.replace(".svg", "2.svg");
        } else {
            if (img.src.indexOf("2.png") == -1)
                img.src = img.src.replace(".png", "2.png");
        }
    }
}

function outSvg(img) {
    if (goParent(img, 1).className.indexOf("active") == -1) {
        if (img.src.indexOf(".svg") != -1) {
            if (img.src.indexOf("2.svg") != -1)
                img.src = img.src.replace("2.svg", ".svg");
        } else {
            if (img.src.indexOf("2.png") != -1)
                img.src = img.src.replace("2.png", ".png");
        }
    }
}

/**=======================================*/
cache2 = {
    user_cache: new Array(),
    put: function (w, st, name) {
        uc = this.user_cache;
        if (name) {
            uc[name] = st;
        } else {
            var nam = w.document.URL.split('?')[0],
                pag = uc[nam];
            if (!pag) {
                uc[nam] = new Array();
                pag = uc[nam];
            }
            pag.push(st);
        }
        w.document.write(st);
    },
    get: function (w, name) {
        if (typeof name == "string") {
            w.document.write(this.user_cache[name]);
        } else {
            w.document.write(this.user_cache[w.document.URL.split('?')[0]][name]);
        }
    }
};
// Обработчик клавиатуры Меню
_.onkeydown = function (e) {
    var event = e || window.event;
    if (event.keyCode == 116) {
        event.keyCode = 505;
    }
    if (event.keyCode == 505) {
        return false;
    }
    menuKey(event);
    if (event.keyCode == 27) {
        closeNav();
        if (is.def(getDOM("user_sel"))) chose_one(false);
    }
}
var JsonHashTable = function () {
    var s = this;
    var json = {};
    var msg = "";
    this.getJson = function () {
        json.transfer_times = s.mergeMsgandJson();
        return json;
    };
    this.setJson = function (j) {
        json = j;
    };
    this.setNotifyMsg = function (m) {
        msg = m.split("~")[0] + "~" + m.split("~")[1];
    };
    this.setMsg_cnt = function (cnt) {
        json.message_cnt = cnt;
    };
    this.mergeMsgandJson = function () {
        var m = msg.split(" ");
        if (m.length == 1) return;
        var transfers = [];
        for (var i = 0; i < m.length; i++) {
            var js = {};
            js.title = m[i].split("<b>")[0];
            var l = m[i].split("<b>")[1].length;
            js.value = m[i].split("<b>")[1].substr(0, l - 4);
            transfers.push(js);
        }
        return transfers;
    };
};
var jsonHash = new JsonHashTable();
/*----------WEBSOCKET------------*/
var fbws = new FBWebSocket();
/*===ochiq menu tashqarisidagi iframe bosilgandan menuni yopish uchun===*/
window.addEventListener('blur', function () {
    if ((_.activeElement.tagName == "IFRAME" || _.activeElement.tagName == "FRAME"))
        closeNav();
});

/*======menu ochilganda vaqtincha sloy tortib qo'yilgan shuni olib tashlash uchun=====*/
_.onclick = function (e) {
    var event = e || window.event;
    var dom = event.srcElement || event.target;
    var id = dom.getAttribute("id");
    if (id == "content") {
        closeNav();
        rightMenu(false);
    }
    if (id != "msg" && is.def(getDOM("user_sel")) && getDOM("user_sel").style.display != "none") {
        if (!event.target.closest("#employee") && !event.target.closest("#user_sel")) {
            chose_one(false);
        }
    } else if (id != "hasopday" && is.def(getDOM("list_operdays")) && getDOM("list_operdays").style.display != "none") {
        hideDOM("list_operdays");
        getDOM("oper_den_img").className = "";
    } else if (id != "new_op_den" && is.def(getDOM("opentime")) && getDOM("opentime").style.display != "none") {
        hideDOM("opentime");
    } else if (id != "trm_ico_img" && is.def(getDOM("rightmenu")) && getDOM("rightmenu").style.display != "none") {
        hideDOM("rightmenu");
        getDOM("trm_ico").className = "";
        getDOM("trm_ico_img").src = "/ibs/user/img/" + themeName + "/svg/currency.svg";
    }
    if (is.def(e.target)) {
        /*=== menu ochiq bo'lsa va u turgan blockdan boshqa joy click bo'lsa menuni yopish uchun ===*/
        if ((!e.target.closest("#mySidenav")) && (!e.target.closest("#vertical_menu"))) {
            if (is.def(getDOM("mySidenav"))) {
                if (getDOM("mySidenav").classList == "sidenav open")
                    closeNav();
            }
        }

        /*=== right menu ochiq bo'lsa va u turgan blockdan boshqa joy click bo'lsa menuni yopish uchun ===*/
        if ((!e.target.closest("#trm_ico")) && (!e.target.closest("#rightmenu"))) {
            if (is.def(getDOM("rightmenu"))) {
                if (getDOM("rightmenu").className == "active")
                    rightMenu(false);
            }
        }
    }
};

/*===knopka bosilishni boshlashi bn avtomat searchga yozib ketadi agar menu ochiq bo'lsa=====*/
_.onkeypress = function (e) {
    var wd = getNavWidth();
    if (getDOM("iabsDiv").style.display == "inline" && wd == "450") {
        getDOM("keyword_menu").focus();
    } else if (getDOM("reportsDiv").style.display == "inline" && wd == "451") {
        getDOM("keyword_report").focus();
    }
};

/**============klaviaturadan boshqarish=====*/
function up_down(e) {
    /***CTRL+1***/
    var event = e || window.event;
    if (event.ctrlKey && event.keyCode == 49) {
        openNav();
    }
    /***CTRL+2***/
    if (event.ctrlKey && event.keyCode == 50) {
        openRecent();
    }
    /***CTRL+3***/
    if (event.ctrlKey && event.keyCode == 51) {
        openReport();
    }
    /***CTRL+4***/
    if (event.ctrlKey && event.keyCode == 52) {
        closeNav();
        openFavourite();
    }
}

/*================================start menu sidebar and content=====================================================*/

/*========== barcha jsonlarni bazadan olib kelish ==========*/
function getMenu() {
    AJAX.load({POST: {request: "get_menu"}});
}

function getPin() {
    AJAX.load({POST: {request: "get_menu_pinn"}});
}

function getReports() {
    AJAX.load({POST: {request: "get_reports"}});
}

function getMessage() {
    AJAX.load({POST: {request: "get_message"}});
}

function getNotify() {
    AJAX.load({POST: {request: "get_notify"}});
}

function getChat() {
    return;
    AJAX.load({POST: {request: "chat", mID: _mID}, async: true});
}

function getUserCache() {
    AJAX.load({POST: {request: "user_cache"}, async: true});
}

function getIabsInfo() {
    AJAX.load({
        POST: {request: "get_iabs_info"}, onSuccess: function (d) {
            d = eval('(' + d.trim() + ')');
            jsonHash.setJson(d);
        }
    });
}

function getUserImage() {
    AJAX.load({
        POST: {request: "get_user_image"}, onSuccess: function (d) {
            d = eval('(' + d.replace(/\n|\r/g, "") + ')');
            if (d[1] != "EMPTY") {
                getDOM("user_image").src = "data:" + d[1] + ";base64," + d[0];
            }
        }, onError: function (d) {
            alert(d);
        }
    });
}

/*========= virtual user bo'lib kirish =====================*/
function changeUser(obj, user_id, filial_local) {
    hideDOM("user_sel");
    AJAX.load({
        url: nocacheURL(nvl(__contextPath, "") + "/ibs/login_by_vu.jsp"),
        POST: {
            user_id: user_id
        },
        onSuccess: function (d) {
            if (d.trim() == "Y") {
                var str = getDOM("employee").innerHTML;
                var l = getDOM("user_sel").getElementsByTagName("label");
                for (var i = 0; i < l.length; i++) {
                    l[i].style.fontWeight = "";
                }
                obj.style.fontWeight = "bold";
                setDOMValue("filialcode", filial_local + " / " + top.user_code + " (" + user_id + ")");
                getMenu();
                getMessage();
                getNotify();
                getPin();
                getUserCache();
            } else {
                alert(d);
            }
        }
    });
}

/**
 *olib kelingan jsonlarni global o'zgaruvchiga berish  va qandaydir xatolik bo'lsa iabs 6.0.0 menusini o'zini menularni chizish uchun
 */
function urlPathForRecent(arr) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i].l.indexOf("class=srch") < 0) {
            arr[i].l += searchs[arr[i].c];
        }
    }
    return arr;
}

function getLoadListData(searchList, menuType) {
    var searchEntryNames = [],
        formCodes = [];
    for (var i = 0; i < searchList.length; i++) {
        searchEntryNames.push(searchList[i].l);
        formCodes.push(searchList[i].c);
    }
    return {
        "listName": menuType,
        "searchEntryNames": searchEntryNames,
        "formCodes": formCodes
    };
}

function createMenu(d, r) {
    iabs = d;
    recent = r;
    for_search = [];
    getDOM("tree").innerHTML = drawItem(iabs, 0, true, "iabs");
    var data = getLoadListData(for_search, "iabs");
    fbws.loadListForSearch(data);
    goFavorite();
}

/*======otchyotlarni oliob kelib menu qilib chizib beradi =======*/
function createReports(d) {
    reports = d;
    getDOM("reports").innerHTML = drawItem(reports, 0, true, "reports");
    var data = getLoadListData(report_search, "reports");
    fbws.loadListForSearch(data);
}

/***=============start menu ===============================*/

/*===menu chizayotganda bolasi bor yoki yo'qligini tekshiradi====*/
function hasChildItem(items) {
    if (is.undef(items) || items.length == 0) {
        return false;
    }
    return true;
}

var urlPath = [], fullUrl = [], searchs = [], pp = 0;

function appendURLPATH(l, menuType) {
    if (menuType == "iabs") {
        urlPath.push(tenString(l));
    }
}

/*=====menu chizib uni html ko'rinishida yasab beradi===*/
function drawItem(menu, id, search, menuType, pp) {
    var ul = "", vn = "", onAct = "", result = "", pin = "";
    var freeImg = "<img src='user/img/" + themeName + "/free.png' class='icon_free'/>";
    if (is.undef(menu)) {
        return;
    }
    var hasChildMenu = hasChildItem(menu.i);
    if (hasChildMenu) {
        h += 1;
        if (menu.i.length > 1) {
            appendURLPATH(menu.l, menuType);
            vn = "<img src='user/img/" + themeName + "/" + "svg/arrow_right.svg" + "' onclick='openClose(this," + h + ")'/>";
        } else if (menu.i.length == 1 && is.def(menu.i[0].i)) {
            appendURLPATH(menu.i[0].l, menuType);
            vn = "<img src='user/img/" + themeName + "/" + "svg/arrow_right.svg" + "' onclick='openClose(this," + h + ")'/>";
        } else {
            vn = freeImg;
        }
        if (id == 0) {
            h -= 1;
            ul = "<ul class='' is_open='Y'>";
        } else {
            if (menu.i.length > 1) {
                ul = "<ul class='nav' is_open='N' id='item" + h + "'>";
            } else if (menu.i.length == 1 && is.def(menu.i[0].i)) {
                ul = "<ul class='nav' is_open='N' id='item" + h + "'>";
            } else {
                ul = "<ul class='nav' is_open='Y' id='item" + h + "'>";
            }
        }
        if (menu.i.length > 1) {
            onAct = "onclick='openClose(this," + h + ")'";
        } else if (menu.i.length == 1 && is.def(menu.i[0].i)) {
            onAct = "onclick='openClose(this," + h + ")'";
            menu.l = menu.i[0].l;
            menu.i = menu.i[0].i;
        } else {
            onAct = ((menuType != "reports") ? "onclick='goUrl(" + menu.i[0].c + ")'" : "onclick='goRepUrl(" + menu.i[0].c + ")'");
            menu.l = menu.i[0].l;
            menu.c = menu.i[0].c;
            if (menuType != "reports") {
                pin = "<span " + ((ps.indexOf("~#" + menu.c + "~#") > -1 || menu.i[0].p == 1) ? "class='pinned'" : "class='unpinned'") + ((!is_turn_pin) ? " style='display:none'" : "") + " onclick='pinned(this," + menu.c + ")'></span>";
            }
        }
    } else {
        if (search) {
            if (menuType.indexOf("reports") > -1) {
                report_search.push({l: menu.l, c: menu.c});
            } else {
                if (menuType.indexOf("iabs") > -1) {
                    if (pp == 1) {
                        appendURLPATH(menu.l, menuType);
                        if (urlPath.join("/").indexOf("iABS") > -1) {
                            fullUrl[menu.c] = urlPath.join("/").substr(urlPath.join("/").indexOf("iABS") + 5, urlPath.join("/").length);
                        } else if (urlPath.join("/").indexOf("REPORTS") == -1) {
                            fullUrl[menu.c] = urlPath.join("/");
                        }
                        urlPath.pop();
                    }
                    searchs[menu.c] = '<i class=srch >(' + fullUrl[menu.c] + ')</i>';
                }
                for_search.push({l: menu.l, c: menu.c, p: menu.p});
            }
        }
        if (menuType === "reports") {
            onAct = "onclick='goRepUrl(" + menu.c + ")'";
        } else {
            onAct = "onclick='goUrl(" + menu.c + ")'";
        }
        if (menuType != "reports") {
            if (is.def(menu.p)) {
                pin = "<span " + ((ps.indexOf("~#" + menu.c + "~#") > -1 || menu.p == 1) ? "class='pinned'" : "class='unpinned'") + ((!is_turn_pin) ? " style='display:none'" : "") + " onclick='pinned(this," + menu.c + ")'></span>";
            } else {
                pin = "";
            }
        }
        if (menu.c == 220105) {
            showDOM("pie_button");
        }
    }
    if (id > 0) {
        result = "<li>" + vn + "<label class='txt'" + onAct + " onmouseleave=\"closebyTime(this)\" onmouseenter=\"openbyTime(this," + (is.def(menu.c) ? false : true) + "); changeClass(this,'txt1')\" onmouseout=\"changeClass(this,'txt')\" onmousemove=\"changeClass(this,'txt1')\">" + menu.l + "</label>" + pin + ul;
    }
    if (hasChildMenu) {
        for (var i = 0; i < menu.i.length; i++) {
            id += 1;
            result += drawItem(menu.i[i], id, search, menuType, 1);
            if (menuType == "iabs") {
                appendURLPATH(menu.l, menuType);
                if (i == menu.i.length - 1) {
                    urlPath.pop();
                }
            }
        }
        result += "</ul>";
    }
    result += "</li>";
    if (menuType === "iabs") {
        if (pp == 1) {
            urlPath.pop();
        } else {
            urlPath.length = 0;
        }
    }
    return result;
}

/*==================== textdan 10 tasini kesib oladi ================*/
function tenString(txt) {
    if (txt.length > 15) {
        return txt.substr(0, 15) + "...";
    }
    return txt;
}

function getMenuType() {
    var d = {};
    if (getDOM("reportsDiv").style.display == "none") {
        d = {
            "menuType": "iabs",
            "searchList": for_search,
            "parentMenu": "iABS",
            "htmlId": "tree",
            "allData": iabs,
            "searchHtmlId": "keyword_menu_close",
            "keywordSearch": "keyword_menu"
        };
    } else {
        d = {
            "menuType": "reports",
            "searchList": report_search,
            "parentMenu": "REPORTS",
            "htmlId": "reports",
            "allData": reports,
            "searchHtmlId": "keyword_report_close",
            "keywordSearch": "keyword_report"
        };
    }
    d["smart"] = {
        "is_smartY": "Умный поиск",
        "is_smartN": "Обычный поиск",
        "imgOnY": "smart-search3.svg",
        "imgOnN": "smart-search.svg",
        "classNameY": "turnPin active",
        "classNameN": "turnPin",
        "turnOn": getCookie(d.menuType + "_smart") == "Y"
    };
    return d;
}

/*==================== menudan search qilish ========================*/
var orgnSrchVal = "";

function search_menu(value, default_form) {
    var arr = [];
    var menu = getMenuType();
    if (value != "") {
        orgnSrchVal = value.toLowerCase();
        showDOM(menu.searchHtmlId);
        if (value.length > 1) {
            if (isCross() && fbws.isOpenWS()) {
                var data = {"listName": menu.menuType, "searchText": value};
                fbws.searchData(data, callBackSearchData, menu["smart"].turnOn);
            } else {
                arr = makeArrayForSearch(value, menu.searchList, menu.menuType);
                drawSearchData(arr);
            }
        }
    } else {
        orgnSrchVal = "";
        hideDOM(menu.searchHtmlId);
        if (default_form != "N") {
            getDOM(menu.htmlId).innerHTML = drawItem(menu.allData, 0, false, menu.menuType);
        }
    }
}

function callBackSearchData(d) {
    if (is.def(d["action"]) && d["action"] != "load") {
        if (d.code == 0) {
            var searchRes = new Array();
            for (var i = 0; i < d.responseBody.length; i++) {
                searchRes.push({
                    l: d.responseBody[i].formName,
                    c: d.responseBody[i].formCode
                });
            }
            drawSearchData(searchRes);
        }
    }
}

function drawSearchData(arr) {
    var menu = getMenuType();
    var newArr = arr;
    if (arr.length > 0) {
        for (i = 0; i < arr.length; i++) {
            if (menu.menuType == "iabs") {
                if (arr[i].l.indexOf("class=srch") < 0) {
                    newArr[i].l += searchs[arr[i].c];
                }
            }
        }
        getDOM(menu.htmlId).innerHTML = drawItem({l: menu.parentMenu, i: newArr}, 0, false, menu.menuType);
        moveCursorIabs(menu.htmlId);
    } else {
        getDOM(menu.htmlId).innerHTML = "";
    }
}

function input_close() {
    var menu = getMenuType();
    if (getDOM(menu.keywordSearch).value != "") {
        showDOM(menu.searchHtmlId);
    } else {
        hideDOM(menu.searchHtmlId);
    }
    search_menu(getDOM(menu.keywordSearch).value);
}

function clearValue(el) {
    getDOM(el).value = "";
    getDOM(el).focus();
}

function clearUrlArray() {
    urlPath.length = 0;
    fullUrl.length = 0;
    searchs.length = 0;
}

/*====== menuni search qilganda yonidan chiqgan x knopkasi uchun =========*/
function reset_search(is_open_menu) {
    var obj = ((getDOM("keyword_menu_content").style.display == "none") ? getDOM("keyword_report") : getDOM("keyword_menu"));
    if (is.undef(is_open_menu)) {
        if (obj.value == "") {
            closeNav(true);
        }
        posCursor = 0;
    }
    search_menu("");
    orgnSrchVal = "";
    setDOMValue(obj, "");
    obj.focus();
}

/*====== search uchun array yasab beradi ===================*/
function makeArrayForSearch(value, i_arr, menuType) {
    var arr = [];
    for (var i = 0; i < i_arr.length; i++) {
        var label = cyril_to_lat(i_arr[i].l).toLowerCase();
        if (label.indexOf(cyril_to_lat(value.toLowerCase())) > -1 || i_arr[i].l.toLowerCase().indexOf(orgnSrchVal) > -1) {
            arr.push(i_arr[i]);
        }
    }
    return arr;
}

/*======= replaceAll uchun =================================*/
String.prototype.replaceAll = function (search, replacement) {
    var target = this;
    return target.split(search).join(replacement);
};
/*======= trim methodi uchun =================================*/
String.prototype.trim = function () {
    return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
};

/*======= cursor tepaga i pastga tushadi down/up knokalari bosilganda ============*/
function moveCursorIabs(objText) {
    var key, ul, li, max = 0;
    key = (window.event) ? event.keyCode : e.keyCode;
    ul = getDOM(objText);
    li = ul.childNodes;
    for (var i = 0; i < li.length; i++) {
        if (ul.childNodes[i].nodeName == "LI") {
            max++;
        }
    }
    if (key == 40) { /**down arrow key*/
        if (posCursor >= max) {
            posCursor = max;
        }
        if (max == posCursor) {
            li[posCursor - 1].childNodes[0].className = "txt1";
            return;
        } else {
            li[posCursor].childNodes[0].className = "txt1";
            scrollToElement(li[posCursor].childNodes[0], true);
            ++posCursor;
        }
    }
    if (key == 38) { /**up arrow key*/
        if (posCursor > max) {
            posCursor = 0;
        }
        if (posCursor <= 1) {
            posCursor = 1;
            li[posCursor - 1].childNodes[0].className = "txt1";
            return;
        } else {
            --posCursor;
            li[posCursor - 1].childNodes[0].className = "txt1";
        }
        scrollToElement(li[posCursor - 1].childNodes[0], false);
    }
    if (key == 13) { /*** right or enter*/
        if (max > 0 && posCursor == 0) {
            li[posCursor].childNodes[0].click();
        } else {
            li[posCursor - 1].childNodes[0].click();
        }
    }
    if (key !== 40 && key !== 38) {
        posCursor = 0;
    }
}

/*========== elementni parent scrolli ichida ko'rsatish uchun ==========*/
function scrollToElement(el, p) {
    el.scrollIntoView(p);
    //el - scroll ichidagi element
    //p - true pastga, false yuqoriga nisbatan
}

/*================menu ochilganda qolganlarini yopvorish===================**/
function openClose(obj, v) {
    clearActive(goParent(obj, 1), "open");
    var item = goParent(obj, 1).childNodes[2];
    if (item.className == "") {
        item.className = "nav";
        item.setAttribute("is_open", "N");
        changeImg(obj, "arrow_right");
    } else {
        var par = goParent(obj, 2).childNodes;
        for (var i = 0; i < par.length; i++) {
            var ch = par[i].childNodes;
            for (var j = 0; j < ch.length; j++) {
                if (ch[j].getAttribute("is_open") == "Y") {
                    ch[j].className = "nav";
                    ch[j].setAttribute("is_open", "N");
                    changeImg(ch[j].parentNode.childNodes[1], "arrow_right");
                }
            }
        }
        var j = 0;
        for (var i = v + 1; i <= h; i++) {
            var dom = getDOM("item" + i);
            dom.className = "nav";
            dom.setAttribute("is_open", "N");
            changeImg(dom, "arrow_right");
            j++;
            if (j == 2) {
                break;
            }
        }
        item.className = "";
        item.setAttribute("is_open", "Y");
        changeImg(obj, "arrow_down");
        setActive(goParent(obj, 1), "open");
    }
    // console.log(window.event.clientY);
    // getDOM("tree").scrollTop = getDOM("tree").scrollTop-window.event.clientY;
}

function setActive(el, cls) {
    clearActive(el, cls);
    el.className += " " + cls;
}

function clearActive(el, cls) {
    var parent, childs, child;
    parent = goParent(el, 1);
    childs = parent.childNodes;
    for (var i = 0; i < childs.length; i++) {
        child = childs[i];
        if (child.className.indexOf(cls) != -1) {
            child.className = child.className.replace(cls, "");
        }
    }
}

/*============= mishkani cursori borganda birpas kutib keyin ochishi uchun ===================*/
var timeout;
var milliSecund = 900;
var k;

function openbyTime(o, s) {
    if (!Date.now) {
        Date.now = function now() {
            return new Date().getTime();
        };
    }
    if (s) {
        var t = Date.now();
        timeout = setTimeout(function () {
            if (t > 1000) {
                if (o.parentNode.childNodes[0].src) {
                    if (o.parentNode.childNodes[0].src.indexOf("close") > -1)
                        if (o.parentNode.childNodes[2]) {
                            if (o.parentNode.childNodes[2].className == "nav") {
                                o.fireEvent("onclick");
                            }
                        }
                }
            }
        }, milliSecund);
    } else {
        var t = Date.now();
        k = t;
        timeout = setTimeout(function () {
            if (k > 1000) {
                if (o.tagName == "BUTTON") {
                    var imgSrc = o.childNodes[0].src;
                    var imgName = imgSrc.substr(imgSrc.indexOf("img") + 4);
                    if (imgName.indexOf("list") > -1) {
                        openNav();
                    }
                    if (imgName.indexOf("recent") > -1) {
                        openRecent();
                    }
                    if (imgName.indexOf("report") > -1) {
                        openReport();
                    }
                    if (imgName.indexOf("favourite") > -1) {
                        openFavourite();
                    }
                }
            }
        }, milliSecund);
    }
}

function closebyTime(o) {
    clearTimeout(timeout);
}

/*=========showhide qilish ===*/
function hideElement() {
    for (var i = 0; i < arguments.length; i++) {
        hideDOM(arguments[i]);
    }
}

function showElement() {
    for (var i = 0; i < arguments.length; i++) {
        showDOM(arguments[i]);
    }
}

/*================ Barcha menularni ochiq bo'lsa yopadi =======================*/
function openAllMenuItem() {
    var obj = ((getDOM("iabsDiv").style.display == "inline") ? getDOM("iabsDiv") : (getDOM("reportsDiv").style.display == "inline") ? getDOM("reportsDiv") : document);
    var ul = obj.getElementsByTagName("ul");
    for (var i = 0; i < ul.length; i++) {
        if (ul[i].className == "nav" && ul[i].getAttribute("is_open") == "N") {
            ul[i].className = "";
            ul[i].setAttribute("is_open", "Y");
            changeImg(ul[i], 'arrow_down');
        }
    }
}

/*================ Barcha menularni ochib yuboradi =======================*/
function closeAllMenuItem() {
    var obj = ((getDOM("iabsDiv").style.display == "inline") ? getDOM("iabsDiv") : (getDOM("reportsDiv").style.display == "inline") ? getDOM("reportsDiv") : document);
    var ul = obj.getElementsByTagName("ul");
    for (var i = 0; i < ul.length; i++) {
        if (ul[i].className == "" && ul[i].getAttribute("is_open") == "Y") {
            ul[i].className = "nav";
            ul[i].setAttribute("is_open", "N");
            changeImg(ul[i], "arrow_right");
        }
    }
}

/**===================================start pin===================================================*/

/*==== pin bo'lganlarini chizish uchun ===*/
function createPin(d) {
    ps = "~#";
    if (d.length > 0) {
        getDOM("pinContent").innerHTML = drawPinTab(d);
        for (var i = 0; i < d.length; i++) {
            ps += d[i].c + "~#";
        }
    } else {
        getDOM("pinContent").innerHTML = "";
    }
}

/*=== smart search turn on and off  ===*/
function smartOnOff() {
    var menu = getMenuType();
    var turnOnSmart = getCookie(menu.menuType + "_smart");
    if (turnOnSmart == "Y") {
        setCookie(menu.menuType + "_smart", "N", 1000);
    } else {
        setCookie(menu.menuType + "_smart", "Y", 1000);
    }
    loadSmartOnOff();
}

function loadSmartOnOff() {
    var menu = getMenuType();
    let el = getDOM(menu.keywordSearch + "_smart");
    var datas = menu["smart"];
    var turnOnSmart = (getCookie(menu.menuType + "_smart") == "") ? "N" : getCookie(menu.menuType + "_smart");
    getDOM(menu.keywordSearch).placeholder = datas["is_smart" + turnOnSmart];
    el.className = datas["className" + turnOnSmart];
    el.childNodes[1].src = "/ibs/user/img/" + themeName + "/svg/" + datas["imgOn" + turnOnSmart];
}

/*==== pin qilish uchun ====*/
function turnOnPin(obj) {
    if (obj.getAttribute("open_pin") == "N") {
        obj.childNodes[1].src = "/ibs/user/img/" + themeName + "/svg/star3.svg";
        is_turn_pin = true;
        obj.setAttribute("open_pin", "Y");
        turnOnAllPin();
        obj.className = "turnPin active";
    } else {
        is_turn_pin = false;
        obj.childNodes[1].src = "/ibs/user/img/" + themeName + "/svg/star.svg";
        turnOnAllPin();
        obj.setAttribute("open_pin", "N");
        obj.className = "turnPin";
    }
}

/*====== Search polyasi yonidagi yulduzcha belgisi bosilganda ishlaydi ====*/
function turnOnAllPin() {
    var pn = document.getElementsByTagName("span");
    for (var i = 0; i < pn.length; i++) {
        if (pn[i].className == "pinned" || pn[i].className == "unpinned") {
            if (pn[i].style.display == "none" && is_turn_pin) {
                pn[i].style.display = "";
            } else if (pn[i].style.display == "" && !is_turn_pin) {
                pn[i].style.display = "none";
            }
        }
    }
}

/*====== pin qilish ====*/
function pinned(obj, value) {
    AJAX.load({
        POST: {
            request: "set_pin_menu",
            pinned: value
        }
    });
    obj.className = (obj.className == "pinned") ? "unpinned" : "pinned";
    getPin();
}

/*========= iconka boriligini tekshiradi ===============*/
function hasIcone(d) {
    return d != "";
}

/*=========pinned qilinganlarni chizish uchun===============*/
function drawPinTab(d) {
    var res = "", img, imgsrc;
    img = "document";
    for (var i = 0; i < d.length; i++) {
        imgsrc = "user/img/" + themeName + "/svg/" + ((hasIcone(d[i].icon)) ? d[i].icon : img) + ".svg";
        if (i % 6 == 0) {
            res += "<tr><td class='td-pn' onmouseover='hoverPin(this, 1)' onmouseout='hoverPin(this)' onclick='goUrl(" + d[i].c + ")' title='" + d[i].l + "'><p><img src=" + imgsrc + " class='pin-style'><p class='txt-pin'>" + d[i].l + "</p></p>";
        } else {
            res += "<td class='td-pn' onmouseover='hoverPin(this, 1)' onmouseout='hoverPin(this)' onclick='goUrl(" + d[i].c + ")' title='" + d[i].l + "'><p><img src=" + imgsrc + " class='pin-style'><p class='txt-pin'>" + d[i].l + "</p></p>";
        }
    }
    return "<table cellspacing='24' cellpadding='24' >" + res + "</table>";
}

/*===========pin hover=======*/
function hoverPin(par, isOver) {
    var img = par.getElementsByTagName("img")[0];
    if (!img || img.tagName != "IMG") return;
    if (isOver) {
        overSvg(img);
    } else {
        outSvg(img);
    }
}

/*===========pin qilingan podsistemalarni ochib berishi=======*/
function openFavourite(o) {
    closeNav();
    if (getDOM("pinContent").style.display == "none") {
        getDOM("pinContent").style.display = "";
        activMenu(o, true);
    } else {
        closeFav();
    }
}

/**===============end pin====================================================================*/
function toggle() {
    var width = 0;
    var id = setInterval(frame, 5);

    function frame() {
        if (width >= 450) {
            clearInterval(id);
        } else {
            width += 150;
            setNavWidth(width + "px");
        }
    }
}

/*=========== html tagidagi classlar almashuvi========*/
function changeClass(obj, name) {
    obj.className = name;
}

/*=========== html tagidagi class qo'shish========*/
function addClass(obj, cls) {
    if (obj.className.indexOf(cls) == -1) {
        obj.className += " " + cls;
    }
}

/*=========== html tagidagi class o'chirish========*/
function removeClass(obj, cls) {
    if (obj.className.indexOf(" " + cls) != -1) {
        obj.className = obj.className.replace(" " + cls, "");
    }
    if (obj.className.indexOf(cls) != -1) {
        obj.className = obj.className.replace(cls, "");
    }
}

/*=========== menudagi rasmlar almashuvi==============*/
function changeImg(obj, imgtext) {
    var img = goParent(obj).getElementsByTagName("img")[0];
    if (img.src) {
        if (img.src.indexOf("free") > -1) {
            img.src = "/ibs/user/img/" + themeName + "/free.png";
        } else {
            img.src = "/ibs/user/img/" + themeName + "/svg/" + imgtext + ".svg";
        }
    }

}

/*=========== Iabs menuni ochib berishi=======*/
function openNav(o) {
    hideElement("recentDiv", "reportsDiv", "keyword_report_content", "keyword_menu_close", "keyword_report_smart");
    showElement("iabsDiv", "searchForm", "keyword_menu_content", "turnPin", "content", "keyword_menu_smart");
    if (getDOM("keyword_menu").value != "") {
        reset_search("Y");
    }
    orgnSrchVal = "";
    var wd = getNavWidth();
    if (wd == "450") {
        closeNav(true);
    } else {
        openMenu("iabs");
        activMenu(o, true);
        getDOM("mySidenav").style.left = "0px";
        // getDOM("keyword_menu").focus();
    }
}

function openMenu(menuType) {
    if (menuType == "iabs") {
        setNavWidth("450");
        //getDOM("keyword_menu").focus();   // menu ochilib yopilganida active menu o'chib ketadi
        posCursor = 0;
        fr = 0;
        var h = new Date().getTime();
        if ((h - k) <= 500) {
            closebyTime(timeout);
        }
    }
    if (menuType == "recent") {
        setNavWidth("449");
        recent.i = urlPathForRecent(recent.i);
        getDOM("recent").innerHTML = drawItem(recent, 0, false, "recent");
        upDown("recent", fr);
        getDOM("for_copy").focus();
    }
    if (menuType == "report") {
        setNavWidth("451");
        if (getDOM("keyword_report").value != "") {
            getDOM("keyword_report").focus();
            posCursor = 0;
        }
    }
    if (getDOM("mySidenav").classList == "sidenav")
        setTimeout(function () {
            getDOM("mySidenav").classList = "sidenav open";
        }, 100);
}

function setNavWidth(width) {
    getDOM("mySidenav").style.width = size(width);
    getDOM("mySidenav").setAttribute("size", width);
}

function getNavWidth() {
    return getDOM("mySidenav").getAttribute("size");
}

/*========= menular contentini ochib yopish====*/
function closeNav(v) {
    var wd = getNavWidth();
    if (wd == "451" || wd == "450" || wd == "449") {
        setNavWidth("448");
        getDOM("mySidenav").style.left = size(-500);
        if (getDOM("mySidenav").classList == "sidenav open")
            setTimeout(function () {
                getDOM("mySidenav").classList = "sidenav";
            }, 100);
        activMenu(null, false);
    }
    hideDOM("content");
}

/*========= oxirgi kirilganlar ro'yhatini ochib berish====*/
function closeFav() {
    getDOM("pinContent").style.display = "none";
    activMenu(null, false);
}

/*======== oxirgi kirilgan podsistemalarni ochib berishi====*/
function openRecent(o) {
    hideElement("iabsDiv", "reportsDiv", "searchForm");
    showElement("recentDiv", "content");
    fr = 0;
    var wd = getNavWidth();
    if (wd == "449") {
        closeNav(true);
    } else {
        openMenu("recent");
        activMenu(o, true);
        getDOM("mySidenav").style.left = "0px";
    }
}

function upDown(objText, fr) {
    _.onkeydown = function (e) {
        var key, ul, li, max = 0;
        key = (window.event) ? event.keyCode : e.keyCode;
        up_down(e);
        ul = getDOM(objText);
        li = ul.childNodes;

        for (var i = 0; i < li.length; i++) {
            if (ul.childNodes[i].nodeName == "LI") {
                max++;
            }
        }

        if (key == 40) { /**down arrow key*/
            if (fr > max) {
                fr = 0;
            }
            if (max == fr) {
                li[fr - 1].childNodes[0].className = "txt1";
                return;
            } else {
                if (fr != 0)
                    li[fr - 1].childNodes[0].className = "txt";
                li[fr].childNodes[0].className = "txt1";
                getDOM(objText).scrollTop = getDOM(objText).scrollTop + fr;
                ++fr;
            }
        }
        if (key == 38) { /**up arrow key*/
            if (fr > max) {
                fr = 0;
            }
            if (fr <= 1) {
                fr = 1;
                li[fr - 1].childNodes[0].className = "txt1";
                return;
            } else {
                --fr;
                li[fr - 1].childNodes[0].className = "txt1";
                li[fr].childNodes[0].className = "txt";
            }
            getDOM(objText).scrollTop = getDOM(objText).scrollTop - 12;
        }
        if (key == 39 || key == 13) { /*** right or enter*/
            if (max > 0 && fr == 0) {
                li[fr].childNodes[0].click();
            } else {
                li[fr - 1].childNodes[0].click();
            }
        }
    };
}

/*======= otchyotlarni ochib berishi====*/
function openReport(o) {
    hideElement("recentDiv", "iabsDiv", "keyword_menu_content", "turnPin", "keyword_report_close", "keyword_menu_smart");
    showElement("reportsDiv", "searchForm", "keyword_report_content", "content", "keyword_report_smart");
    search_menu("", "N");
    var wd = getNavWidth();
    if (wd == "451") {
        closeNav(true);
    } else {
        openMenu("report");
        activMenu(o, true);
        getDOM("mySidenav").style.left = "0px";
        getDOM("keyword_report").focus();
    }
}

function goErrorHandler(c, url) {
    // if (c == "A") {
    //     go({
    //         url: url,
    //         target: contents,
    //         lock: false
    //     });
    //     return;
    // } else {
    //     go({
    //         url: "/errorHandler.jsp?support_browser=" + c,
    //         target: contents,
    //         lock: false
    //     });
    // }

    var u="";
    switch (c){
        case "A": u=url; break;
        case "L":u="/expiredLicense.jsp";break;
        default: u="/errorHandler.jsp?support_browser=" + c;
    }

    go({
        url:u,
        target:contents,
        lock:false
    })
}

/*=====pod sistemaga o'tish=====*/
function goUrl(formCode) {
    if (this.url) {
        return go({
            url: this.url,
            target: "modalE",
            dialogWidth: 1000,
            dialogHeight: 600,
            lock: false
        });
        if (is.def(preLoad) && is.func(preLoad)) {
            preLoad("l", false);
        }
    } else {
        AJAX.load({
            POST: {
                request: "loadForm",
                formCode: ((formCode) ? formCode : this.formCode)
            },
            onSuccess: function (d) {
                var url = d[0];
                var supportBr = d[2];/*A-All,C-cross,I-ie*/
                var formVersion = d[3] || "v0.0.0"; /*Forma versiyasi*/
                setCookie("parent_url", url);
                var sub_menu = eval('(' + d[1] + ')');
                fc = this.POST.formCode;
                if (is.def(recent.i)) {
                    for (var i = 0; i < for_search.length; i++) {
                        if (for_search[i].c == fc) {
                            fl = for_search[i].l;
                            break;
                        }
                    }
                    var v = [{l: fl, c: fc}];
                    for (var i = 0; i < recent.i.length && v.length <= 20; i++) {
                        if (recent.i[i].c != fc)
                            v.push(recent.i[i]);
                    }
                    recent.i = v;
                    getDOM("recent").innerHTML = drawItem(recent, 0, false, "recent");
                } else {
                    var v = [{label: hm[fc], formCode: fc, action: goUrl}];
                    fl = hm[fc].substr(0, hm[fc].indexOf("<font"));
                    for (var i = 0; i < mn[1].items.length && v.length <= 20; i++) {
                        if (mn[1].items[i].formCode != fc)
                            v.push(mn[1].items[i]);
                    }
                    mn[1].items = v;
                }
                fl = fl.substring(0, (fl.indexOf("<br/>") > -1) ? fl.indexOf("<br/>") : fl.length);
                if (fl.indexOf("class=srch") > -1) {
                    fl = fl.substring(0, fl.indexOf("class=srch") - 3);
                }
                formTitle.innerHTML = fl.substring(0, 38) + " (" + formVersion + ")";
                getDOM("formcode").innerHTML = fc;
                getDOM("formcode").style.display = "inline";
                formTitle.title = fc + " - " + fl;
                // go({url: url,target: contents,lock: false});
                goErrorHandler(supportBr, url);
                // initSubMenu(sub_menu);
                if (is.def(preLoad) && is.func(preLoad)) {
                    preLoad("l", false);
                }
            }
        });
    }
    closeNav();
    closeFav();
}

function initSubMenu(mn) {
    // setTimeout(function () {
    // var subObj = window._.contents;
    // if (mn.items.length > 0 && subObj.tabControls) {
    // subObj.drawTab(mn.items);
    // }
    // }, 1000);
}

/*===yulduzcha oxirgi marta kirilgan podsistemalarni ko'rsatish=====*/
function goFavorite() {
    if (is.def(recent.i) && recent.i.length > 0) {
        goUrl(recent.i[0].c);
    } else if (rm.length > 0) {
        goUrl(rm[0]);
    } else {
        go({
            url: "user/info.jsp",
            target: contents,
            lock: false
        });
        preLoad("l", false);
    }
}

function constructUrl(originalText) {
    var baseUrlMatch = originalText.match(/^(.*?\?)/);
    var baseUrl = baseUrlMatch ? baseUrlMatch[1] : "";
    var paramsRegex = /([\w\-]+)=([^&]*)/g;
    var match;
    var params = {};
    while ((match = paramsRegex.exec(originalText)) !== null) {
        var key = match[1];
        var value = match[2];
        params[key] = value;
    }
    if (params["rep_id"]) {
        params["rep_id"] = encodeURIComponent(params["rep_id"]);
    }
    if (params["repProc"]) {
        params["repProc"] = encodeURIComponent(params["repProc"]);
    }
    var newUrl =
        baseUrl +
        (function () {
            var queryString = [];
            for (var key in params) {
                if (params.hasOwnProperty(key)) {
                    queryString.push(key + "=" + params[key]);
                }
            }
            return queryString.join("&");
        })();

    return newUrl;
}

/*==================reportlarni ochib  berish==========*/
function goRepUrl(fc) {
    AJAX.load({
        POST: {
            request: "getReportUrl",
            formCode: fc
        },
        onSuccess: function (d) {
            d = constructUrl(d);
            go({
                url: (d.indexOf("&repTitle=") > 0) ? d.substr(0, d.indexOf("&repTitle=")) : d,
                param: {
                    repTitle: (d.indexOf("&repTitle=") > 0) ? d.substr(d.indexOf("&repTitle=") + 10) : ''
                },
                target: contents,
                lock: false
            });
            closeNav();
        }
    });
}

/*=====instruksiyani ochib berishi ========*/
function goHelp(o) {
    activMenu(o, true);
    AJAX.load({
        POST: {
            request: "get_help_url",
            formCode: fc
        },
        onSuccess: function (d) {
            var url = d.toString().trim();
            if (url != "NOT_HELP_URL") {
                go({url: url, target: "new", lock: false});
            } else {
                alert(si_not_help_url);
            }
            activMenu(null, false);
        }
    });
}

/*==== iabs 6.0.0 dagi global searchga o'tish uchun =======*/
function goSearch() {
    go({url: this.url, target: contents, lock: false});
}

/*===== chatni ochib berish uchun =========================*/
function goChat(o) {
    closeNav();
    activMenu(o, true);
    go({
        url: "user/chat_messages.jsp",
        target: "modalE",
        dialogWidth: 1000,
        lock: false,
        callback: activMenu
    });
}

/*====================================*/
function goInfo(o) {
    closeNav();
    activMenu(o, true);
    //go({url:'/ibs/user/info.jsp', target:"modal", dialogWidth: window.screen.availWidth-100, dialogHeight: window.screen.availHeight-200, lock:false, callback: activMenu });
    go({
        url: '/ibs/user/info/classic/info_for_cross.jsp',
        target: "modal",
        dialogWidth: window.screen.availWidth - 100,
        dialogHeight: window.screen.availHeight - 200,
        lock: false,
        callback: activMenu
    });
}

function goSetting(o) {
    closeNav();
    closeFav();
    activMenu(o, true);
    go({url: 'user/util/profile/settings.jsp', target: contents, lock: false});
}

function goFeedback(o) {
    closeNav();
    activMenu(o, true);
    go({
        url: "/ibs/fbsd/lists/list/issue/issue.jsp",
        target: "modal",
        dialogWidth: 600,
        dialogHeight: 480,
        lock: false,
        callback: activMenu
    });
}

function goSD(o) {
    activMenu(o, true);
    go({url: 'fbsd/main.jsp', target: contents, dialogFill: true, lock: false});
}

function goBI(o) {
    activMenu(o, true);
    go({
        url: 'bi/oi/view.jsp',
        target: 'modal',
        dialogFill: true,
        lock: false,
        cmsHelperTiltle: '',
        callback: activMenu
    });
}

function goElib(o) {
    activMenu(o, true);
    go({
        url: 'elib/docs.jsp',
        target: 'modal',
        dialogFill: true,
        lock: false,
        cmsHelperTiltle: '',
        callback: activMenu
    });
}

function activMenu(actObj, isOpen) {
    var btns = getDOM("side_bar_menu").getElementsByTagName("button");
    var activeClass = "side-bar-btn active";
    var mainClass = "side-bar-btn";
    for (var i = 0; i < btns.length; i++) {
        btns[i].className = mainClass;
        changeActImg(btns[i], false);
    }
    if (actObj) {
        actObj.className = activeClass;
        changeActImg(actObj, true);
    }
}

function changeActImg(obj, isActive) {
    var imgObj = obj.getElementsByTagName("img")[0];
    var fullImg = imgObj.src;
    var root = fullImg.substr(0, fullImg.lastIndexOf("/") + 1);
    var img = fullImg.substr(fullImg.lastIndexOf("/") + 1, fullImg.length);
    var type = img.substr(img.lastIndexOf("."), img.length);
    var imgName = img.substr(0, img.lastIndexOf("."));
    var orgName = "";
    if (imgName.lastIndexOf("2") > -1) {
        orgName = imgName.substr(0, imgName.lastIndexOf("2"));
    } else if (imgName.lastIndexOf("3") > -1) {
        orgName = imgName.substr(0, imgName.lastIndexOf("3"));
    } else {
        orgName = imgName;
    }
    if (isActive) {
        imgObj.src = root + orgName + "3" + type;
    } else {
        imgObj.src = root + orgName + type;
    }
}

/*=======logout qilish=====*/
function logout() {
    closeNav();
    if (confirm(si_ask))
        outPage();
}

/**=======logout qilinganda sessiyani yopadi====*/
function outPage() {
    AJAX.load({url: "logoff.jsp"});
}

/**=======================================start header============================================================================*/
/*=====sistemadagi soatni ko'rsatib turishi uchun=======*/
var getDigitalDate = function () {
    var obj = this;
    var d;
    this.setDigitDate = function (d) {
        obj.d = d;
    };
    this.getDigitDate = function () {
        return obj.d;
    };
};
var dateD = new getDigitalDate();

function digitalWatch() {
    var date = new Date(new Date().getTime() + sysdate);
    if (sysdate < 0) {
        date = new Date(new Date().getTime() - Math.abs(sysdate));
    }
    dateD.setDigitDate(date);
    /*if(is.def(getDOM("ETP"))) {
		getDOM("ETP").innerHTML = '<p style="vertical-align:bottom; display:block" title="' + si_sysdate + '"><span>' + si_time + ':</span> <span style="text-align:right"><b>' + date.format("d.m.Y") + '</b></span>' + '<span style="text-align:right"><b>' + date.format("H:i:s") + '</b></span>' + '</p>';
	}*/
    // getDOM("mEndTime").innerHTML = _mEndTime;
    _mTimeout = setTimeout("digitalWatch()", 1000);
}

/*=====userga kelgan messagelarni yashirish ==========*/
function hideUserMessage() {
    getDOM("showhide").style.display = "none";
    getDOM("showhide").innerHTML = "";
}

/*=====userga kelgan messagelarni ko'rish ==========*/
function showUserMessage(w, h, src) {
    w = parseInt((w == "fill") ? _.body.clientWidth - 10 : (w) ? w : "800");
    h = parseInt((h == "fill") ? _.body.clientHeight - 10 : (h) ? h : "250");
    src = ((src) ? src : "show_message.jsp");
    var cW = Math.ceil(((_.body.clientWidth - w) / 2) > 0 ? ((_.body.clientWidth - w) / 2) : 0);
    var cH = Math.ceil(((_.body.clientHeight - h) / 2) > 0 ? ((_.body.clientHeight - h) / 2) : 0);
    getDOM("showhide").innerHTML = "";
    getDOM("showhide").style.display = "inline";
    ifrm = document.createElement("iframe");
    ifrm.src = src;
    ifrm.style.width = w + "px";
    ifrm.style.height = h + "px";
    ifrm.style.marginLeft = cW + "px";
    ifrm.style.marginRight = cW + "px";
    ifrm.className = "show_message";
    img = document.createElement("img");
    img.src = "user/img/" + themeName + "/close_over.png";
    img.addEventListener('click', hideUserMessage);
    img.onmouseover = this.src = "user/img/" + themeName + "/close_out.png";
    img.onmouseout = this.src = "user/img/" + themeName + "/close_over.png";
    img.style.position = "absolute";
    img.style.zIndex = "1";
    img.style.top = (cH + 5) + "px";
    img.style.right = (cW + 5) + "px";
    img.title = si_hide;
    getDOM("showhide").appendChild(ifrm);
    ifrm.focus();
    var pos = 10,
        i = 0,
        id = setInterval(frame, 10);

    function frame() {
        if (pos >= cH && i == 0) {
            i = 1;
        } else if (i == 1 && pos <= (cH - 50)) {
            i = 2;
        } else if (pos >= cH && i == 2) {
            clearInterval(id);
            getDOM("showhide").appendChild(img);
        } else {
            if (i == 0 || i == 2) {
                pos += 10;
            } else {
                pos -= 10;
            }
            ifrm.style.top = pos + 'px';
        }
    }
}

/** HTML Entities */
function htmlEntities(str) {
    return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

/** Show High Messages */
function showHighMessages(d) {
    const employeeCode = top.user_code;
    let json = d.split("~")[2];
    json = json ? JSON.parse(json).messages[employeeCode] : null;
    if (!json || Object.keys(json).length === 0) return;
    let timer = setInterval(function () {
        hideFirstToast();
    }, 10 * 1000);

    function hideFirstToast() {
        const t = document.querySelectorAll(".beautyToast-wrapper .beautyToast");
        if (t && t.length >= 5) {
            const id = t[0].getAttribute("toast-id");
            if (id) closeToast(id, function () {
            });
        } else {
            addToast();
        }
    }

    function addToast() {
        if (Object.keys(json).length === 0) {
            clearInterval(timer);
        } else {
            const messageId = Object.keys(json)[0];
            const messageText = htmlEntities(json[messageId][0]);
            let messageType = json[messageId][1];

            if (!readedMessages.includes(messageId)) {
                switch (messageType) {
                    case "S":
                        messageType = "success";
                        break;
                    case "I":
                        messageType = "info";
                        break;
                    case "W":
                        messageType = "warning";
                        break;
                    case "E":
                        messageType = "error";
                        break;
                }
                const detailBtn = '<button class="detailBtn" message-id="' + messageId + '" onclick="showMessageDetail(this)">&#x41F;&#x43E;&#x434;&#x440;&#x43E;&#x431;&#x43D;&#x44B;&#x439;</button>';
                beautyToast[messageType]({
                    message: messageText + detailBtn,
                    timeout: 0,
                    animationTime: 150,
                    closeColor: "#68D84C",
                    darkTheme: (themeName === 'dark'),
                    onClose: function () {
                    },
                    onOpen: function () {
                    }
                });
                readedMessages.push(messageId);
            }
            delete json[messageId];
        }
    }
}

/** Remove Message */
function removeMessage(o) {
    hideMessage(o);
    deleteMessage(o);
}

/** Hide Message */
function hideMessage(o) {
    const p = o.closest(".beautyToast ");
    const toastId = p.getAttribute("toast-id");
    if (toastId) closeToast(toastId, function () {
    });
}

/** Delete Message */
function deleteMessage(o) {
    const p = o.closest(".beautyToast ");
    const messageId = p.querySelector(".detailBtn").getAttribute("message-id");
    AJAX.load({
        POST: {
            request: "delete_message",
            messageId: messageId
        },
        onSuccess: function (d) {
            //alert("Message deleted!");
        },
        onError: function (d) {
            alert(d);
        }
    });
}

/** Show Message Detail */
function showMessageDetail(o) {
    const messageId = o.getAttribute("message-id");
    hideMessage(o);
    go({
        url: "/ibs/user/util/toast/detail.jsp?messageId=" + messageId,
        target: "modalE",
        dialogWidth: size(620),
        dialogHeight: size(420),
        callback: function () {
            deleteMessage(o);
        }
    });
}

/*=====kelgan messagelarni ko'rsatib turish=================*/
function notifyMsg(d) {
    console.log(d);
    if (d[0] != "") {
        if (isFutureDate(isFutureOperDay)) {
            setDS(operday, d[0], "Y");
        } else {
            setDS(operday, d[0]);
        }
    }
    if (d[1] != "") {
        jsonHash.setNotifyMsg(d[1]);
        setTimeout(openTime, 1000);
        if ("H" == d[1].substring(0, 1)) {
            _mEndTime = d[1].substring(1);
        } else {
            _mEndTime = d[1];
        }

        let count = d[1].split("~");
        jsonHash.setMsg_cnt(count[count.length - 1]);

        try {
            showHighMessages(d[1]);
        } catch (error) {
        }
    }
    if (d.length > 2) {
        if (d[2] != "" && _mID != d[2]) {
            _mID = d[2];
        }
        /* if ("H" == d[1].substring(0, 1)) {
			if (d[2] != "" && is.def(d[3])) {
				goChat();
			}
		} */
        /* if (is.def(d[3]) && d[3].length > 0) {
			getDOM("msg").innerHTML = '<marquee class="msg_marquee" SCROLLAMOUNT=2 SCROLLDELAY=20 onclick="goChat();">' + d[3];
		} else {
			getDOM("msg").innerHTML = "";
		} */
    }
    /* if(is.def(_mTimeout)) clearTimeout(_mTimeout);
	digitalWatch(); */
}

/*===============fbsd notify messages count=====================*/
function fbsdMsg(count) {
    if (is.def(count) && (count > 0)) {
        showDOM("notify_count");
        getDOM("notify_count").innerHTML = "<h3>" + ((count > 9) ? "9+" : count) + "</h3>";
        getDOM("notify_count").setAttribute("title", count);
    } else {
        hideDOM("notify_count");
    }
}

/*===============virtual userga o'tish=====================*/
function chose_one(v) {
    var par = getDOM("msg");
    var el = getDOM("user_sel");
    if (!el) return false;
    if (!v) {
        par.className = "";
        hideDOM(el);
    } else {
        if (!event.target.closest("#user_sel")) {
            if (el.style.display != "none") {
                chose_one(false);
            } else {
                par.className = "isOpen";
                hidePopups();
                showDOM(el);
                showDOM("content");
            }
        }
    }
    event.preventDefault();
    event.stopPropagation();
}

/*============Search in user list================*/
function searchUser(val) {
    let labels = _.querySelectorAll("#user_sel div > label");
    let l, text, count = 0, s = 0, e = 0;
    for (let i = 0; i < labels.length; i++) {
        l = labels[i];
        text = (l.innerText || l.textContent);
        s = text.indexOf(val);
        if (s > -1) {
            e = s + val.length;
            l.innerHTML = text.slice(0, s) + "<b>" + val + "</b>" + text.slice(e, text.length);
            l.parentNode.style.display = "block";
            count++;
        } else {
            l.parentNode.style.display = "none";
        }
    }
    let empty = _.querySelector("#user_sel .noUsers");
    empty.style.display = (count > 0) ? "none" : "block";
}

/*============Hide all popup blocks==============*/
function hidePopups() {
    hideDOM("list_operdays");
    getDOM("oper_den_img").className = "";
    hideDOM("opentime");
    hideDOM("rightmenu");
    getDOM("trm_ico").className = "";
    getDOM("trm_ico_img").src = "/ibs/user/img/" + themeName + "/svg/currency.svg";
}

/***==========Tilni o'zgartirish========***/
function changeLangImg(val) {
    return;
    hideDOM(obj + "_sel");
    switch (val) {
        case 1:
            getDOM("lang").innerHTML = "<a><img src='user/img/" + themeName + "/lang_rus.png'></a>";
            break;
        case 2:
            getDOM("lang").innerHTML = "<a><img src='user/img/" + themeName + "/lang_uzc.png'></a>";
            break;
        case 3:
            getDOM("lang").innerHTML = "<a><img src='user/img/" + themeName + "/lang_uzl.png'></a>";
            break;
        case 4:
            getDOM("lang").innerHTML = "<a><img src='user/img/" + themeName + "/lang_eng.png'></a>";
            break;
    }
    getDOM(val).style.border = "1px solid dodgerblue";
}

/*=========tilni o'zgartirish===========*/
function changeLanguage(val) {
    // chose_one("lang_sel");
    changeLangImg(val);
    AJAX.load({
        POST: {
            request: "change_language",
            nls_index: val
        },
        onSuccess: function (d) {
            alert(replaceQGH(si_succ_and_next));
        },
        onError: function (d) {
            alert(d);
        }
    });
}

/*=========operdenni o'zgartirish========*/
function setOperDay(v, s) {
    ajax.load({
        POST: {
            request: 'set_oper_day',
            new_operden: v
        },
        onSuccess: function (d) {
            isFutureOperDay = d.toString();
            operday = v;
            alert(si_changeOperday + " " + operday + "!");
            if (isFutureDate(d)) {
                setDS(operday, s, "Y");
                getDOM("TXTOPDAY").className = "run24x7";
                getDOM("hasopday").src = "/ibs/user/img/" + themeName + "/svg/24x7-active.svg";
            } else {
                setDS(operday, s);
                getDOM("TXTOPDAY").removeAttribute("class");
                getDOM("hasopday").src = "/ibs/user/img/" + themeName + "/svg/24x7.svg";
            }
            var fmCode = getDOMValue("formcode");
            goUrl(fmCode);
        }
    });
}

function execFutureDate() {
    if (isFutureDate(isFutureOperDay)) {
        getDOM("TXTOPDAY").className = "run24x7";
        getDOM("hasopday").src = "/ibs/user/img/" + themeName + "/svg/24x7-active.svg";
    } else {
        getDOM("TXTOPDAY").removeAttribute("class");
        getDOM("hasopday").src = "/ibs/user/img/" + themeName + "/svg/24x7.svg";
    }
}

/*==operdenlar ro'yhatini olib keladi==**/
function getOperDays() {
    if (allowed24x7 == "N") {
        getDOM("TXTOPDAY").className = "disable24x7";
        getDOM("hasopday").removeAttribute("onclick");
        hideDOM("list_operdays");
        getDOM("oper_den_img").className = "";
        getDOM("hasopday").src = "/ibs/user/img/" + themeName + "/svg/24x7-disable.svg";
    } else if (allowed24x7 == "Y") {
        showDOM("hasopday");
        ajax.load({POST: {request: 'get_oper_days'}});
        setTimeout(function () {
            execFutureDate();
        }, 700);
    }
}

/*=========operdenni tanlash=======*/
function selectOperDen(obj) {
    var operden = obj.childNodes[1].innerHTML;
    var state = (si_open == getDOMValue(obj.childNodes[2])) ? "O" : (getDOMValue(obj.childNodes[2]) == si_close) ? "C" : "O";
    setOperDay(operden, state);
    changeOperDen();
    changeCheckedImg(obj);
}

/*===operdenlar ro'yhatini olib kelish==*/
var hasAllowNewOperden = false;

function createOperDen(d) {
    hasAllowNewOperden = allowNewDate(d);
    if (hasAllowNewOperden) {
        let el = _.getElementsByClassName("oper_den_block")[0];
        if (el) el.className = "oper_den_block allowNewDate";
    }
    getDOM("list_operdays").innerHTML = "<table style='border-collapse: collapse; width:100%' cellpadding=3>" + d + "</table>";
    hideDOM(getDOM("list_operdays"));
    initDOM(getDOM("list_operdays"));
    var trs = getDOM("list_operdays").getElementsByTagName("tr");
    for (var i = 0; i < trs.length; i++) {
        trs[i].onmousemove = function () {
            changeClass(this, 'hoverOperdays');
        };
        trs[i].onmouseout = function () {
            changeClass(this, '');
        };
        trs[i].onclick = function () {
            selectOperDen(this);
        };
        if (trs[i].childNodes) {
            var d = trs[i].childNodes[1].innerText;
            var s = trs[i].childNodes[2].innerText;
            if (s === "C") {
                trs[i].childNodes[2].style.color = "var(--color-red)";
                trs[i].childNodes[2].innerText = si_close;
            } else {
                trs[i].childNodes[2].style.color = "var(--color-green)";
                trs[i].childNodes[2].innerText = si_open;
            }
            if (d == currday) {
                trs[i].style.fontWeight = "bolder";
            }
        }
    }
}

function allowNewDate(d) {
    var tr_s = d.split("<tr>");
    tr_s.shift();
    return tr_s.length > 1;
}

function IsEmptyOrWhiteSpace(str) {
    return (str.match(/^\s*$/) || []).length > 0;
}

/*===kirgan userga 24x7 rejimida ishlashiga ruxsat bor yoki yo'q ekanligini tekshirish===*/
function changeOperDen() {
    if (allowed24x7 == "Y") {
        if (getDOM("list_operdays").style.display == "none" && hasAllowNewOperden) {
            showDOM("list_operdays");
            getDOM("oper_den_img").className = "setCaret";
            showDOM("content");
        } else {
            hideDOM("list_operdays");
            getDOM("oper_den_img").className = "";
        }
    }
}

/*========= 24x7 uchun datalar ro'yhatini tanlash uchun ======*/
function changeCheckedImg(obj) {
    var imgs = getDOM("list_operdays").getElementsByTagName("img");
    var trs = getDOM("list_operdays").getElementsByTagName("tr");
    for (var i = 0; i < imgs.length; i++) {
        imgs[i].src = "user/img/" + themeName + "/svg/unchecked.svg";
        trs[i].style.fontWeight = "normal";
    }
    obj.childNodes[0].childNodes[0].src = "user/img/" + themeName + "/svg/checked.svg";
    obj.style.fontWeight = "bolder";
}

/*------*/
function isFutureDate(operden) {
    var patt = new RegExp("Y");
    var res = patt.test(operden);
    return res;
}

/*===vaqtni va rangini o'zgartirish*/
function setDS(d, s, c) {
    var span, o_c;
    span = "<span id=new_op_den onclick=\"toggleBankTime()\" >";
    if (is.def(c)) {
        span = "<span id=new_op_den onclick=\"toggleBankTime()\">";
    }
    o_c = (s == "O" ? si_open : s == "C" ? si_close : si_open);
    if (s == "O") {
        o_c = "<code style=\"color:var(--color-green);\">" + si_open + "</code>";
    } else if (s == "C") {
        o_c = "<code style=\"color:var(--color-red);\">" + si_close + "</code>";
    }
    getDOM("DS").innerHTML = span + d + " " + o_c + "</span>";
    initDOM(getDOM("DS"));
}

function unpDayLst(l) {
    var t = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ", r = "", d, m, y, c, i = 0;
    while (i < l.length) {
        c = l.charAt(i);
        if (c == "y") {
            y = l.substr(i + 1, 4);
            i += 4;
            c = "m";
        }
        if (c == "m") {
            m = "" + t.indexOf(l.charAt(i + 1));
            i += 2;
            c = l.charAt(i);
        }
        d = "" + t.indexOf(c);
        if (d.length < 2)
            d = "0" + d;
        if (m.length < 2)
            m = "0" + m;
        r += '<option>' + d + '.' + m + '.' + y;
        i++;
    }
    return r;
}

function sOT(t) {
    ibs_banner.oText.innerText = t
}

function setBannerText(level, nLab) {
    b = ibs_banner;
    switch (level) {
        case 0: { //подсветить тексть 'Выбор подсистемы.'
            if (isLoaded)
                sOT("Выберите подсистему.");
            break
        }
        case 1: { //Запомнить выбранную подсистему в subSystemLabel
            b.subSystemLabel = "Подсистема: \"" + nLab + "\"";
            break
        }
        case 2: { //Подсветить выбранную подсистему из subSystemLabel
            sOT(b.subSystemLabel);
            break
        }
        case 3: { //Запомнить выбранную задачу в taskLabel
            b.taskLabel = "Задача: \"" + nLab + "\"";
            break
        }
        case 4: { //Подсветить выбранную задачу
            sOT(b.taskLabel);
            break
        }
        case 5: { //Подсветить выбранную форму (запоминать не надо)
            sOT("\"" + nLab + "\"");
            break
        }
    }
}

sBT = setBannerText

// Установить свет фона
function setBg(m, c) {
    m.style.backgroundColor = c;
    m.parentElement.bgColor = c
}

// Выбор элемента Меню
function mSel(i) {
    c = menu[mI];
    t = menu[i];
    setBg(c, t.style.backgroundColor);
    setBg(t, "#B070EB");
    mI = i;
    t.focus()
}

function noMenu() {
    return false;
}

// Сделать заданную Меню текущим
function setMenu(m, e) {
    esc = e;
    if (m != null) {
        if (m.length > 0)
            menu = m;
        else
            menu = [m];
        mI = 0;
        mSel(0);
        for (i = 0; i < m.length; i++) {
            p = m[i].parentElement;
            p.style.cursor = "hand";
            p.onclick = m[i].click;
            m[i].onfocus = new Function("if(mI!=" + i + ")mSel(" + i + ")");
            p.onfocus = m[i].onfocus;
            m[i].oncontextmenu = noMenu;
            p.oncontextmenu = noMenu;
        }
    }
}

function execCopy(obj) {
    setDOMValue("for_copy", obj.innerHTML);
    getDOM("for_copy").select();
    _.execCommand("copy");
};

function menuKey(e) {
    try {
        var event = e || window.event;
        if (menu && menu.length) {
            var k = event.keyCode || event.charCode;
            if (k == 9)
                e.keyCode = 0;
            if (k == 27 && esc != null)
                esc.click();
            if (k == 37)
                mSel(0);
            if (k == 38 && mI > 0)
                mSel(mI - 1);
            if (k == 39)
                mSel(menu.length - 1);
            if (k == 40 && mI < menu.length - 1)
                mSel(mI + 1)
        }
    } catch (e) {
    }
}

/**==================================end header===============================================================*/
/***=====function for global=====*/

/*====================== increment uchun ======================*/
function toggleInc(min, max, forFrame, interval) {
    var width = min;
    var forFrame = (is.def(forFrame) ? forFrame : 5);
    var interval = (is.def(interval) ? interval : 10);
    var id = setInterval(frame, forFrame);

    function frame() {
        if (width >= max) {
            clearInterval(id);
        } else {
            width += interval;
            setNavWidth(width + "px");
        }
    }
}

/*===================== decriment uchun ================================================*/
function toggleDec(max, min, forFrame, interval) {
    var width = max;
    var forFrame = (is.def(forFrame) ? forFrame : 5);
    var interval = (is.def(interval) ? interval : 10);
    var id = setInterval(frame, forFrame);

    function frame() {
        if (width <= min) {
            clearInterval(id);
        } else {
            width -= interval;
            setNavWidth(width + "px");
        }
    }
}

/*------bpm oynasini ochib berishi uchun------*/
function goBPM() {
    go({
        url: 'bpm/bpms.jsp',
        target: contents,
        cmsHelperTiltle: 'Panel',
        lock: false,
        arg: "channelmode=1,directories=1,location=0,menubar=0,toolbar=0,resizable=1,scrollbars=1,status=0,titlebar=1"
    });
}

//---------------------------------------
function goCalendar() {
    go({
        url: 'calendar/calendar.jsp?is_main=N',
        target: "new",
        cmsHelperTiltle: 'Panel',
        lock: false,
        arg: "channelmode=1,directories=0,location=0,menubar=1,toolbar=0,resizable=1,scrollbars=1,status=1"
    });
}

//Кадр модулидан тугилган кунларни тортамиз
function goHR_Happy() {
    if (num_of_logins == "1") {
        go({
            url: "/ibs/ia/hr/happi.jsp",
            target: 'modalE',
            dialogWidth: screen.width - 100,
            dialogHeight: '370'
        });
    }
}

function createIabsInfo(d) {
    jsonHash.setJson(d);
}

function pageLoad() {
    //
}

function rightMenu(ev) {
    let par = getDOM("trm_ico");
    let rmenu = getDOM("rightmenu");
    let img = getDOM("trm_ico_img");
    if (ev) {
        rightMenuDraw();
        if (rmenu.style.display == "block") {
            rmenu.style.display = "none";
            par.className = "";
            img.src = "/ibs/user/img/" + themeName + "/svg/currency.svg";
        } else {
            rmenu.style.display = "block";
            par.className = "isOpen";
            img.src = "/ibs/user/img/" + themeName + "/svg/currency_active.svg";
        }
        showDOM("content");
    } else {
        rmenu.style.display = "none";
        par.className = "";
        img.src = "/ibs/user/img/" + themeName + "/svg/currency.svg";
    }
    if (is.def(_mTimeout)) clearTimeout(_mTimeout);
    digitalWatch();
}

function rightMenuDraw() {
    let d, code, el, info, oper_day, week_day, currencies, min_zp;
    d = jsonHash.getJson();
    el = getDOM("rightmenu");
    info = d.info;
    oper_day = info.oper_day;
    week_day = info.week_day;
    currencies = info.currencies;
    min_zp = info.min_zp;
    code = "<div class='valyuta'><p>" + si_currencies + "</p><p><b>" + week_day + ", " + oper_day + "</b></p></div>" + "<div class='valyuta_list'>";
    for (let i = 0; i < currencies.length; i++) {
        code += "<p title='" + currencies[i].title + "'><span><b>1 " + currencies[i].symbol + "</b></span> <span ondblclick='execCopy(this);'>" + currencies[i].equival + "</span> <span style='color:var(--color-" + currencies[i].diff_color + ");text-align:right;'> " + currencies[i].difference + "</span></p>";
    }
    code += "</div>";
    code += "<div class='ekix'><p>" + si_min_zp_title + "</p><p><b>" + min_zp.money + "</b><b style='text-align:right;'>" + min_zp.date + "</b></p></div>";
    code += "<div id='ETP'></div>";
    el.innerHTML = code;
}

function toggleBankTime() {
    let el = getDOM("opentime");
    if (el.style.display == "none") {
        showDOM(el);
        showDOM("content");
    } else {
        hideDOM(el);
    }
}

function changeTheme(theme_id, theme_curr) {
    let id, theme;
    if (theme_id == 1 && theme_curr == 2) {
        id = 2;
        theme = "theme_DARK";
    } else if (theme_id == 2 && theme_curr == 1) {
        id = 1;
        theme = "theme_LIGHT";
    } else {
        return false;
    }
    AJAX.load({
        POST: {
            request: "set_theme",
            theme_id: id,
            theme_url: theme
        },
        onSuccess: function (d) {
            if (d) {
                top._t().go({});
            }
        },
        onError: function (d) {
            alert(d);
        }
    });
}

function openTime(d) {
    var oper_day, week_day, transfer, code = "";
    var d = jsonHash.getJson();
    oper_day = d.info.oper_day;
    week_day = d.info.week_day;
    transfer = d.transfer_times;
    code = "<p>Операционный  день<br /><b>" + week_day + ", " + oper_day + "</b></p><div>";
    for (var j = 0; j < transfer.length; j++) {
        if (transfer[j].title == "ЦБ:") continue;
        code += "<span " + " title='" + si_transfer_times[j] + "'>" + transfer[j].title + " <b>" + transfer[j].value + "</b></span>";
    }
    code += "</div>";
    getDOM("opentime").innerHTML = code;
    hideDOM("opentime");
    messageCnt();  //message count chiqarish uchun
}

function messageCnt() {
    if (is.def(getDOM("message_count"))) {
        setmessageCnt();
        setInterval(setmessageCnt, 5000);
    }
}

function setmessageCnt() {
    var d = jsonHash.getJson();
    if ((is.def(d.message_cnt)) && (d.message_cnt > 0)) {
        showDOM("message_count");
        getDOM("message_count").innerHTML = "<h3>" + ((d.message_cnt > 9) ? "9+" : d.message_cnt) + "</h3>";
        getDOM("message_count").setAttribute("title", d.message_cnt);
    } else {
        hideDOM("message_count");
    }
}

// window width and height
window.getWinSize = function () {
    if (window.innerWidth != undefined) {
        return [window.innerWidth, window.innerHeight];
    } else {
        var B = document.body,
            D = document.documentElement;
        return [Math.max(D.clientWidth, B.clientWidth),
            Math.max(D.clientHeight, B.clientHeight)];
    }
}

function onBeforeInit() {
    initDOM(getDOM("cnt"));
    setInterval(getChat, 60000);
}

window.xhrPingManager = (function () {
    var maxIntervalMs = 30 * 60 * 1000;
    var intervalMs = 3 * 60 * 1000;
    var autoStopTime = 30 * 60 * 1000;
    var timerId = null;
    var autoStopTimeId = null;
    var isRunning = false;

    function ping() {
        if (!isRunning) return;

        var xhr = window.XMLHttpRequest
            ? new XMLHttpRequest()
            : new ActiveXObject("Microsoft.XMLHTTP");

        var now = (Date.now ? Date.now() : new Date().getTime());
        xhr.open("GET", "/ibs/user/ping.jsp?_=" + now, true);

        try {
            xhr.setRequestHeader("Cache-Control", "no-store");
        } catch (e) {
        }

        xhr.send();
        scheduleNext();
    }

    function scheduleNext() {
        if (isRunning) {
            timerId = setTimeout(ping, intervalMs);
        }
    }

    return {
        start: function (stopAfterMinute) {
            if (isRunning) {
                this.stop();
            }

            isRunning = true;
            ping();

            autoStopTime = (typeof stopAfterMinute === 'number' && stopAfterMinute > 0 && stopAfterMinute * 60 * 1000 < maxIntervalMs)
                ? stopAfterMinute * 60 * 1000
                : maxIntervalMs;

            autoStopTimeId = setTimeout(function () {
                window.xhrPingManager.stop();
            }, autoStopTime);
        },
        stop: function () {
            if (timerId) clearTimeout(timerId);
            if (autoStopTimeId) clearTimeout(autoStopTimeId);

            isRunning = false;
            timerId = null;
            autoStopTimeId = null;
        },
        isActive: function () {
            return isRunning;
        }
    };
})();

function onLoad() {
    getMenu();
    getMessage();
    getNotify();
    getReports();
    getPin();
    getUserCache();
    getIabsInfo();
    getUserImage();
    up_down();
    calendarAndLang();
    getOperDays();
    pageLoad();
    loadSmartOnOff();
    if (is.func(goHR_Happy))
        goHR_Happy();
}