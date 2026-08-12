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
    String accountId = request.getParameter("account_id");
    try {
        ServletCallableStatement cs = new ServletCallableStatement(stored, request);
        cs.setProcedure("User_Session.PUT_Number");
        cs.setString("i_Key", "acc_account_id");
        cs.setString("i_Value", accountId);
        cs.execute();
    } catch (Exception ex) {
        Util.alertUserMessage(ex, out);
    }
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <style>
        /* ===== fabrika-produktov.html uslubiga moslashtirilgan grid dizayni ===== */
        .formToolbar { border: none !important; background: none !important; box-shadow: none !important; margin-bottom: 10px; }
        .formToolbar td { border: none !important; }
        #basepanel { background: #ffffff; border: 1px solid #E4E7EF; border-radius: 10px; box-shadow: 0 1px 2px rgba(16,24,52,.04), 0 8px 24px rgba(16,24,52,.06); padding: 4px !important; }
        #tbl { border-collapse: separate !important; border-spacing: 0; width: 100%; font: 12.6px "Segoe UI", Arial, sans-serif; }
        #tbl thead th {
            background: #FAFBFD !important; color: #6B7280 !important;
            font-weight: 700 !important; text-transform: uppercase; font-size: 11px; letter-spacing: .03em;
            border: none !important; border-bottom: 1px solid #E4E7EF !important; padding: 10px 8px !important;
            white-space: nowrap;
        }
        #tbl tbody td, #tbl tbody th {
            border: none !important; border-bottom: 1px solid #EEF0F4 !important;
            padding: 8px !important; color: #1C2333;
        }
    </style>
    <table class="formToolbar" align="center">
        <tr>
            <td id="tableControls" align="right">
                <input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
            </td>
        </tr>
    </table>
    <t:table from="ACC_ACCOUNT_BALANCES_V">
        <t:field id="1" name="account_balance_id" label="<%=si_id%>"/>
        <t:field id="2" name="account_id" label="<%=si_account_id%>"/>
        <t:field id="3" name="saldo_in" label="<%=si_saldo_in%>"/>
        <t:field id="4" name="saldo_out" label="<%=si_saldo_out%>"/>
        <t:field id="5" name="income" label="<%=si_income%>"/>
        <t:field id="6" name="expense" label="<%=si_expense%>"/>
        <t:field id="7" name="income_all" label="<%=si_income_all%>"/>
        <t:field id="8" name="expense_all" label="<%=si_expense_all%>"/>
        <t:field id="9" name="sync_date" label="<%=si_sync_date%>" type="datetime"/>
        <t:grid page="" numbering="" withoutCursor="" hideFilterButton="">
            <t:column for="3"/>
            <t:column for="4"/>
            <t:column for="5"/>
            <t:column for="6"/>
            <t:column for="7"/>
            <t:column for="8"/>
            <t:column for="9"/>
        </t:grid>
    </t:table>
</t:form>
</t:page>
<%!
    static final int si_title       = SI("Остаток по счёту", "?исоб ?олди?и", "Hisob qoldig'i", "Account balance");
    static final int si_exit        = SI("Закрыть", "Ёпиш", "Yopish", "Close");
    static final int si_id          = SI("ID", "ID", "ID", "ID");
    static final int si_account_id  = SI("Счёт", "?исоб", "Hisob", "Account");
    static final int si_saldo_in    = SI("Сальдо вход.", "Кирувчи сальдо", "Kiruvchi saldo", "Saldo in");
    static final int si_saldo_out   = SI("Сальдо исход.", "Чи?увчи сальдо", "Chiquvchi saldo", "Saldo out");
    static final int si_income      = SI("Приход", "Кирим", "Kirim", "Income");
    static final int si_expense     = SI("Расход", "Чи?им", "Chiqim", "Expense");
    static final int si_income_all  = SI("Приход (всего)", "Кирим (жами)", "Kirim (jami)", "Income (total)");
    static final int si_expense_all = SI("Расход (всего)", "Чи?им (жами)", "Chiqim (jami)", "Expense (total)");
    static final int si_sync_date   = SI("Дата синхр.", "Синхр. санаси", "Sinxr. sanasi", "Sync date");
%>
<%@ include file="/language.jsp" %>
