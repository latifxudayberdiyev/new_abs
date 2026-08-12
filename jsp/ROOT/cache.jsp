<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%
    Hashtable userCache = (Hashtable) session.getValue(Resource.STR_USER_CACHE);
    if (userCache == null) {
        userCache = new Hashtable();
        session.putValue(Resource.STR_USER_CACHE, userCache);
    }
    String cacheName = request.getParameter("n");
    userCache.put(cacheName, Boolean.TRUE);
%>