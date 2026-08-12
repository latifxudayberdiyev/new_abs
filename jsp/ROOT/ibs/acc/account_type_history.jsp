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
    </style>

    <table class="formToolbar" align="center">
        <tr>
            <td></td>
            <td id="tableControls" align="right">
                <input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
            </td>
        </tr>
    </table>
    <t:table from="ACC_ACCOUNT_TYPE_HISTORY_V">
        <t:field id="1" name="history_id" label="<%=si_id%>"/>
        <t:field id="2" name="action_code" label="<%=si_action%>"/>
        <t:field id="3" name="action_name" label="<%=si_action%>" type="quote"/>
        <t:field id="4" name="modified_on" label="<%=si_modified_on%>" type="datetime"/>
        <t:field id="5" name="modified_by" label="<%=si_modified_by%>"/>
        <t:field id="6" name="after_snapshot" label="<%=si_details%>" type="quote"/>
        <t:grid page="" numbering="" withoutCursor="" withoutSortButtons="">
            <t:column for="3"/>
            <t:column for="4"/>
            <t:column for="5"/>
            <t:column for="6" align="left"/>
        </t:grid>
    </t:table>
</t:form>
</t:page>
<%!
    static final int si_title       = SI("История изменений записи", "Узгаришлар тарихи", "O'zgarishlar tarixi", "Change history");
    static final int si_exit        = SI("Закрыть", "Ёпиш", "Yopish", "Close");
    static final int si_id          = SI("ID", "ID", "ID", "ID");
    static final int si_action      = SI("Действие", "Амал", "Amal", "Action");
    static final int si_modified_on = SI("Дата", "Сана", "Sana", "Date");
    static final int si_modified_by = SI("Автор", "Муаллиф", "Muallif", "Author");
    static final int si_details     = SI("Детали", "Тафсилотлар", "Tafsilotlar", "Details");
%>
<%@ include file="/language.jsp" %>
