/* go({form : tblForm, param : {submit : 1}}) */

/* onAction (double click or enter)
 * function onAction() {}
 * function onAction(cell) {}
 * onSelect (on selected cell)
 * function onSelect() {}
 * function onSelect(cell, oldcell) {}
 * onRowChange
 * function onRowChange()
 */
function _cA_(s) {
    var c = tblForm[tdf.c[_chc_].n];
    if (is.undef(c[0])) c = makeArray(c);
    for (var i = 0; i < c.length; i++) {
        c[i].checked = s == 1 ? true : s == 2 ? false : !c[i].checked;
    }
}
alert("old");
var _oc_, _chc_, constTimeout, constGrid, tdi = {}, jsSearch = ""
    , constTime = (is.def(tdf.ar) ? tdf.ar : 5000)
    , autoRefresh = (is.def(tdf.ar) ? "Y" : "N")
    , constTableControls = (is.def(getDOM("tableControls")) ? getDOM("tableControls").innerHTML : "")
    , _lastTime = 0
    , _tblLang = nvl(tdf.lang, 1)
    , _tblSeconds = ["", "секунд", "секунд", "sekund", "seconds"]
    , _tblStart = ["", "Старт", "Ё&#1179;иш", "Yoqish", "Start"]
    , _tblStop = ["", "Стоп", "Ўчириш", "O'chirish", "Stop"]
    , _tblNoData = ["", "нет данных", "маълумот йў&#1179;", "ma'lumot yo'q", "no data"]
    , _tblSelectAll = ["", "Выделить все", "&#1202;аммасини танлаш", "Hammasini tanlash", "Select all"]
    , _tblCancelAll = ["", "Отменить выделенное", "Танлов бекор &#1179;илиш", "Tanlov bekor qilish", "Cancel selection"]
    ,
    _tblSelectInvert = ["", "Инвертировать выделенное", "Танлашнинг тартибини алмаштир", "Tanlashning tartibini almashtir", "Invert selection"]
    , _tblApply = ["", "Применить", "&#1178;ўллаш", "Qo'llash", "Apply"]
    , _tblClean = ["", "Очистить", "Тозалаш", "Tozalash", "Clean out"]
    ,
    _tblFiltered = ["", "Поля, подлежащие фильтрации", "Фильтрланадиган майдонлар", "Filtrlanadigan maydonlar", "The fields to be filtered"]
    ,
    _tblSorting = ["", "Сортировка", " &nbsp; Тартиб &nbsp; ", "&nbsp; &nbsp; Tartib &nbsp; &nbsp;", " &nbsp; Sorting &nbsp; "]
    , _tblExcel = ["", "Печатать в Excel", "Excel га чи&#1179;ариш", "Excel ga chiqarish", "Печатать в Excel"]
    , _tblFilter = ["", "Фильтр", "Фильтр", "&nbsp; Filtr &nbsp;", "&nbsp; Filter &nbsp;"]
    , _tblNotEqual = ["", "не равно", "тенг эмас", "teng emas", "not equal"]
    , _tblEqual = ["", "равно", "тенг", "teng", "equally"]
    , _tblMore = ["", "больше", "катта", "katta", "more"]
    , _tblLess = ["", "меньше", "кичик", "kichik", "less"]
    , _tblContains = ["", "содержит", "маджуд", "mavjud", "contains"]
    , _tblBegin = ["", "начиная с", "бошланади", "boshlandi", "beginning with"]
    , _tblEnd = ["", "с конца", "тугайди", "tugaydi", "from the end"]
    , _tblHotReload = ["", "Обновить страницу", "Сахифани янгилаш", "Saxifani yangilash", "Refresh page"]
    , _tblHotHome = ["", "Первая страница", "Биринчи сахифа", "Birinchi saxifa", "First page"]
    , _tblHotUp = ["", "Предыдущая страница", "Олдинги сахифа", "Oldingi saxifa", "Previous page"]
    , _tblHotDown = ["", "Следущая страница", "Кейинги сахифа", "Keyingi saxifa", "Next page"]
    , _tblHotEnd = ["", "Последняя страница", "Охирги сахифа", "Oxirgi saxifa", "Last page"]
    , _tblMultiSelect = ["", "Выберите опции", "Параметрларни танланг", "Parametrlarni tanlang", "Select options"]

    , _chMenu = [{
        label: _tblSelectAll[_tblLang]
        , action: function () {
            _cA_(1)
        }
    }, {
        label: _tblCancelAll[_tblLang]
        , action: function () {
            _cA_(2)
        }
    }, {
        label: _tblSelectInvert[_tblLang]
        , action: function () {
            _cA_(3)
        }
    }];

