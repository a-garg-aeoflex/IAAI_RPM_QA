({
    init : function (component) {
        let brokerId;
		let sPageURL = decodeURIComponent(window.location.search.substring(1));
        let sURLVariables = sPageURL.split('&'); 
        let sParameterName;
        for (let i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            console.log('param ' + sParameterName[0] + ' : ' +sParameterName[1]);
            if (sParameterName[0] === 'BrokerId') {
               brokerId = sParameterName[1] === undefined ? true : sParameterName[1];
            }            
         }
        if(!$A.util.isEmpty(brokerId)){
            
            let flow = component.find("flowData");
            let inputVariables = [
                { name : "BrokerId", type : "String", value: brokerId }   
            ];
            
            flow.startFlow("Need_A_Broker", inputVariables);
        }
        
    },
    handleStatusChange : function (component, event,helper) {
       if(event.getParam("status") === "FINISHED") {
            helper.navigate(component, event);
        }
	}
})