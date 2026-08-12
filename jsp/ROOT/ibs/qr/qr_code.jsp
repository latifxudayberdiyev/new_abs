<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<jsp:useBean id="util" class="iabs.oraUtil" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		pageContext.setAttribute(Resource.SESSION_EXPIRED, Boolean.TRUE);
	}
	Language lang = new Language(user.getLanguageIndex(), sentences);
	pageContext.setAttribute(Resource.STR_LANGUAGE, lang);
	String id = request.getParameter("id");
	String res_qr = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAkgAAAJIAQAAAACyZSYCAAAETElEQVR4nO3VwXLcMAwDUPz/T7NtCIDQTnrp5FY4G8eWyKccMFzMT12oVKlSpUqVKlX6fyTs9fuFD+PPn00WDD/D58F1VqoUkqLFN/dqdbX9nexzZ6VKuQKwR+UIUeyT3NkKdlaq9I0URXz4anZtDDUWV6r0N0ncvnPvkmlp5Faq9K0kT4RTd1HlYTfsEJ2VKoXE3X/4kVup0oVSl9awz5HAbdREnBl8Nleq5FGlaLrrayc2BycrjO+8q1Tpbhk5KIRa2rXhUQquj6pU6ZXciggpGE4GEcHB6DCllSq9yWTILmxcparIKq4MMGRUqnR3LzB17kcchaecf6G3SpXczmJNuVuaR2Ma467CSpVCwsQXpluOH66qhQ2Xy0qVUoLid9n0EROveB7Dr1RJkhM4D6kd749CGOHEVKr0SnABARzMeDKgzqyWx9GsVEmSLqbuY74xhAfpXS1TqdIjbdtmDc6jpP2DSCvDy95KlVJiuT0riuNGlTVxopsqVcpkKn2RwXEKecLoCC8MY41KlULKd309biLl682jMGbioFKlDylSOriQjtLpA4neGSysVCm6beDZB9N3vnPqTVSq9Ehz8fIQcxT3A4f3ErnxVXGlStfhkGXnVyRV7SMAEhjHtVKlkxQ75hOabgIvqbiia61U6U3mBg1UGLir9yBM6mmoVOmR3ujt0Nt1uBgXVnYgeitVMrA1yNfhu3a87WfomkqVQoox519NNM06+Dg9M5hPMitVchIpDMcdq3ZnSVf7P7ghWalS3DH63Ww6dMAdSCAO0/mVKk2UDCcYlLWYert1R42HnTcqVYqo6VmVETw3GXGpZyAqVXqljaAKvcEV8IeIPn6rVCkl5c3D7qNYqM5kbcy5SpUsjYVRDnWPm9LJgxRlWZUqzf1ZiuXr+Qy2OpIzDjAiwJUq6abRxnTiDBUyr3lzTCtVSon18WFitx4Kb8b3dSpVsjRccyGrkYdkdJlbBFCpUibTyZvjbvwNvyLvi/KOElKpkm4Aq5RBCQqdQZ12raQrVUrpwrZ1h2+3jllpXxXiSpUe6aszEpf1DKrzGSHGR1ulSurlxrjTQb3qMzUMh6+VKp3kqE08mOGuVuZe1VGpUkgZLiijiqLWVHHJ3ByrtlIlJ/OGGzzD1MAtZ1ZBVtGb8UqVni7mk6twQvkKeBWX40qVQvK20il6F+0OQ4i44c14pUrukIgI4hUDSqsrLseVKukmy9ymENqcj+Bi/EOrUqWTVON+yFtA6xlVLem4SpWcTGft8FuB20leJcVKlR6JV4y2G2SrMYIciA6mElup0kmRvW19gEitoD3Vs28qVUrp8miAxYwrKwC3plip0itF/hhPNSq20af0arVSpe8l3cHcbeoyob7xRG1UqvRdMvPGpNq7vDKy43ulSim9+dQjIzp8ZmrddWGuVCklhU3AqB6TrVo+9KBKlRzKn7gqVapUqVKlSpX+D+kXs84JdWr+pe4AAAAASUVORK5CYII=";
	String client_name = "YATT IBRAGIMOV FARRUX XUSNITDINOVICH";
	
	//res_qr = stored.execFunction("QR_ONLINE_API.get_res_qr(" + id + ")");
	//client_name = stored.execFunction("QR_ONLINE_API.get_client_name(" + id + ")");
