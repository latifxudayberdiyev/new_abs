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
    </style>

    <table class="formToolbar" align="center">
        <tr>
            <td></td>
            <td id="tableControls" align="right">
                <input type="button" value="<%=lang.get(si_exit)%>" onclick="top.close()">
            </td>
        </tr>
    </table>
    <t:table from="ACC_R_CLASS_CATALOG_V">
        <t:field id="1" name="catalog_id" label="<%=si_id%>"/>
        <t:field id="2" name="class_code" label="<%=si_class%>"/>
        <t:field id="3" name="range_disp" label="<%=si_range%>"/>
        <t:field id="4" name="catalog_name" label="<%=si_name%>" type="quote"/>
        <t:field id="5" name="catalog_desc" label="<%=si_desc%>" type="quote"/>
        <t:field id="6" name="modules_list" label="<%=si_modules%>" type="quote"/>
        <t:grid page="" numbering="" withoutCursor="" withoutSortButtons="">
            <t:column for="2"/>
            <t:column for="3"/>
            <t:column for="4" align="left"/>
            <t:column for="5" align="left"/>
            <t:column for="6"/>
        </t:grid>
    </t:table>
</t:form>
</t:page>
<%!
    static final int si_title  = SI("Типы счетов — справочник", "Типы счетов — маълумотнома", "Hisob turlari - ma'lumotnoma", "Account classes - reference");
    static final int si_exit   = SI("Закрыть", "Ёпиш", "Yopish", "Close");
    static final int si_id     = SI("ID", "ID", "ID", "ID");
    static final int si_class  = SI("Класс", "Синф", "Sinf", "Class");
    static final int si_range  = SI("Диапазон счетов", "Счётлар диапазони", "Hisoblar diapazoni", "Account range");
    static final int si_name   = SI("Наименование", "Номланиши", "Nomlanishi", "Name");
    static final int si_desc   = SI("Описание", "Тавсиф", "Tavsif", "Description");
    static final int si_modules = SI("Обычно используется в модулях", "Одатда модулларда ишлатилади", "Odatda modullarda ishlatiladi", "Typically used in modules");
%>
<%@ include file="/language.jsp" %>
