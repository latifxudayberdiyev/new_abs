<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="uz.fido_biznes.cms.Language" %>
<%@ page import="uz.fido_biznes.cms.Resource" %>
<%@ page import="uz.fido_biznes.cms.Sentence" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session"/>
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/>
<jsp:useBean id="user" class="iabs.User" scope="session"/>
<%
    Connection conn = cods.getConnection();
    if (conn == null || user.getUserCode() == null) {
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
    }
    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%><t:page><%
%><t:form minWidth="fill" minHeight="fill">
    <link rel="stylesheet" href="css/error.css?v=<%= System.currentTimeMillis() %>">
    <script>
        var FO_TEMPLATE_ID = 1;
        var FO_LABEL_ID = 17;
        var COL_MODULE_IDX = 4;

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

        function observeGridForModules() {
            var table = document.getElementById('tbl');
            if (!table || !window.MutationObserver) return;
            new MutationObserver(function () {
                stylizeModules();
            })
                .observe(table, {childList: true, subtree: true});
        }

        function responseModal(r) {
            if (r) {
                go({});
            }
        }

        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "label.jsp?process_code=GET_LABEL",
                    param: {
                        template_id: getData(FO_TEMPLATE_ID)
                    },
                    target: "modalE",
                    dialogHeight: 700,
                    dialogWidth: 1200,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function history() {
            if (!getDOM("bHistory").disabled) {
                go({
                    url: "label_history.jsp",
                    param: {
                        label_id: getData(FO_LABEL_ID)
                    },
                    target: "modalE",
                    dialogHeight: 700,
                    dialogWidth: Math.max(1600, screen.availWidth - 60),
                    lock: false
                });
            }
        }

        function onAction() {
            edit();
        }


        function onLoad() {
            if (!dataExist()) {
                getDOM("bEdit").setDisable(true);
                getDOM("bHistory").setDisable(true);
            }
            stylizeModules();
            observeGridForModules();


        }
    </script>
    <table class="formToolbar" align="center">
        <tr>
            <td>
                <input type="button" name="bEdit" onclick="edit();" value="<%=lang.get(si_edit)%>">
                <input type="button" name="bHistory" onclick="history();" value="<%=lang.get(si_history)%>">
            </td>
            <td id="tableControls" align="right"></td>
        </tr>
        <tr>
            <td colspan="2" align="left">
                <b><%=lang.get(si_search)%>
                </b><span id="filterControls"></span>
            </td>
        </tr>
    </table>
    <div class="grid-card">
        <t:dynamicGrid gridId="5"/>
    </div>
</t:form>
</t:page>
<%!
    static final int si_search = SI("Search:", "search", "Qidiruv:", "Search:");
    static final int si_edit = SI("O'zgartirish", "Изменить", "O'zgartirish", "Edit");
    static final int si_history = SI("O'zgarishlar tarixi", "История изменений", "O'zgarishlar tarixi", "History");
%>
<%@ include file="/language.jsp" %>
