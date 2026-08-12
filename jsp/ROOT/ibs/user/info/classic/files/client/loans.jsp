<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="storedObj" class="iabs.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
		Connection conn = cods.getConnection();
		if (conn == null || user.getUserCode() == null)
				pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
		Language lang = new Language(user.getLanguageIndex(), sentences);
		pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
    String client_code         = stored.decryptParameterValue(request,"code","CORE_INFO");//request.getParameter("code");
	String iWHERE = "client_code='"+client_code+"'";
String formTitle = lang.get(si_form_title) + "<div id=sumControls></div>";
%><t:form titleText="<%= formTitle %>" minHeight="fill" minWidth="fill">
<object id="plugin0" type="application/x-fidoprint" width="1" height="1">
	<param name="onload" value="pluginLoaded" />
</object>
	<script src="../style/jquery.min.js"></script>
<script>

</script>
<style>
#sumControls {
	position: absolute;
	right: 40px;
	top: 0;
}

select#actions {
		font: 16px Arial;
		padding:10px;
		width: 262px;
		height: 32px;
		line-height: 32px;
		text-indent: 4px;
		cursor: pointer;
}
.qrcode {
	position: absolute;
	top: 0;
	right: -30px
}
</style>
		<table align=center class=formToolbar>
				<tr>
					<td  align="right" id="tableControls">
				<tr style="background-color:#E4E8FF">
					<td align=center colspan="2" class="filterContainer"><i>
					<span style="color:#1E396D;" id=filterControls></span></i></td>
		</table>
<t:table from="LN_V_CARD" where="<%=iWHERE%>">
	<t:field id="60" name="CLIENT_UID" label="<%=si_client_uid%>">
		<t:filter operator="_like_" size="10" mask="10|0-9"/>
	</t:field>
	<t:field id="1" name="LOAN_ID"								labelText="<span></span>">
			<t:filter mask="10|0-9"										label="<%= si_loan_id %>" showInGrid="" size="10" value="0"/>
	</t:field>
	<t:field id="55" name="CLAIM_ID" label="<%= si_claim_id %>">
			<t:filter mask="10|0-9" size="10"/>
	</t:field>
	<t:field id="28" name="LOAN_ID" />
