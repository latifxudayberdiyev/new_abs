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
    boolean is_edit = (accountTypeId != null && !accountTypeId.equals(""));
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
        function toggleObjectCode() {
            var enabled = document.fm.is_virtual.checked;
            document.fm.object_code.disabled = !enabled;
            if (!enabled) {
                document.fm.object_code.value = '';
            }
        }

        function onLoad() {
<%
    if (is_edit) {
%>
            document.fm.account_type_id.value = data.account_type_id;
            document.fm.name.value = data.name;
            document.fm.module_code.value = data.module_code;
            document.fm.balance_type.value = (data.balance_type == 'Внебаланс') ? 'OFB' : 'BAL';
            document.fm.state.value = data.state;
            document.fm.unique_contract_flag.checked = (data.unique_contract_flag == 'Y');
            document.fm.is_open_flag.checked = (data.is_open_flag == 'Y');
            document.fm.incode_type.value = data.incode_type;
            document.fm.is_virtual.checked = (data.is_virtual == 'Y');
            document.fm.object_code.value = data.object_code || '';
<%
    }
%>
            toggleObjectCode();
            document.fm.is_virtual.addEventListener("change", toggleObjectCode);
        }
    </script>
    <div id="basepanel" class="panel">
        <iframe name="frm" style="display:none"></iframe>
        <form name="fm" method="post" action="account_type.jsp?process_code=<%=is_edit?"EDIT_ACC_ACCOUNT_TYPE":"CREATE_ACC_ACCOUNT_TYPE"%>" target="frm">
            <input type="hidden" name="request" value="save">
            <input type="hidden" name="account_type_id" value="">
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
                <input name="name" r="1" mask="200|" class="form-control">
                <label><%=lang.get(si_name)%> <q></q>:</label>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <select name="module_code" r="1" class="form-control">
                        <t:options code="module_code" name="module_name" from="ACC_R_MODULES_V"/>
                    </select>
                    <label><%=lang.get(si_module)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <select name="balance_type" r="1" class="form-control">
                        <option value="BAL"><%=lang.get(si_balance)%></option>
                        <option value="OFB"><%=lang.get(si_off_balance)%></option>
                    </select>
                    <label><%=lang.get(si_balance_type)%> <q></q>:</label>
                </div>
            </div>
            <div style="display:grid;grid-template-columns:1fr 1fr;gap:5px">
                <div class="form-group">
                    <select name="state" r="1" class="form-control">
                        <t:options code="code" name="name" from="r_state_v"/>
                    </select>
                    <label><%=lang.get(si_state)%> <q></q>:</label>
                </div>
                <div class="form-group">
                    <select name="incode_type" r="1" class="form-control">
                        <option value="D"><%=lang.get(si_incode_debit)%></option>
                        <option value="C"><%=lang.get(si_incode_credit)%></option>
                    </select>
                    <label><%=lang.get(si_incode_type)%> <q></q>:</label>
                </div>
            </div>
            <label style="display:flex;align-items:center;gap:6px;font-size:13px;padding:4px 0;"><input type="checkbox" name="unique_contract_flag" value="1"> <%=lang.get(si_unique_contract)%></label>
            <label style="display:flex;align-items:center;gap:6px;font-size:13px;padding:4px 0;"><input type="checkbox" name="is_open_flag" value="1"> <%=lang.get(si_is_open)%></label>
            <label style="display:flex;align-items:center;gap:6px;font-size:13px;padding:4px 0;"><input type="checkbox" name="is_virtual" value="1"> <%=lang.get(si_is_virtual)%></label>
            <div class="form-group">
                <select name="object_code" class="form-control">
                    <option value=""></option>
                    <t:options code="object_code" name="object_code" from="SM_R_OBJECTS_V"/>
                </select>
                <label><%=lang.get(si_object_code)%>:</label>
            </div>
            <div style="padding:8px 0;color:#888;font-size:11.5px;">
                <%=lang.get(si_children_hint)%>
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
<%!
    static final int si_add_title      = SI("Добавление типа счёта", "Тип счёт кушиш", "Hisob turi qo'shish", "Add account type");
    static final int si_edit_title     = SI("Изменение типа счёта", "Тип счётни узгартириш", "Hisob turini o'zgartirish", "Edit account type");
    static final int si_save           = SI("Сохранить", "Сакраш", "Saqlash", "Save");
    static final int si_success        = SI("Успешно выполнено!", "Муваффакиятли бажарилди!", "Muvaffaqiyatli bajarildi!", "Successfully executed!");
    static final int si_exit           = SI("Отмена", "Бекор килиш", "Bekor qilish", "Cancel");
    static final int si_name           = SI("Наименование", "Номланиши", "Nomlanishi", "Name");
    static final int si_module         = SI("Модуль", "Модуль", "Modul", "Module");
    static final int si_balance_type   = SI("Баланс/внебаланс", "Баланс/внебаланс", "Balans/vnebalans", "Balance/off-balance");
    static final int si_balance        = SI("Баланс", "Баланс", "Balans", "Balance");
    static final int si_off_balance    = SI("Внебаланс", "Внебаланс", "Vnebalans", "Off-balance");
    static final int si_state          = SI("Состояние", "Холати", "Holati", "State");
    static final int si_incode_type    = SI("Тип кодирования", "Кодлаш тури", "Kodlash turi", "Incode type");
    static final int si_incode_debit   = SI("D - Дебет", "D - Дебет", "D - Debet", "D - Debit");
    static final int si_incode_credit  = SI("C - Кредит", "C - Кредит", "C - Kredit", "C - Credit");
    static final int si_unique_contract = SI("Уникальный счёт договора", "Уникал шартнома счёти", "Unikal shartnoma hisobi", "Unique contract account");
    static final int si_is_open        = SI("IsOpen (счёт открыт/доступен)", "IsOpen (счёт очик/мавжуд)", "IsOpen (hisob ochiq/mavjud)", "IsOpen (account open/available)");
    static final int si_is_virtual     = SI("Виртуальный счёт", "Виртуал счёт", "Virtual hisob", "Virtual account");
    static final int si_object_code    = SI("Код связанного объекта", "Богланган объект коди", "Bog'liq obyekt kodi", "Related object code");
    static final int si_children_hint  = SI("Тип клиента, коды COA и валюта задаются отдельными дочерними записями — после сохранения откройте \"Дочерние записи\" в списке.",
                                             "Тип клиента, коды COA ва валюта алохида дочерние записи сифатида белгиланади.",
                                             "Тип клиента, COA kodlari va valyuta alohida dochernie zapisi sifatida belgilanadi — saqlagandan so'ng ro'yxatda \"Дочерние записи\" ni oching.",
                                             "Client type, COA codes and currency are set as separate child records - after saving, open \"Child records\" in the list.");
%>
<%@ include file="/language.jsp" %>
