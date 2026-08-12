<%@ page contentType="text/html;charset=Windows-1251" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session"/>
<%
    //String url = request.getParameter("url") == null ? "jdbc:oracle:thin:@172.20.6.105:1521/PDB" : request.getParameter("url");
    String url = request.getParameter("url") == null ? "jdbc:oracle:thin:@172.25.57.41:1521/PDB" : request.getParameter("url");
    String userName = request.getParameter("userName") == null ? "crobs_v3" : request.getParameter("userName");
    String userPassword = request.getParameter("userPassword") == null ? "crobs_v3" : request.getParameter("userPassword");

    iabs.DBParameters params;

    if (!url.equals("") && !userName.equals("") && !userPassword.equals("")) {
        String spaces = "                         ";
        params = new iabs.DBParameters();
        params.put("url", spaces + url + spaces);
        params.put("userName", spaces + userName + spaces);
        params.put("userPassword", spaces + userPassword + spaces);
        params.saveToFile("/iabs.parameters");
		//params.saveToFile("/Projects/iabs/iabs/iabs.parameters");
		//params.saveToFile("/tomcat9_ABS/webapps/ROOT/iabs.parameters");
    }
%>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=windows-1251">
    <title>Изменение доступа к БД</title>
    <link rel=stylesheet type="text/css" href="/webapp/css/oracle.css">
</head>
<body>
<table style="border-style:solid; border-left-width:thin; border-bottom-width:thin;border-top-width:thin;border-right-width:thin;font-size:8pt"
       width="500" align="center" bgcolor="<%= cods.cTableBackground %>" bordercolor="<%= cods.cFrame %>" border="0"
       cellspacing="0">
    <tr>
        <td>
            <form name="fmEdit" action="iabsParameters.jsp">
                <table style="font-size:8pt" width="500" align="center" bgcolor="<%= cods.cTableBackground %>"
                       bordercolor="<%= cods.cFrame %>" border="0">
                    <thead>
                    <tr bordercolor="<%= cods.cFrame %>" border="0" class="vrTableHeader" style="text-align: center;">
                        <th colspan=4>Настройка доступа к БД
                    </thead>
                    <tbody>
                    <tr>
                        <td nowrap>URL доступа к БД:
                        <td><input class="pole" value="<%=url%>" name="url" size=70>
                    <tr>
                        <td>Логин:
                        <td><input class="pole" value="<%=userName%>" name="userName">
                    <tr>
                        <td>Пароль:
                        <td><input class="pole" value="<%=userPassword%>" name="userPassword">
                    <tr>
                        <td align=center><input type=submit class=cbutton value="Сохранить">
                        <td align=right><input type=button class=cbutton onClick="self.close()" value="Выход">
                </table>
                </tbody>
            </form>
</table>
</body>