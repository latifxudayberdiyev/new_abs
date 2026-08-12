<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
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
    String accountId = request.getParameter("account_id");
    String childId = request.getParameter("account_module_id");
    boolean is_edit = (childId != null && !childId.equals(""));
    if (is_edit) {
        try {
            out.println("<script>var data=" + stored.execJsonRequestFunction("Core_Api.Get_Model_Clob", request) + ";</script>");
        } catch (Exception ex) {
            Util.alertUserMessage(ex, out);
        }
    }
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
    <style>
        /* ===== fabrika-produktov.html uslubiga moslashtirilgan tugma dizayni ===== */
        .formToolbar { border: none !important; background: none !important; box-shadow: none !important; margin-bottom: 14px; }
        .formToolbar td { border: none !important; }
        .formToolbar input[type="submit"], .formToolbar input[type="button"] {
            background: #3457EF !important;
            border: 1px solid #3457EF !important;
            border-radius: 7px !important;
            color: #ffffff !important;
            font: 600 12.5px "Segoe UI", Arial, sans-serif !important;
            padding: 8px 18px !important;
            cursor: pointer;
            box-shadow: none !important;
            transition: background .12s;
        }
        .formToolbar td#tableControls input[type="button"] {
            background: #ffffff !important;
            border: 1px solid #E4E7EF !important;
            color: #3457EF !important;
        }
        .formToolbar input[type="submit"]:hover { background: #2843C9 !important; border-color: #2843C9 !important; }
        .formToolbar td#tableControls input[type="button"]:hover { background: #EAEEFF !important; }
        #basepanel { padding: 4px 2px; }
    </style>

    <script>
        function onLoad() {
<%
    if (is_edit) {
%>
            document.fm.account_module_id.value = data.account_module_id;
            document.fm.module_code.value = data.module_code;
            document.fm.is_active_flag.checked = (data.is_active_flag == 'Y');
<%
    }
%>
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="account_module.jsp?process_code=<%=is_edit?"EDIT_ACC_ACCOUNT_MODULE":"CREATE_ACC_ACCOUNT_MODULE"%>" target="frm">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="account_module_id" value="">
            <input type="hidden" name="account_id" value="<%=accountId%>">
            <input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
                </tr>
            </table>
            <div class="form-group">
                <input class="form-control" readonly tabindex="-1" value="<%=accountId%>">
                <label><%=lang.get(si_account_id)%>:</label>
            </div>
            <div class="form-group">
                <select name="module_code" r="1" class="form-control">
                    <t:options code="module_code" name="module_name" from="ACC_R_MODULES_V"/>
                </select>
                <label><%=lang.get(si_module)%> <q></q>:</label>
            </div>
            <label style="display:flex;align-items:center;gap:6px;font-size:13px;padding:4px 0;"><input type="checkbox" name="is_active_flag" value="1" checked> <%=lang.get(si_is_active)%></label>
        </form>
    </div>
</t:form>
</t:page>
<t:requests>
    <t:request name="save"><%
        try {
            stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
            out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>
</t:requests>
<%!
    static final int si_add_title  = SI("Добавить модуль", "Модул ?ўшиш", "Modul qo'shish", "Add module");
    static final int si_edit_title = SI("Изменить модуль", "Модулни ўзгартириш", "Modulni o'zgartirish", "Edit module");
    static final int si_save       = SI("Сохранить", "Са?лаш", "Saqlash", "Save");
    static final int si_success    = SI("Успешно выполнено!", "Муваффа?иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_exit       = SI("Отмена", "Бекор ?илиш", "Bekor qilish", "Cancel");
    static final int si_account_id = SI("Счёт (родитель)", "?исоб (она)", "Hisob (ota)", "Account (parent)");
    static final int si_module     = SI("Модуль", "Модул", "Modul", "Module");
    static final int si_is_active  = SI("Активен", "Актив", "Faol", "Active");
%>
<%@ include file="/language.jsp" %>
