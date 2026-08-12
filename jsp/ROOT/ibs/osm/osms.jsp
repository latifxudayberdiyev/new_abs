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
%><t:page><%
%><t:form  minWidth="fill" minHeight="fill">
    <link rel="stylesheet" href="../mlt/css/label.css?v=<%= System.currentTimeMillis() %>">
    <script>
        /* Grid ustun indekslari (numbering ustuni 0-o'rinda):
           0=raqam 1=operation_id 2=operation_code 3=module_code 4=name 5=state */
        var COL_MODULE_IDX = 3;
        var COL_STATE_IDX  = 5;

        function responseModal(r) {
            if (r) {
                go({});
            }
        }

        function add() {
            go({
                url: "osm.jsp?process_code=SAVE_OPERATION",
                target: "modalE",
                dialogHeight: 520,
                dialogWidth: 900,
                lock: false,
                callback: responseModal
            });
        }

        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "osm.jsp?process_code=GET_OPERATION",
                    param: {
                        operation_id: getData(1)
                    },
                    target: "modalE",
                    dialogHeight: 520,
                    dialogWidth: 900,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function onAction() {
            edit();
        }

        function settings() {
            if (!getDOM("bSettings").disabled) {
                go({
                    url: "osm_settings.jsp",
                    param: {
                        operation_id: getData(1)
                    }
                });
            }
        }

        function onLoad() {
            if (!dataExist()) {
                getDOM("bEdit").setDisable(true);
                getDOM("bSettings").setDisable(true);
            }
            stylizeModules();
            stylizeStates();
            observeGrid();
        }

        var modulePillPalette = [
            ['#e0f2ea', '#1a7f5a'], ['#e8f0fe', '#1a56db'], ['#fdf1e0', '#b45309'],
            ['#f3e8ff', '#7c3aed'], ['#e0f7fa', '#0e7490'], ['#fde8e8', '#b91c1c']
        ];
        var modulePillColorMap = {};
        var modulePillColorIdx = 0;

        function stylizeModules() {
            var table = document.getElementById('tbl');
            if (!table) return;
            var rows = table.rows;
            for (var i = 0; i < rows.length; i++) {
                var td = rows[i].cells[COL_MODULE_IDX];
                if (!td || td.tagName !== 'TD' || td.querySelector('.module-pill')) continue;
                var text = td.textContent.trim();
                if (!text) continue;
                if (!modulePillColorMap[text]) {
                    modulePillColorMap[text] = modulePillPalette[modulePillColorIdx % modulePillPalette.length];
                    modulePillColorIdx++;
                }
                var colors = modulePillColorMap[text];
                td.innerHTML = '';
                var span = document.createElement('span');
                span.className = 'module-pill';
                span.style.background = colors[0];
                span.style.color = colors[1];
                span.textContent = text;
                td.appendChild(span);
            }
        }


        function stylizeStates() {
            var table = document.getElementById('tbl');
            if (!table) return;
            var rows = table.rows;
            for (var i = 0; i < rows.length; i++) {
                var td = rows[i].cells[COL_STATE_IDX];
                if (!td || td.tagName !== 'TD' || td.querySelector('.module-pill')) continue;
                var code = td.textContent.trim();
                if (!code) continue;
                var isAct = (code === 'A');
                td.innerHTML = '';
                var span = document.createElement('span');
                span.className = 'module-pill';
                span.style.background = isAct ? '#e0f2ea' : '#eef1f5';
                span.style.color      = isAct ? '#1a7f5a' : '#667085';
                span.textContent = isAct ? '<%=lang.get(si_active)%>' : '<%=lang.get(si_passive)%>';
                td.appendChild(span);
            }
        }

        function observeGrid() {
            var table = document.getElementById('tbl');
            if (!table || !window.MutationObserver) return;
            new MutationObserver(function () { stylizeModules(); stylizeStates(); })
                .observe(table, { childList: true, subtree: true });
        }
    </script>

    <table class="formToolbar" align="center">
        <tr>
            <td>
                <input type="button" name="bAdd"  onclick="add();"  value="<%=lang.get(si_add)%>">
                <input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
                <input type="button" name="bSettings" onclick="settings();" value="<%=lang.get(si_settings)%>">
            </td>
            <td id="tableControls" align="right"></td>
        </tr>
        <tr>
            <td colspan="2" align="left">
                <b><%=lang.get(si_search)%></b><span id="filterControls"></span>
            </td>
        </tr>
    </table>

    <div class="grid-card">
        <t:table from="Core.OPERATION_V">

            <t:field id="1" name="operation_id" label="<%=si_operation_id%>">
                <t:filter operator="=" />
            </t:field>

            <t:field id="2" name="operation_code" label="<%=si_operation_code%>">
                <t:filter operator="_like_" showInGrid="" />
            </t:field>

            <t:field id="3" name="module_code" label="<%=si_module_code%>">
                <t:filter operator="="
                          optionSQL="select '<option value=''' || module_code || '''>' || module_code
                                       from (select distinct module_code
                                               from Core.OPERATION_V
                                              where module_code is not null)
                                      order by module_code" />
            </t:field>

            <t:field id="4" name="name" label="<%=si_name%>">
                <t:filter operator="_like_" />
            </t:field>

            <t:field id="5" name="state" label="<%=si_state%>">
                <t:filter operator="="
                          optionSQL="select '<option value=''' || state || '''>' || state
                                       from (select distinct state
                                               from Core.OPERATION_V
                                              where state is not null)
                                      order by state" />
            </t:field>

            <t:grid page="" numbering="" withoutCursor="">
                <t:column for="1" />
                <t:column for="2" />
                <t:column for="3" />
                <t:column for="4" />
                <t:column for="5" />
            </t:grid>

        </t:table>
    </div>
</t:form>
</t:page>
<%!
    static final int si_operation_id = SI("Идентификатор операции", "Операция идентификатори", "Operatsiya identifikatori", "Operation ID");
    static final int si_operation_code = SI("Код операции", "Операция коди", "Operatsiya kodi", "Operation Code");
    static final int si_module_code = SI("Код модуля", "Модул коди", "Modul kodi", "Module Code");
    static final int si_name = SI("Наименование", "Номланиши", "Nomlanishi", "Name");
    static final int si_state = SI("Статус", "Холати", "Holati", "Status");
    static final int si_active = SI("Активный", "Актив", "Aktiv", "Active");
    static final int si_passive = SI("Пассивный", "Пассив", "Passiv", "Passive");
    static final int si_add = SI("Добавить", "Кўшиш", "Qo'shish", "Add");
    static final int si_settings = SI("Settings", "Settings", "Settings", "Settings");
    static final int si_edit = SI("Изменить", "Ўзгартириш", "O'zgartirish", "Edit");
    static final int si_search = SI("Поиск:", "Кидирув:", "Qidiruv:", "Search:");
%>
<%@ include file="/language.jsp" %>
