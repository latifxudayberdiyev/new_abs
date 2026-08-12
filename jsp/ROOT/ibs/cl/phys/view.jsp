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
%>
<t:page>
    <t:form title="<%= si_tittle%>" minWidth="fill" minHeight="fill">
        <link rel="stylesheet" href="css/style.css">
        <script>

        </script>
        <div>
            <div>
                <h3>Параметры поиска</h3>
                <table>
                    <tr>
                        <td>
                            <label>Код клиента</label><br>
                            <input type="text" oninput="this.value=this.value.replace(/\D/g,'');" type="text">
                        </td>
                        <td>
                            <label>Ф.И.О</label><br>
                            <input type="text">
                        </td>
                        <td>
                            <label>Серия документа</label><br>
                            <input type="text">
                        </td>
                        <td>
                            <label>Номер документа</label><br>
                            <input
                                    maxlength="7"
                                    oninput="this.value=this.value.replace(/\D/g,'');" type="text">
                        </td>
                        <td>
                            <label>Дата рождения</label><br>
                            <input type="text" mask="date">
                        </td>

                    </tr>

                    <tr>
                        <td colspan="5">
                            <button type="submit">Просмотр</button>
                            <button type="submit" style="background-color: #1d4ed8 !important;">Создать</button>
                            <button type="submit">Протокол</button>
                            <button type="submit" style="color: #1d4ed8;">Найти</button>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <%--        <div class="data-grid">--%>
        <%--            <t:dynmaicGrid gridId="5"/>--%>
        <%--        </div>--%>
    </t:form>
</t:page>
<%!
    static final int si_tittle = SI("Физическое лицо — Реестр клиентов", "search", "Qidiruv:", "Search:");
    static final int si_view = SI("Просмотр", "View", "Ko'rish", "Edit");
    static final int si_add = SI("Создать", "Add", "Qo'shish", "Add");
    static final int si_search = SI("Найти", "Search", "Qidiruv", "Search");
%>
<%@ include file="/language.jsp" %>