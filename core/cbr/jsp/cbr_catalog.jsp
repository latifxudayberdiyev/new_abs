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

    /* 19 ta Markaziy Bank spravochnigi: {ref_id, view_name, label_si_id} */
    int[] refIds = {6, 7, 8, 12, 14, 16, 17, 18, 26, 27, 52, 54, 57, 63, 72, 74, 92, 93, 125};
    String[] refViews = {
        "r_subject_type_v", "r_subject_sexual_identity_v", "r_verifying_document_type_v",
        "r_bank_v", "r_bank_type_v", "r_region_v", "r_currency_v", "r_country_v",
        "r_document_v", "r_rez_cl_v", "r_district_v", "r_tax_organization_v",
        "r_form_property_v", "r_organization_legal_form_v", "r_nation_v", "r_obraz_v",
        "r_coato_v", "r_business_form_v", "r_mahalla_v"
    };
    int[] refLabelIds = {
        si_ref_6, si_ref_7, si_ref_8, si_ref_12, si_ref_14, si_ref_16, si_ref_17, si_ref_18,
        si_ref_26, si_ref_27, si_ref_52, si_ref_54, si_ref_57, si_ref_63, si_ref_72, si_ref_74,
        si_ref_92, si_ref_93, si_ref_125
    };

    int refId = 6;
    try {
        refId = Integer.parseInt(request.getParameter("ref_id"));
    } catch (Exception ex) {
        refId = 6;
    }
    boolean refIdValid = false;
    for (int rid : refIds) {
        if (rid == refId) { refIdValid = true; break; }
    }
    if (!refIdValid) refId = 6;

    /* Joriy spravochnikning yangilanish jadvali (interval/oxirgi va keyingi Job holati) */
    String curInterval = "";
    String lastRefreshOn = "";
    String lastRefreshStatus = "";
    String lastRefreshMsg = "";
    String nextRefreshOn = "";
    if (conn != null) {
        PreparedStatement schedPs = conn.prepareStatement(
            "select refresh_interval, to_char(last_refresh_on,'dd.mm.yyyy hh24:mi:ss'), last_refresh_status, last_refresh_msg, " +
            "to_char(next_refresh_on,'dd.mm.yyyy hh24:mi:ss') " +
            "from cbr_r_references_v where ref_id = ?");
        schedPs.setInt(1, refId);
        ResultSet schedRs = schedPs.executeQuery();
        if (schedRs.next()) {
            curInterval = schedRs.getString(1);
            if (curInterval == null) curInterval = "";
            lastRefreshOn = schedRs.getString(2);
            if (lastRefreshOn == null) lastRefreshOn = "";
            lastRefreshStatus = schedRs.getString(3);
            if (lastRefreshStatus == null) lastRefreshStatus = "";
            lastRefreshMsg = schedRs.getString(4);
            if (lastRefreshMsg == null) lastRefreshMsg = "";
            nextRefreshOn = schedRs.getString(5);
            if (nextRefreshOn == null) nextRefreshOn = "";
        }
        schedRs.close();
        schedPs.close();
    }
