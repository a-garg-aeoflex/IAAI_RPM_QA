({
    fetchAcc : function(component, event, helper) {
        component.set("v.isOpen", true);
        
         
         helper.fetchAccHelper(component, event, helper);
         var processSpinner = component.find("processSpinner");
         
    },
    openModel: function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) { 
        component.set("v.isOpen", false);
    },
    
})