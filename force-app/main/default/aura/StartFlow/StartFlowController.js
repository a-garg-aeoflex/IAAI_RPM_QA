({
    init : function (component,event,helper) {
        try{
            let brokerId;
            let sPageURL = decodeURIComponent(window.location.search.substring(1));
            let sURLVariables = sPageURL.split('&'); 
            let sParameterName;

            let inputVariables = [];
            inputVariables.push({ name :"LastName", type : "String", value:  "test" });  
            let flow = component.find("flowData");   
            //flow.startFlow(component.get("v.flow_name"), inputVariables);
            inputVariables = helper.getInputParams(component);
            //console.log('inputvars ' + inputVariables);
            
        }
        catch(e){
            console.log('Error: ' + e.message);
        }
        
    },
    handleStatusChange : function (component, event,helper) {
      
	}
})