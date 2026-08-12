<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
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
    String code        		= stored.decryptParameterValue(request,"code","CORE_INFO");//request.getParameter("code");
    String subject          = Util.quotesSQL(request.getParameter("subject"));
	String iWhere = " client_code='"+code+"' and Client_Type_Code='"+subject+"'";
%><t:form title="<%=si_formTitle%>" minHeight="fill" minWidth="fill">
<table class=formToolbar>
  <tr>
      <td id=tableControls align=right>
</table>
<t:table from="SV_V_EMISSION_CONTRACTS" where="<%=iWhere%>">
  <t:field id="6"  name="Filial_Code"                 label="<%=si_Filial_Code%>">
      <t:filter mask="mfo" size="10" referenceName="filials" requestName="getFilialName" referenceURL="/ibs/sv/util/references.jsp" requestURL="/ibs/sv/util/references.jsp"/>
  </t:field>
  <t:field id="1"  name="Contract_Id"                 label="<%=si_Contract_Id%>">
    <t:filter mask="12|0-9" />
  </t:field>
  <t:field id="2"  name="Contract_Parent_Id"          label="<%=si_Contract_Parent_Id%>">
    <t:filter mask="12|0-9" />
  </t:field>
  <t:field id="3"  name="Client_Id"                   label="<%=si_Client_Id%>">
    <t:filter mask="10|0-9" />
  </t:field>
  <t:field id="10"  name="Cardholder_Id"              label="<%=si_Cardholder_Id%>">
      <t:filter mask="10|0-9" />
  </t:field>
  <t:field id="4"  name="Client_Code"                 label="<%=si_Client_Code%>">
    <t:filter mask="clientcode" />
  </t:field>
  <t:field id="5"  name="Client_Name"                 label="<%=si_Client_Name%>" type="quote">
    <t:filter mask="100|" operator="_search_" size="70" />
  </t:field>
  <t:field id="24"  name="Client_Type_Code"        label="<%=si_Client_Type_Code%>">
      <t:filter optionSQL="select '<option value=' || Subject_Type || '>' || Name from V_Subject_Type" />
  </t:field>
  <t:field id="11"  name="Cardholder_Name"            label="<%=si_Cardholder_Name%>" type="quote">
      <t:filter mask="100|" operator="_search_" size="70" />
  </t:field>
  <t:field id="15"  name="Organization"              label="<%=si_Organization_Name%>" type="quote">
      <t:filter mask="100|" operator="_search_" size="70" />
  </t:field>
  <t:field id="7"  name="Contract_Type_Name"          label="<%=si_Contract_Type%>" type="quote" />
  <t:field id="8"  name="Type_Group_Id"               label="<%=si_Contract_Type%>">
      <t:filter optionSQL="select '<option value=' || Id || '>' || Name from SV_V_EMISSION_CONTRACT_GROUPS" />
  </t:field>
  <t:field id="9"  name="Contract_Number"             label="<%=si_Contract_Number%>" type="quote">
      <t:filter mask="20|" operator="_search_" />
  </t:field>
  <t:field id="26" name="Currency_Code"    label="<%= si_Currency %>"/>
  <t:field id="22"  name="Contract_State_Id"          label="<%=si_Contract_State%>">
    <t:filter optionSQL="select '<option value=' || Id || '>' || Name from SV_V_Contract_States" />
  </t:field>
  <t:field id="12"  name="Card_Number_Char"           label="<%=si_Card_Number_with_space%>" type="quote">
    <t:filter  operator="_like_" />
  </t:field>
  <t:field id="13"  name="Card_Number"                label="<%=si_Card_Number%>">
      <t:filter mask="16|" operator="_like_" />
  </t:field>
  <t:field id="14"  name="Date_Expiry"                label="<%=si_Card_Date_Expiry%>" />
  <t:field id="18"  name="Date_Registered"            label="<%=si_Card_Date_Registered%>" type="datetime"/>
  <t:field id="16"  name="Card_State"                 label="<%=si_Card_State%>" type="quote" />
  <t:field id="17"  name="Card_SV_State"              label="<%=si_Card_SV_State%>" type="quote" />
  <t:field id="19"  name="State_Id"                   label="<%=si_Card_State%>">
      <t:filter optionSQL="select '<option value=' || Id || '>' || Name from SV_V_Card_States" />
  </t:field>
  <t:field id="20"  name="Sv_State_Code"              label="<%=si_Card_SV_State%>">
      <t:filter optionSQL="select '<option value=' || Code || '>' || Name from SV_V_Card_SvStates" />
  </t:field>
  <t:field id="21"  name="Date_Registered_Truncated"  label="<%=si_Card_Date_Registered%>" type="date">
      <t:filter operator="range" mask='date'/>
  </t:field>
  <t:field id="23"  name="Contract_State_Name"        label="<%=si_Contract_State%>" type="quote" />
  <t:field id="27"  name="Doc_Num"         			  label="<%=si_doc_num%>"  >
    <t:filter  operator="_like_"  />   
  </t:field>
  <t:field id="28"  name="birthday"        			  label="<%=si_birthday%>"  >
	    <t:filter mask="date" />
  </t:field>
    <t:grid page="" rowColor="d(16) == '3' ? 'red' : 'black'">
    <t:column for="6" />
    <t:column for="7" />
    <t:column for="9" />
    <t:column for="11" align="left" />
    <t:column for="12" />
    <t:column for="16"/>
    <t:column for="23"/>
	<t:column for="17" />
    <t:foot>
        <t:row>
            <t:cell for="3" />
            <t:cell for="1" />
            <t:cell for="2" />
            <t:cell for="18" />
        </t:row>
        <t:row>
            <t:cell colspan="9" for="5" size="100%"/>
        </t:row>
        <t:row>
            <t:cell colspan="9" for="15" size="100%"/>
        </t:row>
    </t:foot>
 </t:grid>
