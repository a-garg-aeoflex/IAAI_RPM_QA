({
    fetchListedAccountCon: function(component, event) {
        console.log('fetchListedAccoountCon');
        var action = component.get("c.fetchAccountCon");
        action.setParams({
            "OppId":component.get("v.recordId")
        });
        var contactsList = [];
        action.setCallback(this, function(response) {
            console.log('fetchListedAccoountCon setCallback');
            console.log('fetchListedAccoountCon response.getState() '+response.getState());
            if (response.getState() == "SUCCESS") {
                var Account = response.getReturnValue();
                console.log('allValues '+response.getReturnValue())
                //console.log('Account length '+Account.lstCon.length)
                console.log('Account.objAccount '+Account.objAccount);
                console.log('Account.objAccount '+Account.objAccount.Id)
                //console.log('Account.lstCon '+Account.lstCon[0].Id)
                if (Account !== undefined &&  Account !== null) {
                    component.set("v.Account", Account.objAccount);
                    if(!Account.objAccount.Is_Broker_Created__c){
                        component.set("v.isSuccess",true);
                        
                        
                    }else{
                        
                        component.set("v.isAlreadyConverted",true)
                    }
                    if(Account.lstCon !== undefined && Account.lstCon !== null && Account.lstCon.length > 0){
                        contactsList = Account;
                        var contact = Account.lstCon[0];
                        console.log(contact.Account_buyer_status__c +' '+contact.AccountBuyerStatus__c);
                        component.set("v.contactList", Account.lstCon);
                    }
                }
            }else if(response.getState() === "ERROR"){
                console.log('Error Occured');
                
                
            }
        });
        // component.set("v.contactList", contactsList);
        console.log('test'+ component.get("v.contactList"));
        component.set("v.isLoading", false);
        $A.enqueueAction(action);
    },
    createBrokerASAP: function(component, event) {
        console.log('createBrokerASAP');
        var accountBuyerId = component.get("v.Account").BI_ID__c;
        
       // console.log(accountBuyerId);
        if(accountBuyerId !== undefined && accountBuyerId.startsWith("BUY-")){
            var perfixBuy = accountBuyerId.split("-");
            accountBuyerId = perfixBuy[1];
            console.log(accountBuyerId);
        }
        var selectedRows = component.get("v.selectedRows");
        console.log(selectedRows);
        var employerIds =[];
        for(var i in selectedRows){
            employerIds[i] = parseInt(selectedRows[i].Buyer_Employee_ID__c);
        }
        var action = component.get("c.creakeBrokerService");
        action.setParams({
            "AddBrokerFee":component.get("v.isAddBrokerFee"),
            "LicenseBuyerID":accountBuyerId,
            "EmployeeIDs" : employerIds,
            "OppId":component.get("v.recordId")
            
        });
        var contactsList = [];
        var ProcessWait = component.find("processSpinner");
        $A.util.removeClass(ProcessWait, "slds-hide");
        $A.util.addClass(ProcessWait, "slds-show");
        action.setCallback(this, function(response) {
            console.log('fetchListedAccoountCon setCallback');
            var status = response.getState();            
            var toastEvent = $A.get("e.force:showToast");
            var ResponseResult;
            if(status === "SUCCESS"){
                ResponseResult = response.getReturnValue();
                console.log('ResponseResult.ErrorCode '+ResponseResult.ErrorCode);
                console.log('ResponseResult.ErrorDescription '+ResponseResult.ErrorDescription);
                console.log('ResponseResult.NewBuyerID '+ResponseResult.NewBuyerID);
                console.log(status === "SUCCESS");             
                component.set("v.isSuccess", false);
                component.set("v.isAlreadyConverted",false);
                console.log(status === "SUCCESS");
                if(ResponseResult.ErrorCode === '000'){
                    toastEvent.setParams({                    
                        title : "Success!",
                        message: "Buyer is converted to broker: "+ ResponseResult.NewBuyerID+" "+"successfully.",                    
                        duration:"500",
                        key: "info_alt",
                        type: "success",
                        mode: "dismissible"
                    });
                }else{
                    toastEvent.setParams({                    
                        title : "Failed!",
                        message: "Error Occured while converting the buyer. Error: "+ResponseResult.ErrorDescription,                    
                        duration:"5",
                        key: "info_alt",
                        type: "Error",
                        mode: "dismissible"
                    });                
                }
                
                console.log(status === "SUCCESS");
                //toastEvent.fire();
                
            }else if(status === "ERROR"){
                var message = errors[0].message;
                console.log('test');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({                    
                    title : "Failed!",
                    message: message+"Buyer is converted to broker successfully.",                    
                    duration:"5",
                    key: "info_alt",
                    type: "Error",
                    mode: "dismissible"
                });                
                
                console.log(message);
            }
            console.log('this done1');
            $A.util.removeClass(ProcessWait, "slds-show");
            $A.util.addClass(ProcessWait, "slds-hide");
            console.log('this done2');
            toastEvent.fire();
            console.log('this done3');
            
            component.set("v.IsMessage", true);
            component.set("v.isModalOpen", false);
            $A.get('e.force:refreshView').fire();
            console.log('this done4');
        });
        $A.enqueueAction(action);
    },
    
    
})