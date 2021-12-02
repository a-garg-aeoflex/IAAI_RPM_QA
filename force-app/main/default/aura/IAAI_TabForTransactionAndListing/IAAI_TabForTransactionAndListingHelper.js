({
    getUserMethod: function(component) {
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log(storeResponse);
                component.set("v.uname", storeResponse.username);
                component.set("v.submitbid", !storeResponse.contact[0].Terms_and_Conditions__c);
                let consentCmp = component.find("consent");
                consentCmp.set("v.value", (storeResponse.globalPartner.length > 0) ? storeResponse.globalPartner[0].Bolt_on_Consent__c : 'Consent Not Found');
            }
        });
        $A.enqueueAction(action);
    }

})