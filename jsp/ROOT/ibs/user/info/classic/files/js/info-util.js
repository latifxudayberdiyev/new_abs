
var svgViloyatlar = document.querySelectorAll("#viloyatlar > *");
var viloyatNomlari = document.querySelectorAll(".viloyat li");
var activeViloyat = document.querySelector(".viloyat li.active");
/*bazadan ma'lumot olib keluvchi funksiyalar*/
var curr_data={}, work_data={}, info_data={}
function getCurrency(param) {
	loadingPanel("cb_currency", true);
	if (is.undef(param.request)) {
		param.request = 'get_currency';
	}
	AJAX.load({
		POST: param,
		async: true,
		onSuccess: function (d) {
			curr_data = eval('(' + d + ')');
			drawCurrency(curr_data);
			//initCurItem();
		},
		onError: function (e) {
			alert(e);
		}
	});
}
function getWorkingTime(param) {
	loadingPanel("time-list", true);
	if (is.undef(param.request)) {
		param.request = 'get_working_time';
	}
	AJAX.load({
		POST: param,
		async: true,
		onSuccess: function (d) {
			work_data=eval('(' + d + ')');
			drawWorkingTime(work_data);
		},
		onError: function (e) {
			alert(e);
		}
	});
}
function getBank(region_code) {
	loadingPanel("svginfo", true);
	AJAX.load({
		POST: {
			request: 'get_bank',
			region_code: region_code
		},
		async: true,
		onSuccess: function (d) {
			svgInfo(eval('(' + d + ')'));
		},
		onError: function (e) {
			alert(e);
		}
	});
}
function getInfoData() {
	AJAX.load({
		POST: {
			request: 'get_info_data'
		},
		async: true,
		onSuccess: function (d) {
			info_data = eval('(' + d + ')');
			drawWidgetDatas(info_data);
		},
		onError: function (e) {
			alert(e);
		}
	});
}
function getChartInfo() {
	AJAX.load({
		POST: {
			request: 'get_chart_data'
		},
		async: true
	});
}
function getCalendar() {
	AJAX.load({
		POST: {
			request: 'get_calendar'
		},
		onSuccess: function (d) {
			showCalendar(d);
		},
		onError: function (e) {
			alert(e);
		}
	});
}
setInterval(drawDataByInterval,30000);
function drawDataByInterval() {
	// getCurrency({});
	// getWorkingTime({});
	// getInfoData();
	drawCurrency(curr_data);
	drawWorkingTime(work_data);
	drawWidgetDatas(info_data);
}
function drawChartData(d) {
	chart_data = d;
	drawChartDest();
	selectedChartDest(4);
	drawChart(4,'USD');
}
/*--------------------------------------------------------*/
function removeAllOn() {
	function removeON(el) {
		el.classList.remove("on");
	}
	viloyatNomlari.forEach(removeON);
	svgViloyatlar.forEach(removeON);
	activeViloyat.classList.add("active");
}

function addOnFromState(el) {
  let viloyatID = el.getAttribute("id");
  let curViloyat = document.querySelector("[data-state='" + viloyatID + "']");
  el.classList.add("on");
  curViloyat.classList.add("on");
  activeViloyat = document.querySelector(".viloyat li.active");
  activeViloyat.classList.remove("active");
}

svgViloyatlar.forEach(function(el) {
  el.addEventListener("mouseenter", function() {
    addOnFromState(el);
  });
  el.addEventListener("mouseleave", function() {
     removeAllOn();
  });
  
  el.addEventListener("touchstart", function() {
    removeAllOn();
    addOnFromState(el);
  });
});

function removeAllActive() {
  svgViloyatlar.forEach(function(el) {
    el.classList.remove("active");
  });
}

