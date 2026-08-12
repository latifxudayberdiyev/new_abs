const dataSource = getChartData(4, 'USD');

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