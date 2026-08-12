var month = document.getElementsByName("month");
var year = document.getElementsByName("year");
var gInx = 0;
var variable = "";

dm = new Array(Array(), Array(), Array(), Array(), Array(), Array());
var obj = "", text;
var Dy, Dm, Dd;

function crossCalendarDiv(dy, dm, dd) {
    if (isCross()) {
        return "<table>"
            + "<tr align=\"center\">"
            + "<td nowrap>"
            + "<input type='button' value='<' onclick=\"GoBack('<')\">"
            + " " + getMonths(dm) + " "
            + " " + getYears(dy) + " "
            + "<input type='button' value='>' onclick=\"GoBack('>')\">"
            + "<tr>"
            + "<td>"
            + "<table class='calendar-body' cellpadding='0' cellspacing='0'>"
            + "<thead>"
            + " " + getWeekDay(dd) + " "
            + "</thead>"
            + "<tbody id='oTable'>"
            + "</tbody>"
            + "</table>"
            + "</table>";
    } else {
        return "<table border=\"0\" bgcolor=\"#6699cc\" width=\"165\">"
            + "<tr align=\"center\">"
            + "<td nowrap>"
            + "<input type=\"Button\" value=\" < \" onclick=\"GoBack('<')\" style=\"border: solid 1 black;font-family: Arial;font-size: 8pt;\">"
            + " " + getMonths(dm) + " "
            + " " + getYears(dy) + " "
            + "<input type=\"Button\" value=\" > \" onclick=\"GoBack('>')\" style=\"border: solid 1 black;font-family: Arial;font-size: 8pt;\">"
            + "<tr>"
            + "<td>"
            + "<table width=\"100%\" border=\"1\" bgcolor=\"#e5e5e5\" bordercolor=\"#778899\" cellpadding=\"0\" cellspacing=\"0\" style=\"border:1px solid #dcdcdc;\">"
            + "<thead bgcolor=\"#778899\" style=\"cursor:default; text-align:center; font:bold 7.5pt Tahoma, Verdana, sans-serif; color:white;\">"
            + " " + getWeekDay(dd) + " "
            + "</thead><tbody id=\"oTable\" style=\"text-decoration:none; font: 9pt Tahoma, Verdana; color:black;\"></tbody></table></table>";
    }
}

function CreateDiv(dy, dm, dd) {
    divContainer = document.createElement("DIV");
    divContainer.id = "ibs-calendar";

    if (isCross()) {
        divContainer.className = "calendar-cross-browser"
        var theme = top._t().themeName;
        if (theme === "dark") divContainer.className = "calendar-dark-theme calendar-cross-browser"
        else if (theme === "light") divContainer.className = "calendar-light-theme calendar-cross-browser"
    } else divContainer.className = "calendar-ie-browser"

    divContainer.innerHTML = crossCalendarDiv(dy, dm, dd);
    divContainer.style.display = 'none';
    divContainer.style.zIndex = 10;

    return divContainer
}

function getMonths(dm) {
    var selVal = "";
    var Months = ["Январь", "Февраль", "Март", "Апрель", "Май", "Июнь", "Июль", "Август", "Сентябрь", "Октябрь", "Ноябрь", "Декабрь"];
    str = "<select name='month' onchange='SetCalendar()'>";
    for (var i = 0; i < Months.length; i++) {
        selVal = (i == dm - 1) ? "selected" : "";
        str += "<option value='" + i + "' " + selVal + ">" + Months[i];
    }
    str += "</select>";
    return str;
}

function getYears(dy) {
    var selVal = "";
    var Years = new Array(1950, 2050);
    str = "<select name='year' onchange='SetCalendar()'>";
    for (var i = Years[0]; i <= Years[1]; i++) {
        selVal = (i == dy) ? "selected" : "";
        str += "<option value='" + i + "' " + selVal + ">" + i;
    }
    str += "</select>";
    return str;
}

function getWeekDay(dd) {
    var w = new Array("Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс")
    str = "<tr align='center'>";
    for (var i = 0; i < w.length; i++) {
        str += "<td width='20px'>" + w[i];
    }
    return str;
}


function clearArray() {
    for (var i = 0; i <= 5; i++) {
        for (var l = 1; l <= 7; l++) {
            dm[i][l] = null;
        }
    }
}

function delTable() {
    for (var i = oTable.rows.length - 1; i >= 0; i--) {
        oTable.deleteRow(i);
    }
}

function GetArrayDays(Year, Month) {
    var d = new Date(Year, Month - 1, 1);
    var WeekDay = d.getDay();
    var g = 0;
    clearArray();
    while (d.getMonth() == Month - 1) {
        WeekDay = d.getDay();
        if (WeekDay == 0)
            WeekDay = 7;
        dm[g][WeekDay] = d.getDate();
        if (WeekDay == 7)
            g++;
        d = new Date(Year, d.getMonth(), d.getDate() + 1);
    }
}