function setViloyat(el) {
	removeAllActive();
	el.classList.add("active");
	let viloyatID = el.getAttribute("id");
	let region_code = viloyatID.substr(-2);
	let curViloyat = document.querySelector("[data-state='" + viloyatID + "']");
	activeViloyat.classList.remove("active");
	activeViloyat = curViloyat;
	activeViloyat.classList.add("active");
	getBank(region_code);
}
function svgInfo(d) {
	let curViloyat, data;
	curViloyat = activeViloyat.getAttribute('data-state');
	data = d[curViloyat];
	drawBranch(data);
}
function phoneMask(e) {
	if (e.length < 12) {
		e = "998" + e;
	}
	var x = e.replace(/\D/g, '').match(/(\d{3})(\d{2})(\d{3})(\d{2})(\d{2})/);
	return '(' + x[1] + ') ' + x[2] + '-' + x[3] + '-' + x[4] + '-' + x[5];
}

/*---------------------------------------------------------------------------*/
function workTime(d) {
	let code = "";
	let time;
	let sum_time = 0,len=0;;
	for (var i = 0; i < d.length; i++) {
		if (i >= 4) {
			sum_time += parseInt(d[i].time);
			len += 1;
		} else {
			time = timeConvert(parseInt(d[i].time));
			code += `<div class="ipbc-item">
					<div class="ipbc-icon">
						<i></i>
					</div>
					<div class="ipbc-text" >
                                                <div class="ipbc-simvol" title="` + d[i].name + `">` + d[i].name + `</div>
						<div class="ipbc-value">` + time + `</div>
					</div>
		</div>`;
		}
	}
	if (len > 0) {
		code += `<div class="ipbc-item">
					<div class="ipbc-icon">
						<i></i>
					</div>
					<div class="ipbc-text" >
						<div class="ipbc-simvol" title="Другие `+ len +`">Другие ` + len + `</div>
						<div class="ipbc-value">` + timeConvert(sum_time) + `</div>
					</div>
				</div>`; 
	}
	/* document.getElementById("timechart").insertAdjacentHTML("beforebegin", code); */
	document.getElementById("time-list").innerHTML = code;
	
	var other = d.splice(4,d.length - 4,{name:"Другие",time:sum_time});
}
function drawWorkingTime(d){
	loadingPanel("time-list",false);
	workTime(d.data);
	timechart(d.data);
	getDOM("working_day").value = d.oper_day;
}
function timeConvert(n) {
	var hours = (n / 60 );
	var rhours = Math.floor(hours);
	var minutes = (hours - rhours) * 60;
	var rminutes = Math.round(minutes);
	if ((rminutes < 10) && (rminutes > 0)) {
		rminutes = "0" + rminutes;
	}
	return rhours + "ч." + rminutes + "м";
}

function timechart(d) {
	let times = [],	sum = 0;
	for (var i = 0; i < d.length; i++) {
		sum += parseInt(d[i].time);
		times.push(parseInt(d[i].time));
	}
	timechartDraw(d,times, sum);
}

