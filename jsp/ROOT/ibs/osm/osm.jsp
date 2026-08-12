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
    String operation_id = request.getParameter("operation_id");
    String request_name = request.getParameter("request");
    if (operation_id != null && !"save".equals(request_name)) {
        try {
            out.println("<script>var data=" +
                stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request) + ";</script>");
        } catch (Exception ex) {
            Util.alertUserMessage(ex, out);
        }
    }
%><t:form title="<%=(operation_id!=null)?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
    <style>
        .form-control { border-radius: 8px !important; }
        input[type="submit"], input[type="button"] {
            height: 30px; padding: 0 20px; border-radius: 20px !important;
            font: 600 12px Arial, sans-serif; cursor: pointer;
        }
        input[type="submit"] { border: 1px solid #0b3d75 !important; background: #0b3d75 !important; color: #fff !important; }
        input[type="submit"]:hover { background: #0a3268 !important; }
        input[type="button"] { border: 1px solid #d7dee8 !important; background: #fff !important; color: #344054 !important; }
        input[type="button"]:hover { background: #f4f7fb !important; border-color: #b8c9dd !important; }
        .hintbox {
            background: #eaf2ff; border: 1px solid #cfe0f5; border-radius: 8px;
            padding: 8px 11px; font-size: 11.5px; color: #0b3d75; margin-bottom: 10px;
        }
        .sect {
            font: 700 10.5px Arial, sans-serif; color: #0b3d75; text-transform: uppercase;
            letter-spacing: .5px; border-top: 1px solid #e5e9f0;
            padding: 12px 0 8px; margin-top: 4px;
        }
    </style>
    <script>
        function onLoad() {
        }
        function beforeSave() {
            var names = ["operation_code", "module_code", "message_code"];
            for (var i = 0; i < names.length; i++) {
                var f = fm.elements[names[i]];
                if (f && f.value) {
                    f.value = f.value.toUpperCase();
                }
            }
            return true;
        }
    </script>

    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="osm.jsp?process_code=SAVE_OPERATION" target="frm"
              onsubmit="return beforeSave();">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="operation_id" value="">

            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
            </table>


            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="operation_code" r="1" mask="50|" class="form-control">
                    <label><%=lang.get(si_operation_code)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <input name="module_code" r="1" mask="50|" class="form-control">
                    <label><%=lang.get(si_module_code)%> <q></q>:</label>
                </div>
            </div>

            <div class="sect"><%=lang.get(si_sect_name)%></div>

            <div class="form-group">
                <input name="message_code" r="1" mask="100|" class="form-control">
                <label><%=lang.get(si_message_code)%> <q></q>:</label>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="mask_lang1" r="1" mask="1000|" class="form-control">
                    <label><%=lang.get(si_lang1)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <input name="mask_lang2" mask="1000|" class="form-control">
                    <label><%=lang.get(si_lang2)%>:</label>
                </div>
                <div class="form-group">
                    <input name="mask_lang3" mask="1000|" class="form-control">
                    <label><%=lang.get(si_lang3)%>:</label>
                </div>
                <div class="form-group">
                    <input name="mask_lang4" mask="1000|" class="form-control">
                    <label><%=lang.get(si_lang4)%>:</label>
                </div>
            </div>
<%
    /* Holat faqat o'zgartirish rejimida - yaratishda Save_Operation state = 'A' qilib qo'yadi */
    if (operation_id != null) {
%>
            <div class="sect"><%=lang.get(si_sect_state)%></div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <select name="state" r="1" class="form-control">
                        <option value="A"><%=lang.get(si_active)%></option>
                        <option value="P"><%=lang.get(si_passive)%></option>
                    </select>
                    <label><%=lang.get(si_state)%> <q></q>:</label>
                </div>
                <div class="form-group"></div>
            </div>
<%
    }
%>
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
    static final int si_add_title =
            SI("Добавление операции", "Операция кўшиш", "Operatsiya qo'shish", "Add operation");

    static final int si_edit_title =
            SI("Изменение операции", "Операцияни ўзгартириш", "Operatsiyani o'zgartirish", "Edit operation");

    static final int si_operation_code =
            SI("Код операции", "Операция коди", "Operatsiya kodi", "Operation Code");

    static final int si_module_code =
            SI("Код модуля", "Модул коди", "Modul kodi", "Module Code");

    static final int si_sect_name =
            SI("Наименование операции (многоязычное)", "Операция номи (куп тилли)",
               "Operatsiya nomi (ko'p tilli)", "Operation name (multilingual)");

    static final int si_message_code =
            SI("Код наименования (MLL)", "Номланиш коди (MLL)", "Nomlanish kodi (MLL)", "Name code (MLL)");

    static final int si_lang1 =
            SI("Русский", "Русча", "Ruscha", "Russian");

    static final int si_lang2 =
            SI("Узбекский (кириллица)", "Узбекча (кирилл)", "O'zbekcha (kiril)", "Uzbek (Cyrillic)");

    static final int si_lang3 =
            SI("Узбекский (латиница)", "Узбекча (лотин)", "O'zbekcha (lotin)", "Uzbek (Latin)");

    static final int si_lang4 =
            SI("Английский", "Инглизча", "Inglizcha", "English");

    static final int si_sect_state =
            SI("Состояние", "Холати", "Holati", "State");

    static final int si_state =
            SI("Статус", "Холати", "Holati", "Status");

    static final int si_active =
            SI("Активный", "Актив", "Aktiv", "Active");

    static final int si_passive =
            SI("Пассивный", "Пассив", "Passiv", "Passive");

    static final int si_save =
            SI("Сохранить", "Саклаш", "Saqlash", "Save");

    static final int si_exit =
            SI("Выход", "Чикиш", "Chiqish", "Exit");

    static final int si_success =
            SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");


%>
<%@ include file="/language.jsp" %>
