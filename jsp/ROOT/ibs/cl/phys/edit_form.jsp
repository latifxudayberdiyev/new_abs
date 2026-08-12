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
    // "Просмотр" tugmasi shu parametrlar bilan chaqiradi:
    // edit_form.jsp?process_code=EDIT_CL_PHYS_PERSON&model_process_code=MODEL_CL_PHYS_PERSON&account_id=...
    String account_id = request.getParameter("account_id");
    boolean is_edit = (account_id != null && !account_id.equals(""));
    if (is_edit) {
        try {
            out.println("<script>var data=" + stored.execJsonRequestFunction("Core_Api.Get_Model_Clob", request) + ";</script>");
        } catch (Exception ex) {
            Util.alertUserMessage(ex, out);
        }
    }
%><t:form title="<%=si_title%>" minWidth="1000" minHeight="fill">
    <script>
        function onLoad() {
            callRequest(fm.source_code);
            toggleBankClient();
        }

        function toggleBankClient() {
            var isBank = getDOMValue(fm.is_bank_client) == "1";
            getDOM("bankInfo").innerHTML = isBank
                ? "<%=lang.get(si_will_be_bank_client)%>"
                : "<%=lang.get(si_will_be_potential_client)%>";
        }

        function beforeSave() {
            return true;
        }
    </script>

    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" target="frm" onsubmit="return beforeSave();">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="account_id" value="">

            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
                </tr>
            </table>

            <div class="form-group" style="display:flex;justify-content:space-between;align-items:center">
                <div>
                    <label style="font-weight:bold"><%=lang.get(si_bank_client)%></label><br>
                    <span style="color:#888"><%=lang.get(si_bank_client_hint)%></span>
                </div>
                <input type="checkbox" name="is_bank_client" value="1" onclick="toggleBankClient();">
            </div>
            <div id="bankInfo" class="form-group" style="background:#fff7e6;padding:8px"></div>

            <div style="display:grid;grid-template-columns:1fr 2fr;gap:5px">
                <div class="form-group">
                    <input name="client_code" class="form-control" readonly tabindex="-1">
                    <label><%=lang.get(si_client_code)%>:</label>
                </div>
                <div class="form-group">
                    <input name="source_code" class="form-control" readonly tabindex="-1">
                    <label><%=lang.get(si_source)%>:</label>
                </div>
            </div>

            <div class="form-group">
                <input name="full_name" mask="150|" class="form-control">
                <label><%=lang.get(si_name)%>:</label>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="pinfl" mask="14|0-9" class="form-control">
                    <label><%=lang.get(si_pinfl)%>:</label>
                </div>
                <div class="form-group">
                    <input name="doc_seria" mask="2|A-Z" class="form-control">
                    <label><%=lang.get(si_doc_seria)%>:</label>
                </div>
                <div class="form-group">
                    <input name="doc_number" mask="7|0-9" class="form-control">
                    <label><%=lang.get(si_doc_number)%>:</label>
                </div>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="date_birth" mask="date" class="form-control">
                    <label><%=lang.get(si_date_birth)%>:</label>
                </div>
                <div class="form-group">
                    <input name="phone_number" mask="15|" class="form-control">
                    <label><%=lang.get(si_phone_number)%>:</label>
                </div>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <select name="state" class="form-control">
                        <t:options code="code" name="name" from="r_state_v"/>
                    </select>
                    <label><%=lang.get(si_state)%>:</label>
                </div>
                <div class="form-group">
                    <select name="is_access_denied" class="form-control">
                        <t:options code="code" name="name" from="core_r_access_denieds"/>
                    </select>
                    <label><%=lang.get(si_is_access_denied)%>:</label>
                </div>
            </div>
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


