({
    doInit : function(component, event, helper) {
        var OpporunityId = component.get("v.recordId");
        helper.fetchListedAccountCon(component, event);
        component.set("v.columns", [
            {label: "Name", fieldName: "Name", type: "text"},
            {label: "Buyer Employee ID", fieldName: "Buyer_Employee_ID__c", type: "text"},
            {label: "Buyer ID", fieldName: "Buyer_ID__c", type: "text"}, 
           //{label: "Account Buyer status", fieldName: "Account_Buyer_Status__c", type: "text"}-->,
            {label: "Status Code", fieldName: "Status_Code__c", type: "text"}
            
        ]);
    },
    
    getNext : function(component, event, helper){
        
        var AccountDetail = component.find("AccountDetail");
        var datatable = component.find("datatable");
        var nextButtom = component.find("nextButtom");
        var Previous = component.find("Previous");
        var Submit = component.find("Submit");
        
        $A.util.removeClass(AccountDetail, "slds-show");
        $A.util.removeClass(datatable, "slds-hide");
        $A.util.removeClass(Submit, "slds-hide");
        $A.util.removeClass(Previous, "slds-hide");
        $A.util.removeClass(nextButtom, "slds-show");
        
        $A.util.addClass(AccountDetail, "slds-hide");
        $A.util.addClass(datatable, "slds-show");
        $A.util.addClass(Submit, "slds-show");
        $A.util.addClass(Previous, "slds-show");
        $A.util.addClass(nextButtom, "slds-hide");
        
    },
    getPrevious : function(component, event, helper){ 
        var AccountDetail = component.find("AccountDetail");
        var datatable = component.find("datatable");
        var nextButtom = component.find("nextButtom");
        var Previous = component.find("Previous");
        var Submit = component.find("Submit");
        
        $A.util.addClass(AccountDetail, "slds-show");
        $A.util.addClass(datatable, "slds-hide");
        $A.util.addClass(Submit, "slds-hide");
        $A.util.addClass(Previous, "slds-hide");
        $A.util.addClass(nextButtom, "slds-show");
        
        $A.util.removeClass(AccountDetail, "slds-hide");
        $A.util.removeClass(datatable, "slds-show");
        $A.util.removeClass(Submit, "slds-show");
        $A.util.removeClass(Previous, "slds-show");
        $A.util.removeClass(nextButtom, "slds-hide");
        
        
        
    },
    handleRowSelection : function(component, event, helper){
        var selRows = event.getParam("selectedRows");
        component.set("v.selectedRows",selRows);
        for(var i in selRows){
            var selectedR = component.get("v.selectedRows");
            console.log(selectedR.length);
            console.log(selRows[i].Id+" "+selRows[i].Name+" "+selRows[i].Buyer_Employee_ID__c)
        }
        console.log(component.get("v.selectedRows").length);
    },
    handleSubmit : function(component, event, helper){
    },
    handleOpenModal: function(component, event, helper) {
        console.log("handleOpenModal");
        component.set("v.isModalOpen", true);
    },
    
    handleCloseModal: function(component, event, helper) {
        console.log("handleCloseModal");
        component.set("v.isModalOpen", false);
       
         var convertedSuccessFully = component.get("v.IsMessage");
        if(convertedSuccessFully === true){
            window.location.reload();
            
        }  
        
    },
    selectedAddBroker : function(component, event, helper){
        var addBrokerFee = (component.find("AddBrokerFee"));
        var isaddBrokerFee = component.get("v.isAddBrokerFee");
        console.log(addBrokerFee);
        console.log(isaddBrokerFee);
    },
    creakeBroker : function(component, event, helper){
        console.log('creakeBroker');
        helper.createBrokerASAP(component, event);
        console.log('creakeBroker1');
          //window.location.reload();
          $A.get('e.force:refreshView').fire();
       // component.set("v.isModalOpen", false);
        
        
        
        
        
         
    },
    
    handleExit : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        var convertedSuccessFully = component.get("v.IsMessage");
        if(convertedSuccessFully === true){
            window.location.reload();
            
        }
    }
})