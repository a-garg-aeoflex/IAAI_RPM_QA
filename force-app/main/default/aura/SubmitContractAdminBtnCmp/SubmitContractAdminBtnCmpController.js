({
	doInit : function(component, event, helper) {
        var action = component.get("c.getCurrentAccount");
        action.setParams({
            "accountId" : component.get("v.recordId")
        });
		action.setCallback(this, function(response) {
             var state = response.getState();
            console.log(' callback status '+state);
			 if (state === "SUCCESS") {              
                console.log("From server: " + response.getReturnValue());
                 var currentRec = response.getReturnValue();
                  console.log('currentRec '+currentRec.allMandatoryFilled);
                 if(currentRec.allMandatoryFilled == true){
                    
                     $A.enqueueAction(component.get("c.submitApprovalProcessJS"));
                     $A.get('e.force:refreshView').fire()
                     $A.get("e.force:closeQuickAction").fire();
                	
                     //alert("please fill all mandatory fields");
                 }else{
                     console.log("1");
                     // alert("please fill all mandatory fields");
                     //alert("Process started");
                    // $A.get("e.force:closeQuickAction").fire()
                     //$A.enqueueAction(component.get("c:showToastSuccessed"));
                    // $A.get("e.force:closeQuickAction").fire()
                      var spinner = component.find("mySpinner");
                     $A.util.addClass(spinner, "slds-hide");
					console.log("1 "+component.get("v.showError"));
                     component.set("v.showError",true);
                     console.log("2 "+component.get("v.showError"));
                	 component.set("v.errorMessage","Please fill all the mandatory fields <br />"+currentRec.mandatoryFields);
                    
                     console.log(component.get("v.errorMessage"));
                 }
             } else if (state === "INCOMPLETE") {
                // do something
             } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);

 
	},
    submitApprovalProcessJS : function(component, event, helper) {
       var action = component.get("c.submitApprovalProcess");
        action.setParams({
            "currentRecordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
             var state = response.getState();
            console.log(' callback status '+state);
			 if (state === "SUCCESS") {              
                console.log("From server Approval: " + response.getReturnValue());
                 var currentRec = response.getReturnValue();
                  
                 console.log("approval Process sucessfully submited.")
             } else if (state === "INCOMPLETE") {
                // do something
             } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message1: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error 1");
                }
            }
        });
        $A.enqueueAction(action);
	},
    showToastSuccessed : function(component, event, helper) {
        var toastEvent2 = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been Processed."
        });
        toastEvent2.fire();
	}
})