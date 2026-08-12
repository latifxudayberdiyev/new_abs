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
    String template_code = request.getParameter("template_code");
    boolean is_edit = (template_code != null && !template_code.equals(""));
    if (is_edit) {
        try {
            out.println("<script>var data=" + stored.execJsonRequestFunction("Mpt_Admin_Api.Get_Model_Clob", request) + ";</script>");
        } catch (Exception ex) {
            Util.alertUserMessage(ex, out);
        }
    }
%><t:form title="<%=is_edit?si_edit_title:si_add_title%>" minWidth="fill" minHeight="fill">
    <script>
        function onLoad() {
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" target="frm">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="sm_relation_id" value="">
            <input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
            </table>
            <div class="form-group">
                <input name="template_code" mask="50|A-Za-z"
                       oninput="this.value=this.value.toUpperCase();" <%=is_edit?"readonly":""%> r="1"
                       class="form-control">
                <label><%=lang.get(si_code)%> <q></q>:</label>
            </div>
            <div class="form-group">
                <input name="template_name" mask="200|" r="1" class="form-control">
                <label><%=lang.get(si_name)%> <q></q>:</label>
            </div>
            <div class="form-group">
                <select name="module_code" class="form-control" r="1">
                    <option value=""></option>
                    <t:options code="module_code" name="module_name" from="mpt_modules_v"/>
                </select>
                <label><%=lang.get(si_module)%> <q></q>:</label>
            </div>
            <div class="form-group">
                <textarea name="description" mask="1000|" class="form-control" rows="3"></textarea>
                <label><%=lang.get(si_description)%>:</label>
            </div>
            <div class="form-group">
                <select name="is_active" class="form-control" r="1">
                    <option value="Y"><%=lang.get(si_active)%>
                    </option>
                    <option value="N"><%=lang.get(si_inactive)%>
                    </option>
                </select>
                <label><%=lang.get(si_state)%>:</label>
            </div>
        </form>
    </div>
</t:form>
</t:page>
<t:requests>
    <t:request name="save"><%
        try {
            stored.execJsonRequestProcedure("Mpt_Admin_Api.Execute_Process_Clob", request);
            out.print("<script>alert('" + lang.get(si_success) + "');parent.returnValue=true;parent.close();</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
            out.print("<script>parent.pageLock(false);</script>");
        }
    %></t:request>
</t:requests>
<%!
    static final int si_add_title = SI("Добавление типа шаблона", "Шаблон турини кушиш", "Shablon turini qo'shish", "Add template type");
    static final int si_edit_title = SI("Изменение типа шаблона", "Шаблон турини узгартириш", "Shablon turini o'zgartirish", "Edit template type");
    static final int si_save = SI("Сохранить", "Саклаш", "Saqlash", "Save");
    static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_exit = SI("Отмена", "Бекор килиш", "Bekor qilish", "Cancel");
    static final int si_code = SI("Код типа", "Тури коди", "Turi kodi", "Type code");
    static final int si_name = SI("Название типа", "Тури номи", "Turi nomi", "Type name");
    static final int si_module = SI("Модуль", "Модул", "Modul", "Module");
    static final int si_description = SI("Описание", "Тавсиф", "Tavsif", "Description");
    static final int si_state = SI("Состояние", "Холат", "Holat", "State");
    static final int si_active = SI("Активный", "Фаол", "Faol", "Active");
    static final int si_inactive = SI("Неактивный", "Нофаол", "Nofaol", "Inactive");
%>
<%@ include file="/language.jsp" %>
