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
    String userId = request.getParameter("user_id");
    String login = request.getParameter("login");
%><t:page><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <script>
        function checkPasswords() {
            if (fm.new_password.value != fm.password_confirm.value) {
                alert("<%=lang.get(si_pwd_mismatch)%>");
                return false;
            }
            return true;
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" target="frm" onsubmit="return checkPasswords();">
            <input type="hidden" name="request" value="save">
            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
            </table>
            <input type="hidden" name="user_id" value="<%=Util.quotesEsc(userId)%>">
            <input type="hidden" name="provider_type" value="LOCAL">
            <input type="hidden" name="provider_key" value="<%=Util.quotesEsc(login)%>">
            <div class="form-group">
                <input value="<%=Util.quotesEsc(login)%>" class="form-control" readonly tabindex="-1">
                <label><%=lang.get(si_login)%>:</label>
            </div>
            <div class="form-group">
                <input type="password" name="new_password" mask="100|" r="1" class="form-control">
                <label><%=lang.get(si_new_password)%> <q></q>:</label>
            </div>
            <div class="form-group">
                <input type="password" name="password_confirm" mask="100|" r="1" class="form-control">
                <label><%=lang.get(si_password_confirm)%> <q></q>:</label>
            </div>
            <p style="color:#9ca3af;font-size:12px"><%=lang.get(si_hint)%>
            </p>
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
    static final int si_title = SI("Сброс пароля", "Паролни тиклаш", "Parolni tiklash", "Reset password");
    static final int si_save = SI("Сохранить", "Са?лаш", "Saqlash", "Save");
    static final int si_success = SI("Успешно выполнено!", "Муваффа?иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_exit = SI("Выход", "Чи?иш", "Chiqish", "Exit");
    static final int si_login = SI("Логин", "Логин", "Login", "Login");
    static final int si_new_password = SI("Новый пароль", "Янги парол", "Yangi parol", "New password");
    static final int si_password_confirm = SI("Подтверждение пароля", "Паролни тасди?лаш", "Parolni tasdiqlash", "Confirm password");
    static final int si_pwd_mismatch = SI("Пароли не совпадают!", "Пароллар мос келмади!", "Parollar mos kelmadi!", "Passwords do not match!");
    static final int si_hint = SI("Пользователю нужно будет сменить этот пароль при следующем входе.", "Фойдаланувчи кейинги киришда бу паролни ўзгартириши керак бўлади.", "Foydalanuvchi keyingi kirishda bu parolni albatta o'zgartirishi kerak bo'ladi.", "The user will be required to change this password on next login.");
%>
<%@ include file="/language.jsp" %>
