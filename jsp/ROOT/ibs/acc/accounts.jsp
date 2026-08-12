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
        /* t:field id larining tartibi (getData(N) uchun): 1=account_id, 2=account_code, 3=account_type_id,
           4=account_type_name, 5=account_type_code, 6=owner_type, 7=owner_type_name, 8=client_id,
           9=client_name, 10=object_id, 11=code_filial, 12=filial_name, 13=code_currency, 14=currency_name,
           15=abs_account_id, 16=account_status, 17=account_status_name, 18=date_open, 19=date_close,
           20=module_count */
        var FO_ID = 1;

        function responseModal(r) {
            if (r) {
                go({});
            }
        }

        function add() {
            go({
                url: "account.jsp?process_code=CREATE_ACC_ACCOUNT",
                target: "modalE",
                dialogHeight: 560,
                dialogWidth: 620,
                lock: false,
                callback: responseModal
            });
        }

        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "account.jsp?process_code=EDIT_ACC_ACCOUNT",
                    param: {
                        model_process_code: "MODEL_ACC_ACCOUNT",
                        account_id: getData(FO_ID)
                    },
                    target: "modalE",
                    dialogHeight: 560,
                    dialogWidth: 620,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function del() {
            if (!getDOM("bDelete").disabled) {
                if (confirm("<%=lang.get(si_confirm_delete)%>")) {
                    document.getElementById("accountDelId").value = getData(FO_ID);
                    document.fmAccountDel.submit();
                }
            }
        }

        function modules() {
            if (!getDOM("bModules").disabled) {
                go({
                    url: "account_modules.jsp",
                    param: {
                        account_id: getData(FO_ID)
                    },
                    target: "modalE",
                    dialogHeight: 480,
                    dialogWidth: 700,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function balance() {
            if (!getDOM("bBalance").disabled) {
                go({
                    url: "account_balance.jsp",
                    param: {
                        account_id: getData(FO_ID)
                    },
                    target: "modalE",
                    dialogHeight: 420,
                    dialogWidth: 560,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function onAction() {
            edit();
        }

        function onLoad() {
            if (!dataExist()) {
                getDOM("bEdit").setDisable(true);
                getDOM("bDelete").setDisable(true);
                getDOM("bModules").setDisable(true);
                getDOM("bBalance").setDisable(true);
            }
        }
    </script>
    <table class="formToolbar" align="center">
        <tr>
            <td>
                <button type="button" class="acc-tbtn" name="bAdd" onclick="add();"><i class="fas fa-plus"></i><span><%=lang.get(si_add)%></span></button>
                <button type="button" class="acc-tbtn" name="bEdit" onclick="edit();"><i class="fas fa-pen"></i><span><%=lang.get(si_edit)%></span></button>
                <button type="button" class="acc-tbtn" name="bDelete" onclick="del();"><i class="fas fa-trash-alt"></i><span><%=lang.get(si_delete)%></span></button>
                <button type="button" class="acc-tbtn" name="bModules" onclick="modules();"><i class="fas fa-puzzle-piece"></i><span><%=lang.get(si_modules)%></span></button>
                <button type="button" class="acc-tbtn" name="bBalance" onclick="balance();"><i class="fas fa-wallet"></i><span><%=lang.get(si_balance)%></span></button>
            </td>
            <td id="tableControls" align="right"></td>
        </tr>
        <tr align="center">
            <td colspan="2">
                <b><%=lang.get(si_search)%></b><span id="filterControls"></span>
            </td>
        </tr>
    </table>
    <t:table from="ACC_ACCOUNTS_V">
        <t:field id="1" name="account_id" label="<%=si_id%>">
            <t:filter mask="9|0-9-"/>
        </t:field>
        <t:field id="2" name="account_code" label="<%=si_account_code%>" type="quote">
            <t:filter operator="_like_" mask="30|"/>
        </t:field>
        <t:field id="3" name="account_type_id" label="<%=si_account_type%>">
            <t:filter optionSQL="select '<option value='|| account_type_id ||'>' || name from ACC_ACCOUNT_TYPES_V order by name"/>
        </t:field>
        <t:field id="4" name="account_type_name" label="<%=si_account_type%>" type="quote"/>
        <t:field id="5" name="account_type_code" label="<%=si_account_type_code%>" type="quote"/>
        <t:field id="6" name="owner_type" label="<%=si_owner_type%>">
            <t:filter optionSQL="select '<option value='||code||'>' || name from (select 'C' code, 'Клиент' name from dual union all select 'B', 'Bank' name from dual)"/>
        </t:field>
        <t:field id="7" name="owner_type_name" label="<%=si_owner_type%>" type="quote"/>
        <t:field id="8" name="client_id" label="<%=si_client%>">
            <t:filter mask="9|0-9-"/>
        </t:field>
        <t:field id="9" name="client_name" label="<%=si_client%>" type="quote">
            <t:filter operator="_search_" mask="200|"/>
        </t:field>
        <!--t:field id="10" name="object_id" label="<%//=si_object_id%>"/-->
        <t:field id="11" name="code_filial" label="<%=si_filial%>">
            <t:filter operator="_like_" mask="20|"/>
        </t:field>
        <t:field id="12" name="filial_name" label="<%=si_filial%>" type="quote"/>
        <t:field id="13" name="code_currency" label="<%=si_currency%>">
            <t:filter optionSQL="select '<option value='|| code ||'>' || char_code from CBR_CURRENCY_V order by char_code"/>
        </t:field>
        <t:field id="14" name="currency_name" label="<%=si_currency%>" type="quote"/>
        <t:field id="15" name="abs_account_id" label="<%=si_abs_account_id%>"/>
        <t:field id="16" name="account_status" label="<%=si_account_status%>">
            <t:filter optionSQL="select '<option value='||v||'>' || v from (select 'O' v from dual union all select 'C' from dual union all select 'B' from dual)"/>
        </t:field>
        <t:field id="17" name="account_status_name" label="<%=si_account_status%>" type="quote"/>
        <t:field id="18" name="date_open" label="<%=si_date_open%>" type="datetime">
            <t:filter operator="range" mask="datetime"/>
        </t:field>
        <t:field id="19" name="date_close" label="<%=si_date_close%>" type="datetime">
            <t:filter operator="range" mask="datetime"/>
        </t:field>
        <t:field id="20" name="module_count" label="<%=si_module_count%>"/>
        <t:field id="21" name="created_on" label="<%=si_created_on%>" type="datetime">
            <t:filter operator="range" mask="datetime"/>
        </t:field>
        <t:field id="22" name="created_by" label="<%=si_created_by%>"/>
        <t:field id="23" name="modified_on" label="<%=si_modified_on%>" type="datetime">
            <t:filter operator="range" mask="datetime"/>
        </t:field>
        <t:field id="24" name="modified_by" label="<%=si_modified_by%>"/>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="2"/>
            <t:column for="4" align="left"/>
            <t:column for="7"/>
            <t:column for="9" align="left"/>
            <t:column for="12"/>
            <t:column for="14"/>
            <t:column for="17"/>
            <t:column for="18"/>
            <t:column for="20"/>
            <t:foot><t:row>
                <t:cell for="21" size="100%"/>
                <t:cell for="22" size="100%"/>
                <t:cell for="23" size="100%"/>
                <t:cell for="24" size="100%"/>
            </t:row></t:foot>
        </t:grid>
    </t:table>
    <iframe name="frmAccountDel" style="display:none"></iframe>
    <form name="fmAccountDel" method="post" target="frmAccountDel">
        <input type="hidden" name="request" value="delete">
        <input type="hidden" name="process_code" value="DELETE_ACC_ACCOUNT">
        <input type="hidden" name="account_id" id="accountDelId" value="">
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
    static final int si_title              = SI("Счета клиентов", "Мижоз ?исоблари", "Hisob raqamlar", "Accounts");
    static final int si_add                = SI("Добавить", "?ўшиш", "Qo'shish", "Add");
    static final int si_edit               = SI("Изменить", "Ўзгартириш", "O'zgartirish", "Edit");
    static final int si_delete             = SI("Удалить", "Ўчириш", "O'chirish", "Delete");
    static final int si_modules            = SI("Модули счёта", "?исоб модуллари", "Hisob modullari", "Account modules");
    static final int si_balance            = SI("Остаток", "?олди?", "Qoldiq", "Balance");
    static final int si_search             = SI("Поиск:", "?идирув:", "Qidiruv:", "Search:");
    static final int si_confirm_delete     = SI("Удалить выбранный счёт?", "Танланган ?исобни ўчирасизми?", "Tanlangan hisobni o'chirasizmi?", "Delete the selected account?");
    static final int si_id                 = SI("ID", "ID", "ID", "ID");
    static final int si_account_code       = SI("Номер счёта", "?исоб ра?ами", "Hisob raqami", "Account number");
    static final int si_account_type       = SI("Тип счёта", "?исоб тури", "Hisob turi", "Account type");
    static final int si_account_type_code  = SI("Код типа счёта", "?исоб тури коди", "Hisob turi kodi", "Account type code");
    static final int si_owner_type         = SI("Владелец", "Эгаси", "Egasi", "Owner");
    static final int si_client             = SI("Клиент", "Мижоз", "Mijoz", "Client");
    static final int si_object_id          = SI("Object ID", "Object ID", "Object ID", "Object ID");
    static final int si_filial             = SI("Филиал", "Филиал", "Filial", "Branch");
    static final int si_currency           = SI("Валюта", "Валюта", "Valyuta", "Currency");
    static final int si_abs_account_id     = SI("ABS Account ID", "ABS Account ID", "ABS Account ID", "ABS account ID");
    static final int si_account_status     = SI("Статус", "?олати", "Holati", "Status");
    static final int si_date_open          = SI("Дата открытия", "Очилган сана", "Ochilgan sana", "Date open");
    static final int si_date_close         = SI("Дата закрытия", "Ёпилган сана", "Yopilgan sana", "Date close");
    static final int si_module_count       = SI("Кол-во модулей", "Модуллар сони", "Modullar soni", "Modules");
    static final int si_created_on         = SI("Дата создания", "Яратилган сана", "Yaratilgan sana", "Created on");
    static final int si_created_by         = SI("Кем создан", "Ким яратган", "Kim yaratgan", "Created by");
    static final int si_modified_on        = SI("Дата изменения", "Ўзгартирилган сана", "O'zgartirilgan sana", "Modified on");
    static final int si_modified_by        = SI("Кем изменён", "Ким ўзгартирган", "Kim o'zgartirgan", "Modified by");
%>
<%@ include file="/language.jsp" %>
