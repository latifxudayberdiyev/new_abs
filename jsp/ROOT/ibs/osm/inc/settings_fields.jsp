<%@ page pageEncoding="WINDOWS-1251" %>

<div class="tabpane" id="paneFields" style="display:none">
    <div class="hint"><%=lang.get(si_select_action)%></div>
</div>

<script>
    var SI_FIELDS      = "<%=lang.get(si_fields)%>";
    var SI_FIELD       = "<%=lang.get(si_field)%>";
    var SI_ADD_AF      = "<%=lang.get(si_add_af)%>";
    var SI_NO_FIELDS   = "<%=lang.get(si_no_fields)%>";
    var SI_REQ_SHORT   = "<%=lang.get(si_req_short)%>";
    var SI_HIDDEN      = "<%=lang.get(si_hidden)%>";
    var SI_READONLY    = "<%=lang.get(si_readonly)%>";
    var SI_CONFIRM_DEL_AF = "<%=lang.get(si_confirm_del_af)%>";

    var SI_AF_SEC_MAIN  = "<%=lang.get(si_af_sec_main)%>";
    var SI_AF_SEC_POS   = "<%=lang.get(si_af_sec_pos)%>";
    var SI_AF_SEC_BEHAV = "<%=lang.get(si_af_sec_behav)%>";
    var SI_AF_SEC_VALUE = "<%=lang.get(si_af_sec_value)%>";
    var SI_AF_SEC_LOOK  = "<%=lang.get(si_af_sec_look)%>";

    var SI_AF_CODE      = "<%=lang.get(si_af_code)%>";
    var SI_AF_TYPE      = "<%=lang.get(si_af_type)%>";
    var SI_AF_LABEL     = "<%=lang.get(si_af_label)%>";
    var SI_AF_MODULE    = "<%=lang.get(si_af_module)%>";
    var SI_AF_DESC      = "<%=lang.get(si_af_desc)%>";
    var SI_AF_ROW       = "<%=lang.get(si_af_row)%>";
    var SI_AF_COL       = "<%=lang.get(si_af_col)%>";
    var SI_AF_REQUIRED  = "<%=lang.get(si_af_required)%>";
    var SI_AF_VISIBLE   = "<%=lang.get(si_af_visible)%>";
    var SI_AF_READONLY  = "<%=lang.get(si_af_readonly)%>";
    var SI_AF_F9        = "<%=lang.get(si_af_f9)%>";
    var SI_AF_MASK      = "<%=lang.get(si_af_mask)%>";
    var SI_AF_MAXLEN    = "<%=lang.get(si_af_maxlen)%>";
    var SI_AF_PLACEHOLD = "<%=lang.get(si_af_placehold)%>";
    var SI_AF_DEF_SQL   = "<%=lang.get(si_af_def_sql)%>";
    var SI_AF_DEF_VALUE = "<%=lang.get(si_af_def_value)%>";
    var SI_AF_SQL_TEXT  = "<%=lang.get(si_af_sql_text)%>";
    var SI_AF_CHECK_VAL = "<%=lang.get(si_af_check_val)%>";
    var SI_AF_LOAD_PARAM= "<%=lang.get(si_af_load_param)%>";
    var SI_AF_SQL_EXEC  = "<%=lang.get(si_af_sql_exec)%>";
    var SI_AF_FLD_COLOR = "<%=lang.get(si_af_fld_color)%>";
    var SI_AF_TXT_COLOR = "<%=lang.get(si_af_txt_color)%>";
    var SI_AF_TXT_SIZE  = "<%=lang.get(si_af_txt_size)%>";
    var SI_AF_TXT_WEIGHT= "<%=lang.get(si_af_txt_weight)%>";
    var SI_AF_TXT_ALIGN = "<%=lang.get(si_af_txt_align)%>";
    var SI_AF_NEED_CODE = "<%=lang.get(si_af_need_code)%>";
    var SI_AF_NEED_TYPE = "<%=lang.get(si_af_need_type)%>";
    var SI_AF_NEED_LBL  = "<%=lang.get(si_af_need_lbl)%>";
    var SI_AF_NEED_COL  = "<%=lang.get(si_af_need_col)%>";
    var SI_NOT_SET      = "<%=lang.get(si_not_set)%>";

    var afRows = [];

    function loadActionFields() {
        if (!selectedActionId) return;
        document.getElementById("paneFields").innerHTML =
            '<div class="hint">' + SI_LOADING + '</div>';
        document.getElementById("af_action_id").value = selectedActionId;
        document.getElementById("afForm").submit();
    }

    /* text_align uchun: bo'sh qiymat ham mumkin (ustun nullable) */
    function alignSelect(nm, val) {
        var opts = ["LEFT", "CENTER", "RIGHT"];
        var h = '<select name="' + nm + '"><option value="">' + SI_NOT_SET + '</option>';
        for (var i = 0; i < opts.length; i++) {
            h += '<option value="' + opts[i] + '"' +
                 (String(opts[i]) === String(val) ? ' selected' : '') + '>' + opts[i] + '</option>';
        }
        return h + '</select>';
    }

    function buildAfForm(r, i) {
        var h = '<div class="fgrid">';

        h += '<div class="sect-sep">' + SI_AF_SEC_MAIN + '</div>';
        h += fld(SI_AF_CODE,   txt("af_field_code_" + i, r.field_code));
        h += fld(SI_AF_TYPE,   txt("af_field_type_" + i, r.field_type));
        h += fld(SI_AF_LABEL,  txt("af_label_mll_code_" + i, r.label_mll_code));
        h += fld(SI_AF_MODULE, txt("af_module_mll_code_" + i, r.module_mll_code));
        h += fld(SI_AF_DESC,   txt("af_description_" + i, r.description), true);

        h += '<div class="sect-sep">' + SI_AF_SEC_POS + '</div>';
        h += fld(SI_AF_ROW, txt("af_row_ord_" + i, r.row_ord), "narrow");
        h += fld(SI_AF_COL, txt("af_column_ord_" + i, r.column_ord), "narrow");
        h += fld(SI_STATE,  stateSelect("af_state_" + i, r.state), "narrow");

        h += '<div class="sect-sep">' + SI_AF_SEC_BEHAV + '</div>';
        h += fld(SI_AF_REQUIRED, ynSelect("af_is_required_" + i, r.is_required), "narrow");
        h += fld(SI_AF_VISIBLE,  ynSelect("af_is_visible_" + i, r.is_visible), "narrow");
        h += fld(SI_AF_READONLY, ynSelect("af_is_read_only_" + i, r.is_read_only), "narrow");
        h += fld(SI_AF_F9,       ynSelect("af_is_f9_" + i, r.is_f9), "narrow");
        h += fld(SI_AF_MASK,     txt("af_field_mask_" + i, r.field_mask), "narrow");
        h += fld(SI_AF_MAXLEN,   txt("af_field_max_length_" + i, r.field_max_length), "narrow");
        h += fld(SI_AF_PLACEHOLD, txt("af_placeholder_text_" + i, r.placeholder_text), "wide");

        h += '<div class="sect-sep">' + SI_AF_SEC_VALUE + '</div>';
        h += fld(SI_AF_DEF_SQL,   ynSelect("af_is_def_sql_" + i, r.is_def_sql), "narrow");
        h += fld(SI_AF_CHECK_VAL, txt("af_check_value_" + i, r.check_value), "narrow");
        h += fld(SI_AF_LOAD_PARAM, txt("af_load_param_" + i, r.load_param), "narrow");
        h += fld(SI_AF_DEF_VALUE, txt("af_def_value_" + i, r.def_value), "wide");
        h += fld(SI_AF_SQL_TEXT,  txt("af_sql_text_" + i, r.sql_text), "wide");
        h += fld(SI_AF_SQL_EXEC,  txt("af_sql_exec_loading_" + i, r.sql_exec_loading), "wide");

        h += '<div class="sect-sep">' + SI_AF_SEC_LOOK + '</div>';
        h += fld(SI_AF_FLD_COLOR,  txt("af_field_color_" + i, r.field_color), "narrow");
        h += fld(SI_AF_TXT_COLOR,  txt("af_text_color_" + i, r.text_color), "narrow");
        h += fld(SI_AF_TXT_SIZE,   txt("af_text_size_" + i, r.text_size), "narrow");
        h += fld(SI_AF_TXT_WEIGHT, txt("af_text_weight_" + i, r.text_weight), "narrow");
        h += fld(SI_AF_TXT_ALIGN,  alignSelect("af_text_align_" + i, r.text_align), "narrow");

        h += '</div>';
        h += '<div class="pt-foot">' +
             '<button type="button" class="btn-pri" onclick="saveAf(' + i + ');">' +
             SI_SAVE + '</button></div>';
        return h;
    }

    function onActionFieldsLoaded(model) {
        var box = document.getElementById("paneFields");
        afRows  = (model && model.list) ? model.list : [];

        if (!model) {
            box.innerHTML = '<div class="hint">' + SI_NO_DATA + '</div>';
            return;
        }

        var html = '<div class="cards">';
        html += '<div class="pane-head" style="border:0;background:none;padding:2px 2px 8px">' +
                '<span class="pane-title">' + SI_FIELDS + ' &mdash; ' + afRows.length + '</span>' +
                '<span><input type="button" onclick="addAf();" value="' + SI_ADD_AF + '"></span>' +
                '</div>';

        if (!afRows.length) {
            html += '<div class="hint">' + SI_NO_FIELDS + '</div>';
        }

        for (var i = 0; i < afRows.length; i++) {
            var r     = afRows[i];
            var isAct = (r.state === "A");
            var pos   = (r.row_ord ? r.row_ord : "-") + "/" + esc(r.column_ord);
            var marks = "";
            if (r.is_required  === "Y") marks += pill(SI_REQ_SHORT, "#fde8e8", "#b91c1c");
            if (r.is_visible   === "N") marks += pill(SI_HIDDEN,    "#eef1f5", "#667085");
            if (r.is_read_only === "Y") marks += pill(SI_READONLY,  "#fdf1e0", "#b45309");

            html += '<div class="pt" id="af' + i + '">';
            html += '<div class="pt-head" onclick="toggleAf(' + i + ');">' +
                    '<span class="pt-idx">' + pos + '</span>' +
                    '<span class="pt-caret">&#9656;</span>' +
                    '<span class="pt-name">' + esc(r.field_code) + '</span>' +
                    '<span class="pt-sub">' +
                    esc(r.field_label ? r.field_label : r.label_mll_code) +
                    (r.field_type ? ' &middot; ' + esc(r.field_type) : '') +
                    '</span>' + marks +
                    pill(isAct ? SI_ACTIVE : SI_PASSIVE,
                         isAct ? "#e0f2ea" : "#eef1f5",
                         isAct ? "#1a7f5a" : "#667085") +
                    '<span class="pt-tools">' +
                    '<span class="ico del" title="' + SI_DELETE + '"' +
                    ' onclick="event.stopPropagation();delAf(' + i + ');">' + ICO_TRASH + '</span>' +
                    '</span></div>';
            html += '<div class="pt-body" id="afb' + i + '"></div>';
            html += '</div>';
        }
        html += '</div>';
        box.innerHTML = html;
    }

    function toggleAf(i) {
        var box  = document.getElementById("af" + i);
        var body = document.getElementById("afb" + i);
        if (box.className.indexOf("open") >= 0) {
            box.className = "pt";
            return;
        }
        if (!body.innerHTML) body.innerHTML = buildAfForm(afRows[i], i);
        box.className = "pt open";
    }

    function addAf() {
        /* Yangi maydon: keyingi ustun raqami, qolganlari standart qiymatlar bilan */
        var col = 1;
        for (var i = 0; i < afRows.length; i++) {
            if (Number(afRows[i].column_ord) >= col) col = Number(afRows[i].column_ord) + 1;
        }
        afRows.push({
            column_ord: col, state: "A",
            is_required: "Y", is_visible: "Y", is_read_only: "N", is_f9: "N", is_def_sql: "N",
            field_code: "", field_type: "", label_mll_code: "", module_mll_code: "OSM"
        });
        onActionFieldsLoaded({ list: afRows });
        toggleAf(afRows.length - 1);
    }

    function av(i, nm) {
        var el = document.getElementsByName("af_" + nm + "_" + i)[0];
        return el ? el.value : "";
    }

    function saveAf(i) {
        if (!av(i, "field_code"))     { alert(SI_AF_NEED_CODE); return; }
        if (!av(i, "field_type"))     { alert(SI_AF_NEED_TYPE); return; }
        if (!av(i, "label_mll_code")) { alert(SI_AF_NEED_LBL);  return; }
        if (!av(i, "column_ord"))     { alert(SI_AF_NEED_COL);  return; }

        var f = document.getElementById("afSaveForm");
        var names = ["field_code", "field_type", "label_mll_code", "module_mll_code",
                     "description", "row_ord", "column_ord", "placeholder_text",
                     "field_mask", "field_max_length", "is_f9", "sql_text", "check_value",
                     "load_param", "sql_exec_loading", "is_read_only", "is_visible",
                     "is_def_sql", "def_value", "is_required", "field_color", "text_color",
                     "text_size", "text_weight", "text_align", "state"];
        for (var k = 0; k < names.length; k++) {
            f.elements[names[k]].value = av(i, names[k]);
        }
        f.elements["action_field_id"].value = afRows[i].action_field_id || "";
        f.elements["action_id"].value       = selectedActionId;
        f.submit();
    }

    function delAf(i) {
        /* hali saqlanmagan qator - shunchaki ro'yxatdan olib tashlaymiz */
        if (!afRows[i].action_field_id) {
            afRows.splice(i, 1);
            onActionFieldsLoaded({ list: afRows });
            return;
        }
        if (!confirm(SI_CONFIRM_DEL_AF)) return;
        var f = document.getElementById("afDelForm");
        f.elements["action_field_id"].value = afRows[i].action_field_id;
        f.submit();
    }

    function onAfSaved(ok, msg) {
        if (!ok) { alert(msg); return; }
        if (msg) alert(msg);
        loadActionFields();
    }
