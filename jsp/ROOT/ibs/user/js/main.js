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
        if (is.def(getDOM("user_sel"))) hideDOM("user_sel");
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
/*function addHandler(object, event, handler, useCapture) {
	if(object.addEventListener) {
		object.addEventListener(event, handler, useCapture ? useCapture : false);
	} else if(object.attachEvent) {
		object.attachEvent('on' + event, handler);
	} else alert("Add handler is not supported");
}
addHandler(window,"blur",function(){
    if(_.activeElement.tagName == "IFRAME" || _.activeElement.tagName == "FRAME")
	closeNav();
});*/

/*======menu ochilganda vaqtincha sloy tortib qo'yilgan shuni olib tashlash uchun=====*/
_.onclick = function (e) {
    var event = e || window.event;
    var dom = event.srcElement || event.target;
    var id = dom.getAttribute("id");
    if (id == "content") {
        rightMenu(false);
    }
    if (id != "user" && is.def(getDOM("user_sel")) && getDOM("user_sel").style.display != "none") {
        hideDOM("user_sel");
    }
    if (id != "hasopday" && is.def(getDOM("list_operdays")) && getDOM("list_operdays").style.display != "none") {
        hideDOM("list_operdays");
    }
    if (isCross()) {
        if (is.def(e.target)) {

            /*=== right menu ochiq bo'lsa va u turgan blockdan boshqa joy click bo'lsa menuni yopish uchun ===*/
            if ((!e.target.closest("#trm_ico")) && (!e.target.closest("#rightmenu"))) {
                if (is.def(getDOM("rightmenu"))) {
                    if (getDOM("rightmenu").className == "active")
                        rightMenu(false);
                }
            }
        }
    }

};


/**============claviaturadan boshqarish=====*/

/*================================start menu sidebar and content=====================================================*/

/*========== barcha jsonlarni bazadan olib kelish ==========*/



function getUserCache() {
    AJAX.load({POST: {request: "user_cache"}, async: true});
}


function checkFeedback() {
    AJAX.load({POST: {request: "check_feedback"}});
}

/*========= virtual user bo'lib kirish =====================*/

/**
 *olib kelingan jsonlarni global o'zgaruvchiga berish  va qandaydir xatolik bo'lsa iabs 6.0.0 menusini o'zini menularni chizish uchun
 */


/*======otchyotlarni oliob kelib menu qilib chizib beradi =======*/

/***=============start menu ===============================*/

/*===menu chizayotganda bolasi bor yoki yo'qligini tekshiradi====*/


/*==================== textdan 10 tasini kesib oladi ================*/

/*==================== menudan search qilish ========================*/




/*====== menuni search qilganda yonidan chiqgan x knopkasi uchun =========*/

/*====== search uchun array yasab beradi ===================*/

/*======= replaceAll uchun =================================*/
String.prototype.replaceAll = function (search, replacement) {
    var target = this;
    return target.split(search).join(replacement);
};
/*======= trim methodi uchun =================================*/
String.prototype.trim = function () {
    return this.replace(/^[\s\uFEFF\xA0]+|[\s\uFEFF\xA0]+$/g, '');
};

/*======= sariq rangda tasvirlash ===========================*/

/*====== topilgan textni qaytaradi ==========================*/

/*======= cursor tepaga i pastga tushadi down/up knokalari bosilganda ============*/

/*========== elementni parent scrolli ichida ko'rsatish uchun ==========*/

/*================menu ochilganda qolganlarini yopvorish===================**/



/*============= mishkani cursori borganda birpas kutib keyin ochishi uchun ===================*/


/*=========showhide qilish ===*/


/*================ Barcha menularni ochiq bo'lsa yopadi =======================*/

/*================ Barcha menularni ochib yuboradi =======================*/

/**===================================start pin===================================================*/

/*==== pin bo'lganlarini chizish uchun ===*/

/*==== pin qilish uchun ====*/

