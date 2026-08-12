<%@ page contentType="text/html;charset=WINDOWS-1251" language="java" %>
<%@ page import="java.sql.*,java.util.*, uz.fido_biznes.cms.*" %>
<%@ page import="oracle.sql.*, oracle.jdbc.*" %>
<%@ taglib uri="/WEB-INF/cms.tld" prefix="t" %>
<jsp:useBean id="cods" class="iabs.oraDBConnection" scope="session" />
<jsp:useBean id="stored" class="uz.fido_biznes.sql.StoredObject" scope="session" />
<jsp:useBean id="user" class="iabs.User" scope="session" />
<%
	Connection conn = cods.getConnection();
	if (conn == null || user.getUserCode() == null) {
		response.sendRedirect("/ibs/login.jsp");
		return;
	}
	String id = request.getParameter("id");
	String format = request.getParameter("format");
	if (format == null) format = "a4";
	boolean isA5 = "a5".equals(format);
	String res_qr = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAkgAAAJIAQAAAACyZSYCAAAETElEQVR4nO3VwXLcMAwDUPz/T7NtCIDQTnrp5FY4G8eWyKccMFzMT12oVKlSpUqVKlX6fyTs9fuFD+PPn00WDD/D58F1VqoUkqLFN/dqdbX9nexzZ6VKuQKwR+UIUeyT3NkKdlaq9I0URXz4anZtDDUWV6r0N0ncvnPvkmlp5Faq9K0kT4RTd1HlYTfsEJ2VKoXE3X/4kVup0oVSl9awz5HAbdREnBl8Nleq5FGlaLrrayc2BycrjO+8q1Tpbhk5KIRa2rXhUQquj6pU6ZXciggpGE4GEcHB6DCllSq9yWTILmxcparIKq4MMGRUqnR3LzB17kcchaecf6G3SpXczmJNuVuaR2Ma467CSpVCwsQXpluOH66qhQ2Xy0qVUoLid9n0EROveB7Dr1RJkhM4D6kd749CGOHEVKr0SnABARzMeDKgzqyWx9GsVEmSLqbuY74xhAfpXS1TqdIjbdtmDc6jpP2DSCvDy95KlVJiuT0riuNGlTVxopsqVcpkKn2RwXEKecLoCC8MY41KlULKd309biLl682jMGbioFKlDylSOriQjtLpA4neGSysVCm6beDZB9N3vnPqTVSq9Ehz8fIQcxT3A4f3ErnxVXGlStfhkGXnVyRV7SMAEhjHtVKlkxQ75hOabgIvqbiia61U6U3mBg1UGLir9yBM6mmoVOmR3ujt0Nt1uBgXVnYgeitVMrA1yNfhu3a87WfomkqVQoox519NNM06+Dg9M5hPMitVchIpDMcdq3ZnSVf7P7ghWalS3DH63Ww6dMAdSCAO0/mVKk2UDCcYlLWYert1R42HnTcqVYqo6VmVETw3GXGpZyAqVXqljaAKvcEV8IeIPn6rVCkl5c3D7qNYqM5kbcy5SpUsjYVRDnWPm9LJgxRlWZUqzf1ZiuXr+Qy2OpIzDjAiwJUq6abRxnTiDBUyr3lzTCtVSon18WFitx4Kb8b3dSpVsjRccyGrkYdkdJlbBFCpUibTyZvjbvwNvyLvi/KOElKpkm4Aq5RBCQqdQZ12raQrVUrpwrZ1h2+3jllpXxXiSpUe6aszEpf1DKrzGSHGR1ulSurlxrjTQb3qMzUMh6+VKp3kqE08mOGuVuZe1VGpUkgZLiijiqLWVHHJ3ByrtlIlJ/OGGzzD1MAtZ1ZBVtGb8UqVni7mk6twQvkKeBWX40qVQvK20il6F+0OQ4i44c14pUrukIgI4hUDSqsrLseVKukmy9ymENqcj+Bi/EOrUqWTVON+yFtA6xlVLem4SpWcTGft8FuB20leJcVKlR6JV4y2G2SrMYIciA6mElup0kmRvW19gEitoD3Vs28qVUrp8miAxYwrKwC3plip0itF/hhPNSq20af0arVSpe8l3cHcbeoyob7xRG1UqvRdMvPGpNq7vDKy43ulSim9+dQjIzp8ZmrddWGuVCklhU3AqB6TrVo+9KBKlRzKn7gqVapUqVKlSpX+D+kXs84JdWr+pe4AAAAASUVORK5CYII=";
	String client_name = "YATT IBRAGIMOV FARRUX XUSNITDINOVICH";
	
	//res_qr = stored.execFunction("QR_ONLINE_API.get_res_qr(" + id + ")");
	//client_name = stored.execFunction("QR_ONLINE_API.get_client_name(" + id + ")");
