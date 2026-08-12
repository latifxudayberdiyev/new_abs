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
	String curPeriod = stored.execFunction("Zpt.Curr_Month");
	String period = cods.nvl(request.getParameter("period"));
	period = period.equals("") ? curPeriod : period;
	String vView = curPeriod.equals(period) ? "Zp_Personal_v" : "Zp_Personal_Old_v";
	String where = "Period = to_Date('" + period + "', 'dd.mm.yyyy')"; 
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
		<table class="formToolbar" cellspacing="2">
			<tr>
				<td align="right">Период : <select id=period onChange='setPeriod(this)'><%=stored.execSelect("SELECT '<option value=''' || To_Char(Period,'dd.mm.yyyy') || '''>' || To_Char(Period,'mm.yyyy') FROM vv_Zp_Period t")%></select>
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
	</t:form>
</t:page>
<%!
static final int si_FormTitle = SI("Персональная заработная плата сотрудника ($1)","Ходимнинг шахсий ойлик маоши ($1)","Xodimning shaxsiy oylik maoshi ($1)","");
%>
<%@ include file="/language.jsp" %>
