<%@ page pageEncoding="WINDOWS-1251" %>
<div class="tabpane" id="ptBody">
    <div class="hint"><%=lang.get(si_select_action)%></div>
</div>

<script>
    var SI_NO_TEMPLATE  = "<%=lang.get(si_no_template)%>";
    var SI_DT           = "<%=lang.get(si_dt)%>";
    var SI_CT           = "<%=lang.get(si_ct)%>";
    var SI_CURRENCY     = "<%=lang.get(si_currency)%>";
    var SI_SUMM         = "<%=lang.get(si_summ)%>";
    var SI_PURPOSE_CODE = "<%=lang.get(si_purpose_code)%>";
    var SI_PURPOSE      = "<%=lang.get(si_purpose)%>";
    var SI_POSTINGS     = "<%=lang.get(si_postings)%>";
    var SI_POSTING      = "<%=lang.get(si_posting)%>";
    var SI_ADD_PT       = "<%=lang.get(si_add_pt)%>";
    var SI_CHOOSE_ACC   = "<%=lang.get(si_choose_acc)%>";
    var SI_CHOOSE_METHOD= "<%=lang.get(si_choose_method)%>";
    var SI_SEC_ACC      = "<%=lang.get(si_sec_acc)%>";
    var SI_SEC_SUMM     = "<%=lang.get(si_sec_summ)%>";
    var SI_SEC_PURPOSE  = "<%=lang.get(si_sec_purpose)%>";
    var SI_SEC_OTHER    = "<%=lang.get(si_sec_other)%>";
    var SI_DT_ACC       = "<%=lang.get(si_dt_acc)%>";
    var SI_CT_ACC       = "<%=lang.get(si_ct_acc)%>";
    var SI_DT_OWN       = "<%=lang.get(si_dt_own)%>";
    var SI_CT_OWN       = "<%=lang.get(si_ct_own)%>";
    var SI_PURPOSE_CODE_GETTER = "<%=lang.get(si_purpose_code_getter)%>";
    var SI_PURPOSE_GETTER      = "<%=lang.get(si_purpose_getter)%>";
    var SI_SORT_ORD     = "<%=lang.get(si_sort_ord)%>";
    var SI_CONFIRM_DEL  = "<%=lang.get(si_confirm_del)%>";
    var SI_NEED_DT      = "<%=lang.get(si_need_dt)%>";
    var SI_NEED_CT      = "<%=lang.get(si_need_ct)%>";
    var SI_NEED_SORT    = "<%=lang.get(si_need_sort)%>";
    var SI_CONFLICT_PURPOSE = "<%=lang.get(si_conflict_purpose)%>";
    var SI_CONFLICT_CODE    = "<%=lang.get(si_conflict_code)%>";

    /* Selectlar uchun ma'lumotnomalar - sahifa ochilganda bir marta yuklanadi */
    var REF_ACCOUNTS   = [];
    var REF_GETTERS    = [];
    var REF_VALIDATORS = [];
    var ptRows         = [];

    function onRefsLoaded(model) {
        REF_ACCOUNTS   = (model && model.account_types)      ? model.account_types      : [];
        REF_GETTERS    = (model && model.getters)            ? model.getters            : [];
        REF_VALIDATORS = (model && model.validate_functions) ? model.validate_functions : [];
        /* osmFrame endi bo'sh - amallar ro'yxatini shu yerdan boshlaymiz.
           model null bo'lsa ham chaqiriladi, aks holda ro'yxat "Yuklanmoqda"da qolib ketadi. */
        if (!ALL_MODE) loadActions();
    }

    function loadPostTemplates() {
        if (!selectedActionId) return;
        document.getElementById("ptBody").innerHTML = '<div class="hint">' + SI_LOADING + '</div>';
        document.getElementById("pt_action_id").value = selectedActionId;
        document.getElementById("ptForm").submit();
    }

    /* ---------- forma elementlari ---------- */

    function accCode(id) {
        if (id === null || id === undefined || id === "") return "";
        return "<%=lang.get(si_acc_prefix)%>" + ("00000" + id).slice(-5);
    }

    function accSelect(nm, val) {
        var h = '<select name="' + nm + '"><option value="">' + SI_CHOOSE_ACC + '</option>';
        for (var i = 0; i < REF_ACCOUNTS.length; i++) {
            var a = REF_ACCOUNTS[i];
            h += '<option value="' + esc(a.account_type_id) + '"' +
                 (String(a.account_type_id) === String(val) ? ' selected' : '') + '>' +
                 esc(accCode(a.account_type_id)) + ' - ' + esc(a.name) + '</option>';
        }
        return h + '</select>';
    }

    function getterSelect(nm, type, val) {
        var h = '<select name="' + nm + '"><option value="">' + SI_CHOOSE_METHOD + '</option>';
        for (var i = 0; i < REF_GETTERS.length; i++) {
            var g = REF_GETTERS[i];
            if (g.type !== type) continue;
            h += '<option value="' + esc(g.getter_code) + '"' +
                 (String(g.getter_code) === String(val) ? ' selected' : '') + '>' +
                 esc(g.description ? g.description : g.getter_code) + '</option>';
        }
        return h + '</select>';
    }

    function buildPtForm(r, i) {
        var h = '<div class="fgrid">';

        h += '<div class="sect-sep">' + SI_SEC_ACC + '</div>';
        h += fld(SI_DT_ACC, accSelect("dt_account_type_id_" + i, r.dt_account_type_id), "wide");
        h += fld(SI_DT_OWN, ynSelect("is_dt_own_" + i, r.is_dt_own), "narrow");
        h += fld(SI_CT_ACC, accSelect("ct_account_type_id_" + i, r.ct_account_type_id), "wide");
        h += fld(SI_CT_OWN, ynSelect("is_ct_own_" + i, r.is_ct_own), "narrow");

        h += '<div class="sect-sep">' + SI_SEC_SUMM + '</div>';
        h += fld(SI_SUMM, getterSelect("summ_getter_" + i, "SUMM", r.summ_getter), "wide");

        h += '<div class="sect-sep">' + SI_SEC_PURPOSE + '</div>';
        h += fld(SI_PURPOSE_CODE_GETTER,
                 getterSelect("purpose_code_getter_" + i, "PURPOSE_CODE", r.purpose_code_getter));
        h += fld(SI_PURPOSE_CODE, txt("purpose_code_" + i, r.purpose_code));
        h += fld(SI_PURPOSE_GETTER,
                 getterSelect("purpose_getter_" + i, "PURPOSE", r.purpose_getter));
        h += fld(SI_PURPOSE, txt("purpose_" + i, r.purpose));

        h += '<div class="sect-sep">' + SI_SEC_OTHER + '</div>';
        h += fld(SI_SORT_ORD, txt("sort_ord_" + i, r.sort_ord), "narrow");
        h += fld(SI_STATE, stateSelect("state_" + i, r.state), "narrow");

        h += '</div>';
        h += '<div class="pt-foot">' +
             '<button type="button" class="btn-pri" onclick="savePt(' + i + ');">' +
             SI_SAVE + '</button></div>';
        return h;
    }

    /* ---------- akkordeon ---------- */

    function onPostTemplatesLoaded(model) {
        var box = document.getElementById("ptBody");
        ptRows  = (model && model.list) ? model.list : [];

        if (!model) {
            box.innerHTML = '<div class="hint">' + SI_NO_DATA + '</div>';
            return;
        }

        var html = '<div class="cards">';
        html += '<div class="pane-head" style="border:0;background:none;padding:2px 2px 8px">' +
                '<span class="pane-title">' + SI_POSTINGS + ' &mdash; ' + ptRows.length + '</span>' +
                '<span><input type="button" onclick="addPt();" value="' + SI_ADD_PT + '"></span>' +
                '</div>';

        if (!ptRows.length) {
            html += '<div class="hint">' + SI_NO_TEMPLATE + '</div>';
        }

        for (var i = 0; i < ptRows.length; i++) {
            var r     = ptRows[i];
            var isAct = (r.state === "A");
            var dc    = r.detail_count ? r.detail_count : 0;
            var sub   = SI_DT + " " + (r.dt_account_name ? r.dt_account_name
                                                         : accCode(r.dt_account_type_id) || "&mdash;") +
                        " &nbsp;&rarr;&nbsp; " +
                        SI_CT + " " + (r.ct_account_name ? r.ct_account_name
                                                         : accCode(r.ct_account_type_id) || "&mdash;");

            html += '<div class="pt" id="pt' + i + '">';
            html += '<div class="pt-head" onclick="togglePt(' + i + ');">' +
                    '<span class="pt-idx">' + esc(r.sort_ord) + '</span>' +
                    '<span class="pt-caret">&#9656;</span>' +
                    '<span class="pt-name">' + SI_POSTING + ' ' + esc(r.sort_ord) + '</span>' +
                    '<span class="pt-sub">' + sub + '</span>' +
                    (dc > 0 ? pill(dc + " " + SI_CURRENCY, "#e8f0fe", "#1a56db") : "") +
                    pill(isAct ? SI_ACTIVE : SI_PASSIVE,
                         isAct ? "#e0f2ea" : "#eef1f5",
                         isAct ? "#1a7f5a" : "#667085") +
                    '<span class="pt-tools">' +
                    '<span class="ico del" title="' + SI_DELETE + '"' +
                    ' onclick="event.stopPropagation();delPt(' + i + ');">' + ICO_TRASH + '</span>' +
                    '</span></div>';
            html += '<div class="pt-body" id="ptb' + i + '"></div>';
            html += '</div>';
        }
        html += '</div>';
        box.innerHTML = html;
    }

    /* Forma faqat ochilganda quriladi - ko'p provodkada tez ishlashi uchun */
    function togglePt(i) {
        var box  = document.getElementById("pt" + i);
        var body = document.getElementById("ptb" + i);
        if (box.className.indexOf("open") >= 0) {
            box.className = "pt";
            return;
        }
        if (!body.innerHTML) body.innerHTML = buildPtForm(ptRows[i], i);
        box.className = "pt open";
    }

    function addPt() {
        var next = 1;
        for (var i = 0; i < ptRows.length; i++) {
            if (Number(ptRows[i].sort_ord) >= next) next = Number(ptRows[i].sort_ord) + 1;
        }
        ptRows.push({ sort_ord: next, state: "A", is_dt_own: "Y", is_ct_own: "Y", detail_count: 0 });
        onPostTemplatesLoaded({ list: ptRows });
        togglePt(ptRows.length - 1);
    }

    /* ---------- saqlash / o'chirish ---------- */

    function v(i, nm) {
        var el = document.getElementsByName(nm + "_" + i)[0];
        return el ? el.value : "";
    }

    function savePt(i) {
        if (!v(i, "dt_account_type_id")) { alert(SI_NEED_DT); return; }
        if (!v(i, "ct_account_type_id")) { alert(SI_NEED_CT); return; }
        if (!v(i, "sort_ord"))           { alert(SI_NEED_SORT); return; }
        /* C4/C5: maqsad yo metod orqali, yo qo'lda - ikkalasi birga bo'lmaydi */
        if (v(i, "purpose_getter") && v(i, "purpose")) { alert(SI_CONFLICT_PURPOSE); return; }
        if (v(i, "purpose_code_getter") && v(i, "purpose_code")) { alert(SI_CONFLICT_CODE); return; }

        var f = document.getElementById("saveForm");
        f.elements["post_template_id"].value    = ptRows[i].post_template_id || "";
        f.elements["action_id"].value           = selectedActionId;
        f.elements["sort_ord"].value            = v(i, "sort_ord");
        f.elements["dt_account_type_id"].value  = v(i, "dt_account_type_id");
        f.elements["is_dt_own"].value           = v(i, "is_dt_own");
        f.elements["ct_account_type_id"].value  = v(i, "ct_account_type_id");
        f.elements["is_ct_own"].value           = v(i, "is_ct_own");
        f.elements["summ_getter"].value         = v(i, "summ_getter");
        f.elements["purpose_code_getter"].value = v(i, "purpose_code_getter");
        f.elements["purpose_code"].value        = v(i, "purpose_code");
        f.elements["purpose_getter"].value      = v(i, "purpose_getter");
        f.elements["purpose"].value             = v(i, "purpose");
        f.elements["state"].value               = v(i, "state");
        f.submit();
    }

    function delPt(i) {
        /* hali saqlanmagan qator - shunchaki ro'yxatdan olib tashlaymiz */
        if (!ptRows[i].post_template_id) {
            ptRows.splice(i, 1);
            onPostTemplatesLoaded({ list: ptRows });
            return;
        }
        if (!confirm(SI_CONFIRM_DEL)) return;
        var f = document.getElementById("delForm");
        f.elements["post_template_id"].value = ptRows[i].post_template_id;
        f.submit();
    }

    /* Saqlash/o'chirish yakunlangach: xabar + ro'yxatni qayta yuklash */
    function onPtSaved(ok, msg) {
        if (!ok) { alert(msg); return; }
        if (msg) alert(msg);
        loadPostTemplates();
    }