function timechartDraw(d,times, sum) {
	let w,code = "";
	for (var i = 0; i < times.length; i++) {
		w = (times[i] * 100) / sum;
		code += `<div title="` + d[i].name + `" style="width:` + w + `%"></div>`;
	}
	document.querySelector("#timechart .time-graphic").innerHTML = code;
}
function makeTime() {
	function widgetTime() {
		var today = new Date();
		var time = ((parseInt(today.getHours()) < 10) ? "0" + today.getHours() : today.getHours()) + ":" + ((parseInt(today.getMinutes()) < 10) ? "0" + today.getMinutes() : today.getMinutes());
		getDOM("time").innerHTML = time
	}
	widgetTime();
	setInterval(widgetTime, 30000);
}
function prevOperDay(type){
	var which = 'PREV';
	var cur_day;
	if(type == 'currency'){
		cur_day = getDOM("curr_oper_day").value;
		getCurrency({request: 'get_currency',oper_day:cur_day,which:which});
	}else if (type == 'working_time') {
		cur_day = getDOM("working_day").value;
		getWorkingTime({request: 'get_working_time',oper_day: cur_day,which: which});
	}
}
function nextOperDay(type) {
	var which = 'NEXT';
	var cur_day;
	if (type == 'currency') {
		cur_day = getDOM("curr_oper_day").value;
		getCurrency({request: 'get_currency',oper_day: cur_day,which: which});
	} else if (type == 'working_time') {
		cur_day = getDOM("working_day").value;
		getWorkingTime({request: 'get_working_time',oper_day: cur_day,which: which});
	}
}
function loadingPanel(objText,s){
	if(s){
		getDOM(objText).classList.add("for_loader");
		getDOM(objText).innerHTML="<img src='files/icons/loading.gif' style='margin:auto'>";
	}else{
		getDOM(objText).classList.remove("for_loader");
	}
}
function getCurrInfoByCurrency(cur) {
	let curr_infos = [],cross_infos = [];
	let d = curr_data;
	for (let i = 1; i < d.data.length; i++) {
		if (d.data[i].children_curr.length > 0) {
			let json = {};
			var ch_curr = d.data[i].children_curr.filter((data) => data.curr_char_code == cur);
			for (let j = 0; j < ch_curr.length; j++) {
				json.name = d.data[i].name;
				json.code = d.data[i].code;
				json.curr_name = ch_curr[j].curr_name;
				json.buying_rate = ch_curr[j].buying_rate;
				json.color_buying_rate = ch_curr[j].color_buying_rate;
				json.diff_buying_rate = ch_curr[j].diff_buying_rate;
				json.selling_rate = ch_curr[j].selling_rate;
				json.color_selling_rate = ch_curr[j].color_selling_rate;
				json.diff_selling_rate = ch_curr[j].diff_selling_rate;
			}
			if (ch_curr.length > 0)
				curr_infos.push(json);
		}
	}
	return curr_infos
}
function getCrossInfoByDest(dest, cur) {
	let c = curr_data.data;
	let ch_c = c.filter((d) => d.code == dest)[0].children_cross;
	let cross_infos = [];
	for (let i = 0; i < ch_c.length; i++) {
		let t = ch_c[i].data.filter((d) => d.char_code == cur);
		if(t.length>0)
			cross_infos.push({end_sum: ch_c[i].end_sum,data: t});
	}
	return cross_infos;
}

