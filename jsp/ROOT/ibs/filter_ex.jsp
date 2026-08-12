<%@ page import="iabs.*, java.text.SimpleDateFormat, java.sql.*, java.util.ArrayList" contentType="text/html;charset=Windows-1251"%>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="apps" class="iabs.oraApplication" scope="application" />
<%
	String subsystemURL = request.getParameter("subsystemURL");
	String backURL = request.getParameter("backURL");
	String form_name = request.getParameter("form_name");
	String columnTableName = request.getParameter("columnTableName");
try{
	int columnCount = Integer.parseInt(request.getParameter("columnCount"));

/////////////////////////   обработка фильтра   /////////////////////////////////
	int valuesCount = 0;
	String filterString = "";
	String sortString = "";											//Cодержит строку сортировки для селекта.
	String types = request.getParameter("types");					//ТИПЫ ПОЛЕЙ ФМЛЬТРА
	String values = cods.ConvIso(request.getParameter("values"));	//Хранилище значений фильтра
	String mask = extract(valuesCount++,values);					//Это переменная для признака маскировки в фильтре
	String paramName="";
	String paramType="";
	String paramValue="";
	String where_clause = "";
	for (int i=0;i<columnCount;i++){
		paramName = extract(i,columnTableName);
		paramType = extract(i,types);
		paramValue = extract(valuesCount++,values);
		if ("N".equals(paramType) || "C".equals(paramType) ){
			if (!paramValue.equals(""))
				filterString += " " + where_clause + " " + paramName + " like '" +mask + cods.quotesSQL(paramValue) + mask + "'";
		}
		else if ("S".equals(paramType)){
			String paramValue2 = extract(valuesCount++,values);
			String numberFormat = "'FM999G999G999G999G990D009999', 'NLS_NUMERIC_CHARACTERS = ''. '''";
			if (!paramValue.equals("")){
					if (!paramValue2.equals("")){
					if (paramValue.equals(paramValue2)) filterString += " " + where_clause + " to_number(" + paramName + ","+numberFormat+") = "+ paramValue;
					else filterString += " " + where_clause + " to_number(" + paramName + ","+numberFormat+") between "+ paramValue + " and "+ paramValue2;
				}
				else filterString += " " + where_clause + " to_number(" + paramName + ","+numberFormat+") >= "+ paramValue;
			}
			else if (!paramValue2.equals("")) filterString += " " + where_clause + " to_number(" + paramName + ","+numberFormat+") <= "+ paramValue2;
		}
		else if ("D".equals(paramType)){
			String paramValue2 = extract(valuesCount++,values);
				if (!paramValue.equals("")){
				if (!paramValue2.equals("")) filterString += " " + where_clause + " trunc(" + paramName + ") between to_date('"+ paramValue + "','dd.mm.yyyy') and to_date('"+ paramValue2 + "','dd.mm.yyyy')";
				else filterString += " " + where_clause + " trunc(" + paramName + ") >= to_date('"+ paramValue + "','dd.mm.yyyy')";
			}
			else if (!paramValue2.equals("")) filterString += " " + where_clause + " trunc(" + paramName + ") <= to_date('"+ paramValue2 + "','dd.mm.yyyy')";
		}
			else{	//varchar с uppercase	(Вообще - то тут должна быть проверка на соответствие типу "U", но чтобы фильтр не ломался от неверного ввода в таблице, оставим как есть.)
			if (!paramValue.equals(""))
				filterString += " " + where_clause + " upper(" + paramName + ") like '" +mask + cods.quotesSQL(paramValue.toUpperCase()) + mask + "'";
		}
		if (extract(valuesCount++,values).equals("1")) sortString +=  (sortString.equals("")?" order by ":" , ")+paramName;
		if (!filterString.equals("")) where_clause = "and";
	}
	session.putValue(form_name+".filterValues",values);
	session.putValue(form_name+".filterString", filterString+(sortString.equals("")?"":sortString));
}catch(Exception e){%>
	<script>
		alert("<%=cods.fixEnter(e.toString())%>");
	</script>
<%}%>
<html>
<body onload="goForm.submit();">
<form name="goForm" method="post" action="<%=backURL%>">
<%
String paramName = "";
for (java.util.Enumeration e = request.getParameterNames() ; e.hasMoreElements();) {
	paramName = (String)e.nextElement();%>
<input type="hidden" name="<%=paramName%>" value="<%=cods.quotes(cods.ConvIso(request.getParameter(paramName)))%>">
<%}%>
</form>
</body>
</html>

<%!
////////////////        Функция, вырезающая из стринга нужное значение по индексу        ///////////////////
///////////////              (в качестве разделителя используется delim)               ///////////////////
String extract(int k, String str){		//индекс: от 0 - .... Если элемент не найден, возвращается пустая строка.
	return extract(k, str, "~#");		//индекс: от 0 - .... Если элемент не найден, возвращается пустая строка.
}
String extract(int k, String str, String delim){	//индекс: от 0 - .... Если элемент не найден, возвращается пустая строка.
	String param = "";							//Возвращаемый параметр
	int beg=0;									//Индекс начала конкретного значения параметра в строке всех параметров
	int end=0;									//Индекс конца конкретного значения параметра в строке всех параметров
	int add = delim.length();
	try{
		str += delim;							//Подготоавливаем строку к поиску
		for(int i=0;i<k+1;i++){					//Последовательно пробегаемся по всем параметра
			end = str.indexOf(delim,beg);		//Определяем индех конца конкретного параметра в строке параметров
			param = str.substring(beg,end);		//Запоминаем параметр в массиве параметров
			beg = end+add;						//Переходим на начало следующего параметра
		}
     }catch(Exception e){
	 	param = "";
	 }
	 return (param);
}
%>
