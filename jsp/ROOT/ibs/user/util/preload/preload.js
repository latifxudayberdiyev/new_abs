function preLoad(type, state) {
	try {
		if (!isCross())
			return;
		var preloadBlock = document.createElement("div");
		preloadBlock.setAttribute("class", "preload_loading");
		var preload = "preload_loading";
		switch (type) {
		case "l":
			preload = "preload_loading";
			break;
		case "s":
			preload = "preload_success";
			break;
		case "w":
			preload = "preload_warning";
			break;
		case "e":
			preload = "preload_error";
			break;
		}
		preloadBlock.innerHTML = `
	<div id="preload_loading" class="preload_loading ${(type!="l")?"preload_hide":""}">
		<svg class="preload_load_spinner" viewBox="0 0 50 50">
		  <circle class="path" cx="25" cy="25" r="20" fill="none" stroke-width="3"></circle>
		</svg>
	</div>
	<div id="preload_success" class="preload_success ${(type!="s")?"preload_hide":""}">
		<div class="spreload_sa">
		<div class="spreload_sa-success">
		<div class="spreload_sa-success-tip"></div>
		<div class="spreload_sa-success-long"></div>
		<div class="spreload_sa-success-placeholder"></div>
		<div class="spreload_sa-success-fix"></div>
		</div>
		</div>
	</div>
	<div id="preload_error" class="preload_error ${(type!="e")?"preload_hide":""}">
		<div class="epreload_sa">
		<div class="epreload_sa-error">
		<div class="epreload_sa-error-x">
		<div class="epreload_sa-error-left"></div>
		<div class="epreload_sa-error-right"></div>
		</div>
		<div class="epreload_sa-error-placeholder"></div>
		<div class="epreload_sa-error-fix"></div>
		</div>
		</div>
	</div>
	<div id="preload_warning" class="preload_warning ${(type!="w")?"preload_hide":""}">
		<div class="wpreload_sa">
		<div class="wpreload_sa-warning">
		<div class="wpreload_sa-warning-body"></div>
		<div class="wpreload_sa-warning-dot"></div>
		</div>
		</div>
	</div>`;
		if (state) {
			document.body.insertBefore(preloadBlock, null);
		} else {
			var cl = preload + " preload_hide";
			document.getElementsByClassName(preload)[0].className = cl;
			document.getElementsByClassName(preload)[0].remove();
		}
	} catch (e) {}
}
