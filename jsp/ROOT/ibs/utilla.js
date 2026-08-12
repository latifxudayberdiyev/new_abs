////////	Перемещение по страницам селекта   ////////
function Go(direct) {
	if (direct == "first") GoToLine(1, linesPerPage);
	else if (direct == "prev") GoToLine((pageNumber - 1), linesPerPage);
	else if (direct == "next") GoToLine((pageNumber + 1), linesPerPage);
	else if (direct == "last") {
		w = Math.floor(totalLines / linesPerPage);
		if (Math.floor(totalLines / linesPerPage) != (totalLines / linesPerPage)) w++;
		GoToLine(w, linesPerPage);
	}
}

function Lines() {
	var k = window.prompt("Введите количество отображаемых записей на странице:", linesPerPage);
	var format = /^\d{1,5}$/;
	if (k == null) return;
	else if (format.test(k) && k != 0) {
		linesPerPage = k;
		GoToLine(1, k);
	} else alert("Введите числовое значение (1..99999)");
}

////////////	Бегающая строчка !!!! (по стрелкам клавы и по клику мышки)   ////////////////
var oldRow = null;

function selectRow() {
	// обработчик мышки
	if ((event.srcElement.parentElement).tagName != "TR") return;
	if (oldRow == null)
		oldRow = event.srcElement.parentElement;
	moveRow(event.srcElement.parentElement.rowIndex);
	if (event.type == "dblclick")
		editRow(oldRow.rowIndex);
}

function moveCursor() {
	if (oTable.rows.length == 0) return;
	if (oldRow == null) {
		oldRow = oTable.rows[0];
		moveRow(0);
	} else if (event.keyCode == 40 && oldRow.rowIndex < oTable.rows.length - 1) moveRow(oldRow.rowIndex + 1);	// down
	else if (event.keyCode == 38 && oldRow.rowIndex > 0) moveRow(oldRow.rowIndex - 1);	// up
	else if (event.keyCode == 13) editRow(oldRow.rowIndex);	// Enter
}

function moveRow(rowIndex) {
	oldRow.bgColor = "";
	oldRow = oTable.rows[rowIndex];
	oldRow.bgColor = highlight;
	if (event != null && event.type != "click") oldRow.scrollIntoView(false);
	onRowSelect(oldRow.rowIndex);
}

function onRowSelect(rowIndex) {
	for (i = 0; i < jForm.elements.length; i++) {
		var pIndex = -1;
		if (jForm.elements[i].id != "") {
			pIndex = jForm.elements[i].id.substring(1) * 1 + 1;
			if (oHead.rows[0].cells[pIndex].id == "sum") jForm.elements[i].value = oldRow.cells[pIndex].innerText.replace(/ ?,?/g, '');
			else jForm.elements[i].value = oldRow.cells[pIndex].innerText;
			if (jForm.elements[i].tagName == 'SELECT') checkSV(jForm.elements[i]);
		}
	}
	onRowSelectPlus();
}

function onKeyDown() {
	if (event.keyCode != 9 && event.srcElement.tagName != 'INPUT' && event.srcElement.tagName != 'SELECT') {
		moveCursor();
		return (false);
	}
	return (true);
}

/////////////   Загрузочный и прочий функционал   ///////////////
function refreshSize() {
	if (oTable.rows.length != 0) {
		for (i = 0; i < oHead.rows[0].cells.length; i++)
			if (oHead.rows[0].cells[i].style.display != "none" && oHead.rows[0].cells[i].clientWidth > oTable.rows[0].cells[i].clientWidth) {
				oTable.rows[0].cells[i].noWrap = true;
				oTable.rows[0].cells[i].width = oHead.rows[0].cells[i].clientWidth + 2;
//				alert("i=" + i + " " + oHead.rows[0].cells[i].clientWidth+" "+ oTable.rows[0].cells[i].clientWidth );
			}
		for (i = 0; i < oHead.rows[0].cells.length; i++) {
			if (oHead.rows[0].cells[i].style.display != "none") oHead.rows[0].cells[i].width = oTable.rows[0].cells[i].clientWidth + 2;
//			alert("i=" + i + " " + oHead.rows[0].cells[i].clientWidth+" "+ oTable.rows[0].cells[i].clientWidth );
		}
	}
}

