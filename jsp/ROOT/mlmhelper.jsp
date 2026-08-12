<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*,uz.fido_biznes.cms.mlm.*" %>
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
    uz.fido_biznes.cms.Language lang = new uz.fido_biznes.cms.Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
    LanguageHelper lh = new LanguageHelper(request.getParameter("fileUrl"));
%><t:form title="<%=si_title%>" minWidth="fill" minHeight="fill">
    <style>
        table, input {
            width: 100%;
        }

        td {
            width: 25%;
        }
    </style>
    <div id=basepanel>
    <iframe name=frm style="display:none;"></iframe>
    <form name=fm target=frm>
    <input type=hidden name=request value=save>
    <table align=center width="100%" class=formToolbar cellspacing=2>
        <tr>
            <td><input type=submit value="<%=lang.get(si_add)%>" style="width:150px;">
    </table>

    <%
        out.print(lh.read());
    %>
</t:form>
</t:page>
<t:request name="save">
    <script><%
  try {
    String[] ru = request.getParameterValues("ru");
    String[] uzc = request.getParameterValues("uzc");
    for (int i=0;i<ru.length;i++){
      ru[i] = Util.encodeISO(ru[i], "Cp1251");
      uzc[i]= Util.encodeISO(uzc[i], "Cp1251");
    }
    LanguageHelper lh=new LanguageHelper(request.getParameter("fileUrl"));
    lh.write(request.getParameterValues("key"),ru,uzc,request.getParameterValues("uzl"),request.getParameterValues("en"));
    %>alert('<%=lang.get(si_saved)%>');
    top.returnValue = true;
    top.close();
    <%
      } catch(Exception ex) {
        out.print(ex);
        Util.alertUserMessage(ex, out, false);
        %>parent.pageLock(false);<%
        }
    %></script>
</t:request>
<%!
    static final int si_title = SI("Редактировать данные в JSP", "si_title", "si_title", "si_title");
    static final int si_add = SI("Сохранить", "si_add", "si_add", "si_add");
    static final int si_saved = SI("Успешно", "si_saved", "si_saved", "si_saved");
//-------------------------------------------------------------------------------------------------
%>
<%@ include file="/language.jsp" %>
