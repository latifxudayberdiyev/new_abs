<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*, java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
%><t:page><%
%><t:form minWidth="fill" minHeight="fill">
	<link rel="stylesheet" href="css/pf.css">
	<style>
		/* pf.css'dagi qoidalar go({}) orqali qayta yuklanganda ba'zan ishlamay
		   qoladigan holatlar kuzatilgan (feedback-cms-jsp-framework-gotchas #5) -
		   shu sabab quick-actions qatorining stillari shu yerda ham inline
		   takrorlanadi, tashqi faylga bog'liq bo'lmasligi uchun. */
		.pf-page .pf-quick-actions{ display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:20px; }
		.pf-page .pf-quick-action{ display:flex; align-items:center; gap:12px; background:var(--pf-card); border:1px solid var(--pf-border); border-radius:var(--pf-radius); padding:16px; box-shadow:var(--pf-shadow); cursor:pointer; text-decoration:none; color:inherit; transition:border-color .15s,transform .15s; }
		.pf-page .pf-quick-action:hover{ border-color:var(--pf-accent); transform:translateY(-1px); }
		.pf-page .pf-quick-action .pf-qa-icon{ width:32px; height:32px; border-radius:8px; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
		.pf-page .pf-quick-action .pf-qa-icon svg{ width:16px; height:16px; }
		.pf-page .pf-quick-action .pf-qa-title{ font-size:13.5px; font-weight:700; color:var(--pf-text); }
		.pf-page .pf-quick-action .pf-qa-sub{ font-size:11.5px; color:var(--pf-text-faint); margin-top:2px; }
		@media (max-width:1100px){ .pf-page .pf-quick-actions{ grid-template-columns:1fr 1fr; } }
		/* Donut diagramma - xuddi shu sababdan (yuqoridagi izohga qarang) inline. */
		.pf-page .pf-donut-wrap{ display:flex; align-items:center; gap:28px; flex-wrap:wrap; }
		.pf-page .pf-donut-box{ position:relative; width:132px; height:132px; flex-shrink:0; }
		.pf-page .pf-donut-box svg{ display:block; width:132px; height:132px; }
		.pf-page .pf-donut-track{ stroke:var(--pf-gray-bg); }
		.pf-page .pf-donut-center{ position:absolute; inset:0; display:flex; flex-direction:column; align-items:center; justify-content:center; text-align:center; pointer-events:none; }
		.pf-page .pf-donut-total{ font-size:26px; font-weight:800; color:var(--pf-text); line-height:1; letter-spacing:-.5px; }
		.pf-page .pf-donut-sub{ font-size:10.5px; color:var(--pf-text-faint); margin-top:3px; max-width:64px; line-height:1.2; }
		.pf-page .pf-donut-legend{ flex-direction:column; gap:10px; }
	</style>
	<script>
		function onLoad() {
		}
	</script>
	<div class="pf-page">
		<div class="pf-head">
			<div>
				<h1><%=lang.get(si_title)%></h1>
				<p><%=lang.get(si_subtitle)%></p>
			</div>
		</div>

		<div class="pf-quick-actions">
			<a class="pf-quick-action" href="products.jsp">
				<div class="pf-qa-icon" style="background:#EAEEFF;color:#3457EF;">
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
				</div>
				<div>
					<div class="pf-qa-title"><%=lang.get(si_qa_add_product)%></div>
					<div class="pf-qa-sub"><%=lang.get(si_qa_add_product_sub)%></div>
				</div>
			</a>
			<a class="pf-quick-action" href="categories.jsp">
				<div class="pf-qa-icon" style="background:#F1EDFF;color:#7C5CFC;">
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
				</div>
				<div>
					<div class="pf-qa-title"><%=lang.get(si_qa_add_category)%></div>
					<div class="pf-qa-sub"><%=lang.get(si_qa_add_category_sub)%></div>
				</div>
			</a>
			<a class="pf-quick-action" href="attributes.jsp">
				<div class="pf-qa-icon" style="background:#E7F7EE;color:#178A4C;">
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"></polygon><polyline points="2 17 12 22 22 17"></polyline><polyline points="2 12 12 17 22 12"></polyline></svg>
				</div>
				<div>
					<div class="pf-qa-title"><%=lang.get(si_qa_add_attribute)%></div>
					<div class="pf-qa-sub"><%=lang.get(si_qa_add_attribute_sub)%></div>
				</div>
			</a>
			<a class="pf-quick-action" href="parameters.jsp">
				<div class="pf-qa-icon" style="background:#FDF3E0;color:#C88A1B;">
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
				</div>
				<div>
					<div class="pf-qa-title"><%=lang.get(si_qa_add_parameter)%></div>
					<div class="pf-qa-sub"><%=lang.get(si_qa_add_parameter_sub)%></div>
				</div>
			</a>
		</div>

		<div class="pf-stats-grid"><%
			int cProducts = 0, cCategories = 0, cAttributes = 0, cParameters = 0;
			{
				Statement stC = null;
				ResultSet rsC = null;
				try {
					stC = conn.createStatement();
					rsC = stC.executeQuery(
						"select (select count(*) from PF_PRODUCTS_V) as C_PRODUCTS," +
						"       (select count(*) from PF_R_CATEGORIES_V) as C_CATEGORIES," +
						"       (select count(*) from PF_R_ATTRIBUTES_V) as C_ATTRIBUTES," +
						"       (select count(*) from PF_R_PARAMETERS_V) as C_PARAMETERS" +
						"  from dual"
					);
					if (rsC.next()) {
						cProducts = rsC.getInt("C_PRODUCTS");
						cCategories = rsC.getInt("C_CATEGORIES");
						cAttributes = rsC.getInt("C_ATTRIBUTES");
						cParameters = rsC.getInt("C_PARAMETERS");
					}
				} finally {
					if (rsC != null) rsC.close();
					if (stC != null) stC.close();
				}
			}
		%>
			<div class="pf-stat-card">
				<div class="pf-stat-icon" style="background:#EAEEFF;color:#3457EF;">
					<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path></svg>
				</div>
				<div class="pf-stat-label"><%=lang.get(si_stat_products)%></div>
				<div class="pf-stat-value"><%=cProducts%></div>
			</div>
			<div class="pf-stat-card">
				<div class="pf-stat-icon" style="background:#F1EDFF;color:#7C5CFC;">
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="7" height="7"></rect><rect x="14" y="3" width="7" height="7"></rect><rect x="14" y="14" width="7" height="7"></rect><rect x="3" y="14" width="7" height="7"></rect></svg>
				</div>
				<div class="pf-stat-label"><%=lang.get(si_stat_categories)%></div>
				<div class="pf-stat-value"><%=cCategories%></div>
			</div>
			<div class="pf-stat-card">
				<div class="pf-stat-icon" style="background:#E7F7EE;color:#178A4C;">
					<svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 2 7 12 12 22 7 12 2"></polygon><polyline points="2 17 12 22 22 17"></polyline><polyline points="2 12 12 17 22 12"></polyline></svg>
				</div>
				<div class="pf-stat-label"><%=lang.get(si_stat_attributes)%></div>
				<div class="pf-stat-value"><%=cAttributes%></div>
			</div>
			<div class="pf-stat-card">
				<div class="pf-stat-icon" style="background:#FDF3E0;color:#C88A1B;">
					<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"></path><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"></path></svg>
				</div>
				<div class="pf-stat-label"><%=lang.get(si_stat_parameters)%></div>
				<div class="pf-stat-value"><%=cParameters%></div>
			</div>
		</div>

		<div class="pf-card">
			<h3><%=lang.get(si_status_title)%></h3><%
			String[] stateCodes = {"DRAFT", "ON_APPROVAL", "ACTIVE", "SUSPENDED", "PASSIVE", "ARCHIVED"};
			String[] stateColors = {"#9AA1B2", "#C88A1B", "#178A4C", "#D64545", "#0E9A93", "#6B7280"};
			int[] stateLabels = {si_state_draft, si_state_on_approval, si_state_active, si_state_suspended, si_state_passive, si_state_archived};
			int[] stateCounts = new int[stateCodes.length];
			int stateTotal = 0;
			{
				Statement stSt = null;
				ResultSet rsSt = null;
				try {
					stSt = conn.createStatement();
					rsSt = stSt.executeQuery("select CURRENT_STATE, count(*) as C from PF_PRODUCTS_V group by CURRENT_STATE");
					while (rsSt.next()) {
						String s = rsSt.getString("CURRENT_STATE");
						int c = rsSt.getInt("C");
						for (int i = 0; i < stateCodes.length; i++) {
							if (stateCodes[i].equals(s)) { stateCounts[i] = c; break; }
						}
						stateTotal += c;
					}
				} finally {
					if (rsSt != null) rsSt.close();
					if (stSt != null) stSt.close();
				}
			}
			if (stateTotal > 0) {
		%>
			<div class="pf-donut-wrap">
				<div class="pf-donut-box">
					<svg viewBox="0 0 36 36">
						<circle class="pf-donut-track" cx="18" cy="18" r="15.9155" fill="none" stroke-width="4"></circle><%
						/* Donut segmentlari - r=15.9155 tanlangan, chunki bunda aylana
						   uzunligi ~100 ga teng, shu sabab foiz qiymatini to'g'ridan-to'g'ri
						   stroke-dasharray sifatida ishlatish mumkin (standart SVG-donut
						   texnikasi). Har bir segment soat 12 dan boshlanishi uchun
						   dashoffset=25 dan boshlab, oldingi segmentlar yig'indisi
						   ayiriladi (manfiy qiymat SVG'da xavfsiz - naqsh davri bo'yicha
						   avtomatik aylanadi). */
						double cumulative = 0;
						for (int i = 0; i < stateCodes.length; i++) {
							if (stateCounts[i] == 0) continue;
							double pct = 100.0 * stateCounts[i] / stateTotal;
							double dashOffset = 25 - cumulative;
					%>
						<circle cx="18" cy="18" r="15.9155" fill="none" stroke="<%=stateColors[i]%>" stroke-width="4"
							stroke-dasharray="<%=pct%> <%=100-pct%>" stroke-dashoffset="<%=dashOffset%>"></circle><%
							cumulative += pct;
						}
					%>
					</svg>
					<div class="pf-donut-center">
						<div class="pf-donut-total"><%=stateTotal%></div>
						<div class="pf-donut-sub"><%=lang.get(si_donut_products_word)%></div>
					</div>
				</div>
				<div class="pf-legend pf-donut-legend"><%
					for (int i = 0; i < stateCodes.length; i++) {
						if (stateCounts[i] == 0) continue;
				%>
					<div class="pf-li"><span class="pf-sw" style="background:<%=stateColors[i]%>;"></span><%=lang.get(stateLabels[i])%> &mdash; <b><%=stateCounts[i]%></b></div><%
					}
				%>
				</div>
			</div><%
			} else {
		%>
			<div class="pf-empty"><%=lang.get(si_empty_recent)%></div><%
			}
		%>
		</div>

		<div class="pf-two-col">
			<div class="pf-card">
				<div class="pf-card-head">
					<h3><%=lang.get(si_recent_products)%></h3>
					<a class="pf-btn pf-btn-ghost" style="padding:6px 12px;font-size:12px;" href="products.jsp"><%=lang.get(si_all_products)%></a>
				</div>
				<div class="pf-mini-list"><%
					Statement stR = null;
					ResultSet rsR = null;
					boolean anyR = false;
					try {
						stR = conn.createStatement();
						rsR = stR.executeQuery(
							"select NAME, CATEGORY_NAME, CURRENT_STATE from PF_PRODUCTS_V order by CREATED_AT desc fetch first 5 rows only"
						);
						while (rsR.next()) {
							anyR = true;
							String pName = rsR.getString("NAME");
							String pCat = rsR.getString("CATEGORY_NAME");
							String pState = rsR.getString("CURRENT_STATE");
				%>
					<div class="pf-mini-row">
						<div>
							<div class="pf-mini-name"><%=esc(pName)%></div>
							<div class="pf-mini-sub"><%=esc(pCat)%></div>
						</div>
						<span class="pf-badge pf-badge-gray"><%=esc(pState)%></span>
					</div><%
						}
					} finally {
						if (rsR != null) rsR.close();
						if (stR != null) stR.close();
					}
					if (!anyR) {
				%>
					<div class="pf-empty"><%=lang.get(si_empty_recent)%></div><%
					}
				%>
				</div>
			</div>
			<div class="pf-card">
				<div class="pf-card-head">
					<h3><%=lang.get(si_categories_title)%></h3>
					<a class="pf-btn pf-btn-ghost" style="padding:6px 12px;font-size:12px;" href="categories.jsp"><%=lang.get(si_all_categories)%></a>
				</div>
				<div class="pf-mini-list"><%
					Statement stCa = null;
					ResultSet rsCa = null;
					boolean anyCa = false;
					try {
						stCa = conn.createStatement();
						rsCa = stCa.executeQuery("select NAME, ATTR_COUNT, PRODUCT_COUNT from PF_R_CATEGORIES_V order by NAME");
						while (rsCa.next()) {
							anyCa = true;
							String caName = rsCa.getString("NAME");
							int caAttr = rsCa.getInt("ATTR_COUNT");
							int caProd = rsCa.getInt("PRODUCT_COUNT");
				%>
					<div class="pf-mini-row">
						<div class="pf-mini-name"><%=esc(caName)%></div>
						<span class="pf-badge pf-badge-blue"><%=caAttr%> <%=lang.get(si_stat_attributes)%></span>
					</div><%
						}
					} finally {
						if (rsCa != null) rsCa.close();
						if (stCa != null) stCa.close();
					}
					if (!anyCa) {
				%>
					<div class="pf-empty"><%=lang.get(si_empty_categories)%></div><%
					}
				%>
				</div>
			</div>
		</div>

		<div class="pf-two-col">
			<div class="pf-card">
				<div class="pf-card-head">
					<h3><%=lang.get(si_attributes_title)%></h3>
					<a class="pf-btn pf-btn-ghost" style="padding:6px 12px;font-size:12px;" href="attributes.jsp"><%=lang.get(si_all_attributes)%></a>
				</div>
				<div class="pf-mini-list"><%
					Statement stAt = null;
					ResultSet rsAt = null;
					boolean anyAt = false;
					try {
						stAt = conn.createStatement();
						rsAt = stAt.executeQuery(
							"select v.NAME, v.PARAM_COUNT from PF_R_ATTRIBUTES_V v order by v.SORT_ORDER"
						);
						while (rsAt.next()) {
							anyAt = true;
							String atName = rsAt.getString("NAME");
							int atParams = rsAt.getInt("PARAM_COUNT");
				%>
					<div class="pf-mini-row">
						<div class="pf-mini-name"><%=esc(atName)%></div>
						<span class="pf-badge pf-badge-amber"><%=atParams%> <%=lang.get(si_stat_parameters)%></span>
					</div><%
						}
					} finally {
						if (rsAt != null) rsAt.close();
						if (stAt != null) stAt.close();
					}
					if (!anyAt) {
				%>
					<div class="pf-empty"><%=lang.get(si_empty_attributes)%></div><%
					}
				%>
				</div>
			</div>
			<div class="pf-card">
				<h3><%=lang.get(si_attention_title)%></h3>
				<div class="pf-mini-list"><%
					boolean anyAttn = false;
					Statement stA1 = null;
					ResultSet rsA1 = null;
					try {
						stA1 = conn.createStatement();
						rsA1 = stA1.executeQuery("select NAME from PF_R_CATEGORIES_V where ATTR_COUNT = 0 order by NAME");
						while (rsA1.next()) {
							anyAttn = true;
							String n = rsA1.getString("NAME");
				%>
					<div class="pf-mini-row">
						<div class="pf-mini-name"><%=esc(n)%></div>
						<span class="pf-badge pf-badge-gray"><%=lang.get(si_attention_no_attrs)%></span>
					</div><%
						}
					} finally {
						if (rsA1 != null) rsA1.close();
						if (stA1 != null) stA1.close();
					}
					Statement stA2 = null;
					ResultSet rsA2 = null;
					try {
						stA2 = conn.createStatement();
						rsA2 = stA2.executeQuery(
							"select v.NAME from PF_R_ATTRIBUTES_V v" +
							" where v.MODULE_CODE is null" +
							"   and v.PARAM_COUNT = 0" +
							" order by v.NAME"
						);
						while (rsA2.next()) {
							anyAttn = true;
							String n = rsA2.getString("NAME");
				%>
					<div class="pf-mini-row">
						<div class="pf-mini-name"><%=esc(n)%></div>
						<span class="pf-badge pf-badge-gray"><%=lang.get(si_attention_no_params)%></span>
					</div><%
						}
					} finally {
						if (rsA2 != null) rsA2.close();
						if (stA2 != null) stA2.close();
					}
					if (!anyAttn) {
				%>
					<div class="pf-empty"><%=lang.get(si_attention_empty)%></div><%
					}
				%>
				</div>
			</div>
		</div>
	</div>
</t:form>
</t:page>
<%!
	static String esc(String s) {
		if (s == null) return "";
		return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
	}
	static final int si_title = SI("Панель управления", "Бош&#1179;арув панели", "Boshqaruv paneli", "Dashboard");
	static final int si_subtitle = SI("Сводка по продуктам, их жизненному циклу, категориям, атрибутам и параметрам.", "Ма&#1203;сулотлар, уларнинг &#1203;аёт цикли, категориялар, атрибутлар ва параметрлар б&#1118;йича умумий к&#1118;риниш.", "Mahsulotlar, ularning hayot sikli, kategoriyalar, atributlar va parametrlar bo'yicha umumiy ko'rinish.", "Overview of products, their lifecycle, categories, attributes, and parameters.");
	static final int si_qa_add_product = SI("Создать продукт", "Ма&#1203;сулот яратиш", "Mahsulot yaratish", "Create product");
	static final int si_qa_add_product_sub = SI("Новый продукт с нуля", "Нолдан янги ма&#1203;сулот", "Noldan yangi mahsulot", "New product from scratch");
	static final int si_qa_add_category = SI("Добавить категорию", "Категория &#1179;&#1118;шиш", "Kategoriya qo'shish", "Add category");
	static final int si_qa_add_category_sub = SI("Новый тип продукта", "Янги ма&#1203;сулот тури", "Yangi mahsulot turi", "New product type");
	static final int si_qa_add_attribute = SI("Добавить атрибут", "Атрибут &#1179;&#1118;шиш", "Atribut qo'shish", "Add attribute");
	static final int si_qa_add_attribute_sub = SI("Новая группа параметров", "Янги параметрлар гуру&#1203;и", "Yangi parametrlar guruhi", "New parameter group");
	static final int si_qa_add_parameter = SI("Добавить параметр", "Параметр &#1179;&#1118;шиш", "Parametr qo'shish", "Add parameter");
	static final int si_qa_add_parameter_sub = SI("В атрибут", "Атрибутга", "Atributga", "Into an attribute");
	static final int si_stat_products = SI("Продукты", "Ма&#1203;сулотлар", "Mahsulotlar", "Products");
	static final int si_stat_categories = SI("Категории", "Категориялар", "Kategoriyalar", "Categories");
	static final int si_stat_attributes = SI("Атрибуты", "Атрибутлар", "Atributlar", "Attributes");
	static final int si_stat_parameters = SI("Параметры", "Параметрлар", "Parametrlar", "Parameters");
	static final int si_status_title = SI("Продукты по статусам жизненного цикла", "Ма&#1203;сулотлар &#1203;аёт цикли &#1203;олатлари б&#1118;йича", "Mahsulotlar hayot sikli holatlari bo'yicha", "Products by lifecycle status");
	static final int si_donut_products_word = SI("продуктов", "ма&#1203;сулот", "mahsulot", "products");
	static final int si_recent_products = SI("Недавние продукты", "С&#1118;нгги ма&#1203;сулотлар", "So'nggi mahsulotlar", "Recent products");
	static final int si_all_products = SI("Все продукты", "Барча ма&#1203;сулотлар", "Barcha mahsulotlar", "All products");
	static final int si_categories_title = SI("Категории продуктов", "Ма&#1203;сулот категориялари", "Mahsulot kategoriyalari", "Product categories");
	static final int si_all_categories = SI("Все категории", "Барча категориялар", "Barcha kategoriyalar", "All categories");
	static final int si_attributes_title = SI("Атрибуты и параметры", "Атрибутлар ва параметрлар", "Atributlar va parametrlar", "Attributes and parameters");
	static final int si_all_attributes = SI("Все атрибуты", "Барча атрибутлар", "Barcha atributlar", "All attributes");
	static final int si_attention_title = SI("Требуют внимания", "Эътибор талаб &#1179;илади", "E'tibor talab qiladi", "Needs attention");
	static final int si_empty_recent = SI("Продукты пока не созданы.", "&#1202;али ма&#1203;сулотлар яратилмаган.", "Hali mahsulotlar yaratilmagan.", "No products created yet.");
	static final int si_empty_categories = SI("Категории пока не созданы.", "&#1202;али категориялар яратилмаган.", "Hali kategoriyalar yaratilmagan.", "No categories created yet.");
	static final int si_empty_attributes = SI("Атрибуты пока не созданы.", "&#1202;али атрибутлар яратилмаган.", "Hali atributlar yaratilmagan.", "No attributes created yet.");
	static final int si_attention_empty = SI("Особых замечаний нет.", "Ало&#1203;ида эслатма й&#1118;&#1179;.", "Alohida eslatma yo'q.", "Nothing needs attention.");
	static final int si_attention_no_attrs = SI("без атрибутов", "атрибутсиз", "atributsiz", "no attributes");
	static final int si_attention_no_params = SI("без параметров", "параметрсиз", "parametrsiz", "no parameters");
	static final int si_state_draft = SI("Черновик", "&#1178;оралама", "Qoralama", "Draft");
	static final int si_state_on_approval = SI("На согласовании", "Келишувда", "Kelishuvda", "In approval");
	static final int si_state_active = SI("Активен", "Фаол", "Faol", "Active");
	static final int si_state_suspended = SI("Приостановлен", "Т&#1118;хтатилган", "To'xtatilgan", "Suspended");
	static final int si_state_archived = SI("В архиве", "Архивда", "Arxivda", "Archived");
	static final int si_state_passive = SI("Пассивный режим", "Пассив режим", "Passiv rejim", "Passive mode");
%>
<%@ include file="/language.jsp" %>