function scrollHead() {
	oDiv1.scrollLeft = oDiv2.scrollLeft;
}

var oldCell = null;

function sorting() {
	var obj = event.srcElement;
	if (obj.tagName != "TH" || oTable.rows.length < 2) return;
	var cIndex = obj.cellIndex, currentRow, cTEXT, direct, add1;
	if (obj.id == "num") add = "*1";
	else if (obj.id == "sum") add = ".replace(/ /g, '')*1";
	else add = "";
	if (oldCell != obj && oldCell != null && oldCell.innerText.substring(oldCell.innerText.length - 1) == "*") oldCell.innerText = oldCell.innerText.substring(0, oldCell.innerText.length - 1);
	oldCell = obj;
	if (obj.innerText.substring(obj.innerText.length - 1) != "*") {
		direct = "<";
		obj.innerText = obj.innerText + "*";
	} else {
		direct = ">";
		obj.innerText = obj.innerText.substring(0, obj.innerText.length - 1);
	}
	for (nn = 0; nn < oTable.rows.length; nn++) {
		currentRow = oTable.rows[nn];
		for (i = nn; i < oTable.rows.length; i++) {
			eval("if (oTable.rows[i].cells[cIndex].innerText " + add + direct + " currentRow.cells[cIndex].innerText" + add + ")	currentRow = oTable.rows[i]");
		}
		if (currentRow.rowIndex != nn) {
			cTEXT = oTable.rows[nn].swapNode(currentRow);
		}
		/*					  for (i=0;i<currentRow.cells.length;i++){
										cTEXT = oTable.rows[nn].cells[i].innerText;
										oTable.rows[nn].cells[i].innerText =  currentRow.cells[i].innerText;
										currentRow.cells[i].innerText = cTEXT;
								}
		*/
	}
	moveRow(0);
}

/////////////       Различные чекеры !!!!   /////////////
function checkConfirm(msgDetail) {
	return confirm("Вы действительно хотите " + msgDetail + " ?");
}

function checkSV(obj) {
	if (obj.selectedIndex == -1) obj.value = "NA"
	if (obj.selectedIndex == -1) obj.value = "NF"
}

function checkForm() {
	with (jForm) {
		for (i = 0; i < elements.length; i++) {
			if ((elements[i].title != "") && (elements[i].value == "")) {
				alert("Заполните поле \"" + elements[i].title.toUpperCase() + "\"");
				elements[i].focus();
				return;
			}
			if (elements[i].tagName == "SELECT" && (elements[i].value == "NF" || elements[i].value == "NA")) {
				alert("Значение списка не задано !!!");
				elements[i].focus();
				return;
			}
		}
		submit();
		disabledAll(true);
	}
}

function checkSum() {
	var obj = event.srcElement;
	if (event.type == 'keypress') {
		if (event.keyCode == 44) {
			event.keyCode = 46;
			obj.focus();
			return;
		}
	} else {
		var format = /^\d{1,18}(\.\d{1,2})?$/;
		var msg = "Поле суммы должно содержать только цифровые значения формата ssss.tt!";
		return (checkFormat(format, msg));
	}
}

function checkPerc() {
	var format = /^\d{1,4}(\.\d{1,2})?$/;
	return (checkFormat(format, "Неверный формат поля " + event.srcElement.title.toUpperCase() + " !"));
}

function checkNumber() {
	var format = /^\d*$/;
	var msg = "Поле " + event.srcElement.title.toUpperCase() + " должно содержать только цифры!";
	return (checkFormat(format, msg));
}

function checkFormat(format, msg) {
	var obj = event.srcElement;
	if ((obj.value != "") && !format.test(obj.value)) {
		alert(msg);
		obj.value = obj.defaultValue;
		obj.focus();
		obj.select();
		return (false);
	}
	return (true);
}

////////////////////////////   Набор скриптов для формочек ввода     /////////////////////
function changeColor() {		//Подсветка полей ввода
	if (event.type == "focus") event.srcElement.style.backgroundColor = '#e2efff';
	else event.srcElement.style.backgroundColor = '';
}