<% if (user.isHeaderBank()){ %>
	<t:field id="4" name="FILIAL_CODE"						label="<%= si_filial_code %>">
		<t:filter showInGrid="" size="4" mask="mfo" operator="like_" referenceName="filials" referenceURL="/ibs/ls/util/references.jsp" requestName="filials" requestURL="/ibs/ls/util/references.jsp" />
	</t:field>
<% } else { %>
	<t:field id="4" name="FILIAL_CODE"						label="<%= si_filial_code %>"/>
<% } %>
	<t:field id="30" name="NIK_ID"								label="<%= si_niki_id %>">
			<t:filter mask="10|0-9" showInGrid="" size="10" />
	</t:field>
	<t:field id="2" name="CLIENT_CODE"						label="<%= si_client_code %>">
		<t:filter mask="8|0-9" operator="_like_" showInGrid="" size="10" />
	</t:field>
	<t:field id="3" name="CLIENT_NAME"						label="<%= si_client_name %>" type="quote">
		<t:filter size="90" operator="_search_" showInGrid="" />
	</t:field>
	<t:field id="48" name="INN"										label="<%= si_inn %>" >
		<t:filter mask="9|0-9" size="10" />
	</t:field>
	<t:field id="49" name="DOC_NUMBER"						label="<%= si_doc_number %>" >
		<t:filter mask="{2|A-Z}-{7|0-9}" size="10" />
	</t:field>
	<t:field id="44" name="CLIENT_SUBJECT_CODE"		label="<%= si_CL_SUBJECT_CODE %>" >
		 <t:filter optionSQL="select '<option value=''' || CODE || '''>' || CODE || ' - ' || NAME from v_subject_type" />
	</t:field>
	<t:field id="45" name="CLIENT_TYPE"						label="<%= si_CLIENT_TYPE %>" >
		 <t:filter optionSQL="select '<option value=''' || CODE || '''>' || CODE || ' - ' || NAME from ref_type_client_v" />
	</t:field>
	<t:field id="46" name="BORROWER"							label="<%= si_BORROWER %>" >
		 <t:filter optionSQL="select '<option value=''' || ALL_CODE || '''>' || ALL_CODE || ' - ' || NAME from ln_v_borrower" />
	</t:field>
	<t:field id="43" name="PRODUCT_ID||' : '||PRODUCT_NAME" label="<%= si_product %>" type="quote" />
	<t:field id="42" name="PRODUCT_ID"						label="<%= si_product %>">
			<t:filter mask="12|0-9-" referenceName="product2" referenceURL="/ibs/ls/util/references2.jsp" requestName="product2" requestURL="/ibs/ls/util/references2.jsp" />
	</t:field>
	<t:field id="6" name="CONDITION_NAME"					label="<%= si_condition %>" type="quote"/>
	<t:field id="9" name="CLAIM_NUMBER"						label="<%= si_claim_number %>">
			<t:filter mask="5|0-9" size="5" />
	</t:field>
	<t:field id="10" name="LOAN_NUMBER"						label="<%= si_loan_number %>">
			<t:filter mask="5|0-9" size="5"/>
	</t:field>
	<t:field id="13" name="CONTRACT_CODE"					label="<%= si_contract_code %>" type="quote">
			<t:filter mask="14|" size="14" />
	</t:field>
	<t:field id="14" name="CONTRACT_DATE"					label="<%= si_contract_date %>"/>
	<t:field id="16" name="OPEN_DATE"						label="<%= si_open_date %>"	 type="date" >
	    <t:filter mask="date" operator="range"/>
	</t:field>
	<t:field id="17" name="CLOSE_DATE"						label="<%= si_close_date %>" type="date">
			<t:filter mask="date" operator="range"/>
	</t:field>
	<t:field id="19" name="CURRENCY_CODE"					label="<%= si_currency %>">
			<t:filter mask="{3|0-9}" size="3" operator="like_" referenceName="currency" referenceURL="/ibs/ls/util/references.jsp" requestName="currency" requestURL="/ibs/ls/util/references.jsp" />
	</t:field>
	<t:field id="20" name="AMOUNT"								label="<%= si_summ %>"			 type="sum">
			<t:filter mask="number(20,2)" operator="range" size="15"/>
			<t:sum label="<%=si_total_amount%>" type="sum" />
	</t:field>
	<t:field id="26" name="LOAN_TYPE_NAME"				label="<%= si_loan_type %>" type="quote"/>
	<t:field id="27" name="LOAN_TYPE_CODE"				label="<%= si_loan_type %>">
			<t:filter mask="2|0-9" operator="like_" referenceName="loanTypes" referenceURL="/ibs/ls/util/references.jsp" requestName="loanTypes" requestURL="/ibs/ls/util/references.jsp" />
	</t:field>

	<t:field id="33" name="PURPOSE_CODE"					label="<%= si_loan_purpose %>">
			<t:filter mask="6|0-9" operator="like_" referenceName="purposes" referenceURL="/ibs/ls/util/references.jsp" requestName="purposes" requestURL="/ibs/ls/util/references.jsp" />
	</t:field>
	<t:field id="7" name="CLAIM_TYPE_CODE"				    label="<%= si_claim_type %>">
			<t:filter optionSQL="select '<option value=''' || CODE || '''>' || CODE || ' - ' || NAME from LN_V_CLAIM_TYPE" />
	</t:field>
	<t:field id="8" name="CLAIM_TYPE_NAME"				    label="<%= si_claim_type %>" type="quote"/>
	<t:field id="5" name="CONDITION_CODE"					label="<%= si_condition %>" type="quote">
			<t:filter value="11" operator="like_" showInGrid="" optionSQL="select '<option value=''' || CODE || '''>' || NAME from LN_V_LOAN_STATUS_EXT t" />
	</t:field>
	<t:field id="31" name="NK_STATE_CODE"					label="<%= si_niki_state %>">
		<t:filter optionSQL="select '<option value=''' || CODE || '''>' || CODE || ' - ' || NAME from NK_V_REQUEST_CONDITIONS" />
	</t:field>
	<t:field id="32" name="NK_STATE_NAME"					label="<%= si_niki_state %>"	 type="quote" color="d(31)!='O'?'red':'black'"/>
	<t:field id="34" name="PURPOSE_NAME"					label="<%= si_loan_purpose %>" type="quote"/>
	<t:field id="35" name="Eco_Sec_Name"					label="<%= si_eco_sec %>" type="quote"/>
	<t:field id="36" name="Err_Mess"						label="<%= si_nk_err_mess %>" type="quote" color="d(31)!='O'?'red':'black'"/>
	<t:field id="37" name="Nvl(SALDO, 0)"					label="<%= si_saldo %>"				type="sum" color="'black; font-weight:bold;'">
		<t:filter mask="number(20,2)" operator="range"/>
		<t:sum label="<%=si_total_saldo%>" type="sum" />
	</t:field>
	<t:field id="38" name="Ln_Api2.Has_Account_In_Card(Loan_Id, 1)" label="<%= si_main_account %>">
		<t:filter mask="20|0-9" size="25" />
	</t:field>
	<t:field id="39" name="Ln_Api2.Has_Inspector_In_Card(Loan_Id)" label="<%= si_inspector %>">
		<t:filter mask="100|" size="90" />
	</t:field>
	<t:field id="40" name="LOAN_UID"							label="<%= si_loan_uid %>">
		<t:filter mask="10|" size="15" />
	</t:field>

	<t:field id="41" name="Nvl(UNUSED_SUMM_LOAN, 0)" label="<%= si_unused_summ_loan %>" type="sum" />
	<t:field id="47" name="client_id" />
	<t:field id="50"  name="Card_Number"     label="<%=si_card_number%>" >
	</t:field>
	<t:field id="51"  name="Card_Name"      label="<%=si_card_type%>"   />
	<t:field id="53"  name="bs_state"      label="<%=si_bs_state%>"   />
	<t:field id="54"  name="bs_state_name" label="<%=si_bs_state%>"   />
	<t:field id="52"  name="Card_Type"      label="<%=si_card_type%>"  >
	</t:field>
	<t:grid page="25" withoutCursor="">
		<t:column for="28" type="checkbox" name="loansIds"/>
		<t:column for="4"/>
		<t:column for="2"/>
		<t:column for="3"	 align="left"/>
		<t:column for="9"/>
		<t:column for="10"/>
		<t:column for="13" />
		<t:column for="19" />
		<t:column for="20" align="right"/>
		<t:column for="37" align="right"/>
		<t:column for="41" align="right"/>
		<t:column for="6"/>		
    <t:foot>
				<t:row>
						<t:cell for="1" size="90%" />
						<t:cell for="16" size="90%" />
						<t:cell for="17" size="90%" />
						<t:cell for="32" size="90%" />
				</t:row>
				<t:row>
						<t:cell for="8" size="90%" />
						<t:cell for="43" colspan="2" size="96%" align="left" />
						<t:cell for="30" size="90%" />
				</t:row>
				<t:row>
						<t:cell colspan="6" for="26" size="98%"  align="left" />
				</t:row>
				<t:row>
						<t:cell colspan="8" for="34" size="98%" align="left" />
				</t:row>
				<t:row>
						<t:cell colspan="8" for="35" size="98%" align="left" />
				</t:row>
				<t:row>
						<t:cell colspan="8" for="36" size="98%" align="left" />
				</t:row>
		</t:foot>
	</t:grid>
