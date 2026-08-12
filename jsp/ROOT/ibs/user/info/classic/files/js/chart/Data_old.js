var chart_data = {};
function getCategory() {
	var category = [];
	for (var i in chart_data.d) {
		category.push({"label": chart_data.d[i].day});
	}
	return [{category:category}];
}
function getChartDataByDest(dest) {
	var cs = [], c = "";
	for (let i in chart_data.d) {
		cs.push(chart_data.d[i].data.filter((d) => d.code == dest)[0]);
	}
	return cs;
}
function getChartByCurr(dest, curr) {
	let d = getChartDataByDest(dest);
	let d_cs = [];
	for (let i in d) {
		d_cs.push(d[i].child.filter((t) => t.char_code == curr)[0]);
	}
	return d_cs;
}
var min, max;
function getDataChartVal(dest, curr, type) {
	let data = [];
	try {
		let d = getChartByCurr(dest, curr);
		let s = "equival";
		if (type == "BUY") {
			s = "buying_rate";
		} else if (type == "SEL") {
			s = "selling_rate";
		}
		d.forEach(function (t, i) {
			data.push({"value": t[s]});
		});
		/* if(data[0].value != "undefined") */
		if(typeof data[0].value == "number") {
			min=data[0].value, max=data[0].value;
			for(var i=0; i<data.length; i++) {
				if(data[i].value > max) { max = data[i].value; }
				if(data[i].value < min) { min = data[i].value; }
			}
			console.log("min: " + min);
			console.log("max: " + max);			
		}
		return data;
	} catch (e) {
		return [];
	}
}
function getDataSet(dest, curr) {
	let buyings = getDataChartVal(dest, curr, 'BUY');
	let sellings = getDataChartVal(dest, curr, 'SEL');
	if (buyings.length==0) return;
	if(is.undef(buyings[0].value)){
		return [{seriesname: si_currency_CB, data: getDataChartVal(1, curr, 'CB')}];
	}
	return [{seriesname: si_currency_CB, data: getDataChartVal(1, curr, 'CB')},
			{seriesname: si_buying_rate, data: buyings},
			{seriesname: si_selling_rate, data: sellings}];
}
function getDestData(curr) {
	let dests = [];
	for (let i in chart_data.d[0].data) {
		if (chart_data.d[0].data[i].child.length > 0 && chart_data.d[0].data[i].child.filter((t) => t.char_code == curr).length > 0)
			dests.push({code: chart_data.d[0].data[i].code,name: chart_data.d[0].data[i].name});
	}
	return dests;
}
function getChartData(dest,curr) {
	return {
		chart: {
			showhovereffect: "1",
			numbersuffix: " UZS", 
			labelDisplay:"rotate",
			slantLabel: "1",
			// labelStep: "2",
			drawcrossline: "1",
			setAdaptiveYMin: "1",
			/* decimalSeparator: ",",
			thousandSeparator: ".", */
			/* showLegend: "0", */
			/* showValues: "1", */
			/* thousandSeparatorPosition: "2,3", */
			formatNumberScale: "0",
			plotHighlightEffect: "fadeout", 
			legendPosition: "right",
			/* legendAllowDrag: "1", */
			/* legendPosition: "absolute",
			legendXPosition: "700",
			legendYPosition: "420", */
			/* legendIconScale: "1", */
			plottooltext: "$seriesName - <b>$dataValue</b>",
			theme: "fusion",
			yAxisMaxValue: max,
			yAxisMinValue: min,
			/* setAdaptiveYMin:"1",
			numdivlines: "7" */
		},
		categories: getCategory(),
		dataset: getDataSet(dest, curr)
	};
}