(function () {
    function getElementsByClassNamePolyfill(parent, className) {
        var results = [];
        var elements = parent.getElementsByTagName('*');
        for (var i = 0; i < elements.length; i++) {
            if ((' ' + elements[i].className + ' ').indexOf(' ' + className + ' ') > -1) {
                results.push(elements[i]);
            }
        }
        return results;
    }

    function Multiselect(selectElement, fm) {
        var hiddenSelect = selectElement;
        var multiSelectHTML = '<div class="ie-iabs-multi-select">' +
            '<span class="dropdown-container">' + _tblMultiSelect[_tblLang] + '</span>' +
            '<div class="checkbox-options" style="display: none;">';

        var options = hiddenSelect.options;
        var selectedCount = 0;

        for (var i = 0; i < options.length; i++) {
            var isChecked = options[i].selected ? 'checked="checked"' : '';
            if (options[i].selected) {
                selectedCount++;
            }
            multiSelectHTML +=
                '<label>' +
                '<input type="checkbox" value="' + options[i].value + '" ' + isChecked + '>' +
                options[i].text +
                '</label>';
        }

        multiSelectHTML += '</div></div>';

        if (hiddenSelect.insertAdjacentHTML) {
            hiddenSelect.insertAdjacentHTML('afterend', multiSelectHTML);
        } else {
            var tempDiv = document.createElement('div');
            tempDiv.innerHTML = multiSelectHTML;
            hiddenSelect.parentNode.insertBefore(tempDiv.firstChild, hiddenSelect.nextSibling);
        }

        var multiSelect = hiddenSelect.nextSibling;

        hiddenSelect.style.display = 'none';

        var dC = multiSelect.getElementsByTagName('span')[0];
        var optionsContainer = multiSelect.getElementsByTagName('div')[0];

        var allMultiSelects = getElementsByClassNamePolyfill(fm, 'checkbox-options');

        dC.onclick = function (event) {
            event = event || window.event;
            event.cancelBubble = true;

            for (var i = 0; i < allMultiSelects.length; i++) {
                if (allMultiSelects[i] !== optionsContainer) {
                    allMultiSelects[i].style.display = 'none';
                }
            }

            optionsContainer.style.display = optionsContainer.style.display === 'block' ? 'none' : 'block';
        };

        function updateSelectedCount() {
            selectedCount = 0;

            var checkboxes = optionsContainer.getElementsByTagName('input');

            for (var i = 0; i < checkboxes.length; i++) {
                if (options[i]) {
                    options[i].selected = checkboxes[i].checked;
                    if (checkboxes[i].checked) {
                        selectedCount++;
                    }
                }
            }

            var selectedCountSpan = multiSelect.getElementsByTagName('span')[0];
            selectedCountSpan.innerText = selectedCountSpan.textContent = _tblMultiSelect[_tblLang] + ' (' + selectedCount + ')';
        }

        var checkboxes = optionsContainer.getElementsByTagName('input');
        for (var i = 0; i < checkboxes.length; i++) {
            checkboxes[i].onclick = function () {
                updateSelectedCount();
            };
        }

        this.clear = function () {
            var checkboxes = optionsContainer.getElementsByTagName('input');

            for (var i = 0; i < checkboxes.length; i++) {
                checkboxes[i].checked = false;
                if (options[i]) {
                    options[i].selected = false;
                }
            }

            updateSelectedCount();
        };

        updateSelectedCount();
    }

    var multiselectInstances = [];

    var originalMultiselect = Multiselect;
    window.Multiselect = function (selectElement, fm) {
        var instance = new originalMultiselect(selectElement, fm);
        multiselectInstances.push(instance);
        return instance;
    };

    window.Multiselect.clearAll = function () {
        for (var i = 0; i < multiselectInstances.length; i++) {
            multiselectInstances[i].clear();
        }
    };
})();

function doGridFilter() {
    var h, v, p = {};
    for (i in tdf.h) {
        h = tdf.h[i];
        if (h.f && h.f.g) {
            if (h.f.m === "date") {
                v = document.getElementById("f" + h.i).value;
                if (v == '__.__.____') {
                    v = '';
                }
            } else {
                v = getDOM("f" + h.i).value;
                if (/^_+$/.test(v)) {
                    v = '';
                }
            }
            p["f" + h.i] = v;
        }
    }
    go({param: p});
}

function _fc(h, r) {
    function dc(h) {
        if (h.f.s) {
            if (h.f.t == 4 && r != 2) {
                return "<select multiple='multiple' name=f" + h.i + " id=f" + h.i + (r == 2 ? " onchange='doGridFilter()'" : "") + (is.def(h.f.r) ? " r=" + h.f.r : "") + ">" + h.f.s + "</select>";
            } else {
                return "<select name=f" + h.i + " id=f" + h.i + (r == 2 ? " onchange='doGridFilter()'" : "") + (is.def(h.f.r) ? " r=" + h.f.r : "") + "><option value=></option>" + h.f.s + "</select>";
            }
        } else {
            var _sn = ""
                ,
                _s = "<input name=f" + h.i + " id=f" + h.i + (r == 2 ? " onkeypress='if(event.keyCode==13){doGridFilter();}'" : "") + (is.def(h.f.c) ? " size=" + h.f.c : "") + (is.def(h.f.m) ? ' mask="' + h.f.m + '"' : "") + (is.def(h.f.r) ? " r=" + h.f.r : "");
            if (r != 2) {
                if (h.f.rf) {
                    _s += ' reference="{name:\'' + h.f.rf + '\',get:{f1:fm.f' + h.i + '},put:[fm.f' + h.i + ',fm.f' + h.i + 'Name],url:\'' + (is.def(h.f.rfu) ? h.f.rfu : _.URL.split('?')[0]) + '\'}"';
                }
                if (h.f.rq) {
                    _s += ' request="{name:\'' + h.f.rq + '\',get:{code:fm.f' + h.i + '},put:[fm.f' + h.i + 'Name],url:\'' + (is.def(h.f.rqu) ? h.f.rqu : _.URL.split('?')[0]) + '\'}"';
                }
                if (is.def(h.f.rf) || is.def(h.f.rq)) _sn = "<input name=f" + h.i + "Name a=l readonly size=70 tabIndex=-1>";
            }
            _s += " nullable=1>";
            return _s + _sn;
        }
    }

    var s = "";
    var q = "";
    if (h.f) {
        if (h.f.r == 1) q = " <q>*</q>";
        if (r > 1 && is.undef(h.f.g)) return s;
        if (h.f.l) s += h.f.l;
        else s += h.l + q;
        if (r == 1) s += "<td nowrap>";
        switch (h.f.t) {
            case 1:
                s += ":" + dc(h) + " ";
                break;
            case 2:
                s += ":" + dc(h);
                s += ' -';
                s += dc(h) + " ";
                break;
            case 3:
                s += ":<select name=fo" + h.i + (r == 2 ? " onchange='go({param:{fo" + h.i + ":this.value}})'" : "") + '><option value="">&nbsp;<option value="!=">' + _tblNotEqual[_tblLang] + '<option value="=" selected >' + _tblEqual[_tblLang] + '<option value=">">' + _tblMore[_tblLang] + '<option value="<">' + _tblLess[_tblLang] + '<option value="_like_">' + _tblContains[_tblLang] + '<option value="like_">' + _tblBegin[_tblLang] + '<option value="_like">' + _tblEnd[_tblLang] + '</select>';
                s += dc(h);
                break;
            case 4:
                s += ":" + dc(h) + " ";
        }
        if (r == 1) s += '<td align=center><span style="font-weight:bold;width:20px;text-align:right"></span><input tabIndex=-1 type=checkbox name=a' + h.i + ' onclick="onSortClick(this)"><span class=navbut style="font-size:18px;color:red;text-align:left" onclick="changeDir(this)"></span>';
    }
    return s;
}

