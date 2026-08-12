function onLoad(){
	goClientDoc("ACCOUNT");
	getDOM("client_name").innerHTML=localStorage.getItem('client_name'); 
	if(subject=="P"){
		hideDOM("card2");
	}
}
$(".button-group__btn").click(function(eventObject){
	eventObject.preventDefault();
	goClientDoc($(this).find("input").val());
	$(this).find("input").prop("checked", true);
});
function goClientDoc(t){
	let url="client/accounts_list.jsp";
	switch (t) {
	case "ACCOUNT":
		url = "client/accounts_list.jsp";
		break;
	case "CARD2":
		url = "client/card2.jsp";
		break;
	case "LEAD":
		url = "client/leads.jsp";
		break;
	case "LOAN":
		url = "client/loans.jsp";
		break;
	case "DEP":
		if (subject == 'J'){
			url = "client/deposits_yur.jsp";
		}else{
			url = "client/deposits_fiz.jsp";
		}
		break;
	case "SV":
		url = "client/sv_cards.jsp";
		break;
	}
	go({url:url+'?code='+encodeURIComponent(code)+'&subject='+subject,target:client_info,lock:false});
}