function Calendar(Year, Month, Day) {
    if (isCross()) {
        var dd = new Date()
        Today = null;
        variable = "day";
        month.value = Month - 1;
        year.value = Year;
        if (Year == dd.getYear() && Month - 1 == dd.getMonth()) Today = dd.getDate();
        if (Dy == dd.getYear() && Dm == dd.getMonth()) Day = Dd;
        GetArrayDays(Year, Month);
        if (oTable.rows.length > 0)
            delTable();
        for (i = 0; i <= 5; i++) {
            c = 0;
            var oRow = oTable.insertRow(oTable.rows.length);
            for (l = 1; l <= 7; l++) {
                oCell = oRow.insertCell(c);
                oCell.align = "center";
                if (dm[i][l] != null) {
                    if (l == 6 || l == 7) {
                        variable = "day";
                        oCell.id = "weekEnd";
                    } else {
                        variable = "day";
                    }                // сб вс
                    if (dm[i][l] == Day) {
                        variable = "actDay";
                        oCell.id = "actDay";
                    } else {
                        variable = "day";
                    } // активный день
                    if (dm[i][l] == Today) {
                        variable = "toDay";
                        oCell.id = "toDay";
                    } else {
                        variable = "day";
                    } // сегодня
                    oCell.innerHTML = "<div id=\"" + variable + "\" onclick=\"returnDate('" + dm[i][l] + "','" + Month + "','" + Year + "','" + obj + "')\" href=\"#\" >" + dm[i][l] + "</div>";
                } else {
                    oCell.innerHTML = "&nbsp;";
                    if (l == 6 || l == 7) oCell.id = "weekEnd";
                }
                c++;
            }
        }
    } else {
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
                    oCell.innerHTML = "<a id=\"" + name + "\" onclick=\"returnDate('" + dm[i][l] + "','" + Month + "','" + Year + "','" + obj + "')\" href=\"#\" >" + dm[i][l] + "</a>";
                } else {
                    oCell.innerHTML = "&nbsp;";
                    if (l == 6 || l == 7) oCell.id = "weekEnd";
                }
                c++;
            }
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
    cln = getDOM("ibs-calendar");
    if (cln.style.display == "block") {
        cln.style.display = "none";
    }
}

function drawCalendar(t, a) {
    if (a != undefined) {
        var e = a.parentNode.getElementsByTagName('input');
        for (i = 0; i < e.length; i++) {
            if (e[i].name == t) {
                text = e[i];
                gInx = text.getIndex();
            }
        }
    } else {
        text = getDOM(t)
    }
    obj = t;
    iText = text.value;
    ds = new Date();
    if (iText != "") {
        Dy = parseInt(iText.substr(6, 4), 10);
        Dm = parseInt(iText.substr(3, 2), 10);
        Dd = parseInt(iText.substr(0, 2), 10);
    } else {
        Dy = ds.getFullYear();
        Dm = ds.getMonth() + 1;
        Dd = ds.getDate();
    }
    var cln = CreateDiv(Dy, Dm, Dd);

    cln.setAttribute("field-name", t)
    cln.style.left = event.clientX - 20;
    cln.style.top = event.clientY + 10;

    cln.style.display = "block";
    _.body.appendChild(cln);
    // cln.style.position = "absolute";
    // text.parentNode.appendChild(cln);
    // text.parentNode.className = "calendar-wrapper"
    Calendar(Dy, Dm, Dd);
}

function hideIbsCalendar() {
    var existingCalendar = getDOM("ibs-calendar");
}

function ShowCalendar(t, a) {
    var existingCalendar = getDOM("ibs-calendar");
    if (existingCalendar) {
        var oldFieldName = existingCalendar.getAttribute("field-name");
        _.body.removeChild(existingCalendar);
        if (oldFieldName && t && (oldFieldName !== t)) {
            drawCalendar(t, a);
        }
    } else {
        drawCalendar(t, a);
    }
}

function ShowCalendar2(t, a) {
    var existingCalendar = getDOM("ibs-calendar");
    if (existingCalendar) {
        var oldFieldName = existingCalendar.getAttribute("field-name");
        _.body.removeChild(existingCalendar);
        if (oldFieldName && t && (oldFieldName !== t)) {
            drawCalendar(t, a);
        }
    } else {
        drawCalendar(t, a);
    }
}

function returnDate(d, m, y) {
    m.length == 1 ? m = "0" + m : m = m;
    d.length == 1 ? d = "0" + d : d = d;
    text.value = d + "." + m + "." + y;
    // cln = getDOM("ibs-calendar");
    var existingCalendar = getDOM("ibs-calendar");
    if (existingCalendar) {
        _.body.removeChild(existingCalendar);
    }
    // cln.style.display = "none";
    // setIframeForm("N");
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
// function setIframeForm(act) {
//     frName = "IFRAME_FOR_CALENDAR_";
//     setIframe(frName, act);
// }

// function setIframe(frName, act) {
// Yes = false;
// if ((k = document.getElementById(frName)) != null) {
//     Yes = true;
// }
// if (act == 'N') {
//     k.style.display = 'none';
//     return;
// }
// object = document.getElementById("calendar");
// //if (act=="N")return;
// if (Yes) {
//     fr = k;
// } else {
//     fr = document.createElement("iframe");
// }
// var x = object;
// var x_c = x.getBoundingClientRect();
// fr.style.width = x.clientWidth;
// fr.style.height = x.clientHeight;
// fr.style.left = x_c.left;
// fr.style.top = x_c.top;
// fr.style.zIndex = 2;
// fr.style.position = "absolute";
// fr.scrolling = "no";
// fr.frameBorder = 0;
// fr.style.display = '';
// if (Yes == false) {
//     fr.id = frName;
//     document.body.appendChild(fr);
//     /* document.recalc(); */
// }
// }