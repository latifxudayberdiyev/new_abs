<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*, uz.fido_biznes.sql.Direction" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/>
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
    Connection conn = cods.getConnection();

    if (conn == null || user.getUserCode() == null)
        pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);

    Language lang = new Language(user.getLanguageIndex(), sentences);
    pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
    String client_code = stored.decryptParameterValue(request,"code","CORE_INFO");//request.getParameter("code");
	String iWHERE = "client_code ='"+client_code+"'";
    String formTitle = lang.get(si_formTitle) + "<div id=sumControls></div>";
%><t:form titleText="<%=formTitle %>" minWidth="fill" minHeight="fill">
<style>
#sumControls {
    position: absolute;
    right: 40px;
    top: 0;
}
</style> 
<style>
	.qrcode{
		cursor:pointer;
        position: absolute;
        top: 0;
        right: 15px;
        width: 20px;
        height: 20px;
	}
	.for_td{width:1%}
</style>
<table class=formToolbar>
	  <td colspan=2 align="center"  >
		  <i><span style="color:#1E396D;" id=filterControls></span></i>
      <td id="tableControls" align="right">
    </table>
<table border=0>
    <tr>
        <td>
  <th  align="right" id=sumControls>

</table>
<t:table from="dep_v_contracts" where="<%=iWHERE%>">
      <t:field id="40" name="id">
        <t:filter mask="6|0-9" showInGrid="" size="6" label="<%=si_id%>"/>
      </t:field>
      <t:field id="19" name="state" label="<%=si_state_name%>">
         <t:filter optionSQL="select '<option value=' || Code || '>' ||Name from DEP_V_CONTRACT_STATES"/>
      </t:field>
      <t:field id="0" name="filial_code" label="<%=si_mfo%>">
          <t:filter  mask="mfo" referenceName="filials" referenceURL="/ibs/dep/util/references.jsp" requestName="get_filial_name" requestURL="/ibs/dep/util/references.jsp" showInGrid="" size="5"/>
      </t:field>
      <t:field id="1" name="id" label="<%=si_id%>"/>
      <t:field id="3" name="action_resource_name" label="<%=si_action_resource_name%>" type="quote"/>
      <t:field id="21" name="action_resource" label="<%=si_action_resource_name%>">
          <t:filter optionSQL="select '<option value=' || Code || '>' || Name from DEP_V_ACTION_RESOURCE"/>
      </t:field>
      <t:field id="4" name="client_type" label="<%=si_client_type_name%>">
         <t:filter optionSQL="select '<option value=' || Code || '>' ||Name from DEP_V_CLIENT_TYPE"/>
      </t:field>
      <t:field id="5" name="client_type_name" label="<%=si_client_type_name%>" type="quote"/>
      <t:field id="6" name="currency_type" label="<%=si_currency_type_name%>">
         <t:filter optionSQL="select '<option value=' || Code || '>' ||Name from DEP_V_CURRENCY_TYPE"/>
      </t:field>
      <t:field id="7" name="currency_type_name" label="<%=si_currency_type_name%>" type="quote"/>
      <t:field id="8" name="deposit_type" label="<%=si_deposit_type_name%>">
         <t:filter optionSQL="select '<option value=' || Code || '>' ||Name from DEP_V_DEPOSIT_TYPE"/>
      </t:field>
      <t:field id="9" name="deposit_type_name" label="<%=si_deposit_type_name%>" type="quote"/>
      <t:field id="10" name="account_layouts" label="<%=si_account_layouts_name%>">
         <t:filter referenceName="layouts" requestName="getAccountLayout"/>
      </t:field>
      <t:field id="29" name="client_code" label="<%=si_client_name%>">
		<t:filter referenceName="clients" referenceURL="/ibs/dep/util/references.jsp" requestName="get_client_name" requestURL="/ibs/dep/util/references.jsp" />
      </t:field>
      <t:field id="27" name="contract_number" label="<%=si_contract_number%>" type="quote">
		<t:filter mask="100|" operator="_search_" showInGrid="" size="10"/>
      </t:field>
      <t:field id="2" name="contract_name" label="<%=si_contract_name%>" type="quote">
         <t:filter  mask="100|" size="40" operator="_search_" showInGrid=""/>
      </t:field>
      <t:field id="28" name="contract_date" label="<%=si_contract_date%>" type="date">
		<t:filter mask="date" operator="range"/>
      </t:field>
      <t:field id="16" name="currency_code" label="<%=si_currency_char_code%>">
         <t:filter referenceName="currencies" requestName="getCurrencyName" requestURL="/ibs/dep/util/references.jsp"/>
      </t:field>
      <t:field id="24" name="summa" label="<%=si_summa%>" type="sum">
		<t:filter mask="number(20,2)" operator="range"/>
		<t:sum label="<%=si_total_summa%>" type="sum" />
      </t:field>
      <t:field id="50" name="dep_account_saldo" label="<%=si_saldo_out%>" type="sum">
		<t:filter mask="number(20,2)" operator="range"/>
		<t:sum label="<%=si_saldo_out_sum%>" type="sum" />
      </t:field>
		<t:field id="55" name="Dep_Account_Saldo_13" label="<%=si_account_saldo_13%>" type="sum">
			<t:filter mask="number(20,2)" operator="range"/>
		</t:field>
      <t:field id="51" name="dep_account" labelText="<span></span><%=si_account_act%>"/>
      <t:field id="52" name="dep_account" label="<%=si_account%>">
          <t:filter mask="20|0-9%" operator="like_" size="25" referenceName="accounts" referenceURL="/ibs/dep/util/references.jsp"/>
      </t:field>
      <t:field id="22" name="date_begin" label="<%=si_date_begin%>" type="date">
          <t:filter mask="date" operator="range"/>
      </t:field>
      <t:field id="23" name="date_end" label="<%=si_date_end%>" type="date">
          <t:filter mask="date" operator="range"/>
      </t:field>
      <t:field id="31" name="date_end_fact" label="<%=si_date_end_fact%>" type="date">
          <t:filter mask="date" operator="range"/>
      </t:field>
      <t:field id="25" name="count_days" label="<%=si_count_days%>">
          <t:filter mask="10|0-9" operator="range"/>
      </t:field>
      <t:field id="37" name="remain_days" label="<%=si_remain_days%>">
          <t:filter mask="number(10)" operator="range"/>
      </t:field>
      <t:field id="26" name="min_summa_calc_percent" label="<%=si_min_summa_calc_percent%>" type="sum">
          <t:filter mask="number(20,2)" operator="range"/>
      </t:field>
      <t:field id="32" name="days_in_year" label="<%=si_days_in_year%>">
          <t:filter optionSQL="select '<option value=' || Code || '>' ||Name from DEP_V_DAYS_IN_YEAR"/>
      </t:field>
      <t:field id="33" name="capitalization_code" label="<%=si_capitalization_code%>">
          <t:filter optionSQL="select '<option value=' || Code || '>' ||Name from DEP_V_CAPITALIZATION"/>
      </t:field>
      <t:field id="34" name="calc_percent_type" label="<%=si_calc_percent_type%>"/>
      <t:field id="35" name="procent_last" label="<%=si_procent_last%>" type="sum">
          <t:filter mask="number(9,6)" operator="range"/>
      </t:field>
      <t:field id="36" name="take_tax" label="<%=si_take_tax%>">
          <t:filter option="<%=si_take_tax_option%>"/>
      </t:field>
      <t:field id="11" name="account_layouts_name" label="<%=si_account_layouts_name%>" type="quote"/>
      <t:field id="17" name="currency_char_code" label="<%=si_currency_char_code%>" type="quote"/>
      <t:field id="20" name="state_name" label="<%=si_state_name%>" type="quote"/>
      <t:field id="30" name="client_name" labelText="<span><%=lang.get(si_client_name)%></span>" type="quote">
      </t:field>
	  <t:field id="41" name="percent_rate" labelText="Процент вклада%" type="numberS6"/>
      <t:field id="53" name="product_type" label="<%=si_product_type%>">
		<t:filter mask="3|0-9" size="3"/>
	  </t:field>
	  <t:field id="54" name="sub_coa" label="<%=si_sub_coa%>">
		<t:filter mask="2|0-9" size="2"/>
	  </t:field>			
      <t:grid page="20" withoutCursor="">
        <t:column for="40" type="checkbox" name="ids" labelText=""/>
        <t:column for="0"/>
        <t:column for="27"/>
        <t:column for="2" align="left"/>
        <t:column for="3"/>
        <t:column for="22"/>
        <t:column for="23"/>
        <t:column for="37"/>
        <t:column for="17"/>
        <t:column for="41"/>
        <t:column for="24" align="right"/>
        <t:column for="50" align="right"/>
				<t:column for="55" align="right"/>
        <t:column for="20"/>
        <t:foot>
            <t:row>
                <t:cell for="1" size="15" />
                <t:cell for="9" size="30"/>
                <t:cell for="30" size="100%" colspan="3"/>
            </t:row>
            <t:row>
                <t:cell for="28" size="15"/>
                <t:cell for="5"/>
                <t:cell for="26" colspan="2"/>
            </t:row>
            <t:row>
                <t:cell for="25" size="10"/>
                <t:cell for="7"/>
                <t:cell for="51" size="25"/>
            </t:row>
			<t:row>
				<t:cell for="54" size="2"/>
				<t:cell for="53" size="3"/>
			</t:row>
        </t:foot>
      </t:grid>
    </t:table>
