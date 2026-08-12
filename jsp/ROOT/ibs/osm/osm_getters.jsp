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
    <style>
        /* Papka tabi: faol tabning oq pastki chegarasi panel chizig'ini yopadi */
        .osm-tabs { display: flex; gap: 2px; padding-left: 10px; margin-bottom: -1px; position: relative; z-index: 1; }
        .osm-tab {
            padding: 7px 16px; cursor: pointer; white-space: nowrap;
            font: 600 11px Arial, sans-serif; color: #667085;
            background: #f7f9fc; border: 1px solid #e5e9f0; border-radius: 8px 8px 0 0;
            transition: background .12s, color .12s;
        }
        .osm-tab:hover { background: #eaf0f8; color: #0b3d75; }
        .osm-tab.active { background: #fff; color: #0b3d75; border-bottom-color: #fff; cursor: default; }
        .osm-panel {
            border: 1px solid #e5e9f0; border-radius: 0 10px 10px 10px; background: #fff;
            padding: 10px 10px 10px 10px; box-shadow: 0 1px 3px rgba(16,24,40,.05); margin: 10px 10px 10px 10px;
        }
        /* karta ichida karta bo'lmasligi uchun ramka olib tashlanadi, lekin
           label.css dagi padding:8px qoladi - aks holda jadval panelga yopishadi */
        .osm-panel .grid-card { border: none; box-shadow: none; border-radius: 0; }
    </style>
    <script>
        /* Grid ustun indekslari (numbering ustuni 0-o'rinda):
           0=raqam 1=getter_code 2=function_name 3=description 4=type 5=state */
        var COL_STATE_IDX = 5;

        function responseModal(r) {
            if (r) {
                go({});
            }
        }

        /* Qo'shish tugmasi ataylab yo'q: getter funksiyalarini developer
           bazaga qo'shadi, foydalanuvchi faqat formada tanlaydi. */
        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "osm_getter.jsp?process_code=GET_GETTER_FUNCTION",
                    param: {
                        getter_code: getData(1)
                    },
                    target: "modalE",
                    dialogHeight: 420,
                    dialogWidth: 700,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function onAction() {
            edit();
        }

        function onLoad() {
            if (!dataExist()) {
                getDOM("bEdit").setDisable(true);
            }
            stylizeStates();
            observeGrid();
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
            new MutationObserver(function () { stylizeStates(); })
                .observe(table, { childList: true, subtree: true });
        }
    </script>

    <div class="osm-tabs">
        <span class="osm-tab" onclick="document.location='osm_methods.jsp';"><%=lang.get(si_tab_validate)%></span>
        <span class="osm-tab active"><%=lang.get(si_tab_getter)%></span>
        <span class="osm-tab" onclick="document.location='osm_settings.jsp?mode=all';"><%=lang.get(si_tab_actions)%></span>
    </div>

    <div class="osm-panel">
    <table class="formToolbar" align="center">
        <tr>
            <td>
                <input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
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
        <t:table from="Core.Getter_Function_V">

            <t:field id="1" name="getter_code" label="<%=si_getter_code%>">
                <t:filter operator="_like_" showInGrid="" />
            </t:field>

            <t:field id="2" name="function_name" label="<%=si_function_name%>">
                <t:filter operator="_like_" />
            </t:field>

            <t:field id="3" name="description" label="<%=si_description%>">
                <t:filter operator="_like_" />
            </t:field>

            <t:field id="4" name="type" label="<%=si_type%>">
                <t:filter operator="="
                          optionSQL="select '<option value=''' || type || '''>' || type
                                       from (select distinct type
                                               from Core.Getter_Function_V
                                              where type is not null)
                                      order by type" />
            </t:field>

            <t:field id="5" name="state" label="<%=si_state%>">
                <t:filter operator="="
                          optionSQL="select '<option value=''' || state || '''>' || state
                                       from (select distinct state
                                               from Core.Getter_Function_V
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
    </div>
</t:form>
</t:page>
<%!
    static final int si_getter_code   = SI("Код геттера", "Геттер коди", "Getter kodi", "Getter Code");
    static final int si_function_name = SI("Наименование функции", "Функция номи", "Funksiya nomi", "Function Name");
    static final int si_description   = SI("Описание", "Тавсифи", "Tavsifi", "Description");
    static final int si_type          = SI("Тип", "Тури", "Turi", "Type");
    static final int si_state         = SI("Статус", "Холати", "Holati", "Status");
    static final int si_active        = SI("Активный", "Актив", "Aktiv", "Active");
    static final int si_passive       = SI("Пассивный", "Пассив", "Passiv", "Passive");
    static final int si_edit          = SI("Изменить", "Ўзгартириш", "O'zgartirish", "Edit");
    static final int si_search        = SI("Поиск:", "Кидирув:", "Qidiruv:", "Search:");
    static final int si_tab_validate  = SI("Функции проверки", "Текшириш функциялари", "Tekshiruv funksiyalari", "Validation Functions");
    static final int si_tab_getter    = SI("Функции геттеров", "Геттер функциялари", "Getter funksiyalari", "Getter Functions");
    static final int si_tab_actions   = SI("Действия", "Амаллар", "Amallar", "Actions");
%>
<%@ include file="/language.jsp" %>
