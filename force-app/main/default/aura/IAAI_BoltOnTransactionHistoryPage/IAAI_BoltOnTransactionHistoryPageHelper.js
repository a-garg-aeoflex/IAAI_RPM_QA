({

    fetchVPE: function(component, pageNumber, pageSize) {
        component.set("v.userid", $A.get("$SObjectType.CurrentUser.Id"));
        var action = component.get("c.fetchVPEListing");
        var userid = component.get("v.userid").toString();
        action.setParams({
            'pageSize': pageSize,
            'pageNumber': pageNumber,
            'userid': userid
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                var data1 = response.getReturnValue().buyerListingList;
                var modifyData = [];
                for (var i = 0; i < data1.length; i++) {
                    modifyData[i] = data1[i];
                    if (data1[i].Contact__c == undefined) {} else {
                        modifyData[i].CreatedByName = data1[i].Contact__r.Name;
                    }
                    modifyData[i].isaActive = false;
                    modifyData[i].acceptStatus = "Accept Offer";

                    if (modifyData[i].Accept_Offer__c == true) {

                        modifyData[i].isaActive = true;
                        modifyData[i].acceptStatus = "Accepted";

                    } else if (modifyData[i].Bolt_On_Bid_Amount__c == undefined) {

                        modifyData[i].isaActive = true;
                        modifyData[i].acceptStatus = "No Offer";

                    } else if (modifyData[i].Bolt_On_Bid_Amount__c != undefined && modifyData[i].Bid_Offer_Submitted__c == false) {
                        //modifyData[i].Bolt_On_Bid_Amount__c = '';
                        modifyData[i].isaActive = true;
                        modifyData[i].acceptStatus = "No Offer";
                    } else {
                        modifyData[i].isaActive = false;
                        modifyData[i].acceptStatus = "Accept Offer";
                    }

                }
                data1.forEach(element => {
                    if (element.Status_of_Listing__c === 'Pending') {
                        element.Status_of_Listing__c = 'Offer Made';
                        element.buttonLabel = 'Accept Offer';
                        element.iconName = 'utility:info';
                        element.iconVariant = 'error';
                    } else if (element.Status_of_Listing__c === 'Won') {
                        element.Status_of_Listing__c = 'Offer Accepted';
                        element.buttonLabel = 'Offer Accepted';
                        element.iconName = 'utility:info';
                        element.iconVariant = 'error';
                        element.disabled = 'disabled';
                    } else if (element.Status_of_Listing__c === 'Lost') {
                        element.Status_of_Listing__c = 'Offer Rejected';
                        element.buttonLabel = 'Offer Rejected';
                        element.iconName = 'utility:info';
                        element.iconVariant = 'error';
                        element.disabled = 'disabled';
                    } else {
                        element.Status_of_Listing__c = 'Pending';
                        element.buttonLabel = 'Accept Offer';
                        element.Original_Bid_Offer_Amount__c = 0.00;
                        element.iconName = 'utility:info';
                        element.iconVariant = 'error';
                        element.disabled = 'disabled';
                    }
                });
                component.set("v.vpeList", data1);
                component.set("v.PageNumber", data.pageNumber);
                component.set("v.TotalRecords", data.totalRecords);
                component.set("v.RecordStart", data.recordStart);
                component.set("v.RecordEnd", data.recordEnd);
                component.set("v.TotalPages", Math.ceil(data.totalRecords / pageSize));
            }
        });
        $A.enqueueAction(action);
    },

    getColumns: function(component) {

        component.set('v.mycolumns', [
            { label: 'Name', fieldName: 'Name', type: 'text', },
            { label: 'VIN', fieldName: 'VIN__c', type: 'text' },
            { label: 'Make', fieldName: 'Make__c', type: 'text' },
            { label: 'Model', fieldName: 'Model__c', type: 'text' },
            { label: 'Year', fieldName: 'Model_Year__c', type: 'text' },
            { api: 'CreatedDate', label: 'Created Date', fieldName: 'CreatedDate', type: 'date' },
            { label: 'Created By', fieldName: 'CreatedByName' },
            { label: 'Offer', fieldName: 'Bolt_On_Bid_Amount__c', type: 'currency', cellAttributes: { alignment: 'left' } },
            {
                label: 'Accept Offer',
                type: "button",
                typeAttributes: {
                    label: { fieldName: 'acceptStatus' },
                    name: 'Accept_Offer',
                    title: 'Accept Offer',
                    variant: 'destructive',
                    disabled: { fieldName: 'isaActive' },
                    iconPosition: 'left'
                }
            },
            //{label: 'Offer Accepted', fieldName: 'Accept_Offer__c', type: 'boolean'}
        ]);
    },

    toastMsg: function(strType, strMessage) {
        var showToast = $A.get("e.force:showToast");
        showToast.setParams({
            message: strMessage,
            type: strType,
            mode: 'sticky'
        });
        showToast.fire();
    }



})