</t:form></t:page>
<t:references>
    <t:reference name="currencies" title="<%=si_currency_char_code %>" >
        <t:table from="dep_v_currency" where="code in (select distinct currency_code from dep_v_contracts)">
          <t:field id="1" name="CODE" label="<%=si_code %>">
            <t:filter showInGrid="" mask="3|0-9" operator="like_" />
          </t:field>
          <t:field id="2" name="NAME" label="<%=si_name %>" type="quote" />
          <t:field id="3" name="CHAR_CODE" label="<%=si_code %>" />
          <t:grid page="" hideFilterButton="" withoutCursor="" >
            <t:column for="1"  />
            <t:column for="3" />
            <t:column for="2" align="left"/>
          </t:grid>
        </t:table>
      </t:reference>
    <t:reference name="layouts" title="<%=si_account_layouts_name %>" >
        <t:table from="dep_v_account_layouts">
          <t:field id="1" name="id" label="<%=si_code %>">
            <t:filter showInGrid="" mask="10|0-9" operator="like_" />
          </t:field>
          <t:field id="2" name="NAME" label="<%=si_name %>" type="quote" />
          <t:grid page="" hideFilterButton="" withoutCursor="" >
            <t:column for="1"  />
            <t:column for="2" align="left"/>
          </t:grid>
        </t:table>
      </t:reference>
