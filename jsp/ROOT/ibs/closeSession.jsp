<%@ page import="java.sql.*, java.util.*" contentType="text/html;charset=WINDOWS-1251"%>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session"/>
<html>
<head>
        <link rel=stylesheet type="text/css" href="/webapp/css/oracle.css">
        <meta http-equiv="Content-Type" content="text/html; charset=WINDOWS-1251">
        <title>Сотрудник:<%= (String)session.getValue("emplName")%>, Организация:<%= (String)session.getValue("filialName")%></title>
</head>
<%      

// ЭТА СТРАНИЧКА ГРОХАЕТ СЕССИЮ, НО ТОЛЬКО В ТОМ СЛУЧАЕ, ЕСЛИ МЫ РАБОТАЕМ ПОД МАГИКОМ.
//                         ОСТАВЛЕНА ДЛЯ СОВМЕСТИМОСТИ.
//           ДЛЯ РАБОТЫ БЕЗ МАГИКА ТУ ЖЕ ФУНКЦИЮ ВЫПОЛНЯЕТ FinalCode.jsp


// Убиваем коннект к базе (для освобождения ресурсов сервера)
if (session.getValue("ibs.task")==null) {
	try{
		if (cods.getConnection()!=null) cods.getConnection().close();
	}catch(Exception e){
		out.println(e.toString());
	}
	session.invalidate();
}
%>
</html>