function selectCurrItem(o) {
	let dest = o.getAttribute("destination");
	let curr = $("#currency-select").children("option:selected").val();
	let cross_infos = getCrossInfoByDest(dest, curr);
	let html = "";
	for (let i = 0; i < cross_infos.length; i++) {
		html += `<label class="button-group__btn">
					<input type="radio" name="group" onclick="checkedCross(this,` + i + `,` + dest + `,'` + curr + `')" value="` + i + `"/>
					<span class="button-group__label">
						До ` + cross_infos[i].end_sum + `.
					</span>
				</label>`;
	}
	getDOM("end_sum_btn").innerHTML = html;
	if (cross_infos.length > 0) {
		document.querySelectorAll(".button-group__btn")[0].children[0].click();
	} else {
		getDOM("cross_curs").innerHTML = "";
	}
	hoverCrossItem(o);
}
function hoverCrossItem(o, h) {
	// try {
	if (is.undef(goParent(o, 2)))
		return;
	let divs = goParent(o, 2).children;
	for (let i = 0; i < divs.length; i++) {
		divs[i].children[0].style.color = "";
	}
	if (is.undef(h))
		o.style.color = "#016EDA";
	// } catch (e) {}
}
function checkedCross(o, index, dest, curr) {
	drawCrossCurs(o, index, dest, curr);
}
function checkedChartDest(dest) {
	let cur = $("#currency-select2").children("option:selected").val();
	selectedChartDest(dest);
	drawChart(dest, cur);
}
function selectedChartDest(dest){
	getDOM("dest_"+dest).checked = true;
}
function getChartDest(){
	return $(".radio .hidden:checked").val();
}
function drawWidgetDatas(data) {
	if (is.def(data)) {
		d = data;
	}
	for (let s in d) {
		getDOM(s).innerHTML = d[s];
	}
}
function drawCrossCurs(o, index, dest, curr) {
	let cross_infos = getCrossInfoByDest(dest, curr);
	let html = `<div class="cdc-item">
					<div></div>
					<div><h4>`+si_selling_rate+`</h4></div>
					<div><h4>`+si_buying_rate+`</h4></div>
			   </div>`;
	for (let i = 0; i < cross_infos[index].data.length; i++) {
		let c = cross_infos[index].data[i];
		html += `<div class="cdc-item">
					<div>` + c.name + ` <i class="fas fa-long-arrow-alt-right"></i> ` + c.quote_curr + `</div>
						<div>
							<div class="left">
								<span onClick="copyText(this)" style="cursor:copy">` + c.buying_rate + `</span>
							</div>
						</div>
						<div>
							<div class="left">
							<span onClick="copyText(this)" style="cursor:copy">` + c.selling_rate + `</span>
						</div>
					</div>
				</div>`;
	}
	if (cross_infos.length > 0)
		getDOM("cross_curs").innerHTML = html;
}
function drawCurrInfo(cur) {
	function getChrtImg(t, r) {
		if (parseInt(r) == 0)
			return 'chart_zero';
		return (t == 'red') ? 'chart_down' : 'chart_up';
	}
	function getChrClass(t, r) {
		if (parseInt(r) == 0)
			return 'zero';
		return (t == 'red') ? 'down' : 'up';
	}
	function getChrDiff(t, r) {
		if (parseInt(r) == 0)
			return r;
		return (t == 'red') ? ' - ' + r : ' + ' + r;
	}
	var html = `<div class="cdc-item">
					<div></div>
					<div><h4>Покупка</h4></div>
					<div><h4>Продажа</h4></div>
				</div>`;
	var cross = html;
	let d_b_r,d_s_r,c_b_r,c_s_r,has_curr = false;
	/**/
	let cur_infos = getCurrInfoByCurrency(cur);
	let cross_infos = [];
	for (let i = 0; i < cur_infos.length; i++) {
		has_curr=true;
		d_b_r = cur_infos[i].diff_buying_rate;
		d_s_r = cur_infos[i].diff_selling_rate;
		c_b_r = cur_infos[i].color_buying_rate;
		c_s_r = cur_infos[i].color_selling_rate;
		cross_infos = getCrossInfoByDest(cur_infos[i].code, cur);
		html += `<div class="cdc-item" has-cross="` + cross_infos.length + `">
					<div destination="` + cur_infos[i].code + `" style="cursor:pointer" onclick="selectCurrItem(this)">` + cur_infos[i].name + `</div>
					<div>
						<div class="left">
							<span onClick="copyText(this)" style="cursor:copy">` + cur_infos[i].buying_rate + `</span>
							<i class="fas fa-calculator" onClick="currencyCalc(this)">
							</i>
						</div>
						<div class="right">
							<span class="` + getChrClass(c_b_r, d_b_r) + `">` + getChrDiff(c_b_r, d_b_r) + `</span>
							<img src="files/icons/again/` + getChrtImg(c_b_r, d_b_r) + `.svg" />
						</div>
					</div>
					<div>
						<div class="left">
							<span onClick="copyText(this)" style="cursor:copy">` + cur_infos[i].selling_rate + `</span>
							<i class="fas fa-calculator" onClick="currencyCalc(this)"></i>
						</div>
						<div class="right">
							<span class="` + getChrClass(c_s_r, d_s_r) + `">` + getChrDiff(c_s_r, d_s_r) + `</span>
							<img src="files/icons/again/` + getChrtImg(c_s_r, d_s_r) + `.svg" />
						</div>
					</div>
				</div>`;
	}
	getDOM("curr_content").innerHTML = html;
	var objs = document.querySelectorAll("div.cdc-item");
	for (let i = 0; i < objs.length; i++) {
		if (objs[i].getAttribute("has-cross") > 0) {
			objs[i].children[0].click();
			break;
		} else {
			objs[i].children[0].click();
			hoverCrossItem(objs[i].children[0], 1);
		}
	}
	if (!has_curr) {
		getDOM("cross_curs").innerHTML = "";
		getDOM("end_sum_btn").innerHTML = "";
	}
}

