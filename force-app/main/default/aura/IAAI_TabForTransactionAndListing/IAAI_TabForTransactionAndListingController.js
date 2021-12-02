({
    onInit: function(component, event, helper) {
        helper.getUserMethod(component);
        $A.enqueueAction(component.get('c.getDealerInfoMethod'));
    },
    handleLogOut: function(component, event, helper) {
        window.location.replace("/bolton/secur/logout.jsp");
    },

    openVideo: function(component, event, helper) {
        component.set("v.showVideo", true);
    },
    closeModel: function(component, event, helper) {
        component.set("v.showVideo", false);
    },
    onCheck: function(component, event, helper) {
        if (component.find("checkbox").get("v.value")) {
            component.find('saveButton').set('v.disabled', false);
        } else {
            component.find('saveButton').set('v.disabled', true);
        }
    },

    onSave: function(component, event, helper) {
        component.find('saveButton').set('v.disabled', true);
        var action = component.get("c.acceptTermsAndConditions");
        action.setParams({});
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.find('saveButton').set('v.disabled', false);
            if (state == "SUCCESS") {
                if (response.getReturnValue().success) {
                    component.set("v.submitbid", false);
                }
            }
        });
        $A.enqueueAction(action);
    },

    getDealerInfoMethod: function(component, event, helper) {
        var recId = component.get("v.userid");
        var action = component.get("c.getDealerInfo");
        action.setParams({
            'userId': recId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(response.getError());
            console.log(response.getReturnValue());
            if (state == "SUCCESS") {
                if (response.getReturnValue() == true) {
                    component.set("v.submitbid", false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    downloadCSVTemplate: function(component, event, helper) {
        event.preventDefault();
        let csv = 'Provider First Name,Provider Last Name,VIN,Vehicle Condition Grade,Make,Model,Year,Mileage,Vehicle Image,Pickup Phone Number, Street,Pickup City,Pickup State,Pickup Zip Code,Has Keys?,Notes\n';
        let hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_blank';
        hiddenElement.download = 'listing_template_' + Date.now() + '.csv';
        hiddenElement.click();
    },
    refreshListing: function(component, event, helper) {

    }
})