%><t:page><%
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <script>
        function onRefChange(dom) {
            document.location = 'cbr_catalog.jsp?ref_id=' + dom.value;
        }
        function onLoad() {
            var sel = getDOM('refSelect');
            for (var k = 0; k < sel.options.length; k++) {
                if (sel.options[k].value == '<%=refId%>') sel.options[k].selected = true;
            }
        }
        function cbrManualRefresh() {
            document.fmCbrRefresh.submit();
        }
        function cbrSaveSchedule() {
            getDOM('cbrIntervalHidden').value = getDOM('cbrIntervalSelect').value;
            document.fmCbrSchedule.submit();
        }
    </script>
    <iframe name="frmCbrSched" style="display:none"></iframe>
    <form name="fmCbrRefresh" method="post" action="cbr_catalog.jsp" target="frmCbrSched">
        <input type="hidden" name="request" value="cbr_manual_refresh"/>
        <input type="hidden" name="process_code" value="CBR_MANUAL_REFRESH"/>
        <input type="hidden" name="ref_id" value="<%=refId%>"/>
    </form>
    <form name="fmCbrSchedule" method="post" action="cbr_catalog.jsp" target="frmCbrSched">
        <input type="hidden" name="request" value="cbr_set_schedule"/>
        <input type="hidden" name="process_code" value="CBR_SET_SCHEDULE"/>
        <input type="hidden" name="ref_id" value="<%=refId%>"/>
        <input type="hidden" id="cbrIntervalHidden" name="interval" value=""/>
    </form>
    <table class="formToolbar" align="center">
        <tr>
            <td>
                <%=lang.get(si_select_ref)%>:
                <select id="refSelect" onchange="onRefChange(this)"><%
                    for (int i = 0; i < refIds.length; i++) {
                %><option value="<%=refIds[i]%>"<%=refIds[i] == refId ? " selected" : ""%>>&#8470;<%=refIds[i]%> &mdash; <%=lang.get(refLabelIds[i])%></option><%
                    }
                %></select>
            </td>
            <td id="tableControls" align="right"></td>
        </tr>
        <tr align="center">
            <td colspan="2">
                <b><%=lang.get(si_search)%>
                </b><span id="filterControls"></span></td>
        </tr>
        <tr>
            <td colspan="2">
                <b><%=lang.get(si_schedule)%>:</b>
                <select id="cbrIntervalSelect">
                    <option value=""<%=curInterval.equals("") ? " selected" : ""%>><%=lang.get(si_interval_off)%></option>
                    <option value="15MIN"<%=curInterval.equals("15MIN") ? " selected" : ""%>><%=lang.get(si_interval_15min)%></option>
                    <option value="1HOUR"<%=curInterval.equals("1HOUR") ? " selected" : ""%>><%=lang.get(si_interval_1hour)%></option>
                    <option value="6HOUR"<%=curInterval.equals("6HOUR") ? " selected" : ""%>><%=lang.get(si_interval_6hour)%></option>
                    <option value="1DAY"<%=curInterval.equals("1DAY") ? " selected" : ""%>><%=lang.get(si_interval_1day)%></option>
                    <option value="10DAY"<%=curInterval.equals("10DAY") ? " selected" : ""%>><%=lang.get(si_interval_10day)%></option>
                    <option value="1MONTH"<%=curInterval.equals("1MONTH") ? " selected" : ""%>><%=lang.get(si_interval_1month)%></option>
                    <option value="1YEAR"<%=curInterval.equals("1YEAR") ? " selected" : ""%>><%=lang.get(si_interval_1year)%></option>
                </select>
                <input type="button" value="<%=lang.get(si_save_schedule)%>" onclick="cbrSaveSchedule()"/>
                &nbsp;&nbsp;
                <input type="button" value="<%=lang.get(si_refresh_now)%>" onclick="cbrManualRefresh()"/>
                &nbsp;&nbsp;<%
                if (!lastRefreshOn.equals("")) {
                    String statusLabel = lastRefreshStatus.equals("S") ? lang.get(si_status_ok) : lang.get(si_status_error);
            %><span><%=lang.get(si_last_refresh)%>: <%=lastRefreshOn%> (<%=statusLabel%><%
                    if (lastRefreshStatus.equals("E") && !lastRefreshMsg.equals("")) {
                %>: <%=lastRefreshMsg%><%
                    }
            %>)</span><%
                }
                if (!nextRefreshOn.equals("")) {
            %>&nbsp;&nbsp;<span><%=lang.get(si_next_refresh)%>: <%=nextRefreshOn%></span><%
                }
            %>
            </td>
        </tr>
    </table>