</script>
<%!
    static final int si_fields =
            SI("Поля формы", "Форма майдонлари", "Forma maydonlari", "Form fields");

    static final int si_field =
            SI("Поле", "Майдон", "Maydon", "Field");

    static final int si_add_af =
            SI("+ Добавить поле", "+ Майдон кушиш", "+ Maydon qo'shish", "+ Add field");

    static final int si_no_fields =
            SI("Поля не заданы", "Майдонлар белгиланмаган", "Maydonlar belgilanmagan",
               "No fields defined");

    static final int si_req_short =
            SI("обяз.", "мажб.", "majb.", "req.");

    static final int si_hidden =
            SI("скрытое", "яширин", "yashirin", "hidden");

    static final int si_readonly =
            SI("чтение", "укиш", "o'qish", "read only");

    static final int si_confirm_del_af =
            SI("Удалить поле?", "Майдон учирилсинми?", "Maydon o'chirilsinmi?", "Delete the field?");

    static final int si_not_set =
            SI("— не задано —", "— белгиланмаган —", "— belgilanmagan —", "— not set —");

    static final int si_af_sec_main =
            SI("Основное", "Асосий", "Asosiy", "Main");

    static final int si_af_sec_pos =
            SI("Расположение", "Жойлашуви", "Joylashuvi", "Position");

    static final int si_af_sec_behav =
            SI("Поведение", "Хатти-харакати", "Xatti-harakati", "Behaviour");

    static final int si_af_sec_value =
            SI("Значение и SQL", "Киймат ва SQL", "Qiymat va SQL", "Value and SQL");

    static final int si_af_sec_look =
            SI("Оформление", "Куриниши", "Ko'rinishi", "Appearance");

    static final int si_af_code =
            SI("Код поля", "Майдон коди", "Maydon kodi", "Field code");

    static final int si_af_type =
            SI("Тип поля", "Майдон тури", "Maydon turi", "Field type");

    static final int si_af_label =
            SI("Код наименования (MLL)", "Номланиш коди (MLL)", "Nomlanish kodi (MLL)", "Label code (MLL)");

    static final int si_af_module =
            SI("Код модуля (MLL)", "Модул коди (MLL)", "Modul kodi (MLL)", "Module code (MLL)");

    static final int si_af_desc =
            SI("Описание", "Тавсифи", "Tavsifi", "Description");

    static final int si_af_row =
            SI("Строка", "Катор", "Qator", "Row");

    static final int si_af_col =
            SI("Столбец", "Устун", "Ustun", "Column");

    static final int si_af_required =
            SI("Обязательное", "Мажбурий", "Majburiy", "Required");

    static final int si_af_visible =
            SI("Видимое", "Куринади", "Ko'rinadi", "Visible");

    static final int si_af_readonly =
            SI("Только чтение", "Факат укиш", "Faqat o'qish", "Read only");

    static final int si_af_f9 =
            SI("Выбор по F9", "F9 оркали танлаш", "F9 orqali tanlash", "F9 lookup");

    static final int si_af_mask =
            SI("Маска", "Маска", "Maska", "Mask");

    static final int si_af_maxlen =
            SI("Макс. длина", "Макс. узунлик", "Maks. uzunlik", "Max length");

    static final int si_af_placehold =
            SI("Подсказка в поле", "Майдондаги эслатма", "Maydondagi eslatma", "Placeholder");

    static final int si_af_def_sql =
            SI("Значение из SQL", "Киймат SQL дан", "Qiymat SQL dan", "Default from SQL");

    static final int si_af_def_value =
            SI("Значение по умолчанию", "Стандарт киймат", "Standart qiymat", "Default value");

    static final int si_af_sql_text =
            SI("SQL запрос", "SQL суров", "SQL so'rov", "SQL query");

    static final int si_af_check_val =
            SI("Проверяемое значение", "Текширилувчи киймат", "Tekshiriluvchi qiymat", "Check value");

    static final int si_af_load_param =
            SI("Параметры загрузки", "Юклаш параметрлари", "Yuklash parametrlari", "Load params");

    static final int si_af_sql_exec =
            SI("SQL при загрузке", "Юклашдаги SQL", "Yuklashdagi SQL", "SQL on loading");

    static final int si_af_fld_color =
            SI("Цвет поля", "Майдон ранги", "Maydon rangi", "Field color");

    static final int si_af_txt_color =
            SI("Цвет текста", "Матн ранги", "Matn rangi", "Text color");

    static final int si_af_txt_size =
            SI("Размер текста", "Матн улчами", "Matn o'lchami", "Text size");

    static final int si_af_txt_weight =
            SI("Толщина текста", "Матн калинлиги", "Matn qalinligi", "Text weight");

    static final int si_af_txt_align =
            SI("Выравнивание", "Текислаш", "Tekislash", "Alignment");

    static final int si_af_need_code =
            SI("Укажите код поля", "Майдон кодини курсатинг", "Maydon kodini ko'rsating",
               "Specify the field code");

    static final int si_af_need_type =
            SI("Укажите тип поля", "Майдон турини курсатинг", "Maydon turini ko'rsating",
               "Specify the field type");

    static final int si_af_need_lbl =
            SI("Укажите код наименования", "Номланиш кодини курсатинг", "Nomlanish kodini ko'rsating",
               "Specify the label code");

    static final int si_af_need_col =
            SI("Укажите столбец", "Устунни курсатинг", "Ustunni ko'rsating", "Specify the column");
%>