function drawBranch(data) {
	let code = "";
	getDOM("svginfo").classList.remove("for_loader");
	for (var i = 0; i < data.length; i++) {
		code += `<div class="svginfo-item"><div class="svginfo-title">
					<img src='files/` + data[i].logo + `' />
					<span>` + data[i].branch_name + `</span>
				</div>
				<div class="svginfo-text">
					<span>МФО:</span>
					<p>` + data[i].branch_code + `</p>
				</div>
				<div class="svginfo-text">
					<span>Tel:</span>
					<p>` + phoneMask('998947777777') + `</p>
				</div>
				<div class="svginfo-text">
					<span>Аддрес:</span>
					<p>` + data[i].address + `</p>
				</div>							
			</div>`;
	}
	getDOM("svginfo").innerHTML = code;
}
function drawCurrency(d) {
	loadingPanel("cb_currency",false);
	if (d.data.length > 0) {
		var cb_cur = d.data[0];
		var cur_html = "";

		for (var i = 0; i < cb_cur.children_curr.length; i++) {
			cur_html += `<div class="ipbc-item" data-currency="`+cb_cur.children_curr[i].curr_char_code+`" onclick="showCurrency(this)">
						<div class="ipbc-icon">
							<img src="files/icons/flags/` + cb_cur.children_curr[i].curr_char_code + `.svg" />
						</div>
						<div class="ipbc-text">
							<div class="ipbc-simvol">` + cb_cur.children_curr[i].curr_name + `</div>
							<div class="ipbc-value">` + cb_cur.children_curr[i].equival + `</div>
						</div>
					</div>`;
		}
		
		getDOM("cb_currency").innerHTML = cur_html;
	}
	getDOM("curr_oper_day").value = d.oper_day;
}
function drawChartDest() {
	let html = "";
	let dests = getDestData();
	for (let i = 1; i < dests.length; i++) {
		html += `<label for="dest_`+dests[i].code+`" class="radio" onclick="checkedChartDest(`+dests[i].code+`)">
					<input type="radio" name="chart_dest"  id="dest_`+dests[i].code+`" value="` + dests[i].code + `" class="hidden"/>
					<span class="label"></span>` + dests[i].name + `
				</label>`;
	}
	getDOM("chart_radio").innerHTML = html;
}
function drawChart(dest, curr) {
	let dataSource = getChartData(dest, curr);
	FusionCharts.ready(function () {
		var myChart = new FusionCharts({
				type: "msline",
				renderAt: "chart-container",
				width: "100%",
				height: "100%",
				dataFormat: "json",
				dataSource
			}).render();
	});
}
/*******************************************/
$(".cdt-close").click(function(){
	$(".currency-data").removeClass("open");
	removeCalc();
});

$(".cd-bottom button").click(function(){
	$(".currency-data").removeClass("open");
});

