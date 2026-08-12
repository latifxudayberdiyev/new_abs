var month = document.getElementsByName("month");
var year = document.getElementsByName("year");
var gInx = 0;
var divView = "<table border=\"0\" bgcolor=\"#6699cc\" width=\"165\">"
	+ "<tr align=\"center\">"
	+ "<td nowrap>"
	+ "<input type=\"Button\" value=\" < \" onclick=\"GoBack('<')\" style=\"border: solid 1 black;font-family: Arial;font-size: 8pt;\">"
	+ " " + getMonths() + " "
	+ " " + getYears() + " "
	+ "<input type=\"Button\" value=\" > \" onclick=\"GoBack('>')\" style=\"border: solid 1 black;font-family: Arial;font-size: 8pt;\">"
	+ "<tr>"
	+ "<td>"
	+ "<table width=\"100%\" border=\"1\" bgcolor=\"#e5e5e5\" bordercolor=\"#778899\" cellpadding=\"0\" cellspacing=\"0\" style=\"border:1px solid #dcdcdc;\">"
	+ "<thead bgcolor=\"#778899\" style=\"cursor:default; text-align:center; font:bold 7.5pt Tahoma, Verdana, sans-serif; color:white;\">"
	+ " " + getWeekDay() + " "
	+ "</thead>"
	+ "<tbody id=\"oTable\" style=\"text-decoration:none; font: 9pt Tahoma, Verdana; color:black;\">"
	+ "</tbody>"
	+ "</table>"
	+ "</table>";

function CreateDiv() {
	if (document.getElementById("calendar") == null) {
		divContainer = document.createElement("DIV");
		divContainer.id = "calendar";
		divContainer.innerHTML = divView;
		divContainer.style.visible = 'hidden';
		divContainer.style.zIndex = 10;
		document.body.appendChild(divContainer);
	}
}

function getMonths() {
	var Months = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"];
	str = "<select name='month' style='font-family: arial;font-size: 8pt;' onchange='SetCalendar()'>"
	for (i = 0; i < Months.length; i++) {
		str += "<option value='" + i + "'>" + Months[i];
	}
	str += "</select>";
	return str;
}

function getYears() {
	var selVal = "";
	var Years = new Array(1950, 2050);
	str = "<select name='year' style='font-family: arial;font-size: 8pt;' onchange='SetCalendar()'>"
	for (i = Years[0]; i <= Years[1]; i++) {
		(i == 2020) ? selVal = "selected" : selVal = "";
		str += "<option value='" + i + "' " + selVal + ">" + i;
	}
	str += "</select>";
	return str;
}

function getWeekDay() {
	var w = new Array("Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс")
	str = "<tr align='center'>";
	for (i = 0; i < w.length; i++) {
		str += "<td width='20px'>" + w[i];
	}
	return str;
}

dm = new Array(Array(), Array(), Array(), Array(), Array(), Array());
var obj = "", text;
var Dy, Dm, Dd;

function clearArray() {
	for (i = 0; i <= 5; i++) {
		for (l = 1; l <= 7; l++) {
			dm[i][l] = null;
		}
	}
}

function delTable() {
	for (i = oTable.rows.length - 1; i >= 0; i--) {
		oTable.deleteRow(i);
	}
}

function GetArrayDays(Year, Month) {// заполнение массива календаря
	var d = new Date(Year, Month - 1, 1);
	var WeekDay = d.getDay();
	var g = 0;
	clearArray();
	while (d.getMonth() == Month - 1) {
		WeekDay = d.getDay();
		if (WeekDay == 0) WeekDay = 7;
		dm[g][WeekDay] = d.getDate();
		if (WeekDay == 7) g++;
		d = new Date(Year, d.getMonth(), d.getDate() + 1);
	}
}

function Calendar(Year, Month, Day) {
	var dd = new Date()
	Today = null;
	name = "day";
	month.value = Month - 1;
	year.value = Year;
	if (Year == dd.getYear() && Month - 1 == dd.getMonth()) Today = dd.getDate();
	if (Dy == dd.getYear() && Dm == dd.getMonth()) Day = Dd;
	GetArrayDays(Year, Month)
	if (oTable.rows.length > 0) delTable();
	for (i = 0; i <= 5; i++) {
		c = 0;
		var oRow = oTable.insertRow(oTable.rows.length);
		for (l = 1; l <= 7; l++) {
			oCell = oRow.insertCell(c);
			oCell.align = "center";
			if (dm[i][l] != null) {
				if (l == 6 || l == 7) {
					name = "day";
					oCell.id = "weekEnd";
				} else {
					name = "day";
				}                // сб вс
				if (dm[i][l] == Day) {
					name = "actDay";
					oCell.id = "actDay";
				} else {
					name = "day";
				} // активный день
				if (dm[i][l] == Today) {
					name = "toDay";
					oCell.id = "toDay";
				} else {
					name = "day";
				} // сегодня
				oCell.innerHTML = "<div id=\"" + name + "\" onclick=\"returnDate('" + dm[i][l] + "','" + Month + "','" + Year + "','" + obj + "')\" href=\"#\" >" + dm[i][l] + "</div>";
			} else {
				oCell.innerHTML = "&nbsp;";
				if (l == 6 || l == 7) oCell.id = "weekEnd";
			}
			c++;
		}
	}
}

