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
    String accountTypeId = request.getParameter("account_type_id");
    if (accountTypeId == null) {
        accountTypeId = (String) session.getValue("ACC_ACCOUNT_TYPE_ID");
    } else {
        session.putValue("ACC_ACCOUNT_TYPE_ID", accountTypeId);
    }
    try {
        ServletCallableStatement cs = new ServletCallableStatement(stored, request);
        cs.setProcedure("User_Session.PUT_Number");
        cs.setString("i_Key", "acc_account_type_id");
        cs.setString("i_Value", accountTypeId);
        cs.execute();
    } catch (Exception ex) {
        Util.alertUserMessage(ex, out);
    }
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <style>
        /* ===== fabrika-produktov.html uslubiga moslashtirilgan grid/tugma dizayni ===== */
        .formToolbar { border: none !important; background: none !important; box-shadow: none !important; margin-bottom: 10px; }
        .formToolbar td { border: none !important; }
        .formToolbar input[isbutton="true"],
        .formToolbar button.navbut[isbutton="true"] {
            background: #ffffff !important;
            border: 1px solid #E4E7EF !important;
            border-radius: 7px !important;
            color: #3457EF !important;
            font: 600 12.5px "Segoe UI", Arial, sans-serif !important;
            padding: 7px 14px !important;
            margin-right: 6px !important;
            cursor: pointer;
            box-shadow: none !important;
            transition: background .12s, border-color .12s;
        }
        .formToolbar button.navbut[isbutton="true"] { padding: 6px 9px !important; }
        .formToolbar input[isbutton="true"]:hover:not(:disabled),
        .formToolbar button.navbut[isbutton="true"]:hover:not(:disabled) {
            background: #EAEEFF !important;
            border-color: #C7CEE8 !important;
        }
        .formToolbar input[isbutton="true"]:disabled,
        .formToolbar button.navbut[isbutton="true"]:disabled {
            color: #9AA1B2 !important;
            border-color: #E4E7EF !important;
        }
        .formToolbar input.rpp, .formToolbar input.tp {
            border-radius: 6px !important; border: 1px solid #E4E7EF !important;
        }
        #basepanel { background: #ffffff; border: 1px solid #E4E7EF; border-radius: 10px; box-shadow: 0 1px 2px rgba(16,24,52,.04), 0 8px 24px rgba(16,24,52,.06); padding: 4px !important; }
        #tbl { border-collapse: separate !important; border-spacing: 0; width: 100%; font: 12.6px "Segoe UI", Arial, sans-serif; }
        #tbl thead th {
            background: #FAFBFD !important; color: #6B7280 !important;
            font-weight: 700 !important; text-transform: uppercase; font-size: 11px; letter-spacing: .03em;
            border: none !important; border-bottom: 1px solid #E4E7EF !important; padding: 10px 8px !important;
            cursor: pointer; white-space: nowrap;
        }
        #tbl tbody td, #tbl tbody th {
            border: none !important; border-bottom: 1px solid #EEF0F4 !important;
            padding: 8px !important; color: #1C2333;
        }
        #tbl tbody tr:hover td, #tbl tbody tr:hover th { background: #FAFBFD !important; }
        #tbl tbody tr.cellSel td, #tbl tbody tr.cellSel th { background: #EAEEFF !important; }
        #tbl tbody td.cellCur { background: transparent !important; }
        .formToolbar button.acc-tbtn {
            display: inline-flex !important; align-items: center; gap: 6px;
            background: #ffffff !important;
            border: 1px solid #E4E7EF !important;
            border-radius: 7px !important;
            color: #3457EF !important;
            font: 600 12.5px "Segoe UI", Arial, sans-serif !important;
            padding: 7px 14px !important;
            margin-right: 6px !important;
            cursor: pointer;
            box-shadow: none !important;
            transition: background .12s, border-color .12s;
        }
        .formToolbar button.acc-tbtn i { font-size: 12px; }
        .formToolbar button.acc-tbtn:hover:not(:disabled) {
            background: #EAEEFF !important;
            border-color: #C7CEE8 !important;
        }
        .formToolbar button.acc-tbtn:disabled {
            color: #9AA1B2 !important;
            border-color: #E4E7EF !important;
            cursor: not-allowed;
        }
    </style>

    <script>
        /* t:field id lari: 1=account_type_client_id, 2=account_type_id, 3=client_type,
           4=client_type_name, 5=state, 6=state_name, 7=code_coa, 8=currency_code */
        var FO_ID = 1;

        function responseModal(r) {
            if (r) {
                go({
                    url: "account_type_clients.jsp?account_type_id=<%=accountTypeId%>"
                });
            }
        }

        function add() {
            go({
                url: "account_type_client.jsp?process_code=CREATE_ACC_ACCOUNT_TYPE_CLIENT",
                param: {
                    account_type_id: "<%=accountTypeId%>"
                },
                target: "modalE",
                dialogHeight: 420,
                dialogWidth: 480,
                lock: false,
                callback: responseModal
            });
        }

        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "account_type_client.jsp?process_code=EDIT_ACC_ACCOUNT_TYPE_CLIENT",
                    param: {
                        model_process_code: "MODEL_ACC_ACCOUNT_TYPE_CLIENT",
                        account_type_id: "<%=accountTypeId%>",
                        account_type_client_id: getData(FO_ID)
                    },
                    target: "modalE",
                    dialogHeight: 420,
                    dialogWidth: 480,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function del() {
            if (!getDOM("bDelete").disabled) {
                if (confirm("<%=lang.get(si_confirm_delete)%>")) {
                    document.getElementById("accTypeClientDelId").value = getData(FO_ID);
                    document.fmAccTypeClientDel.submit();
                }
            }
        }

        function onAction() {
            edit();
        }

        function onLoad() {
            if (!dataExist()) {
                getDOM("bEdit").setDisable(true);
                getDOM("bDelete").setDisable(true);
            }
        }
    </script>
    <table class="formToolbar" align="center">
        <tr>
            <td>
                <button type="button" class="acc-tbtn" name="bAdd" onclick="add();"><i class="fas fa-plus"></i><span><%=lang.get(si_add)%></span></button>
                <button type="button" class="acc-tbtn" name="bEdit" onclick="edit();"><i class="fas fa-pen"></i><span><%=lang.get(si_edit)%></span></button>
                <button type="button" class="acc-tbtn" name="bDelete" onclick="del();"><i class="fas fa-trash-alt"></i><span><%=lang.get(si_delete)%></span></button>
            </td>
            <td id="tableControls" align="right">
                <input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
            </td>
        </tr>
    </table>
    <t:table from="ACC_ACCOUNT_TYPE_CLIENTS_V">
        <t:field id="1" name="account_type_client_id" label="<%=si_id%>"/>
        <t:field id="2" name="account_type_id" label="<%=si_account_type_id%>"/>
        <t:field id="3" name="client_type" label="<%=si_client_type%>"/>
        <t:field id="4" name="client_type_name" label="<%=si_client_type%>" type="quote"/>
        <t:field id="5" name="state" label="<%=si_state%>"/>
        <t:field id="6" name="state_name" label="<%=si_state%>" type="quote"/>
        <t:field id="7" name="code_coa" label="<%=si_code_coa%>">
            <t:filter operator="_like_" mask="20|"/>
        </t:field>
        <t:field id="8"  name="currency_code" label="<%=si_currency%>"/>
        <t:field id="9"  name="account_term_type" label="<%=si_account_term_type%>"/>
        <t:field id="10" name="subject_type" label="<%=si_subject_type%>"/>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="4" align="left"/>
            <t:column for="6"/>
            <t:column for="7"/>
            <t:column for="8"/>
            <t:column for="9"/>
            <t:column for="10"/>
        </t:grid>
    </t:table>
    <iframe name="frmAccTypeClientDel" style="display:none"></iframe>
    <form name="fmAccTypeClientDel" method="post" target="frmAccTypeClientDel">
        <input type="hidden" name="request" value="delete">
        <input type="hidden" name="process_code" value="DELETE_ACC_ACCOUNT_TYPE_CLIENT">
        <input type="hidden" name="account_type_client_id" id="accTypeClientDelId" value="">
        <input type="hidden" name="user_id" value="<%=user.getUserCode()%>">
    </form>