</t:references>
<t:requests>
    <t:request name="getAccountLayout"><%
        try
        {
            String code = request.getParameter("code");
            String name = stored.execSelect("select name from dep_v_account_layouts where id='" + Util.quotesSQL(code) + "'");
            if  ( name.equalsIgnoreCase("") )
              throw new Exception("Введенный код в справочнике не найден!") ;
            JArray result = new JArray();
            result.push(name);
            out.print(result.toString());
        }
        catch (Exception ex)
        {
            response.setHeader("RT","error");
            out.print(Util.getUserMessage(ex));
        }
      %></t:request>
</t:requests>
<%!
static final int si_formTitle              = SI("Депозитный договоров","Омонатлар рўйхати","Omonatlar ro`yxati","");
static final int si_mfo                    = SI("Филиал","Филиал","Филиал","Mfo");
static final int si_id                     = SI("ID","ID","ID","Id");
static final int si_loan_id                = SI("ID договора","ID договора","ID договора","Id");
static final int si_name                   = SI("Наименование","Номи","Номи","Name");
static final int si_action_resource_name   = SI("Действие над ресурсом","Ресурс устида амал","Ресурс устида амал","Action on a resource");
static final int si_client_type_name       = SI("Тип клиента","Мижоз тури","Mijoz turi","custemer type");
static final int si_currency_type_name     = SI("Тип валюты","Валюта тури","Valyuta turi","Currency type ");
static final int si_deposit_type_name      = SI("Тип вклада","Омонат тури","Omonat turi","Deposit type name");
static final int si_account_layouts_name   = SI("Макет счета","&#1202;исобвара&#1179; макети","Hisobvaraq maketi","Account layout");
static final int si_date_begin             = SI("Дата привл./разм.","Жалб этиш/жойлаштириш санаси","Jalb etish/joylashtirish sanasi","Date begin");
static final int si_date_end               = SI("Дата закрытия","Ёпиш санаси","Yopish sanasi","Date end");
static final int si_date_end_fact          = SI("Дата фактического закрытия","Амалда ёпилган сана","Amalda yopilgan sana","Date ending");
static final int si_currency_char_code     = SI("Валюта","Валюта","Valyuta","Currency ");
static final int si_summa                  = SI("Сумма","Сумма","Summa","Amount");
static final int si_total_summa                  = SI("Общая - Сумма договор","","","");
static final int si_count_days             = SI("Срок договора в днях","Шартнома муддати кунларда","Shartnoma muddati kunlarda","Contract duration in days");
static final int si_min_summa_calc_percent = SI("Мин. сумма для начис. %","% &#1203;исоблаш учун минимал сумма","% hisoblash uchun minimal summa","Min. amount assessed.");
static final int si_contract_number        = SI("Номер договора","Шартнома номери","Shartnoma nomeri","Contract number");
static final int si_contract_date          = SI("Дата договора","Шартнома санаси","Shartnoma sanasi","Contract date");
static final int si_contract_name          = SI("Наименование","Номи","Nomi","Contract name");
static final int si_code                   = SI("Код","Код","Kod","Code");
static final int si_take_tax               = SI("Снимать налог","Соли&#1179;ни ушлаб &#1179;олиш","Soliqni ushlab qolish","Withdraw tax");
static final int si_take_tax_option        = SI("<option value='Y'>Да<option value='N'>Нет","<option value='Y'>&#1202;а<option value='N'>Йў&#1179;","<option value='Y'>Ha<option value='N'>Yo`q","<option value='Y'>Yes<option value='N'>No");
static final int si_days_in_year           = SI("Банковских дней","банк кунлари","bank kunlari","bank days");
static final int si_capitalization_code    = SI("Капитализация","Капитализация","Kapitalizatsiya","Capitalization");
static final int si_calc_percent_type      = SI("Тип расчета процентов","Фоизларни &#1203;исоблаш тури","Foizlarni hisoblash turi","Calc interest ");
static final int si_procent_last           = SI("Процент после окончания","Тугагандан сўнг фоиз","Tugagandan so`ng foiz","Percent after ending");
static final int si_remain_days            = SI("Осталось дней","Кунлар &#1179;олди","Kunlar qoldi","days left");
static final int si_client_name            = SI("Клиент","Мижоз","Mijoz","custemer ");
static final int si_saldo_out              = SI("Остаток деп. счета","Депозит &#1203;исобвара&#1171;и &#1179;олди&#1171;и","Depozit hisobvarag`i qoldig`i","balance from dep. Account");
static final int si_saldo_out_sum          = SI("&nbsp;|&nbsp;Сумма остаток","","","");
static final int si_account                = SI("Депозитный счет","Депозит &#1203;исобвара&#1171;и","Depozit hisobvarag`i","Deposit Account");
static final int si_state_name             = SI("Состояние","&#1202;олати","Holati","Status");
static final int si_protocol               = SI("Протокол","Баённома","Bayonnoma","Protocol");
static final int si_actual_closing         = SI("Факт закр.","Амалда ёпилган","Amalda yopilgan","Actual closing");
static final int si_account_act            = SI("Счет","&#1202;исобвара&#1179;","Hisobvaraq","account");
static final int si_product_type					 = SI("Продукт","","","Product");
static final int si_sub_coa								 = SI("Суб счёт","","","Sub Coa");
static final int si_account_saldo_13			 = SI("Остаток проср. счета","","","");
%><%@ include file="/language.jsp" %>