<%
    if (refId == 6) {
%>
    <t:table from="cbr_subject_type_v" sessionName="cbr_subject_type">
        <t:field id="1" name="code" label="<%=si_code_6%>"/>
        <t:field id="2" name="name" label="<%=si_name_6%>" type="quote">
            <t:filter operator="_search_" mask="40|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 7) {
%>
    <t:table from="cbr_subject_sexual_identity_v" sessionName="cbr_subject_sexual_identity">
        <t:field id="1" name="code" label="<%=si_code_7%>"/>
        <t:field id="2" name="name" label="<%=si_name_7%>" type="quote">
            <t:filter operator="_search_" mask="10|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 8) {
%>
    <t:table from="cbr_verifying_document_type_v" sessionName="cbr_verifying_document_type">
        <t:field id="1" name="code" label="<%=si_code_8%>"/>
        <t:field id="2" name="name" label="<%=si_name_8%>" type="quote">
            <t:filter operator="_search_" mask="50|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 12) {
%>
    <t:table from="cbr_bank_v" sessionName="cbr_bank">
        <t:field id="1" name="code" label="<%=si_code_12%>"/>
        <t:field id="2" name="name" label="<%=si_name_12%>" type="quote">
            <t:filter operator="_search_" mask="80|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 14) {
%>
    <t:table from="cbr_bank_type_v" sessionName="cbr_bank_type">
        <t:field id="1" name="code" label="<%=si_code_14%>"/>
        <t:field id="2" name="name" label="<%=si_name_14%>" type="quote">
            <t:filter operator="_search_" mask="40|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 16) {
%>
    <t:table from="cbr_region_v" sessionName="cbr_region">
        <t:field id="1" name="code" label="<%=si_code_16%>"/>
        <t:field id="2" name="name" label="<%=si_name_16%>" type="quote">
            <t:filter operator="_search_" mask="30|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 17) {
%>
    <t:table from="cbr_currency_v" sessionName="cbr_currency">
        <t:field id="1" name="code" label="<%=si_code_17%>"/>
        <t:field id="2" name="name" label="<%=si_name_17%>" type="quote">
            <t:filter operator="_search_" mask="35|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 18) {
%>
    <t:table from="cbr_country_v" sessionName="cbr_country">
        <t:field id="1" name="code" label="<%=si_code_18%>"/>
        <t:field id="2" name="name" label="<%=si_name_18%>" type="quote">
            <t:filter operator="_search_" mask="60|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 26) {
%>
    <t:table from="cbr_document_v" sessionName="cbr_document">
        <t:field id="1" name="code" label="<%=si_code_26%>"/>
        <t:field id="2" name="name" label="<%=si_name_26%>" type="quote">
            <t:filter operator="_search_" mask="30|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 27) {
%>
    <t:table from="cbr_rez_cl_v" sessionName="cbr_rez_cl">
        <t:field id="1" name="code" label="<%=si_code_27%>"/>
        <t:field id="2" name="name" label="<%=si_name_27%>" type="quote">
            <t:filter operator="_search_" mask="20|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 52) {
%>
    <t:table from="cbr_district_v" sessionName="cbr_district">
        <t:field id="1" name="code" label="<%=si_code_52%>"/>
        <t:field id="2" name="name" label="<%=si_name_52%>" type="quote">
            <t:filter operator="_search_" mask="30|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 54) {
%>
    <t:table from="cbr_tax_organization_v" sessionName="cbr_tax_organization">
        <t:field id="1" name="code" label="<%=si_code_54%>"/>
        <t:field id="2" name="name" label="<%=si_name_54%>" type="quote">
            <t:filter operator="_search_" mask="80|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 57) {
%>
    <t:table from="cbr_form_property_v" sessionName="cbr_form_property">
        <t:field id="1" name="code" label="<%=si_code_57%>"/>
        <t:field id="2" name="name" label="<%=si_name_57%>" type="quote">
            <t:filter operator="_search_" mask="100|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 63) {
%>
    <t:table from="cbr_organization_legal_form_v" sessionName="cbr_organization_legal_form">
        <t:field id="1" name="code" label="<%=si_code_63%>"/>
        <t:field id="2" name="name" label="<%=si_name_63%>" type="quote">
            <t:filter operator="_search_" mask="80|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 72) {
%>
    <t:table from="cbr_nation_v" sessionName="cbr_nation">
        <t:field id="1" name="code" label="<%=si_code_72%>"/>
        <t:field id="2" name="nation_name" label="<%=si_name_72%>" type="quote">
            <t:filter operator="_search_" mask="15|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 74) {
%>
    <t:table from="cbr_obraz_v" sessionName="cbr_obraz">
        <t:field id="1" name="code" label="<%=si_code_74%>"/>
        <t:field id="2" name="obraz_name" label="<%=si_name_74%>" type="quote">
            <t:filter operator="_search_" mask="20|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 92) {
%>
    <t:table from="cbr_coato_v" sessionName="cbr_coato">
        <t:field id="1" name="code" label="<%=si_code_92%>"/>
        <t:field id="2" name="uzb_lat_name" label="<%=si_name%>" type="quote">
            <t:filter operator="_search_" mask="60|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 93) {
%>
    <t:table from="cbr_business_form_v" sessionName="cbr_business_form">
        <t:field id="1" name="code" label="<%=si_code_93%>"/>
        <t:field id="2" name="name_rus" label="<%=si_name%>" type="quote">
            <t:filter operator="_search_" mask="150|"/>
        </t:field>
        <t:field id="3" name="date_activ" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_deact" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    } else if (refId == 125) {
%>
    <t:table from="cbr_mahalla_v" sessionName="cbr_mahalla">
        <t:field id="1" name="code_uz_cad" label="<%=si_code_125%>"/>
        <t:field id="2" name="name_uz" label="<%=si_name%>" type="quote">
            <t:filter operator="_search_" mask="50|"/>
        </t:field>
        <t:field id="3" name="date_open" label="<%=si_date_activ%>" type="date"/>
        <t:field id="4" name="date_close" label="<%=si_date_deact%>" type="date"/>
        <t:field id="5" name="state_name" label="<%=si_state%>">
            <t:filter option="<%=si_state_option%>"/>
        </t:field>
        <t:grid page="" numbering="" withoutCursor="">
            <t:column for="1"/>
            <t:column for="2" align="left"/>
            <t:column for="5"/>
        </t:grid>
    </t:table>
<%
    }
