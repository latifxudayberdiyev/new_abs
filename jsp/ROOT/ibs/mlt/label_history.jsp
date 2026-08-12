<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
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
    String labelIdParam = request.getParameter("label_id");
    if (labelIdParam == null) labelIdParam = "";
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <style>
        .formToolbar { border-bottom: none; padding-bottom: 8px; }
        .formToolbar input[type="button"] {
            height: 30px; padding: 0 14px; border: 1px solid #d7dee8 !important; border-radius: 6px !important;
            background: #ffffff !important; color: #344054 !important; font: 600 12px Arial, sans-serif;
            box-shadow: 0 1px 2px rgba(16,24,40,.04);
        }
        .formToolbar input[type="button"]:hover { background: #f4f7fb !important; border-color: #b8c9dd !important; }

        .grid-card { background: #fff; border: 1px solid #e5e9f0; border-radius: 10px; padding: 8px; box-shadow: 0 1px 3px rgba(16,24,40,.05); overflow-x: auto; max-width: 100%; }
        table.hist-table { width: 100%; border-collapse: separate; border-spacing: 0; font: 12px Arial, sans-serif; }
        table.hist-table th {
            background: #f8f9fb; color: #667085; font: 700 11px Arial, sans-serif;
            text-transform: uppercase; letter-spacing: .3px; border-bottom: 1px solid #e5e9f0; padding: 8px 6px; text-align: left; white-space: nowrap;
        }
        table.hist-table td { border-bottom: 1px solid #eef1f5; padding: 6px 5px; vertical-align: top; }
        table.hist-table tr:nth-child(even) td { background: #fafbfc; }

        table.hist-table td.mask-cell { min-width: 140px; max-width: 220px; word-break: break-word; }

        .pill { display: inline-block; padding: 3px 12px; border-radius: 999px; font: 700 11px Arial, sans-serif; white-space: nowrap; }
        .hist-empty { padding: 30px; text-align: center; color: #98a2b3; font: 13px Arial, sans-serif; }
    </style>
    <script>
        var pillPalette = [['#e0f2ea','#1a7f5a'], ['#e8f0fe','#1a56db'], ['#fdf1e0','#b45309'], ['#f3e8ff','#7c3aed'], ['#e0f7fa','#0e7490'], ['#fde8e8','#b91c1c']];
        var pillColors = {};
        function pillFor(text) {
            if (!text) return document.createTextNode('');
            if (!pillColors[text]) pillColors[text] = pillPalette[Object.keys(pillColors).length % pillPalette.length];
            var c = pillColors[text];
            var span = document.createElement('span');
            span.className = 'pill';
            span.style.background = c[0];
            span.style.color = c[1];
            span.textContent = text;
            return span;
        }
        function makeCell(content, cls) {
            var td = document.createElement('td');
            if (cls) td.className = cls;
            if (content instanceof Node) td.appendChild(content);
            else td.appendChild(document.createTextNode(content || ''));
            return td;
        }
        function onHistoryLoaded(list) {
            var body = document.getElementById('histBody');
            body.innerHTML = '';
            if (!list || !list.length) {
                document.getElementById('histEmpty').style.display = 'block';
                return;
            }
            document.getElementById('histEmpty').style.display = 'none';
            list.forEach(function(r) {
                var tr = document.createElement('tr');
                tr.appendChild(makeCell(r.action_date || ''));
                tr.appendChild(makeCell(pillFor(r.action)));
                tr.appendChild(makeCell(pillFor(r.module_code)));
                tr.appendChild(makeCell(r.message_code || ''));
                tr.appendChild(makeCell(r.description || ''));
                tr.appendChild(makeCell(r.field_hint || ''));
                tr.appendChild(makeCell(r.template_description || ''));
                tr.appendChild(makeCell(r.param_count != null ? String(r.param_count) : ''));
                tr.appendChild(makeCell(r.format_string || ''));
                for (var i = 1; i <= 10; i++) {
                    tr.appendChild(makeCell(r['message_mask_lang' + i] || '', 'mask-cell'));
                }
                tr.appendChild(makeCell(r.modified_by != null ? String(r.modified_by) : ''));
                body.appendChild(tr);
            });
        }
        function loadHistory() {
            document.getElementById('historyForm').submit();
        }
        function onLoad() {
            loadHistory();
        }
    </script>

    <table class="formToolbar" align="center">
        <tr>
            <td></td>
            <td align="right">
                <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
            </td>
        </tr>
    </table>

    <div class="grid-card">
        <table class="hist-table">
            <thead>
                <tr>
                    <th><%=lang.get(si_action_date)%></th>
                    <th><%=lang.get(si_action)%></th>
                    <th><%=lang.get(si_module)%></th>
                    <th><%=lang.get(si_message_code)%></th>
                    <th><%=lang.get(si_description)%></th>
                    <th><%=lang.get(si_field_hint)%></th>
                    <th><%=lang.get(si_template_desc)%></th>
                    <th><%=lang.get(si_param_count)%></th>
                    <th><%=lang.get(si_format_string)%></th>
                    <th><%=lang.get(si_message_mask1)%></th>
                    <th><%=lang.get(si_message_mask2)%></th>
                    <th><%=lang.get(si_message_mask3)%></th>
                    <th><%=lang.get(si_message_mask4)%></th>
                    <th><%=lang.get(si_message_mask5)%></th>
                    <th><%=lang.get(si_message_mask6)%></th>
                    <th><%=lang.get(si_message_mask7)%></th>
                    <th><%=lang.get(si_message_mask8)%></th>
                    <th><%=lang.get(si_message_mask9)%></th>
                    <th><%=lang.get(si_message_mask10)%></th>
                    <th><%=lang.get(si_modified_by)%></th>
                </tr>
            </thead>
            <tbody id="histBody"></tbody>
        </table>
        <div id="histEmpty" class="hist-empty" style="display:none"><%=lang.get(si_no_data)%></div>
    </div>

    <iframe name="historyFrame" style="display:none"></iframe>
    <form id="historyForm" method="post" action="label_history.jsp" target="historyFrame" style="display:none">
        <input type="hidden" name="request" value="load_history">
        <input type="hidden" name="process_code" value="GET_HISTORY_BY_LABEL_ID">
        <input type="hidden" name="label_id" value="<%=labelIdParam%>">
    </form>
</t:form>
</t:page>

<t:requests>
    <t:request name="load_history"><%
        try {
            String result = stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request);
            out.print("<script>");
            out.print("try {");
            out.print("  var _raw = " + result + ";");
            out.print("  var _list = [];");
            out.print("  if (_raw && _raw.list) _list = _raw.list;");
            out.print("  else if (_raw && _raw.data && _raw.data.list) _list = _raw.data.list;");
            out.print("  parent.onHistoryLoaded(_list);");
            out.print("} catch(e) { parent.onHistoryLoaded([]); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onHistoryLoaded([]);</script>");
        }
    %></t:request>
</t:requests>

<%!
    static final int si_title       = SI("O'zgarishlar tarixi", "История изменений", "O'zgarishlar tarixi", "Change History");
    static final int si_exit        = SI("Chiqish", "Выход", "Chiqish", "Exit");
    static final int si_action_date   = SI("Amal sanasi", "Дата действия", "Amal sanasi", "Action Date");
    static final int si_action        = SI("Amal", "Действие", "Amal", "Action");
    static final int si_module        = SI("Module", "Модуль", "Modul", "Module");
    static final int si_message_code  = SI("Message Code", "Код сообщения", "Xabar kodi", "Message Code");
    static final int si_description   = SI("Label tavsifi", "Описание метки", "Label tavsifi", "Label Description");
    static final int si_field_hint    = SI("Field Hint", "Подсказка", "Maydon izohi", "Field Hint");
    static final int si_template_desc = SI("Template tavsifi", "Описание шаблона", "Shablon tavsifi", "Template Description");
    static final int si_param_count   = SI("Param Count", "Кол-во параметров", "Parametrlar soni", "Param Count");
    static final int si_format_string = SI("Format", "Формат", "Format", "Format");
    static final int si_modified_by   = SI("O'zgartirgan", "Кем изменено", "O'zgartirgan", "Modified By");
    static final int si_no_data       = SI("Ma'lumot yo'q", "Нет данных", "Ma'lumot yo'q", "No data");

    static final int si_message_mask1  = SI("Mask (RU)",     "Маска (RU)",     "Niqob (RU)",    "Mask (RU)");
    static final int si_message_mask2  = SI("Mask (UZ-CYR)", "Маска (UZ-CYR)", "Niqob (Kiril)", "Mask (UZ-CYR)");
    static final int si_message_mask3  = SI("Mask (UZ)",     "Маска (UZ)",     "Niqob (UZ)",    "Mask (UZ)");
    static final int si_message_mask4  = SI("Mask (EN)",     "Маска (EN)",     "Niqob (EN)",    "Mask (EN)");
    static final int si_message_mask5  = SI("Mask (KK)",     "Маска (KK)",     "Niqob (KK)",    "Mask (KK)");
    static final int si_message_mask6  = SI("Mask (TJ)",     "Маска (TJ)",     "Niqob (TJ)",    "Mask (TJ)");
    static final int si_message_mask7  = SI("Mask 7",  "Маска 7",  "Niqob 7",  "Mask 7");
    static final int si_message_mask8  = SI("Mask 8",  "Маска 8",  "Niqob 8",  "Mask 8");
    static final int si_message_mask9  = SI("Mask 9",  "Маска 9",  "Niqob 9",  "Mask 9");
    static final int si_message_mask10 = SI("Mask 10", "Маска 10", "Niqob 10", "Mask 10");
%>
<%@ include file="/language.jsp" %>
