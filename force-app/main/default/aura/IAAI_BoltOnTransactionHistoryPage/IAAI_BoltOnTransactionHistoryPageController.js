({     
    onInit : function( component, event, helper ) {  
        
        var pageSize = component.get("v.PageSize").toString();
        var pageNumber = component.get("v.PageNumber").toString();
        helper.getColumns(component);
        helper.fetchVPE(component, pageNumber, pageSize);  
    },  
    onSubmitClick  : function( component, event, helper ) {   
                component.set("v.submitbid", true); 
                component.set("v.rows", event.getParam('row'));
    },
    closeModel  : function( component, event, helper ) {   
                component.set("v.submitbid", false);
    },
    onSave : function(component, event, helper) {
        var updatedRecords = component.find("vpeTable").get("v.draftValues"); 
        var recID = component.get("v.rows").Id; 
        var action = component.get("c.updateVPEListingRec"); 
        action.setParams({ 
            'updatedVPEList' : recID 
        });  
        action.setCallback(this,function(response) { 
            var state = response.getState();   
            if ( state == "SUCCESS" ) {
                if (response.getReturnValue() == true ){ 
                       component.find("vpeTable").set("v.draftValues", null); 
                       var pageNumber = component.get("v.PageNumber");  
                       var pageSize = component.get("v.PageSize"); 
                       
        			   helper.fetchVPE(component, pageNumber, pageSize);
       				   component.set("v.submitbid", false);
                    helper.toastMsg('error', 'Something went wrong. Contact your system administrator.'); 
                } 
            } else {
                helper.toastMsg('error', 'Something went wrong. Contact your system administrator.'); 
            } 
        });  
        $A.enqueueAction(action);  
    },
    

    
    handleNext: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.get("v.PageSize"); 
        pageNumber++;
        helper.fetchVPE(component, pageNumber, pageSize);
    },
     
    handlePrev: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.get("v.PageSize");
        pageNumber--;
        helper.fetchVPE(component, pageNumber, pageSize);
    },
      
})