/*====== Search polyasi yonidagi yulduzcha belgisi bosilganda ishlaydi ====*/

/*====== pin qilish ====*/

/*========= iconka boriligini tekshiradi ===============*/

/*=========pinned qilinganlarni chizish uchun===============*/

/*===========pin qilingan podsistemalarni ochib berishi=======*/

/**===============end pin====================================================================*/

/*=========== html tagidagi classlar almashuvi========*/
function changeClass(obj, name) {
    obj.className = name;
}

/*=========== html tagidagi class qo'shish========*/

/*=========== menudagi rasmlar almashuvi==============*/

/*=========== Iabs menuni ochib berishi=======*/




/*========= menular contentini ochib yopish====*/

/*========= oxirgi kirilganlar ro'yhatini ochib berish====*/

/*======== oxirgi kirilgan podsistemalarni ochib berishi====*/


/*======= otchyotlarni ochib berishi====*/

function goErrorHandler(c, url) {
    var u = "";
    switch (c) {
        case "A":
            u = url;
            break;
        case "L":
            u = "/expiredLicense.jsp";
            break;
        default:
            u = "/errorHandler.jsp?support_browser=" + c;
    }

    go({
        url: u,
        target: contents,
        lock: false
    })
}

/*=====pod sistemaga o'tish=====*/


/*===yulduzcha oxirgi marta kirilgan podsistemalarni ko'rsatish=====*/

/*==================reportlarni ochib  berish==========*/

/*==================reportlarni ochib  berish==========*/

/*=====instruksiyani ochib berishi ========*/

/**====== iabs 6.0.0 dagi global search uchun ma'lumot yig'ish=======*/



/*=======logout qilish=====*/
function logout() {
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
    var self = this;
    var d;
    this.setDigitDate = function (d) {
        self.d = d;
    };
    this.getDigitDate = function () {
        return self.d;
    };
};
var dateD = new getDigitalDate();

