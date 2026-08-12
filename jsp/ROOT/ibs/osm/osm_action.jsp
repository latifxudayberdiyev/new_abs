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
    String action_id = request.getParameter("action_id");
    boolean is_edit  = (action_id != null && action_id.length() > 0);

    String v_code       = "";
    String v_name_mll   = "";
    String v_module_mll = "";
    String v_state      = "A";
    if (is_edit) {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement(
                "select action_code, name_mll_code, module_mll_code, state" +
                "  from Core.Action_V where action_id = ?");
            ps.setString(1, action_id);
            rs = ps.executeQuery();
            if (rs.next()) {
                v_code       = (rs.getString("action_code") != null) ? rs.getString("action_code") : "";
                v_name_mll   = rs.getString("name_mll_code");
                v_module_mll = rs.getString("module_mll_code");
                v_state      = rs.getString("state");
            }
        } catch (Exception ex) {
            Util.alertUserMessage(ex, out);
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
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
        }

        function normalizeCode(el) {
            if (!el) return;
            var pos = el.selectionStart;
            var before = el.value.length;
            el.value = el.value.toUpperCase().replace(/[^A-Z0-9_]/g, "");
            var diff = before - el.value.length;
            if (pos != null) {
                el.selectionStart = el.selectionEnd = Math.max(0, pos - diff);
            }
        }

        function beforeSave() {
            normalizeCode(fm.elements["action_code"]);
            normalizeCode(fm.elements["name_mll_code"]);
            normalizeCode(fm.elements["module_mll_code"]);
            return true;
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="osm_action.jsp?process_code=SAVE_ACTION" target="frm"
              onsubmit="return beforeSave();">
            <input type="hidden" name="request" value="save">
<%          if (is_edit) { %>
            <input type="hidden" name="action_id" value="<%=action_id%>">
<%          } %>
            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
            </table>
            <div style="display:grid;grid-template-columns:2fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="action_code" mask="50|" class="form-control"
                           value="<%=v_code%>" oninput="normalizeCode(this)">
                    <label><%=lang.get(si_action_code)%>:</label>
                </div>
<%          if (is_edit) { %>
                <div class="form-group">
                    <select name="state" class="form-control">
                        <option value="A"<%="A".equals(v_state)?" selected":""%>><%=lang.get(si_active)%></option>
                        <option value="P"<%="P".equals(v_state)?" selected":""%>><%=lang.get(si_passive)%></option>
                    </select>
                    <label><%=lang.get(si_state)%>:</label>
                </div>
<%          } %>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="name_mll_code" r="1" mask="100|" class="form-control"
                           value="<%=v_name_mll%>" oninput="normalizeCode(this)">
                    <label><%=lang.get(si_name_mll)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <input name="module_mll_code" r="1" mask="100|" class="form-control"
                           value="<%=v_module_mll%>" oninput="normalizeCode(this)">
                    <label><%=lang.get(si_module_mll)%> <q></q>:</label>
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
    static final int si_add_title  = SI("Добавление действия", "Амал кўшиш", "Amal qo'shish", "Adding an action");
    static final int si_edit_title = SI("Изменение действия", "Амални ўзгартириш", "Amalni o'zgartirish", "Editing an action");
    static final int si_save       = SI("Сохранить", "Саклаш", "Saqlash", "Save");
    static final int si_exit       = SI("Выход", "Чикиш", "Chiqish", "Exit");
    static final int si_success    = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_action_code = SI("Код действия", "Амал коди", "Amal kodi", "Action code");
    static final int si_name_mll   = SI("MLL код наименования", "Ном учун MLL коди", "Nom uchun MLL kodi", "Name MLL code");
    static final int si_module_mll = SI("MLL код модуля", "Модул учун MLL коди", "Modul uchun MLL kodi", "Module MLL code");
    static final int si_state      = SI("Статус", "Холати", "Holati", "Status");
    static final int si_active     = SI("Активный", "Актив", "Aktiv", "Active");
    static final int si_passive    = SI("Пассивный", "Пассив", "Passiv", "Passive");
%>
<%@ include file="/language.jsp" %>