</script>
<%!
    static final int si_post_templates =
            SI("Ўаблоны проводок", "ѕроводка шаблонлари", "Provodka shablonlari", "Posting templates");

    static final int si_select_action =
            SI("¬ыберите действие слева", "„апдан амални танланг", "Chapdan amalni tanlang",
               "Select an action on the left");

    static final int si_no_template =
            SI("Ўаблон проводки не задан", "ѕроводка шаблони белгиланмаган",
               "Provodka shabloni belgilanmagan", "No posting template");

    static final int si_dt = SI("ƒт", "ƒт", "Dt", "Dr");
    static final int si_ct = SI(" т", " т", "Kt", "Cr");

    static final int si_currency =
            SI("вал.", "вал.", "val.", "cur.");

    static final int si_summ =
            SI("—умма", "—умма", "Summa", "Amount");

    static final int si_purpose_code =
            SI(" од назначени€", "ћаксад коди", "Maqsad kodi", "Purpose code");

    static final int si_purpose =
            SI("Ќазначение", "ћаксад", "Maqsad", "Purpose");

    static final int si_acc_prefix =
            SI("—„-", "—„-", "SCH-", "ACC-");

    static final int si_postings =
            SI("Ќастройки проводок", "ѕроводка созламалари", "Provodka sozlamalari", "Posting settings");

    static final int si_posting =
            SI("ѕроводка", "ѕроводка", "Provodka", "Posting");

    static final int si_add_pt =
            SI("+ ƒобавить проводку", "+ ѕроводка кушиш", "+ Provodka qo'shish", "+ Add posting");

    static final int si_choose_acc =
            SI("Ч ¬ыбрать тип счЄта Ч", "Ч ’исоб турини танланг Ч", "Ч Hisob turini tanlang Ч",
               "Ч Select account type Ч");

    static final int si_choose_method =
            SI("Ч ¬ыбрать метод Ч", "Ч ћетодни танланг Ч", "Ч Metodni tanlang Ч", "Ч Select method Ч");

    static final int si_sec_acc =
            SI("—чета", "’исоблар", "Hisoblar", "Accounts");

    static final int si_sec_summ =
            SI("—умма", "—умма", "Summa", "Amount");

    static final int si_sec_purpose =
            SI("Ќазначение платежа", "“улов максади", "To'lov maqsadi", "Payment purpose");

    static final int si_sec_other =
            SI("ѕрочее", "Ѕошка", "Boshqa", "Other");

    static final int si_dt_acc =
            SI("ƒебет Ч тип счЄта", "ƒебет Ч хисоб тури", "Debet Ч hisob turi", "Debit Ч account type");

    static final int si_ct_acc =
            SI(" редит Ч тип счЄта", " редит Ч хисоб тури", "Kredit Ч hisob turi", "Credit Ч account type");

    static final int si_dt_own =
            SI("ƒебет Ч свой счЄт", "ƒебет Ч уз хисоби", "Debet Ч o'z hisobi", "Debit Ч own account");

    static final int si_ct_own =
            SI(" редит Ч свой счЄт", " редит Ч уз хисоби", "Kredit Ч o'z hisobi", "Credit Ч own account");

    static final int si_purpose_code_getter =
            SI(" од назначени€ Ч метод", "ћаксад коди Ч метод", "Maqsad kodi Ч metod",
               "Purpose code Ч method");

    static final int si_purpose_getter =
            SI("Ќазначение Ч метод", "ћаксад Ч метод", "Maqsad Ч metod", "Purpose Ч method");

    static final int si_sort_ord =
            SI("ѕор€док", "“артиб", "Tartib", "Order");

    static final int si_confirm_del =
            SI("”далить проводку?", "ѕроводка учирилсинми?", "Provodka o'chirilsinmi?",
               "Delete the posting?");

    static final int si_need_dt =
            SI("¬ыберите тип счЄта по дебету", "ƒебет буйича хисоб турини танланг",
               "Debet bo'yicha hisob turini tanlang", "Select the debit account type");

    static final int si_need_ct =
            SI("¬ыберите тип счЄта по кредиту", " редит буйича хисоб турини танланг",
               "Kredit bo'yicha hisob turini tanlang", "Select the credit account type");

    static final int si_need_sort =
            SI("”кажите пор€док проводки", "ѕроводка тартибини курсатинг",
               "Provodka tartibini ko'rsating", "Specify the posting order");

    static final int si_conflict_purpose =
            SI("Ќазначение задаЄтс€ либо методом, либо текстом Ч не одновременно",
               "ћаксад Є метод оркали, Є матн оркали берилади Ч иккаласи бирга эмас",
               "Maqsad yo metod orqali, yo matn orqali beriladi - ikkalasi birga emas",
               "Purpose is set either by method or by text, not both");

    static final int si_conflict_code =
            SI(" од назначени€ задаЄтс€ либо методом, либо текстом Ч не одновременно",
               "ћаксад коди Є метод оркали, Є матн оркали берилади Ч иккаласи бирга эмас",
               "Maqsad kodi yo metod orqali, yo matn orqali beriladi - ikkalasi birga emas",
               "Purpose code is set either by method or by text, not both");
%>