function showFilter() {
    var s = "<table id=base align=center cellspacing=1 minWidth=fill minHeight=fill ><tr><td class=formTitle>Заявка<tr><td><form name=fm><table align=center class=formToolbar><tr><td>";
    s += '<input type=button value="' + _tblApply[_tblLang] + '" onclick="applyFilter()" title="[CTRL + ENTER]"><input type=reset value="' + _tblClean[_tblLang] + '" title="[CTRL + L]" onclick="clearFilter()"></table>';
    s += '<table border=0><tr style="font:bold"><td colspan=2 align=center>' + _tblFiltered[_tblLang] + '<td align=center nowrap>' + _tblSorting[_tblLang];
    for (var i = 0; i < tdf.h.length; i++) {
        if (tdf.h[i].f) {
            s += "<tr><td align=right>" + _fc(tdf.h[i], 1)
        }
    }
    var r = go({
        target: "modalE"
        , action: function (w) {
            w._.body.innerHTML = s;
            w._.body.style.background = w._.body.currentStyle["modal-background"];
            w.data = {
                fm: nvl(tdd.w, {})
            };

            w.tdf = tdf;
            w.sort = nvl(tdd.s, []);
            w.evalSize(w.base.clientWidth + 100, w.base.clientHeight);
            w.findIt = function (v) {
                for (var i = 0; i < w.sort.length; i++)
                    if (w.sort[i][0] == v) return i;
                return -1
            };
            w.onSortClick = function (t) {
                var i = t.name.substr(1);
                if (t.checked) w.sort.push([i, "asc"]);
                else {
                    i = w.findIt(i);
                    w.sort = w.sort.slice(0, i).concat(w.sort.slice(i + 1));
                }
                w.fillSort();
            };
            w.changeDir = function (t) {
                var f = t.previousSibling;
                if (f.checked) {
                    f = w.findIt(f.name.substr(1));
                    w.sort[f][1] = w.sort[f][1] == "desc" ? "asc" : "desc";
                    w.fillSort();
                }
            };
            w.fillSort = function () {
                var f;
                for (var i = 0; i < w.tdf.h.length; i++) {
                    if (tdf.h[i].f) {
                        f = w.fm["a" + w.tdf.h[i].i];
                        f.checked = false;
                        f.previousSibling.innerHTML = "";
                        f.nextSibling.innerHTML = "";
                    }
                }
                for (var i = 0; i < w.sort.length; i++) {
                    f = w.fm["a" + w.sort[i][0]];
                    if (is.undef(f)) continue
                    f.checked = true;
                    f.previousSibling.innerHTML = i + 1;
                    f.nextSibling.innerHTML = w.sort[i][1] == "desc" ? 5 : 6;
                }
            };
            /*TODO. Code Review qilish kerak.*/
              /* Multi select uchun, valuelarni qabul qilib uni arrayga parse qilib ["101,102"]=>["101","102"], optionlarni selected qilish methodi */
            w.setSelectValue = function (s, id) {
                if (is.def(tdd.w[id])) {
                    var rawValues = tdd.w[id][0].split(",");
                    var valuesToSelect = [];

                    for (var k = 0; k < rawValues.length; k++) {
                        valuesToSelect.push(rawValues[k].replace(/^\s+|\s+$/g, ""));
                    }

                    var options = s.getElementsByTagName("option");

                    function arrayContains(array, value) {
                        for (var i = 0; i < array.length; i++) {
                            if (array[i] === value) {
                                return true;
                            }
                        }
                        return false;
                    }

                    for (var j = 0; j < options.length; j++) {
                        if (arrayContains(valuesToSelect, options[j].value)) {
                            options[j].selected = true
                        }
                    }
                }
            };

            w.onLoad = function () {
                w.hideDOM(w.base.tBodies[0].rows[0]);
                w.fillSort();
                w._.onkeyup = (function (e) {
                    var e = w.event || e;
                    var unicode = e.keyCode ? e.keyCode : e.charCode;
                    if (e.ctrlKey && unicode == "13") { //HOTKEY ctrl + enter
                        w.applyFilter();
                    } else if (e.ctrlKey && unicode == "76") { //HOTKEY ctrl + l
                        w.fm.reset();
                    }
                });

                if (is.def(tdd.w)) {
                    var selects = w._.fm.getElementsByTagName("select");

                    for (var i = 0; i < selects.length; i++) {
                        var select = selects[i];

                        if (select && select.getAttribute("multiple")) {
                            var _id = select.getAttribute("id");

                            w.setSelectValue(select, _id);
                        }
                    }
                }

                var s = w._.fm.getElementsByTagName("select");
                for (var i = 0; i < s.length; i++) {
                    if (s[i] && s[i].getAttribute('multiple')) {
                        Multiselect(s[i], w._)
                    }
                }
            };
            w.applyFilter = function () {
                if (!w.fm.fireEvent("onsubmit")) return;
                var es = w.fm.elements
                    , e, p = {};
                for (var i = 0; i < es.length; i++) {
                    e = es[i];
                    if (e.name.length > 0) {
                        if (is.def(p[e.name])) p[e.name].push(e.value);
                        else if (w._.getElementById(e.name) && w._.getElementById(e.name).getAttribute("multiple") && e.value) {
                            var _s = w._.getElementById(e.name);
                            var _o = _s.getElementsByTagName("option");
                            p[e.name] = [];

                            for (var j = 0; j < _o.length; j++) {
                                if (_o[j] && _o[j].selected) {
                                    p[e.name].push(_o[j].value);
                                }
                            }

                            p[e.name] = p[e.name].join(",");
                        } else p[e.name] = [e.value];
                    }
                }
                for (var i = 0; i < w.sort.length; i++) {
                    p["s" + w.sort[i][0]] = [i, w.sort[i][1]];
                }

                if (w.sort && w.sort.length === 0) {
                    p["clearSort"] = "true";
                }
                w.returnValue = p;
                w.close();
            };
            w.clearFilter = function () {
                w.sort = [];
                w.fm.reset();
                Multiselect.clearAll()
            }
        }
        , lock: false
        , dialogWidth: 1100
        , dialogScroll: "yes"
    });
    if (r != null) go({
        param: r
    });
}

