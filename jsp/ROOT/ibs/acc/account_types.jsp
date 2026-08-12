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
        /* t:field id larining tartibi (getData(N) uchun): 1=account_type_id, 2=code, 3=name,
           4=module_code, 5=module_name, 6=balance_type, 7=state, 8=state_name,
           9=unique_contract_flag, 10=unique_contract_name, 11=is_open_flag, 12=is_open_name,
           13=incode_type, 14=is_virtual, 15=is_virtual_name, 16=object_code, 17=child_count */
        var FO_ID = 1, FO_NAME = 3, FO_CHILD_COUNT = 17;

        function responseModal(r) {
            if (r) {
                go({});
            }
        }

        function add() {
            go({
                url: "account_type.jsp?process_code=CREATE_ACC_ACCOUNT_TYPE",
                target: "modalE",
                dialogHeight: 480,
                dialogWidth: 560,
                lock: false,
                callback: responseModal
            });
        }

        function edit() {
            if (!getDOM("bEdit").disabled) {
                go({
                    url: "account_type.jsp?process_code=EDIT_ACC_ACCOUNT_TYPE",
                    param: {
                        model_process_code: "MODEL_ACC_ACCOUNT_TYPE",
                        account_type_id: getData(FO_ID)
                    },
                    target: "modalE",
                    dialogHeight: 480,
                    dialogWidth: 560,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function del() {
            if (!getDOM("bDelete").disabled) {
                var msg = "<%=lang.get(si_confirm_delete)%>";
                if (Number(getData(FO_CHILD_COUNT)) > 0) {
                    msg += " <%=lang.get(si_confirm_delete_children)%>";
                }
                if (confirm(msg)) {
                    document.getElementById("accTypeDelId").value = getData(FO_ID);
                    document.fmAccTypeDel.submit();
                }
            }
        }

        function clients() {
            if (!getDOM("bClients").disabled) {
                go({
                    url: "account_type_clients.jsp",
                    param: {
                        account_type_id: getData(FO_ID)
                    },
                    target: "modalE",
                    dialogHeight: 560,
                    dialogWidth: 900,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function history() {
            if (!getDOM("bHistory").disabled) {
                go({
                    url: "account_type_history.jsp",
                    param: {
                        account_type_id: getData(FO_ID)
                    },
                    target: "modalE",
                    dialogHeight: 520,
                    dialogWidth: 720,
                    lock: false,
                    callback: responseModal
                });
            }
        }

        function catalog() {
            go({
                url: "account_type_catalog.jsp",
                target: "modalE",
                dialogHeight: 560,
                dialogWidth: 900,
                lock: false,
                callback: responseModal
            });
        }

        function onAction() {
            edit();
        }

        function onLoad() {
            if (!dataExist()) {
                getDOM("bEdit").setDisable(true);
                getDOM("bDelete").setDisable(true);
                getDOM("bClients").setDisable(true);
                getDOM("bHistory").setDisable(true);
            }
        }
    </script>
    <table class="formToolbar" align="center">
        <tr>
            <td>
                <button type="button" class="acc-tbtn" name="bAdd" onclick="add();"><i class="fas fa-plus"></i><span><%=lang.get(si_add)%></span></button>
                <button type="button" class="acc-tbtn" name="bEdit" onclick="edit();"><i class="fas fa-pen"></i><span><%=lang.get(si_edit)%></span></button>
                <button type="button" class="acc-tbtn" name="bDelete" onclick="del();"><i class="fas fa-trash-alt"></i><span><%=lang.get(si_delete)%></span></button>
                <button type="button" class="acc-tbtn" name="bClients" onclick="clients();"><i class="fas fa-sitemap"></i><span><%=lang.get(si_clients)%></span></button>
                <button type="button" class="acc-tbtn" name="bHistory" onclick="history();"><i class="fas fa-history"></i><span><%=lang.get(si_history)%></span></button>
                <button type="button" class="acc-tbtn" name="bCatalog" onclick="catalog();"><i class="fas fa-book"></i><span><%=lang.get(si_catalog)%></span></button>
            </td>
            <td id="tableControls" align="right"></td>
        </tr>
        <tr align="center">
            <td colspan="2">
                <b><%=lang.get(si_search)%></b><span id="filterControls"></span>
            </td>
        </tr>
    </table>
    <t:table from="ACC_ACCOUNT_TYPES_V">
        <t:field id="1" name="account_type_id" label="<%=si_id%>">
            <t:filter mask="9|0-9-"/>
        </t:field>
        <t:field id="2" name="code" label="<%=si_code%>" type="quote">
            <t:filter operator="_like_" mask="20|"/>
        </t:field>
        <t:field id="3" name="name" label="<%=si_name%>" type="quote">
            <t:filter operator="_search_" mask="200|"/>
        </t:field>
        <t:field id="4" name="module_code" label="<%=si_module%>">
            <t:filter optionSQL="select '<option value='|| module_code ||'>' || module_name from ACC_R_MODULES_V order by module_name"/>
        </t:field>
        <t:field id="5" name="module_name" label="<%=si_module%>" type="quote"/>
        <t:field id="6" name="balance_type" label="<%=si_balance_type%>" type="quote">
            <t:filter optionSQL="select '<option value='||v||'>' || v from (select 'Баланс' v from dual union all select 'Внебаланс' from dual)"/>
        </t:field>
        <t:field id="7" name="state" label="<%=si_state%>">
            <t:filter optionSQL="select '<option value='|| code ||'>' || name from r_state_v"/>
        </t:field>
        <t:field id="8" name="state_name" label="<%=si_state%>" type="quote"/>
        <t:field id="9" name="unique_contract_flag" label="<%=si_unique_contract%>"/>
        <t:field id="10" name="unique_contract_name" label="<%=si_unique_contract%>" type="quote"/>
        <t:field id="11" name="is_open_flag" label="<%=si_is_open%>"/>
        <t:field id="12" name="is_open_name" label="<%=si_is_open%>" type="quote"/>
        <t:field id="13" name="incode_type" label="<%=si_incode_type%>"/>
        <t:field id="14" name="is_virtual" label="<%=si_is_virtual%>"/>
        <t:field id="15" name="is_virtual_name" label="<%=si_is_virtual%>" type="quote"/>
        <t:field id="16" name="object_code" label="<%=si_object_code%>">
            <t:filter operator="_like_" mask="100|"/>
        </t:field>
        <t:field id="17" name="child_count" label="<%=si_child_count%>"/>
        <t:field id="18" name="created_on" label="<%=si_created_on%>" type="datetime">
            <t:filter operator="range" mask="datetime"/>
        </t:field>
        <t:field id="19" name="created_by" label="<%=si_created_by%>"/>
        <t:field id="20" name="modified_on" label="<%=si_modified_on%>" type="datetime">
            <t:filter operator="range" mask="datetime"/>
        </t:field>
        <t:field id="21" name="modified_by" label="<%=si_modified_by%>"/>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="2"/>
            <t:column for="3" align="left"/>
            <t:column for="5" align="left"/>
            <t:column for="6"/>
            <t:column for="8"/>
            <t:column for="10"/>
            <t:column for="12"/>
            <t:column for="17"/>
            <t:foot><t:row>
                <t:cell for="16" size="100%"/>
                <t:cell for="18" size="100%"/>
                <t:cell for="19" size="100%"/>
                <t:cell for="20" size="100%"/>
                <t:cell for="21" size="100%"/>
            </t:row></t:foot>
        </t:grid>
    </t:table>
    <iframe name="frmAccTypeDel" style="display:none"></iframe>
    <form name="fmAccTypeDel" method="post" target="frmAccTypeDel">
        <input type="hidden" name="request" value="delete">
        <input type="hidden" name="process_code" value="DELETE_ACC_ACCOUNT_TYPE">
        <input type="hidden" name="account_type_id" id="accTypeDelId" value="">
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
    static final int si_title                    = SI("Тип счёта", "Тип счёта", "Hisob turi", "Account type");
    static final int si_add                      = SI("Добавить", "Кушиш", "Qo'shish", "Add");
    static final int si_edit                      = SI("Изменение", "Узгартириш", "O'zgartirish", "Edit");
    static final int si_delete                    = SI("Удалить", "Учириш", "O'chirish", "Delete");
    static final int si_clients                   = SI("Дочерние записи", "Дочерние записи", "Дочерние записи", "Child records");
    static final int si_history                   = SI("История", "Тарих", "Tarix", "History");
    static final int si_catalog                   = SI("Типы Счетов", "Типы Счетов", "Hisob turlari", "Account classes");
    static final int si_search                    = SI("Поиск:", "Кидирув:", "Qidiruv:", "Search:");
    static final int si_confirm_delete            = SI("Удалить выбранный тип счёта?", "Танланган тип счётни учирасизми?", "Tanlangan hisob turini o'chirasizmi?", "Delete the selected account type?");
    static final int si_confirm_delete_children   = SI("Вместе с дочерними записями.", "Дочерние записи билан биргаликда.", "Dochernie zapisi bilan birga.", "Together with its child records.");
    static final int si_id                        = SI("ID", "ID", "ID", "ID");
    static final int si_code                      = SI("Тип счёт ID", "Тип счёт ID", "Тип счёт ID", "Account type ID");
    static final int si_name                      = SI("Наименование", "Номланиши", "Nomlanishi", "Name");
    static final int si_module                    = SI("Модуль", "Модуль", "Modul", "Module");
    static final int si_balance_type              = SI("Баланс/внебаланс", "Баланс/внебаланс", "Balans/vnebalans", "Balance/off-balance");
    static final int si_state                     = SI("Состояние", "Холати", "Holati", "State");
    static final int si_unique_contract           = SI("Уникал. договор", "Уникал. шартнома", "Unikal shartnoma", "Unique contract");
    static final int si_is_open                   = SI("IsOpen", "IsOpen", "IsOpen", "IsOpen");
    static final int si_incode_type               = SI("Тип кодирования", "Кодлаш тури", "Kodlash turi", "Incode type");
    static final int si_is_virtual                = SI("Виртуальный", "Виртуал", "Virtual", "Virtual");
    static final int si_object_code               = SI("Код объекта", "Объект коди", "Obyekt kodi", "Object code");
    static final int si_child_count               = SI("Дочерних записей", "Дочерних записей", "Dochernie zapisi", "Child records");
    static final int si_created_on                = SI("Дата создания", "Яратилган сана", "Yaratilgan sana", "Created on");
    static final int si_created_by                = SI("Кем создан", "Ким яратган", "Kim yaratgan", "Created by");
    static final int si_modified_on               = SI("Дата изменения", "Узгартирилган сана", "O'zgartirilgan sana", "Modified on");
    static final int si_modified_by               = SI("Кем изменён", "Ким узгартирган", "Kim o'zgartirgan", "Modified by");
%>
<%@ include file="/language.jsp" %>
