({
    getURLParams: function(component,params){

        let retVal = {};
        let inputVariables =[];
        for (const element of  params) {                
            retVal[element] = '';
        }
        let sPageURL = decodeURIComponent(window.location.search.substring(1));
        let sURLVariables = sPageURL.split('&'); 
        let sParameterName;
        for (let i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');
            if(params.includes(sParameterName[0])){
                let parm = sParameterName[1] === undefined ? true : sParameterName[1];
                inputVariables.push({ name : sParameterName[0], type : "String", value:  sParameterName[1] });
            }
        
        }
        return inputVariables;
 
    },
    getInputParams: function(component){
        let params = [];
        let flowparams = [];
        for (let i=0; i <= 5; i++) {        
            if(component.get('v.flow_var0'+i.toString())) {
                params.push(component.get('v.flow_var0'+i.toString()));                
            }
        }    
        //console.log('params'  + JSON.stringify(params));
        let keyStorage =localStorage.getItem('info');
        //console.log(' keyStorage: ' +  keyStorage);       
        let urlParams = [];
        for (let i=1; i <= 2; i++) {        
            if(component.get('v.flow_fromURL0'+i.toString())) {
                urlParams.push(component.get('v.flow_fromURL0'+i.toString()));                
            }
        }  
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        //console.log('userId ' + userId);
        //console.log('URL Params: ' + urlParams); 
        let urlParamValues;
        urlParamValues = this.getURLParams(component,urlParams);
        if(!userId){
            let action = component.get("c.getParms");
            action.setParams({
               "params": params,
               "values":  keyStorage
            });
            action.setCallback(this, function (response) {
               let state = response.getState();
               if (state === "SUCCESS") {
                  let resp = response.getReturnValue();
                  if(Array.isArray(resp) && urlParamValues){
                   resp.push(...urlParamValues);
                  }
                  let flow = component.find("flowData");  
                  flow.startFlow(component.get("v.flow_name"), resp);
   
               } 
            });
            $A.enqueueAction(action);
        }else{
            let action = component.get("c.getLoggedONInfo");
            action.setParams({ "params": params });
            action.setCallback(this, function (response) {
                let state = response.getState();
                if (state === "SUCCESS") {
                    let resp = response.getReturnValue();
                    if(Array.isArray(resp) && urlParamValues){
                        resp.push(...urlParamValues);
                    }
                    let flow = component.find("flowData");  
                    flow.startFlow(component.get("v.flow_name"), resp);
                } 
            });
            $A.enqueueAction(action);
        }
       
    }
})