(ajaxTable = function (obj) {
    if (obj) {
        tdd = null;
        tdi = {};
        try {
            eval("tdd=" + obj);
        } catch (e) {
            if (e instanceof SyntaxError) {
                alert(e.message);
            }
        }
        constGrid = "";
        getDOM("tblForm").parentNode.removeChild(getDOM("tblForm"));
    }
    for (var i = 0; i < tdf.h.length; i++) {
        var h = tdf.h[i];
        if (is.undef(tdi[h.i])) tdi[h.i] = i;
        else {
            alert(h.i + " id is dublicated");
            throw "ex";
        }
    }
    if (is.undef(tdf.f)) tdf.f = 0;
    var _al = ["left", "center", "right"]
        , st = "";
    if (tdd.p || !is.hasFlag(tdf.f, 16)) {
        st += "";
        if (tdd.p) {
            st += '<input value=' + (tdd.p.RPP > tdd.p.TR ? tdd.p.TR : tdd.p.RPP) + ' class=rpp size=2 mask="4|0-9" onkeypress="if(event.keyCode==13){go({param:{_rpp:(this.value>0)?this.value:1,page:1}});this.cb=1}" onfocus="this.value=tdd.p.RPP;this.select();" onblur="if(this.cb!=1)this.value=(tdd.p.RPP>tdd.p.TR? tdd.p.TR: tdd.p.RPP)"><input value="- ' + tdd.p.TR + '" class=tp tabindex=-1 readonly size=' + ((new String(tdd.p.TR)).length + 2) + ">";
            st += '<button class=navbut onclick="goPage(\'first\')"' + (tdd.p.PN <= 1 ? 'disabled' : '') + ' title="' + _tblHotHome[_tblLang] + '[HOME]">9</button>';
            st += '<button class=navbut onclick="goPage(\'prev\')"' + (tdd.p.PN <= 1 ? 'disabled' : '') + ' title="' + _tblHotUp[_tblLang] + '[PAGE UP]">7</button>';
            if (tdd.p.MP < 20) {
                st += '<select onChange="goPage(this.value)"' + (tdd.d.length == 0 ? " disabled" : "") + ">";
                for (var i = 1; i <= tdd.p.MP; i++) {
                    st += "<option value=" + i + (i == tdd.p.PN ? " selected>" : ">") + i
                }
                st += "</select>";
            } else st += "<input class=rpp value=" + tdd.p.PN + ' onkeypress="if(event.keyCode==13)this.blur();" onblur="goPage(this.value);" onfocus="this.select()" size=' + ((new String(tdd.p.MP)).length) + '><input value="- ' + tdd.p.MP + '" class=tp tabindex=-1 readonly size=' + ((new String(tdd.p.MP)).length) + ">";
            st += '<button class=navbut onclick="goPage(\'succ\');"' + (tdd.p.PN >= tdd.p.MP ? 'disabled' : '') + ' title="' + _tblHotDown[_tblLang] + '[PAGE DOWN]">8</button>';
            st += '<button class=navbut onclick="goPage(\'last\');"' + (tdd.p.PN >= tdd.p.MP ? "disabled" : "") + ' title="' + _tblHotEnd[_tblLang] + '[END]">:</button>';
        }
        if (!is.hasFlag(tdf.f, 256)) {
            st += '<button class=navbut onclick="exportFormPreview();" ><img  src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAQAAAC1+jfqAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAadEVYdFNvZnR3YXJlAFBhaW50Lk5FVCB2My41LjEwMPRyoQAAANJJREFUKM+d0b1KA2EQheEnsBr8VPCvsRHBNmBtlTaxURur2KfJDQi2WokLVq5YqBvBXtIIXoOkiIg3ICgpJAEbwWrzA8EFz1QD78ww55BpVdWhG/diY9p1rOnOqQMlkeDayqAiHq0rjAzMajsb1AW34wsFyUiXTgLexHakUvMZEOtaVPVtc/KGJZ+OPDtH8OLEtkRibniiru/dAoIrM6YEQWEINPR8WEbwZE9JTU0xA9Z8qXt1iaClbENFxXQGPOiI7Pux9c83/zQq1+rcsHLi/gUagEXcukqmLgAAAABJRU5ErkJggg==" title="' + _tblExcel[_tblLang] + '[ALT + E]"/></button>';
        }
        if (!is.hasFlag(tdf.f, 16)) {
            st += '<button class=navbut oncontextmenu="return menu(event);" onclick="getAjaxTDD();" title="' + _tblHotReload[_tblLang] + '[ALT + R]">q</button>';
            st += '<div id="contextMenuId" style="display:none;position:absolute;/*top:0;left:0;*/border:1px solid #666666;background-color:#F2F2F2;padding:2px;float:left;"></div>';
        }
        if (is.hasFlag(tdf.f, 32)) st += '<button class=navbut onclick="go({param:{_recreateValue:1}})">x</button>';
        if (!is.hasFlag(tdf.f, 64) && is.hasFlag(tdd.f, 1)) {
            st += '<button onclick="showFilter()"' + (is.hasFlag(tdd.f, 2) ? " class=withFilter" : "") + " title='[ALT + F]'>" + _tblFilter[_tblLang] + "</button>";
        }
    }
    if (st != "") {
        try {
            getDOM("tableControls").innerHTML = st + constTableControls;
        } catch (ex) {
            alert("tableControls is not found");
            throw ex;
        }
    }
    st = "";
    for (var i = 0; i < tdf.h.length; i++) {
        st += _fc(tdf.h[i], 2);
    }
    if (st != "") {
        try {
            getDOM("filterControls").innerHTML = st;
        } catch (ex) {
            alert("filterControls is not found");
            throw ex;
        }
    }
    if (is.def(tdf.sum)) {
        st = "";
        for (var i = 0; i < tdf.sum.length; i++) {
            st += ((st == "") ? "" : " ") + "<b>" + tdf.sum[i] + "</b>: " + ((is.def(tdd.sum[i])) ? tdd.sum[i] : 0);
        }
        if (st != "") {
            try {
                getDOM("sumControls").innerHTML = st;
            } catch (ex) {
                alert("sumControls is not found");
                throw ex;
            }
        }
    }
    st = "";
    var k = 0;
    if (!is.hasFlag(tdf.f, 4)) k++;
    if (is.hasFlag(tdf.f, 1)) k++;
    if (!obj) {
        st += '<div class=panel id=basepanel style="height:300px">';
    }
    st += '<form name=tblForm nocycle=1 method=post><table id=tbl cellspacing=0 cellpadding=5 cl=' + k + " ><thead><tr>";
    if (!is.hasFlag(tdf.f, 4)) st += "<th>&nbsp;";
    if (is.hasFlag(tdf.f, 1)) st += "<th>&nbsp;";
    for (var i = 0; i < tdf.c.length; i++) {
        if (tdf.c[i].t != 4) {
            var dr1, dr2 = "";
            if (tdf.c[i].t != 2) {
                if (dataExist() && !is.hasFlag(tdf.f, 8)) {
                    if (tdd.s && tdd.s.length > 0 && tdf.c[i].i == tdd.s[0][0]) {
                        dr1 = tdd.s[0][1] == "desc" ? 5 : 6;
                        dr2 = ' <span class="navbut cSort">' + dr1 + "</span>"
                    } else {
                        dr1 = 5;
                    }
                    st += '<th onclick="go({param:{s' + tdf.c[i].i + ":[1,'" + (dr1 == 6 ? "desc" : "asc") + '\']}})">';
                } else {
                    st += "<th>";
                }
            } else {
                st += "<th";
                if (tdf.c[i].w) st += " nowrap";
                st += '><button onclick="if(dataExist()){_chc_=' + i + ';drawMenu(_chMenu,event.clientX, event.clientY);}" style="width:12px;height:12px">&nbsp;</button>';
            }
            st += nvl(is.def(tdf.c[i].l) ? tdf.c[i].l : tdf.h[tdi[tdf.c[i].i]].l, "&nbsp;") + dr2;
        }
        tdf.c[i].a = nvl(tdf.c[i].a, 1);
    }
    st += "<tbody>";
    for (var j = 0; j < tdd.d.length; j++) {
        function d(i) {
            return tdd.d[j][tdi[i]]
        }

        function c(c) {
            if (c) {
                c = eval(c);
                if (is.def(c)) return ' style="color:' + c + '"';
            } else {
                return "";
            }
        }

        /* jsSearch != "" bolsa tdd dan search qilinadi bazaga murojat qilmasdan
         */
        /*if(_oc_ != null && jsSearch != "") {
            var searchResult = tdd.d[j][tdi[tdf.c[_oc_.cellIndex-1].i]];
            if(searchResult.toLowerCase().indexOf(jsSearch.toLowerCase()) == -1) continue;
            //alert(_oc_.cellIndex + " -> " + tdf.c[_oc_.cellIndex-1].i +" : " + jsSearch);
        }*/
        st += "<tr class=" + (j % 2 == 0 ? "cellEven" : "cellOdd") + c(tdf.rc) + ">";
        if (!is.hasFlag(tdf.f, 4)) st += '<th style="padding:0px;">&nbsp;';
        if (is.hasFlag(tdf.f, 1)) st += "<th>" + (j + 1 + (is.undef(tdd.p) ? 0 : (tdd.p.PN - 1) * tdd.p.RPP));
        for (var i = 0; i < tdf.c.length; i++) {
            k = tdd.d[j][tdi[tdf.c[i].i]];
            if (is.undef(k)) k = "";
            switch (tdf.c[i].t) {
                case 1:
                    st += '<td align=center><input onfocus="moveCell(this.parentNode)" onblur="this.editing=false" onkeydown="if(this.editing){if(event.keyCode!=13)event.cancelBubble=true}" a=' + ["l", "c", "r"][tdf.c[i].a];
                    if (tdf.c[i].n) st += " name=" + tdf.c[i].n;
                    if (tdf.c[i].m) st += ' mask="' + tdf.c[i].m + '"';
                    if (tdf.c[i].e) st += ' enable="' + tdf.c[i].e + '"';
                    if (tdf.c[i].r) st += " r=1";
                    if (tdf.c[i].x) st += " size=" + tdf.c[i].x;
                    if (is.def(tdf.c[i].z)) st += tdf.c[i].z == "" || tdd.d[j][tdi[tdf.c[i].z]] != 0 ? " readonly" : "";
                    st += c(tdf.h[tdi[tdf.c[i].i]].c);
                    st += ' value="' + k + '">';
                    break;
                case 2:
                    st += '<td align=center><input onfocus="moveCell(this.parentNode)" type=checkbox';
                    if (tdf.c[i].n) st += " name=" + tdf.c[i].n;
                    if (is.def(tdf.c[i].z)) st += tdf.c[i].z == "" || tdd.d[j][tdi[tdf.c[i].z]] != 0 ? " disabled" : "";
                    if (tdf.c[i].c && tdd.d[j][tdi[tdf.c[i].c]] != 0) st += " checked";
                    st += ' value="' + k + '">';
                    break;
                case 4:
                    st += "<input type=hidden name=" + tdf.c[i].n + ' value="' + k + '">';
                    break;
                default:
                    st += "<td align=" + _al[tdf.c[i].a];
                    st += c(tdf.h[tdi[tdf.c[i].i]].c);
                    if (tdf.c[i].w) st += " nowrap";
                    st += ">";
                    if (k == "") st += "&nbsp;";
                    else st += k;
            }
        }
        if (obj) {
            constGrid += st;
        } else {
            _.write(st);
        }
        st = ""
    }
    if (tdd.d.length == 0) {
        k = tdf.c.length + (!is.hasFlag(tdf.f, 4) ? 1 : 0) + (is.hasFlag(tdf.f, 1) ? 1 : 0);
        st += "<tr class=cellEven><td colspan=" + k + " align=center>" + _tblNoData[_tblLang];
    }
    st += "</table></form>";
    if (!obj) st += "</div>";
    if (tdf.t && !obj) {
        st += '<fieldset style="clear:left" ><form name=footForm><table width=100% border=0>';
        for (var i = 0; i < tdf.t.length; i++) {
            st += "<tr>";
            for (var j = 0; j < tdf.t[i].length; j++) {
                st += '<th style="width:1%;text-align:right;"';
                if (tdf.t[i][j].r) st += " rowspan=" + tdf.t[i][j].r;
                var l = tdf.h[tdi[tdf.t[i][j].i]].l;
                /* agar footerda textni wrap qilish kerak bo`lsa "^" belgisidan keyin wrap bo`ladi
                 */
                st += " >" + (is.def(l) ? l.replace(/ /g, "&nbsp;").replace(/\^/g, " ") + ":" : "") + "<td";
                if (tdf.t[i][j].r) st += " rowspan=" + tdf.t[i][j].r;
                if (tdf.t[i][j].c) st += " colspan=" + tdf.t[i][j].c;
                st += ">";
                if (is.undef(tdf.t[i][j].a)) tdf.t[i][j].a = 1;
                var x = tdf.t[i][j].x;
                switch (tdf.t[i][j].t) {
                    case 1:
                        st += "<textarea ondblclick='footFormShow(this, true);' tabindex=-1 readonly name=a" + tdf.t[i][j].i;
                        if (tdf.t[i][j].y) st += " rows=" + tdf.t[i][j].y;
                        if (x) {
                            if (x.indexOf("%") >= 0) st += ' style="width:' + x + '"';
                            else st += " cols=" + x;
                        }
                        st += ' style="text-align:' + _al[tdf.t[i][j].a] + '"></textarea>';
                        break;
                    case 0:
                    default:
                        st += "<input ondblclick='footFormShow(this);' tabindex=-1 readonly name=a" + tdf.t[i][j].i;
                        if (x) {
                            if (x.indexOf("%") >= 0) st += ' style="width:' + x + '"';
                            else st += " size=" + x;
                        }
                        st += ' style="text-align:' + _al[tdf.t[i][j].a] + '">';
                }
            }
        }
        st += "</table></form></fieldset>";
    }
    if (obj) {
        getDOM("basepanel").innerHTML = constGrid + st;
        initDOM(getDOM("base"));
        ajaxGrid();
        if (typeof onLoad == "function")
            onLoad();
        if (typeof onRowChange == "function" && dataExist())
            onRowChange();
        if (typeof onSelect == "function" && dataExist())
            onSelect();
    } else {
        _.write(st);
    }
    if (autoRefresh == "Y") {
        constTimeout = setTimeout(getAjaxTDD, constTime);
    }
})();

