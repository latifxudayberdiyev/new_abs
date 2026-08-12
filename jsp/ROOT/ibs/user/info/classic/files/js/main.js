function copyText(element) {
	var range,selection,worked;
	if (document.body.createTextRange) {
		range = document.body.createTextRange();
		range.moveToElementText(element);
		range.select();
	} else if (window.getSelection) {
		selection = window.getSelection();
		range = document.createRange();
		range.selectNodeContents(element);
		selection.removeAllRanges();
		selection.addRange(range);
	}
	try {
		document.execCommand('copy');
		/* alert('text copied'); */
	} catch (err) {
		/* alert('unable to copy text'); */
	}
}

/*---------Custom Select-------*/
var x, i, j, l, ll, selElmnt, a, b, c;
x = document.getElementsByClassName("custom-select");
l = x.length;
for (i = 0; i < l; i++) {
	selElmnt = x[i].getElementsByTagName("select")[0];
	ll = selElmnt.length;
	a = document.createElement("DIV");
	a.setAttribute("class", "select-selected");
	/* a.innerHTML = selElmnt.options[selElmnt.selectedIndex].innerHTML; */
	x[i].appendChild(a);
	b = document.createElement("DIV");
	b.setAttribute("class", "select-items select-hide");
	for (j = 1; j < ll; j++) {
		c = document.createElement("DIV");
		c.innerHTML = selElmnt.options[j].innerHTML;
		if (i == 0 && j == 1) {
			c.className = "same-as-selected";
		}
		c.addEventListener("click", function (e) {
			var y,i,k,s,h,sl,yl;
			s = this.parentNode.parentNode.getElementsByTagName("select")[0];
			sl = s.length;
			h = this.parentNode.previousSibling;
			for (i = 0; i < sl; i++) {
				if (s.options[i].innerHTML == this.innerHTML) {
					s.selectedIndex = i;
					/* h.innerHTML = this.innerHTML; */
					y = this.parentNode.getElementsByClassName("same-as-selected");
					yl = y.length;
					for (k = 0; k < yl; k++) {
						y[k].removeAttribute("class");
					}
					this.setAttribute("class", "same-as-selected");
					break;
				}
			}
			h.click();
		});
		b.appendChild(c);
	}
	x[i].appendChild(b);
	a.addEventListener("click", function (e) {
		e.stopPropagation();
		closeAllSelect(this);
		this.nextSibling.classList.toggle("select-hide");
		this.classList.toggle("select-arrow-active");
	});
}
function closeAllSelect(elmnt) {
	var x,y,i,xl,yl,arrNo = [];
	x = document.getElementsByClassName("select-items");
	y = document.getElementsByClassName("select-selected");
	xl = x.length;
	yl = y.length;
	for (i = 0; i < yl; i++) {
		if (elmnt == y[i]) {
			arrNo.push(i)
		} else {
			y[i].classList.remove("select-arrow-active");
		}
	}
	for (i = 0; i < xl; i++) {
		if (arrNo.indexOf(i)) {
			x[i].classList.add("select-hide");
		}
	}
}
document.addEventListener("click", closeAllSelect);
/*-----------------------------*/
function drawClWidget(d, s) {
	var data = d.data;
	clientData=d.data;
	let html = "";
	let hasData=false;
	for (let i = 0; i < data.length; i++) {
		html += `<div class="client">
				<a onclick="goClient(`+i+`)">
					<div class="client-thumb">
						<div class="client-thumb-img">
							<img src="img/` + getSImg(data[i]) + `" />
						</div>
						<div class="client-name">
                            <div title='` + data[i].name + `'>` + data[i].name + `</div>
						</div>
					</div>
					<div class="schyot">
						<span class="` + getSClass(data[i].subject) + `">` + data[i].subject_text + `</span>
					</div>
					<div class="data-item">
						<div class="data-item-title">`+si_inn+`:</div>
						<div class="data-item-value">` + data[i].inn + `</div>
					</div>
					<div class="data-item">
						<div class="data-item-title">`+si_code+`:</div>
						<div class="data-item-value">` + data[i].code + `</div>
					</div>
					<div class="data-item">
						<div class="data-item-title">`+si_addres+`:</div>
						<div class="data-item-value">` + data[i].address + `</div>
					</div>
					<div class="data-item">
						<div class="data-item-title">`+getClientDataByS(data[i]).text+`:</div>
						<div class="data-item-value">` + getClientDataByS(data[i]).value + `</div>
					</div>					
				</a>
			</div>`;
			hasData=true;
	}
	if(!hasData){
		return `<p class="no_data_found">`+si_no_data_found+`</p>`;
	}else{
		return `<div class="clients">`+html+`</div>`;
	}
}
var clientData=[];
function drawClList(d, s) {
	let data = d.data;
	clientData=d.data;
	let hasData = false;
	let html = `<table class="clients-list-table">
			  <thead>
				<tr>
				  <th scope="col">¹</th>
				  <th scope="col">` + si_photo + `</th>
				  <th scope="col">` + si_name + `</th>
				  <th scope="col">` + si_type + `</th>
				  <th scope="col">` + si_inn + `</th>
				  <th scope="col">` + si_code + `</th>
				  <th scope="col">` + si_date_open + `</th>
				  <th scope="col">` + si_date_end + `</th>
				</tr>
			  </thead>
			  <tbody>`;
	for (let i = 0; i < data.length; i++) {
		html += `<tr onclick="goClient(` + i + `);" onmouseover="">
				  <th scope="row">` + (i + 1) + `</th>
				  <td><img src="img/` + getSImg(data[i]) + `"></td>
				  <td style="text-align:left">` + data[i].name + `</td>
				  <td><span class="` + getSClass(data[i].subject) + `">` + data[i].subject_text + `</span></td>
				  <td>` + data[i].inn + `</td>
				  <td>` + data[i].code + `</td>
				  <td>` + data[i].date_open + `</td>
				  <td>` + data[i].date_end + `</td>
				</tr>`;
		hasData = true;
	}
	if (hasData) {
		html += `</tbody></table>`;
	} else {
		html += `<tr><td colspan="8" class="no_data_found">` + si_no_data_found + `</td></tr></tbody></table>`;
	}
	return `<div class="clients-list-content">` + html + `</div>`;
}
function getSClass(s) {
	return s == "J" ? "yur-liso" : "fiz-liso";
}
function getClientDataByS(d){
	if(d.subject=="J"){
		return {text:si_date_open,value:d.date_open};
	}else{
		return {text:si_passport,value:d.client_data.passport};
	}
}
function getSImg(s) {
	if (s.subject == "J") {
		return "yuridik.png";
	} else {
		if (s.client_data.gender == 1) {
			return "male.png";
		} else if (s.client_data.gender == 2) {
			return "female.png";
		} else {
			return "user.jpg";
		}
	}
}
function selectSubject(o, subject) {
	o.children[0].checked = true;
	let pageNum=getActivePageNum();
	getClients(pageNum);
	window.event.preventDefault();
}
function selectGridType(o, t) {
	o.children[0].checked = true;
	let subjectType = getSubjectType();
	drawClients(subjectType);
	window.event.preventDefault();
}
function getSubjectType() {
	let subjects = document.getElementsByName("subject");
	return Array.from(subjects).filter((d) => d.checked)[0].value;
}
function getGridType() {
	let grid_types = document.getElementsByName("grid_type");
	return Array.from(grid_types).filter((d) => d.checked)[0].value;
}
function drawClients(s) {
	let html = "",clName = "clients-list";
	if (getGridType() == "WIDGET") {
		html = drawClWidget(clData, s);
		clName = "client-content";
	} else {
		html = drawClList(clData, s);
		clName = "clients-list";
	}
	getDOM("clients").className = clName;
	getDOM("clients").innerHTML = html;
	getDOM('pagination').innerHTML = drawPagination(Math.ceil(clData.length / showClient), clData.page_num);
	loading(false);
}
function isEmpty(obj) {
	for (var prop in obj) {
		if (obj.hasOwnProperty(prop))
			return false;
	}
	return true;
}
function createPagination(pageSize, pageNum) {
	getClients(pageNum,getFilterData());
}
let showClient = 12;
let clData={};
function getClients(pageNum, filter) {
	loading(true);
	let param = {
		request: 'get_clients',
		page_num: (is.def(pageNum) ? pageNum : 1),
		page_size: showClient,
		subject: getSubjectType()
	};
	let newParam = {};
	if (is.def(filter) && !isEmpty(filter)) {
		newParam = {...param,...filter};
	} else {
		newParam = param;
	}
	AJAX.load({
		POST: newParam,
		async: true,
		onSuccess: function (d) {
			clData=eval('(' + d + ')');
			console.log(clData);
			drawClients(newParam.subject);
		},
		onError: function (d) {
			alert(d);
		}
	});
}
function drawPagination(pages, page) {
	let str = '<ul>';
	let active;
	let pageCutLow = page - 1;
	let pageCutHigh = page + 1;
	if (page > 1) {
		str += '<li class="page-item previous no"><a class="page-link" onclick="createPagination('+pages+',' + (page - 1) + ')">'+si_prev+'</a></li>';
	}
	if (pages < 6) {
		for (let p = 1; p <= pages; p++) {
			active = page == p ? "active-page" : "no";
				str += '<li class="' + active + '"><a class="page-link" onclick="createPagination('+pages+',' + p + ')">' + p + '</a></li>';
		}
	} else {
		if (page > 2) {
			str += '<li class="no page-item"><a class="page-link" onclick="createPagination('+pages+', 1)">1</a></li>';
			if (page > 3) {
				str += '<li class="out-of-range"><a class="page-link" onclick="createPagination('+pages+',' + (page - 2) + ')">...</a></li>';
			}
		}
		if (page === 1) {
			pageCutHigh += 2;
		} else if (page === 2) {
			pageCutHigh += 1;
		}
		if (page === pages) {
			pageCutLow -= 2;
		} else if (page === pages - 1) {
			pageCutLow -= 1;
		}
		for (let p = pageCutLow; p <= pageCutHigh; p++) {
			if (p === 0) {
				p += 1;
			}
			if (p > pages) {
				continue
			}
			active = page == p ? "active-page" : "no";
			str += '<li class="page-item ' + active + '"><a class="page-link" onclick="createPagination('+pages+',' + p + ')">' + p + '</a></li>';
		}
		if (page < pages - 1) {
			if (page < pages - 2) {
				str += '<li class="out-of-range"><a class="page-link" onclick="createPagination('+pages+',' + (page + 2) + ')">...</a></li>';
			}
			str += '<li class="page-item no"><a class="page-link" onclick="createPagination('+pages+','+pages+')">' + pages + '</a></li>';
		}
	}
	if (page < pages) {
		str += '<li class="page-item next no"><a class="page-link" onclick="createPagination('+pages+',' + (page + 1) + ')">'+si_next+'</a></li>';
	}
	str += '</ul>';
	return str;
}
function getActivePageNum() {
	try {
		let activePage = document.querySelector(".client-pagination .active-page");
		return is.undef(activePage) ? 1 : activePage.children[0].innerText;
	} catch (e) {
		return 1;
	}
}
var fields = [getDOM("client_name"), getDOM("code"), getDOM("inn"), getDOM("filial")];
function filtered(o) {
	let datas = fields.filter((d) => d.value.length > 0);
	// if (o.value.length > 0 || datas.length > 0) {
		// getDOM("search_btn").disabled = false;
	// } else {
		// getDOM("search_btn").disabled = true;
	// }
}
function getFilterData() {
	let datas = fields.filter((d) => d.value.length > 0);
	let searchParam = {};
	for (let i = 0; i < datas.length; i++) {
		searchParam[datas[i].name] = datas[i].value;
	}
	return searchParam;
}
function search() {
	let pageNum = getActivePageNum();
	getClients(pageNum, getFilterData());
	window.event.preventDefault();
}
function goClient(i){
	$('#clients').fadeTo(0, 0.2);
	localStorage.setItem('client_name', clientData[i].name);
	// go({url:'client.jsp?code='+clientData[i].code+'&subject='+clientData[i].subject,lock:false});
	go({url:'client.jsp?code='+encodeURIComponent(clientData[i].codeEncry)+'&subject='+clientData[i].subject,lock:false});
}
function loading(s) {
	if (s) {
		$('#waitImage').css('display', 'block');
		$('#clients').fadeTo(0, 0.2);
	} else {
		$('#waitImage').css('display', 'none');
		$('#clients').fadeTo(0, 1);
	}
}
function onLoad() {
	initDOM(getDOM("filter_content"));
	getClients();

}