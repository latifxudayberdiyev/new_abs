<%@ page contentType="text/html;charset=WINDOWS-1251" language="java"%><%
%><%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %><%
%><%@ page import="oracle.sql.*, oracle.jdbc.driver.*" %><%
%><%@ taglib uri="/WEB-INF/cms.tld" prefix="t"%><%
%><jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" /><%
%><jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session"/><%
%><jsp:useBean id="user" class="iabs.User" scope="session" /><%
%><jsp:useBean id="util" class="iabs.oraUtil" scope="session" /><%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null)
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
//-------------------------------------------------------------------------------------------------
%><t:page><%
	String client_code = stored.decryptParameterValue(request,"code","CORE_INFO");//request.getParameter("code");
%><t:form title="<%= si_titleText %>" minHeight="fill" minWidth="fill" >
<link href="../util/font.css" rel="stylesheet" type="text/css">
<table align="center" class="formToolbar" cellspacing=2>
<tr><td id="tableControls" align="right">
</table><%
	String whereClause = "cl_acc like'%"+client_code+"___'";
%>
<t:table from="cf_card_client_documents_v" where="<%=whereClause%>">
	<t:field id="11" name="client_acc" label="<%=si_client_acc%>" />
	<t:field id="1" name="num_doc" label="<%=si_doc_no%>" type="quote" >
		<t:filter operator="_search_" mask="10|" size="10"/>
		<t:sort orderKey="3"/>
	</t:field>
	<t:field id="2" name="date_doc" label="<%=si_doc_date%>" >
		<t:filter operator="range" mask="date" size="10"/>
		<t:sort orderKey="2" direction="desc"/>
	</t:field>
	<t:field id="13" name="doc_sum_pay" type="sum" label="<%=si_doc_sum_pay%>">
			<t:filter operator="range" mask="number(20,2)" />
	</t:field>
	<t:field id="3" name="sum_card2" label="<%=si_sum_card2%>" type="sum">
		<t:filter operator="range" mask="number(20,2)" />
	</t:field>
	<t:field id="4" name="co_mfo" label="<%=si_co_mfo%>">
		<t:filter mask="{5|0-9}" size="5" />
	</t:field>
	<t:field id="5" name="co_acc" label="<%=si_receiver_acc%>" >
		<t:filter operator="_search_" mask="20|0-9" size="23"/>
	</t:field>
	<t:field id="6" name="purpose_code" label="<%=si_pay_pur_code%>"	>
		<t:filter operator="_search_" mask="4|0-9" size="6"/>
	</t:field>
	<t:field id="7" name="state_name" label="<%=si_state%>" type="quote" />
	<t:field id="8" name="card_id" label="<%=si_card_id%>"/>
	<t:field id="9" name="state" label="<%=si_state%>" >
		<t:filter option="<%= si_state2 %>" />
	</t:field>
	<t:field id="10" name="has_unlead">
	  <t:sort orderKey="1" direction="desc"/>
	</t:field>
	<t:field id="24" name="sum_paid" label="<%=si_sum_paid%>" type="sum" />
	<t:field id="25" name="sum_unlead" label="<%=si_sum_unlead%>" type="sum" />
	<t:field id="12" name="date_reactivate" type="date" label="<%=si_date_reactivate%>"/>
	<t:field id="14" name="reason_reactivate" type="quote" label="<%=si_reason_reactivate%>"/>
	<t:field id="15" name="cl_acc" />
	<t:field id="16" name="is_active" label="<%=si_is_active%>" >
		<t:filter option="<%=si_is_active_option%>" />
	</t:field>
	<t:field id="17" name="cl_name" type="quote" label="<%=si_cl_name%>"/>
	<t:field id="18" name="co_name" type="quote" label="<%=si_co_name%>"/>
	<t:field id="19" name="source_task ||' - '|| source_task_name" label="<%=si_source_task%>" type="quote" />
	<t:field id="20" name="source_task" label="<%=si_source_task%>" >
		<t:filter optionSQL="select '<option value=' || task_code ||'>' || task_code ||' - '||label from cf_source_tasks_v" />
	</t:field>
	<t:field id="21" name="lock_level" label="<%=si_lock_level%>" >
		<t:filter option="<%=si_level_option%>" />
	</t:field>
	<t:field id="22" name="lock_level_name" label="<%=si_lock_level%>" type="quote" />
	<t:field id="23" name="purpose_name" label="<%=si_pay_purpose_name%>" type="quote" >
		<t:filter operator="_search_" size="30"/>
	</t:field>
	<t:field id="38" name="group_code" label="<%=si_group_code%>" />
	<t:field id="39" name="account_owner" label="<%=si_account_owner%>">
	  <t:filter mask="9|0-9-" size="9" referenceName="user_name" referenceURL="/ibs/core/util/references.jsp" requestName="user_name" requestURL="/ibs/core/util/references.jsp" />
	</t:field>
	<t:field id="40" name="(select account_owner ||' - '|| core_adm_util.user_name(account_owner, 'N') from dual)" label="<%=si_account_owner%>" type="quote"/>
	<t:grid numbering="" page="" withoutCursor="" rowColor="(d(9)=='A' && d(10)==1)?'#FF0000':(d(9)=='N')?'#0000FF':(d(9)=='S')?'#965AD8':''">
		<t:column for="8" align="left"/>
		<t:column for="1" />
		<t:column for="2" />
		<t:column for="13" align="right"/>
		<t:column for="3" align="right"/>
		<t:column for="4" />
		<t:column for="5" />
		<t:column for="6" />
		<t:column for="7" />
		<t:foot>
			<t:row>
				<t:cell for="19" size="100%" align="left"/>
				<t:cell for="22" size="100%" align="left"/>
			</t:row>
			<t:row>
				<t:cell for="24" align="right"/>
				<t:cell for="25" align="right"/>
			</t:row>
		  <t:row>
				<t:cell for="12" align="left"/>
				<t:cell for="14" size="100%" align="left"/>
			</t:row>
			<t:row>
				<t:cell for="38" align="left"/>
				<t:cell for="40" size="100%" align="left"/>
			</t:row>
			<t:row>
				<t:cell for="23" size="100%" colspan="3" align="left"/>
			</t:row>
		</t:foot>
	</t:grid>