<div style="padding: 10px 0;">

    <div style="font-weight: bold; margin-bottom: 15px;">
        <%=lang.get(si_search_title)%>
    </div>

    <div style="display: flex; gap: 14px; width: 80%;">

        <div style="flex: 1;">
            <div style="margin-bottom: 6px;">
                <%=lang.get(si_client_code)%>
            </div>

            <input type="text" name="client_code" id="client_code" maxlength="6" inputmode="numeric"
                   oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                   style="width: 100%; box-sizing: border-box;">
        </div>

        <div style="flex: 1;">
            <div style="margin-bottom: 6px;">
                <%=lang.get(si_full_name)%>
            </div>
            <input type="text" name="full_name" id="full_name"
                   style="width: 100%; box-sizing: border-box;">
        </div>

        <div style="flex: 1;">
            <div style="margin-bottom: 6px;">
                <%=lang.get(si_doc_series)%>
            </div>

            <input type="text" name="doc_series" id="doc_series" maxlength="2"
                   oninput="this.value = this.value.toUpperCase().replace(/[^A-Z]/g, '')"
                   style="width: 100%; box-sizing: border-box;">
        </div>

        <div style="flex: 1;">
            <div style="margin-bottom: 6px;">
                <%=lang.get(si_doc_number)%>
            </div>

            <input type="text" name="doc_number" id="doc_number" maxlength="7" inputmode="numeric"
                   oninput="this.value = this.value.replace(/[^0-9]/g, '')"
                   style="width: 100%; box-sizing: border-box;">
        </div>

        <div style="flex: 1;">
            <div style="margin-bottom: 6px;">
                <%=lang.get(si_birth_date)%>
            </div>
            <input type="text" mask="date" name="birth_date" id="birth_date"
                   style="width: 80%; box-sizing: border-box;">
        </div>

    </div>
</div>


<%!
    static final int si_title = SI("Изменение клиента", "Мижозни узгартириш", "Mijozni o'zgartirish", "Edit client");
    static final int si_save = SI("Сохранить", "Сакраш", "Saqlash", "Save");
    static final int si_exit = SI("Закрыть", "Чикиш", "Chiqish", "Exit");
    static final int si_success = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_bank_client = SI("Клиент банка", "Банк мижози", "Bank mijozi", "Bank client");
    static final int si_bank_client_hint = SI(
            "Включите переключатель чтобы отметить как «Клиент банка».",
            "Банк мижози сифатида белгилаш учун ушбу тугмачани ёкинг.",
            "Bank mijozi sifatida belgilash uchun shu tugmachani yoqing.",
            "Turn on to mark as a bank client.");
    static final int si_will_be_bank_client = SI(
            "Клиент отмечен как <b>Клиент банка</b>.",
            "Мижоз <b>Банк мижози</b> сифатида белгиланган.",
            "Mijoz <b>Bank mijozi</b> sifatida belgilangan.",
            "The client is marked as a <b>Bank client</b>.");
    static final int si_will_be_potential_client = SI(
            "Клиент отмечен как <b>Потенциальный</b>.",
            "Мижоз <b>Потенциал</b> сифатида белгиланган.",
            "Mijoz <b>Potensial</b> sifatida belgilangan.",
            "The client is marked as <b>Potential</b>.");
    static final int si_client_code = SI("Код клиента", "Мижоз коди", "Mijoz kodi", "Client code");
    static final int si_source = SI("Источник", "Манба", "Manba", "Source");
    static final int si_name = SI("Ф.И.О", "Ф.И.Ш.", "F.I.Sh.", "Full name");
    static final int si_pinfl = SI("ПИНФЛ", "ПИНФЛ", "PINFL", "PINFL");
    static final int si_doc_seria = SI("Серия документа", "Хужжат сериyаси", "Hujjat seriyasi", "Document series");
    static final int si_doc_number = SI("Номер документа", "Хужжат раками", "Hujjat raqami", "Document number");
    static final int si_date_birth = SI("Дата рождения", "Тугилган сана", "Tug'ilgan sana", "Date of birth");
    static final int si_phone_number = SI("Телефон", "Телефон", "Telefon", "Phone");
    static final int si_state = SI("Состояние", "Холати", "Holati", "State");
    static final int si_is_access_denied = SI("Доступ к системе", "Тизимга кириш", "Tizimga kirish", "System access");
%>
<%@ include file="/language.jsp" %>