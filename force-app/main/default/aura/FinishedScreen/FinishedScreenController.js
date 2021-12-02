({
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
        $A.get('e.force:refreshView').fire();
    },
    
    openCaseDetail: function(cmp, event, helper){
        console.log(cmp.get("v.caseId"));
        var recordId = cmp.get("v.caseId");
        
        
        var navService = cmp.find("navService");
        var pageReference = {    
            "type": "standard__recordPage", //example for opening a record page, see bottom for other supported types
            "attributes": {
                "recordId": recordId, //place your record id here that you wish to open
                "actionName": "view"
            }
        }
        console.log('error: ' );
        navService.generateUrl(pageReference).then($A.getCallback(function(url) {
            console.log('error:1' );
            console.log('success: ' + url); //you can also set the url to an aura attribute if you wish
            //window.open(url,'_blank');
            window.open(url,'_self');
            
        }), 
            $A.getCallback(function(error) {
              console.log('error: ' + error);}));
        
    },
    
    handleCaseDetailEvent:function(cmp, event, helper) {
        console.log("hello Final Screen");
        var caseRec = event.getParam("selsObjRec");
        var SelectedCase = event.getParam("selectedCaseId");
        cmp.set("v.selectedCaseRec", caseRec); 
        console.log("v.caseRec "+caseRec.Id);
        console.log("v.caseNumber "+caseRec.CaseNumber);
        console.log("selectedCaseRec "+cmp.get("v.selectedCaseRec"));
        cmp.set("v.caseId", caseRec.Id);
        cmp.set("v.caseNumber", caseRec.CaseNumber);
    },
})