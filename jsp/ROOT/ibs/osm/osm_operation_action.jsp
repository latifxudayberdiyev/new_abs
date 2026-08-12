<%@ page contentType="text/html;charset=WINDOWS-1251" pageEncoding="WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>

<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />

<%
    Connection conn = cods.getConnection();
    if (conn == null || user.getUserCode() == null) {
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
    }
    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%><t:page><%
    String operation_id = request.getParameter("operation_id");
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <style>
        .oam-wrap { padding: 4px 2px; font: 12px Arial, sans-serif; }
        .oam-add {
            display: grid; grid-template-columns: 2fr 1fr 1fr auto; gap: 6px;
            align-items: center; padding: 8px; margin-bottom: 10px;
            border: 1px solid #cfe0f5; border-radius: 9px; background: #f7fafd;
        }
        .oam-add select, .oam-add input {
            height: 27px; box-sizing: border-box; width: 100%;
            border: 1px solid #b6c2d2; border-radius: 6px; padding: 0 6px;
            font: 11.5px Arial, sans-serif; color: #101828; background: #fff;
        }
        .oam-lbl { font: 600 9.5px Arial, sans-serif; color: #667085;
                   text-transform: uppercase; letter-spacing: .4px; display: block; margin-bottom: 2px; }
        .oam-list { border: 1px solid #e5e9f0; border-radius: 9px; overflow: hidden; }
        .oam-row {
            display: grid; grid-template-columns: 26px 1fr 90px 70px 26px;
            gap: 6px; align-items: center; padding: 7px 9px;
            border-bottom: 1px solid #f0f2f6; background: #fff; cursor: grab;
        }
        .oam-row:last-child { border-bottom: none; }
        .oam-row:hover { background: #f7fafd; }
        .oam-row.drag { opacity: .4; }
        .oam-row.over { border-top: 2px solid #0b3d75; }
        .oam-idx {
            width: 20px; height: 20px; line-height: 20px; text-align: center;
            border-radius: 5px; background: #eef2f7; color: #475467;
            font: 700 10.5px Arial, sans-serif;
        }
        .oam-name { font: 600 11.5px Arial, sans-serif; color: #101828; }
        .oam-row select { height: 24px; border: 1px solid #d7dee8; border-radius: 5px;
                          font: 11px Arial, sans-serif; background: #fff; }
        .oam-empty { padding: 26px 10px; text-align: center; color: #98a2b3; font-size: 12px; }
        .oam-foot { display: flex; justify-content: flex-end; gap: 6px; margin-top: 10px; }
        input[type="submit"], input[type="button"] {
            height: 30px; padding: 0 20px; border-radius: 20px !important;
            font: 600 12px Arial, sans-serif; cursor: pointer;
        }
        input[type="submit"] { border: 1px solid #0b3d75 !important; background: #0b3d75 !important; color: #fff !important; }
        input[type="submit"]:hover { background: #0a3268 !important; }
        input[type="button"] { border: 1px solid #d7dee8 !important; background: #fff !important; color: #344054 !important; }
        input[type="button"]:hover { background: #f4f7fb !important; border-color: #b8c9dd !important; }
    </style>
    <script>
        var SI_NEED_ACTION = "<%=lang.get(si_need_action)%>";
        var SI_EMPTY       = "<%=lang.get(si_empty)%>";
        var SI_DEL         = "<%=lang.get(si_del)%>";

        /* Barcha amallar (ACTION_V) va operatsiyaga biriktirilganlar - ikkalasi ham
           sahifa yuklanganda serverdan keladi, modal ichida AJAX yo'q. */
        var ALL_ACTIONS = <%
            StringBuilder sbAll = new StringBuilder("[");
            PreparedStatement ps1 = null; ResultSet rs1 = null;
            try {
                ps1 = conn.prepareStatement(
                    "select action_id, name from Core.Action_V where state = 'A' order by name");
                rs1 = ps1.executeQuery();
                boolean f1 = true;
                while (rs1.next()) {
                    if (!f1) sbAll.append(",");
                    f1 = false;
                    sbAll.append("{\"id\":").append(rs1.getString("action_id"))
                         .append(",\"name\":\"")
                         .append(rs1.getString("name") == null ? "" :
                                 rs1.getString("name").replace("\\", "\\\\").replace("\"", "\\\""))
                         .append("\"}");
                }
            } catch (Exception ex) {
            } finally {
                if (rs1 != null) try { rs1.close(); } catch (Exception e) {}
                if (ps1 != null) try { ps1.close(); } catch (Exception e) {}
            }
            out.print(sbAll.append("]").toString());
        %>;

        var ROWS = <%
            StringBuilder sbR = new StringBuilder("[");
            if (operation_id != null && operation_id.length() > 0) {
                PreparedStatement ps2 = null; ResultSet rs2 = null;
                try {
                    ps2 = conn.prepareStatement(
                        "select oa.action_id, oa.sort_ord, oa.is_optional, oa.process_type, a.name" +
                        "  from Core.Osm_R_Operation_Actions oa, Core.Action_V a" +
                        " where a.action_id = oa.action_id and oa.operation_id = ?" +
                        "   and oa.state = 'A' order by oa.sort_ord");
                    ps2.setString(1, operation_id);
                    rs2 = ps2.executeQuery();
                    boolean f2 = true;
                    while (rs2.next()) {
                        if (!f2) sbR.append(",");
                        f2 = false;
                        sbR.append("{\"id\":").append(rs2.getString("action_id"))
                           .append(",\"name\":\"")
                           .append(rs2.getString("name") == null ? "" :
                                   rs2.getString("name").replace("\\", "\\\\").replace("\"", "\\\""))
                           .append("\",\"pt\":\"").append(rs2.getString("process_type"))
                           .append("\",\"opt\":\"").append(rs2.getString("is_optional"))
                           .append("\"}");
                    }
                } catch (Exception ex) {
                } finally {
                    if (rs2 != null) try { rs2.close(); } catch (Exception e) {}
                    if (ps2 != null) try { ps2.close(); } catch (Exception e) {}
                }
            }
            out.print(sbR.append("]").toString());
        %>;

        function onLoad() {
            fillActionSelect();
            render();
        }

        function esc(v) {
            if (v === null || v === undefined) return "";
            return String(v).replace(/&/g, "&amp;").replace(/</g, "&lt;")
                            .replace(/>/g, "&gt;").replace(/"/g, "&quot;");
        }

        /* Biriktirilganlar tanlovda ko'rinmaydi */
        function fillActionSelect() {
            var sel = document.getElementById("newAction");
            var h = '<option value=""></option>';
            for (var i = 0; i < ALL_ACTIONS.length; i++) {
                var a = ALL_ACTIONS[i], used = false;
                for (var j = 0; j < ROWS.length; j++) {
                    if (String(ROWS[j].id) === String(a.id)) { used = true; break; }
                }
                if (!used) h += '<option value="' + a.id + '">' + esc(a.name) + '</option>';
            }
            sel.innerHTML = h;
        }

        function ptSel(i, val) {
            return '<select onchange="ROWS[' + i + '].pt=this.value;">' +
                   '<option value="SYNC"' + (val === "SYNC" ? ' selected' : '') + '>SYNC</option>' +
                   '<option value="FORM"' + (val === "FORM" ? ' selected' : '') + '>FORM</option>' +
                   '</select>';
        }

        function optSel(i, val) {
            return '<select onchange="ROWS[' + i + '].opt=this.value;">' +
                   '<option value="N"' + (val !== "Y" ? ' selected' : '') + '><%=lang.get(si_no)%></option>' +
                   '<option value="Y"' + (val === "Y" ? ' selected' : '') + '><%=lang.get(si_yes)%></option>' +
                   '</select>';
        }

        function render() {
            var box = document.getElementById("oamList");
            if (!ROWS.length) {
                box.innerHTML = '<div class="oam-empty">' + SI_EMPTY + '</div>';
                return;
            }
            var h = "";
            for (var i = 0; i < ROWS.length; i++) {
                h += '<div class="oam-row" draggable="true" data-i="' + i + '"' +
                     ' ondragstart="dragStart(event,' + i + ')"' +
                     ' ondragover="dragOver(event,' + i + ')"' +
                     ' ondragleave="dragLeave(event,' + i + ')"' +
                     ' ondrop="dropRow(event,' + i + ')"' +
                     ' ondragend="dragEnd(event)">' +
                     '<span class="oam-idx">' + (i + 1) + '</span>' +
                     '<span class="oam-name">' + esc(ROWS[i].name) + '</span>' +
                     ptSel(i, ROWS[i].pt) + optSel(i, ROWS[i].opt) +
                     '<span class="ico del" title="' + SI_DEL + '"' +
                     ' onclick="removeRow(' + i + ');" style="cursor:pointer">&#10005;</span>' +
                     '</div>';
            }
            box.innerHTML = h;
        }

        /* ---------- surish (drag & drop) ---------- */
        var dragIdx = null;

        function dragStart(e, i) {
            dragIdx = i;
            e.dataTransfer.effectAllowed = "move";
            /* Firefox uchun ma'lumot bo'lishi shart */
            try { e.dataTransfer.setData("text/plain", String(i)); } catch (ex) {}
            e.currentTarget.className = "oam-row drag";
        }

        function dragOver(e, i) {
            e.preventDefault();
            e.dataTransfer.dropEffect = "move";
            if (dragIdx !== null && dragIdx !== i) e.currentTarget.className = "oam-row over";
        }

        function dragLeave(e, i) {
            if (e.currentTarget.className.indexOf("over") >= 0) e.currentTarget.className = "oam-row";
        }

        /* Surish: element o'z joyidan olinib, yangi joyga qo'yiladi.
           Oradagilar bir pog'ona suriladi (almashish emas). */
        function dropRow(e, i) {
            e.preventDefault();
            if (dragIdx === null || dragIdx === i) return;
            var moved = ROWS.splice(dragIdx, 1)[0];
            ROWS.splice(i, 0, moved);
            dragIdx = null;
            render();
        }

        function dragEnd(e) {
            dragIdx = null;
            render();
        }

        function removeRow(i) {
            ROWS.splice(i, 1);
            fillActionSelect();
            render();
        }

        function addRow() {
            var sel = document.getElementById("newAction");
            if (!sel.value) { alert(SI_NEED_ACTION); return; }
            var nm = sel.options[sel.selectedIndex].text;
            ROWS.push({ id: sel.value, name: nm,
                        pt: document.getElementById("newPt").value,
                        opt: document.getElementById("newOpt").value });
            fillActionSelect();
            render();
        }

        /* Butun ro'yxat bitta so'rovda ketadi - qatorma-qator saqlashda
           OSM_R_OPERATION_ACTIONS_U1 to'qnashadi.
           Yashirin maydon qiymati har doim satr, ichma-ich JSON massivini bu
           mexanizm uzata olmaydi. Format: action_id:sort_ord:process_type:is_optional;...
           Kernel uni Regexp_Substr bilan ajratadi. */
        function beforeSave() {
            var parts = [];
            for (var i = 0; i < ROWS.length; i++) {
                parts.push(ROWS[i].id + ":" + (i + 1) + ":" + ROWS[i].pt + ":" + ROWS[i].opt);
            }
            document.fm.items.value = parts.join(";");
            return true;
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="osm_operation_action.jsp?process_code=SAVE_OPERATION_ACTIONS"
              target="frm" onsubmit="return beforeSave();">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="operation_id" value="<%=(operation_id != null) ? operation_id : ""%>">
            <input type="hidden" name="items" value="">

            <div class="oam-wrap">
                <div class="oam-add">
                    <span><span class="oam-lbl"><%=lang.get(si_action)%></span>
                        <select id="newAction"></select></span>
                    <span><span class="oam-lbl"><%=lang.get(si_type)%></span>
                        <select id="newPt"><option value="SYNC">SYNC</option><option value="FORM">FORM</option></select></span>
                    <span><span class="oam-lbl"><%=lang.get(si_optional)%></span>
                        <select id="newOpt"><option value="N"><%=lang.get(si_no)%></option><option value="Y"><%=lang.get(si_yes)%></option></select></span>
                    <span><span class="oam-lbl">&nbsp;</span>
                        <input type="button" onclick="addRow();" value="<%=lang.get(si_add)%>"></span>
                </div>

                <div class="oam-list" id="oamList"></div>

                <div class="oam-foot">
                    <input type="button" onclick="parent.close();" value="<%=lang.get(si_cancel)%>">
                    <input type="submit" value="<%=lang.get(si_save)%>">
                </div>
            </div>
        </form>
    </div>
</t:form>
</t:page>
<t:requests>
    <t:request name="save"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>
</t:requests>
<%!
    static final int si_title       = SI("Действия операции", "Операция амаллари", "Operatsiya amallari", "Operation actions");
    static final int si_action      = SI("Действие", "Амал", "Amal", "Action");
    static final int si_type        = SI("Тип", "Тури", "Turi", "Type");
    static final int si_optional    = SI("Необязательное", "Ихтиёрий", "Ixtiyoriy", "Optional");
    static final int si_add         = SI("Добавить", "Кўшиш", "Qo'shish", "Add");
    static final int si_save        = SI("Сохранить", "Саклаш", "Saqlash", "Save");
    static final int si_cancel      = SI("Отмена", "Бекор килиш", "Bekor qilish", "Cancel");
    static final int si_del         = SI("Убрать", "Олиб ташлаш", "Olib tashlash", "Remove");
    static final int si_yes         = SI("Да", "Ха", "Ha", "Yes");
    static final int si_no          = SI("Нет", "Йук", "Yo'q", "No");
    static final int si_need_action = SI("Выберите действие", "Амални танланг", "Amalni tanlang", "Select an action");
    static final int si_empty       = SI("Перетащите действия для изменения порядка",
                                         "Тартибни узгартириш учун амалларни судранг",
                                         "Tartibni o'zgartirish uchun amallarni sudrang",
                                         "Drag actions to change the order");
    static final int si_success     = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
%>
<%@ include file="/language.jsp" %>