</t:table>
</t:form>
</t:page>

<%!
static final int si_titleText         = SI("Документы","&#1202;ужжатлар","Hujjatlar","Documnets");
static final int si_print             = SI("Печать","Чоп &#1179;илиш","Chop qilish","Print");
static final int si_edit              = SI("Изменить","Ўзгартириш","O`zgartirish","Edit");
static final int si_pay               = SI("Оплатить","Тўлаш","To`lash","Pay for");
static final int si_add               = SI("Добавить","&#1178;ўшиш","Qo`shish","Add");
static final int si_recall            = SI("Отозвать","&#1178;айтариб олиш","Qaytarib olish","Recall");
static final int si_protocol_block    = SI("Протокол разблокировки","Блокдан чи&#1179;ариш протоколи","Blokdan chiqarish protokoli","Unblocking Protocol");
static final int si_testclient        = SI("Тест Автооплаты по Клиенту","Мижоз бўйича синов автотўлови","Mijoz bo`yicha sinov avtoto`lovi","Test AutoPay for Client");
static final int si_synchro        	  = SI("Синхронизация","","","");
static final int si_history           = SI("История по операциям","Операциялар тарихи","Operatsiyalar tarixi","History of Operations");
static final int si_chose_act         = SI("Выберите действие","&#1202;аракатни танланг","Harakatni tanlang","Select the action");
static final int si_chose_action      = SI("Выполнить действие","&#1202;аракатни бажариш","Harakatni bajarish","Run action");
static final int si_change_state      = SI("Активировать/Деактивировать","Активлаштириш/Деактивлаштириш","Aktivlashtirish/Deaktivlashtirish","Activate/Deactivate");
static final int si_confirm           = SI("Вы действительно хотите перенести все документы на основной расчетный счет этой записи?","Сиз &#1203;а&#1179;и&#1179;атдан &#1203;ам барча хужжатларни мижознинг асосий хисоб ра&#1179;амига ўтказмо&#1179;чимисиз?","Siz haqiqatdan ham barcha xujjatlarni mijozning asosiy xisob raqamiga o`tkazmoqchimisiz?","Are you sure you want to transfer all the documents on the main account this record?");
static final int si_movedocs          = SI("Перенести все документы на основной расчетный счет","Барча &#1203;ужжатларни асосий &#1203;исоб-китоб вара&#1171;ига ўтказиш","Barcha hujjatlarni asosiy hisob-kitob varag`iga o`tkazish","Transfer all documents to the main account");
static final int si_activate          = SI("Вы действительно хотите активировать этот документ?","&#1202;а&#1179;и&#1179;атдан &#1203;ам ушбу &#1203;ужжатни активлаштирмо&#1179;чимисиз?","Haqiqatdan ham ushbu hujjatni aktivlashtirmoqchimisiz?","Are you sure you want to activate this document");
static final int si_search            = SI("Поиск :","&#1178;идириш :","Qidirish :","Search :");
static final int si_doc_date          = SI("Дата","Сана","Sana","Date");
static final int si_doc_no            = SI("Номер<br>документа","&#1202;ужжат<br>тартиб ра&#1179;ами","Hujjat<br>tartib raqami","Document<br>number");
static final int si_sum_card2         = SI("Остаток","&#1178;олди&#1179;","Qoldiq","Residue");
static final int si_pay_pur_code      = SI("Код назначения<br>платежа","Тўлов<br>ма&#1179;сади коди","To`lov<br>maqsadi kodi","Code<br>for payment");
static final int si_pay_purpose_name  = SI("Назначение платежа","Тўлов максади","To`lov maksadi","Payment purpose");
static final int si_edit_protocol     = SI("Протокол изменений","Ўзгаришлар протоколи","O`zgarishlar protokoli","The protocol change");
static final int si_co_mfo            = SI("МФО<br>получателя","Олувчи<br>МФОси","Oluvchi<br>MFOsi","MFO<br>recipient");
static final int si_state             = SI("Состояние","&#1202;олати","Holati","State");
static final int si_sum_paid          = SI("Оплаченная сумма","Тўланган сумма","To`langan summa","");
static final int si_receiver_acc      = SI("Счет получателя","Олувчи &#1203;исобвара&#1171;и","Oluvchi hisobvarag`i","Beneficiary Account");
static final int si_state2            = SI("<option value=A>Активный<option value=N>Новый<option value=S>Неактивный<option value=C>Закрытый<option value=D>Удален","<option value=A>Актив<option value=N>Янги<option value=S>Ноактив<option value=C>Ёпилган<option value=D>Ўчирилган","<option value=A>Aktiv<option value=N>Yangi<option value=S>Noaktiv<option value=C>Yopilgan<option value=D>O`chirilgan","<option value=A>Active<option value=N>New<option value=S>Inactive<option value=C>Closed<option value=D>Deleted");
static final int si_date_reactivate   = SI("Срок истечения отсрочки","Кечиктиришнинг тугаш санаси","Kechiktirishning tugash sanasi","The expiry date");
static final int si_reason_reactivate = SI("Причина отсрочки","Ижрони кечиктириш сабаби","Ijroni kechiktirish sababi","The reason for postponing");
static final int si_doc_sum_pay       = SI("Сумма<br>по документу","&#1202;ужжат бўйича<br>сумма","Hujjat bo`yicha<br>summa","The amount<br>of the document");
static final int si_is_active         = SI("Текущий","&#1202;озирги","Hozirgi","Current");
static final int si_is_active_option  = SI("<option value='Y'>Да<option value='N'>Нет","<option value='Y'>&#1202;а<option value='N'>Йў&#1179;","<option value='Y'>Ha<option value='N'>Yo`q","<option value='Y'>Yes<option value='N'>No");
static final int si_client_acc        = SI("Счет плательщика","Тўловчи &#1203;исобвара&#1171;и","To`lovchi hisobvarag`i","Account of the payer");
static final int si_cl_name           = SI("Наименование плательщика","Тўловчи номи","To`lovchi nomi","Payer name");
static final int si_co_name           = SI("Наименование получателя","Олувчи номи","Oluvchi nomi","Name of a consignee");
static final int si_source_task       = SI("Модуль, породивший документ","&#1202;ужжатни киритган модул","Hujjatni kiritgan modul","The parent Task");
static final int si_card_id           = SI("Код","Код","Kod","Code");
static final int si_lock_level        = SI("Уровень блокировки","Блокировка даражаси","Blokirovka darajasi","");
static final int si_level_option      = SI("<option value='0'>Филиал<option value='1'>Головной банк","<option value='0'>Филиал<option value='1'>Бош банк","<option value='0'>Filial<option value='1'>Bosh bank","<option value='0'>Filial<option value='1'>Header Branch");
static final int si_operation         = SI("Операции","Операциялар","Operatsiyalar","Operations");
static final int si_protocol          = SI("Протоколы","Протоколлар","Protokollar","Protocols");
static final int si_sum_unlead        = SI("Непроведенный остаток","Ўтказилмаган колдик","O`tkazilmagan koldik","Unlead saldo");
static final int si_group_code		  = SI("Код группы","","","");
static final int si_account_owner	  = SI("Счет владелеца","","","");
static final int si_success     	  = SI("Успешно выполнено!","Муваффакиятли бажарилди!","Muvaffaqiyatli bajarildi!","Completed successfully!");
//-------------------------------------------------------------------------------------------------
%><%@ include file="/language.jsp" %>
