<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*, uz.fido_biznes.sql.Direction" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ page import="iabs.oraDBConnection" %>
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
    String code         = stored.decryptParameterValue(request,"code","CORE_INFO");//request.getParameter("code");
%><t:form title="<%=si_formTitle %>" minWidth="fill" minHeight="fill">
<link rel="stylesheet" type="text/css" href="/ibs/ca/style/form.css">
<style>
span.lineStateIco{
	font: 140% wingdings !important;
}
</style>
<table class="formToolbar">
  <tr><td id="tableControls" align="right">
</table>
<%	String iWhere = "CLIENT_CODE='"+code+"'"; %>
<t:table from="V_ACCOUNTS" where="<%=iWhere%>">
	<t:field id="1" name="ID" labelText="ID счета" color="d(4)=='C'?'#808080':'black'" />
	<t:field id="2" name="CODE" label="<%=si_code%>" type="quote"/>
	<t:field id="24" name="ACC_EXTERNAL" label="<%=si_acc_external%>" type="quote" color="d(4)=='C'?'#808080':'black'" >
        <t:filter referenceName="accounts" referenceURL="/ibs/ca/util/references.jsp" operator="like_"/>
    </t:field>
   <t:field id="28" name="client_id" labelText="ID клиента" >
      <t:filter operator="_search_" mask="10|0-9"  size="10"/>
    </t:field>
	<t:field id="3" name="NAME" label="<%=si_name%>" type="quote" color="d(4)=='C'?'#808080':'black'" >
        <t:filter mask="80|" size="75" operator="_search_"/>
    </t:field>
	<t:field id="4" name="CONDITION" label="<%=si_condition%>" color="d(4)=='C'?'#808080':'black'" >
        <t:filter optionSQL="select '<option value ='||code||'>'||name from v_acc_condition" value="A"/>
    </t:field>
	<t:field id="6" name="SALDO_OUT_CHAR" label="<%=si_saldo_out_char%>" type="quote" color="d(4)=='C'?'#808080':'black'" />
	<t:field id="7" name="SALDO_UNLEAD_CHAR" label="<%=si_saldo_unlead_char%>" type="quote" color="d(4)=='C'?'#808080':'black'"/>

	<t:field id="9" name="CODE_COA" label="<%=si_code_coa%>" >
        <t:filter mask="5|0-9" operator="like_" referenceName="coa" referenceURL="/ibs/ca/util/references.jsp" requestName="get_coa_name" requestURL="/ibs/ca/util/references.jsp"/>
    </t:field>
	<t:field id="11" name="CODE_FILIAL" label="<%=si_code_filial%>" color="d(4)=='C'?'#808080':'black'" >
        <t:filter mask="mfo" referenceName="filials" referenceURL="/ibs/ca/util/references.jsp" requestName="get_filial_name" requestURL="/ibs/ca/util/references.jsp"/>
    </t:field>
	<t:field id="12" name="CLIENT_CODE" label="<%=si_client_code%>" >
        <t:filter referenceName="clients" referenceURL="/ibs/ca/util/references.jsp" requestName="get_client_name" requestURL="/ibs/ca/util/references.jsp"/>
    </t:field>
    <t:field id="14" name="CODE_CURRENCY" label="<%=si_code_currency%>">
        <t:filter referenceName="currency" referenceURL="/ibs/ca/util/references.jsp" requestName="get_currency_name" requestURL="/ibs/ca/util/references.jsp"/>
    </t:field>
	<t:field id="15" name="GROUP_CODE" label="<%=si_group_code%>">
        <t:filter optionSQL="select '<option value ='||group_code||'>'||group_name from v_group_employee"/>
    </t:field>
	<t:field id="16" name="SIGN_REGISTR" label="<%=si_sign_registr%>">
        <t:filter optionSQL="select '<option value ='||code||'>'||name from V_ACC_REGISTR"/>
    </t:field>
	<t:field id="20" name="A_CLIENT_CODE" label="<%=si_a_client_code%>" color="d(4)=='C'?'#808080':'black'" >
        <t:filter mask="8|0-9" operator="like_"/>
    </t:field>
	<t:field id="21" name="A_ACCOUNT_CODE" label="<%=si_a_account_code%>" color="d(4)=='C'?'#808080':'black'" >
        <t:filter mask="27|0-9A-Z" operator="like_" size="50"/>
    </t:field>
	<t:field id="5" name="CONDITION_NAME" label="<%=si_condition%>" color="d(4)=='C'?'#808080':'black'" type="quote"/>
	<t:field id="22" name="LIABILITY_ACTIVE" label="<%=si_liability_active%>">
         <t:filter option="<%=si_liability_opt%>"/>
    </t:field>
	<t:field id="23" name="BALANCE_OUT" label="<%=si_balance_out%>">
         <t:filter option="<%=si_balance_out_opt%>"/>
    </t:field>
    <t:field id="25" name="SALDO_OUT" type="number" label="<%=si_saldo_out_char%>">
        <t:filter mask="number(20,2)" operator="range"/>
    </t:field>
    <t:field id="26" name="SALDO_UNLEAD" type="number" label="<%=si_saldo_unlead_char%>">
        <t:filter mask="number(20,2)" operator="range"/>
    </t:field>
    <t:field id="27" name="'<span class=lineStateIco>'||case when client_id_sign = '*' then '&#xFD;' else '&#xFE;' end||'</span>'" type="quote" labelText="Пр." color="d(50)=='*'?'red':'black'" />
    <t:field id="29" name="OWNED_EMPLOYEE" labelText="Владелец счета" >
      <t:filter operator="_search_" mask="10|0-9" size="10" />
    </t:field>
    <t:field id="33" name="client_id_sign_num"  labelText="Пр. привязки к клиенту" type="quote">
      <t:filter operator="like" option="<%=si_sign_option%>"/>
    </t:field>
    <t:field id="50" name="client_id_sign"/>
    <t:field id="19" name="LEAD_LAST_DATE" label="<%=si_lead_last_date%>" type="date">
        <t:filter mask="date" operator="range"/>
    </t:field>
    <t:field id="31" name="DATE_VALIDATE" labelText="Дата последнего изменения" >
      <t:filter mask="date" operator="range" />
    </t:field>
    <t:field id="8" name="OPEN_DATE" label="<%=si_open_date%>" type="date">
        <t:filter mask="date" operator="range"/>
    </t:field>
    <t:field id="32" name="DATE_CHANGE_CONDITION" labelText="Дата изменения состояния" type="date" >
      <t:filter mask="date" operator="range" />
    </t:field>
    <t:grid page="25" withoutCursor="">
        <t:column for="1"/>
        <t:column for="11"/>
        <t:column for="24"/>
        <t:column for="3" align="left"/>
        <t:column for="6" align="right"/>
        <t:column for="7" align="right"/>
        <t:column for="19"/>
        <t:column for="15"/>
        <t:column for="5"/>
        <t:column for="27"/>
        <t:foot>
            <t:row>
                <t:cell for="20"/>
                <t:cell for="21"/>
            </t:row>
        </t:foot>
    </t:grid>
