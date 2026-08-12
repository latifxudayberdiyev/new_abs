<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.driver.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
  Connection conn = cods.getConnection();
  if (conn == null || user.getUserCode() == null) 
    pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
  Language lang = new Language(user.getLanguageIndex(), sentences);
  pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
    ServletCallableStatement cs = new ServletCallableStatement(stored, request);
    cs.setFunction("User_Api.End_Time_Payments_Model");
    cs.execute();
    %><script>data=<%= cs.getStringResult() %></script><%
%><t:form noCache="" title="<%= si_formTitle %>" minWidth="800" minHeight="400">
    <script type="text/javascript">
        function vldTime() {
          return parseInt(this.value.substr(0,2))<24;
        }
    </script>
    <iframe name=frm style="display:none"></iframe>
    <form name=fm target=frm alert="Имеются заполненные некоректно или незаполненные обязательные поля!">
    <input type="hidden" name="request" value="save">
    <table align=center class=formToolbar cellspacing=2>
        <tr>
            <td><input type="submit" value="Сохранить"></td>
        </tr>
    </table>
    <div id="basepanel" class="panel">
        <table>
            <tr><td>&nbsp;</td></tr>
<%--            <tr>--%>
<%--                <td align=left nowrap>Дата окончания <q></q>:</td>--%>
<%--                <td><input name="to_date" mask="date" size="9" r=1></td>--%>
<%--            </tr>--%>
            <tr>
                <td align=left nowrap>Режим работы межбанковской платежной системы <q></q>:</td>
                <td><input name="interbank" size=5 a=c r=1 mask="{2|0-9}:{1|0-5}{1|0-9}" validate=vldTime></td>
            </tr>
            <tr>
                <td align=left nowrap>Режим работы межбанковской платежной системы денежного рынка <q></q>:</td>
                <td><input name="to_budget" size=5 a=c r=1 mask="{2|0-9}:{1|0-5}{1|0-9}" validate=vldTime></td>
            </tr>
            <tr>
                <td align=left nowrap>Режим работы межбанковской денежно кредитной платежной системы ЦБ РУз <q></q>:</td>
                <td><input name="to_cbu" size=5 a=c r=1 mask="{2|0-9}:{1|0-5}{1|0-9}" validate=vldTime></td>
            </tr>
            <tr>
                <td align=left nowrap>Время окончания межфилиальних платежей <q></q>:</td>
                <td><input name="interbranch" size=5 a=c r=1 mask="{2|0-9}:{1|0-5}{1|0-9}" validate=vldTime></td>
            </tr>
            <tr>
                <td align=left nowrap>Основание для изменения:</td>
                <td><textarea name="reason" rows=5 cols=40></textarea></td>
            </tr>
        </table>
    </div>
</t:form>
</t:page>
<t:requests><%
%><t:request name="save"><script><%
  try {
    ServletCallableStatement cs = new ServletCallableStatement(stored, request);
    cs.setProcedure("User_Api.Edit_End_Time_Payments");
    cs.setStringParameter("i_Interbank","interbank");
    cs.setStringParameter("i_Interbranch","interbranch");
    cs.setStringParameter("i_To_Budget","to_budget");
    cs.setStringParameter("i_To_Cbu","to_cbu");
    cs.setDateParameter("i_To_Date", "to_date");
    cs.setStringParameter("i_Reason","reason");
    cs.execute();
    %>alert("Данные сохранены успешно!");<%
  } catch (Exception ex) {
    Util.alertUserMessage(ex, out, false);
  } finally {
    %>parent.pageLock(false); parent.go({});<%
  }
%></script></t:request><%
%></t:requests>
<%!
    static final int si_formTitle = SI("Время окончания платежей","Тўловларнинг тугаш ва&#1179;ти","To'lovlarning tugash vaqti","");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
