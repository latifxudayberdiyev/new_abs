Object.prototype.fireEvent = function (event) {
    if (document.createEventObject) {
        var evt = document.createEventObject("Event");
        return this.fireEvent(event, evt)
    } else {
        var evt = document.createEvent("HTMLEvents");
        evt.initEvent(event.substring(2), true, true); // event type,bubbling,cancelable
        return !this.dispatchEvent(evt);
    }
};
String.prototype.trim = function () {
    var t = this
        , len = t.length
        , st = 0;
    while ((st < len) && (t.charCodeAt(st) <= 32)) st++;
    while ((st < len) && (t.charCodeAt(len - 1) <= 32)) len--;
    return ((st > 0) || (len < t.length)) ? t.substring(st, len) : t;
};
String.prototype.replaceAll = function (search, replacement) {
    var target = this;
    return target.split(search).join(replacement);
};
function parseJson(jsonString) {
	try {
		return JSON.parse(jsonString);
	} catch (e) {
		try {
			return eval('(' + jsonString + ')');
		} catch (er) {
			alert(jsonString);
		}
	}
}
function JsonToString(v) {
	try {
		return JSON.stringify(v);
	} catch (e) {
		if (isNumber(v)) {
			return v;
		}
		if (isString(v)) {
			return "'" + v.replace(/\\/g, "\\\\").replace(/'/g, "\\\'") + "'";
		}
		if (isArray(v)) {
			var r = "[";
			for (var i = 0; i < v.length; i++) {
				if (i != 0)
					r += ",";
				r += JsonToString(v[i]);
			}
			return r + "]";
		}
		if (isHash(v)) {
			var r = "{",
			f = false;
			for (a in v) {
				if (f)
					r += ",";
				f = true;
				r += a + ":" + JsonToString(v[a]);
			}
			return r + "}";
		}
		return v;
	}
}
/**/
function isArray(o) {
    return Object.prototype.toString.call(o) === '[object Array]';
}
function isFunc(o) {
    return Object.prototype.toString.call(o) === '[object Function]';
}
function isHash(o) {
    return Object.prototype.toString.call(o) === '[object Object]';
}
function isNumber(o) {
    return Object.prototype.toString.call(o) === '[object Number]';
}
function isString(o) {
    return Object.prototype.toString.call(o) === '[object String]';
}
function isUndef(o) {
    return (o === undefined || o == null);
}
function getOSName() {
	var osName = "";
	if (window.navigator.platform.indexOf("Win") != -1) {
		osName = "windows";
	} else if(window.navigator.platform.indexOf("Mac") != -1) {
		osName = "mac";
	} else if(window.navigator.platform.indexOf("Linux") != -1) {
		osName = "linux";
	} else if(window.navigator.userAgent.indexOf("Android") != -1) {
		osName = "android";
	} else if(window.navigator.userAgent.indexOf("iPhone") != -1) {
		osName = "ios";
	} else if(window.navigator.userAgent.indexOf("iPad") != -1) {
		osName = "ios";
	} else if(window.navigator.userAgent.indexOf("iPod") != -1) {
		osName = "ios";
	}
	return osName;
}
function getIabsClientName() {
	var osName = getOSName();
	var fileName = "";
	switch(osName) {
		case "windows": fileName = iabsClientWindowsName; 	break;
		case "linux": 	fileName = iabsClientLinuxName; 	break;
		case "mac": 	fileName = iabsClientMacName; 		break;
		case "ios": 	fileName = iabsClientIOSName; 		break;
		case "android": fileName = iabsClientAndroidName; 	break;
	}
	return fileName;
}
function getIabsClientOSVersion() {
	var osName = getOSName();
	var version = "";
	switch(osName) {
		case "windows": version = iabsClientWindowsVersion; 	break;
		case "linux": 	version = iabsClientLinuxVersion; 	 	break;
		case "mac": 	version = iabsClientMacVersion; 	 	break;
		case "ios": 	version = iabsClientIOSVersion; 	 	break;
		case "android": version = iabsClientAndroidVersion; 	break;
	}
	return version;
}
/*------------------------start hashtable --------------------------------*/
var hash = function (string, max) {
    var hash = 0;
    for (var i = 0; i < string.length; i++) {
        hash += string.charCodeAt(i);
    }
    return hash % max;
};
var HashTable = function () {
    var storage = [];
    var storageLimit = 1;
    var keys = [];
    this.print = function () {
        // console.log(storage);
    };
    this.put = function (key, value) {
        var index = hash(key, storageLimit);
        if (storage[index] === undefined) {
            storage[index] = [
                [key, value]
            ];
        } else {
            var inserted = false;
            for (var i = 0; i < storage[index].length; i++) {
                if (storage[index][i][0] === key) {
                    storage[index][i][1] = value;
                    /* bu keyga value qo'yayotganda agar bo'lsa boshqa qo'ymasligi uchun*/
                    inserted = true;
                }
            }
            if (inserted === false) {
                storage[index].push([key, value]);
            }
        }
    };
    this.remove = function (key) {
        var index = hash(key, storageLimit);
        if (storage[index].length === 1 && storage[index][0][0] === key) {
            delete storage[index];
        } else {
            for (var i = 0; i < storage[index].length; i++) {
                if (storage[index][i][0] === key) {
                    delete storage[index][i];
                }
            }
        }
    };
    this.get = function (key) {
        try {
            var index = hash(key, storageLimit);
            if (isUndef(storage[index])) {
                return "";
            } else {
                for (var i = 0; i < storage[index].length; i++) {
                    if (storage[index][i][0] === key) {
                        return (isUndef(storage[index][i][1]) ? "" : storage[index][i][1]);
                    }
                }
            }
        } catch (e) {
            return "";
        }
    };
    this.has = function (key) {
        var index = hash(key, storageLimit);
        if (storage[index] === undefined) {
            return false;
        } else {
            for (var i = 0; i < storage[index].length; i++) {
                if (storage[index][i][0] === key) {
                    return true;
                    break;
                } else {
                    return false;
                    break;
                }
            }
        }
    };
};
var ht = new HashTable();
window.FBWebSocket = function (url) {
	var iabsClientUrl = "localhost:8088/app";
	var osName = getOSName();
	this.url = isUndef(url) ? iabsClientUrl : url;
	var iabsClient = getIabsClientName();
	var obj = this;
	var ws = null;
	var callbackFunc;
	var readyState;/*0-connection,1-open,2-closing,3-closed*/
	var currentVersion = "";
	this.runWS = function () {
	 	try {
	 		ws = new WebSocket('ws://' + obj.url);
	 		ws.onopen = function (d) {
				if(obj.isIabsClientWS()){
					ws.send(JsonToString({"action": "getVersion"}));
					obj.getIPData(setJsonToHashtable);
				}
	 			obj.readyState = d.currentTarget.readyState;
				if (obj.readyState == 1) {
					document.getElementById("iabs-client").style.display = "none";
					if (typeof pluginValid == "function") {
						pluginValid();
					}
				}
	 		};
	 		ws.onmessage = function (d) {
	 			obj.resultData(d);
	 		};
	 		ws.onclose = function (d) {
	 			obj.readyState = d.currentTarget.readyState;
	 		};
	 		ws.onerror = function (e) {
	 			obj.readyState = e.currentTarget.readyState;
				if (obj.isIabsClientWS() && e.type == 'error') {
					if (obj.readyState == 3) {
												document.getElementById("iabs-client").style.display = "block";
						var text = "<a href='/ibs/user/soft/iabs-client/"+ osName +"/"+ iabsClient + "' target='_blank' download>«агрузите программу iABS7 Client, чтобы воспользоватьс€ всеми преимуществами системы iABS 7!</a>";
						obj.setIabsClientText(text);
                        if(document.getElementById("load"))
						    document.getElementById("load").style.display = "none";
					} else {
						obj.getIPData(setJsonToHashtable);
					}
				}else{
					console.log('error',e);
				}
	 		};
	 	} catch (e) {
	 		ws = null;
	 	};
	};
	this.needUPDVersion = function (cV, nV) {
		var cVs = wV.split(".");
		var nVs = nV.split(".");
		cVs[0] = cVs[0].substring(1,cVs[0].length);
		nVs[0] = nVs[0].substring(1,nVs[0].length);
		if(cVs[0]>nVs[0]){
			return false;
		}
	};
	this.isOpenWS = function () {
		if(obj.hasWS()){
			return obj.readyState == 1;
		}else{
			return false;
		}
	};
	this.isIabsClientWS = function () {
		return obj.url == iabsClientUrl;
	};
	this.hasWS = function () {
		return ws != null;
	};
	this.getIPData = function(callback){
		 ws.send(JsonToString({"action": "getData"}));
		 if(isFunc(callback)){
				callbackFunc = callback;
		}
	};
	this.execCallbackFunc = function (result) {
		if (isFunc(callbackFunc)){
			callbackFunc(result);
		}
	};
	this.resultData = function (d) {
		var searchRes = parseJson(d.data);
		obj.setIabsClientVersion(searchRes);
		obj.execCallbackFunc(searchRes);
	};
	this.getSerialNumber = function(callback) {
		ws.send(JsonToString({ "action": "getSerialNumber"}));
		if(isFunc(callback)) {
			callbackFunc = callback;
		}
	};
	this.signedMsg = function(queryLine,callback){
		// ws.send(JsonToString({"function": "cryptoSign", "obj": queryLine}));
		ws.send(JsonToString({ "action": "signMessage", "data": {"signMessage": queryLine}}));
		if(isFunc(callback)){
				callbackFunc = callback;
		}
	};
	this.setIabsClientVersion = function (d) {
		if (d["action"] == "getVersion") {
			currentVersion = d["responseBody"];
			obj.updateVersion(currentVersion, getIabsClientOSVersion());
		}
	};
	this.getIabsClientVersion = function() {
		return currentVersion;
	};
	this.setIabsClientText = function(text){
		if (!isUndef(document.getElementById("iabs-client"))) {
				document.getElementById("iabs-client").innerHTML = text;
			}
	};
	this.updateVersion = function (cV, nV) {
		// obj.needUPDVersion(cV,nV);
		cV = cV.replace(/[vV.]/g, "");
		nV = nV.replace(/[vV.]/g, "");
		if (cV < nV) {
			var text= "<a href='/ibs/user/soft/"+iabsClient+"' target='_blank' download>ћы рекомендуем вам обновить iABS7 Client до последней версии, чтобы воспользоватьс€ всеми преимуществами системы iABS 7!</a>";
			obj.setIabsClientText(text);
		}
	};
	this.main = function () {
		obj.runWS();
	};
	/*-----------------------------------*/
	obj.main();
};
function setJsonToHashtable(json) {
    var obj = {};
    if (json['code'] == 0) {
        obj = json['responseBody'];
    }
    for (var key in obj) {
        if (isArray(obj[key])) {
            ht.put(key, obj[key]);
        } else {
            ht.put(key, obj[key]);
        }
    }
}
function makeURLParam() {
	var makeURLParam = "";
	var params = ["mac", "ip", "domainName", "terminalName", "remoteUser"];
	var macsANDips;
	function appendURLParam(param, value) {
		makeURLParam += "&" + param + "=" + value;
	}
	for (var i = 0; i < params.length; i++) {
		macsANDips = ht.get(params[i]);
		if (!isUndef(macsANDips)) {
			if (isArray(macsANDips)) {
				for (var j = 0; j < macsANDips.length; j++) {
					appendURLParam(params[i], macsANDips[j]);
				}
			} else {
				appendURLParam(params[i], macsANDips);
			}
		}
	}
	return makeURLParam;
}
try {
		/*===============================================================================*/
		var p;
		var ips = [],
		macs = [];
		var sr = (new ActiveXObject("WbemScripting.SWbemLocator")).ConnectServer(".");
		var e = new Enumerator(sr.ExecQuery("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled=true"));

		for (; !e.atEnd(); e.moveNext()) {
			p = e.item();
			macs.push(p.MACAddress);
			ips.push((p.IPAddress != null ? p.IPAddress(0) : ""));
		}
		p = (new Enumerator(sr.ExecQuery("SELECT * FROM Win32_ComputerSystem"))).item();
		ht.put('mac', macs);
		ht.put('ip', ips);
		ht.put('domainName', p.Domain);
		ht.put('terminalName', encodeURIComponent(p.Name));
		ht.put('remoteUser', encodeURIComponent(p.UserName.replace(p.Name + "\\", "")));
		/*===============================================================================*/
} catch (e) {
		var fbws = new FBWebSocket();
		// var fbws2 = new FBWebSocket('localhost:8181');
}