%>
<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="x-ua-compatible" content="IE=11; IE=10; IE=9; IE=8; IE=7">
	<meta charset="UTF-8">
	<title>QR.uz - <%=client_name%></title>
	<style>
		* { margin: 0; padding: 0; box-sizing: border-box; }

		body {
			font-family: Arial, "Helvetica Neue", Helvetica, sans-serif;
			background-color: #EFF4FA;
		}

		.toolbar {
			background: #f5f5f5;
			padding: 10px 20px;
			display: flex;
			justify-content: space-between;
			align-items: center;
			border-bottom: 1px solid #ddd;
		}

		.toolbar h3 { margin: 0; color: #333; }

		.toolbar-btn {
			padding: 10px 20px;
			border: none;
			border-radius: 8px;
			cursor: pointer;
			font-size: 14px;
			font-weight: 600;
			margin-right: 10px;
		}

		.btn-horizontal { background: linear-gradient(135deg, #3498db, #2980b9); color: white; }
		.btn-vertical { background: linear-gradient(135deg, #00B2F3, #0288d1); color: white; }
		.toolbar-btn:hover { opacity: 0.9; }

		.main-wrapper {
			display: flex;
			justify-content: center;
			align-items: center;
			min-height: calc(100vh - 60px);
			padding: 20px;
		}

		/* ============ Preview - A4 sahifa (297x210mm) ============ */
		.page {
			position: relative;
			width: 842px;
			max-width: 100%;
			aspect-ratio: 297 / 210;
			background: #002F82;
			overflow: hidden;
		}

		/* Poster: SVG nisbati saqlanadi (cho'zilmaydi) */
		.poster {
			position: absolute;
			top: 0;
			left: 5.21%;
			width: 89.58%;
			height: 89.52%;
			background-image: url("QR_UZ_Horizontal.svg");
			background-size: 100% 100%;
			background-repeat: no-repeat;
		}

		/* Oq footer */
		.footer {
			position: absolute;
			left: 0;
			bottom: 0;
			width: 100%;
			height: 10.48%;
			background: #ffffff;
			display: flex;
			align-items: center;
			justify-content: space-between;
			padding: 0 4%;
		}

		.footer img.f-logo { height: 65%; width: auto; display: block; }
		.footer img.f-qr { height: 88%; width: auto; display: block; }

		.footer .f-text {
			flex: 1;
			text-align: center;
			color: #002F82;
			font-weight: 900;
			font-size: 35px;
			padding: 0 2%;
		}

		/* QR placeholder - HTML/CSS bilan */
		.qr-on-svg {
			position: absolute;
			left: 53.32%;
			top: 13.95%;
			width: 40.50%;
			height: 57.31%;
			background: white;
			border: 4px solid #00B2F3;
			border-radius: 24px;
			padding: 12px;
			display: flex;
			align-items: center;
			justify-content: center;
		}

		.qr-on-svg img {
			width: 100%;
			height: 100%;
			object-fit: contain;
		}

		.client-name {
			position: absolute;
			left: 53.32%;
			width: 40.50%;
			top: 73%;
			text-align: center;
			color: white;
			font-weight: 500;
			font-size: 13px;
		}

		/* Title */
		.title {
			position: absolute;
			left: 3.9%;
			top: 22%;
			width: 45%;
			color: white;
			font-weight: 900;
			line-height: 1;
			letter-spacing: -0.02em;
			font-size: 60px;
		}

		.title .accent { color: #00B2F3; }

		.subtitle {
			position: absolute;
			left: 3.9%;
			top: 72%;
			width: 45%;
			color: #00B2F3;
			font-size: 18px;
			font-weight: 500;
		}

		/* Step labels */
		.step-label {
			position: absolute;
			text-align: center;
			color: white;
			font-size: 9px;
			width: 13%;
		}

		.step-label .title-line {
			font-weight: 700;
			margin-bottom: 2px;
		}

		.step-label .ru-line {
			color: #b3d4f5;
			font-size: 10px;
			font-weight: 400;
		}

		.step-1 { left: 52%; top: 90%; }
		.step-2 { left: 68%; top: 90%; }
		.step-3 { left: 83%; top: 90%; }

		/* Call center banner - HTML/CSS bilan */
		.call-center {
			position: absolute;
			left: 3.8%;
			top: 84%;
			width: 30.3%;
			height: 7.4%;
			background: #00B2F3;
			border-radius: 9999px;
			display: flex;
			align-items: center;
			justify-content: center;
			color: white;
			font-weight: 700;
			font-size: 22px;
		}

		/* Responsive */
		@media screen and (max-width: 900px) {
			.title { font-size: 40px; }
			.subtitle { font-size: 13px; }
			.step-label { font-size: 8px; }
			.step-label .ru-line { font-size: 7px; }
			.call-center { font-size: 16px; }
			.client-name { font-size: 10px; }
			.qr-on-svg { border-width: 3px; border-radius: 16px; padding: 8px; }
			.footer .f-text { font-size: 11px; }
		}

		@media screen and (max-width: 600px) {
			.title { font-size: 28px; }
			.subtitle { font-size: 10px; }
			.step-label { font-size: 6px; }
			.step-label .ru-line { font-size: 5px; }
			.call-center { font-size: 11px; }
			.client-name { font-size: 7px; }
			.qr-on-svg { border-width: 2px; border-radius: 10px; padding: 5px; }
			.footer .f-text { font-size: 8px; }
		}
	</style>
</head>
<body>

<div class="toolbar">
	<div>
		<button class="toolbar-btn btn-horizontal" onclick="openPdfWindow('a4')">
			<%=lang.get(si_download)%> A4
		</button>
		<button class="toolbar-btn btn-vertical" onclick="openPdfWindow('a5')">
			<%=lang.get(si_download)%> A5
		</button>
	</div>
	<h3><%=client_name%></h3>
</div>

<div class="main-wrapper">
	<div class="page">
		<div class="poster">
		<div class="title">
			<span class="accent">Yagona<br>QR-kod</span><br>orqali<br>to'lang
		</div>

		<div class="subtitle">
			Оплата через единый QR-код
		</div>

		<div class="qr-on-svg">
			<img src="<%=res_qr%>" />
		</div>
		<div class="client-name"><%=client_name%></div>

		<div class="step-label step-1">
			<div class="title-line">Ilovani oching</div>
			<div class="ru-line">Проверьте приложение</div>
		</div>
		<div class="step-label step-2">
			<div class="title-line">QR-kodni skanerlang</div>
			<div class="ru-line">Отсканируйте QR-код</div>
		</div>
		<div class="step-label step-3">
			<div class="title-line">To'lovni tasdiqlang</div>
			<div class="ru-line">Подтвердите оплату</div>
		</div>

			<div class="call-center">Call center: 13-38</div>
		</div>

		<div class="footer">
			<img class="f-logo" src="logo_sqb_mobile.svg" alt="SQB Mobile" />
			<div class="f-text">To'lovlar uchun tezkor yechim</div>
			<img class="f-qr" src="qr_app.png" alt="App QR" />
		</div>
	</div>
</div>

<script>
	function openPdfWindow(format) {
		window.open('qr_code_pdf.jsp?id=<%=id%>&format=' + format, '_blank', 'width=1000,height=750');
	}
</script>
</body>
</html>

<%!
    static final int si_title = SI("QR-код", "QR-код", "QR-kod", "QR code");
    static final int si_exit = SI("Выход", "Чи&#1179;иш", "Chiqish", "Exit");
    static final int si_download = SI("Скачать", "Юклаб олиш", "Yuklab olish", "Download");
%>
<%@ include file="/language.jsp" %>
