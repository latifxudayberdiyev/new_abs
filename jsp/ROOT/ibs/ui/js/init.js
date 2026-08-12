// if(!fm.fireEvent('onsubmit')) return;
// window.focus();
// go({clearParams:false,url:'proportion.jsp?id='+ getData(1)});	

	w.onLoad = function(){
		var DataExists = dataExist();
			if(getDOM('btnEdit'))
			getDOM('btnEdit').disabled = !DataExists;
			if(getDOM('btnDel'))
			getDOM('btnDel').disabled = !DataExists;	
			if(getDOM('btnHis'))
			getDOM('btnHis').disabled = !DataExists;	
		}
	}
	function init(){
		window.status=document.location;
		if(screen.availWidth < 1025){
			document.getElementById("base").className += " init_1025";
			t = document.getElementById("tbl");
			small_filter();
		}
		if(screen.availWidth < 801){
			document.getElementById("base").className += " init_800";
			small_filter();
		}
		
	}
	var iss = "0";
	function small_filter(){
		var put = parent.parent.location.href;
		lPut = put.indexOf('cmshelper.jsp?');
      if (lPut>-1) {
				put = put.substring(0, lPut);
				put +="ibs/";
			}
      else {      
        lPut = put.indexOf('main.jsp?');
        if (lPut>-1) put = put.substring(0, lPut);
      }
		sb_put = put.indexOf('sb');
		if (sb_put>-1)
			put = put.substring(0, sb_put);
		else {
			sb_put = put.indexOf('sb');
			if (sb_put>-1) put = put.substring(0, sb_put);
		}
		var a=document.getElementsByTagName('button');
		for(i=0;i<a.length; i++){
			if(iss == "0" && a[i].className != "navbut" && a[i].type=="button"){
					iss="1";
				var srcs = put + "sb/util/icons/f.png";
				a[i].value='';
				if(a[i].className == "withFilter")
					srcs = put + "sb/util/icons/f_red.png";
				a[i].innerHTML='<img src=' + srcs + ' height=15 style="margin-left:5px;" width=20/>';
			}
		}
	}
	function disable_elements(){
		var length = fm.elements.length,i;
		for (i=0; i < length; i++) {
			if(fm.elements[i].type=="textarea")
				fm.elements[i].readOnly=true;
			else
			fm.elements[i].disabled = true;
		}
		getDOM("btnExit").disabled = false;
	}
	function disable_form(){
		pageLock(true);
	}
	//Открытия закрытия легенд фиелдсета
	
	function hide_open_legend(){
		var legends = document.getElementsByTagName("legend");
		for(var i=0; i<legends.length; i++){
				legends[i].onclick = function(){
				var el = this.parentNode.children[1];
				if(el.style.display=="none")
							el.style.display="";
				else 	el.style.display="none";
			}
		}
	}
// слово без символа. при отправки в go() without_symb(getData(2),"%") / обычно выходит ошибка в %
	function without_symb(txt,symb){
		if(txt.indexOf(symb))
			txt=txt.replace(symb,"");
		return txt;
	}
	function go_action(actions,ask_cause) {
		if (window.confirm(ask_cause))
			go({form:tblForm, param:{action:actions}});
	}
	function disabling_all_input(input_type){	
		var c = new Array();
		c = document.getElementsByTagName('input'); 
		for (var i = 0; i < c.length; i++){
			if (c[i].type == input_type)//checkbox,input,radio...
				c[i].disabled = true;
		}
	}
	function fill_zero(obj, len)
    {
        var val = obj.value;
        if (val.length < len)
        for (var i = val.length; i < len; i++) {
            val = "0" + val;
        }
        obj.value = val;
    }
		//в grid
		function is_any_checked(){
        for(var i = tblForm.elements.length; --i >= 0;){
           if ( tblForm.elements[i].type === 'checkbox' && tblForm.elements[i].checked )
               return true;
        }
        return false;
    }
		
function loadScript(url)
{
    // Adding the script tag to the head as suggested before
    var head = document.getElementsByTagName('head')[0];
    var script = document.createElement('script');
    script.type = 'text/javascript';
    script.src = url; 
    // Fire the loading
    head.appendChild(script);
}
function check_account()
{
	var filter=/\d{20}/;
	if (!filter.test(event.srcElement.value) && event.srcElement.value!="")
	{
		event.srcElement.focus();
        alert("Поле счета должно содержать 20 цифровых символов.");
		return false;
    }
}	

function set_tab() {
    var e = document.getElementsByTagName('INPUT');
    for (var r in e) {
      if (is.def(e[r].readOnly))
        if (e[r].readOnly) 
          e[r].tabIndex = -1;
    }
	}
//УБЕРАЕТ ПУCТИЕ СТРОКИ
function delSpace(v){
	return v.replace(/\s/g, '')
}
function nvl(v,vn){
	if (v=="") v=vn;
	return v;
}
// request.getParameter js da
function get(name){
   if(name=(new RegExp('[?&]'+encodeURIComponent(name)+'=([^&]*)')).exec(location.search))
      return decodeURIComponent(name[1]);
}