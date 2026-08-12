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
    String accountTypeId = request.getParameter("account_type_id");
    String childId = request.getParameter("account_type_client_id");
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
            document.fm.account_type_client_id.value = data.account_type_client_id;
            document.fm.client_type.value = data.client_type;
            document.fm.state.value = data.state;
            document.fm.code_coa.value = data.code_coa;
            document.fm.currency_code.value = data.currency_code;
<%
    }
%>
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="account_type_client.jsp?process_code=<%=is_edit?"EDIT_ACC_ACCOUNT_TYPE_CLIENT":"CREATE_ACC_ACCOUNT_TYPE_CLIENT"%>" target="frm">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="account_type_client_id" value="">
            <input type="hidden" name="account_type_id" value="<%=accountTypeId%>">
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
                <input class="form-control" readonly tabindex="-1" value="<%=accountTypeId%>">
                <label><%=lang.get(si_parent)%>:</label>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <select name="client_type" r="1" class="form-control">
                        <option value="C"><%=lang.get(si_client_c)%></option>
                        <option value="B"><%=lang.get(si_client_b)%></option>
                    </select>
                    <label><%=lang.get(si_client_type)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <select name="state" r="1" class="form-control">
                        <t:options code="code" name="name" from="r_state_v"/>
                    </select>
                    <label><%=lang.get(si_state)%> <q></q>:</label>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="code_coa" r="1" mask="5|0-9" class="form-control">
                    <label><%=lang.get(si_code_coa)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <input name="currency_code" mask="3|0-9*" class="form-control" placeholder="*">
                    <label><%=lang.get(si_currency)%>:</label>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <select name="account_term_type" r="1" class="form-control">
                        <t:options code="code" name="name" from="acc_r_term_types_v"/>
                    </select>
                    <label><%=lang.get(si_account_term_type)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <select name="subject_type" r="1" class="form-control">
                        <t:options code="code" name="name" from="acc_r_subject_types_v"/>
                    </select>
                    <label><%=lang.get(si_subject_type)%> <q></q>:</label>
                </div>
            </div>
            <div style="padding:8px 0;color:#888;font-size:11.5px;"><%=lang.get(si_currency_hint)%></div>
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
    static final int si_add_title    = SI("Новая дочерняя запись", "Янги дочерняя запись", "Yangi dochernie zapisi", "New child record");
    static final int si_edit_title   = SI("Изменение дочерней записи", "Дочерняя записьни узгартириш", "Dochernie zapisini o'zgartirish", "Edit child record");
    static final int si_save         = SI("Сохранить", "Сакраш", "Saqlash", "Save");
    static final int si_success      = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_exit         = SI("Отмена", "Бекор килиш", "Bekor qilish", "Cancel");
    static final int si_parent       = SI("Тип счёт ID (родитель)", "Тип счёт ID (ота)", "Тип счёt ID (ota)", "Account type (parent)");
    static final int si_client_type  = SI("Тип клиента", "Мижоз тури", "Mijoz turi", "Client type");
    static final int si_client_c     = SI("C - Клиент", "C - Мижоз", "C - Mijoz", "C - Client");
    static final int si_client_b     = SI("B - Bank", "B - Bank", "B - Bank", "B - Bank");
    static final int si_state        = SI("Состояние", "Холати", "Holati", "State");
    static final int si_code_coa     = SI("Коды COA (Баланс код)", "Коды COA (Баланс код)", "COA kodlari (Balans kod)", "COA codes (Balance code)");
    static final int si_currency     = SI("Валюта", "Валюта", "Valyuta", "Currency");
    static final int si_account_term_type = SI("Срок счета", "?исоб муддати", "Hisob muddati", "Account Term");
    static final int si_subject_type = SI("Тип клиента", "Мижоз тури", "Mijoz turi", "Client Type");
    static final int si_currency_hint = SI("\"*\" означает, что подходит для всех валют.", "\"*\" барча валюталар учун мос эканини билдиради.", "\"*\" barcha valyutalarga mosligini bildiradi.", "\"*\" means it fits all currencies.");
%>
<%@ include file="/language.jsp" %>
