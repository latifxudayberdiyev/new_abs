<%@ page pageEncoding="WINDOWS-1251" %>
<div class="tabpane" id="paneValidates" style="display:none">
    <div class="hint"><%=lang.get(si_select_action)%></div>
</div>

<script>
    var SI_VALIDATES     = "<%=lang.get(si_validates)%>";
    var SI_VALIDATE      = "<%=lang.get(si_validate)%>";
    var SI_ADD_AV        = "<%=lang.get(si_add_av)%>";
    var SI_NO_VALIDATES  = "<%=lang.get(si_no_validates)%>";
    var SI_CONFIRM_DEL_AV= "<%=lang.get(si_confirm_del_av)%>";
    var SI_AV_CODE       = "<%=lang.get(si_av_code)%>";
    var SI_AV_NAME       = "<%=lang.get(si_av_name)%>";
    var SI_AV_FUNCTION   = "<%=lang.get(si_av_function)%>";
    var SI_AV_VALUE_CHK  = "<%=lang.get(si_av_value_chk)%>";
    var SI_AV_SORT       = "<%=lang.get(si_av_sort)%>";
    var SI_CHOOSE_FUNC   = "<%=lang.get(si_choose_func)%>";
    var SI_BY_LIST       = "<%=lang.get(si_by_list)%>";
    var SI_MEMBERS       = "<%=lang.get(si_members)%>";
    var SI_AV_NEED_CODE  = "<%=lang.get(si_av_need_code)%>";
    var SI_AV_NEED_NAME  = "<%=lang.get(si_av_need_name)%>";
    var SI_AV_NEED_SORT  = "<%=lang.get(si_av_need_sort)%>";
    var SI_AV_NEED_FUNC  = "<%=lang.get(si_av_need_func)%>";
    var SI_MB_TITLE      = "<%=lang.get(si_mb_title)%>";
    var SI_MB_ADD        = "<%=lang.get(si_mb_add)%>";
    var SI_MB_CODE       = "<%=lang.get(si_mb_code)%>";
    var SI_MB_NAME       = "<%=lang.get(si_mb_name)%>";
    var SI_MB_SORT       = "<%=lang.get(si_mb_sort)%>";
    var SI_MB_NEED_CODE  = "<%=lang.get(si_mb_need_code)%>";
    var SI_MB_NEED_NAME  = "<%=lang.get(si_mb_need_name)%>";
    var SI_MB_NEED_SORT  = "<%=lang.get(si_mb_need_sort)%>";
    var SI_MB_CONFIRM    = "<%=lang.get(si_mb_confirm_del)%>";

    var ICO_SAVE =
        '<svg viewBox="0 0 16 16" width="13" height="13" fill="currentColor">' +
        '<path d="M13.5 2H3a1 1 0 0 0-1 1v10a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V3.5L13.5 2zM5 3h5v3H5V3zm6 10H5V9h6v4z"/>' +
        '</svg>';

    var avRows = [];
    /* Qiymatlar javobi index'siz keladi - qaysi tekshiruv so'raganini eslab qolamiz */
    var mbLoadingIdx = null;

    function loadActionValidates() {
        if (!selectedActionId) return;
        document.getElementById("paneValidates").innerHTML =
            '<div class="hint">' + SI_LOADING + '</div>';
        document.getElementById("av_action_id").value = selectedActionId;
        document.getElementById("avForm").submit();
    }

    /* Funksiya selecti: REF_VALIDATORS sahifa ochilganda yuklanadi */
    function funcSelect(nm, val) {
        var h = '<select name="' + nm + '"><option value="">' + SI_CHOOSE_FUNC + '</option>';
        for (var i = 0; i < REF_VALIDATORS.length; i++) {
            var f = REF_VALIDATORS[i];
            h += '<option value="' + esc(f.function_id) + '"' +
                 (String(f.function_id) === String(val) ? ' selected' : '') + '>' +
                 esc(f.function_desc ? f.function_desc : f.function_name) + '</option>';
        }
        return h + '</select>';
    }

    function buildAvForm(r, i) {
        var h = '<div class="fgrid">';
        h += fld(SI_AV_CODE, txt("av_code_" + i, r.code));
        h += fld(SI_AV_NAME, txt("av_name_" + i, r.name));
        h += fld(SI_AV_FUNCTION, funcSelect("av_function_id_" + i, r.function_id), "wide");
        h += fld(SI_AV_VALUE_CHK, valueChkSelect("av_is_value_check_" + i, r.is_value_check, i), "narrow");
        h += fld(SI_AV_SORT, txt("av_sort_ord_" + i, r.sort_ord), "narrow");
        h += fld(SI_STATE, stateSelect("av_state_" + i, r.state), "narrow");
        h += '</div>';
        h += '<div class="pt-foot">' +
             '<button type="button" class="btn-pri" onclick="saveAv(' + i + ');">' +
             SI_SAVE + '</button></div>';
        /* Qiymatlar bloki har doim quriladi, lekin "Ha" tanlanmaguncha yashirin.
           Saqlanmagan qatorda action_validate_id yo'q - qiymatni bog'lab bo'lmaydi. */
        if (r.action_validate_id) {
            h += '<div class="mem" id="avm' + i + '"' +
                 (r.is_value_check === "Y" ? '' : ' style="display:none"') + '>' +
                 '<div class="mem-hint">' + SI_LOADING + '</div></div>';
        }
        return h;
    }

    /* ---------- qiymatlar (osm_r_action_validate_members) ---------- */

    /* ynSelect umumiy yordamchi, unga onchange qo'shib bo'lmaydi - shu maydon uchun
       alohida select: "Ha" tanlanganda qiymatlar bloki darrov ochilishi kerak. */
    function valueChkSelect(nm, val, i) {
        return '<select name="' + nm + '" onchange="onValueChkChange(' + i + ', this);">' +
               '<option value="Y"' + (val !== "N" ? ' selected' : '') + '>' + SI_YES + '</option>' +
               '<option value="N"' + (val === "N" ? ' selected' : '') + '>' + SI_NO  + '</option>' +
               '</select>';
    }

    function onValueChkChange(i, sel) {
        var box = document.getElementById("avm" + i);
        if (!box) return;
        if (sel.value !== "Y") {
            box.style.display = "none";
            return;
        }
        box.style.display = "";
        if (avRows[i].members) renderMembers(i);
        else loadMembers(i);
    }

    function loadMembers(i) {
        mbLoadingIdx = i;
        document.getElementById("mb_action_validate_id").value = avRows[i].action_validate_id;
        document.getElementById("mbForm").submit();
    }

    function onMembersLoaded(model) {
        if (mbLoadingIdx === null) return;
        avRows[mbLoadingIdx].members = (model && model.list) ? model.list : [];
        renderMembers(mbLoadingIdx);
    }

    function renderMembers(i) {
        var box = document.getElementById("avm" + i);
        if (!box) return;
        var rows = avRows[i].members || [];

        /* Qo'shish tugmasi sarlavhada emas, ro'yxat o'rnida - dumaloq "+" */
        var addBtn = '<div class="mem-addwrap">' +
                     '<button type="button" class="mem-add" title="' + SI_MB_ADD + '"' +
                     ' onclick="addMb(' + i + ');">+</button></div>';

        var h = '<div class="mem-head">' +
                '<span class="mem-title">' + SI_MB_TITLE + '</span></div>';

        if (!rows.length) {
            box.innerHTML = h + addBtn;
            return;
        }

        h += '<table class="memt"><thead><tr>' +
             '<th>' + SI_MB_CODE + '</th>' +
             '<th>' + SI_MB_NAME + '</th>' +
             '<th>' + SI_MB_SORT + '</th>' +
             '<th>' + SI_STATE   + '</th>' +
             '<th class="mem-act"></th>' +
             '</tr></thead><tbody>';
        for (var j = 0; j < rows.length; j++) {
            var m = rows[j];
            h += '<tr>' +
                 '<td><input type="text" name="mb_code_' + i + '_' + j + '" value="' + esc(m.member_code) + '"></td>' +
                 '<td><input type="text" name="mb_name_' + i + '_' + j + '" value="' + esc(m.name)        + '"></td>' +
                 '<td><input type="text" name="mb_sort_' + i + '_' + j + '" value="' + esc(m.sort_ord)    + '"></td>' +
                 '<td>' + stateSelect("mb_state_" + i + "_" + j, m.state) + '</td>' +
                 '<td class="mem-act">' +
                 '<span class="ico" title="' + SI_SAVE + '" onclick="saveMb(' + i + ',' + j + ');">' + ICO_SAVE + '</span>' +
                 '<span class="ico del" title="' + SI_DELETE + '" onclick="delMb(' + i + ',' + j + ');">' + ICO_TRASH + '</span>' +
                 '</td></tr>';
        }
        h += '</tbody></table>';
        box.innerHTML = h + addBtn;
    }

    function addMb(i) {
        if (!avRows[i].members) avRows[i].members = [];
        var rows = avRows[i].members;
        var next = 1;
        for (var j = 0; j < rows.length; j++) {
            var s = parseInt(rows[j].sort_ord, 10);
            if (!isNaN(s) && s >= next) next = s + 1;
        }
        rows.push({ member_code: "", name: "", sort_ord: next, state: "A" });
        renderMembers(i);
    }

    function mv(i, j, nm) {
        var el = document.getElementsByName("mb_" + nm + "_" + i + "_" + j)[0];
        return el ? el.value.replace(/^\s+|\s+$/g, "") : "";
    }

    function saveMb(i, j) {
        if (!mv(i, j, "code")) { alert(SI_MB_NEED_CODE); return; }
        if (!mv(i, j, "name")) { alert(SI_MB_NEED_NAME); return; }
        if (!mv(i, j, "sort")) { alert(SI_MB_NEED_SORT); return; }

        mbLoadingIdx = i;
        var f = document.getElementById("mbSaveForm");
        f.elements["member_id"].value          = avRows[i].members[j].member_id || "";
        f.elements["action_validate_id"].value = avRows[i].action_validate_id;
        f.elements["member_code"].value        = mv(i, j, "code");
        f.elements["name"].value               = mv(i, j, "name");
        f.elements["sort_ord"].value           = mv(i, j, "sort");
        f.elements["state"].value              = mv(i, j, "state");
        f.submit();
    }

    function delMb(i, j) {
        /* hali saqlanmagan qator - shunchaki ro'yxatdan olib tashlaymiz */
        if (!avRows[i].members[j].member_id) {
            avRows[i].members.splice(j, 1);
            renderMembers(i);
            return;
        }
        if (!confirm(SI_MB_CONFIRM)) return;
        mbLoadingIdx = i;
        document.getElementById("mb_del_member_id").value = avRows[i].members[j].member_id;
        document.getElementById("mbDelForm").submit();
    }

    function onMbSaved(ok, msg) {
        if (!ok) { alert(msg); return; }
        if (msg) alert(msg);
        if (mbLoadingIdx !== null) loadMembers(mbLoadingIdx);
    }

    function onActionValidatesLoaded(model) {
        var box = document.getElementById("paneValidates");
        avRows  = (model && model.list) ? model.list : [];

        if (!model) {
            box.innerHTML = '<div class="hint">' + SI_NO_DATA + '</div>';
            return;
        }

        var html = '<div class="cards">';
        html += '<div class="pane-head" style="border:0;background:none;padding:2px 2px 8px">' +
                '<span class="pane-title">' + SI_VALIDATES + ' &mdash; ' + avRows.length + '</span>' +
                '<span><input type="button" onclick="addAv();" value="' + SI_ADD_AV + '"></span>' +
                '</div>';

        if (!avRows.length) {
            html += '<div class="hint">' + SI_NO_VALIDATES + '</div>';
        }

        for (var i = 0; i < avRows.length; i++) {
            var r     = avRows[i];
            var isAct = (r.state === "A");
            var byLst = (r.is_value_check === "Y");
            var mc    = r.member_count ? r.member_count : 0;
            var sub   = byLst
                      ? SI_BY_LIST + (mc > 0 ? " (" + mc + ")" : "")
                      : (r.function_desc ? r.function_desc
                                         : (r.function_name ? r.function_name : "&mdash;"));

            html += '<div class="pt" id="av' + i + '">';
            html += '<div class="pt-head" onclick="toggleAv(' + i + ');">' +
                    '<span class="pt-idx">' + esc(r.sort_ord) + '</span>' +
                    '<span class="pt-caret">&#9656;</span>' +
                    '<span class="pt-name">' + esc(r.code) + '</span>' +
                    '<span class="pt-sub">' + esc(r.name) + ' &middot; ' + sub + '</span>' +
                    (byLst && mc > 0 ? pill(mc + " " + SI_MEMBERS, "#e8f0fe", "#1a56db") : "") +
                    pill(isAct ? SI_ACTIVE : SI_PASSIVE,
                         isAct ? "#e0f2ea" : "#eef1f5",
                         isAct ? "#1a7f5a" : "#667085") +
                    '<span class="pt-tools">' +
                    '<span class="ico del" title="' + SI_DELETE + '"' +
                    ' onclick="event.stopPropagation();delAv(' + i + ');">' + ICO_TRASH + '</span>' +
                    '</span></div>';
            html += '<div class="pt-body" id="avb' + i + '"></div>';
            html += '</div>';
        }
        html += '</div>';
        box.innerHTML = html;
    }

    function toggleAv(i) {
        var box  = document.getElementById("av" + i);
        var body = document.getElementById("avb" + i);
        if (box.className.indexOf("open") >= 0) {
            box.className = "pt";
            return;
        }
        if (!body.innerHTML) {
            body.innerHTML = buildAvForm(avRows[i], i);
            /* Ro'yxat faqat blok ko'rinadigan bo'lsa yuklanadi */
            if (document.getElementById("avm" + i) && avRows[i].is_value_check === "Y") {
                loadMembers(i);
            }
        }
        box.className = "pt open";
    }

    function addAv() {
        var next = 1;
        for (var i = 0; i < avRows.length; i++) {
            if (Number(avRows[i].sort_ord) >= next) next = Number(avRows[i].sort_ord) + 1;
        }
        avRows.push({ sort_ord: next, state: "A", is_value_check: "N",
                      code: "", name: "", member_count: 0 });
        onActionValidatesLoaded({ list: avRows });
        toggleAv(avRows.length - 1);
    }

    function vv(i, nm) {
        var el = document.getElementsByName("av_" + nm + "_" + i)[0];
        return el ? el.value : "";
    }

    function saveAv(i) {
        if (!vv(i, "code"))     { alert(SI_AV_NEED_CODE); return; }
        if (!vv(i, "name"))     { alert(SI_AV_NEED_NAME); return; }
        if (!vv(i, "sort_ord")) { alert(SI_AV_NEED_SORT); return; }
        /* C3 qoidasi: qiymatlar ro'yxati bo'yicha tekshirilmasa, funksiya majburiy */
        if (vv(i, "is_value_check") === "N" && !vv(i, "function_id")) {
            alert(SI_AV_NEED_FUNC); return;
        }

        var f = document.getElementById("avSaveForm");
        f.elements["action_validate_id"].value = avRows[i].action_validate_id || "";
        f.elements["action_id"].value          = selectedActionId;
        f.elements["code"].value               = vv(i, "code");
        f.elements["name"].value               = vv(i, "name");
        f.elements["function_id"].value        = vv(i, "function_id");
        f.elements["is_value_check"].value     = vv(i, "is_value_check");
        f.elements["sort_ord"].value           = vv(i, "sort_ord");
        f.elements["state"].value              = vv(i, "state");
        f.submit();
    }

    function delAv(i) {
        /* hali saqlanmagan qator - shunchaki ro'yxatdan olib tashlaymiz */
        if (!avRows[i].action_validate_id) {
            avRows.splice(i, 1);
            onActionValidatesLoaded({ list: avRows });
            return;
        }
        if (!confirm(SI_CONFIRM_DEL_AV)) return;
        var f = document.getElementById("avDelForm");
        f.elements["action_validate_id"].value = avRows[i].action_validate_id;
        f.submit();
    }

    function onAvSaved(ok, msg) {
        if (!ok) { alert(msg); return; }
        if (msg) alert(msg);
        loadActionValidates();
    }