function SetCalendar() {
	y = year[0][year[0].selectedIndex].value;
	m = month[0].selectedIndex + 1;
	d = 0;
	Calendar(y, m, d);
}

function UnShowCalendar() {
	cln = document.getElementById("calendar");
	if (cln.style.visibility == "visible") {
		cln.style.visibility = "hidden";
	}
}

function ShowCalendar(t, a) {
	if (a != undefined) {
		var e = a.parentNode.getElementsByTagName('input');
		for (i = 0; i < e.length; i++) {
			if (e[i].name == t) {
				text = e[i];
				gInx = text.getIndex();
			}
		}
	} else {
		text = document.getElementById(t);
	}
	obj = t;
	iText = text.value;
	CreateDiv();
	cln = document.getElementById("calendar");

	ds = new Date();
	if (iText != "") {
		Dy = iText.substr(6, 4);
		Dm = iText.substr(3, 2);
		Dd = iText.substr(0, 2);
	} else {
		Dy = ds.getYear();
		Dm = ds.getMonth() + 1;
		Dd = ds.getDate();
	}
	if (cln.style.visibility != "visible") {
		Calendar(Dy, Dm, Dd);
		cln.style.left = event.clientX - 20;
		cln.style.top = event.clientY + 10;
		cln.style.visibility = "visible";
		setIframeForm('Y');
		SetCalendar();
	} else {
		cln.style.visibility = "hidden";
		setIframeForm('N');
	}
}

function ShowCalendar2(t, a) {
	var e = a.parentNode.getElementsByTagName('input');
	for (i = 0; i < e.length; i++) {
		if (e[i].name == t) {
			text = e[i];
			gInx = text.getIndex();
		}
	}
	//text=document.getElementById(t);
	obj = t;
	iText = text.value;
	CreateDiv();
	cln = document.getElementById("calendar");

	ds = new Date();
	if (iText != "") {
		Dy = iText.substr(6, 4);
		Dm = iText.substr(3, 2);
		Dd = iText.substr(0, 2);
	} else {
		Dy = ds.getYear();
		Dm = ds.getMonth() + 1;
		Dd = ds.getDate();
	}
	if (cln.style.visibility != "visible") {
		Calendar(Dy, Dm, Dd);
		cln.style.left = event.clientX - 20;
		cln.style.top = event.clientY + 10;
		cln.style.visibility = "visible";
		setIframeForm('Y');
	} else {
		cln.style.visibility = "hidden";
		setIframeForm('N');
	}
}

function returnDate(d, m, y) {
	m.length == 1 ? m = "0" + m : m = m;
	d.length == 1 ? d = "0" + d : d = d;
	text.value = d + "." + m + "." + y;
	cln = document.getElementById("calendar");
	cln.style.visibility = "hidden";
	setIframeForm("N");
}

function GoBack(w) {
	var month, year;
	month = document.getElementsByName("month")[0];
	year = document.getElementsByName("year")[0];
	m = month.selectedIndex;
	y = year.selectedIndex;
	if (w == "<") {
		if (m == 0) {
			m = 11;
			y = y - 1;
		} else {
			m -= 1;
		}
	}
	if (w == ">") {
		if (m == 11) {
			m = 0;
			y = y + 1;
		} else {
			m += 1
		}
	}
	month.value = month[m].value;
	year.value = year[y].value;
	SetCalendar();
}

// дополнено 11_03_2009 создание iframe  для нормального отображения календаря
function setIframeForm(act) {
	frName = "IFRAME_FOR_CALENDAR_";
	setIframe(frName, act);
}

function setIframe(frName, act) {
	Yes = false;
	if ((k = document.getElementById(frName)) != null) {
		Yes = true;
	}
	if (act == 'N') {
		k.style.display = 'none';
		return;
	}
	object = document.getElementById("calendar");
	//if (act=="N")return;
	if (Yes) {
		fr = k;
	} else {
		fr = document.createElement("iframe");
	}
	var x = object;
	var x_c = x.getBoundingClientRect();
	fr.style.width = x.clientWidth;
	fr.style.height = x.clientHeight;
	fr.style.left = x_c.left;
	fr.style.top = x_c.top;
	fr.style.zIndex = 2;
	fr.style.position = "absolute";
	fr.scrolling = "no";
	fr.frameBorder = 0;
	fr.style.display = '';
	if (Yes == false) {
		fr.id = frName;
		document.body.appendChild(fr);
		/* document.recalc(); */
	}
}