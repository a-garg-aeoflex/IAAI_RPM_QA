import { LightningElement, api, track, wire } from 'lwc';
import doAcceptOffer from '@salesforce/apex/BoltOnController.doAcceptOffer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import DECLINE_REASON from '@salesforce/schema/VPE_Listings__c.Decline_Reason__c';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class BoltOnListings extends LightningElement {
    @api records;
    @track recordDetail;
    showSpinner;

    get isMobile() {
        return FORM_FACTOR === 'Small';
    }

    @wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: DECLINE_REASON })
    reasonOfRejection;

    showMoreDetail(event) {
        let tempRecords = JSON.parse(JSON.stringify(this.records));
        this.recordDetail = tempRecords.find((element) => element.Id === event.target.dataset.id);
    }

    hideModal() {
        this.recordDetail = undefined;
    }

    doAcceptOffer(event) {
        try {
            let fields = new Object();
            fields.Id = this.recordDetail.Id;
            let toastMessage = 'Offer Accepted Successfully';
            if (event.target.dataset.name === 'reject') {
                let input = this.template.querySelector('lightning-combobox');
                if (input.value) {
                    toastMessage = 'Offer Rejected';
                    fields.Status_of_Listing__c = 'Lost';
                    fields.Decline_Reason__c = input.value;
                } else {
                    input.reportValidity();
                    this.dispatchEvent(new ShowToastEvent({
                        message: 'Please select a reason for declining the offer',
                        variant: 'error'
                    }));
                    return;
                }
            } else {
                fields.Status_of_Listing__c = 'Won';
            }
            console.log(fields);
            debugger;
            this.showSpinner = true;
            doAcceptOffer({ listing: fields })
                .then(result => {
                    if (result) {
                        this.dispatchEvent(new ShowToastEvent({
                            title: 'SUCCESS',
                            message: toastMessage,
                            variant: 'success'
                        }));
                        location.reload();
                    }
                })
                .catch(error => {
                    this.showSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'ERROR',
                        message: error.body.message,
                        variant: 'error'
                    }));
                });
        } catch (error) {
            console.error(error);
        }
    }
}