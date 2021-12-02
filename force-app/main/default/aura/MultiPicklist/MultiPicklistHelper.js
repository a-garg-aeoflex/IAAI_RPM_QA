({
    selectOptionHelper : function(component,label,isCheck) {
        var selectedOption='';
		var allOptions = component.get('v.options');
        var secValues = [];
        var count=0;
        if(label =='All'){
            for(var i=0;i<allOptions.length;i++){
                if(isCheck =='true') {
                    allOptions[i].isChecked = false; 
                }else{
                    allOptions[i].isChecked = true; 
                }
            }
            
            
        }else {
        for(var i=0;i<allOptions.length;i++){
            if(allOptions[i].label==label) {
                if(isCheck=='true'){
                    allOptions[i].isChecked = false; 
                }else{
                    allOptions[i].isChecked = true; 
                } 
            } 
            if(allOptions[i].isChecked){
                selectedOption=allOptions[i].label; 
                 secValues.push(allOptions[i].label);
                count++; 
            }
         } 
        }
        if(count>1){
            selectedOption = count+' items selected';
        }
        component.set("v.selectedOptions",selectedOption);
        component.set('v.options',allOptions);
        component.set('v.selectedValues',secValues);
        var myEvent = $A.get("e.c:IAAI_PicklistEvent");
        myEvent.setParams({"selectedplvalues": secValues});
        myEvent.fire();
        
    },
    getOpetionsHelper: function(component)
    {
        var action = component.get("c.getOptions");   
        action.setCallback(this, function(response) {
            var state  = response.getState(); 
            var result = response.getReturnValue(); 
            
            for(var i=0;i<=result.length;i++){            
                opt.push({label:result[i].label,isChecked:result[i].isChecked});
            }
            component.set("v.options",opt);
            
        });
        
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
        
    } 
})