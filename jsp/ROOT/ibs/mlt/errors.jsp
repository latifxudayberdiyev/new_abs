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
%><t:form minWidth="fill" minHeight="fill" >
    <link rel="stylesheet" href="css/error.css?v=<%= System.currentTimeMillis() %>">
    <script>
        var FO_TEMPLATE_ID  = 1;
        var FO_ERROR_ID     = 18;
        var FO_MESSAGE_CODE = 2;

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
            new MutationObserver(function () { stylizeModules(); })
                .observe(table, { childList: true, subtree: true });
        }

        function showNotes() {
            if (!getDOM("bNotes").disabled) {
                var errorId = getData(FO_ERROR_ID);
                if (!errorId) {
                    alert('<%=lang.get(si_select_row)%>');
                    return;
                }
                openNotesPanel(errorId);
            }
        }

        function responseModal(r) {
            if (r) {
                go({});
            }
        }

        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "error.jsp?process_code=GET_TEMPLATE",
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
                    url: "error_history.jsp",
                    param: {
                        error_id: getData(FO_ERROR_ID)
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
                getDOM("bFixNote").setDisable(true);
                getDOM("bNotes").setDisable(true);
            }
            stylizeModules();
            observeGridForModules();
        }
    </script>

    <%@ include file="notes.jsp" %>

    <table class="formToolbar" align="center">
        <tr>
            <td>
                <input type="button" name="bEdit"    onclick="edit();"      value="<%=lang.get(si_edit)%>">
                <input type="button" name="bHistory" onclick="history();"   value="<%=lang.get(si_history)%>">
                <input type="button" name="bFixNote" onclick="fixNote();"   value="<%=lang.get(si_fix_note)%>">
                <input type="button" name="bNotes"   onclick="showNotes();" value="<%=lang.get(si_see_notes)%>">
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
        <t:dynamicGrid gridId="4" />
    </div>
</t:form>
</t:page>

<t:requests>

    <t:request name="load_notes"><%
        try {
            String result = stored.execJsonRequestFunction("Core.MLt_Api.Get_Model_Clob", request);
            out.print("<script>");
            out.print("try {");
            out.print("  var _raw = " + result + ";");
            out.print("  var _list = [];");
            out.print("  if (_raw && _raw.list) _list = _raw.list;");
            out.print("  else if (_raw && _raw.data && _raw.data.list) _list = _raw.data.list;");
            out.print("  parent.onNotesLoaded(_list);");
            out.print("} catch(e) { parent.onNotesLoaded([]); }");
            out.print("</script>");
        } catch (Exception ex) {
            out.print("<script>parent.onNotesLoaded([]);</script>");
        }
    %></t:request>

    <t:request name="save_fix_note"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.alert('" + lang.get(si_success) + "');</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>

    <t:request name="save_reaction"><%
        try {
            stored.execJsonRequestProcedure("Core.Mlt_Api.Execute_Process_Clob", request);
            out.print("<script>parent.onReactionSaved();</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>

</t:requests>
<%!
    static final int si_edit     = SI("O'zgartirish", "", "O'zgartirish", "Edit");
    static final int si_history  = SI("O'zgarishlar tarixi", "", "O'zgarishlar tarixi", "History");
    static final int si_fix_note = SI("Fix Note", "", "Eslatma qo'shish", "Fix Note");
    static final int si_search   = SI("Search:", "", "Qidiruv:", "Search:");
    static final int si_success  = SI("Muvaffaqiyatli bajarildi!", "", "Muvaffaqiyatli bajarildi!", "Successfully executed!");

    /* notes.jsp ishlatadigan konstantalar */
    static final int si_select_row       = SI("Please select a row!", "", "Qator tanlang!", "Please select a row!");
    static final int si_fix_note_title   = SI("Fix Note", "", "Eslatma qo'shish", "Fix Note");
    static final int si_error_label      = SI("Error:", "", "Xato:", "Error:");
    static final int si_note_text        = SI("Note text:", "", "Eslatma matni:", "Note text:");
    static final int si_note_placeholder = SI("Enter note...", "", "Eslatma kiriting...", "Enter note...");
    static final int si_note_required    = SI("Note text is required!", "", "Eslatma matni kiritilishi shart!", "Note text is required!");
    static final int si_save             = SI("Save", "", "Saqlash", "Save");
    static final int si_cancel           = SI("Cancel", "", "Bekor qilish", "Cancel");
    static final int si_notes_title      = SI("Fix Notes", "", "Fix Notes", "Fix Notes");
    static final int si_see_notes        = SI("Korish", "", "Korish", "See notes");
    static final int si_no_notes         = SI("Eslatmalar YOQ", "", "Eslatmalar YOQ", "No notes");
    static final int si_loading          = SI("Yuklanmoqda...", "", "Yuklanmoqda...", "Loading...");
%>
<%@ include file="/language.jsp" %>