function getData(i) {
    return tdd.d[_oc_.parentNode.sectionRowIndex][tdi[i]];
}

function dataExist() {
    if (tdd.d.length > 0) return true;
    return false
}

function goPage(v) {
    if (tdd.p) {
        try {
            top._t()["RS" + _.URL.split("?")[0]] = null;
        } catch (e) {
            window["RS" + _.URL.split("?")[0]] = null;
        }
        switch (v) {
            case "first":
                if (tdd.p.PN > 1) getAjaxTDD(1);
                /*go({param: {page: 1}});*/
                break;
            case "prev":
                if (tdd.p.PN > 1) getAjaxTDD(tdd.p.PN - 1);
                /*go({param: {page: tdd.p.PN - 1}});*/
                break;
            case "succ":
                if (tdd.p.PN < tdd.p.MP) getAjaxTDD(tdd.p.PN + 1);
                /*go({param: {page: tdd.p.PN + 1}});*/
                break;
            case "last":
                if (tdd.p.PN < tdd.p.MP) getAjaxTDD(tdd.p.MP);
                /*go({param: {page: tdd.p.MP}});*/
                break;
            default:
                if (v < 1) v = 1;
                if (v > tdd.p.MP) v = tdd.p.MP;
                getAjaxTDD(v);
            /*go({param: {page: v}});*/
        }
    }
}

