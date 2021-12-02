({
    fetchAccHelper : function(component, event, helper) {
       
        component.set('v.mycolumns', [
            {label: 'Subscription Name', fieldName: 'Name', type: 'text'},
            {label: 'subscriptionId', fieldName: 'subscriptionId__c', type: 'text'},
            {label: 'Amount', fieldName: 'Amount__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }, currencyDisplayAs: "code" }},
            {label: 'Subscription Status', fieldName: 'SubscriptionStatus__c', type: 'text'},
            {label: 'SubscribedDate', fieldName: 'SubscribedDate__c', type: 'Date'},
            {label: 'subscriptionCMSId', fieldName: 'subscriptionCMSId__c', type: 'test'}
        ]);
        var action = component.get("c.getBuyerSubcription");
        action.setParams({
            "AccountId":component.get("v.recordId")
        });
        action.setCallback(this, function(response){
             var processSpinner = component.find("processSpinner");
            
            $A.util.addClass(processSpinner, "slds-show");
         	$A.util.removeClass(processSpinner, "slds-hide");
         
            var state = response.getState();
            if (state === "SUCCESS") {
                var subslit = response.getReturnValue();
          
                if(subslit.length === 0){
                    component.set("v.showNoFound", true);
                }
                component.set("v.acctList", response.getReturnValue());
            }
            
             $A.util.removeClass(processSpinner, "slds-show");
         	 $A.util.addClass(processSpinner, "slds-hide");
          
        });
        $A.enqueueAction(action);
       
    }
})