%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>PDF - <%=client_name%></title>
	<style>
		* { margin: 0; padding: 0; box-sizing: border-box; }

		body {
			margin: 0;
			padding: 0;
			background: #222;
			font-family: Arial, "Helvetica Neue", Helvetica, sans-serif;
		}

		/* Sahifa = poster + oq footer */
		#pdf-content {
			display: none;
			position: relative;
			background: #002F82;   /* poster yon chetlari bilan bir xil rang */
			overflow: hidden;
		}

		/* Poster: SVG nisbati aynan saqlanadi -> cho'zilmaydi */
		.poster {
			position: absolute;
			top: 0;
			background-size: 100% 100%;
			background-repeat: no-repeat;
		}

		/* Oq footer */
		.footer {
			position: absolute;
			left: 0;
			bottom: 0;
			width: 100%;
			background: #ffffff;
			display: flex;
			align-items: center;
			justify-content: space-between;
		}

		.footer img.f-logo { width: auto; display: block; }
		.footer img.f-qr { display: block; }

		.footer .f-text {
			flex: 1;
			text-align: center;
			color: #002F82;
			font-weight: 700;
			line-height: 1.2;
		}

		<% if (isA5) { %>
		/* ============ A5 PORTRAIT (148x210mm) - Vertikal SVG ============ */
		#pdf-content {
			width: 148mm;
			height: 210mm;
		}

		.poster {
			left: 6.16mm;
			width: 135.68mm;
			height: 192mm;
			background-image: url("QR_UZ_Vertical.svg");
		}

		/* QR placeholder - HTML/CSS */
		.qr-on-svg {
			position: absolute;
			left: 22.69%;
			top: 34.92%;
			width: 57.31%;
			height: 40.50%;
			background: white;
			border: 0.8mm solid #00B2F3;
			border-radius: 5mm;
			padding: 2mm;
			display: flex;
			align-items: center;
			justify-content: center;
		}

		.client-name {
			position: absolute;
			left: 22.69%;
			width: 57.31%;
			top: 75.7%;
			text-align: center;
			color: white;
			font-size: 7pt;
			font-weight: 500;
		}

		.title {
			position: absolute;
			left: 5%;
			top: 13.5%;
			width: 90%;
			text-align: center;
			color: white;
			font-weight: 900;
			font-size: 32pt;
			line-height: 1.05;
			letter-spacing: -0.02em;
		}

		.subtitle {
			position: absolute;
			left: 5%;
			top: 28.5%;
			width: 90%;
			text-align: center;
			color: #00B2F3;
			font-size: 11pt;
			font-weight: 500;
		}

		.step-label {
			position: absolute;
			text-align: center;
			color: white;
			font-size: 6.5pt;
			width: 28%;
		}

		.step-label .title-line { font-weight: 700; margin-bottom: 0.7mm; }
		.step-label .ru-line { color: #b3d4f5; font-size: 6pt; font-weight: 400; }

		.step-1 { left: 12%; top: 87%; }
		.step-2 { left: 39%; top: 87%; }
		.step-3 { left: 64%; top: 87%; }

		/* Call center banner - HTML/CSS */
		.call-center {
			position: absolute;
			left: 11%;
			top: 92%;
			width: 78%;
			height: 6.5%;
			background: #00B2F3;
			border-radius: 9999px;
			display: flex;
			align-items: center;
			justify-content: center;
			color: white;
			font-weight: 700;
			font-size: 14pt;
		}

		/* Footer - A5 */
		.footer { height: 18mm; padding: 0 6mm; }
		.footer img.f-logo { height: 9mm; }
		.footer img.f-qr { width: 14mm; height: 14mm; }
		.footer .f-text { font-size: 22pt; padding: 0 3mm; font-weight: 900;}

		<% } else { %>
		/* ============ A4 LANDSCAPE (297x210mm) - Gorizontal SVG ============ */
		#pdf-content {
			width: 297mm;
			height: 210mm;
		}

		.poster {
			left: 15.48mm;
			width: 266.04mm;
			height: 188mm;
			background-image: url("QR_UZ_Horizontal.svg");
		}

		/* QR placeholder - HTML/CSS */
		.qr-on-svg {
			position: absolute;
			left: 53.32%;
			top: 13.95%;
			width: 40.50%;
			height: 57.31%;
			background: white;
			border: 1mm solid #00B2F3;
			border-radius: 6mm;
			padding: 3mm;
			display: flex;
			align-items: center;
			justify-content: center;
		}

		.client-name {
			position: absolute;
			left: 53.32%;
			width: 40.50%;
			top: 73%;
			text-align: center;
			color: white;
			font-size: 11pt;
			font-weight: 500;
		}

		.title {
			position: absolute;
			left: 3.9%;
			top: 22%;
			width: 45%;
			color: white;
			font-weight: 900;
			font-size: 50pt;
			line-height: 1;
			letter-spacing: -0.02em;
		}

		.title .accent { color: #00B2F3; }

		.subtitle {
			position: absolute;
			left: 3.9%;
			top: 67%;
			width: 45%;
			color: #00B2F3;
			font-size: 16pt;
			font-weight: 500;
		}

		.step-label {
			position: absolute;
			text-align: center;
			color: white;
			font-size: 9pt;
			width: 13%;
		}

		.step-label .title-line { font-weight: 700; margin-bottom: 1mm; }
		.step-label .ru-line { color: #b3d4f5; font-size: 8pt; font-weight: 400; }

		.step-1 { left: 52%; top: 90%; }
		.step-2 { left: 68%; top: 90%; }
		.step-3 { left: 83%; top: 90%; }

		/* Call center banner - HTML/CSS */
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
			font-size: 19pt;
		}

		/* Footer - A4 */
		.footer { height: 22mm; padding: 0 12mm; }
		.footer img.f-logo { height: 12mm; }
		.footer img.f-qr { width: 17mm; height: 17mm; }
		.footer .f-text { font-size: 37pt; padding: 0 6mm; font-weight: 900;}

		<% } %>

		.qr-on-svg img {
			width: 100%;
			height: 100%;
			object-fit: contain;
		}

		.status-msg {
			color: #fff;
			font-size: 18px;
			text-align: center;
			margin-top: 40px;
		}
	</style>