</t:table>
</t:form></t:page>
<%!
    static final int si_formTitle          = SI("Список счетов");
    static final int si_code               = SI("Счёт");
    static final int si_name               = SI("Наименование");
    static final int si_acc_external       = SI("Счёт");
    static final int si_condition          = SI("Состояние");
    static final int si_saldo_out_char     = SI("Сальдо исх.");
    static final int si_saldo_unlead_char  = SI("Сальдо по непр. док.");
    static final int si_open_date          = SI("Дата открытия");
    static final int si_code_coa           = SI("Баланс. счёт");
    static final int si_code_filial        = SI("Филиал");
    static final int si_client_code        = SI("Клиент");
    static final int si_code_currency      = SI("Валюта");
    static final int si_group_code         = SI("Код группы");
    static final int si_sign_registr       = SI("НИББД");
    static final int si_lead_last_date     = SI("Дата последней операции");
    static final int si_a_client_code      = SI("Код кл. внеш. подсис.");
    static final int si_a_account_code     = SI("Код счёта. внеш. подсис.");
    static final int si_liability_active   = SI("Тип счета");
    static final int si_balance_out        = SI("Тип бал. счета");
    static final int si_liability_opt      = SI("<option value='A'>Активный<option value='P'>Пассивный<option value='null'>Активно-пассивный");
    static final int si_balance_out_opt    = SI("<option value='B'>Балансовый<option value=0>Внебалансовый");
    static final int si_sign_option        = SI("<option value='1'>Привязан<option value='0'>Не привязан");
	//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>