function initCurItem() {
	$("#cb_currency .ipbc-item").click(function () {
		var sym = $(this).attr("data-currency");
		$(".currency-data").addClass("open");
		$("#currency-select").val(sym);
		$(".custom-select .select-selected").remove();
		$(".custom-select .select-items").remove();
		customSelect("custom-select");
		changeCurImg("custom-select");
		removeCalc();
		drawCurrInfo(sym);
	});
}
function showCurrency(o){
// $("#cb_currency .ipbc-item").click(function () {
	var sym = $(o).attr("data-currency");
	$(".currency-data").addClass("open");
	$("#currency-select").val(sym);
	$(".custom-select .select-selected").remove();
	$(".custom-select .select-items").remove();
	customSelect("custom-select");
	changeCurImg("custom-select");
	removeCalc();
	drawCurrInfo(sym);
// });
}
function currencyCalc(el) {
	let cur = $("#currency-select").children("option:selected").val();
	var str, kurs;
	kurs =  el.parentNode.getElementsByTagName("span")[0].textContent.replace(/ /g,"");
	kurs = parseFloat(kurs);
	str = `<div class="currency-calc" style="top:`+ el.offsetTop +`px; left:` + el.offsetLeft + `px">
		<div class="cc-body">
			<div class="ccb-close">
				<i class="fas fa-times" onClick="removeCalc()"></i>
			</div>
			<div class="ccb-left">
				<input type="text" value="1" id="currency1" onkeyup="calcKeyUp(this)" />
				<span>`+cur+`</span>
			</div>
			<div class="equal">
				<i class="fas fa-equals"></i>
			</div>
			<div class="ccb-right">
				<input type="text" value="` + kurs + `" id="currency2" data-value="` + kurs + `" onfocus="copyText(this)" />
				<span>SUM</span>
			</div>
			<div class="cc-body-arrow"></div>
		</div>
	</div>`;	
	removeCalc();
	document.querySelector(".currency-data .cd-content").innerHTML += str;
}
function changeCurImg(t) {
	let src = "files/icons/flags/";
	let cur = "";
	let selectCurr=false;
	if (t == "custom-select") {
		cur = $("#currency-select").children("option:selected").val();
		selectCurr = !$(".custom-select .select-selected").hasClass("select-arrow-active");
		$("#currency-img").attr("src", src + cur + ".svg");
		$("#currency-img").css({width: "30px",height: "30px"});
		if(selectCurr)
		    drawCurrInfo(cur);
	} else if (t == "custom-select2") {
		selectCurr = !$(".custom-select2 .select-selected").hasClass("select-arrow-active");
		cur = $("#currency-select2").children("option:selected").val();
		let dest = getChartDest();
		$("#currency-img2").attr("src", src + cur + ".svg");
		if (selectCurr)
			drawChart(dest, cur);
	}
}
customSelect("custom-select2");

function removeCalc() {
	$(".currency-calc").remove();
}
function calcKeyUp(el) {
	var val,val2,el2,num,num2;
	val = el.value.replace(/ /g, '');
	el.value = val;
	val2 = $("#currency2").attr("data-value");
	val2 = parseFloat(val2.replace(/ /g, ''));
	val2 *= val;
	if (isNaN(val2)) {
		val2 = 0;
	}
	$("#currency2").val(val2);
	num = el.value;
	el.value = num.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
	num2 = $("#currency2").val();
	num2 = num2.replace(/\B(?=(\d{3})+(?!\d))/g, " ");
	$("#currency2").val(num2);
};

function copyToClipboard(text) {
   var textArea = document.createElement("textarea");
   textArea.value = text.replace(/ /g, '');
   document.body.appendChild( textArea );       
   textArea.select();
   try {
      var successful = document.execCommand('copy');
	  $.toast({
			heading: 'Информация',
			text: 'Текст скопирован!',
			position: 'bottom-right',
			bgColor: '#006EDB',
			loader: true,
			loaderBg: '#FFC542',
			stack: false
		});
   } catch (err) {
      console.log('Oops, unable to copy',err);
   }    
   document.body.removeChild( textArea );
}

function copyText(el) {
	var clipboardText = "";
	if (el.tagName == "INPUT") {
		clipboardText = el.value;
	} else {
		clipboardText = el.innerText;
	}
	copyToClipboard(clipboardText);
}
function goClients() {
	go({
		url: "files/clients.jsp",
		lock: false
	});
}
function goMessage() {
	go({
		url: "/ibs/user/info/chat_messages.jsp",
		target: "modalE",
		dialogWidth: 1000,
		lock: false
	});
}
function goDocument() {
	go({
		url: "files/payments.jsp",
		target: "modalE",
		dialogWidth: 1000,
		lock: false
	});
}
function showCalendar(html){
	
}
function selectDay(day){
	
}