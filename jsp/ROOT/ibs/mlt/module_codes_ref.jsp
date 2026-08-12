<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="uz.fido_biznes.cms.*" %>
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
%>
<t:references>
    <t:reference name="get_module_code">
        <t:table from="core.MLT_MODULE_V">
            <t:field id="1" name="code" label="<%=si_module_code%>">
                <t:filter operator="_like_" size="10" showInGrid=""/>
            </t:field>
            <t:field id="2" name="name" label="<%=si_module_name%>" type="quote">
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
    static final int si_module_code = SI("Module Code", "Module Code", "Modul kodi", "Module Code");
    static final int si_module_name = SI("Module Name", "Module Name", "Modul nomi", "Module Name");
%>
<%@ include file="/language.jsp" %>