function moveCell(cell) {

    if (dataExist()) {
        if (_oc_ == null) _oc_ = cell;
        var row = ((_oc_.parentElement == null) ? cell.parentElement : _oc_.parentElement)
            , nc = _oc_.firstChild
            , row2 = cell.parentElement
            , oc;
        if (nc.stopMoving && event.type != "click") return;
        _oc_.className = "";
        row.className = row.sectionRowIndex % 2 ? "cellOdd" : "cellEven";
        row2.className = "cellSel";
        cell.className = "cellCur";
        if (!is.hasFlag(tdf.f, 4)) {
            row.cells[0].innerHTML = "&nbsp;";
            row2.cells[0].innerHTML = '<span style="font-family:webdings;">4</span>';
        }
        if (cell.offsetTop < basepanel.scrollTop + tbl.tHead.offsetHeight) basepanel.scrollTop = cell.offsetTop - tbl.tHead.offsetHeight;
        if (cell.offsetTop + cell.offsetHeight > basepanel.offsetHeight + basepanel.scrollTop) basepanel.scrollTop = cell.offsetTop + cell.offsetHeight - basepanel.offsetHeight;
        oc = _oc_;
        _oc_ = cell;
        nc = cell.firstChild;
        if (nc.tagName == "INPUT" && nc.type == "text") nc.focus();
        else cell.focus();
        if (tdf.t) {
            for (var i = 0; i < tdf.t.length; i++)
                for (var j = 0; j < tdf.t[i].length; j++) _.footForm["a" + tdf.t[i][j].i].value = replaceQGH(getData(tdf.t[i][j].i));
        }
        try {
            top._t()["RS" + _.URL.split("?")[0]] = [_oc_.parentNode.sectionRowIndex, _oc_.cellIndex, basepanel.scrollTop];
        } catch (e) {
            window["RS" + _.URL.split("?")[0]] = [_oc_.parentNode.sectionRowIndex, _oc_.cellIndex, basepanel.scrollTop];
        }
        /* function onSelect(currentCell)
         * currentCell cursor ustida turgan katak
         * cursor o`zgarganda chaqiriladi
         */
        if (typeof onSelect == "function" && dataExist()) onSelect(cell, oc);
        if (is.def(event)) {
            if (event.type == "load" && typeof (onRowChange) == "function")
                onRowChange();
        }
        if ((row != row2 && dataExist()) && typeof (onRowChange) == "function") {
            _lastTime = (new Date()).getTime();
            setTimeout("if((new Date()).getTime()-_lastTime >= 10)onRowChange()", 10);
        }
    }
}

