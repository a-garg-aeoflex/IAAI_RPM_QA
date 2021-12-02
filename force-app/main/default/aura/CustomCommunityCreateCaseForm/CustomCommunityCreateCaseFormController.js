({
    itemsChange : function(component, event, helper) {           
           var appEvent = $A.get("e.selfService:caseCreateFieldChange");
        console.log('  event.getSource().get("v.fieldName") '+event.getSource().get("v.fieldName"));
        console.log('  event.getSource().get("v.value") '+event.getSource().get("v.value"));
           appEvent.setParams({
               "modifiedField": event.getSource().get("v.fieldName"),
               "modifiedFieldValue": event.getSource().get("v.value")
           });
   
           appEvent.fire();
        },
    getValueFromLwc : function(component, event, helper) {
        console.log("wellcom");
        console.log("wellcomeee "+ event.getParam('Dvalue'));
		component.set("v.inputValue", event.getParam('Dvalue'));
        component.get("v.inputValue");
	
     var appEvent = $A.get("e.selfService:caseCreateFieldChange");
        console.log('  event.getSource().get("v.fieldName") '+event.getSource().get("v.fieldName"));
        console.log('  event.getSource().get("v.value") '+event.getSource().get("v.value"));
           appEvent.setParams({
               "modifiedField": "Description",
               "modifiedFieldValue": component.get("v.inputValue")
           });
        appEvent.fire();
    },
    handleFilterChange: function(component, event) {
		console.log("wellcome");  
        var filters = event.getParam('filters');
        component.set('v.message', filters.length > 0 ? 'Your selection: ' + filters.join() : 'No selection');
    },
   })