function digitalWatch() {
    var date = new Date(new Date().getTime() + sysdate);
    if (sysdate < 0) {
        date = new Date(new Date().getTime() - Math.abs(sysdate));
    }
    dateD.setDigitDate(date);
    if (is.def(getDOM("ETP"))) {
        getDOM("ETP").innerHTML = '<p style="vertical-align:bottom; display:block" title="' + si_sysdate + '"><span>' + si_time + ':</span> <span style="text-align:right"><b>' + date.format("d.m.Y") + '</b></span>' + '<span style="text-align:right"><b>' + date.format("H:i:s") + '</b></span>' + '</p>';
    }
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
    img.src = "user/img/close_over.png";
    if (isCross()) {
        img.addEventListener('click', hideUserMessage);
    } else {
        img.attachEvent('onclick', hideUserMessage);
    }
    img.onmouseover = this.src = "user/img/close_out.png";
    img.onmouseout = this.src = "user/img/close_over.png";
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
    var employeeCode = top.user_code;
    var json = d.split("~")[2];
    json = json ? JSON.parse(json).messages[employeeCode] : null;
    if (!json || Object.keys(json).length === 0) return;
    var timer = setInterval(function () {
        hideFirstToast();
    }, 10 * 1000);

    function hideFirstToast() {
        var t = document.querySelectorAll(".beautyToast-wrapper .beautyToast");
        if (t && t.length >= 5) {
            var id = t[0].getAttribute("toast-id");
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
            var messageId = Object.keys(json)[0];
            var messageText = htmlEntities(json[messageId][0]);
            var messageType = json[messageId][1];
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
                var detailBtn = '<button class="detailBtn" message-id="' + messageId + '" onclick="showMessageDetail(this)">&#x41F;&#x43E;&#x434;&#x440;&#x43E;&#x431;&#x43D;&#x44B;&#x439;</button>';
                beautyToast[messageType]({
                    message: messageText + detailBtn,
                    timeout: 0,
                    animationTime: 150,
                    closeColor: "#68D84C",
                    darkTheme: false,
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
    var p = o.closest(".beautyToast ");
    var toastId = p.getAttribute("toast-id");
    if (toastId) closeToast(toastId, function () {
    });
}

/** Delete Message */
function deleteMessage(o) {
    var p = o.closest(".beautyToast ");
    var messageId = p.querySelector(".detailBtn").getAttribute("message-id");
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
    var messageId = o.getAttribute("message-id");
    hideMessage(o);
    go({
        url: "/ibs/user/util/toast/detail.jsp?messageId=" + messageId,
        target: "modalE",
        dialogWidth: 620,
        dialogHeight: 420,
        callback: function () {
            deleteMessage(o);
        }
    });
}

/*=====kelgan messagelarni ko'rsatib turish=================*/
function notifyMsg(d) {
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

        var count = d[1].split("~");
        jsonHash.setMsg_cnt(count[count.length - 1]);
        if (isCross()) {
            try {
                showHighMessages(d[1]);
            } catch (error) {
            }
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

/*===============virtual userga o'tish=====================*/
function chose_one(obj) {
    if (getDOM(obj + "_sel").style.display == "none") {
        showDOM(obj + "_sel");
        if (_.body.clientHeight < getDOM(obj + "_sel").offsetHeight) {
            getDOM(obj + "_sel").style.height = "500px";
            getDOM(obj + "_sel").style.overflowY = "scroll";
        }
    } else {
        hideDOM(obj + "_sel");
    }
}

/***==========Tilni o'zgartirish========***/
function changeLangImg(val) {
    return;
    hideDOM(obj + "_sel");
    switch (val) {
        case 1:
            getDOM("lang").innerHTML = "<a><img src='user/img/lang_rus.png'></a>";
            break;
        case 2:
            getDOM("lang").innerHTML = "<a><img src='user/img/lang_uzc.png'></a>";
            break;
        case 3:
            getDOM("lang").innerHTML = "<a><img src='user/img/lang_uzl.png'></a>";
            break;
        case 4:
            getDOM("lang").innerHTML = "<a><img src='user/img/lang_eng.png'></a>";
            break;
    }
    getDOM(val).style.border = "1px solid dodgerblue";
}

/*=========tilni o'zgartirish===========*/
function changeLanguage(val) {
    chose_one("lang_sel");
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
                getDOM("new_op_den").style.color = "#FFC646";
                getDOM("TXTOPDAY").style.color = "#FFC646";
                getDOM("hasopday").src = "/ibs/user/img/24x7.gif";
            } else {
                setDS(operday, s);
                getDOM("new_op_den").style.color = "";
                getDOM("TXTOPDAY").style.color = "";
                if (iscross) {
                    getDOM("hasopday").src = "/ibs/user/img/svg/24x7.svg";
                } else {
                    getDOM("hasopday").src = "/ibs/user/img/png/24x7.png";
                }
            }
            /* var fmCode = getDOMValue("formTitle").substring(0, getDOMValue("formTitle").indexOf(" ")); */
            var fmCode = getDOMValue("formcode");
            /* goUrl(fmCode); */ // TODO(operday-followup): eski menyu olib tashlandi, contents iframe'dagi joriy formani qayta yuklash kerak
        }
    });
}

function execFutureDate() {
    if (isFutureDate(isFutureOperDay)) {
        getDOM("new_op_den").style.color = "#FFC646";
        getDOM("TXTOPDAY").style.color = "#FFC646";
        getDOM("hasopday").src = "/ibs/user/img/24x7.gif";
    } else {
        if (getDOM("new_op_den"))
            getDOM("new_op_den").style.color = "";
        getDOM("TXTOPDAY").style.color = "";
        if (iscross) {
            getDOM("hasopday").src = "/ibs/user/img/svg/24x7.svg";
        } else {
            getDOM("hasopday").src = "/ibs/user/img/png/24x7.png";
        }
        if (!hasAllowNewOperden) {
            getDOM("hasopday").style.filter = "alpha(opacity=50)";
        }
    }
}

/*==operdenlar ro'yhatini olib keladi==**/
function getOperDays() {
    if (allowed24x7 == "N") {
        hideDOM("hasopday");
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
            var s = trs[i].childNodes[2].innerText;
            var d = trs[i].childNodes[1].innerText;
            trs[i].childNodes[2].innerText = (s == "O" ? si_open : s == "C" ? si_close : si_open);
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
        } else {
            hideDOM("list_operdays");
        }
    }
}

/*========= 24x7 uchun datalar ro'yhatini tanlash uchun ======*/
function changeCheckedImg(obj) {
    var imgs = getDOM("list_operdays").getElementsByTagName("img");
    var trs = getDOM("list_operdays").getElementsByTagName("tr");
    for (var i = 0; i < imgs.length; i++) {
        imgs[i].src = "user/img/unchecked.png";
        trs[i].style.fontWeight = "normal";
    }
    obj.childNodes[0].childNodes[0].src = "user/img/checked.png";
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
    var span = "<span id=new_op_den >";
    if (is.def(c)) {
        span = "<span id=new_op_den style=\"color:#FFC646\">";
    }
    getDOM("DS").innerHTML = span + d + " " + (s == "O" ? si_open : s == "C" ? si_close : si_open) + "</span>";
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
/**====== IABS 6.5.0 uchun video darslikni ochish uchun ======*/
function video() {
    var newWin = window.open("", "_blank", "width=1000,height=600");
    newWin.document.write('<' + '!DOCTYPE html><html><head><title>' + si_video + '</title></head><body style="text-align:center;"><embed src="/ibs/user/img/IABS6.5.avi" width="950" height="556" ></body></html>');
}

/***=====function for global=====*/

/*====================== increment uchun ======================*/

/*===================== decriment uchun ================================================*/

/*===bpm oynasini ochib berishi uchun===*/
function goBPM() {
    if (isCross()) {
        go({
            url: 'bpm/extensions/bpms.jsp',
            target: 'modal',
            dialogFill: true,
            lock: false
        });
    } else {
        go({
            url: 'bpm/extensions/bpms.jsp',
            target: "new",
            cmsHelperTiltle: 'Panel',
            lock: false,
            arg: "channelmode=1,directories=1,location=0,menubar=0,toolbar=0,resizable=1,scrollbars=1,status=0,titlebar=1"
        });
    }
}

function goBPM2() {
    if (isCross()) {
        go({
            url: 'bpm2/bpms.jsp',
            target: 'modal',
            dialogFill: true,
            lock: false
        });
    } else {
        go({
            url: 'bpm2/bpms.jsp',
            target: "new",
            cmsHelperTiltle: 'Panel',
            lock: false,
            arg: "channelmode=1,directories=1,location=0,menubar=0,toolbar=0,resizable=1,scrollbars=1,status=0,titlebar=1"
        });
    }
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
            url: "ia/hr/happi.jsp",
            target: 'modalE',
            dialogWidth: screen.width - 100,
            dialogHeight: '370'
        });
    }
}

