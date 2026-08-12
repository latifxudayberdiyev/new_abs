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
    String getter_code = request.getParameter("getter_code");
    String request_name = request.getParameter("request");
    boolean is_edit = (getter_code != null && getter_code.length() > 0);
    if (is_edit && !"save".equals(request_name)) {
        try {
            out.println("<script>var data=" + stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request) + ";</script>");
        } catch (Exception ex) {
            Util.alertUserMessage(ex, out);
        }
    }
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
    <style>
        .form-control { border-radius: 8px !important; }
        input[type="submit"], input[type="button"] {
            height: 30px; padding: 0 20px; border-radius: 20px !important; font: 600 12px Arial, sans-serif; cursor: pointer;
        }
        input[type="submit"] { border: 1px solid #0b3d75 !important; background: #0b3d75 !important; color: #fff !important; }
        input[type="submit"]:hover { background: #0a3268 !important; }
        input[type="button"] { border: 1px solid #d7dee8 !important; background: #fff !important; color: #344054 !important; }
        input[type="button"]:hover { background: #f4f7fb !important; border-color: #b8c9dd !important; }
    </style>
    <script>
        function onLoad() {
<%      if (is_edit) { %>
            if (typeof data != "undefined" && data) {
                document.fm.elements["getter_code"].value = data.getter_code;
                document.fm.elements["type"].value        = data.type;
                document.fm.elements["state"].value       = data.state;
            }
<%      } %>
        }

        function normalize(el, re) {
            if (!el) return;
            var pos = el.selectionStart;
            var before = el.value.length;
            el.value = el.value.toUpperCase().replace(re, "");
            var diff = before - el.value.length;
            if (pos != null) {
                el.selectionStart = el.selectionEnd = Math.max(0, pos - diff);
            }
        }

        function normalizeCode(el) { normalize(el, /[^A-Z0-9_]/g); }

        function normalizeFunctionName(el) { normalize(el, /[^A-Z0-9_$#.]/g); }

        function beforeSave() {
            normalizeCode(fm.elements["getter_code"]);
            normalizeFunctionName(fm.elements["function_name"]);
            return true;
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="osm_getter.jsp?process_code=SAVE_GETTER_FUNCTION" target="frm"
              onsubmit="return beforeSave();">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="is_create" value="<%=is_edit?"N":"Y"%>">
            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
            </table>
            <div style="display:grid;grid-template-columns:2fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="getter_code" r="1" mask="50|" class="form-control"
                           <%=is_edit?"readonly":""%> oninput="normalizeCode(this)">
                    <label><%=lang.get(si_getter_code)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <select name="type" class="form-control">
                        <option value="SUMM"><%=lang.get(si_type_summ)%></option>
                        <option value="PURPOSE"><%=lang.get(si_type_purpose)%></option>
                        <option value="PURPOSE_CODE"><%=lang.get(si_type_purpose_code)%></option>
                    </select>
                    <label><%=lang.get(si_type)%> <q></q>:</label>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:2fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="function_name" r="1" mask="50|" class="form-control"
                           oninput="normalizeFunctionName(this)">
                    <label><%=lang.get(si_function_name)%> <q></q>:</label>
                </div>
<%          if (is_edit) { %>
                <div class="form-group">
                    <select name="state" class="form-control">
                        <option value="A"><%=lang.get(si_active)%></option>
                        <option value="P"><%=lang.get(si_passive)%></option>
                    </select>
                    <label><%=lang.get(si_state)%>:</label>
                </div>
<%          } %>
            </div>
            <div style="display:grid;grid-template-columns:2fr;gap:5px">
                <div class="form-group">
                    <input name="description" mask="100|" class="form-control">
                    <label><%=lang.get(si_description)%>:</label>
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
    static final int si_add_title        = SI("Добавление", "Кўшиш", "Qo'shish", "Adding");
    static final int si_edit_title       = SI("Изменение", "Ўзгартириш", "O'zgartirish", "Editing");
    static final int si_save             = SI("Сохранить", "Саклаш", "Saqlash", "Save");
    static final int si_exit             = SI("Выход", "Чикиш", "Chiqish", "Exit");
    static final int si_success          = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_getter_code      = SI("Код геттера", "Геттер коди", "Getter kodi", "Getter Code");
    static final int si_function_name    = SI("Наименование функции", "Функция номи", "Funksiya nomi", "Function Name");
    static final int si_description      = SI("Описание", "Тавсифи", "Tavsifi", "Description");
    static final int si_type             = SI("Тип", "Тури", "Turi", "Type");
    static final int si_type_summ        = SI("Сумма", "Сумма", "Summa", "Amount");
    static final int si_type_purpose     = SI("Назначение", "Максад", "Maqsad", "Purpose");
    static final int si_type_purpose_code= SI("Код назначения", "Максад коди", "Maqsad kodi", "Purpose Code");
    static final int si_state            = SI("Статус", "Холати", "Holati", "Status");
    static final int si_active           = SI("Активный", "Актив", "Aktiv", "Active");
    static final int si_passive          = SI("Пассивный", "Пассив", "Passiv", "Passive");
%>
<%@ include file="/language.jsp" %>
