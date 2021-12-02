({
    doInit: function(component, event, helper) {
        console.log('Init function');
        helper.fetchPickListVal(component, 'Type', 'taskType');
        helper.caseRecordType(component, event);
        
        
    },
    onPicklistChange: function(component, event, helper) {
        
        var strType = event.getSource().get("v.value");
        component.set("v.selectedPickVal", strType);
    },
    NextStep : function (cmp, event, helper) {
        console.log('v.Counter');
        var count = cmp.get("v.Counter");
        if(count === 1){
            console.log('test '+cmp.get("v.selectedLookUpRecord.Id") !== undefined && cmp.get("v.selectedLookUpRecord.Id") !== null);
            console.log('test1 '+cmp.get("v.selectedLookUpRecord.Id"));
            console.log('test1 '+cmp.get("v.AccountId"));
            if(cmp.get("v.selectedLookUpRecord.Id") !== undefined && cmp.get("v.selectedLookUpRecord.Id") !== null){
                var selectedAcc = cmp.get("v.selectedLookUpRecord.Id");
                var selectedAccId = cmp.get("v.AccountId");
                if(selectedAcc !== selectedAccId){
                    cmp.set("v.refreshedCon", false);
                    var blank = '{}';
                    cmp.set("v.selectedLookUpRecord1",selectedAcc);
                     cmp.set("v.refreshedCon", true)
                    
                }
            }
        }
        if(count === 2){
            console.log('test3 '+cmp.get("v.selectedLookUpRecord.Id"))
            var selectedAcc = cmp.get("v.selectedLookUpRecord.Id")
            cmp.set("v.AccountId",selectedAcc);
            
        }
        console.log('v.Counter'+count);
        count = count + 1;
        cmp.set("v.Counter",count);
        console.log('wwwww');
        console.log('Counter '+count);
        helper.Counter(cmp, event, count);
        console.log('Counter end'+count);
        
    },
    
    PreviousStep : function (cmp, event, helper) {
        
        if(cmp.get("v.selectedLookUpRecord1.Id") == null && cmp.get("v.selectedLookUpRecord1.Id") == null && cmp.get("v.Counter") == 4){
            cmp.set("v.Counter", 3)
        }
        if(cmp.get("v.selectedCaseRec") != null && cmp.get("v.Counter") == 5){
            cmp.set("v.Counter", 4);
            cmp.set("v.selectedCaseRec", null);
        }
        cmp.set("v.StepTwo", false);
        var count = cmp.get("v.Counter")-1;
        cmp.set("v.Counter",count);
        if(count === 1){
            console.log('test3 '+cmp.get("v.selectedLookUpRecord.Id"))
            var selectedAcc = cmp.get("v.selectedLookUpRecord.Id")
            cmp.set("v.AccountId",selectedAcc);
            
        }
        helper.Counter(cmp, event, count);
        
    },
    handleCaseDetailEvent:function(cmp, event, helper) {
        console.log("hello");
        var caseRec = event.getParam("selsObjRec");
        var SelectedCase = event.getParam("selectedCaseId");
        console.log('SelectedCase'+caseRec.AccountId);
        cmp.set("v.selectedCaseRec", caseRec); 
        console.log('cmp.get(v.AccountId)'+cmp.get("v.AccountId"));
        if(cmp.get("v.AccountId") === undefined){
            cmp.set("v.AccountId", caseRec.AccountId);
        }
        
        console.log("v.caseRec "+caseRec.Id);
        console.log("v.caseNumber "+caseRec.CaseNumber);
        console.log("selectedCaseRec "+cmp.get("v.selectedCaseRec"));
        cmp.set("v.caseId", caseRec.Id);
        cmp.set("v.caseNumber", caseRec.CaseNumber);
    },
    handleSubmit: function(cmp, event, helper) {
        helper.createCase(cmp, event);
    },
    handleSuccess: function(cmp, event) {
        
        var newCreatedCase = event.getParams().response;
        console.log('onsuccess: ', newCreatedCase);
        console.log('updatedRecord12: ', newCreatedCase);
        console.log('onsuccess111: ', newCreatedCase.id); 
        console.log('onsuccess111: ', newCreatedCase.fields.CaseNumber.value); 
        cmp.set("v.caseId", newCreatedCase.id);
        cmp.set("v.caseNumber", newCreatedCase.fields.CaseNumber.value);
        
        console.log("handleSuccess");
        if(cmp.get("v.caseId") != null){
            console.log("new case Id :" +cmp.get("v.caseId"));
            var count = cmp.get("v.Counter");
            console.log("v.Counter"+count);
            count = count + 1;
            cmp.set("v.Counter", count);
            console.log('wwwww');
            console.log('Counter '+ count);     
            cmp.set("v.StepTwo", false);
            console.log("v.StepTwo "+cmp.get("v.StepTwo"));
            cmp.set("v.StepOne", false);
            console.log("v.StepOne "+cmp.get("v.StepOne"));
            cmp.set("v.Stepthree", false);
            console.log("v.Stepthree "+cmp.get("v.Stepthree"));
            console.log("v.Stepthree");
            cmp.set("v.StepFour", false);
            cmp.set("v.StepFive", true);
            console.log("v.StepFour"+cmp.get("v.StepFour"));
            console.log("v.StepFive"+cmp.get("v.StepFive"));
            console.log('Counter end'+ count);
        }
    },
    
    CaseIdNumber:function(cmp, event){
        var selectedcaseId = cmp.get("v.caseId"); 
        var selectedcaseNumber = cmp.get("v.caseNumber");
        console.log(selectedRows[0].Id);
        var cmpCaseEvent = cmp.getEvent("CaseIdValue"); 
        cmpCaseEvent.setParams({"caseNumber" : selectedcaseNumber }); 
        cmpCaseEvent.setParams({"caseId" : selectedcaseId }); 
        console.log("Value set");
        cmpCaseEvent.fire();
    },
    
    hide : function(component,event,helper){
        var elements = document.getElementsByClassName("test2");
        elements[0].style.display = 'none';
    },
    
    show : function(component,event,helper){
        var elements = document.getElementsByClassName("test2");
        elements[0].style.display = 'block';
    }
    
    
    
    
    
})