if (_.URL.indexOf("?reference") > 0) {
    window.onAction = function () {
        top.returnValue = tdd.d[_oc_.parentNode.sectionRowIndex];
        top.close();
    };
    window.onKeyEvent = function () {
        if (event.keyCode == 27) {
            window.returnValue = null;
            close();
            return;
        }
        for (var i = 0; i < tdf.h.length; i++) {
            var e = getDOM("f" + tdf.h[i].i);
            if (e) {
                e.focus();
                return;
            }
        }
    }
}
window.funcLoad.push(ajaxGrid = function () {
    tbl.onclick = tbl.ondblclick = function () {
        var o = event.srcElement
            , nc;
        if (o.tagName == "TD") nc = o;
        else if (o.parentNode.tagName == "TD") nc = o.parentNode;
        if (nc) {
            moveCell(nc);
            /* function onAction(currentCell)
             * currentCell cursor ustida turgan katak
             * enter tugmasi bosilganda yoki, double click bo`lganda chaqiriladi
             */
            if (event.type == "dblclick" && typeof onAction == "function" && dataExist()) onAction(_oc_)
        }
    };
    tbl.onkeydown = function () {
        if (!dataExist()) return false;
        var e = event.srcElement;

        function w(d, e) {
            var r = _oc_.parentNode.sectionRowIndex
                , c = _oc_.cellIndex
                , rl = tbl.tBodies[0].rows.length
                , cl = tbl.rows[0].cells.length
                , s = 0;

            function rd(d) {
                r += d;
                s++;
                if (r < 0) {
                    r = 0;
                    if (e) {
                        r = rl - 1;
                        if (s < 2) cd(-1);
                    }
                }
                if (r >= rl) {
                    r = rl - 1;
                    if (e) {
                        r = 0;
                        if (s < 2) cd(1);
                    }
                }
            }

            function cd(d) {
                c += d;
                s++;
                if (c < tbl.cl) {
                    c = tbl.cl;
                    if (e) {
                        c = cl - 1;
                        if (s < 2) rd(-1);
                    }
                }
                if (c >= cl) {
                    c = cl - 1;
                    if (e) {
                        c = tbl.cl;
                        if (s < 2) rd(1);
                    }
                }
            }

            if (d == "up") rd(-1);
            else if (d == "down") rd(1);
            else if (d == "left") cd(-1);
            else if (d == "right") cd(1);
            return tbl.tBodies[0].rows[r].cells[c];
        }

        switch (event.keyCode) {
            case 33:
                goPage("prev");
                break;
            case 34:
                goPage("succ");
                break;
            case 35:
                goPage("last");
                break;
            case 36:
                goPage("first");
                break;
            case 37:
                moveCell(w("left"));
                break;
            case 38:
                moveCell(w("up"));
                break;
            case 39:
                moveCell(w("right"));
                break;
            case 40:
                moveCell(w("down"));
                break;
            case 32:
                if (e.tagName == "TD") e = e.firstChild;
                if (e.tagName == "INPUT") {
                    if (e.type == "checkbox" && !e.disabled) e.checked = !e.checked;
                    if (e.type == "text") return true;
                }
                break;
            case 9:
                if (event.shiftKey) moveCell(w("left", 1));
                else moveCell(w("right", 1));
                break;
            case 13:
                if (tdf.e) {
                    var _a = ["up", "right", "down", "left"];
                    moveCell(w(_a[(event.shiftKey ? (tdf.e + 2) % 4 : tdf.e)], 1));
                } else if (typeof onAction == "function" && dataExist()) onAction(_oc_);
                break;
            case 119:
                submitVAR("", 0);
                break;
            case 113:
                if (e.tagName == "TD") e = e.firstChild;
                if (e.tagName == "INPUT" && e.type == "text") e.editing = true;
                break;
            default:
                /* nc.checked = ! nc.checked; */
                /* function onKeyEvent(currentCell)
                 * currentCell cursor ustida turgan katak
                 * klavish bosilgada chaqiriladi
                 */
                if (typeof onKeyEvent == "function") onKeyEvent();
                return true;
        }
        event.returnValue = false;
    };
    if (!basepanel) basepanel = getDOM("basepanel");
    if (!tbl) tbl = getDOM("tbl");
    tbl.cl = parseInt(tbl.cl);
    var c;
    // = [0, tbl.cl, 0];
    if (tdd.w) {
        for (var k in tdd.w) {
            c = getDOM(k);
            if (c) c.value = tdd.w[k][0];
        }
    }
    var kw = []
        , sum = 0
        , w2;
    for (var i = tbl.cl; i < tbl.tHead.rows[0].cells.length; i++) {
        w2 = tbl.tHead.rows[0].cells[i].clientWidth;
        if (is.def(tdf.c[i - tbl.cl].t)) w2 = 0;
        kw.push(w2);
        sum += w2;
    }
    for (var i = tbl.cl; i < tbl.tHead.rows[0].cells.length; i++) {
        if (is.undef(tdf.c[i - tbl.cl].t)) {
            tbl.tHead.rows[0].cells[i].width = Math.round(kw[i - tbl.cl] * 100 / sum) + "%";
        }
    }
    if (!is.hasFlag(tdf.f, 2)) {
        tbl.focus();
        if (dataExist()) {
            try {
                var c = top._t()["RS" + _.URL.split("?")[0]];
            } catch (e) {
                var c = window["RS" + _.URL.split("?")[0]];
            }
            if (!is.array(c) || is.hasFlag(tdf.f, 128)) c = [0, 0, 0];
            var k = tbl.tBodies[0].rows;
            c[0] = c[0] >= k.length ? k.length - 1 : c[0];
            c[1] = c[1] > k[0].cells.length ? k[0].cells.length - 1 : c[1];
            c[1] = c[1] < tbl.cl ? tbl.cl : c[1];
            _oc_ = k[c[0]].cells[c[1]];
            basepanel.scrollTop = c[2];
            moveCell(_oc_);
        }
    }
    _.onkeyup = (function (e) {
        var e = window.event || e;
        var unicode = e.keyCode ? e.keyCode : e.charCode;
        if (!is.hasFlag(tdf.f, 64) && is.hasFlag(tdd.f, 1)) {
            if (e.altKey && unicode == "70") { //HOTKEY alt + f
                showFilter();
            }
        }
        if (!is.hasFlag(tdf.f, 16)) {
            if (e.altKey && unicode == "82") { //HOTKEY alt + r
                getAjaxTDD();
            }
            if (e.altKey && unicode == "80") { //HOTKEY alt + p
                if (autoRefresh == "N") {
                    autoRefresh = "Y";
                } else {
                    autoRefresh = "N";
                }
                getAjaxTDD();
            }
        }
        if (is.hasFlag(tdf.f, 32)) {
            if (e.ctrlKey && e.altKey && unicode == "69") { //HOTKEY ctrl + alt + r
                go({param: {_recreateValue: 1}});
            }
        }
        if (!is.hasFlag(tdf.f, 256)) {
            if (e.altKey && unicode == "69") { //HOTKEY alt + e
                exportFormPreview();
            }
        }
    });
});

