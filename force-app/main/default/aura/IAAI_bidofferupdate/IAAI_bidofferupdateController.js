({
    handleLoad: function(component, event, helper) {
       var bplam = component.find("inputCmp").get('v.value');
       
        if(bplam != null || bplam > 0){
             component.find("massupdatecb").set("v.disabled", true);
             component.find("inputCmp").set("v.disabled", true);
             component.find("submit").set("v.disabled", true);
        }
    },
	updateBidOfferAmount : function(component, event, helper) {
		
        var sfdcid = component.find("sfdcid").get("v.value");
        var bpllistingid = component.find("listingid").get("v.value");
        var bplamount = component.find("inputCmp").get("v.value");
        
	 	var action = component.get("c.bidOffer");  
        action.setParams({
            "sfdcid" : sfdcid,
            "listingId": bpllistingid,
            "amountValue" : bplamount
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS"){
                 if(response.getReturnValue()){
                     var toastEvent = $A.get("e.force:showToast");
                     //alert("success");
                     toastEvent.setParams({
                         "title": "Success!",
                         "type": "success",
                         "message": "Offer/Bid Submitted!"
                     });
                     toastEvent.fire();
                     component.find("recordEditForm").submit();
                     var myEvent1 = $A.get("e.c:BidRefresh");
                     myEvent1.fire();
                 }else{
                     var toastEvent = $A.get("e.force:showToast");
                     //alert("Error");
                     toastEvent.setParams({
                         "title": "Error!",
                         "type": "error",
                         "message": "Offer/Bid could not Submit, please try again!"
                     });
                     toastEvent.fire();
                 }
            }
        });
        	$A.enqueueAction(action);
      
	},
    callChildMethod : function(component, event, helper) {
         var bpllistingid = component.find("massupdatecb").get('v.checked');
         
        if(bpllistingid){
        	var a = component.get('c.updateBidOfferAmount');
        	$A.enqueueAction(a);
        }
    },
     checkboxSelect: function(component, event, helper) {
        var selectedRec = component.find("massupdatecb").get('v.checked');
         
        var myEvent = $A.get("e.c:MSCountEvent");
        if (selectedRec == true) {
         myEvent.setParams({"selected" : "True"});
         } else{
         myEvent.setParams({"selected" : "False"});
        }
        myEvent.fire();
    }
    
})