</t:table>
</t:form></t:page>
<%!
    static final int si_formTitle            = SI("Договора на пластиковые карты (ПК)","","");
    static final int si_Client_Id            = SI("ID клиента","","");
    static final int si_Contract_Id          = SI("ID договора","","");
    static final int si_Contract_Parent_Id   = SI("ID родит. договора","","");
    static final int si_Client_Code          = SI("Код клиента","","");
    static final int si_Client_Name          = SI("Клиент","","");
    static final int si_Filial_Code          = SI("Филиал","","");
    static final int si_Contract_Type        = SI("Тип договора","","");
    static final int si_Contract_Number      = SI("Номер договора","","");
    static final int si_Cardholder_Id        = SI("ID картодержателя","","");
    static final int si_Cardholder_Name      = SI("Картодержатель","","");
    static final int si_Card_Number          = SI("Номер ПК","","");
    static final int si_Card_Number_with_space          = SI("Номер ПК с пробелом","","");
    static final int si_Card_Date_Expiry     = SI("ПК валидна до","","");
    static final int si_Organization_Name    = SI("Организация","","");
    static final int si_Card_State           = SI("Состояние ПК","","");
    static final int si_Card_SV_State        = SI("SV состояние ПК","","");
    static final int si_Card_Date_Registered = SI("Дата регистрации ПК","","");
    static final int si_Contract_State       = SI("Состояние договора","","");
    static final int si_Client_Type_Code     = SI("Тип клиента","","");
    static final int si_Currency             = SI("Валюта договора","","");
    static final int SI_LIST                 = SI("Список карт организации","","");
    static final int SI_CHANGE               = SI("История изменений","","");
    static final int SI_EDIT                 = SI("Изменить","","");
    static final int SI_DELETE               = SI("Удалить","","");
    static final int SI_CHANGE_STATE         = SI("Смена Состояния","","");
    static final int SI_CONFIRM              = SI("Вы действительно хотите удалить указанный договор на ПК?","","");
    static final int SI_CONTRACT_DELETED     = SI("Договор успешно удален!","","");
    static final int si_birthday             = SI("Дата рождения");
	static final int si_doc_num              = SI("Паспорт ");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>