function exportFormPreview() {
    var u = nocacheURL(nvl(__contextPath, "") + "/exporthelperconf.jsp");
    go({
        url: u
        , param: {
            SN: tdd.SN
        }
        , target: '_blank'
        , dialogHeight: 200
        , dialogWidth: 200
        , lock: false
    });
}

function getAjaxTDD(PN) {
    clearTimeout(constTimeout);
    /*if(jsSearch != "") {
        ajaxTable(tdd); jsSearch = "";
        return;
    }*/

    if (!PN) PN = (is.def(tdd.p)) ? tdd.p.PN : 0;
    AJAX.load({
        url: nocacheURL(nvl(__contextPath, "") + "/ajaxhelper.jsp")
        , POST: {
            PN: PN
            , SN: tdd.SN
        }
        , async: true
        , onSuccess: function (d) {
            //var day = new Date(); console.log(day.toString()+" "+d);
            ajaxTable(d);
        }
    });
}

function defPosition(event) {
    var x = y = 0;
    if (document.attachEvent != null) { // Internet Explorer & Opera
        x = window.event.clientX + (document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft);
        y = window.event.clientY + (document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop);
    } else if (!document.attachEvent && document.addEventListener) { // Gecko
        x = event.clientX + window.scrollX;
        y = event.clientY + window.scrollY;
    } else {
        // Do nothing
    }
    return {
        x: x
        , y: y
    };
}

function footFormShow(obj, show) {
    if (show || obj.value != "" && obj.offsetWidth - (obj.value.length * 8) < -16) {
        go({
            url: nvl(__contextPath, "") + "/foothelper.jsp",
            param: {foot_form_text: encodeURIComponent(obj.value)},
            target: "modalE",
            dialogWidth: 800,
            dialogHeight: 250
        });
    }
}

function menu(event) {
    /* Блокируем всплывание события contextmenu */
    event = event || window.event;
    event.cancelBubble = true;
    /* Показываем собственное контекстное меню */
    var html = "", tdAll = ""
        , menu = getDOM("contextMenuId")
        , symStop = "&#8709;"
        , symStart = "&#8635;"
        , symSelect = "&#9656;"
        , divNo = "<div style='width:25px;float:left;'>&nbsp;</div>"
        ,
        divStop = "<div style='width:25px;text-align:center;color:#990000;background:#EDF2F7;font-weight:bold;float:left;'>" + symStop + "</div><b>"
        ,
        divStart = "<div style='width:25px;text-align:center;color:#009900;background:#EDF2F7;font-weight:bold;float:left;'>" + symStart + "</div><b>"
        ,
        divSeconds = "<div style='width:25px;text-align:center;color:#000099;background:#EDF2F7;border:1px solid #AECFF7;font-weight:bold;float:left;'>" + symSelect + "</div>";
    tdAll += " style='cursor:hand;border:1px solid transparent'";
    tdAll += " onmouseout=\"this.style.backgroundColor='#F2F2F2';this.style.border='1px solid transparent';\"";
    tdAll += " onmouseover=\"this.style.backgroundColor='#EDF2F7';this.style.border='1px solid #AECFF7';\" ";
    html += "<table style='width:100px;' cellpadding='0' cellspacing='0' >";
    html += "<tr><td onclick='constTime=5000;'" + tdAll + " >" + ((constTime == 5000) ? divSeconds : divNo) + "5 " + _tblSeconds[_tblLang];
    html += "<tr><td onclick='constTime=10000;'" + tdAll + ">" + ((constTime == 10000) ? divSeconds : divNo) + "10";
    html += "<tr><td onclick='constTime=15000;'" + tdAll + ">" + ((constTime == 15000) ? divSeconds : divNo) + "15";
    html += "<tr><td onclick='constTime=20000;'" + tdAll + ">" + ((constTime == 20000) ? divSeconds : divNo) + "20";
    html += "<tr><td onclick='constTime=25000;'" + tdAll + ">" + ((constTime == 25000) ? divSeconds : divNo) + "25";
    html += "<tr><td onclick='constTime=30000;'" + tdAll + ">" + ((constTime == 30000) ? divSeconds : divNo) + "30";
    html += "<tr><td onclick='constTime=45000;'" + tdAll + ">" + ((constTime == 45000) ? divSeconds : divNo) + "45";
    html += "<tr><td onclick='constTime=60000;'" + tdAll + ">" + ((constTime == 60000) ? divSeconds : divNo) + "60";
    html += "<tr><td style='height:1px;font-size:1px;' ><hr/>";
    html += "<tr><td onclick=\"autoRefresh='Y';getAjaxTDD();\"" + tdAll + ">" + ((autoRefresh == "Y") ? divStart : divNo) + _tblStart[_tblLang];
    html += "<tr><td onclick=\"autoRefresh='N';getAjaxTDD();\"" + tdAll + ">" + ((autoRefresh == "N") ? divStop : divNo) + _tblStop[_tblLang];
    html += "</table>";
    /* Если есть что показать - показываем */
    if (html) {
        menu.innerHTML = html;
        menu.style.top = defPosition(event).y + "px";
        menu.style.left = (defPosition(event).x - 50) + "px";
        menu.style.display = "";
    }
    /* Блокируем всплывание стандартного браузерного меню */
    return false;
}

/* Закрываем контекстное при клике левой или правой кнопкой по документу
 * Функция для добавления обработчиков событий
 */
function addHandler(object, event, handler, useCapture) {
    if (object.addEventListener) {
        object.addEventListener(event, handler, useCapture ? useCapture : false);
    } else if (object.attachEvent) {
        object.attachEvent('on' + event, handler);
    } else alert("Add handler is not supported");
}

addHandler(document, "contextmenu", function () {
    if (!is.hasFlag(tdf.f, 16)) {
        getDOM("contextMenuId").style.display = "none";
    }
});
addHandler(document, "click", function () {
    if (!is.hasFlag(tdf.f, 16)) {
        getDOM("contextMenuId").style.display = "none";
    }
});