function checkLastRequest() {
}

function createIabsInfo(d) {
    jsonHash.setJson(d);
}

function pageLoad() {
    if (!isCross()) {
        document.body.className = "isIE";
        document.getElementById("rightmenu").style.borderLeft = "1px solid #24426A";
    } else {
        document.getElementById("rightmenu").style.display = "block";
    }
}

function rightMenu(ev) {
    var rmenu;
    rmenu = document.getElementById("rightmenu");
    rmenu.removeAttribute("style");
    if (rmenu.classList) {
        if (ev) {
            rmenu.classList.add("active");
            rightMenuDraw();
            showDOM("content");
        } else {
            rmenu.classList.remove("active");
        }
    } else {
        if (ev) {
            rmenu.className = "active";
            rmenu.style.display = "block";
            rightMenuDraw();
            showDOM("content");
        } else {
            rmenu.className = "";
            rmenu.style.display = "none";
            hideDOM("content");
        }
    }

    if (is.def(_mTimeout)) clearTimeout(_mTimeout);
    digitalWatch();
}

function rightMenuDraw() {
    var d, code, el, info, oper_day, week_day, currencies, min_zp;
    d = jsonHash.getJson();
    el = getDOM("rightmenu");
    info = d.info;
    oper_day = info.oper_day;
    week_day = info.week_day;
    currencies = info.currencies;
    min_zp = info.min_zp;

    code = "<div class='rightmenu_ico'><img class='trm_ico tosvg' src='/ibs/user/img/png/trm-right.png' onclick='rightMenu(false)' onmouseover='overSvg(this)' onmouseout='outSvg(this)' /></div>";
    code += "<div class='valyuta'><p>" + si_currencies + "</p><p><b>" + oper_day + ", " + week_day + "</b></p></div>";
    code += "<div class='valyuta_list'>";

    for (var i = 0; i < currencies.length; i++) {
        code += "<p title='" + currencies[i].title + "'><span><b>1 " + currencies[i].symbol + "</b></span> <span ondblclick='execCopy(this);' style='text-align:right;'>" + currencies[i].equival + "</span> <span style='color:" + currencies[i].diff_color + ";text-align:right;'> " + currencies[i].difference + "</span></p>";
    }

    code += "</div>";
    code += "<div class='ekix'><p>" + si_min_zp_title + "</p><p><b>" + min_zp.money + "</b><b style='text-align:right;'>" + min_zp.date + "</b></p></div>";

    code += "<div id='ETP'></div>";

    el.innerHTML = code;
    fixrightMenu();
}