</t:table>
</t:form>
</t:page>
<%!
static final int si_form_title			    = SI("Кредитные договора","Кредит шартномалари","Kredit shartnomalari","Loan agreement");
static final int si_alert1				      = SI("Договор успешно закрыт!","Шартнома муваффа&#1179;иятли ёпилди!","Shartnoma muvaffaqiyatli yopildi!","Contract closed successfully!");
static final int si_alert2				      = SI("Запрос лимита успешно отправлен в ГО!","Бош банкга лимит сўрови муваффа&#1179;иятли юборилди!","Bosh bankga limit so`rovi muvaffaqiyatli yuborildi!","Query limit successfully sent to the HO!");
static final int si_alert3				      = SI("Данные успешно сохранены","Маълумотлар муваффа&#1179;иятли са&#1179;ланди","Ma`lumotlar muvaffaqiyatli saqlandi","Data saved successfully");
static final int si_alert5		  		    = SI("Неопознанный код выполнение","Таниб бўлмаган	бажариш коди","Tanib bo`lmagan	bajarish kodi","Undefined action code");
static final int si_confirm1		  	    = SI("Вы действительно хотите закрыть выделенный кредит?","Белгиланган кредитни &#1203;а&#1179;и&#1179;атда ёпмо&#1179;чимисиз?","Belgilangan kreditni haqiqatda yopmoqchimisiz?","Are you sure you want to close the selected loan?");
static final int si_confirm2			      = SI("Вы действительно хотите перевести отмеченные галочкой кредиты в состояние \"Текущая ссуда\"? Данная операция осуществляется только над ЗАКРЫТЫМИ кредитами!","\"Галочка\" билан белгиланган кредитларни \"Жорий ссуда\" &#1203;олатига ўтказмо&#1179;чимисиз? Бу операция фа&#1179;ат ЁПИЛГАН кредитлар устида бажарилади.!","\"Galochka\" bilan belgilangan kreditlarni \"Joriy ssuda\" holatiga o`tkazmoqchimisiz? Bu operatsiya faqat YoPILGAN kreditlar ustida bajariladi.!","Are you sure you want to transfer credits to marked products in the state of \"The current loan \"? This operation is carried out only over the closing credits!");
static final int si_confirm3			      = SI("Вы действительно хотите отправить в ГО запрос на лимит по выделенному кредиту?","Белгиланган кредит бўйича	Бош банкга лимит сўровини юбормо&#1179;чимисиз!","Belgilangan kredit bo`yicha	Bosh bankga limit so`rovini yubormoqchimisiz!","Are you sure you want to send in a request to HO limit on a loan?");
static final int si_alert4				      = SI("Отметьте галочкой кредиты, выданные отделом Микрофинансирования!","Микромолиялаш бўлими томонидан берилган кредитларни \"галочка\" билан белгиланг!","Mikromoliyalash bo`limi tomonidan berilgan kreditlarni \"galochka\" bilan belgilang!","Tick ??loans to Microfinance department!");
static final int si_confirm4			      = SI("Вы уверены, что отмеченные галочкой кредиты выданы отделом Микрофинансирования?","\"Галочка билан\" белгиланган кредитлар Микромолиялаш бўлими томонидан берилганлигига ишончингиз комилми?","\"Galochka bilan\" belgilangan kreditlar Mikromoliyalash bo`limi tomonidan berilganligiga ishonchingiz komilmi?","Are you sure you marked with a tick loans issued Microfinance department?");
static final int si_loan_action			    = SI("Действия над кредитами","Кредитлар устида амаллар","Kreditlar ustida amallar","Operations on loans");
static final int si_sync_status			    = SI("Синхронизация состояний","&#1202;олатларни мослаштириш","Holatlarni moslashtirish","State Synchronization");
static final int si_loan_close			    = SI("Закрытие кредита","Кредитни ёпиш","Kreditni yopish","Closing credits");
static final int si_set_sign			    	= SI("Установ. признак выдачи отделом Микрофинанс.","Микромолиялаш бўлими томонидан берилиши белгисини ўрнатиш","Mikromoliyalash bo`limi tomonidan berilishi belgisini o`rnatish","SET. sign extradition Microfinance Department.");
static final int si_restore				    	= SI("Возврат в состояние 'Текущая ссуда'","\"Жорий ссуда\" &#1203;олатига &#1179;айтариш","\"Joriy ssuda\" holatiga qaytarish","Return to a state of 'Current loan'");
static final int si_limits				    	= SI("Лимиты","Лимитлар","Limitlar","Limit");
static final int si_limit_request		    = SI("Запрос лимита","Лимит сўрови","Limit so`rovi","Query limit");
static final int si_modify_ln_states    = SI("Выполнить","Бажариш","Bajarish","Implement");
static final int si_prolong_hisory	    = SI("История пролонгации","Муддатини узайтириш тарихи","Muddatini uzaytirish tarixi","History of prolongation");
static final int si_growing_history	    = SI("История ненаращивания","Ўстирмаслик тарихи","O`stirmaslik tarixi","History of not increasing the reporting");
static final int si_trial_history		    = SI("История суд. разбир.","Суд му&#1203;окамаси тарихи","Sud muhokamasi tarixi","The history of the court. Analyzing.");
static final int si_loan_id					    = SI("ID договора","Шартнома ID си#","Shartnoma ID si#","Contract ID#");
static final int si_claim_id 				    = SI("ID заявки","Ариза ID си","Ariza ID si","Claim ID");
static final int si_loan_uid				    = SI("Логин ID","Login ID","Login ID","Login ID");
static final int si_client_code			    = SI("Код клиента","Мижоз коди","Mijoz kodi","Clinet code");
static final int si_client_name			    = SI("Наименование клиента","Мижоз номи","Mijoz nomi","Client name");
static final int si_filial_code			    = SI("Филиал","Филиал","Filial","Branch");
static final int si_condition				    = SI("Состояние","&#1202;олати","Holati","Status");
static final int si_claim_type			    = SI("Тип договора","Шартнома тури","Shartnoma turi","Type of contract");
static final int si_loan_type				    = SI("Вид кредитования","Кредитлаш тури","Kreditlash turi","Type of crediting");
static final int si_claim_number		    = SI("№ заявки","Буюртма №","Buyurtma №","№ application");
static final int si_loan_number			    = SI("Поряд. № кредита","Кредитнинг тартиб №","Kreditning tartib №","№ application");
static final int si_contract_code		    = SI("№ договора","Шартнома №","Shartnoma №","№ contract");
static final int si_contract_date		    = SI("Дата подписания договора","Шартномани имзолаш санаси","Shartnomani imzolash sanasi","Date of sign contract");
static final int si_open_date				    = SI("Дата начала договора","Шартноманинг бошланиш санаси","Shartnomaning boshlanish sanasi","Start date of the contract");
static final int si_close_date			    = SI("Дата окончания договора","Шартноманинг Тугаш санаси","Shartnomaning Tugash sanasi","The agreement expires");
static final int si_currency				    = SI("Валюта","Валюта","Valyuta","Cuurency");
static final int si_summ					      = SI("Сумма по договору","Шартнома бўйича сумма","Shartnoma bo`yicha summa","The amount sum under the contract");
static final int si_niki_id					    = SI("Уник. № договора в НИКИ","КАМИда шартноманинг уникал №","KAMIda shartnomaning unikal №","Unique. agreement number in NICKY");
static final int si_niki_state			    = SI("Статус НИКИ","КАМИ статуси","KAMI statusi","NICKY Status");
static final int si_loan_purpose		    = SI("Цель кредита","Кредит ма&#1179;сади","Kredit maqsadi","The purpose of the loan");
static final int si_currency2				    = SI("Справочник валют","Валюталар маълумотномаси","Valyutalar ma`lumotnomasi","Currency reference");
static final int si_loan_types			    = SI("Виды кредитования","Кредитлаш турлари","Kreditlash turlari","Type of crediting");
static final int si_eco_sec					    = SI("Экономический сектор","И&#1179;тисодий сектор","Iqtisodiy sektor","Economic sector");
static final int si_nk_err_mess			    = SI("Причина отбраковки НИКИ","КАМИ да носозликга чи&#1179;ариш сабаблари","KAMI da nosozlikga chiqarish sabablari","The reason for the rejection of NIKI");
static final int si_transfer_to_LNB	    = SI("Перевод в модуль \"Учет пробленных кредитов\"","","","");
static final int si_QRCode					    = SI("Инфо (QR код)","","","");
static final int si_saldo					      = SI("Остаток","","","");
static final int si_others					    = SI("Другое","","","");
static final int si_documents				    = SI("Документы","","","");
static final int si_main_account		    = SI("Основной ссудный счет","","","");
static final int si_inspector				    = SI("Инспектор","","","");
static final int si_total_amount		    = SI("Общая - Сумма договор","","","");
static final int si_total_saldo			    = SI("&nbsp; Остаток","","","");
static final int si_show_Limit_graph    = SI("Лимит", "Лимит","Limit","Limit");
static final int si_cancel_bs_count    	= SI("Списание долгов со страхового полиса (Benefit Supreme)", "","","");
static final int si_overdraft				    = SI("Овердрафт","","","");
static final int si_unused_summ_loan    = SI("Неисп.част.","","","");
static final int si_product					    = SI("Кредитный продукт","","","");
static final int si_CL_SUBJECT_CODE	    = SI("Тип субъекта","","","");
static final int si_CLIENT_TYPE			    = SI("Тип клиента","","","");
static final int si_BORROWER				    = SI("Тип заёмщика","","","");
static final int si_contract				    = SI("Договор","","","");
static final int si_guarantors			    = SI("Договор поручительства","","","");
static final int si_compensation		    = SI("Реестр компенсаций","","","");
static final int si_graphic					    = SI("Договор график","","","");
static final int si_inn						      = SI("Инн","","","");
static final int si_doc_number          = SI("Серия и номер паспорта","","","");
static final int si_plagin              = SI("Плагин для печата не установлен!!!","","","");
static final int si_download            = SI("Скачать плагин","","","");
static final int si_credit_source_code  = SI("Код источник финансирования","","","");
static final int si_btn_back            = SI("Назад","","","");
static final int si_add_child_loan      = SI("Добавить дочерный договор","","","");
static final int si_source_cred					= SI("Источник финансирования","","","");
static final int si_departament_id			= SI("Департамент","Департамент","Department","Department");
static final int si_client_uid		      = SI("Клиент UID","","","");
static final int si_loan_pr_customer               = SI("Код цели потреб.кредита","","","");
static final int si_card_number         = SI("Номер карты","","","");
static final int si_card_type           = SI("Тип карты","","","");
static final int si_bs_state            = SI("Состояние Benefit Supreme","","","");
static final int si_option		          = SI("<option value='SV'>Uzcard<option value='GL'>Humo","","","");
static final int si_group               = SI("Группа","","","");
static final int si_monitoring          = SI("Мониторинг","","","");
static final int si_act_monitoring      = SI("Акт мониторинга","","","");
%><%@ include file="/language.jsp" %>