%>
</t:form>
</t:page>
<t:requests>
    <t:request name="cbr_manual_refresh"><%
        try {
            stored.execJsonRequestProcedure("Core_Api.Execute_Process_Clob", request);
            out.print("<script>parent.location.reload();</script>");
        } catch (Exception ex) {
            response.setHeader("RT", "alert");
            Util.alertUserMessage(ex, out);
        }
    %></t:request>
    <t:request name="cbr_set_schedule"><%
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
    static final int si_title       = SI("Справочники ЦБ", "Марказий банк маълумотномалари", "MB spravochniklari", "CB references");
    static final int si_select_ref  = SI("Справочник", "Маълумотнома", "Spravochnik", "Reference");
    static final int si_search      = SI("Поиск:", "Қидирув:", "Qidiruv:", "Search:");
    static final int si_code        = SI("Код", "Код", "Kod", "Code");
    static final int si_name        = SI("Наименование", "Номи", "Nomi", "Name");
    static final int si_name_uz     = SI("Наименование (УЗ)", "Номи (УЗ)", "Nomi (UZ)", "Name (UZ)");
    static final int si_name_ru     = SI("Наименование (РУ)", "Номи (РУ)", "Nomi (RU)", "Name (RU)");
    static final int si_state       = SI("Состояние", "Ҳолати", "Holati", "State");
    static final int si_state_option = SI(
        "<option value=''>Все<option value='Актив'>Актив<option value='Пассив'>Пассив",
        "<option value=''>Барчаси<option value='Актив'>Актив<option value='Пассив'>Пассив",
        "<option value=''>Barchasi<option value='Актив'>Актив<option value='Пассив'>Пассив",
        "<option value=''>All<option value='Актив'>Актив<option value='Пассив'>Пассив");
    static final int si_schedule       = SI("Автообновление", "Автоматик янгилаш", "Avtomatik yangilash", "Auto-refresh");
    static final int si_interval_off   = SI("Отключено", "Ўчирилган", "O'chirilgan", "Disabled");
    static final int si_interval_15min = SI("Каждые 15 минут", "Ҳар 15 дақиқада", "Har 15 daqiqada", "Every 15 minutes");
    static final int si_interval_1hour = SI("Каждый час", "Ҳар соатда", "Har soatda", "Every hour");
    static final int si_interval_6hour = SI("Каждые 6 часов", "Ҳар 6 соатда", "Har 6 soatda", "Every 6 hours");
    static final int si_interval_1day  = SI("Каждый день", "Ҳар куни", "Har kuni", "Every day");
    static final int si_interval_10day = SI("Каждые 10 дней", "Ҳар 10 кунда", "Har 10 kunda", "Every 10 days");
    static final int si_interval_1month = SI("Каждый месяц", "Ҳар ойда", "Har oyda", "Every month");
    static final int si_interval_1year = SI("Каждый год", "Ҳар йилда", "Har yilda", "Every year");
    static final int si_save_schedule  = SI("Сохранить", "Сақлаш", "Saqlash", "Save");
    static final int si_refresh_now    = SI("Обновить сейчас", "Ҳозир янгилаш", "Hozir yangilash", "Refresh now");
    static final int si_last_refresh   = SI("Последнее обновление", "Охирги янгиланиш", "Oxirgi yangilanish", "Last refresh");
    static final int si_next_refresh   = SI("Следующее обновление (Job)", "Кейинги янгиланиш (Job)", "Keyingi yangilanish (Job)", "Next refresh (Job)");
    static final int si_status_ok      = SI("успешно", "муваффақиятли", "muvaffaqiyatli", "success");
    static final int si_status_error   = SI("ошибка", "хатолик", "xatolik", "error");
    static final int si_code_6      = SI("Код типа субъекта", "Субъект тури коди", "Subyekt turi kodi", "Subject type code");
    static final int si_name_6      = SI("Наименование типа субъекта", "Субъект тури номи", "Subyekt turi nomi", "Subject type name");
    static final int si_code_7      = SI("Код пола субъекта", "Жинс коди", "Jins kodi", "Sex code");
    static final int si_name_7      = SI("Наименование пола субъекта", "Жинс номи", "Jins nomi", "Sex name");
    static final int si_code_8      = SI("Код вида документа", "Ҳужжат тури коди", "Hujjat turi kodi", "Document type code");
    static final int si_name_8      = SI("Наименование вида документа", "Ҳужжат тури номи", "Hujjat turi nomi", "Document type name");
    static final int si_code_12     = SI("Код банка", "Банк коди", "Bank kodi", "Bank code");
    static final int si_name_12     = SI("Наименование банка", "Банк номи", "Bank nomi", "Bank name");
    static final int si_code_14     = SI("Код типа банка", "Банк тури коди", "Bank turi kodi", "Bank type code");
    static final int si_name_14     = SI("Наименование типа банка", "Банк тури номи", "Bank turi nomi", "Bank type name");
    static final int si_code_16     = SI("Код области", "Вилоят коди", "Viloyat kodi", "Region code");
    static final int si_name_16     = SI("Наименование области", "Вилоят номи", "Viloyat nomi", "Region name");
    static final int si_code_17     = SI("Код валюты", "Валюта коди", "Valyuta kodi", "Currency code");
    static final int si_name_17     = SI("Наименование валюты", "Валюта номи", "Valyuta nomi", "Currency name");
    static final int si_code_18     = SI("Код страны", "Давлат коди", "Davlat kodi", "Country code");
    static final int si_name_18     = SI("Наименование страны", "Давлат номи", "Davlat nomi", "Country name");
    static final int si_code_26     = SI("Код документа", "Ҳужжат коди", "Hujjat kodi", "Document code");
    static final int si_name_26     = SI("Наименование вида платежного документа", "Тўлов ҳужжати номи", "To'lov hujjati nomi", "Payment document name");
    static final int si_code_27     = SI("Код резидентности", "Резидентлик коди", "Rezidentlik kodi", "Residency code");
    static final int si_name_27     = SI("Наименование резидентности", "Резидентлик номи", "Rezidentlik nomi", "Residency name");
    static final int si_code_52     = SI("Код района", "Туман коди", "Tuman kodi", "District code");
    static final int si_name_52     = SI("Наименование района", "Туман номи", "Tuman nomi", "District name");
    static final int si_code_54     = SI("Код ГНИ", "ГНИ коди", "GNI kodi", "Tax office code");
    static final int si_name_54     = SI("Наименование ГНИ", "ГНИ номи", "GNI nomi", "Tax office name");
    static final int si_code_57     = SI("Код формы собственности", "Мулкчилик шакли коди", "Mulkchilik shakli kodi", "Property form code");
    static final int si_name_57     = SI("Наименование формы собственности", "Мулкчилик шакли номи", "Mulkchilik shakli nomi", "Property form name");
    static final int si_code_63     = SI("Код ОПФ", "ТХШ коди", "TXSH kodi", "Legal form code");
    static final int si_name_63     = SI("Наименование ОПФ", "ТХШ номи", "TXSH nomi", "Legal form name");
    static final int si_code_72     = SI("Код национальности", "Миллат коди", "Millat kodi", "Nationality code");
    static final int si_name_72     = SI("Наименование национальности", "Миллат номи", "Millat nomi", "Nationality name");
    static final int si_code_74     = SI("Код образования", "Таълим коди", "Ta'lim kodi", "Education code");
    static final int si_name_74     = SI("Наименование образования", "Таълим номи", "Ta'lim nomi", "Education name");
    static final int si_code_92     = SI("Код СОАТО", "СОАТО коди", "SOATO kodi", "SOATO code");
    static final int si_code_93     = SI("Код ОПФ (новый)", "ТХШ коди (янги)", "TXSH kodi (yangi)", "Legal form code (new)");
    static final int si_code_125    = SI("Код махалли", "Маҳалла коди", "Mahalla kodi", "Mahalla code");
    static final int si_date_activ  = SI("Действует с", "Амал бошланиши", "Amal boshlanishi", "Active from");
    static final int si_date_deact  = SI("Действует по", "Амал тугаши", "Amal tugashi", "Active until");
    static final int si_date_open   = SI("Дата открытия", "Очилган сана", "Ochilgan sana", "Open date");
    static final int si_date_close  = SI("Дата закрытия", "Ёпилган сана", "Yopilgan sana", "Close date");
    static final int si_order_by    = SI("Порядок", "Тартиб", "Tartib", "Order");
    static final int si_char_code   = SI("Букв. код", "Ҳарф коди", "Harf kodi", "Char code");
    static final int si_scale       = SI("Кол-во знаков", "Каср хонаси", "Kasr xonasi", "Scale");
    static final int si_currency    = SI("Валюта", "Валюта", "Valyuta", "Currency");
    static final int si_region      = SI("Область", "Вилоят", "Viloyat", "Region");
    static final int si_district    = SI("Район", "Туман", "Tuman", "District");
    static final int si_country     = SI("Страна", "Мамлакат", "Mamlakat", "Country");
    static final int si_bank_type_code = SI("Код типа банка", "Банк тури коди", "Bank turi kodi", "Bank type code");
    static final int si_address     = SI("Адрес", "Манзил", "Manzil", "Address");
    static final int si_status_code = SI("Код статуса", "Статус коди", "Status kodi", "Status code");
    static final int si_account_type = SI("Тип счета", "Ҳисоб тури", "Hisob turi", "Account type");
    static final int si_active      = SI("Активен", "Фаол", "Faol", "Active");
    static final int si_email       = SI("Email", "Email", "Email", "Email");
    static final int si_short_name  = SI("Кратк. наим.", "Қисқа номи", "Qisqa nomi", "Short name");
    static final int si_group_code  = SI("Код группы", "Гуруҳ коди", "Guruh kodi", "Group code");
    static final int si_ref_6   = SI("Типы субъектов", "Субъектлар тури", "Subyektlar turlari", "Subject types");
    static final int si_ref_7   = SI("Половая принадлежность субъекта", "Субъектнинг жинси", "Subyektning jinsi", "Subject sexual identity");
    static final int si_ref_8   = SI("Виды удостоверяющих документов", "Тасдиқловчи ҳужжат тури", "Tasdiqlovchi hujjat turlari", "Verifying document types");
    static final int si_ref_12  = SI("Отделения банков РУз", "Ўзбекистон банклари бўлимлари", "O'zbekiston banklari bo'limlari", "Bank branches of Uzbekistan");
    static final int si_ref_14  = SI("Банки РУз", "Ўзбекистон банклари", "O'zbekiston banklari", "Banks of Uzbekistan");
    static final int si_ref_16  = SI("Области РУз", "Ўзбекистон вилоятлари", "O'zbekiston viloyatlari", "Regions of Uzbekistan");
    static final int si_ref_17  = SI("Валюты", "Валюталар", "Valyutalar", "Currencies");
    static final int si_ref_18  = SI("Страны и территории", "Давлатлар ва ҳудудлар", "Davlatlar va hududlar", "Countries and territories");
    static final int si_ref_26  = SI("Виды платежных документов", "Тўлов ҳужжатлари тури", "To'lov hujjatlari turlari", "Payment document types");
    static final int si_ref_27  = SI("Резидентность клиентов", "Мижозлар резидентлиги", "Mijozlar rezidentligi", "Client residency");
    static final int si_ref_52  = SI("Районы РУз", "Ўзбекистон туманлари", "O'zbekiston tumanlari", "Districts of Uzbekistan");
    static final int si_ref_54  = SI("Коды ГНИ", "ГНИ кодлари", "GNI kodlari", "Tax inspection codes");
    static final int si_ref_57  = SI("Формы собственности", "Мулкчилик шакллари", "Mulkchilik shakllari", "Forms of property");
    static final int si_ref_63  = SI("Организационно-правовые формы (ОПФ)", "Ташкилий-ҳуқуқий шакллар", "Tashkiliy-huquqiy shakllar (TXSH)", "Legal organization forms");
    static final int si_ref_72  = SI("Национальности", "Миллатлар", "Millatlar", "Nationalities");
    static final int si_ref_74  = SI("Образование", "Таълим", "Ta'lim", "Education");
    static final int si_ref_92  = SI("Районы СОАТО", "СОАТО туманлари", "SOATO tumanlari", "SOATO districts");
    static final int si_ref_93  = SI("Организационно-правовые формы (новый)", "Ташкилий-ҳуқуқий шакллар (янги)", "Tashkiliy-huquqiy shakllar (yangi)", "Legal organization forms (new)");
    static final int si_ref_125 = SI("Махалля", "Маҳаллалар", "Mahallalar", "Mahalla");
%>
<%@ include file="/language.jsp" %>
