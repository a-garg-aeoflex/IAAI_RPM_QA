({
    doInit: function(component, event, helper) {
        var rCount = '';
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value"); 
        component.find("vpepartnerdd").set("v.value", 'All');
        var vpeId = component.find("vpepartnerdd").get("v.value"); 
        var value = component.get("v.selectedplvalues");
        
        helper.getBuyerListingList(component, pageNumber, pageSize,vpeId,value.toString(),component.get("v.startId"),component.get("v.endId"),"init");
        helper.getVPEPartnerList(component, pageNumber, pageSize);
    },
    
    
    goNextPage: function(component, event, helper) {
        var totalPages = component.get("v.pageCounterInfo.totalPages");
        var value = component.get("v.selectedplvalues");
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        var vpeId = component.find("vpepartnerdd").get("v.value"); 
        pageNumber++;
        helper.getBuyerListingList(component, pageNumber, pageSize,vpeId,value.toString(),component.get("v.startId"),component.get("v.endId"),"next");
        component.set("v.Spinner", false);
        document.getElementById("scrollbar").scrollTop = 0;
        window.scrollTo(0, 0);
    },
    
    goPreviousPage: function(component, event, helper) {
        var totalPages = component.get("v.pageCounterInfo.totalPages");
        var value = component.get("v.selectedplvalues");
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        var vpeId = component.find("vpepartnerdd").get("v.value"); 
        pageNumber--;
        helper.getBuyerListingList(component, pageNumber, pageSize,vpeId,value.toString(),component.get("v.startId"),component.get("v.startId"),"pre");
        component.set("v.Spinner", false);
        document.getElementById("scrollbar").scrollTop = 0;
        window.scrollTo(0, 0);
    },
    
    pageChangebtn: function (component, event, helper) {
        var pg = event.getSource().get("v.label");
        var value = component.get("v.selectedplvalues");
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        var totalPages = component.get("v.pageCounterInfo.totalPages");
        var vpeId = component.find("vpepartnerdd").get("v.value"); 
        if(pg != pageNumber){
            var diff = (parseInt(event.getSource().get("v.label"))-1) - parseInt(pageNumber);
            helper.getBuyerListingList(component, pg, pageSize,vpeId,value.toString(),component.get("v.startId"),component.get("v.endId"),diff.toString());
        }
        component.set("v.Spinner", false);
        document.getElementById("scrollbar").scrollTop = 0;
        window.scrollTo(0, 0);
    },
    
    onPageChange: function(component, event, helper) {
        var value = component.get("v.selectedplvalues");
        var pageNumber = component.get("v.PageNumber"); 
        var pageSize = component.find("pageSize").get("v.value");
        var vpeId = component.find("vpepartnerdd").get("v.value"); 
        helper.getBuyerListingList(component, pageNumber, pageSize,vpeId,value.toString());
    },
    
    refreshCheckbox: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        var vpeId = component.find("vpepartnerdd").get("v.value"); 
        component.set("v.MSCheckBoxCount",0)
        helper.getBuyerListingList(component, pageNumber, pageSize,vpeId,'');
    },
    
    onSelectChange: function(component, event, helper) {
        var value = component.get("v.selectedplvalues");
        var page = 1;
        var pageSize = component.find("pageSize").get("v.value");
        var vpeId = component.find("vpepartnerdd").get("v.value");
        helper.getBuyerListingList(component, page, pageSize,vpeId,value.toString(),component.get("v.startId"),component.get("v.endId"),'init');
    },
    
    viewDetail: function(component, event, helper) {
        var eventSource = event.getSource();
        var bplObject = eventSource.get('v.name');
        var imgurl = eventSource.get('v.value');
        component.set("v.listingID",bplObject);
        if(imgurl != undefined){
            component.set("v.ImgSrc",imgurl);
        }else{
            component.set("v.ImgSrc",'https://iaaicsr--traderev--c.visualforce.com/resource/1572977906000/dummyImage');
        }
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component,event,helper){   
        component.set("v.Spinner", false);
    },
    
    getMarketValue: function(component, event, helper) {
        var eventSource = event.getSource();
        var bplObject = eventSource.get('v.name');
        var action = component.get("c.fetchValueAndUpdateRecord");
        action.setParams({
            "st": bplObject
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
				var buyerPortalListTempParsed = JSON.parse(JSON.stringify(component.get("v.BuyerPortalList")));
                buyerPortalListTempParsed.forEach((record, index) => {
                    if( record.Id === bplObject ) {
                        buyerPortalListTempParsed[index]['Average_Sale_Price__c'] = result.getReturnValue().Average_Sale_Price__c;
                        buyerPortalListTempParsed[index]['Highest_Sale_Price__c'] = result.getReturnValue().Highest_Sale_Price__c;
                        buyerPortalListTempParsed[index]['Lowest_Sale_Price__c'] = result.getReturnValue().Lowest_Sale_Price__c;
                        buyerPortalListTempParsed[index]['Most_Recent_Sale_Date__c'] = result.getReturnValue().Most_Recent_Sale_Date__c;
                        buyerPortalListTempParsed[index]['Primary_Damage__c'] = result.getReturnValue().Primary_Damage__c;
                    	buyerPortalListTempParsed[index]['Vehicle_Condition_Grade__c'] = result.getReturnValue().Vehicle_Condition_Grade__c;
                        component.set("v.BuyerPortalList", buyerPortalListTempParsed);
                    }
                })
            }
        });
        $A.enqueueAction(action);
    },
    
    getPredictiveValue: function(component, event, helper){
        var action = component.get("c.getPredictivePrice");
        action.setParams({
            "listingId": event.getSource().get("v.name")
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS"){
				var buyerPortalListTempParsed = JSON.parse(JSON.stringify(component.get("v.BuyerPortalList")));
                buyerPortalListTempParsed.forEach((record, index) => {
                    if( record.Id === event.getSource().get("v.name") ) {
                    	record.Predicted_Price__c = result.getReturnValue().Predicted_Price__c;
                    	record.Original_Bid_Offer_Amount__c = result.getReturnValue().Original_Bid_Offer_Amount__c;
                    console.log('orig--->>',result.getReturnValue().Original_Bid_Offer_Amount__c);
                    console.log('pre--->>',result.getReturnValue().Predicted_Price__c);
                    }
                });
                component.set("v.BuyerPortalList", buyerPortalListTempParsed);
            }
        });
        $A.enqueueAction(action);
    },
    
    callChild : function(component, event, helper) {
        var childComp = component.find('childComp');
        for(var i = 0;i < childComp.length;i++){
            childComp[i].callChild();
        }
    },
    
    onPartnerChange: function(component, event, helper) {
        var value = component.get("v.selectedplvalues");
        var pageNumber = 1; 
        var pageSize = component.find("pageSize").get("v.value");
        var vpeId = component.find("vpepartnerdd").get("v.value"); 
        helper.getBuyerListingList(component, pageNumber, pageSize,vpeId,value.toString(),component.get("v.startId"),component.get("v.endId"),'init');
    },
    
    handleMyApplicationEvent : function(component, event, helper) {
        var value = event.getParam("selectedplvalues");
        var pageNumber = 1;  
        var pageSize = component.find("pageSize").get("v.value");
        var vpeId = component.find("vpepartnerdd").get("v.value");
        component.set("v.selectedplvalues", value);
        helper.getBuyerListingList(component, pageNumber, pageSize,vpeId,value.toString(),component.get("v.startId"),component.get("v.endId"),'init');
        component.set("v.Spinner", false);
    },
    
    handleMSComponentEvent: function(component, event, helper) {
        var message = event.getParam("selected"); 
        var MSCBCount = component.get("v.MSCheckBoxCount"); 
        if(message == "True"){
            MSCBCount++;
            component.set("v.MSCheckBoxCount",MSCBCount);
        }else if(message == "False"){
            MSCBCount--;
            component.set("v.MSCheckBoxCount",MSCBCount);
        }
        if(MSCBCount > 9){
            var a = component.get('c.openModel');
            $A.enqueueAction(a);
        }
    },
    
    bidRefreshEvent: function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");  
        var pageSize = component.find("pageSize").get("v.value");
        var vpeId = component.find("vpepartnerdd").get("v.value"); 
        helper.getBuyerListingList(component, pageNumber, pageSize,vpeId,'');
    },
    
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    updateBidOfferAmount : function(component, event, helper) {
        event.preventDefault();
        var data = JSON.parse(JSON.stringify(event.getParams().fields));
        console.log(data);
        var sfdcid = data.tempId;
        var bplamount = data.Original_Bid_Offer_Amount__c;
        var bpllistingid = data.Listing_Id__c;
        
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
                    
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "Offer/Bid Submitted!"
                    });
                    toastEvent.fire();
                    
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    
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
    
    inputChangeHandler: function(component, event, helper) {
        component.set("v.bidOfferInputValue", event.detail.value);
    },
    
    bidOfferSubmitHandler: function(component, event, helper){
        var startingBidToBeSend,topBidToBeSend,auctionId;
        if( event.target.dataset.hasOwnProperty('topbid') === false ) {
            topBidToBeSend = 0;
        } else {
            topBidToBeSend = parseInt(event.target.dataset.topbid);
        }
        if( event.target.dataset.hasOwnProperty('startingbid') === false ) {
            startingBidToBeSend = 0;
        } else {
            startingBidToBeSend = parseInt(event.target.dataset.startingbid);
        }
        if( topBidToBeSend > startingBidToBeSend  ) {
            startingBidToBeSend = parseInt(event.target.dataset.topbid)+100;
        } 
        if( event.target.dataset.hasOwnProperty('auctionid') === false ) {
            var auctionId = 'NOT_AVAILABLE';
        } else {
            var auctionId = event.target.dataset.auctionid;
        }
        var sfdcid = event.target.dataset.sfdcid;
        var bplamount = parseInt(event.target.dataset.amount);
        var bpllistingid = event.target.dataset.listingid;
        var buyerPortalListTemp = component.get("v.BuyerPortalList");
        var buyerPortalListTempParsed = JSON.parse(JSON.stringify(buyerPortalListTemp));
        if( event.target.dataset.partner === 'TRADEREV' ) {
            if( event.target.dataset.hasOwnProperty('auctionexpirytime') === true && event.target.dataset.hasOwnProperty('status') === true ) {
                var currentTime = new Date();
                var auctionExpiryTime = new Date(event.target.dataset.auctionexpirytime);
                if( auctionExpiryTime < currentTime ) {
                    helper.showToast('ERROR!', 'error', 'Sorry, this listing is no longer valid.');
                }
            } else {
                var action = component.get("c.makeTraderevBid");
                action.setParams({
                    "sfdcid" : sfdcid,
                    "listingId": bpllistingid,
                    "amountValue" : bplamount,
                    "minStartingBid" : startingBidToBeSend,
                    "auctionId" : auctionId
});
                action.setCallback(this, function(response) {
                var state = response.getState();
                if (component.isValid() && state === "SUCCESS"){
                    console.log(response.getReturnValue().indexOf('requestId'));
                    if(response.getReturnValue().indexOf('requestId') >= 0){
                        setTimeout(function() {
                            var action = component.get("c.getBidResult");
                            action.setParams({
                                "requestId": response.getReturnValue()
                            });
                            action.setCallback(this, function(result) {
                                var state = result.getState();
                                if (component.isValid() && state === "SUCCESS"){
                                    if( result.getReturnValue() ) {
                                        var fetchResult = JSON.parse(result.getReturnValue());
                                        if( fetchResult.hasOwnProperty('resultList') ) {
                                            if( fetchResult.resultList[0].status === 'failed' ) {
                                                helper.showToast("ERROR!","error",fetchResult.resultList[0].errorMessage);
                                            }
                                            else {
                                                var action = component.get("c.saveBidValue");
                                                    action.setParams({
                                                    "recordId": sfdcid,
                                                    "bidValue": bplamount
                                                });
                                                action.setCallback(this, function(result) {
                                                    var state = result.getState();
                                                    if (component.isValid() && state === "SUCCESS"){
                                                        if( result.getReturnValue() ) {
                                                            helper.showToast("SUCCESS!","success","Bid Accepted Successfully");
                                                            buyerPortalListTempParsed.forEach((record, index) => {
                                                                if( record.Id === sfdcid ) {
                                                                buyerPortalListTempParsed[index]['Bid_Offer_Submitted__c'] = true;
                                                                buyerPortalListTempParsed[index]['Status_of_Listing__c'] = 'Pending';
                                                                component.set("v.BuyerPortalList", buyerPortalListTempParsed);
                                                            }
                                                                                              })
                                                        }
                                                    }
                                                });
                                                $A.enqueueAction(action);
                                            }   
                                        } else {
                                            helper.showToast("ERROR!","error",fetchResult);
                                        }
                                    }
                                }
                            });
                            $A.enqueueAction(action);
                    }, 3000);
                    	helper.showToast('INFORMATION!','information','Please wait while we process your Bid');
                    }
                    else
                    {
                        helper.showToast('ERROR!','error',response.getReturnValue());
                    }
                }
                else
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type": "error",
                        "message": "Offer/Bid could not Submit, please try again!"
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(action);
            }
		 } 
        else if ( event.target.dataset.partner === 'CARVIO' ) {
            var action = component.get("c.bidOffer");
            action.setParams({
                "sfdcid" : sfdcid,
                "listingId": bpllistingid,
                "amountValue" : bplamount,
                "minStartingBid" : 0,
                "auctionId" : ""
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (component.isValid() && state === "SUCCESS"){
                    if(response.getReturnValue()){
                        buyerPortalListTempParsed.forEach((record, index) => {
                            if( record.Id === sfdcid ) {
                            buyerPortalListTempParsed[index]['Bid_Offer_Submitted__c'] = true;
                            component.set("v.BuyerPortalList", buyerPortalListTempParsed);
                        }
                                                          })
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "Offer/Bid Submitted!"
                        });
                        toastEvent.fire();
                        
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": "Offer/Bid could not Submit, please try again!"
                        });
                        toastEvent.fire();
                    }
                } else {
                    helper.showToast('ERROR!', 'error', 'CARVIO not responding, Please try again after sometime');
                }
            });
            $A.enqueueAction(action);   
         }
        else {
            var action = component.get("c.bidOffer");
            action.setParams({
                "sfdcid" : sfdcid,
                "listingId": bpllistingid,
                "amountValue" : bplamount,
                "minStartingBid" : 0,
                "auctionId" : ""
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (component.isValid() && state === "SUCCESS"){
                    if(response.getReturnValue()){
                        buyerPortalListTempParsed.forEach((record, index) => {
                            if( record.Id === sfdcid ) {
                                buyerPortalListTempParsed[index]['Bid_Offer_Submitted__c'] = true;
                                component.set("v.BuyerPortalList", buyerPortalListTempParsed);
                            }
                        })
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": "success",
                            "message": "Offer/Bid Submitted!"
                        });
                        toastEvent.fire();
                    }
                    else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": "Offer/Bid could not Submit, please try again!"
                        });
                        toastEvent.fire();
                    }
                } else {
                    helper.showToast('ERROR!', 'error', 'CARVIO not responding, Please try again after sometime');
                }
            });
            $A.enqueueAction(action);   
        }
    },
    
    display : function(component, event, helper) {
    var elements = document.getElementsByClassName("tooltip1");
        elements[0].style.display = 'block';
  },

  displayOut : function(component, event, helper) {
   var elements = document.getElementsByClassName("tooltip1");
        elements[0].style.display = 'none';
  }
})