</t:form>
</t:page>
<t:requests>
    <t:request name="delete"><%
        try {
            stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
            out.print("<script>parent.location.reload();</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>
</t:requests>
<%!
    static final int si_title           = SI("Дочерние записи (Тип клиента / COA / Валюта)", "Дочерние записи", "Дочерние записи (Тип клиента / COA / Валюта)", "Child records (Client type / COA / Currency)");
    static final int si_add             = SI("Добавить", "Кушиш", "Qo'shish", "Add");
    static final int si_edit            = SI("Изменение", "Узгартириш", "O'zgartirish", "Edit");
    static final int si_delete          = SI("Удалить", "Учириш", "O'chirish", "Delete");
    static final int si_exit            = SI("Закрыть", "Ёпиш", "Yopish", "Close");
    static final int si_confirm_delete  = SI("Удалить дочернюю запись?", "Дочерняя записьни учирасизми?", "Dochernie zapisini o'chirasizmi?", "Delete child record?");
    static final int si_id              = SI("ID", "ID", "ID", "ID");
    static final int si_account_type_id = SI("Тип счёта", "Тип счёта", "Тип счёта", "Account type");
    static final int si_client_type     = SI("Тип клиента", "Мижоз тури", "Mijoz turi", "Client type");
    static final int si_state           = SI("Состояние", "Холати", "Holati", "State");
    static final int si_code_coa        = SI("Коды COA (Баланс код)", "Коды COA (Баланс код)", "COA kodlari (Balans kod)", "COA codes (Balance code)");
    static final int si_currency        = SI("Валюта", "Валюта", "Valyuta", "Currency");
    static final int si_account_term_type = SI("Срок счета", "?исоб муддати", "Hisob muddati", "Account Term");
    static final int si_subject_type = SI("Тип клиента", "Мижоз тури", "Mijoz turi", "Client Type");
%>
<%@ include file="/language.jsp" %>
