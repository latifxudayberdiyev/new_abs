<%@ page import="java.text.SimpleDateFormat, java.sql.*, oracle.sql.*, oracle.jdbc.*, java.math.BigDecimal" contentType="text/html;charset=Windows-1251"%>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<%
    int tabindex=1; //эта переменная будет ставиться в тегах input для того чтобы скрипт goNext работал
if (cods.getConnection()==null)
{
    response.sendRedirect("sessionOut.html");
    return;
}
String dbg = "0";
try
{
// total try
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
        <title>Просмотр счетов</title>
        <link rel=stylesheet type="text/css" href="/webapp/css/oracle.css">
        <meta http-equiv="Content-Type" content="text/html; charset=WINDOWS-1251">

<%
// это чтобы вернуться в ту же строчку, где были на предыдущей форме
dbg="1";
String selected = request.getParameter("selected");
String active = "";
    if (selected!=null && !selected.trim().equals("null"))
    {
        session.putValue("acc_selected",request.getParameter("selected"));
    } else
    {
        selected = "";
    }

Connection conn = cods.getConnection();
Statement stmt = conn.createStatement();
ResultSet rset;
CallableStatement cstmt;

String plan = new String();
int i = 0;
String id = request.getParameter("id");
String date_ = request.getParameter("date");
String condition = new String();
String DV = new String();
String filialCode = new String();
String filialName = new String();
String mask = new String();
String Group = new String();
String keyCode = new String();

try
{
    if (id != null)
    {
        plan = id.substring(0,1);
    }
    else
    {
        plan = request.getParameter("plan");
    }
}
catch(Exception e)
{
    out.println(e.getMessage());
}

try
{
    String func = "setup.get_operday()";
    if (id != null)
    {
        func = "account.get_max_date('" + id + "') ";
    }

    cstmt = conn.prepareCall ("{? = call " + func + " } ");
    cstmt.registerOutParameter (1, Types.DATE);
    cstmt.execute ();
    java.util.Date today = cstmt.getDate(1)!=null?cstmt.getDate(1):new java.util.Date();
    cstmt.close();
    SimpleDateFormat df = new SimpleDateFormat("dd.MM.yyyy");
    DV = df.format(today);

    cstmt = conn.prepareCall ("{? = call account.Get_Mask_Acc(" + plan + ") } ");
    cstmt.registerOutParameter (1, Types.VARCHAR);
    cstmt.execute ();
    mask = cstmt.getString(1)!=null?cstmt.getString(1):"";
    cstmt.close();

    cstmt = conn.prepareCall ("{? = call setup.Get_Local_Code() } ");
    cstmt.registerOutParameter (1, Types.VARCHAR);
    cstmt.execute ();
    filialCode = cstmt.getString(1)!=null?cstmt.getString(1):"";
    cstmt.close();

    cstmt = conn.prepareCall ("{? = call bank.Get_Local_Name('"+filialCode+"') } ");
    cstmt.registerOutParameter (1, Types.VARCHAR);
    cstmt.execute ();
    filialName = cstmt.getString(1)!=null?cstmt.getString(1):"";
    cstmt.close();
}
catch(Exception e)
{
    out.println("Error in mask: "  + e.toString());
    return;
}

%>

<script language="JavaScript">

cl='A';

function setBalance()
{

        var a = "0";
        try
        {
            a= event.srcElement.value;
        }
        catch  (exception)
        {
            a=document.client.FIELD_4.value;
        }

        a=a.substr(0,1);
        if (a=='1' || a=='5' || a=='3' || a=='9')
        {
                document.client.Active[0].checked=true;
        }
        if (a=='2' || a=='4')
        {
                document.client.Active[1].checked=true;
        }
        if (a=='9')
        {
                document.client.Balance[1].checked=true;
        }
}
function fillData()
{



    var allow = false; // эта переменная для того чтобы сихнронно выполнялся дблинк для запросов в базу
    // переменные для того чтобы их передать методом get при первой загрузке, чтобы все справочники сразу отразились
    var varObj = new Array();
    var varName = new Array();
    var Name1 = new Array();
    var total = 0;
<%
    String getModal = "";
    if (id != null)
    {
        String select = new String();

        if(date_ == null)
        {
            select = "select a.condition, a.sign_registr, a.name, a.liability_active, to_char(a.date_validate,'dd.mm.yyyy'), b.name, r.name, a.balance_out " +
                     "from accounts_history a, v_acc_condition b, v_acc_registr r where a.id in " +
                     "(select id from accounts where code='" + id + "') and " +
                     "a.condition=b.code and a.sign_registr=r.code and trunc(a.date_validate)=trunc(account.get_nearest_date('" + id + "'))";
        }
        else
        {
            select = "select a.condition, a.sign_registr, a.name, a.liability_active, to_char(a.date_validate,'dd.mm.yyyy'), b.name, r.name, a.balance_out " +
                     "from accounts_history a, v_acc_condition b, v_acc_registr r where a.id in " +
                     "(select id from accounts where code='" + id + "') and " +
                     "a.condition=b.code and a.sign_registr=r.code and trunc(a.date_validate)=trunc(to_date('" + date_ + "','dd.mm.yyyy'))";
        }

        try
        {
            rset = stmt.executeQuery(select);
            if (rset.next())
            {
                condition = rset.getObject(1)!=null?rset.getString(1).trim():"";
                active = rset.getObject(4)!=null?rset.getString(4).trim():"";
                String balance = rset.getObject(8)!=null?rset.getString(8).trim():"";

                if ((date_ == null) || (date_.length() == 0))
                {
                    date_ = rset.getObject(5)!=null?rset.getString(5):"";
                }

%>

    document.client.ConditionCode.value  = "<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>";
    document.client.RegisterSignCode.value  = "<%= rset.getObject(2)!=null?rset.getString(2).trim():"" %>";
    document.client.Name.value  = "<%= cods.quotesEsc(rset.getObject(3)!=null?rset.getString(3).trim():"") %>";
    document.client.Liability.value  = "<%= rset.getObject(4)!=null?rset.getString(4).trim():"" %>";
    document.client.Condition.value  = "<%= rset.getObject(6)!=null?rset.getString(6).trim():"" %>";
    document.client.RegisterSign.value  = "<%= rset.getObject(7)!=null?rset.getString(7).trim():"" %>";
<%
                if (active.equals("A"))
                {
%>
    document.client.Active[0].checked = true;
<%
                }
                else
                {
%>
    document.client.Active[1].checked = true;
<%
                }
                if (balance.equals("B"))
                {
%>
    document.client.Balance[0].checked = true;
<%
                }
                else
                {
%>
    document.client.Balance[1].checked = true;
<%
                }
            }
            rset.close();
        }
        catch(SQLException e)
        {
            out.println(e.getMessage() + "<BR>" + select);
        }
    }

try
{
    rset = stmt.executeQuery("select field, name, view_name, code_seg from v_form_segments where code_plan = " + plan + " order by code");

    i = 1;
    String value = new String();
    String code_seg = new String();
    while(rset.next())
    {
        code_seg = rset.getObject(4)!=null?rset.getString(4).trim():"";
        if (i < 3)
        {
            String segment = plan + "1";
            if (id != null)
            {
                segment = id;
            }
            cstmt = conn.prepareCall ("{? = call plan.get_segment('" + segment + "', " + code_seg + ") } ");
            cstmt.registerOutParameter (1, Types.VARCHAR);
            cstmt.execute ();
            value = cstmt.getString(1)!=null?cstmt.getString(1).trim():"";
%>
    document.client.<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>.value = "<%= value %>";
//    modal_select(client.<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>, "<%= (rset.getObject(1)!=null?rset.getString(1).trim():"") %>","<%= "client.name"+i %>");
// <%="segment >"+segment+"< code_seg >"+code_seg+"<"%>
    varObj  [total] = client.<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>;
    varName [total] = "<%= (rset.getObject(1)!=null?rset.getString(1).trim():"") %>";
    Name1   [total] = "<%= "client.name"+i %>";
    total++;
    allow = true;
    client.<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>.readOnly = true;
<%
            cstmt.close();
        }
        if ((i > 2))// && (!rset.getString("name").equals("Код филиала")))

        {
            if (id != null)
            {
                String segment = id;
                cstmt = conn.prepareCall ("{? = call plan.get_segment('" + segment + "', " + code_seg + ") } ");
                cstmt.registerOutParameter (1, Types.VARCHAR);
                cstmt.execute ();
                value = cstmt.getString(1)!=null?cstmt.getString(1).trim():"";
%>
    document.client.<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>.value = "<%= value %>";
<%
                String F = rset.getObject(3)!=null?rset.getString(3).trim():"";
                if (!F.equals(""))
                {
%>
//    client_select(client.Select<%= i %>, client.<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>, client.name<%= i %>);

//      modal_select(client.<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>, "<%= (rset.getObject(1)!=null?rset.getString(1).trim():"") %>","<%= "client.name"+i %>");
    varObj  [total] = client.<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>;
    varName [total] = "<%= (rset.getObject(1)!=null?rset.getString(1).trim():"") %>";
    Name1   [total] = "<%= "client.name"+i %>";
    total++;

<%
                }
                cstmt.close();
            }
        }
        i++;
    }
    rset.close();
}
catch(SQLException e)
{
    out.println(e.getMessage());
}

%>
    // передача методом get при первой загрузке, чтобы все справочники сразу отразились
//    alert("total="+total);
    var line = "";
    for (i=0;i<total;i++)
    {
        line+="&view="+hashtable[varName[i]]+"&code="+varObj[i].value+"&param="+Name1[i];
    }
//    alert("line is:"+line);
    dblink.location.href="getModal.jsp?type=1"+line;
<%  if(active.equals("")){ %>
    setBalance();
<%  } %>
} /* end of fill_data  */

function change_data()
{
    location.href='cardAccount.jsp?id=<%= id %>&date=' + document.client.dateValid.value + '&d=<%= new java.util.Date() %>&selected=<%=selected%>';
}
</script>


<script language="JavaScript" src="scripts.js"></script>
<script language="JavaScript" src="scrGo.js"></script>

<style>
.but1
{
   FONT-FAMILY: Arial;
   FONT-SIZE: 8pt;
   WIDTH: 130;
}
DIV { font-size: 14 }
#div1 {top: 70; left: 100; position: absolute; z-index: 1}
</style>
</head>

<body onload="fillData();goFirst();">

<form name='client' method='post'>

    <input type="hidden" name="code">
    <input type="hidden" name="LocalCode">
    <input type="hidden" name="DateValidate" value="<%= DV %>">
    <input type="hidden" name="Operation" value="A">
    <input type="hidden" name="Liability" value="A">
    <input type="hidden" name="CodePlan" value="<%= plan %>">
    <input type="hidden" name="ConditionCode" value="A">
    <input type="hidden" name="RegisterSignCode" value="A">
    <input type="hidden" name="CurrentOperation" value="<%= id==null ? "A" : "V" %>">

<br>

<!--
   *******************************************************
   *****************  Hidden Values **********************
   *******************************************************
-->

<%
try
{

    String names[][] = new String[12][3];

    rset = stmt.executeQuery("select field, view_name, name from v_form_segments where code_plan = " + plan + " order by code");
    i = 0;

    while(rset.next())
    {

        i++;


        names[i][0] = rset.getObject(1)!=null?rset.getString(1).trim():"";
        names[i][1] = rset.getObject(2)!=null?rset.getString(2).trim():"";
        String name = rset.getObject(3)!=null?rset.getString(3).trim():"";


//    Показать все утвержденные клиенты
        if (name.equals("Код клиента") && (id==null))
        {
            names[i][1] += " where condition='A'";
        }

    }

    rset.close();
    // making the array like hashtable for views' names storage in JScript
    %>
        <script>
            var hashtable = new Array();
    <%
    for (int ii=1; ii <= i; ii++)
    {
        if (!names[ii][1].equals("") && names[ii][1]!=null)
        {
            String codeF = names[ii][0];
            String view = names[ii][1];
            %>
                hashtable['<%=codeF%>']="<%=view%>";
            <%
        }
    }
    %>
        </script>
    <%


}
catch(SQLException e)
{
    out.println("Error in hidden place: " + e.getMessage());
}

%>

<!-- Код группы -->
<div ID="div1">
<span id="hiddenList22" style="display: 'none';">
<table border="1" cellspacing="0" cellpadding="0" bordercolor="#336699">
<tr>
    <td align="center" style="color: white" bgcolor="#336699">
        Выберите и нажмите Enter
    </td>
</tr>
<tr>
    <td width="100">
        <select name="Select22"
                onKeyUp="ListSelected(Group, Select22, hiddenList22, GroupName);"
                onBlur="HideSelect(hiddenList22, Group);"
                onDblClick="SetSelect(Group, Select22, hiddenList22, GroupName);"
                size="15">
<%
try
{
    String query = "select group_code, group_name from v_group_employee";
    rset = stmt.executeQuery(query);
    while(rset.next())
    {
        String s = rset.getString(1) + " " + rset.getString(2);
        if (s.length() > 60)
            s = s.substring(0, 60);
%>
            <option value="<%= rset.getString(1) %>$$<%= rset.getString(2) %>"><%= s %></option><%
    }
    rset.close();
}
catch(SQLException e)
{
    out.println("<option value='error'>" + e.toString() +  "</option>");
}
%>
        </select>
    </td>
</tr>
</table>
</span>
</div>

<!-- * ***  End of Hidden Values **** * -->

<table width="750" bordercolor="#336699" style="FONT-FAMILY: arial" border="1" cellspacing="0" cellpadding="0" align="center">
<tr>
    <td>
        <table width="100%" bgcolor="#336699">
        <tr>
            <td style="COLOR: white" align="center">
                <b><%= id==null ? "Добавление счета" : "Карточка счета" %></b>
            </td>
        </tr>
        </table>
    </td>
</tr>
<tr>
    <td>
        <fieldset width="100%" style="background-color: #dddddd">
        <table width="100%"  border="0" cellspacing="0" cellpadding="0" align="center" border="1">
        <tr>
            <td align="center" width="750">
<%

if (id != null)
{
    try
    {
        rset = stmt.executeQuery("select code, name from v_acc_action where code in " +
                                 "(select distinct operation from v_acc_operation where condition_init= '" +
                                 condition + "' and ( operation <> 'E' and operation not between '0' and '9')) and code in ('O','A','T','C','D','U')");

        while(rset.next())
        {
%>
                <input type='button' class='but1' name='EditBtn' value='<%= rset.getObject(2)!=null?rset.getString(2).trim():"" %>' id='<%= rset.getObject(1)!=null?rset.getString(1).trim():"" %>' onclick='Edit();'>&nbsp;&nbsp;<%
        }
        rset.close();
    }
    catch(SQLException e)
    {
        out.println("Error in the programm: " + e.getMessage());
    }
}
else
{
%>              <input type='button' class='but1' name='EditBtn' value='Открыть' id='O' onclick='Edit();'>&nbsp;&nbsp;
                <input type='button' class='but1' name='EditBtn' value='Утвердить' id='A' onclick='Edit();'>&nbsp;&nbsp;<%
}
%>
                <input type="button" class='but1' value="Очистить" onclick="javascript: location.href='cardAccount.jsp?plan=<%= plan %>'">&nbsp;&nbsp;
<!--                <input type="button" class='but1' value="Выход" onclick="javascript: location.href='frameAccounts.jsp?id=<%=session.getValue("fAccID")%>';">
                <input type="button" class='but1' value="Выход" onclick="location.href='contents.jsp?id=menu2.jsp'">
-->
                   <input type="button" class='but1' value="Выход" onclick="location.href='frameAccounts.jsp?id=<%=session.getValue("fAccID")%>&d=<%= new java.util.Date() %>'">
            </td>
        </tr>
        </table>
        </fieldset>
        <fieldset>
        <table width="100%" bordercolor="#336699" style="FONT-SIZE: 9pt; FONT-FAMILY: arial" border="0" cellspacing="0" cellpadding="0" align="center">
        <tr>
            <td width="45%">
            <FONT STYLE="font-family:courier;font-size: 8pt;">
            <%= id==null ? "" : id.substring(0,7) %><b><%= id==null ? "" : id.substring(7) %></b>
            </font>
            <FONT STYLE="font-family:courier;font-size: 8pt; color=red;">
            <br><%=mask.substring(0,7)%><b><%= mask.substring(7) %></b>
            </font>
            </td>
            <td align="right" width="30%"> Дата &nbsp;&nbsp;
                <select name="dateValid" class="dropdown" onChange="change_data();" onKeyUp="goNext();" tabindex="1">
<%
if(id==null)
{
%>
                    <option value="<%= DV %>"><%= DV %></option>
<%
}
else
{
    try
    {
        rset = stmt.executeQuery("SELECT to_char(DATE_VALIDATE,'dd.mm.yyyy') FROM accounts_history WHERE id= " +
        "(select id from accounts where code='" + id + "') ORDER BY DATE_VALIDATE");
        while (rset.next())
        {
            String check = new String();
            String x = rset.getObject(1)!=null?rset.getString(1):"";
            if (x.equals(date_))
                check = "selected";
%>
                    <option value="<%= rset.getObject(1)!=null?rset.getString(1):"" %>"  <%= check %>><%= rset.getObject(1)!=null?rset.getString(1):"" %></option>
<%
        }
        rset.close();
     }  catch(SQLException e)
     {
%>
                    <option value='1'>Error: <%=e.getMessage()%></option>
<%
     }
}
%>
                </select> &nbsp;&nbsp;
                <input type="text" class="pole" size="20" name="Condition" value="Неопределен" disabled></td>
        </tr>
        </table>
        </fieldset>
        <fieldset width="100%" style="background-color: #dddddd">
        <table width="100%"  border="0" cellspacing="0" cellpadding="0" align="center">
        <tr>
            <td align="center">
                <input type="button" name="change" style="font-family: Arial; font-size: 8pt;" value="Изменить план счетов" onclick='javascript: hiddenName1.style.display=""; Select1.focus();' disabled>&nbsp;&nbsp;
                <input type="button" name="change" style="font-family: Arial; font-size: 8pt;" value="Изменить тип сальдо" onclick='javascript: hiddenName2.style.display=""; Select2.focus();' disabled>
            </td>
        </tr>
        </table>
        </fieldset>

        <fieldset>
        <table width="100%" bordercolor="#336699" style="FONT-SIZE: 9pt; FONT-FAMILY: arial" border="0" cellspacing="0" cellpadding="0" align="center">
<%
int nameNumber = 4;
try
{
    String query = "select trim(field), trim(name), seg_length, trim(view_name) from v_form_segments where code_plan = " + plan + " order by code";
    rset = stmt.executeQuery(query);
    int ii = 1;
    String codeF = new String();

    while(rset.next())
    {
        codeF = rset.getObject(1)!=null?rset.getString(1).trim():"";

        cstmt = conn.prepareCall ("{? = call ACCOUNT.GET_ENTER_FIELD('" + codeF + "') } ");
        cstmt.registerOutParameter (1, Types.NUMERIC);
        cstmt.execute ();
        int isEnter = cstmt.getInt(1);

        cstmt.close();

// Переменные, для сравнения, чтобы не возникал NullPointerException
        String gst4 = rset.getObject(4)!=null?rset.getString(4).trim():"";
        String gst2 = rset.getObject(2)!=null?rset.getString(2).trim():"";

        String html = "<input type='text' class='pole' name='"+codeF+"' size='"+rset.getString(3)+"'"+
                      " maxlength='"+rset.getString(3)+"'";

        if (gst2.equals("Контрольный ключ"))
        {
            html += " disabled";
            keyCode = codeF;
        }
        if (isEnter == 1)
            html += " id='"+ gst2 +"'";
        if ((ii > 2) && (!gst4.equals(""))  )
            /* &&  (!gst2.equals("Код филиала")) ) */
        {
             html +=" onKeyUp='ModalGet(\""+codeF + "\", name"+ii+");goNext()'";
             if (gst2.equals("Балансовый счет"))
             {
                nameNumber = ii;
                html +=" onChange='modal_select("+codeF+",\""+codeF+"\",\"client.name"+ii+"\");setBalance()' onBlur='setBalance();'";
             }
             else
             {
                html +=" onChange='modal_select("+codeF+",\""+codeF+"\",\"client.name"+ii+"\");'";
             }
        }
        else
        {
            if (gst2.equals("Субсчет") || gst2.equals("Порядковый номер")) html +=" onChange='fillZero(this);'";
            if (gst2.equals("Порядковый номер")) html +=" onKeyUp='if (event.keyCode==120) getAccNumber(client.FIELD_7.value, client.FIELD_4.value, client.FIELD_5.value);goNext();' ";
                else html +=" onKeyUp='goNext();' ";
        }
        if (gst2.equals("Код филиала"))
        {
             html += " value='"+ filialCode + "'";
        }

        if (gst2.equals("План счетов") || gst2.equals("Тип сальдо"))
        {
             html +=" onChange='modal_select("+codeF+",\""+codeF+"\",\"client.name"+ii+"\");'";
        }

        if (gst2.equals("Валюта"))
        {
             html += " value='000'";
        }

        html += " tabindex='"+tabindex+"' ";
        html += ">";

%>
        <tr>
            <td nowrap> <%= gst2 %> </td>
            <td> <%= html %> </td>
<%
        html = "";
        if (!gst4.equals(""))
        {
            html += "            <td> <input type='text' class='pole' name='name" + ii + "'";
            if (!gst2.equals("Субсчет"))
                html += " id='$" + gst2 + "'";
            html +=" size='80' disabled";
            if (gst2.equals("Код филиала"))
            {
                html += " value='" + filialName + "'";
            }
            if (gst2.equals("Валюта"))
            {
                 html += " value='Сум (для междунар.расчетов код 860)'";
            }

            html += "> </td>\n";
        }
        html += "       </tr>";
        out.print(html);
        ii++;
    }
    rset.close();
    rset = stmt.executeQuery("select account.get_group_default("+id+") from dual");
    if(rset.next())
    {
        Group = rset.getString(1)!=null?rset.getString(1):"";
    }
    rset.close();



}
catch(SQLException e)
{
    out.print("Error segment: " + e.getMessage());
}



%>
        <tr>
            <td> Наименование </td>
            <td colspan="3"> <input class=pole name='Name' id="наименование счета" size="93" tabindex="<%=tabindex+1%>" onKeyUp="goNext();" onfocus="if(this.value=='' && client.name<%=nameNumber%>.value!='') this.value=client.name<%=nameNumber%>.value;"> </td>
        </tr>
        <tr>
            <td align="center">
                <table style="FONT-SIZE: 9pt; FONT-FAMILY: arial" border="1" cellspacing="0" cellpadding="0" align="center">
                <tr>
                    <td>
                        <input type="radio" name="Active" checked value="A" tabindex="<%=tabindex+2%>" onKeyUp="goNext();">Активный <br>
                        <input type="radio" name="Active" value="P" tabindex="<%=tabindex+3%>" onKeyUp="goNext();">Пассивный
                    </td>
                </tr>
                </table>
            </td>
            <td align="center">
                <table style="FONT-SIZE: 9pt; FONT-FAMILY: arial" border="1" cellspacing="0" cellpadding="0" align="center">
                <tr>
                    <td>
                        <input type="radio" name="Balance" checked value="B" tabindex="<%=tabindex+4%>" onKeyUp="goNext();">Балансовый<br>
                        <input type="radio" name="Balance" value="O" tabindex="<%=tabindex+5%>" onKeyUp="goNext();">Внебалансовый
                    </td>
                </tr>
                </table>
            </td>
            <td align="left">
                <table style="FONT-SIZE: 9pt; FONT-FAMILY: arial" border="0" cellspacing="0" cellpadding="0" align="center">
                <tr>
                    <td>
                        Группа <input type="text" name="Group" class=pole size="3" maxlength="3" tabindex="<%=tabindex+6%>"
                                      value="<%= Group %>" onKeyUp="ListGet(hiddenList22, Select22, Group, GroupName);goNext();" onchange="fillZero(this);"> <br>
                               <input type="hidden" name="GroupName">
                        НИББД <input type="text" name="RegisterSign" class=pole size="25" value="Не зарегистрирован" disabled>
                    </td>
                </tr>
                </table>
            </td>
        </tr>
        </table>
        </fieldset>
    </td>
</tr>
</table>
            <input type="hidden" name="KeyCode" value="<%= keyCode %>">
<iframe name="dblink" width="0" height="0" src="blank.html" frameborder="0"></iframe>
</form>
</body>
</html>

<%
    stmt.close();
    cstmt.close();
} catch (Exception e)
{
    //total catch
    out.println(dbg);
    out.println("<br>"+e.toString());
}
%>