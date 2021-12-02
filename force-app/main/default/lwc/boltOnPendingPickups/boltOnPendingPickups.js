import { LightningElement, api, track, wire } from 'lwc';
import fetchListingsPendingForPickup from '@salesforce/apex/BoltOnController.fetchListingsPendingForPickup';

export default class BoltOnPendingPickups extends LightningElement {
    @api records;
    @track recordDetail;
    showSpinner;

    connectedCallback() {
        this.showSpinner = true;
        fetchListingsPendingForPickup()
            .then(result => {
                if (result) {
                    let newResult = [];
                    result.forEach(element => {
                        let tempData = element;
                        if (!tempData.Stock_Lookup__r) {
                            tempData.Stock_Lookup__r = { PICKUP_DATETIME__c: 'TBD', QUOTED_RELEASE_DATE__c: 'TBD', DISPATCH_DATETIME__c: 'TBD' };
                        } else {
                            tempData.Stock_Lookup__r.PICKUP_DATETIME__c = (tempData.Stock_Lookup__r.PICKUP_DATETIME__c) ? tempData.Stock_Lookup__r.PICKUP_DATETIME__c : 'TBD';
                            tempData.Stock_Lookup__r.QUOTED_RELEASE_DATE__c = (tempData.Stock_Lookup__r.QUOTED_RELEASE_DATE__c) ? tempData.Stock_Lookup__r.QUOTED_RELEASE_DATE__c : 'TBD';
                            tempData.Stock_Lookup__r.DISPATCH_DATETIME__c = (tempData.Stock_Lookup__r.DISPATCH_DATETIME__c) ? tempData.Stock_Lookup__r.DISPATCH_DATETIME__c : 'TBD';
                        }
                        tempData.Stock_Lookup__r.isPickupAvailable = (tempData.Stock_Lookup__r.PICKUP_DATETIME__c === 'TBD') ? false : true;
                        tempData.Stock_Lookup__r.isQuotedAvailable = (tempData.Stock_Lookup__r.QUOTED_RELEASE_DATE__c === 'TBD') ? false : true;
                        tempData.Stock_Lookup__r.isDispatchAvailable = (tempData.Stock_Lookup__r.DISPATCH_DATETIME__c === 'TBD') ? false : true;
                        newResult.push(tempData);
                    });
                    console.log(newResult);
                    this.records = newResult;
                }
                this.showSpinner = false;
            })
            .catch(error => {
                console.error(error);
            });
    }

    showMoreDetail(event) {
        let tempRecords = JSON.parse(JSON.stringify(this.records));
        this.recordDetail = tempRecords.find((element) => element.Id === event.target.dataset.id);
    }
}