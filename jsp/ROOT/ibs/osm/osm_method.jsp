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
    String function_id = request.getParameter("function_id");
    String request_name = request.getParameter("request");
    if (function_id != null && !"save".equals(request_name)) {
        try {
            out.println("<script>var data=" + stored.execJsonRequestFunction("Core.Mlt_Api.Get_Model_Clob", request) + ";</script>");
        } catch (Exception ex) {
            Util.alertUserMessage(ex, out);
        }
    }
%><t:form title="<%=(function_id!=null)?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
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
        }

        function normalizeFunctionName(el) {
            var pos = el.selectionStart;
            var before = el.value.length;
            el.value = el.value.toUpperCase().replace(/[^A-Z.]/g, "");
            var after = el.value.length;
            var diff = before - after;
            if (pos != null) {
                el.selectionStart = el.selectionEnd = Math.max(0, pos - diff);
            }
        }

        function beforeSave() {
            normalizeFunctionName(fm.elements["function_name"]);
            return true;
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="osm_method.jsp?process_code=SAVE_ACTION_VAL_FUNCTION" target="frm"
              onsubmit="return beforeSave();">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="function_id" value="">
            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
            </table>
            <div style="display:grid;grid-template-columns:2fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="function_name" r="1" mask="50|" class="form-control"
                           oninput="normalizeFunctionName(this)">
                    <label><%=lang.get(si_function_name)%> <q></q>:</label>
                </div>
                <%			if (function_id != null) { %>
                <div class="form-group">
                    <select name="state" class="form-control">
                        <option value="A"><%=lang.get(si_active)%></option>
                        <option value="P"><%=lang.get(si_passive)%></option>
                    </select>
                    <label><%=lang.get(si_state)%>:</label>
                </div>
                <%			} %>
            </div>
            <div style="display:grid;grid-template-columns:2fr;gap:5px">
                <div class="form-group">
                    <input name="function_desc" mask="500|" class="form-control">
                    <label><%=lang.get(si_function_desc)%>:</label>
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
    static final int si_add_title     = SI("\u0414\u043e\u0431\u0430\u0432\u043b\u0435\u043d\u0438\u0435", "\u041a\u045e\u0448\u0438\u0448", "Qo'shish", "Adding");
    static final int si_edit_title    = SI("\u0418\u0437\u043c\u0435\u043d\u0435\u043d\u0438\u0435", "\u040e\u0437\u0433\u0430\u0440\u0442\u0438\u0440\u0438\u0448", "O'zgartirish", "Editing");
    static final int si_save          = SI("\u0421\u043e\u0445\u0440\u0430\u043d\u0438\u0442\u044c", "\u0421\u0430\u043a\u043b\u0430\u0448", "Saqlash", "Save");
    static final int si_exit          = SI("\u0412\u044b\u0445\u043e\u0434", "\u0427\u0438\u043a\u0438\u0448", "Chiqish", "Exit");
    static final int si_success       = SI("\u0423\u0441\u043f\u0435\u0448\u043d\u043e \u0432\u044b\u043f\u043e\u043b\u043d\u0435\u043d\u043e!", "\u041c\u0443\u0432\u0430\u0444\u0444\u0430\u043a\u0438\u044f\u0442\u043b\u0438 \u0431\u0430\u0436\u0430\u0440\u0438\u043b\u0434\u0438!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_function_name = SI("\u041d\u0430\u0438\u043c\u0435\u043d\u043e\u0432\u0430\u043d\u0438\u0435 \u0444\u0443\u043d\u043a\u0446\u0438\u0438", "\u0424\u0443\u043d\u043a\u0446\u0438\u044f \u043d\u043e\u043c\u0438", "Funksiya nomi", "Function Name");
    static final int si_function_desc = SI("\u041e\u043f\u0438\u0441\u0430\u043d\u0438\u0435 \u0444\u0443\u043d\u043a\u0446\u0438\u0438", "\u0424\u0443\u043d\u043a\u0446\u0438\u044f \u0442\u0430\u0432\u0441\u0438\u0444\u0438", "Funksiya tavsifi", "Function Description");
    static final int si_state         = SI("\u0421\u0442\u0430\u0442\u0443\u0441", "\u0425\u043e\u043b\u0430\u0442\u0438", "Holati", "Status");
    static final int si_active        = SI("\u0410\u043a\u0442\u0438\u0432\u043d\u044b\u0439", "\u0410\u043a\u0442\u0438\u0432", "Aktiv", "Active");
    static final int si_passive       = SI("\u041f\u0430\u0441\u0441\u0438\u0432\u043d\u044b\u0439", "\u041f\u0430\u0441\u0441\u0438\u0432", "Passiv", "Passive");
%>
<%@ include file="/language.jsp" %>
