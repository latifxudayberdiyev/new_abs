<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*, oracle.sql.*, oracle.jdbc.*"
			   contentType="text/html;charset=WINDOWS-1251" language="java"%>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/>
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if(conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
	String local = Util.nvl(stored.execFunction("Sl_Util.Get_Local_Code_By_User_Id(Setup.Get_Employee_Code)"),stored.execFunction("Setup.Get_Local_Code"));
	//String curPeriod = stored.execSelect("select trunc(setup.bankday,'MON') from dual");
	String curPeriod = stored.execFunction("Sl_Util.Get_Curr_Period('" + local + "')");
	String period = Util.nvl(request.getParameter("period"),curPeriod);
	String user_type = stored.execFunction("Sl_Util.Get_User_Type");
	String vView = curPeriod.equals(period) ? "Sl_Personal_v" : "Sl_Personal_Old_v";
	String where = period.equals("") ? "Period = to_Date('" + curPeriod + "', 'dd.mm.yyyy')" :
										"Period = to_Date('" + period + "', 'dd.mm.yyyy')"; 
	String emp = stored.execFunction("Setup.Get_Employee_Name");
%>
<t:page>
	<t:form titleText="<%= lang.get(si_FormTitle, emp) %>" minHeight="fill" minWidth="fill">
		<script>
			function onLoad(){
				if(tdd.d.length > 0)
					for (var i=0; i<tbl.tBodies[0].rows.length; i++) {
						if (tdd.d[i][2] == '4') {
						  tbl.tBodies[0].rows[i].style.background = '#bfcfff';
						  tbl.tBodies[0].rows[i].cells[2].style.fontWeight='bold';
						}
					}
				for(var k=0;k<getDOM('period').options.length;k++) {
					if(getDOM('period').options[k].value == '<%= period %>')
					  getDOM('period').options[k].selected = true;
				}
				
			}
			function setPeriod(dom) {
				document.location = '?period=' + dom.value;
			}
		</script>
		<link rel=stylesheet type="text/css" href="/ibs/ia/sl/resources/css/reset.css">
		<% if(Objects.equals(user_type, "0")){%>
			<table class="formToolbar" cellspacing="2">
				<tr>
					<td align="right">Период : <select id=period onChange='setPeriod(this)'><%=stored.execSelect("Select Opts From Sl_s_Personal_Periods_v where period <= '" + curPeriod + "'")%></select>
					<td id="tableControls" align=right width=60>
			</table>
			<t:table from="<%= vView %>" where="<%= where %>">
				<t:field id="1" name="Pay_Name" labelText="Наименование" type="quote"/>
				<t:field id="2" name="Sum_Pay" labelText="Сумма" type="sum" />
				<t:field id="3" name="Rec_Type" />
				<t:field id="4" name="Got_Sum" labelText="На руки" type="sum"/>
				
				<t:grid numbering="" withoutCursor="" withoutSortButtons="">
					<t:column for="1" align="left"/>
					<t:column for="2" align="right"/>
					<t:foot>
						<t:row>
							<t:cell for="4" size="100%" />
						</t:row>
					</t:foot>
				</t:grid>
			</t:table>
		<%}else{%>
			<table width=100% height=100% cellpadding=0 cellspacing=0>
				<tr>
					<td align=center style="vertical-align: middle; font-size:20px; color:#016799; 
								filter: progid:DXImageTransform.Microsoft.Gradient(GradientType=0, StartColorStr='#ffffff', EndColorStr='#dfdfdf')">
						Моя зарплата не работает для внешних пользователей !!!
			</table>
		<%}%>
	</t:form>
</t:page>
<%!
static final int si_FormTitle = SI("Персональная заработная плата сотрудника ($1)","Ходимнинг шахсий ойлик маоши ($1)","Xodimning shaxsiy oylik maoshi ($1)","");
%>
<%@ include file="/language.jsp" %>