</script>
<%!
    static final int si_validates =
            SI("Проверки", "Текширувлар", "Tekshiruvlar", "Validations");

    static final int si_validate =
            SI("Проверка", "Текширув", "Tekshiruv", "Validation");

    static final int si_add_av =
            SI("+ Добавить проверку", "+ Текширув кушиш", "+ Tekshiruv qo'shish", "+ Add validation");

    static final int si_no_validates =
            SI("Проверки не заданы", "Текширувлар белгиланмаган", "Tekshiruvlar belgilanmagan",
               "No validations defined");

    static final int si_confirm_del_av =
            SI("Удалить проверку?", "Текширув учирилсинми?", "Tekshiruv o'chirilsinmi?",
               "Delete the validation?");

    static final int si_av_code =
            SI("Код проверки", "Текширув коди", "Tekshiruv kodi", "Validation code");

    static final int si_av_name =
            SI("Наименование", "Номланиши", "Nomlanishi", "Name");

    static final int si_av_function =
            SI("Функция проверки", "Текширув функцияси", "Tekshiruv funksiyasi", "Validation function");

    static final int si_av_value_chk =
            SI("По списку значений", "Кийматлар руйхати буйича", "Qiymatlar ro'yxati bo'yicha",
               "By value list");

    static final int si_av_sort =
            SI("Порядок", "Тартиб", "Tartib", "Order");

    static final int si_choose_func =
            SI("— Выбрать функцию —", "— Функцияни танланг —", "— Funksiyani tanlang —",
               "— Select function —");

    static final int si_by_list =
            SI("по списку значений", "кийматлар руйхати буйича", "qiymatlar ro'yxati bo'yicha",
               "by value list");

    static final int si_members =
            SI("знач.", "кийм.", "qiym.", "val.");

    static final int si_av_need_code =
            SI("Укажите код проверки", "Текширув кодини курсатинг", "Tekshiruv kodini ko'rsating",
               "Specify the validation code");

    static final int si_av_need_name =
            SI("Укажите наименование", "Номланишини курсатинг", "Nomlanishini ko'rsating",
               "Specify the name");

    static final int si_av_need_sort =
            SI("Укажите порядок", "Тартибни курсатинг", "Tartibni ko'rsating", "Specify the order");

    static final int si_av_need_func =
            SI("Без списка значений функция обязательна",
               "Кийматлар руйхатисиз функция мажбурий",
               "Qiymatlar ro'yxatisiz funksiya majburiy",
               "Function is required unless checking by value list");

    static final int si_mb_title =
            SI("Значения", "Кийматлар", "Qiymatlar", "Values");

    static final int si_mb_add =
            SI("Добавить", "Кўшиш", "Qo'shish", "Add");

    static final int si_mb_code =
            SI("Код", "Коди", "Kodi", "Code");

    static final int si_mb_name =
            SI("Наименование", "Номи", "Nomi", "Name");

    static final int si_mb_sort =
            SI("Порядок", "Тартиб", "Tartib", "Order");

    static final int si_mb_need_code =
            SI("Укажите код значения", "Киймат кодини киритинг", "Qiymat kodini kiriting", "Enter the value code");

    static final int si_mb_need_name =
            SI("Укажите наименование", "Номини киритинг", "Nomini kiriting", "Enter the name");

    static final int si_mb_need_sort =
            SI("Укажите порядок", "Тартибни киритинг", "Tartibni kiriting", "Enter the order");

    static final int si_mb_confirm_del =
            SI("Удалить значение?", "Киймат учирилсинми?", "Qiymat o'chirilsinmi?", "Delete the value?");
%>
