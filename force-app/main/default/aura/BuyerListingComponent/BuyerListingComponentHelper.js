({
    getBuyerListingList: function(component, pageNumber, pageSize, vpePartnerid, value, startId, endId, type) {
        
        var action = component.get("c.getBuyerPortalData");
        action.setParams({
            "pageNumber": pageNumber,
            "pageSize": pageSize,
            "vpePartnerId" : vpePartnerid,
            "listingStatuses" : value,
            "startId":startId.toString(),
            "endId":endId.toString(),
            "type" : type.toString()
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue();  
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd); 
                component.set("v.PageCounter", resultData.PageCounter);
                component.set("v.TotalPages", Math.ceil(resultData.totalRecords / pageSize));
               
                
                		console.log('---AB0---'+resultData.buyerListingList);
                		console.log('---AB1---'+resultData.totalRecords);
                
                if(resultData.buyerListingList != null && resultData.totalRecords > 0){
                    var data = resultData.buyerListingList;
                		
                        if(data[0].Id > data[data.length -1].Id){
                            data.reverse();
                        }
                        component.set("v.BuyerPortalList", data);
                        var lst = resultData.buyerListingList;
                        component.set("v.startId", lst[0].Id); 
                        component.set("v.endId", lst[lst.length -1].Id); 
                }else{
                    component.set("v.BuyerPortalList", null);
                }
                
                component.set("v.Spinner", false);

            }
        });
        $A.enqueueAction(action);
    },
    
    getVPEPartnerList: function(component, pageNumber, pageSize) {
        var action = component.get("c.getListingPartnertList");
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
                var resultData = result.getReturnValue(); 
                component.set("v.vpePartners", resultData);
            }
         });
        $A.enqueueAction(action);
    },
    
     //Footer methods
     /*getPageCountAndTotal : function(component,rCount) {
		var action = component.get("c.getPageCountInfo");
        action.setParams({
            "pageCountInfo" : rCount
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                component.set("v.pageCounterInfo", response.getReturnValue());                
            }
        });
        $A.enqueueAction(action);
	},*/    
    
    showToast: function(title, type, message) {
		var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message
        });
        toastEvent.fire();
    },
    toggleHelper : function(component,event) {
    var toggleText = component.find("tooltip");
    $A.util.toggleClass(toggleText, "toggle");
   }
})