</head>
<body>

<div id="pdf-content">

	<div class="poster">
		<% if (isA5) { %>
		<div class="title">
			Yagona QR-kod<br>orqali to'lang
		</div>
		<% } else { %>
		<div class="title">
			<span class="accent">Yagona<br>QR-kod</span><br>orqali<br>to'lang
		</div>
		<% } %>

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

<p class="status-msg" id="status">PDF tayyorlanmoqda...</p>

<script src="/ibs/qr/scripts/html2pdf.bundle.min.js"></script>
<script>
	window.onload = function () {
		var isA5 = <%= isA5 %>;
		var el = document.getElementById('pdf-content');
		var status = document.getElementById('status');

		el.style.display = 'block';

		setTimeout(function () {
			html2pdf().set({
				margin: 0,
				filename: '<%=client_name%>_<%= isA5 ? "A5" : "A4" %>.pdf',
				image: {type: 'jpeg', quality: 0.98},
				html2canvas: {
					scale: 2,
					useCORS: true,
					allowTaint: true,
					backgroundColor: null
				},
				jsPDF: {
					unit: 'mm',
					format: isA5 ? 'a5' : 'a4',
					orientation: isA5 ? 'portrait' : 'landscape'
				}
			}).from(el).save()
				.then(function () {
					document.body.innerHTML = '<p class="status-msg" style="color:#1abc9c">PDF yuklandi! Oynani yoping.</p>';
				})
				.catch(function (e) {
					status.innerHTML = 'Xatolik: ' + e.message;
					status.style.color = '#e74c3c';
				});
		}, 800);
	};
</script>
</body>
</html>
