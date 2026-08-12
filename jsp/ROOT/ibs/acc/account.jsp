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
    boolean is_edit = (accountId != null && !accountId.equals(""));
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
        function toggleClient() {
            var isClient = (document.fm.owner_type.value == 'C');
            document.getElementById("clientBlock").style.display = isClient ? "" : "none";
            if (!isClient) {
                document.fm.client_id.value = "";
                document.fm.client_id_name.value = "";
            }
        }

        function onLoad() {
<%
    if (is_edit) {
%>
            document.fm.account_id.value = data.account_id;
            document.fm.account_code.value = data.account_code;
            document.fm.account_type_id.value = data.account_type_id;
            document.fm.owner_type.value = data.owner_type;
            document.fm.client_id.value = data.client_id || '';
            document.fm.client_id_name.value = data.client_name || '';
            document.fm.code_filial.value = data.code_filial || '';
            document.fm.code_filial_name.value = data.filial_name || '';
            document.fm.code_currency.value = data.code_currency;
            document.fm.abs_account_id.value = data.abs_account_id || '';
            document.fm.account_status.value = data.account_status;
            document.fm.date_open.value = data.date_open || '';
            document.fm.date_close.value = data.date_close || '';
<%
    }
%>
            toggleClient();
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="account.jsp?process_code=<%=is_edit?"EDIT_ACC_ACCOUNT":"CREATE_ACC_ACCOUNT"%>" target="frm">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="account_id" value="">
            <input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
            <table class="formToolbar" align="center">
                <tr>
                    <td>
                        <input type="submit" value="<%=lang.get(si_save)%>">
                    <td id="tableControls" align="right">
                        <input type="button" onclick="parent.close();" value="<%=lang.get(si_exit)%>">
                </tr>
            </table>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="account_code" r="1" mask="20|" class="form-control">
                    <label><%=lang.get(si_account_code)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <select name="account_type_id" r="1" class="form-control">
                        <t:options code="account_type_id" name="name" from="ACC_ACCOUNT_TYPES_V"/>
                    </select>
                    <label><%=lang.get(si_account_type)%> <q></q>:</label>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <select name="owner_type" r="1" class="form-control" onchange="toggleClient();">
                        <option value="C"><%=lang.get(si_owner_c)%></option>
                        <option value="B"><%=lang.get(si_owner_b)%></option>
                    </select>
                    <label><%=lang.get(si_owner_type)%> <q></q>:</label>
                </div>
                <div class="form-group" id="clientBlock">
                    <input name="client_id" mask="9|0-9" class="form-control"
                           reference="{name:'get_client',put:[fm.client_id,fm.client_id_name]}"
                           request="{name:'get_client',get:{client_id:fm.client_id},put:[fm.client_id_name]}">
                    <input name="client_id_name" class="form-control" readonly tabindex="-1" style="margin-top:3px;background:#FAFBFD;">
                    <label><%=lang.get(si_client)%>:</label>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="code_filial" mask="5|" class="form-control"
                           reference="{name:'get_filial',put:[fm.code_filial,fm.code_filial_name]}"
                           request="{name:'get_filial',get:{code_filial:fm.code_filial},put:[fm.code_filial_name]}">
                    <input name="code_filial_name" class="form-control" readonly tabindex="-1" style="margin-top:3px;background:#FAFBFD;">
                    <label><%=lang.get(si_filial)%>:</label>
                </div>
                <div class="form-group">
                    <select name="code_currency" r="1" class="form-control">
                        <t:options code="code" name="code || ' - ' || char_code || ' - ' || name" from="CBR_CURRENCY_V"/>
                    </select>
                    <label><%=lang.get(si_currency)%> <q></q>:</label>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="abs_account_id" mask="9|0-9" class="form-control">
                    <label><%=lang.get(si_abs_account_id)%>:</label>
                </div>
                <div class="form-group">
                    <select name="account_status" r="1" class="form-control">
                        <option value="O"><%=lang.get(si_status_open)%></option>
                        <option value="C"><%=lang.get(si_status_closed)%></option>
                        <option value="B"><%=lang.get(si_status_blocked)%></option>
                    </select>
                    <label><%=lang.get(si_account_status)%> <q></q>:</label>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <input name="date_open" mask="date" class="form-control">
                    <label><%=lang.get(si_date_open)%>:</label>
                </div>
                <div class="form-group">
                    <input name="date_close" mask="date" class="form-control">
                    <label><%=lang.get(si_date_close)%>:</label>
                </div>
            </div>
            <div style="padding:8px 0;color:#888;font-size:11.5px;">
                <%=lang.get(si_modules_hint)%>
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
    <t:request name="get_client"><%
        try {
            String clientId = request.getParameter("client_id");
            String name = stored.execSelect("select full_name from CL_PHYS_PERSONS_V where client_id=" + Util.quotesEsc(clientId));
            out.print(name);
        } catch (Exception ex) {
            response.setHeader("RT", "error");
            out.print(Util.getUserMessage(ex));
        }
    %></t:request>
    <t:request name="get_filial"><%
        try {
            String codeFilial = request.getParameter("code_filial");
            String name = stored.execSelect("select name from ABS_BRANCHES_V where code='" + Util.quotesEsc(codeFilial) + "'");
            out.print(name);
        } catch (Exception ex) {
            response.setHeader("RT", "error");
            out.print(Util.getUserMessage(ex));
        }
    %></t:request>
</t:requests>
<t:references>
    <t:reference name="get_client">
        <t:table from="CL_PHYS_PERSONS_V">
            <t:field id="1" name="client_id" label="<%=si_id%>">
                <t:filter operator="_like_" size="10" showInGrid=""/>
            </t:field>
            <t:field id="2" name="full_name" label="<%=si_client%>" type="quote">
                <t:filter operator="_search_" showInGrid=""/>
            </t:field>
            <t:grid page="" numbering="" withoutCursor="" hideFilterButton="">
                <t:column for="1"/>
                <t:column for="2" align="left"/>
            </t:grid>
        </t:table>
    </t:reference>
    <t:reference name="get_filial">
        <t:table from="ABS_BRANCHES_V">
            <t:field id="1" name="code" label="<%=si_id%>">
                <t:filter operator="_like_" size="10" showInGrid=""/>
            </t:field>
            <t:field id="2" name="name" label="<%=si_filial%>" type="quote">
                <t:filter operator="_search_" showInGrid=""/>
            </t:field>
            <t:grid page="" numbering="" withoutCursor="" hideFilterButton="">
                <t:column for="1"/>
                <t:column for="2" align="left"/>
            </t:grid>
        </t:table>
    </t:reference>
</t:references>
<%!
    static final int si_add_title      = SI("Добавить счёт", "?исоб ?ўшиш", "Hisob qo'shish", "Add account");
    static final int si_edit_title     = SI("Изменить счёт", "?исобни ўзгартириш", "Hisobni o'zgartirish", "Edit account");
    static final int si_save           = SI("Сохранить", "Са?лаш", "Saqlash", "Save");
    static final int si_success        = SI("Успешно выполнено!", "Муваффа?иятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_exit           = SI("Отмена", "Бекор ?илиш", "Bekor qilish", "Cancel");
    static final int si_id             = SI("ID", "ID", "ID", "ID");
    static final int si_account_code   = SI("Номер счёта", "?исоб ра?ами", "Hisob raqami", "Account number");
    static final int si_account_type   = SI("Тип счёта", "?исоб тури", "Hisob turi", "Account type");
    static final int si_owner_type     = SI("Владелец", "Эгаси", "Egasi", "Owner");
    static final int si_owner_c        = SI("C - Клиент", "C - Мижоз", "C - Mijoz", "C - Client");
    static final int si_owner_b        = SI("B - Банк", "B - Банк", "B - Bank", "B - Bank");
    static final int si_client         = SI("Клиент", "Мижоз", "Mijoz", "Client");
    static final int si_filial         = SI("Филиал", "Филиал", "Filial", "Branch");
    static final int si_currency       = SI("Валюта", "Валюта", "Valyuta", "Currency");
    static final int si_abs_account_id = SI("ABS Account ID", "ABS Account ID", "ABS Account ID", "ABS account ID");
    static final int si_account_status = SI("Статус", "?олати", "Holati", "Status");
    static final int si_status_open    = SI("O - Открыт", "O - Очи?", "O - Ochiq", "O - Open");
    static final int si_status_closed  = SI("C - Закрыт", "C - Ёпи?", "C - Yopiq", "C - Closed");
    static final int si_status_blocked = SI("B - Заблокирован", "B - Блокланган", "B - Bloklangan", "B - Blocked");
    static final int si_date_open      = SI("Дата открытия", "Очилган сана", "Ochilgan sana", "Date open");
    static final int si_date_close     = SI("Дата закрытия", "Ёпилган сана", "Yopilgan sana", "Date close");
    static final int si_modules_hint   = SI("После сохранения откройте \"Модули счёта\" в списке, чтобы подключить счёт к модулям.",
                                             "Са?лангандан сўнг рўйхатда \"?исоб модуллари\"ни очинг.",
                                             "Saqlagandan so'ng ro'yxatda \"Hisob modullari\"ni oching.",
                                             "After saving, open \"Account modules\" in the list to connect modules.");
%>
<%@ include file="/language.jsp" %>