function fixrightMenu() {
    var rmenu, winH, parH, etpH;
    rmenu = getDOM("rightmenu");
    winH = window.getWinSize()[1];
    parH = rmenu.offsetHeight;
    etpH = getDOM("ETP").offsetHeight;
    getDOM("ETP").style.marginTop = winH - parH - etpH - 20 + "px";
    rmenu.style.maxHeight = winH + "px";
    rmenu.style.height = "100%";
}

function openTime(d) {
    var transfer, code = "";
    var d = jsonHash.getJson();
    transfer = d.transfer_times;

    for (var j = 0; j < transfer.length; j++) {
        code += "<span " + " title='" + si_transfer_times[j] + "'>" + transfer[j].title + " <b>" + transfer[j].value + "</b></span>";
    }
    getDOM("opentime").innerHTML = code;
    messageCnt();  //message count chiqarish uchun
}

function messageCnt() {
    d = jsonHash.getJson();
    if (is.def(getDOM("message_count"))) {
        setmessageCnt();
        setInterval(setmessageCnt, 5000);
    }
}

function setmessageCnt() {
    var d = jsonHash.getJson();
    // alert(d.message_cnt);
    if ((is.def(d.message_cnt)) && (d.message_cnt > 0)) {
        showDOM("message_count");
        setDOMValue("message_count", (d.message_cnt > 99) ? "99+" : d.message_cnt);
        getDOM("message_count").setAttribute("title", d.message_cnt);
    } else {
        hideDOM("message_count");
    }
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
  //  setInterval(getChat, 60000);
}

function toSVG() {
    var list = document.getElementsByClassName("tosvg");
    for (var i = 0; i < list.length; i++) {
        list[i].src = list[i].src.replaceAll("png", "svg");
    }
}

var iscross = false;
if (isCross()) {
    iscross = true;
    toSVG();
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
    // SQB app-shell: eski #tree menyusi (getMenu) va CTRL-menyu shortcutlari (up_down)
    // olib tashlandi. Sidebar main.jsp ning o'z initShell() -> getSidebarMenu() orqali quriladi.
    getUserCache();
    calendarAndLang();
    if (is.func(checkLastRequest))
        checkLastRequest();
    if (is.func(goHR_Happy))
        goHR_Happy();
    pageLoad(); //main.js uchun load
}