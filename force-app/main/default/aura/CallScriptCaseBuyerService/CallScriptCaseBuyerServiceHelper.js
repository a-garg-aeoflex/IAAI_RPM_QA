({
    Counter : function (cmp, event, Counter) {
        console.log('Counter '+Counter);
        if(Counter == 1){
            var AccountDiv = cmp.find("AccountDiv");
            $A.util.removeClass(AccountDiv, "slds-hide");
            $A.util.addClass(AccountDiv, "slds-show");
            var contactDiv = cmp.find("contactDiv");
            $A.util.removeClass(contactDiv, "slds-show");
            $A.util.addClass(contactDiv, "slds-hide");
            cmp.set("v.StepOne", true);
            cmp.set("v.StepTwo", false);            
            cmp.set("v.Stepthree", false);
            cmp.set("v.StepFour", false);
            cmp.set("v.StepFive", false);
            cmp.set("v.StepSix", false);
            cmp.set("v.showPrevious", false);
            
            
        }else if(Counter == 2){
            var AccountDiv = cmp.find("AccountDiv");
            $A.util.removeClass(AccountDiv, "slds-show");
            $A.util.addClass(AccountDiv, "slds-hide");
            var contactDiv = cmp.find("contactDiv");
            $A.util.removeClass(contactDiv, "slds-hide");
            $A.util.addClass(contactDiv, "slds-show");
            
            cmp.set("v.showPrevious", true);
            cmp.set("v.StepTwo", true);
            cmp.set("v.StepOne", false);
            console.log("v.Stepthree "+cmp.get("v.Stepthree"));
            cmp.set("v.Stepthree", false);
            console.log("v.Stepthree "+cmp.get("v.Stepthree"));
            cmp.set("v.StepFour", false);
            cmp.set("v.StepFive", false);
            cmp.set("v.StepSix", false);
            
        }else if(Counter == 3){
            var contactDiv = cmp.find("contactDiv");
            $A.util.removeClass(contactDiv, "slds-show");
            $A.util.addClass(contactDiv, "slds-hide");
            console.log(Counter);
            
            
            if(cmp.get("v.selectedLookUpRecord1.Id") != null 
               && cmp.get("v.selectedLookUpRecord1.Id") != null){
                cmp.set("v.StepTwo", false);
                console.log("v.StepTwo "+cmp.get("v.StepTwo"));
                cmp.set("v.StepOne", false);
                console.log("v.StepOne "+cmp.get("v.StepOne"));
                cmp.set("v.Stepthree", true);
                console.log("v.Stepthree "+cmp.get("v.Stepthree"));
                console.log("v.Stepthree");
                cmp.set("v.StepFour", false);
                cmp.set("v.StepFive", false);
                cmp.set("v.StepSix", false);
            }else{
                console.log(Counter);
                cmp.set("v.StepTwo", false);
                console.log("v.StepTwo "+cmp.get("v.StepTwo"));
                cmp.set("v.StepOne", false);
                console.log("v.StepOne "+cmp.get("v.StepOne"));
                cmp.set("v.Stepthree", false);
                console.log("v.Stepthree "+cmp.get("v.Stepthree"));
                console.log("v.Stepthree");
                cmp.set("v.StepFour", true);
                cmp.set("v.StepFive", false);
                cmp.set("v.StepSix", false);
                console.log("v.StepFour"+cmp.get("v.StepFour"));
                cmp.set("v.Counter", 4)
            }
            
        }else if(Counter == 4){
            var contactDiv = cmp.find("contactDiv");
            $A.util.removeClass(contactDiv, "slds-show");
            $A.util.addClass(contactDiv, "slds-hide");
            if(cmp.get("v.selectedCaseRec") != null ){
                console.log(Counter);
                cmp.set("v.StepTwo", false);
                console.log("v.StepTwo "+cmp.get("v.StepTwo"));
                cmp.set("v.StepOne", false);
                console.log("v.StepOne "+cmp.get("v.StepOne"));
                cmp.set("v.Stepthree", false);
                console.log("v.Stepthree "+cmp.get("v.Stepthree"));
                console.log("v.Stepthree");
                cmp.set("v.StepFour", false);
                cmp.set("v.StepFive", true);
                cmp.set("v.StepSix", false);
                cmp.set("v.Counter", 5)
                console.log("v.StepFour"+cmp.get("v.StepFour"));
                
            }else{
                console.log(Counter);
                cmp.set("v.StepTwo", false);
                console.log("v.StepTwo "+cmp.get("v.StepTwo"));
                cmp.set("v.StepOne", false);
                console.log("v.StepOne "+cmp.get("v.StepOne"));
                cmp.set("v.Stepthree", false);
                console.log("v.Stepthree "+cmp.get("v.Stepthree"));
                console.log("v.Stepthree");
                cmp.set("v.StepFour", true);
                cmp.set("v.StepFive", false);
                cmp.set("v.StepSix", false);
                console.log("v.StepFour"+cmp.get("v.StepFour"));
            }
            
            
        }else if(Counter == 5){
            console.log(Counter);
            cmp.set("v.StepTwo", false);
            console.log("v.StepTwo "+cmp.get("v.StepTwo"));
            cmp.set("v.StepOne", false);
            console.log("v.StepOne "+cmp.get("v.StepOne"));
            cmp.set("v.Stepthree", false);
            console.log("v.Stepthree "+cmp.get("v.Stepthree"));
            console.log("v.Stepthree");
            cmp.set("v.StepFour", false);
            cmp.set("v.StepFive", true);
            cmp.set("v.StepSix", false);
            console.log("v.StepFour"+cmp.get("v.StepFour"));
            console.log("v.StepFive"+cmp.get("v.StepFive"));
            this.hideSpinner(cmp, event);
        }else if(Counter == 6){
            this.showSpinner(cmp, event);
            console.log("controller -- controller");
            this.createLogCall(cmp, event);
            console.log(Counter);
            cmp.set("v.StepTwo", false);
            console.log("v.StepTwo "+cmp.get("v.StepTwo"));
            cmp.set("v.StepOne", false);
            console.log("v.StepOne "+cmp.get("v.StepOne"));
            cmp.set("v.Stepthree", false);
            console.log("v.Stepthree "+cmp.get("v.Stepthree"));
            console.log("v.Stepthree");
            cmp.set("v.StepFour", false);
            cmp.set("v.StepFive", false);
            cmp.set("v.StepSix", true);
            console.log("v.StepFour"+cmp.get("v.StepFour"));
            console.log("v.StepFive"+cmp.get("v.StepFive"));
            console.log("controller -- controller - controller");
            this.hideSpinner(cmp, event);
        }
    },
    fetchPickListVal: function(component, fieldName, elementId) {
        console.log('fetchPickListVal');
        var action = component.get("c.getselectOptions");
        action.setParams({
            "ObjectApi_name": "Task",
            "Field_name": "Type"
        });
        var opts = [];
        action.setCallback(this, function(response) {
            console.log('setCallback');
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('allValues '+allValues)
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.set("v.picvalue", allValues);
            }
        });
        $A.enqueueAction(action);
    },
    caseRecordType : function(cmp, event) {
        console.log('getCaseRecordTypeId');
        var action = cmp.get("c.getCaseRecordTypeId");
        action.setCallback(this, function(response) {
            console.log('action.setCallback');
            this.showSpinner(cmp, event);
            console.log('this.showSpinner');
            console.log('setCallback response.getState '+response.getState());
            if (response.getState() == "SUCCESS") {
                console.log('response.getState() is Success');
                var allValues = response.getReturnValue();
                console.log('allValues '+allValues +' allValues.length '+allValues.length)
                if (allValues !== undefined && allValues.length > 0) {
                    for(var i = 0; i < allValues.length; i++){
                        var RecordTYpeidVal = allValues[i].split(',');
                        if(RecordTYpeidVal[0] === 'Buyer_Services'){
                            cmp.set("v.BuyerServiceId" ,RecordTYpeidVal[1]);
                        }else{
                            cmp.set("v.GuestServiceId", RecordTYpeidVal[1]);
                        }
                    }
                }
                console.log('BuyerServiceId '+cmp.get("v.BuyerServiceId"));
                console.log('GuestServiceId '+cmp.get("v.GuestServiceId"));
            }
            this.hideSpinner(cmp, event);
        });
        $A.enqueueAction(action);
    },
    createLogCall: function (cmp, event, Counter){
        console.log(Counter);
        var subject = cmp.find("Subject").get("v.value");
        var Description = cmp.find("Description").get("v.value");
        var type = cmp.get("v.selectedPickVal");
        console.log("subject "+subject);
        console.log("Description "+Description);
        console.log("type "+type);
        var action = cmp.get("c.createLogaCall");
        action.setParams({
            "Subject": subject,
            "Description": Description,
            "Type": cmp.get("v.selectedPickVal"),
            "CaseId": cmp.get("v.caseId")
            
        });
        action.setCallback(this, function(response) {
            this.showSpinner(cmp, event);
            console.log('setCallback');
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                console.log('allValues '+allValues);
                if (allValues != undefined && allValues.length > 0) {
                    console.log("task is  create ");
                }else{
                    console.log("task is not create ");
                }
            }
            this.hideSpinner(cmp, event);
            
        });
        $A.enqueueAction(action);
   },
    createCase: function(cmp, event) {
        console.log("I am In createCase");
        this.showSpinner(cmp, event);
        // stop the form from submitting
        event.preventDefault();       
        var fields = event.getParam('fields');
        console.log("selected Contact "+ cmp.get("v.selectedLookUpRecord1.Id"));
        
       
            fields.AccountId =  cmp.get("v.selectedLookUpRecord.Id") !== null ?cmp.get("v.selectedLookUpRecord.Id"):cmp.get("v.AccountId"); 
            fields.ContactId =  cmp.get("v.selectedLookUpRecord1.Id");
        
        if(cmp.get("v.selectedLookUpRecord1.Id") === undefined ){
            cmp.set("v.RecordTypeId", cmp.get("v.GuestServiceId"));
        }else{
            cmp.set("v.RecordTypeId", cmp.get("v.BuyerServiceId"));
        }
        cmp.find('createCaseForm').submit(fields);
        
        this.hideSpinner(cmp, event);
    },	
    handleCaseIdNNumber : function(cmp, event, helper) {        
        var selectedRows = event.getParam('selectedRows'); 
        console.log(selectedRows[0].Id);
        var cmpCaseEvent = cmp.getEvent("CaseDetailRec"); 
        cmpCaseEvent.setParams({"selsObjRec" : selectedRows[0] }); 
        cmpCaseEvent.setParams({"selectedCaseId" : selectedRows[0].Id }); 
        console.log("Value set");
        cmpCaseEvent.fire(); 
},
    showSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
    },
    
    hideSpinner: function (cmp, event) {
        var spinner = cmp.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
    }
    
})